import { Database } from './Database';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface ProgramEnrollment {
  id: number;
  userId: number;
  programId: number;
  startDate: Date;
  endDate: Date | null;
  currentWeek: number;
  currentDay: number;
  completionRate: number;
  isActive: boolean;
}

export interface WorkoutSession {
  id: number;
  enrollmentId: number;
  weekNumber: number;
  dayNumber: number;
  workoutType: string;
  exercises: string[];
  completed: boolean;
  completedAt: Date | null;
  duration: number;
  notes: string;
}

export interface ProgramProgress {
  enrollment: ProgramEnrollment;
  totalWorkouts: number;
  completedWorkouts: number;
  currentWeekProgress: number;
  overallProgress: number;
  nextWorkout: WorkoutSession | null;
  recentSessions: WorkoutSession[];
}

export class ProgramQueries {
  /**
   * Enroll user in a training program
   */
  static async enrollInProgram(userId: number, programId: number): Promise<number> {
    try {
      const db = await Database.getInstance();
      
      // Check if already enrolled in an active program
      const activeCheck = await db.executeSql(
        'SELECT id FROM program_enrollments WHERE user_id = ? AND is_active = 1',
        [userId]
      );
      
      if (activeCheck[0].rows.length > 0) {
        // Deactivate previous enrollment
        await db.executeSql(
          'UPDATE program_enrollments SET is_active = 0 WHERE user_id = ? AND is_active = 1',
          [userId]
        );
      }
      
      // Create new enrollment
      const startDate = new Date().toISOString();
      const result = await db.executeSql(
        `INSERT INTO program_enrollments 
         (user_id, program_id, start_date, current_week, current_day, completion_rate, is_active) 
         VALUES (?, ?, ?, 1, 1, 0, 1)`,
        [userId, programId, startDate]
      );
      
      const enrollmentId = result[0].insertId;
      
      // Create workout sessions based on program
      await this.createWorkoutSessions(enrollmentId, programId);
      
      return enrollmentId;
    } catch (error) {
      console.error('Error enrolling in program:', error);
      throw error;
    }
  }
  
  /**
   * Create workout sessions for enrollment
   */
  private static async createWorkoutSessions(enrollmentId: number, programId: number): Promise<void> {
    try {
      const db = await Database.getInstance();
      
      // Get program details
      const programDetails = this.getProgramDetails(programId);
      
      for (const week of programDetails.weeks) {
        for (let dayIndex = 0; dayIndex < week.workouts.length; dayIndex++) {
          const workout = week.workouts[dayIndex];
          
          await db.executeSql(
            `INSERT INTO workout_sessions 
             (enrollment_id, week_number, day_number, workout_type, exercises, completed, duration, notes) 
             VALUES (?, ?, ?, ?, ?, 0, 0, '')`,
            [
              enrollmentId,
              week.week,
              dayIndex + 1,
              workout.type,
              JSON.stringify(workout.exercises)
            ]
          );
        }
      }
    } catch (error) {
      console.error('Error creating workout sessions:', error);
      throw error;
    }
  }
  
  /**
   * Get active program enrollment for user
   */
  static async getActiveEnrollment(userId: number): Promise<ProgramEnrollment | null> {
    try {
      const db = await Database.getInstance();
      
      const result = await db.executeSql(
        `SELECT * FROM program_enrollments 
         WHERE user_id = ? AND is_active = 1 
         ORDER BY start_date DESC LIMIT 1`,
        [userId]
      );
      
      if (result[0].rows.length === 0) return null;
      
      const row = result[0].rows.item(0);
      return {
        id: row.id,
        userId: row.user_id,
        programId: row.program_id,
        startDate: new Date(row.start_date),
        endDate: row.end_date ? new Date(row.end_date) : null,
        currentWeek: row.current_week,
        currentDay: row.current_day,
        completionRate: row.completion_rate,
        isActive: row.is_active === 1,
      };
    } catch (error) {
      console.error('Error getting active enrollment:', error);
      return null;
    }
  }
  
  /**
   * Get program progress
   */
  static async getProgramProgress(enrollmentId: number): Promise<ProgramProgress | null> {
    try {
      const db = await Database.getInstance();
      
      // Get enrollment details
      const enrollmentResult = await db.executeSql(
        'SELECT * FROM program_enrollments WHERE id = ?',
        [enrollmentId]
      );
      
      if (enrollmentResult[0].rows.length === 0) return null;
      
      const enrollmentRow = enrollmentResult[0].rows.item(0);
      const enrollment: ProgramEnrollment = {
        id: enrollmentRow.id,
        userId: enrollmentRow.user_id,
        programId: enrollmentRow.program_id,
        startDate: new Date(enrollmentRow.start_date),
        endDate: enrollmentRow.end_date ? new Date(enrollmentRow.end_date) : null,
        currentWeek: enrollmentRow.current_week,
        currentDay: enrollmentRow.current_day,
        completionRate: enrollmentRow.completion_rate,
        isActive: enrollmentRow.is_active === 1,
      };
      
      // Get workout sessions
      const sessionsResult = await db.executeSql(
        'SELECT * FROM workout_sessions WHERE enrollment_id = ? ORDER BY week_number, day_number',
        [enrollmentId]
      );
      
      let totalWorkouts = 0;
      let completedWorkouts = 0;
      let currentWeekCompleted = 0;
      let currentWeekTotal = 0;
      const recentSessions: WorkoutSession[] = [];
      let nextWorkout: WorkoutSession | null = null;
      
      for (let i = 0; i < sessionsResult[0].rows.length; i++) {
        const session = sessionsResult[0].rows.item(i);
        totalWorkouts++;
        
        if (session.completed) {
          completedWorkouts++;
          
          // Add to recent sessions
          if (recentSessions.length < 5) {
            recentSessions.push({
              id: session.id,
              enrollmentId: session.enrollment_id,
              weekNumber: session.week_number,
              dayNumber: session.day_number,
              workoutType: session.workout_type,
              exercises: JSON.parse(session.exercises || '[]'),
              completed: true,
              completedAt: new Date(session.completed_at),
              duration: session.duration,
              notes: session.notes,
            });
          }
        }
        
        // Count current week progress
        if (session.week_number === enrollment.currentWeek) {
          currentWeekTotal++;
          if (session.completed) currentWeekCompleted++;
        }
        
        // Find next workout
        if (!nextWorkout && !session.completed) {
          nextWorkout = {
            id: session.id,
            enrollmentId: session.enrollment_id,
            weekNumber: session.week_number,
            dayNumber: session.day_number,
            workoutType: session.workout_type,
            exercises: JSON.parse(session.exercises || '[]'),
            completed: false,
            completedAt: null,
            duration: 0,
            notes: '',
          };
        }
      }
      
      const overallProgress = totalWorkouts > 0 ? Math.round((completedWorkouts / totalWorkouts) * 100) : 0;
      const currentWeekProgress = currentWeekTotal > 0 ? Math.round((currentWeekCompleted / currentWeekTotal) * 100) : 0;
      
      // Update completion rate in enrollment
      if (enrollment.completionRate !== overallProgress) {
        await db.executeSql(
          'UPDATE program_enrollments SET completion_rate = ? WHERE id = ?',
          [overallProgress, enrollmentId]
        );
      }
      
      return {
        enrollment,
        totalWorkouts,
        completedWorkouts,
        currentWeekProgress,
        overallProgress,
        nextWorkout,
        recentSessions,
      };
    } catch (error) {
      console.error('Error getting program progress:', error);
      return null;
    }
  }
  
  /**
   * Complete a workout session
   */
  static async completeWorkoutSession(
    sessionId: number, 
    duration: number, 
    notes: string = ''
  ): Promise<void> {
    try {
      const db = await Database.getInstance();
      
      const completedAt = new Date().toISOString();
      
      await db.executeSql(
        `UPDATE workout_sessions 
         SET completed = 1, completed_at = ?, duration = ?, notes = ? 
         WHERE id = ?`,
        [completedAt, duration, notes, sessionId]
      );
      
      // Get session details to update enrollment progress
      const sessionResult = await db.executeSql(
        'SELECT * FROM workout_sessions WHERE id = ?',
        [sessionId]
      );
      
      if (sessionResult[0].rows.length > 0) {
        const session = sessionResult[0].rows.item(0);
        
        // Update current week/day in enrollment
        await db.executeSql(
          `UPDATE program_enrollments 
           SET current_week = ?, current_day = ? 
           WHERE id = ?`,
          [session.week_number, session.day_number + 1, session.enrollment_id]
        );
      }
    } catch (error) {
      console.error('Error completing workout session:', error);
      throw error;
    }
  }
  
  /**
   * Get program details (static data)
   */
  private static getProgramDetails(programId: number): any {
    const programDetails = {
      1: {
        weeks: [
          {
            week: 1,
            workouts: [
              { type: '피트니스', exercises: ['스쿼트', '런지', '플랭크'] },
              { type: '스쿼시', exercises: ['포핸드 드라이브', '백핸드 연습'] },
              { type: '피트니스', exercises: ['인터벌 러닝', '코어 운동'] },
              { type: '휴식', exercises: [] },
              { type: '스쿼시', exercises: ['볼리 연습', '서브 연습'] },
              { type: '피트니스', exercises: ['전신 운동'] },
              { type: '휴식', exercises: [] },
            ],
          },
          {
            week: 2,
            workouts: [
              { type: '스쿼시', exercises: ['고강도 드릴', '게임 시뮬레이션'] },
              { type: '피트니스', exercises: ['웨이트 트레이닝', '민첩성 훈련'] },
              { type: '스쿼시', exercises: ['전술 훈련', '포지션 연습'] },
              { type: '피트니스', exercises: ['회복 운동', '스트레칭'] },
              { type: '스쿼시', exercises: ['매치 플레이'] },
              { type: '피트니스', exercises: ['고강도 인터벌'] },
              { type: '휴식', exercises: [] },
            ],
          },
          {
            week: 3,
            workouts: [
              { type: '피트니스', exercises: ['근력 강화', '폭발력 훈련'] },
              { type: '스쿼시', exercises: ['드롭샷', '크로스코트'] },
              { type: '피트니스', exercises: ['지구력 훈련'] },
              { type: '스쿼시', exercises: ['게임 전략'] },
              { type: '휴식', exercises: [] },
              { type: '스쿼시', exercises: ['토너먼트 시뮬레이션'] },
              { type: '휴식', exercises: [] },
            ],
          },
          {
            week: 4,
            workouts: [
              { type: '스쿼시', exercises: ['종합 기술 연습'] },
              { type: '피트니스', exercises: ['회복 운동'] },
              { type: '스쿼시', exercises: ['실전 게임'] },
              { type: '휴식', exercises: [] },
              { type: '스쿼시', exercises: ['평가전'] },
              { type: '피트니스', exercises: ['쿨다운'] },
              { type: '휴식', exercises: [] },
            ],
          },
        ],
      },
      // Add more programs as needed
    };
    
    return programDetails[programId] || programDetails[1];
  }
}
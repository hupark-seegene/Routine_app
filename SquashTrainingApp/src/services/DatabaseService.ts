import SQLite from 'react-native-sqlite-storage';
import {
  UserProfile,
  TrainingProgram,
  WeeklyPlan,
  DailyWorkout,
  Exercise,
  WorkoutLog,
  UserMemo,
  AIAdvice,
  NotificationSettings,
} from '../types';
import { DatabaseOptimized, BackupMetadata, AnalyticsData } from '../database/DatabaseOptimized';

// Enable debugging
SQLite.enablePromise(true);
SQLite.DEBUG(__DEV__);

class DatabaseService {
  private db: SQLite.SQLiteDatabase | null = null;
  private dbOptimized: DatabaseOptimized;

  constructor() {
    this.dbOptimized = DatabaseOptimized.getInstance();
  }

  // Initialize database connection with optimizations
  async init(): Promise<void> {
    try {
      // Initialize optimized database with indexes
      await this.dbOptimized.initializeDatabase();
      this.db = await this.dbOptimized.getDBConnection();
      
      // Schedule periodic optimization
      setInterval(async () => {
        await this.dbOptimized.cleanupCache();
      }, 3600000); // Every hour
      
      // Schedule weekly optimization
      setInterval(async () => {
        await this.dbOptimized.optimizeDatabase();
      }, 604800000); // Every week
      
      console.log('Database initialized with optimizations');
    } catch (error) {
      console.error('Database initialization error:', error);
      throw error;
    }
  }

  // Ensure database is initialized
  private async ensureDatabase(): Promise<SQLite.SQLiteDatabase> {
    if (!this.db) {
      this.db = await this.dbOptimized.getDBConnection();
    }
    if (!this.db) {
      throw new Error('Database not initialized');
    }
    return this.db;
  }

  // Close database connection
  async close(): Promise<void> {
    if (this.db) {
      await this.db.close();
      this.db = null;
    }
  }

  // User Profile Operations
  async createOrUpdateUserProfile(profile: Omit<UserProfile, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const db = await this.ensureDatabase();
    const now = new Date().toISOString();

    // Check if profile exists
    const existing = await db.executeSql(
      'SELECT id FROM user_profile WHERE id = 1'
    );

    if (existing[0].rows.length > 0) {
      // Update existing profile
      await db.executeSql(
        `UPDATE user_profile SET 
          name = ?, age = ?, level = ?, experience_years = ?, 
          goals = ?, injuries = ?, available_days = ?, 
          preferred_time = ?, equipment = ?, updated_at = ?
        WHERE id = 1`,
        [
          profile.name,
          profile.age,
          profile.level,
          profile.experience_years,
          profile.goals,
          profile.injuries,
          JSON.stringify(profile.available_days),
          profile.preferred_time,
          profile.equipment,
          now,
        ]
      );
      return 1;
    } else {
      // Insert new profile
      const result = await db.executeSql(
        `INSERT INTO user_profile 
          (name, age, level, experience_years, goals, injuries, 
           available_days, preferred_time, equipment, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          profile.name,
          profile.age,
          profile.level,
          profile.experience_years,
          profile.goals,
          profile.injuries,
          JSON.stringify(profile.available_days),
          profile.preferred_time,
          profile.equipment,
          now,
          now,
        ]
      );
      return result[0].insertId;
    }
  }

  async getUserProfile(): Promise<UserProfile | null> {
    const db = await this.ensureDatabase();
    const result = await db.executeSql('SELECT * FROM user_profile WHERE id = 1');
    
    if (result[0].rows.length > 0) {
      const row = result[0].rows.item(0);
      return {
        ...row,
        available_days: JSON.parse(row.available_days || '[]'),
      };
    }
    return null;
  }

  // Training Program Operations
  async getActiveProgram(): Promise<TrainingProgram | null> {
    const db = await this.ensureDatabase();
    const result = await db.executeSql(
      'SELECT * FROM training_programs WHERE is_active = 1 ORDER BY start_date DESC LIMIT 1'
    );
    
    if (result[0].rows.length > 0) {
      return result[0].rows.item(0);
    }
    return null;
  }

  async createProgram(program: Omit<TrainingProgram, 'id'>): Promise<number> {
    const db = await this.ensureDatabase();
    const result = await db.executeSql(
      `INSERT INTO training_programs 
        (user_id, program_type, name, duration_weeks, start_date, 
         end_date, current_week, is_active, goals, notes)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        program.user_id,
        program.program_type,
        program.name,
        program.duration_weeks,
        program.start_date,
        program.end_date,
        program.current_week,
        program.is_active ? 1 : 0,
        program.goals,
        program.notes,
      ]
    );
    return result[0].insertId;
  }

  async updateProgramWeek(programId: number, week: number): Promise<void> {
    const db = await this.ensureDatabase();
    await db.executeSql(
      'UPDATE training_programs SET current_week = ? WHERE id = ?',
      [week, programId]
    );
  }

  // Workout Log Operations
  async saveWorkoutLog(log: Omit<WorkoutLog, 'id' | 'logged_at'>): Promise<number> {
    const db = await this.ensureDatabase();
    const now = new Date().toISOString();
    
    const result = await db.executeSql(
      `INSERT INTO workout_logs 
        (user_id, program_id, workout_id, date, duration_minutes, 
         intensity_level, fatigue_level, condition_score, 
         exercises_completed, notes, logged_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        log.user_id,
        log.program_id,
        log.workout_id,
        log.date,
        log.duration_minutes,
        log.intensity_level,
        log.fatigue_level,
        log.condition_score,
        JSON.stringify(log.exercises_completed || []),
        log.notes,
        now,
      ]
    );
    return result[0].insertId;
  }

  async getWorkoutLogs(userId: number, limit: number = 30): Promise<WorkoutLog[]> {
    const db = await this.ensureDatabase();
    const result = await db.executeSql(
      `SELECT * FROM workout_logs 
       WHERE user_id = ? 
       ORDER BY date DESC 
       LIMIT ?`,
      [userId, limit]
    );
    
    const logs: WorkoutLog[] = [];
    for (let i = 0; i < result[0].rows.length; i++) {
      const row = result[0].rows.item(i);
      logs.push({
        ...row,
        exercises_completed: JSON.parse(row.exercises_completed || '[]'),
      });
    }
    return logs;
  }

  async getWorkoutLogsByDateRange(
    userId: number,
    startDate: string,
    endDate: string
  ): Promise<WorkoutLog[]> {
    const db = await this.ensureDatabase();
    const result = await db.executeSql(
      `SELECT * FROM workout_logs 
       WHERE user_id = ? AND date BETWEEN ? AND ?
       ORDER BY date DESC`,
      [userId, startDate, endDate]
    );
    
    const logs: WorkoutLog[] = [];
    for (let i = 0; i < result[0].rows.length; i++) {
      const row = result[0].rows.item(i);
      logs.push({
        ...row,
        exercises_completed: JSON.parse(row.exercises_completed || '[]'),
      });
    }
    return logs;
  }

  // Statistics Operations
  async getTrainingStats(userId: number, days: number = 30): Promise<{
    totalWorkouts: number;
    totalMinutes: number;
    averageIntensity: number;
    averageFatigue: number;
    averageCondition: number;
    completionRate: number;
  }> {
    const db = await this.ensureDatabase();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    
    const result = await db.executeSql(
      `SELECT 
        COUNT(*) as totalWorkouts,
        SUM(duration_minutes) as totalMinutes,
        AVG(intensity_level) as averageIntensity,
        AVG(fatigue_level) as averageFatigue,
        AVG(condition_score) as averageCondition
       FROM workout_logs 
       WHERE user_id = ? AND date >= ?`,
      [userId, startDate.toISOString().split('T')[0]]
    );
    
    const stats = result[0].rows.item(0);
    
    // Calculate completion rate
    const plannedWorkouts = Math.floor(days * 0.7); // Assuming 5 workouts per week
    const completionRate = plannedWorkouts > 0 
      ? (stats.totalWorkouts / plannedWorkouts) * 100 
      : 0;
    
    return {
      totalWorkouts: stats.totalWorkouts || 0,
      totalMinutes: stats.totalMinutes || 0,
      averageIntensity: parseFloat(stats.averageIntensity) || 0,
      averageFatigue: parseFloat(stats.averageFatigue) || 0,
      averageCondition: parseFloat(stats.averageCondition) || 0,
      completionRate: Math.min(completionRate, 100),
    };
  }

  async getWeeklyStats(userId: number): Promise<{
    day: string;
    workouts: number;
    minutes: number;
  }[]> {
    const db = await this.ensureDatabase();
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    
    const result = await db.executeSql(
      `SELECT 
        date,
        COUNT(*) as workouts,
        SUM(duration_minutes) as minutes
       FROM workout_logs 
       WHERE user_id = ? AND date >= ?
       GROUP BY date
       ORDER BY date`,
      [userId, weekAgo.toISOString().split('T')[0]]
    );
    
    const stats = [];
    for (let i = 0; i < result[0].rows.length; i++) {
      const row = result[0].rows.item(i);
      stats.push({
        day: row.date,
        workouts: row.workouts,
        minutes: row.minutes || 0,
      });
    }
    return stats;
  }

  // User Memo Operations
  async saveMemo(memo: Omit<UserMemo, 'id' | 'created_at'>): Promise<number> {
    const db = await this.ensureDatabase();
    const now = new Date().toISOString();
    
    const result = await db.executeSql(
      `INSERT INTO user_memos 
        (user_id, workout_log_id, date, type, content, tags, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        memo.user_id,
        memo.workout_log_id,
        memo.date,
        memo.type,
        memo.content,
        memo.tags,
        now,
      ]
    );
    return result[0].insertId;
  }

  async getMemos(userId: number, limit: number = 20): Promise<UserMemo[]> {
    const db = await this.ensureDatabase();
    const result = await db.executeSql(
      `SELECT * FROM user_memos 
       WHERE user_id = ? 
       ORDER BY created_at DESC 
       LIMIT ?`,
      [userId, limit]
    );
    
    const memos: UserMemo[] = [];
    for (let i = 0; i < result[0].rows.length; i++) {
      memos.push(result[0].rows.item(i));
    }
    return memos;
  }

  // AI Advice Operations
  async saveAIAdvice(advice: Omit<AIAdvice, 'id' | 'created_at'>): Promise<number> {
    const db = await this.ensureDatabase();
    const now = new Date().toISOString();
    
    const result = await db.executeSql(
      `INSERT INTO ai_advice 
        (user_id, date, advice_type, content, context_data, applied, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        advice.user_id,
        advice.date,
        advice.advice_type,
        advice.content,
        JSON.stringify(advice.context_data || {}),
        advice.applied ? 1 : 0,
        now,
      ]
    );
    return result[0].insertId;
  }

  async getLatestAIAdvice(userId: number, type?: string): Promise<AIAdvice | null> {
    const db = await this.ensureDatabase();
    
    let query = 'SELECT * FROM ai_advice WHERE user_id = ?';
    const params: any[] = [userId];
    
    if (type) {
      query += ' AND advice_type = ?';
      params.push(type);
    }
    
    query += ' ORDER BY created_at DESC LIMIT 1';
    
    const result = await db.executeSql(query, params);
    
    if (result[0].rows.length > 0) {
      const row = result[0].rows.item(0);
      return {
        ...row,
        context_data: JSON.parse(row.context_data || '{}'),
        applied: row.applied === 1,
      };
    }
    return null;
  }

  // Notification Settings Operations
  async saveNotificationSettings(
    settings: Omit<NotificationSettings, 'id' | 'updated_at'>
  ): Promise<void> {
    const db = await this.ensureDatabase();
    const now = new Date().toISOString();
    
    // Check if settings exist
    const existing = await db.executeSql(
      'SELECT id FROM notification_settings WHERE user_id = ?',
      [settings.user_id]
    );
    
    if (existing[0].rows.length > 0) {
      // Update existing settings
      await db.executeSql(
        `UPDATE notification_settings SET 
          daily_reminder_enabled = ?, daily_reminder_time = ?,
          weekly_report_enabled = ?, weekly_report_day = ?,
          achievement_alerts = ?, ai_suggestions = ?,
          push_enabled = ?, email_enabled = ?, updated_at = ?
        WHERE user_id = ?`,
        [
          settings.daily_reminder_enabled ? 1 : 0,
          settings.daily_reminder_time,
          settings.weekly_report_enabled ? 1 : 0,
          settings.weekly_report_day,
          settings.achievement_alerts ? 1 : 0,
          settings.ai_suggestions ? 1 : 0,
          settings.push_enabled ? 1 : 0,
          settings.email_enabled ? 1 : 0,
          now,
          settings.user_id,
        ]
      );
    } else {
      // Insert new settings
      await db.executeSql(
        `INSERT INTO notification_settings 
          (user_id, daily_reminder_enabled, daily_reminder_time,
           weekly_report_enabled, weekly_report_day, achievement_alerts,
           ai_suggestions, push_enabled, email_enabled, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          settings.user_id,
          settings.daily_reminder_enabled ? 1 : 0,
          settings.daily_reminder_time,
          settings.weekly_report_enabled ? 1 : 0,
          settings.weekly_report_day,
          settings.achievement_alerts ? 1 : 0,
          settings.ai_suggestions ? 1 : 0,
          settings.push_enabled ? 1 : 0,
          settings.email_enabled ? 1 : 0,
          now,
        ]
      );
    }
  }

  async getNotificationSettings(userId: number): Promise<NotificationSettings | null> {
    const db = await this.ensureDatabase();
    const result = await db.executeSql(
      'SELECT * FROM notification_settings WHERE user_id = ?',
      [userId]
    );
    
    if (result[0].rows.length > 0) {
      const row = result[0].rows.item(0);
      return {
        ...row,
        daily_reminder_enabled: row.daily_reminder_enabled === 1,
        weekly_report_enabled: row.weekly_report_enabled === 1,
        achievement_alerts: row.achievement_alerts === 1,
        ai_suggestions: row.ai_suggestions === 1,
        push_enabled: row.push_enabled === 1,
        email_enabled: row.email_enabled === 1,
      };
    }
    return null;
  }

  // Daily Workout Operations
  async getTodayWorkout(userId: number): Promise<DailyWorkout | null> {
    const db = await this.ensureDatabase();
    const today = new Date().toISOString().split('T')[0];
    
    // First get active program
    const activeProgram = await this.getActiveProgram();
    if (!activeProgram) return null;
    
    // Get today's workout
    const result = await db.executeSql(
      `SELECT dw.* FROM daily_workouts dw
       JOIN weekly_plans wp ON dw.weekly_plan_id = wp.id
       WHERE wp.program_id = ? AND dw.date = ?
       LIMIT 1`,
      [activeProgram.id, today]
    );
    
    if (result[0].rows.length > 0) {
      const workout = result[0].rows.item(0);
      
      // Get exercises for this workout
      const exerciseResult = await db.executeSql(
        `SELECT * FROM exercises 
         WHERE id IN (${workout.exercise_ids || ''})
         ORDER BY order_index`
      );
      
      const exercises: Exercise[] = [];
      for (let i = 0; i < exerciseResult[0].rows.length; i++) {
        exercises.push(exerciseResult[0].rows.item(i));
      }
      
      return {
        ...workout,
        exercises,
      };
    }
    return null;
  }

  // Helper method to get user training data for AI analysis
  async getUserTrainingData(userId: number): Promise<{
    profile: UserProfile | null;
    recentWorkouts: WorkoutLog[];
    stats: any;
    currentProgram: TrainingProgram | null;
  }> {
    const [profile, recentWorkouts, stats, currentProgram] = await Promise.all([
      this.getUserProfile(),
      this.getWorkoutLogs(userId, 14), // Last 2 weeks
      this.getTrainingStats(userId, 30),
      this.getActiveProgram(),
    ]);
    
    return {
      profile,
      recentWorkouts,
      stats,
      currentProgram,
    };
  }

  // Backup and Restore functionality
  async createBackup(backupName?: string): Promise<string> {
    return await this.dbOptimized.createBackup(backupName);
  }

  async restoreBackup(backupPath: string): Promise<void> {
    return await this.dbOptimized.restoreBackup(backupPath);
  }

  // Analytics functionality
  async getAnalytics(userId: number = 1, days: number = 30): Promise<AnalyticsData> {
    return await this.dbOptimized.getAnalytics(userId, days);
  }

  async getWeakAreaAnalysis(userId: number = 1): Promise<any> {
    return await this.dbOptimized.getWeakAreaAnalysis(userId);
  }

  async getProgressTrend(userId: number = 1, exerciseId?: number): Promise<any> {
    return await this.dbOptimized.getProgressTrend(userId, exerciseId);
  }

  // Performance monitoring
  async getPerformanceMetrics(): Promise<{
    cacheHitRate: number;
    avgQueryTime: number;
    totalQueries: number;
  }> {
    const db = await this.ensureDatabase();
    
    // Get cache statistics
    const [cacheStats] = await db.executeSql(
      `SELECT COUNT(*) as total_cached,
        SUM(CASE WHEN expires_at > datetime('now') THEN 1 ELSE 0 END) as valid_cached
       FROM analytics_cache`
    );
    
    const stats = cacheStats.rows.item(0);
    const cacheHitRate = stats.total_cached > 0 
      ? (stats.valid_cached / stats.total_cached) * 100 
      : 0;
    
    return {
      cacheHitRate,
      avgQueryTime: 0, // Would need to implement query timing
      totalQueries: 0  // Would need to implement query counting
    };
  }

  // Custom Exercise Operations
  async addCustomExercise(exercise: {
    name: string;
    category: string;
    type: string;
    muscle_groups: string;
    equipment: string;
    difficulty_level: string;
    instructions: string;
    benefits: string;
    video_url?: string;
    image_url?: string;
    created_by: number;
  }): Promise<number> {
    const db = await this.ensureDatabase();
    
    const result = await db.executeSql(
      `INSERT INTO exercises 
        (name, category, type, muscle_groups, equipment, difficulty_level,
         instructions, benefits, video_url, image_url, created_by, is_custom)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`,
      [
        exercise.name,
        exercise.category,
        exercise.type,
        exercise.muscle_groups,
        exercise.equipment,
        exercise.difficulty_level,
        exercise.instructions,
        exercise.benefits,
        exercise.video_url || null,
        exercise.image_url || null,
        exercise.created_by,
      ]
    );
    
    return result[0].insertId;
  }

  async getCustomExercises(userId: number): Promise<Exercise[]> {
    const db = await this.ensureDatabase();
    
    const result = await db.executeSql(
      `SELECT * FROM exercises 
       WHERE is_custom = 1 AND created_by = ?
       ORDER BY name`,
      [userId]
    );
    
    const exercises: Exercise[] = [];
    for (let i = 0; i < result[0].rows.length; i++) {
      exercises.push(result[0].rows.item(i));
    }
    
    return exercises;
  }

  async updateCustomExercise(
    exerciseId: number,
    userId: number,
    updates: Partial<{
      name: string;
      category: string;
      type: string;
      muscle_groups: string;
      equipment: string;
      difficulty_level: string;
      instructions: string;
      benefits: string;
      video_url: string;
      image_url: string;
    }>
  ): Promise<void> {
    const db = await this.ensureDatabase();
    
    // Build dynamic update query
    const updateFields = Object.keys(updates);
    const setClause = updateFields.map(field => `${field} = ?`).join(', ');
    const values = updateFields.map(field => updates[field as keyof typeof updates]);
    
    await db.executeSql(
      `UPDATE exercises 
       SET ${setClause}
       WHERE id = ? AND is_custom = 1 AND created_by = ?`,
      [...values, exerciseId, userId]
    );
  }

  async deleteCustomExercise(exerciseId: number, userId: number): Promise<void> {
    const db = await this.ensureDatabase();
    
    await db.executeSql(
      `DELETE FROM exercises 
       WHERE id = ? AND is_custom = 1 AND created_by = ?`,
      [exerciseId, userId]
    );
  }

  // Custom Workout Operations
  async saveCustomWorkout(workout: {
    name: string;
    type: string;
    exercises: Array<{
      exerciseId?: number;
      name: string;
      category: string;
      sets?: string;
      reps?: string;
      duration?: string;
      intensity: string;
      instructions?: string;
    }>;
    userId: number;
  }): Promise<number> {
    const db = await this.ensureDatabase();
    const now = new Date().toISOString();
    
    // Start transaction
    await db.executeSql('BEGIN TRANSACTION');
    
    try {
      // Create daily workout entry
      const workoutResult = await db.executeSql(
        `INSERT INTO daily_workouts 
          (name, workout_type, total_duration, intensity_level, 
           focus_areas, is_custom, created_by, created_at)
        VALUES (?, ?, ?, ?, ?, 1, ?, ?)`,
        [
          workout.name,
          workout.type,
          this.calculateTotalDuration(workout.exercises),
          this.calculateAverageIntensity(workout.exercises),
          workout.type,
          workout.userId,
          now,
        ]
      );
      
      const workoutId = workoutResult[0].insertId;
      
      // Add exercises to workout
      for (const exercise of workout.exercises) {
        let exerciseId = exercise.exerciseId;
        
        // If no exerciseId, create a custom exercise
        if (!exerciseId) {
          const exResult = await db.executeSql(
            `INSERT INTO exercises 
              (name, category, type, difficulty_level, instructions, is_custom, created_by)
            VALUES (?, ?, ?, ?, ?, 1, ?)`,
            [
              exercise.name,
              exercise.category,
              workout.type,
              exercise.intensity,
              exercise.instructions || '',
              workout.userId,
            ]
          );
          exerciseId = exResult[0].insertId;
        }
        
        // Link exercise to workout
        await db.executeSql(
          `INSERT INTO workout_exercises 
            (workout_id, exercise_id, sets, reps, duration, intensity, order_index)
          VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            workoutId,
            exerciseId,
            exercise.sets || null,
            exercise.reps || null,
            exercise.duration || null,
            exercise.intensity,
            workout.exercises.indexOf(exercise),
          ]
        );
      }
      
      await db.executeSql('COMMIT');
      return workoutId;
      
    } catch (error) {
      await db.executeSql('ROLLBACK');
      throw error;
    }
  }

  async getCustomWorkouts(userId: number): Promise<DailyWorkout[]> {
    const db = await this.ensureDatabase();
    
    const result = await db.executeSql(
      `SELECT * FROM daily_workouts 
       WHERE is_custom = 1 AND created_by = ?
       ORDER BY created_at DESC`,
      [userId]
    );
    
    const workouts: DailyWorkout[] = [];
    for (let i = 0; i < result[0].rows.length; i++) {
      const workout = result[0].rows.item(i);
      
      // Get exercises for this workout
      const exerciseResult = await db.executeSql(
        `SELECT e.*, we.sets, we.reps, we.duration, we.intensity, we.order_index
         FROM exercises e
         JOIN workout_exercises we ON e.id = we.exercise_id
         WHERE we.workout_id = ?
         ORDER BY we.order_index`,
        [workout.id]
      );
      
      const exercises: Exercise[] = [];
      for (let j = 0; j < exerciseResult[0].rows.length; j++) {
        exercises.push(exerciseResult[0].rows.item(j));
      }
      
      workouts.push({
        ...workout,
        exercises,
      });
    }
    
    return workouts;
  }

  // Helper methods for custom workouts
  private calculateTotalDuration(exercises: any[]): number {
    return exercises.reduce((total, exercise) => {
      if (exercise.duration) {
        return total + parseInt(exercise.duration);
      } else if (exercise.sets && exercise.reps) {
        // Estimate 1 minute per set
        return total + parseInt(exercise.sets);
      }
      return total;
    }, 0);
  }

  private calculateAverageIntensity(exercises: any[]): string {
    const intensityMap = { low: 1, medium: 2, high: 3 };
    const total = exercises.reduce((sum, ex) => sum + (intensityMap[ex.intensity as keyof typeof intensityMap] || 2), 0);
    const avg = total / exercises.length;
    
    if (avg <= 1.5) return 'low';
    if (avg <= 2.5) return 'medium';
    return 'high';
  }
}

// Export singleton instance
export default new DatabaseService();
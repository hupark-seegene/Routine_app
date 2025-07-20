import { getDBConnection } from './database';
import achievementService from '../services/achievementService';

export interface UserStats {
  totalWorkouts: number;
  totalHours: number;
  currentStreak: number;
  longestStreak: number;
  completionRate: number;
  level: string;
}

export interface Achievement {
  id: number;
  name: string;
  description: string;
  icon: string;
  color: string;
  requirement: number;
  progress: number;
  unlockedAt: string | null;
  category: string;
}

export class ProfileQueries {
  static async getUserStats(userId: number = 1): Promise<UserStats> {
    try {
      const db = await getDBConnection();
      
      // Get total workouts and hours
      const [workoutStats] = await db.executeSql(`
        SELECT 
          COUNT(*) as totalWorkouts,
          SUM(actual_duration) as totalMinutes,
          SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) as completedWorkouts
        FROM workout_logs
        WHERE user_id = ?
      `, [userId]);
      
      const stats = workoutStats.rows.item(0);
      const totalWorkouts = stats.totalWorkouts || 0;
      const totalHours = Math.round((stats.totalMinutes || 0) / 60);
      const completedWorkouts = stats.completedWorkouts || 0;
      const completionRate = totalWorkouts > 0 
        ? Math.round((completedWorkouts / totalWorkouts) * 100)
        : 0;
      
      // Calculate streaks
      const [recentWorkouts] = await db.executeSql(`
        SELECT date, completed
        FROM workout_logs
        WHERE user_id = ?
        ORDER BY date DESC
        LIMIT 365
      `, [userId]);
      
      const workouts = [];
      for (let i = 0; i < recentWorkouts.rows.length; i++) {
        workouts.push(recentWorkouts.rows.item(i));
      }
      
      const currentStreak = this.calculateCurrentStreak(workouts);
      const longestStreak = this.calculateLongestStreak(workouts);
      
      // Get user level
      const [userProfile] = await db.executeSql(
        'SELECT level FROM user_profile WHERE id = ?',
        [userId]
      );
      
      const level = userProfile.rows.length > 0 
        ? userProfile.rows.item(0).level 
        : '중급';
      
      return {
        totalWorkouts,
        totalHours,
        currentStreak,
        longestStreak,
        completionRate,
        level,
      };
    } catch (error) {
      console.error('Error getting user stats:', error);
      return {
        totalWorkouts: 0,
        totalHours: 0,
        currentStreak: 0,
        longestStreak: 0,
        completionRate: 0,
        level: '중급',
      };
    }
  }

  static calculateCurrentStreak(workouts: any[]): number {
    if (!workouts || workouts.length === 0) return 0;
    
    let streak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    for (let i = 0; i < 30; i++) {
      const checkDate = new Date(today);
      checkDate.setDate(checkDate.getDate() - i);
      const dateStr = checkDate.toISOString().split('T')[0];
      
      const hasWorkout = workouts.some(w => 
        w.date === dateStr && w.completed
      );
      
      if (hasWorkout) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    
    return streak;
  }

  static calculateLongestStreak(workouts: any[]): number {
    if (!workouts || workouts.length === 0) return 0;
    
    const sortedWorkouts = [...workouts]
      .filter(w => w.completed)
      .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    
    let maxStreak = 0;
    let currentStreak = 0;
    let lastDate: Date | null = null;
    
    sortedWorkouts.forEach(workout => {
      const workoutDate = new Date(workout.date);
      
      if (!lastDate) {
        currentStreak = 1;
      } else {
        const dayDiff = Math.floor(
          (workoutDate.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24)
        );
        
        if (dayDiff === 1) {
          currentStreak++;
        } else {
          maxStreak = Math.max(maxStreak, currentStreak);
          currentStreak = 1;
        }
      }
      
      lastDate = workoutDate;
    });
    
    return Math.max(maxStreak, currentStreak);
  }

  static async getAchievements(userId: number = 1): Promise<Achievement[]> {
    try {
      // Initialize achievement service
      await achievementService.initialize();
      
      // Check for new unlocks
      await achievementService.checkAndUnlockAchievements(userId);
      
      // Get all achievements with progress
      const achievements = await achievementService.getAchievements();
      
      // Map to database format
      return achievements.map((achievement, index) => ({
        id: index + 1,
        name: achievement.title,
        description: achievement.description,
        icon: this.mapIconName(achievement.icon),
        color: this.getTierColor(achievement.tier),
        requirement: achievement.requirement.value,
        progress: Math.round((achievement.progress || 0) * achievement.requirement.value / 100),
        unlockedAt: achievement.unlockedAt || null,
        category: achievement.category,
      }));
    } catch (error) {
      console.error('Error getting achievements:', error);
      return this.getDefaultAchievements();
    }
  }

  static mapIconName(iconName: string): string {
    // Map Material Community Icons to Material Icons
    const iconMap: Record<string, string> = {
      'flag-checkered': 'flag',
      'numeric-10-circle': 'filter-10',
      'medal': 'military-tech',
      'trophy': 'emoji-events',
      'crown': 'stars',
      'fire': 'local-fire-department',
      'calendar-week': 'date-range',
      'calendar-month': 'calendar-today',
      'infinity': 'all-inclusive',
      'clock-time-four': 'access-time',
      'clock-alert': 'alarm',
      'timer-sand': 'hourglass-full',
      'check-all': 'done-all',
      'weather-sunset-up': 'wb-twilight',
      'weather-night': 'nights-stay',
      'lightning-bolt': 'flash-on',
      'shape': 'category',
    };
    
    return iconMap[iconName] || 'star';
  }

  static getTierColor(tier: string): string {
    switch (tier) {
      case 'bronze': return '#CD7F32';
      case 'silver': return '#C0C0C0';
      case 'gold': return '#FFD700';
      case 'platinum': return '#E5E4E2';
      default: return '#4CAF50';
    }
  }

  static getDefaultAchievements(): Achievement[] {
    return [
      {
        id: 1,
        name: '첫 걸음',
        description: '첫 운동을 완료하세요',
        icon: 'flag',
        color: '#CD7F32',
        requirement: 1,
        progress: 0,
        unlockedAt: null,
        category: 'workout',
      },
      {
        id: 2,
        name: '주간 전사',
        description: '7일 연속 운동하기',
        icon: 'local-fire-department',
        color: '#CD7F32',
        requirement: 7,
        progress: 0,
        unlockedAt: null,
        category: 'streak',
      },
      {
        id: 3,
        name: '10회 달성',
        description: '총 10회 운동 완료',
        icon: 'filter-10',
        color: '#CD7F32',
        requirement: 10,
        progress: 0,
        unlockedAt: null,
        category: 'workout',
      },
    ];
  }
}
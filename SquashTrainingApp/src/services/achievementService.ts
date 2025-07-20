import AsyncStorage from '@react-native-async-storage/async-storage';
import databaseService from './databaseService';

export interface Achievement {
  id: string;
  title: string;
  description: string;
  icon: string;
  category: 'workout' | 'streak' | 'skill' | 'milestone' | 'special';
  requirement: {
    type: 'count' | 'streak' | 'time' | 'custom';
    value: number;
    unit?: string;
  };
  progress?: number;
  unlocked: boolean;
  unlockedAt?: string;
  points: number;
  tier: 'bronze' | 'silver' | 'gold' | 'platinum';
}

class AchievementService {
  private achievements: Achievement[] = [
    // Workout Count Achievements
    {
      id: 'first_workout',
      title: 'First Step',
      description: 'Complete your first workout',
      icon: 'flag-checkered',
      category: 'workout',
      requirement: { type: 'count', value: 1 },
      unlocked: false,
      points: 10,
      tier: 'bronze',
    },
    {
      id: 'workout_10',
      title: 'Getting Started',
      description: 'Complete 10 workouts',
      icon: 'numeric-10-circle',
      category: 'workout',
      requirement: { type: 'count', value: 10 },
      unlocked: false,
      points: 25,
      tier: 'bronze',
    },
    {
      id: 'workout_50',
      title: 'Dedicated Player',
      description: 'Complete 50 workouts',
      icon: 'medal',
      category: 'workout',
      requirement: { type: 'count', value: 50 },
      unlocked: false,
      points: 50,
      tier: 'silver',
    },
    {
      id: 'workout_100',
      title: 'Century Club',
      description: 'Complete 100 workouts',
      icon: 'trophy',
      category: 'workout',
      requirement: { type: 'count', value: 100 },
      unlocked: false,
      points: 100,
      tier: 'gold',
    },
    {
      id: 'workout_365',
      title: 'Year-Round Warrior',
      description: 'Complete 365 workouts',
      icon: 'crown',
      category: 'workout',
      requirement: { type: 'count', value: 365 },
      unlocked: false,
      points: 200,
      tier: 'platinum',
    },

    // Streak Achievements
    {
      id: 'streak_3',
      title: 'On a Roll',
      description: 'Maintain a 3-day workout streak',
      icon: 'fire',
      category: 'streak',
      requirement: { type: 'streak', value: 3 },
      unlocked: false,
      points: 15,
      tier: 'bronze',
    },
    {
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Maintain a 7-day workout streak',
      icon: 'calendar-week',
      category: 'streak',
      requirement: { type: 'streak', value: 7 },
      unlocked: false,
      points: 30,
      tier: 'bronze',
    },
    {
      id: 'streak_30',
      title: 'Monthly Master',
      description: 'Maintain a 30-day workout streak',
      icon: 'calendar-month',
      category: 'streak',
      requirement: { type: 'streak', value: 30 },
      unlocked: false,
      points: 75,
      tier: 'silver',
    },
    {
      id: 'streak_100',
      title: 'Unstoppable',
      description: 'Maintain a 100-day workout streak',
      icon: 'infinity',
      category: 'streak',
      requirement: { type: 'streak', value: 100 },
      unlocked: false,
      points: 150,
      tier: 'gold',
    },

    // Time-based Achievements
    {
      id: 'time_10h',
      title: 'Time Investor',
      description: 'Train for 10 total hours',
      icon: 'clock-time-four',
      category: 'milestone',
      requirement: { type: 'time', value: 10, unit: 'hours' },
      unlocked: false,
      points: 20,
      tier: 'bronze',
    },
    {
      id: 'time_50h',
      title: 'Serious Commitment',
      description: 'Train for 50 total hours',
      icon: 'clock-alert',
      category: 'milestone',
      requirement: { type: 'time', value: 50, unit: 'hours' },
      unlocked: false,
      points: 60,
      tier: 'silver',
    },
    {
      id: 'time_100h',
      title: 'Time Master',
      description: 'Train for 100 total hours',
      icon: 'timer-sand',
      category: 'milestone',
      requirement: { type: 'time', value: 100, unit: 'hours' },
      unlocked: false,
      points: 120,
      tier: 'gold',
    },

    // Skill Achievements
    {
      id: 'perfect_week',
      title: 'Perfect Week',
      description: 'Complete all planned workouts in a week',
      icon: 'check-all',
      category: 'skill',
      requirement: { type: 'custom', value: 1 },
      unlocked: false,
      points: 40,
      tier: 'silver',
    },
    {
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Complete 10 workouts before 7 AM',
      icon: 'weather-sunset-up',
      category: 'special',
      requirement: { type: 'custom', value: 10 },
      unlocked: false,
      points: 35,
      tier: 'bronze',
    },
    {
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Complete 10 workouts after 8 PM',
      icon: 'weather-night',
      category: 'special',
      requirement: { type: 'custom', value: 10 },
      unlocked: false,
      points: 35,
      tier: 'bronze',
    },
    {
      id: 'high_intensity',
      title: 'Intensity Junkie',
      description: 'Complete 20 high-intensity workouts',
      icon: 'lightning-bolt',
      category: 'skill',
      requirement: { type: 'custom', value: 20 },
      unlocked: false,
      points: 45,
      tier: 'silver',
    },
    {
      id: 'variety_master',
      title: 'Variety Master',
      description: 'Complete workouts in all 4 categories',
      icon: 'shape',
      category: 'skill',
      requirement: { type: 'custom', value: 4 },
      unlocked: false,
      points: 50,
      tier: 'silver',
    },
  ];

  private readonly STORAGE_KEY = 'achievements_progress';

  async initialize() {
    // Load saved achievement progress
    try {
      const saved = await AsyncStorage.getItem(this.STORAGE_KEY);
      if (saved) {
        const savedAchievements = JSON.parse(saved);
        this.achievements = this.achievements.map(achievement => {
          const savedAchievement = savedAchievements.find((a: Achievement) => a.id === achievement.id);
          return savedAchievement || achievement;
        });
      }
    } catch (error) {
      console.error('Error loading achievements:', error);
    }
  }

  async checkAndUnlockAchievements(userId: number = 1): Promise<Achievement[]> {
    const newlyUnlocked: Achievement[] = [];
    
    try {
      // Get user stats
      const stats = await databaseService.getTrainingStats(userId, 365);
      const workoutLogs = await databaseService.getWorkoutLogs(userId, 1000);
      
      // Calculate current values
      const totalWorkouts = stats.totalWorkouts;
      const totalHours = Math.floor(stats.totalMinutes / 60);
      const currentStreak = this.calculateCurrentStreak(workoutLogs);
      
      // Check each achievement
      for (const achievement of this.achievements) {
        if (achievement.unlocked) continue;
        
        let shouldUnlock = false;
        let progress = 0;
        
        switch (achievement.requirement.type) {
          case 'count':
            if (achievement.category === 'workout') {
              progress = (totalWorkouts / achievement.requirement.value) * 100;
              shouldUnlock = totalWorkouts >= achievement.requirement.value;
            }
            break;
            
          case 'streak':
            progress = (currentStreak / achievement.requirement.value) * 100;
            shouldUnlock = currentStreak >= achievement.requirement.value;
            break;
            
          case 'time':
            if (achievement.requirement.unit === 'hours') {
              progress = (totalHours / achievement.requirement.value) * 100;
              shouldUnlock = totalHours >= achievement.requirement.value;
            }
            break;
            
          case 'custom':
            // Handle custom achievements
            const customProgress = await this.checkCustomAchievement(achievement, workoutLogs);
            progress = customProgress.progress;
            shouldUnlock = customProgress.unlocked;
            break;
        }
        
        achievement.progress = Math.min(progress, 100);
        
        if (shouldUnlock && !achievement.unlocked) {
          achievement.unlocked = true;
          achievement.unlockedAt = new Date().toISOString();
          newlyUnlocked.push(achievement);
        }
      }
      
      // Save progress
      await this.saveAchievements();
      
    } catch (error) {
      console.error('Error checking achievements:', error);
    }
    
    return newlyUnlocked;
  }

  private calculateCurrentStreak(workouts: any[]): number {
    if (!workouts || workouts.length === 0) return 0;
    
    let streak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    // Sort workouts by date descending
    const sortedWorkouts = [...workouts].sort((a, b) => 
      new Date(b.date).getTime() - new Date(a.date).getTime()
    );
    
    for (let i = 0; i < 365; i++) {
      const checkDate = new Date(today);
      checkDate.setDate(checkDate.getDate() - i);
      const dateStr = checkDate.toISOString().split('T')[0];
      
      const hasWorkout = sortedWorkouts.some(w => 
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

  private async checkCustomAchievement(
    achievement: Achievement,
    workouts: any[]
  ): Promise<{ progress: number; unlocked: boolean }> {
    switch (achievement.id) {
      case 'perfect_week':
        // Check if completed all workouts in any recent week
        const weeks = this.groupWorkoutsByWeek(workouts);
        const perfectWeeks = weeks.filter(week => 
          week.planned === week.completed && week.planned >= 5
        ).length;
        return {
          progress: perfectWeeks > 0 ? 100 : 0,
          unlocked: perfectWeeks > 0,
        };
        
      case 'early_bird':
        const earlyWorkouts = workouts.filter(w => {
          const hour = new Date(w.logged_at || w.date).getHours();
          return hour < 7 && w.completed;
        }).length;
        return {
          progress: (earlyWorkouts / achievement.requirement.value) * 100,
          unlocked: earlyWorkouts >= achievement.requirement.value,
        };
        
      case 'night_owl':
        const lateWorkouts = workouts.filter(w => {
          const hour = new Date(w.logged_at || w.date).getHours();
          return hour >= 20 && w.completed;
        }).length;
        return {
          progress: (lateWorkouts / achievement.requirement.value) * 100,
          unlocked: lateWorkouts >= achievement.requirement.value,
        };
        
      case 'high_intensity':
        const highIntensityWorkouts = workouts.filter(w => 
          w.intensity_level >= 8 && w.completed
        ).length;
        return {
          progress: (highIntensityWorkouts / achievement.requirement.value) * 100,
          unlocked: highIntensityWorkouts >= achievement.requirement.value,
        };
        
      case 'variety_master':
        const categories = new Set(
          workouts
            .filter(w => w.completed)
            .map(w => w.category || 'unknown')
        );
        return {
          progress: (categories.size / achievement.requirement.value) * 100,
          unlocked: categories.size >= achievement.requirement.value,
        };
        
      default:
        return { progress: 0, unlocked: false };
    }
  }

  private groupWorkoutsByWeek(workouts: any[]): Array<{ planned: number; completed: number }> {
    const weeks: { [key: string]: { planned: number; completed: number } } = {};
    
    workouts.forEach(workout => {
      const date = new Date(workout.date);
      const weekKey = `${date.getFullYear()}-W${Math.ceil(date.getDate() / 7)}`;
      
      if (!weeks[weekKey]) {
        weeks[weekKey] = { planned: 0, completed: 0 };
      }
      
      weeks[weekKey].planned++;
      if (workout.completed) {
        weeks[weekKey].completed++;
      }
    });
    
    return Object.values(weeks);
  }

  async getAchievements(): Promise<Achievement[]> {
    return this.achievements;
  }

  async getAchievementsByCategory(category: string): Promise<Achievement[]> {
    return this.achievements.filter(a => a.category === category);
  }

  async getUnlockedAchievements(): Promise<Achievement[]> {
    return this.achievements.filter(a => a.unlocked);
  }

  async getTotalPoints(): Promise<number> {
    return this.achievements
      .filter(a => a.unlocked)
      .reduce((total, a) => total + a.points, 0);
  }

  async getAchievementProgress(): Promise<{
    total: number;
    unlocked: number;
    percentage: number;
    points: number;
    nextAchievement?: Achievement;
  }> {
    const total = this.achievements.length;
    const unlocked = this.achievements.filter(a => a.unlocked).length;
    const points = await this.getTotalPoints();
    
    // Find next closest achievement
    const nextAchievement = this.achievements
      .filter(a => !a.unlocked && a.progress !== undefined)
      .sort((a, b) => (b.progress || 0) - (a.progress || 0))[0];
    
    return {
      total,
      unlocked,
      percentage: (unlocked / total) * 100,
      points,
      nextAchievement,
    };
  }

  private async saveAchievements() {
    try {
      await AsyncStorage.setItem(this.STORAGE_KEY, JSON.stringify(this.achievements));
    } catch (error) {
      console.error('Error saving achievements:', error);
    }
  }

  // Check for specific achievement unlock
  async unlockAchievement(achievementId: string): Promise<Achievement | null> {
    const achievement = this.achievements.find(a => a.id === achievementId);
    
    if (achievement && !achievement.unlocked) {
      achievement.unlocked = true;
      achievement.unlockedAt = new Date().toISOString();
      achievement.progress = 100;
      await this.saveAchievements();
      return achievement;
    }
    
    return null;
  }

  // Reset all achievements (for testing/development)
  async resetAchievements() {
    this.achievements = this.achievements.map(a => ({
      ...a,
      unlocked: false,
      unlockedAt: undefined,
      progress: 0,
    }));
    await this.saveAchievements();
  }
}

export default new AchievementService();
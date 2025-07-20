import SQLite from 'react-native-sqlite-storage';
import RNFS from 'react-native-fs';
import { Platform } from 'react-native';

SQLite.DEBUG(false);
SQLite.enablePromise(true);

const database_name = "SquashTraining.db";
const database_version = "2.0"; // Updated version for indexing
const database_displayname = "Squash Training Database";
const database_size = 200000;

let db: SQLite.SQLiteDatabase | null = null;

export interface BackupMetadata {
  version: string;
  createdAt: string;
  totalRecords: number;
  tables: string[];
}

export interface AnalyticsData {
  totalWorkouts: number;
  completionRate: number;
  averageIntensity: number;
  weeklyProgress: Array<{
    week: string;
    workouts: number;
    completionRate: number;
  }>;
  exerciseStats: Array<{
    category: string;
    count: number;
    avgDuration: number;
  }>;
  trendData: {
    intensity: number[];
    condition: number[];
    fatigue: number[];
  };
}

export class DatabaseOptimized {
  private static instance: DatabaseOptimized;
  private db: SQLite.SQLiteDatabase | null = null;

  private constructor() {}

  public static getInstance(): DatabaseOptimized {
    if (!DatabaseOptimized.instance) {
      DatabaseOptimized.instance = new DatabaseOptimized();
    }
    return DatabaseOptimized.instance;
  }

  public async getDBConnection(): Promise<SQLite.SQLiteDatabase> {
    if (this.db) {
      return this.db;
    }
    
    this.db = await SQLite.openDatabase(
      database_name,
      database_version,
      database_displayname,
      database_size
    );
    
    return this.db;
  }

  public async initializeDatabase(): Promise<void> {
    try {
      const db = await this.getDBConnection();
      await this.createTables(db);
      await this.createIndexes(db);
      console.log('Database initialized with indexes successfully');
    } catch (error) {
      console.error('Failed to initialize database:', error);
      throw error;
    }
  }

  private async createTables(db: SQLite.SQLiteDatabase): Promise<void> {
    // Include all existing table creation queries from the original file
    const queries = [
      // User profile table with additional fields
      `CREATE TABLE IF NOT EXISTS user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT,
        level TEXT NOT NULL DEFAULT 'intermediate',
        total_workouts INTEGER DEFAULT 0,
        total_hours REAL DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );`,

      // Training programs table
      `CREATE TABLE IF NOT EXISTS training_programs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration_type TEXT NOT NULL,
        description TEXT,
        is_active BOOLEAN DEFAULT 0,
        current_week INTEGER DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );`,

      // Weekly plans table
      `CREATE TABLE IF NOT EXISTS weekly_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        program_id INTEGER NOT NULL,
        week_number INTEGER NOT NULL,
        phase TEXT NOT NULL,
        focus TEXT NOT NULL,
        FOREIGN KEY (program_id) REFERENCES training_programs (id)
      );`,

      // Daily workouts table
      `CREATE TABLE IF NOT EXISTS daily_workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weekly_plan_id INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL,
        workout_type TEXT NOT NULL,
        FOREIGN KEY (weekly_plan_id) REFERENCES weekly_plans (id)
      );`,

      // Exercises table
      `CREATE TABLE IF NOT EXISTS exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_workout_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        sets INTEGER,
        reps INTEGER,
        duration INTEGER,
        intensity TEXT,
        instructions TEXT,
        FOREIGN KEY (daily_workout_id) REFERENCES daily_workouts (id)
      );`,

      // Workout logs table with additional indexable fields
      `CREATE TABLE IF NOT EXISTS workout_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER DEFAULT 1,
        exercise_id INTEGER,
        exercise_name TEXT NOT NULL,
        date DATE NOT NULL,
        completed BOOLEAN DEFAULT 0,
        actual_sets INTEGER,
        actual_reps INTEGER,
        actual_duration INTEGER,
        intensity_rating INTEGER,
        condition_rating INTEGER,
        fatigue_level INTEGER,
        muscle_soreness INTEGER,
        sleep_quality INTEGER,
        notes TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      );`,

      // User memos table
      `CREATE TABLE IF NOT EXISTS user_memos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER DEFAULT 1,
        date DATE NOT NULL,
        memo TEXT NOT NULL,
        mood TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );`,

      // AI advice table
      `CREATE TABLE IF NOT EXISTS ai_advice (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER DEFAULT 1,
        date DATE NOT NULL,
        advice_type TEXT NOT NULL,
        advice TEXT NOT NULL,
        is_applied BOOLEAN DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );`,

      // Analytics cache table for performance
      `CREATE TABLE IF NOT EXISTS analytics_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cache_key TEXT UNIQUE NOT NULL,
        data TEXT NOT NULL,
        expires_at DATETIME NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );`,

      // Backup history table
      `CREATE TABLE IF NOT EXISTS backup_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        backup_name TEXT NOT NULL,
        backup_path TEXT NOT NULL,
        size_bytes INTEGER,
        record_count INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );`
    ];

    for (const query of queries) {
      await db.executeSql(query);
    }
  }

  // Create indexes for performance optimization
  private async createIndexes(db: SQLite.SQLiteDatabase): Promise<void> {
    const indexes = [
      // Workout logs indexes for fast queries
      'CREATE INDEX IF NOT EXISTS idx_workout_logs_date ON workout_logs(date);',
      'CREATE INDEX IF NOT EXISTS idx_workout_logs_user_date ON workout_logs(user_id, date);',
      'CREATE INDEX IF NOT EXISTS idx_workout_logs_completed ON workout_logs(completed);',
      'CREATE INDEX IF NOT EXISTS idx_workout_logs_exercise ON workout_logs(exercise_id);',
      
      // Training program indexes
      'CREATE INDEX IF NOT EXISTS idx_training_programs_active ON training_programs(is_active);',
      'CREATE INDEX IF NOT EXISTS idx_weekly_plans_program ON weekly_plans(program_id);',
      'CREATE INDEX IF NOT EXISTS idx_daily_workouts_plan ON daily_workouts(weekly_plan_id);',
      'CREATE INDEX IF NOT EXISTS idx_exercises_workout ON exercises(daily_workout_id);',
      
      // User data indexes
      'CREATE INDEX IF NOT EXISTS idx_user_memos_date ON user_memos(user_id, date);',
      'CREATE INDEX IF NOT EXISTS idx_ai_advice_date ON ai_advice(user_id, date);',
      
      // Analytics cache index
      'CREATE INDEX IF NOT EXISTS idx_analytics_cache_key ON analytics_cache(cache_key);',
      'CREATE INDEX IF NOT EXISTS idx_analytics_cache_expires ON analytics_cache(expires_at);'
    ];

    for (const index of indexes) {
      await db.executeSql(index);
    }
    
    console.log('Database indexes created successfully');
  }

  // Backup functionality
  public async createBackup(backupName?: string): Promise<string> {
    try {
      const db = await this.getDBConnection();
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const name = backupName || `backup_${timestamp}`;
      
      // Get backup directory
      const backupDir = Platform.OS === 'ios' 
        ? `${RNFS.DocumentDirectoryPath}/backups`
        : `${RNFS.ExternalDirectoryPath}/backups`;
      
      // Create backup directory if it doesn't exist
      await RNFS.mkdir(backupDir);
      
      const backupPath = `${backupDir}/${name}.json`;
      
      // Fetch all data from tables
      const tables = [
        'user_profile', 'training_programs', 'weekly_plans', 
        'daily_workouts', 'exercises', 'workout_logs', 
        'user_memos', 'ai_advice'
      ];
      
      const backupData: any = {
        metadata: {
          version: database_version,
          createdAt: new Date().toISOString(),
          tables: tables
        },
        data: {}
      };
      
      let totalRecords = 0;
      
      for (const table of tables) {
        const [results] = await db.executeSql(`SELECT * FROM ${table}`);
        const rows = [];
        for (let i = 0; i < results.rows.length; i++) {
          rows.push(results.rows.item(i));
        }
        backupData.data[table] = rows;
        totalRecords += rows.length;
      }
      
      backupData.metadata.totalRecords = totalRecords;
      
      // Write backup to file
      await RNFS.writeFile(backupPath, JSON.stringify(backupData, null, 2), 'utf8');
      
      // Get file size
      const statResult = await RNFS.stat(backupPath);
      
      // Record backup in history
      await db.executeSql(
        'INSERT INTO backup_history (backup_name, backup_path, size_bytes, record_count) VALUES (?, ?, ?, ?)',
        [name, backupPath, statResult.size, totalRecords]
      );
      
      console.log(`Backup created successfully: ${backupPath}`);
      return backupPath;
      
    } catch (error) {
      console.error('Backup failed:', error);
      throw error;
    }
  }

  // Restore functionality
  public async restoreBackup(backupPath: string): Promise<void> {
    try {
      const db = await this.getDBConnection();
      
      // Read backup file
      const backupContent = await RNFS.readFile(backupPath, 'utf8');
      const backupData = JSON.parse(backupContent);
      
      // Validate backup format
      if (!backupData.metadata || !backupData.data) {
        throw new Error('Invalid backup format');
      }
      
      // Begin transaction
      await db.executeSql('BEGIN TRANSACTION');
      
      try {
        // Clear existing data (optional - you might want to merge instead)
        for (const table of backupData.metadata.tables) {
          await db.executeSql(`DELETE FROM ${table}`);
        }
        
        // Restore data table by table
        for (const [table, rows] of Object.entries(backupData.data)) {
          for (const row of rows as any[]) {
            const columns = Object.keys(row).filter(key => key !== 'id');
            const values = columns.map(col => row[col]);
            const placeholders = columns.map(() => '?').join(', ');
            
            await db.executeSql(
              `INSERT INTO ${table} (${columns.join(', ')}) VALUES (${placeholders})`,
              values
            );
          }
        }
        
        // Commit transaction
        await db.executeSql('COMMIT');
        console.log('Backup restored successfully');
        
      } catch (error) {
        // Rollback on error
        await db.executeSql('ROLLBACK');
        throw error;
      }
      
    } catch (error) {
      console.error('Restore failed:', error);
      throw error;
    }
  }

  // Data analysis functionality
  public async getAnalytics(userId: number = 1, days: number = 30): Promise<AnalyticsData> {
    try {
      const db = await this.getDBConnection();
      const endDate = new Date();
      const startDate = new Date(endDate.getTime() - days * 24 * 60 * 60 * 1000);
      
      // Check cache first
      const cacheKey = `analytics_${userId}_${days}`;
      const [cacheResults] = await db.executeSql(
        'SELECT data FROM analytics_cache WHERE cache_key = ? AND expires_at > datetime("now")',
        [cacheKey]
      );
      
      if (cacheResults.rows.length > 0) {
        return JSON.parse(cacheResults.rows.item(0).data);
      }
      
      // Total workouts and completion rate
      const [workoutStats] = await db.executeSql(
        `SELECT 
          COUNT(*) as total_workouts,
          SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) as completed_workouts,
          AVG(intensity_rating) as avg_intensity
        FROM workout_logs 
        WHERE user_id = ? AND date >= ? AND date <= ?`,
        [userId, startDate.toISOString().split('T')[0], endDate.toISOString().split('T')[0]]
      );
      
      const stats = workoutStats.rows.item(0);
      const completionRate = stats.total_workouts > 0 
        ? (stats.completed_workouts / stats.total_workouts) * 100 
        : 0;
      
      // Weekly progress
      const [weeklyData] = await db.executeSql(
        `SELECT 
          strftime('%Y-%W', date) as week,
          COUNT(*) as workouts,
          SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) as completed
        FROM workout_logs
        WHERE user_id = ? AND date >= ? AND date <= ?
        GROUP BY week
        ORDER BY week DESC
        LIMIT 12`,
        [userId, startDate.toISOString().split('T')[0], endDate.toISOString().split('T')[0]]
      );
      
      const weeklyProgress = [];
      for (let i = 0; i < weeklyData.rows.length; i++) {
        const row = weeklyData.rows.item(i);
        weeklyProgress.push({
          week: row.week,
          workouts: row.workouts,
          completionRate: row.workouts > 0 ? (row.completed / row.workouts) * 100 : 0
        });
      }
      
      // Exercise category statistics
      const [exerciseStats] = await db.executeSql(
        `SELECT 
          e.category,
          COUNT(*) as count,
          AVG(wl.actual_duration) as avg_duration
        FROM workout_logs wl
        JOIN exercises e ON wl.exercise_id = e.id
        WHERE wl.user_id = ? AND wl.date >= ? AND wl.date <= ?
        GROUP BY e.category`,
        [userId, startDate.toISOString().split('T')[0], endDate.toISOString().split('T')[0]]
      );
      
      const categoryStats = [];
      for (let i = 0; i < exerciseStats.rows.length; i++) {
        categoryStats.push(exerciseStats.rows.item(i));
      }
      
      // Trend data (last 30 days)
      const [trendData] = await db.executeSql(
        `SELECT 
          date,
          AVG(intensity_rating) as intensity,
          AVG(condition_rating) as condition,
          AVG(fatigue_level) as fatigue
        FROM workout_logs
        WHERE user_id = ? AND date >= ? AND date <= ?
        GROUP BY date
        ORDER BY date`,
        [userId, startDate.toISOString().split('T')[0], endDate.toISOString().split('T')[0]]
      );
      
      const trends = {
        intensity: [],
        condition: [],
        fatigue: []
      };
      
      for (let i = 0; i < trendData.rows.length; i++) {
        const row = trendData.rows.item(i);
        trends.intensity.push(row.intensity || 0);
        trends.condition.push(row.condition || 0);
        trends.fatigue.push(row.fatigue || 0);
      }
      
      const analytics: AnalyticsData = {
        totalWorkouts: stats.total_workouts || 0,
        completionRate: completionRate,
        averageIntensity: stats.avg_intensity || 0,
        weeklyProgress: weeklyProgress,
        exerciseStats: categoryStats,
        trendData: trends
      };
      
      // Cache the results
      const cacheExpiry = new Date(Date.now() + 3600000); // 1 hour
      await db.executeSql(
        'INSERT OR REPLACE INTO analytics_cache (cache_key, data, expires_at) VALUES (?, ?, ?)',
        [cacheKey, JSON.stringify(analytics), cacheExpiry.toISOString()]
      );
      
      return analytics;
      
    } catch (error) {
      console.error('Analytics query failed:', error);
      throw error;
    }
  }

  // Advanced analysis methods
  public async getWeakAreaAnalysis(userId: number = 1): Promise<any> {
    try {
      const db = await this.getDBConnection();
      
      // Analyze lowest performing exercises
      const [weakAreas] = await db.executeSql(
        `SELECT 
          e.name,
          e.category,
          AVG(wl.intensity_rating) as avg_intensity,
          AVG(wl.condition_rating) as avg_condition,
          COUNT(*) as attempts,
          SUM(CASE WHEN wl.completed = 1 THEN 1 ELSE 0 END) as completions
        FROM workout_logs wl
        JOIN exercises e ON wl.exercise_id = e.id
        WHERE wl.user_id = ? AND wl.date >= date('now', '-30 days')
        GROUP BY e.id, e.name, e.category
        HAVING attempts > 3
        ORDER BY avg_intensity ASC, avg_condition ASC
        LIMIT 5`,
        [userId]
      );
      
      const results = [];
      for (let i = 0; i < weakAreas.rows.length; i++) {
        results.push(weakAreas.rows.item(i));
      }
      
      return results;
      
    } catch (error) {
      console.error('Weak area analysis failed:', error);
      throw error;
    }
  }

  public async getProgressTrend(userId: number = 1, exerciseId?: number): Promise<any> {
    try {
      const db = await this.getDBConnection();
      
      let query = `
        SELECT 
          date,
          exercise_name,
          intensity_rating,
          condition_rating,
          actual_duration,
          completed
        FROM workout_logs
        WHERE user_id = ?`;
      
      const params = [userId];
      
      if (exerciseId) {
        query += ' AND exercise_id = ?';
        params.push(exerciseId);
      }
      
      query += ' ORDER BY date DESC LIMIT 100';
      
      const [results] = await db.executeSql(query, params);
      
      const trend = [];
      for (let i = 0; i < results.rows.length; i++) {
        trend.push(results.rows.item(i));
      }
      
      return trend;
      
    } catch (error) {
      console.error('Progress trend query failed:', error);
      throw error;
    }
  }

  // Cleanup old analytics cache
  public async cleanupCache(): Promise<void> {
    try {
      const db = await this.getDBConnection();
      await db.executeSql('DELETE FROM analytics_cache WHERE expires_at < datetime("now")');
      console.log('Analytics cache cleaned');
    } catch (error) {
      console.error('Cache cleanup failed:', error);
    }
  }

  // Database optimization
  public async optimizeDatabase(): Promise<void> {
    try {
      const db = await this.getDBConnection();
      await db.executeSql('VACUUM');
      await db.executeSql('ANALYZE');
      console.log('Database optimized');
    } catch (error) {
      console.error('Database optimization failed:', error);
    }
  }
}

export default DatabaseOptimized;
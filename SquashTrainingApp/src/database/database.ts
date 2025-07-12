import SQLite from 'react-native-sqlite-storage';

SQLite.DEBUG(false);
SQLite.enablePromise(true);

const database_name = "SquashTraining.db";
const database_version = "1.0";
const database_displayname = "Squash Training Database";
const database_size = 200000;

let db: SQLite.SQLiteDatabase | null = null;

export const getDBConnection = async (): Promise<SQLite.SQLiteDatabase> => {
  if (db) {
    return db;
  }
  
  db = await SQLite.openDatabase(
    database_name,
    database_version,
    database_displayname,
    database_size
  );
  
  return db;
};

export const createTables = async (db: SQLite.SQLiteDatabase) => {
  // 사용자 프로필 테이블
  const userProfileQuery = `
    CREATE TABLE IF NOT EXISTS user_profile (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      level TEXT NOT NULL DEFAULT 'intermediate',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // 트레이닝 프로그램 테이블
  const trainingProgramQuery = `
    CREATE TABLE IF NOT EXISTS training_programs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      duration_type TEXT NOT NULL, -- '4weeks', '12weeks', '1year'
      description TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // 주차별 계획 테이블
  const weeklyPlanQuery = `
    CREATE TABLE IF NOT EXISTS weekly_plans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      program_id INTEGER NOT NULL,
      week_number INTEGER NOT NULL,
      phase TEXT NOT NULL, -- 'preparation', 'intensity', 'recovery', 'peak'
      focus TEXT NOT NULL,
      FOREIGN KEY (program_id) REFERENCES training_programs (id)
    );
  `;

  // 일일 운동 테이블
  const dailyWorkoutQuery = `
    CREATE TABLE IF NOT EXISTS daily_workouts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      weekly_plan_id INTEGER NOT NULL,
      day_of_week INTEGER NOT NULL, -- 1-7
      workout_type TEXT NOT NULL, -- 'squash', 'fitness', 'rest'
      FOREIGN KEY (weekly_plan_id) REFERENCES weekly_plans (id)
    );
  `;

  // 운동 항목 테이블
  const exerciseQuery = `
    CREATE TABLE IF NOT EXISTS exercises (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      daily_workout_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      category TEXT NOT NULL, -- 'skill', 'fitness', 'cardio', 'strength'
      sets INTEGER,
      reps INTEGER,
      duration INTEGER, -- in minutes
      intensity TEXT, -- 'low', 'medium', 'high'
      instructions TEXT,
      FOREIGN KEY (daily_workout_id) REFERENCES daily_workouts (id)
    );
  `;

  // 운동 기록 테이블
  const workoutLogQuery = `
    CREATE TABLE IF NOT EXISTS workout_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      exercise_id INTEGER NOT NULL,
      date DATE NOT NULL,
      completed BOOLEAN DEFAULT 0,
      actual_sets INTEGER,
      actual_reps INTEGER,
      actual_duration INTEGER,
      intensity_rating INTEGER, -- 1-10
      condition_rating INTEGER, -- 1-10
      fatigue_level INTEGER, -- 1-10
      muscle_soreness INTEGER, -- 1-10
      sleep_quality INTEGER, -- 1-10
      notes TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (exercise_id) REFERENCES exercises (id)
    );
  `;

  // 사용자 메모 테이블
  const userMemoQuery = `
    CREATE TABLE IF NOT EXISTS user_memos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date DATE NOT NULL,
      memo TEXT NOT NULL,
      mood TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // AI 조언 테이블
  const aiAdviceQuery = `
    CREATE TABLE IF NOT EXISTS ai_advice (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date DATE NOT NULL,
      advice_type TEXT NOT NULL, -- 'program_adjustment', 'recovery', 'motivation'
      advice TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // 알림 설정 테이블
  const notificationSettingsQuery = `
    CREATE TABLE IF NOT EXISTS notification_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      daily_reminder_enabled BOOLEAN DEFAULT 1,
      daily_reminder_time TIME DEFAULT '08:00',
      weekly_report_enabled BOOLEAN DEFAULT 1,
      weekly_report_day INTEGER DEFAULT 1,
      achievement_alerts BOOLEAN DEFAULT 1,
      ai_suggestions BOOLEAN DEFAULT 1,
      push_enabled BOOLEAN DEFAULT 1,
      email_enabled BOOLEAN DEFAULT 0,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  try {
    await db.executeSql(userProfileQuery);
    await db.executeSql(trainingProgramQuery);
    await db.executeSql(weeklyPlanQuery);
    await db.executeSql(dailyWorkoutQuery);
    await db.executeSql(exerciseQuery);
    await db.executeSql(workoutLogQuery);
    await db.executeSql(userMemoQuery);
    await db.executeSql(aiAdviceQuery);
    await db.executeSql(notificationSettingsQuery);
    
    console.log('All tables created successfully');
  } catch (error) {
    console.error('Error creating tables:', error);
    throw error;
  }
};

export const initializeDatabase = async () => {
  try {
    const db = await getDBConnection();
    await createTables(db);
    console.log('Database initialized successfully');
  } catch (error) {
    console.error('Failed to initialize database:', error);
    throw error;
  }
};
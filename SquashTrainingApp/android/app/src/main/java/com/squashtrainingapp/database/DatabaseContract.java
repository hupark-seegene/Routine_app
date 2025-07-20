package com.squashtrainingapp.database;

public final class DatabaseContract {
    
    // Prevent instantiation
    private DatabaseContract() {}
    
    // Inner classes for table definitions
    public static class ExerciseEntry {
        public static final String TABLE_NAME = TABLE_EXERCISES;
    }
    
    public static class RecordEntry {
        public static final String TABLE_NAME = TABLE_RECORDS;
    }
    
    public static class UserEntry {
        public static final String TABLE_NAME = TABLE_USER;
    }
    
    // Database Info
    public static final String DATABASE_NAME = "squashTraining.db";
    public static final int DATABASE_VERSION = 3; // Incremented for workout sessions
    
    // Table Names
    public static final String TABLE_EXERCISES = "exercises";
    public static final String TABLE_RECORDS = "records";
    public static final String TABLE_USER = "user";
    public static final String TABLE_TRAINING_PROGRAMS = "training_programs";
    public static final String TABLE_PROGRAM_ENROLLMENTS = "program_enrollments";
    public static final String TABLE_WORKOUT_SESSIONS = "workout_sessions";
    
    // Common columns
    public static final String COLUMN_ID = "id";
    
    // Exercises Table Columns
    public static final String COLUMN_EXERCISE_NAME = "name";
    public static final String COLUMN_EXERCISE_CATEGORY = "category";
    public static final String COLUMN_EXERCISE_DESCRIPTION = "description";
    public static final String COLUMN_EXERCISE_CHECKED = "is_checked";
    
    // Records Table Columns
    public static final String COLUMN_RECORD_EXERCISE = "exercise_name";
    public static final String COLUMN_RECORD_SETS = "sets";
    public static final String COLUMN_RECORD_REPS = "reps";
    public static final String COLUMN_RECORD_DURATION = "duration";
    public static final String COLUMN_RECORD_INTENSITY = "intensity";
    public static final String COLUMN_RECORD_CONDITION = "condition";
    public static final String COLUMN_RECORD_FATIGUE = "fatigue";
    public static final String COLUMN_RECORD_MEMO = "memo";
    public static final String COLUMN_RECORD_DATE = "date";
    
    // User Table Columns
    public static final String COLUMN_USER_NAME = "name";
    public static final String COLUMN_USER_LEVEL = "level";
    public static final String COLUMN_USER_EXP = "experience";
    public static final String COLUMN_USER_SESSIONS = "total_sessions";
    public static final String COLUMN_USER_CALORIES = "total_calories";
    public static final String COLUMN_USER_HOURS = "total_hours";
    public static final String COLUMN_USER_STREAK = "current_streak";
    
    // Training Programs Table Columns
    public static final String COLUMN_PROGRAM_NAME = "name";
    public static final String COLUMN_PROGRAM_DESCRIPTION = "description";
    public static final String COLUMN_PROGRAM_DURATION_WEEKS = "duration_weeks";
    public static final String COLUMN_PROGRAM_DIFFICULTY = "difficulty";
    public static final String COLUMN_PROGRAM_TYPE = "type";
    public static final String COLUMN_PROGRAM_IMAGE_URL = "image_url";
    public static final String COLUMN_PROGRAM_CREATED_AT = "created_at";
    public static final String COLUMN_PROGRAM_UPDATED_AT = "updated_at";
    
    // Program Enrollments Table Columns
    public static final String COLUMN_ENROLLMENT_USER_ID = "user_id";
    public static final String COLUMN_ENROLLMENT_PROGRAM_ID = "program_id";
    public static final String COLUMN_ENROLLMENT_START_DATE = "start_date";
    public static final String COLUMN_ENROLLMENT_END_DATE = "end_date";
    public static final String COLUMN_ENROLLMENT_CURRENT_WEEK = "current_week";
    public static final String COLUMN_ENROLLMENT_CURRENT_DAY = "current_day";
    public static final String COLUMN_ENROLLMENT_PROGRESS = "progress_percentage";
    public static final String COLUMN_ENROLLMENT_STATUS = "status";
    public static final String COLUMN_ENROLLMENT_LAST_ACTIVITY = "last_activity_date";
    public static final String COLUMN_ENROLLMENT_CREATED_AT = "created_at";
    public static final String COLUMN_ENROLLMENT_UPDATED_AT = "updated_at";
    
    // Workout Sessions Table Columns
    public static final String COLUMN_SESSION_PROGRAM_ID = "program_id";
    public static final String COLUMN_SESSION_NAME = "session_name";
    public static final String COLUMN_SESSION_SCHEDULED_DATE = "scheduled_date";
    public static final String COLUMN_SESSION_DURATION_MINUTES = "duration_minutes";
    public static final String COLUMN_SESSION_STATUS = "status";
    public static final String COLUMN_SESSION_NOTES = "notes";
    public static final String COLUMN_SESSION_CREATED_AT = "created_at";
    public static final String COLUMN_SESSION_UPDATED_AT = "updated_at";
    
    // SQL Create Statements
    public static final String SQL_CREATE_EXERCISES = "CREATE TABLE " + TABLE_EXERCISES +
            "(" +
            COLUMN_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
            COLUMN_EXERCISE_NAME + " TEXT," +
            COLUMN_EXERCISE_CATEGORY + " TEXT," +
            COLUMN_EXERCISE_DESCRIPTION + " TEXT," +
            COLUMN_EXERCISE_CHECKED + " INTEGER DEFAULT 0" +
            ")";
    
    public static final String SQL_CREATE_RECORDS = "CREATE TABLE " + TABLE_RECORDS +
            "(" +
            COLUMN_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
            COLUMN_RECORD_EXERCISE + " TEXT," +
            COLUMN_RECORD_SETS + " INTEGER," +
            COLUMN_RECORD_REPS + " INTEGER," +
            COLUMN_RECORD_DURATION + " INTEGER," +
            COLUMN_RECORD_INTENSITY + " INTEGER," +
            COLUMN_RECORD_CONDITION + " INTEGER," +
            COLUMN_RECORD_FATIGUE + " INTEGER," +
            COLUMN_RECORD_MEMO + " TEXT," +
            COLUMN_RECORD_DATE + " DATETIME DEFAULT CURRENT_TIMESTAMP" +
            ")";
    
    public static final String SQL_CREATE_USER = "CREATE TABLE " + TABLE_USER +
            "(" +
            COLUMN_ID + " INTEGER PRIMARY KEY," +
            COLUMN_USER_NAME + " TEXT," +
            COLUMN_USER_LEVEL + " INTEGER DEFAULT 1," +
            COLUMN_USER_EXP + " INTEGER DEFAULT 0," +
            COLUMN_USER_SESSIONS + " INTEGER DEFAULT 0," +
            COLUMN_USER_CALORIES + " INTEGER DEFAULT 0," +
            COLUMN_USER_HOURS + " REAL DEFAULT 0," +
            COLUMN_USER_STREAK + " INTEGER DEFAULT 0" +
            ")";
    
    // SQL Create Training Programs Table
    public static final String SQL_CREATE_TRAINING_PROGRAMS = "CREATE TABLE " + TABLE_TRAINING_PROGRAMS +
            "(" +
            COLUMN_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
            COLUMN_PROGRAM_NAME + " TEXT NOT NULL," +
            COLUMN_PROGRAM_DESCRIPTION + " TEXT," +
            COLUMN_PROGRAM_DURATION_WEEKS + " INTEGER," +
            COLUMN_PROGRAM_DIFFICULTY + " TEXT," +
            COLUMN_PROGRAM_TYPE + " TEXT," +
            COLUMN_PROGRAM_IMAGE_URL + " TEXT," +
            COLUMN_PROGRAM_CREATED_AT + " DATETIME DEFAULT CURRENT_TIMESTAMP," +
            COLUMN_PROGRAM_UPDATED_AT + " DATETIME DEFAULT CURRENT_TIMESTAMP" +
            ")";
    
    // SQL Create Program Enrollments Table
    public static final String SQL_CREATE_PROGRAM_ENROLLMENTS = "CREATE TABLE " + TABLE_PROGRAM_ENROLLMENTS +
            "(" +
            COLUMN_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
            COLUMN_ENROLLMENT_USER_ID + " INTEGER," +
            COLUMN_ENROLLMENT_PROGRAM_ID + " INTEGER," +
            COLUMN_ENROLLMENT_START_DATE + " DATETIME," +
            COLUMN_ENROLLMENT_END_DATE + " DATETIME," +
            COLUMN_ENROLLMENT_CURRENT_WEEK + " INTEGER DEFAULT 1," +
            COLUMN_ENROLLMENT_CURRENT_DAY + " INTEGER DEFAULT 1," +
            COLUMN_ENROLLMENT_PROGRESS + " REAL DEFAULT 0," +
            COLUMN_ENROLLMENT_STATUS + " TEXT DEFAULT 'Active'," +
            COLUMN_ENROLLMENT_LAST_ACTIVITY + " DATETIME," +
            COLUMN_ENROLLMENT_CREATED_AT + " DATETIME DEFAULT CURRENT_TIMESTAMP," +
            COLUMN_ENROLLMENT_UPDATED_AT + " DATETIME DEFAULT CURRENT_TIMESTAMP," +
            "FOREIGN KEY(" + COLUMN_ENROLLMENT_USER_ID + ") REFERENCES " + TABLE_USER + "(" + COLUMN_ID + ")," +
            "FOREIGN KEY(" + COLUMN_ENROLLMENT_PROGRAM_ID + ") REFERENCES " + TABLE_TRAINING_PROGRAMS + "(" + COLUMN_ID + ")" +
            ")";
    
    // SQL Create Workout Sessions Table
    public static final String SQL_CREATE_WORKOUT_SESSIONS = "CREATE TABLE " + TABLE_WORKOUT_SESSIONS +
            "(" +
            COLUMN_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
            COLUMN_SESSION_PROGRAM_ID + " INTEGER," +
            COLUMN_SESSION_NAME + " TEXT NOT NULL," +
            COLUMN_SESSION_SCHEDULED_DATE + " DATETIME NOT NULL," +
            COLUMN_SESSION_DURATION_MINUTES + " INTEGER DEFAULT 60," +
            COLUMN_SESSION_STATUS + " TEXT DEFAULT 'scheduled'," +
            COLUMN_SESSION_NOTES + " TEXT," +
            COLUMN_SESSION_CREATED_AT + " DATETIME DEFAULT CURRENT_TIMESTAMP," +
            COLUMN_SESSION_UPDATED_AT + " DATETIME DEFAULT CURRENT_TIMESTAMP," +
            "FOREIGN KEY(" + COLUMN_SESSION_PROGRAM_ID + ") REFERENCES " + TABLE_TRAINING_PROGRAMS + "(" + COLUMN_ID + ")" +
            ")";
    
    // SQL Delete Statements
    public static final String SQL_DELETE_EXERCISES = "DROP TABLE IF EXISTS " + TABLE_EXERCISES;
    public static final String SQL_DELETE_RECORDS = "DROP TABLE IF EXISTS " + TABLE_RECORDS;
    public static final String SQL_DELETE_USER = "DROP TABLE IF EXISTS " + TABLE_USER;
    public static final String SQL_DELETE_TRAINING_PROGRAMS = "DROP TABLE IF EXISTS " + TABLE_TRAINING_PROGRAMS;
    public static final String SQL_DELETE_PROGRAM_ENROLLMENTS = "DROP TABLE IF EXISTS " + TABLE_PROGRAM_ENROLLMENTS;
    public static final String SQL_DELETE_WORKOUT_SESSIONS = "DROP TABLE IF EXISTS " + TABLE_WORKOUT_SESSIONS;
}
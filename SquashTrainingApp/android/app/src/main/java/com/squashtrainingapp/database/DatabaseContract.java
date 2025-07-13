package com.squashtrainingapp.database;

public final class DatabaseContract {
    
    // Prevent instantiation
    private DatabaseContract() {}
    
    // Database Info
    public static final String DATABASE_NAME = "squashTraining.db";
    public static final int DATABASE_VERSION = 1;
    
    // Table Names
    public static final String TABLE_EXERCISES = "exercises";
    public static final String TABLE_RECORDS = "records";
    public static final String TABLE_USER = "user";
    
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
    
    // SQL Delete Statements
    public static final String SQL_DELETE_EXERCISES = "DROP TABLE IF EXISTS " + TABLE_EXERCISES;
    public static final String SQL_DELETE_RECORDS = "DROP TABLE IF EXISTS " + TABLE_RECORDS;
    public static final String SQL_DELETE_USER = "DROP TABLE IF EXISTS " + TABLE_USER;
}
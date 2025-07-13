package com.squashtrainingapp;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import java.util.ArrayList;
import java.util.List;

public class DatabaseHelper extends SQLiteOpenHelper {
    
    // Database Info
    private static final String DATABASE_NAME = "squashTraining.db";
    private static final int DATABASE_VERSION = 1;
    
    // Table Names
    private static final String TABLE_EXERCISES = "exercises";
    private static final String TABLE_RECORDS = "records";
    private static final String TABLE_USER = "user";
    
    // Exercises Table Columns
    private static final String KEY_EXERCISE_ID = "id";
    private static final String KEY_EXERCISE_NAME = "name";
    private static final String KEY_EXERCISE_CATEGORY = "category";
    private static final String KEY_EXERCISE_DESCRIPTION = "description";
    private static final String KEY_EXERCISE_CHECKED = "is_checked";
    
    // Records Table Columns
    private static final String KEY_RECORD_ID = "id";
    private static final String KEY_RECORD_EXERCISE = "exercise_name";
    private static final String KEY_RECORD_SETS = "sets";
    private static final String KEY_RECORD_REPS = "reps";
    private static final String KEY_RECORD_DURATION = "duration";
    private static final String KEY_RECORD_INTENSITY = "intensity";
    private static final String KEY_RECORD_CONDITION = "condition";
    private static final String KEY_RECORD_FATIGUE = "fatigue";
    private static final String KEY_RECORD_MEMO = "memo";
    private static final String KEY_RECORD_DATE = "date";
    
    // User Table Columns
    private static final String KEY_USER_ID = "id";
    private static final String KEY_USER_NAME = "name";
    private static final String KEY_USER_LEVEL = "level";
    private static final String KEY_USER_EXP = "experience";
    private static final String KEY_USER_SESSIONS = "total_sessions";
    private static final String KEY_USER_CALORIES = "total_calories";
    private static final String KEY_USER_HOURS = "total_hours";
    private static final String KEY_USER_STREAK = "current_streak";
    
    private static DatabaseHelper instance;
    
    public static synchronized DatabaseHelper getInstance(Context context) {
        if (instance == null) {
            instance = new DatabaseHelper(context.getApplicationContext());
        }
        return instance;
    }
    
    private DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }
    
    @Override
    public void onCreate(SQLiteDatabase db) {
        // Create Exercises Table
        String CREATE_EXERCISES_TABLE = "CREATE TABLE " + TABLE_EXERCISES +
                "(" +
                KEY_EXERCISE_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
                KEY_EXERCISE_NAME + " TEXT," +
                KEY_EXERCISE_CATEGORY + " TEXT," +
                KEY_EXERCISE_DESCRIPTION + " TEXT," +
                KEY_EXERCISE_CHECKED + " INTEGER DEFAULT 0" +
                ")";
        
        // Create Records Table
        String CREATE_RECORDS_TABLE = "CREATE TABLE " + TABLE_RECORDS +
                "(" +
                KEY_RECORD_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
                KEY_RECORD_EXERCISE + " TEXT," +
                KEY_RECORD_SETS + " INTEGER," +
                KEY_RECORD_REPS + " INTEGER," +
                KEY_RECORD_DURATION + " INTEGER," +
                KEY_RECORD_INTENSITY + " INTEGER," +
                KEY_RECORD_CONDITION + " INTEGER," +
                KEY_RECORD_FATIGUE + " INTEGER," +
                KEY_RECORD_MEMO + " TEXT," +
                KEY_RECORD_DATE + " DATETIME DEFAULT CURRENT_TIMESTAMP" +
                ")";
        
        // Create User Table
        String CREATE_USER_TABLE = "CREATE TABLE " + TABLE_USER +
                "(" +
                KEY_USER_ID + " INTEGER PRIMARY KEY," +
                KEY_USER_NAME + " TEXT," +
                KEY_USER_LEVEL + " INTEGER DEFAULT 1," +
                KEY_USER_EXP + " INTEGER DEFAULT 0," +
                KEY_USER_SESSIONS + " INTEGER DEFAULT 0," +
                KEY_USER_CALORIES + " INTEGER DEFAULT 0," +
                KEY_USER_HOURS + " REAL DEFAULT 0," +
                KEY_USER_STREAK + " INTEGER DEFAULT 0" +
                ")";
        
        db.execSQL(CREATE_EXERCISES_TABLE);
        db.execSQL(CREATE_RECORDS_TABLE);
        db.execSQL(CREATE_USER_TABLE);
        
        // Insert initial data
        insertInitialData(db);
    }
    
    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_EXERCISES);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_RECORDS);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_USER);
        onCreate(db);
    }
    
    private void insertInitialData(SQLiteDatabase db) {
        // Insert default exercises
        insertExercise(db, "Front Court Drills", "Movement", "Practice lunging and recovering from the front corners");
        insertExercise(db, "Ghosting", "Movement", "Shadow movements around the court without ball");
        insertExercise(db, "Straight Drives", "Technique", "Hit 50 straight drives on each side");
        insertExercise(db, "Cross Courts", "Technique", "Practice cross court shots with good width");
        insertExercise(db, "Boast Practice", "Technique", "Work on two-wall and three-wall boasts");
        insertExercise(db, "Serves & Returns", "Match Play", "Practice different serves and return options");
        
        // Insert default user
        ContentValues userValues = new ContentValues();
        userValues.put(KEY_USER_ID, 1);
        userValues.put(KEY_USER_NAME, "Alex Player");
        userValues.put(KEY_USER_LEVEL, 12);
        userValues.put(KEY_USER_EXP, 750);
        userValues.put(KEY_USER_SESSIONS, 147);
        userValues.put(KEY_USER_CALORIES, 42580);
        userValues.put(KEY_USER_HOURS, 73.5);
        userValues.put(KEY_USER_STREAK, 7);
        db.insert(TABLE_USER, null, userValues);
    }
    
    private void insertExercise(SQLiteDatabase db, String name, String category, String description) {
        ContentValues values = new ContentValues();
        values.put(KEY_EXERCISE_NAME, name);
        values.put(KEY_EXERCISE_CATEGORY, category);
        values.put(KEY_EXERCISE_DESCRIPTION, description);
        values.put(KEY_EXERCISE_CHECKED, 0);
        db.insert(TABLE_EXERCISES, null, values);
    }
    
    // Exercise methods
    public List<Exercise> getAllExercises() {
        List<Exercise> exercises = new ArrayList<>();
        String selectQuery = "SELECT * FROM " + TABLE_EXERCISES;
        
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery(selectQuery, null);
        
        if (cursor.moveToFirst()) {
            do {
                Exercise exercise = new Exercise();
                exercise.id = cursor.getInt(cursor.getColumnIndex(KEY_EXERCISE_ID));
                exercise.name = cursor.getString(cursor.getColumnIndex(KEY_EXERCISE_NAME));
                exercise.category = cursor.getString(cursor.getColumnIndex(KEY_EXERCISE_CATEGORY));
                exercise.description = cursor.getString(cursor.getColumnIndex(KEY_EXERCISE_DESCRIPTION));
                exercise.isChecked = cursor.getInt(cursor.getColumnIndex(KEY_EXERCISE_CHECKED)) == 1;
                exercises.add(exercise);
            } while (cursor.moveToNext());
        }
        
        cursor.close();
        return exercises;
    }
    
    public void updateExerciseChecked(int id, boolean isChecked) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put(KEY_EXERCISE_CHECKED, isChecked ? 1 : 0);
        db.update(TABLE_EXERCISES, values, KEY_EXERCISE_ID + " = ?", new String[]{String.valueOf(id)});
    }
    
    // Record methods
    public long insertRecord(String exercise, int sets, int reps, int duration, 
                           int intensity, int condition, int fatigue, String memo) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put(KEY_RECORD_EXERCISE, exercise);
        values.put(KEY_RECORD_SETS, sets);
        values.put(KEY_RECORD_REPS, reps);
        values.put(KEY_RECORD_DURATION, duration);
        values.put(KEY_RECORD_INTENSITY, intensity);
        values.put(KEY_RECORD_CONDITION, condition);
        values.put(KEY_RECORD_FATIGUE, fatigue);
        values.put(KEY_RECORD_MEMO, memo);
        
        long id = db.insert(TABLE_RECORDS, null, values);
        
        // Update user stats
        updateUserStats(duration);
        
        return id;
    }
    
    // User methods
    public User getUser() {
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.query(TABLE_USER, null, KEY_USER_ID + " = ?", 
                               new String[]{"1"}, null, null, null);
        
        User user = new User();
        if (cursor != null && cursor.moveToFirst()) {
            user.name = cursor.getString(cursor.getColumnIndex(KEY_USER_NAME));
            user.level = cursor.getInt(cursor.getColumnIndex(KEY_USER_LEVEL));
            user.experience = cursor.getInt(cursor.getColumnIndex(KEY_USER_EXP));
            user.totalSessions = cursor.getInt(cursor.getColumnIndex(KEY_USER_SESSIONS));
            user.totalCalories = cursor.getInt(cursor.getColumnIndex(KEY_USER_CALORIES));
            user.totalHours = cursor.getFloat(cursor.getColumnIndex(KEY_USER_HOURS));
            user.currentStreak = cursor.getInt(cursor.getColumnIndex(KEY_USER_STREAK));
            cursor.close();
        }
        
        return user;
    }
    
    private void updateUserStats(int duration) {
        SQLiteDatabase db = this.getWritableDatabase();
        
        // Get current user stats
        User user = getUser();
        
        // Update stats
        user.totalSessions++;
        user.totalHours += duration / 60.0f;
        user.totalCalories += duration * 10; // Rough estimate: 10 cal/min
        user.experience += 50; // 50 XP per session
        
        // Check for level up
        if (user.experience >= 1000) {
            user.level++;
            user.experience -= 1000;
        }
        
        // Update database
        ContentValues values = new ContentValues();
        values.put(KEY_USER_SESSIONS, user.totalSessions);
        values.put(KEY_USER_HOURS, user.totalHours);
        values.put(KEY_USER_CALORIES, user.totalCalories);
        values.put(KEY_USER_EXP, user.experience);
        values.put(KEY_USER_LEVEL, user.level);
        
        db.update(TABLE_USER, values, KEY_USER_ID + " = ?", new String[]{"1"});
    }
    
    // Inner classes
    public static class Exercise {
        public int id;
        public String name;
        public String category;
        public String description;
        public boolean isChecked;
    }
    
    public static class User {
        public String name;
        public int level;
        public int experience;
        public int totalSessions;
        public int totalCalories;
        public float totalHours;
        public int currentStreak;
    }
}
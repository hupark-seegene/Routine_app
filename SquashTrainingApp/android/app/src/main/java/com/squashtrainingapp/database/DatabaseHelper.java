package com.squashtrainingapp.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import com.squashtrainingapp.database.dao.ExerciseDao;
import com.squashtrainingapp.database.dao.RecordDao;
import com.squashtrainingapp.database.dao.UserDao;

public class DatabaseHelper extends SQLiteOpenHelper {
    
    private static DatabaseHelper instance;
    
    // DAOs
    private ExerciseDao exerciseDao;
    private RecordDao recordDao;
    private UserDao userDao;
    
    public static synchronized DatabaseHelper getInstance(Context context) {
        if (instance == null) {
            instance = new DatabaseHelper(context.getApplicationContext());
        }
        return instance;
    }
    
    private DatabaseHelper(Context context) {
        super(context, DatabaseContract.DATABASE_NAME, null, DatabaseContract.DATABASE_VERSION);
    }
    
    @Override
    public void onCreate(SQLiteDatabase db) {
        // Create tables
        db.execSQL(DatabaseContract.SQL_CREATE_EXERCISES);
        db.execSQL(DatabaseContract.SQL_CREATE_RECORDS);
        db.execSQL(DatabaseContract.SQL_CREATE_USER);
        db.execSQL(DatabaseContract.SQL_CREATE_TRAINING_PROGRAMS);
        db.execSQL(DatabaseContract.SQL_CREATE_PROGRAM_ENROLLMENTS);
        
        // Insert initial data
        insertInitialData(db);
    }
    
    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // Drop existing tables
        db.execSQL(DatabaseContract.SQL_DELETE_PROGRAM_ENROLLMENTS);
        db.execSQL(DatabaseContract.SQL_DELETE_TRAINING_PROGRAMS);
        db.execSQL(DatabaseContract.SQL_DELETE_EXERCISES);
        db.execSQL(DatabaseContract.SQL_DELETE_RECORDS);
        db.execSQL(DatabaseContract.SQL_DELETE_USER);
        
        // Recreate tables
        onCreate(db);
    }
    
    private void insertInitialData(SQLiteDatabase db) {
        // Use DAOs with the provided database instance
        ExerciseDao exerciseDao = new ExerciseDao(db);
        UserDao userDao = new UserDao(db);
        
        // Insert default data
        exerciseDao.insertDefaultExercises();
        userDao.insertDefaultUser();
    }
    
    // Get DAO instances
    public ExerciseDao getExerciseDao() {
        if (exerciseDao == null) {
            exerciseDao = new ExerciseDao(getWritableDatabase());
        }
        return exerciseDao;
    }
    
    public RecordDao getRecordDao() {
        if (recordDao == null) {
            recordDao = new RecordDao(getWritableDatabase());
        }
        return recordDao;
    }
    
    public UserDao getUserDao() {
        if (userDao == null) {
            userDao = new UserDao(getWritableDatabase());
        }
        return userDao;
    }
}
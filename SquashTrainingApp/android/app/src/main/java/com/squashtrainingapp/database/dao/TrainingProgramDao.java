package com.squashtrainingapp.database.dao;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import com.squashtrainingapp.database.DatabaseContract;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.TrainingProgram;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class TrainingProgramDao {
    
    private DatabaseHelper dbHelper;
    private SQLiteDatabase database;
    
    public TrainingProgramDao(DatabaseHelper dbHelper) {
        this.dbHelper = dbHelper;
    }
    
    public TrainingProgramDao(SQLiteDatabase database) {
        this.database = database;
    }
    
    // Insert a new training program
    public long insert(TrainingProgram program) {
        SQLiteDatabase db = database != null ? database : dbHelper.getWritableDatabase();
        
        ContentValues values = new ContentValues();
        values.put(DatabaseContract.COLUMN_PROGRAM_NAME, program.getName());
        values.put(DatabaseContract.COLUMN_PROGRAM_DESCRIPTION, program.getDescription());
        values.put(DatabaseContract.COLUMN_PROGRAM_DURATION_WEEKS, program.getDurationWeeks());
        values.put(DatabaseContract.COLUMN_PROGRAM_DIFFICULTY, program.getDifficulty());
        values.put(DatabaseContract.COLUMN_PROGRAM_TYPE, program.getType());
        values.put(DatabaseContract.COLUMN_PROGRAM_IMAGE_URL, program.getImageUrl());
        
        long id = db.insert(DatabaseContract.TABLE_TRAINING_PROGRAMS, null, values);
        
        if (database == null) {
            db.close();
        }
        
        return id;
    }
    
    // Get all training programs
    public List<TrainingProgram> getAllPrograms() {
        List<TrainingProgram> programs = new ArrayList<>();
        SQLiteDatabase db = database != null ? database : dbHelper.getReadableDatabase();
        
        Cursor cursor = db.query(
            DatabaseContract.TABLE_TRAINING_PROGRAMS,
            null,
            null,
            null,
            null,
            null,
            DatabaseContract.COLUMN_PROGRAM_NAME + " ASC"
        );
        
        while (cursor.moveToNext()) {
            TrainingProgram program = cursorToProgram(cursor);
            programs.add(program);
        }
        
        cursor.close();
        if (database == null) {
            db.close();
        }
        
        return programs;
    }
    
    // Get programs by type
    public List<TrainingProgram> getProgramsByType(String type) {
        List<TrainingProgram> programs = new ArrayList<>();
        SQLiteDatabase db = database != null ? database : dbHelper.getReadableDatabase();
        
        Cursor cursor = db.query(
            DatabaseContract.TABLE_TRAINING_PROGRAMS,
            null,
            DatabaseContract.COLUMN_PROGRAM_TYPE + " = ?",
            new String[]{type},
            null,
            null,
            DatabaseContract.COLUMN_PROGRAM_NAME + " ASC"
        );
        
        while (cursor.moveToNext()) {
            TrainingProgram program = cursorToProgram(cursor);
            programs.add(program);
        }
        
        cursor.close();
        if (database == null) {
            db.close();
        }
        
        return programs;
    }
    
    // Get programs by difficulty
    public List<TrainingProgram> getProgramsByDifficulty(String difficulty) {
        List<TrainingProgram> programs = new ArrayList<>();
        SQLiteDatabase db = database != null ? database : dbHelper.getReadableDatabase();
        
        Cursor cursor = db.query(
            DatabaseContract.TABLE_TRAINING_PROGRAMS,
            null,
            DatabaseContract.COLUMN_PROGRAM_DIFFICULTY + " = ?",
            new String[]{difficulty},
            null,
            null,
            DatabaseContract.COLUMN_PROGRAM_NAME + " ASC"
        );
        
        while (cursor.moveToNext()) {
            TrainingProgram program = cursorToProgram(cursor);
            programs.add(program);
        }
        
        cursor.close();
        if (database == null) {
            db.close();
        }
        
        return programs;
    }
    
    // Get program by ID
    public TrainingProgram getProgramById(long id) {
        SQLiteDatabase db = database != null ? database : dbHelper.getReadableDatabase();
        
        Cursor cursor = db.query(
            DatabaseContract.TABLE_TRAINING_PROGRAMS,
            null,
            DatabaseContract.COLUMN_ID + " = ?",
            new String[]{String.valueOf(id)},
            null,
            null,
            null
        );
        
        TrainingProgram program = null;
        if (cursor.moveToFirst()) {
            program = cursorToProgram(cursor);
        }
        
        cursor.close();
        if (database == null) {
            db.close();
        }
        
        return program;
    }
    
    // Update program
    public int update(TrainingProgram program) {
        SQLiteDatabase db = database != null ? database : dbHelper.getWritableDatabase();
        
        ContentValues values = new ContentValues();
        values.put(DatabaseContract.COLUMN_PROGRAM_NAME, program.getName());
        values.put(DatabaseContract.COLUMN_PROGRAM_DESCRIPTION, program.getDescription());
        values.put(DatabaseContract.COLUMN_PROGRAM_DURATION_WEEKS, program.getDurationWeeks());
        values.put(DatabaseContract.COLUMN_PROGRAM_DIFFICULTY, program.getDifficulty());
        values.put(DatabaseContract.COLUMN_PROGRAM_TYPE, program.getType());
        values.put(DatabaseContract.COLUMN_PROGRAM_IMAGE_URL, program.getImageUrl());
        values.put(DatabaseContract.COLUMN_PROGRAM_UPDATED_AT, new Date().getTime());
        
        int rowsAffected = db.update(
            DatabaseContract.TABLE_TRAINING_PROGRAMS,
            values,
            DatabaseContract.COLUMN_ID + " = ?",
            new String[]{String.valueOf(program.getId())}
        );
        
        if (database == null) {
            db.close();
        }
        
        return rowsAffected;
    }
    
    // Delete program
    public int delete(long id) {
        SQLiteDatabase db = database != null ? database : dbHelper.getWritableDatabase();
        
        int rowsDeleted = db.delete(
            DatabaseContract.TABLE_TRAINING_PROGRAMS,
            DatabaseContract.COLUMN_ID + " = ?",
            new String[]{String.valueOf(id)}
        );
        
        if (database == null) {
            db.close();
        }
        
        return rowsDeleted;
    }
    
    // Convert cursor to TrainingProgram object
    private TrainingProgram cursorToProgram(Cursor cursor) {
        TrainingProgram program = new TrainingProgram();
        
        program.setId(cursor.getLong(cursor.getColumnIndex(DatabaseContract.COLUMN_ID)));
        program.setName(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_PROGRAM_NAME)));
        program.setDescription(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_PROGRAM_DESCRIPTION)));
        program.setDurationWeeks(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_PROGRAM_DURATION_WEEKS)));
        program.setDifficulty(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_PROGRAM_DIFFICULTY)));
        program.setType(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_PROGRAM_TYPE)));
        program.setImageUrl(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_PROGRAM_IMAGE_URL)));
        
        return program;
    }
    
    // Insert default training programs
    public void insertDefaultPrograms() {
        SQLiteDatabase db = database != null ? database : dbHelper.getWritableDatabase();
        
        // 4-Week Focus Programs
        insert(new TrainingProgram(
            "Power Development",
            "Intensive 4-week program to build explosive power for your shots",
            4,
            "Intermediate",
            "Focus"
        ));
        
        insert(new TrainingProgram(
            "Speed & Agility",
            "Improve your court movement and reaction time in 4 weeks",
            4,
            "Intermediate",
            "Focus"
        ));
        
        insert(new TrainingProgram(
            "Endurance Builder",
            "Build stamina to outlast your opponents in long matches",
            4,
            "Beginner",
            "Focus"
        ));
        
        // 12-Week Master Programs
        insert(new TrainingProgram(
            "Complete Player",
            "Comprehensive 12-week program covering all aspects of squash",
            12,
            "Advanced",
            "Master"
        ));
        
        insert(new TrainingProgram(
            "Competition Prep",
            "Get tournament-ready with this intensive 12-week program",
            12,
            "Advanced",
            "Master"
        ));
        
        // Season Programs
        insert(new TrainingProgram(
            "Pre-Season Conditioning",
            "Get in shape before the competitive season starts",
            8,
            "Intermediate",
            "Season"
        ));
        
        insert(new TrainingProgram(
            "In-Season Maintenance",
            "Maintain peak performance throughout the season",
            16,
            "Intermediate",
            "Season"
        ));
        
        insert(new TrainingProgram(
            "Off-Season Recovery",
            "Active recovery and skill development in the off-season",
            6,
            "Beginner",
            "Season"
        ));
    }
}
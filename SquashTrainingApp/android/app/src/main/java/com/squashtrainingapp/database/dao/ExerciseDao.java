package com.squashtrainingapp.database.dao;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import com.squashtrainingapp.models.Exercise;
import com.squashtrainingapp.database.DatabaseContract;
import java.util.ArrayList;
import java.util.List;

public class ExerciseDao {
    
    private SQLiteDatabase database;
    
    public ExerciseDao(SQLiteDatabase database) {
        this.database = database;
    }
    
    // Insert exercise
    public long insert(Exercise exercise) {
        ContentValues values = new ContentValues();
        values.put(DatabaseContract.COLUMN_EXERCISE_NAME, exercise.getName());
        values.put(DatabaseContract.COLUMN_EXERCISE_CATEGORY, exercise.getCategory());
        values.put(DatabaseContract.COLUMN_EXERCISE_DESCRIPTION, exercise.getDescription());
        values.put(DatabaseContract.COLUMN_EXERCISE_CHECKED, exercise.isChecked() ? 1 : 0);
        
        return database.insert(DatabaseContract.TABLE_EXERCISES, null, values);
    }
    
    // Get all exercises
    public List<Exercise> getAllExercises() {
        List<Exercise> exercises = new ArrayList<>();
        String selectQuery = "SELECT * FROM " + DatabaseContract.TABLE_EXERCISES;
        
        Cursor cursor = database.rawQuery(selectQuery, null);
        
        if (cursor.moveToFirst()) {
            do {
                Exercise exercise = cursorToExercise(cursor);
                exercises.add(exercise);
            } while (cursor.moveToNext());
        }
        
        cursor.close();
        return exercises;
    }
    
    // Get exercises by category
    public List<Exercise> getExercisesByCategory(String category) {
        List<Exercise> exercises = new ArrayList<>();
        String selection = DatabaseContract.COLUMN_EXERCISE_CATEGORY + " = ?";
        String[] selectionArgs = { category };
        
        Cursor cursor = database.query(
            DatabaseContract.TABLE_EXERCISES,
            null,
            selection,
            selectionArgs,
            null,
            null,
            null
        );
        
        if (cursor.moveToFirst()) {
            do {
                Exercise exercise = cursorToExercise(cursor);
                exercises.add(exercise);
            } while (cursor.moveToNext());
        }
        
        cursor.close();
        return exercises;
    }
    
    // Update exercise checked status
    public int updateCheckedStatus(int id, boolean isChecked) {
        ContentValues values = new ContentValues();
        values.put(DatabaseContract.COLUMN_EXERCISE_CHECKED, isChecked ? 1 : 0);
        
        return database.update(
            DatabaseContract.TABLE_EXERCISES,
            values,
            DatabaseContract.COLUMN_ID + " = ?",
            new String[] { String.valueOf(id) }
        );
    }
    
    // Delete exercise
    public int delete(int id) {
        return database.delete(
            DatabaseContract.TABLE_EXERCISES,
            DatabaseContract.COLUMN_ID + " = ?",
            new String[] { String.valueOf(id) }
        );
    }
    
    // Insert default exercises
    public void insertDefaultExercises() {
        String[][] defaultExercises = {
            {"Front Court Drills", "Movement", "Practice lunging and recovering from the front corners"},
            {"Ghosting", "Movement", "Shadow movements around the court without ball"},
            {"Straight Drives", "Technique", "Hit 50 straight drives on each side"},
            {"Cross Courts", "Technique", "Practice cross court shots with good width"},
            {"Boast Practice", "Technique", "Work on two-wall and three-wall boasts"},
            {"Serves & Returns", "Match Play", "Practice different serves and return options"}
        };
        
        for (String[] data : defaultExercises) {
            Exercise exercise = new Exercise(data[0], data[1], data[2]);
            insert(exercise);
        }
    }
    
    // Helper method to convert cursor to exercise
    private Exercise cursorToExercise(Cursor cursor) {
        Exercise exercise = new Exercise();
        exercise.setId(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_ID)));
        exercise.setName(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_EXERCISE_NAME)));
        exercise.setCategory(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_EXERCISE_CATEGORY)));
        exercise.setDescription(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_EXERCISE_DESCRIPTION)));
        exercise.setChecked(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_EXERCISE_CHECKED)) == 1);
        return exercise;
    }
}
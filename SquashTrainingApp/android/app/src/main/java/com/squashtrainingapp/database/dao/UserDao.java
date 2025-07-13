package com.squashtrainingapp.database.dao;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import com.squashtrainingapp.models.User;
import com.squashtrainingapp.database.DatabaseContract;

public class UserDao {
    
    private SQLiteDatabase database;
    
    public UserDao(SQLiteDatabase database) {
        this.database = database;
    }
    
    // Insert user
    public long insert(User user) {
        ContentValues values = new ContentValues();
        values.put(DatabaseContract.COLUMN_ID, user.getId());
        values.put(DatabaseContract.COLUMN_USER_NAME, user.getName());
        values.put(DatabaseContract.COLUMN_USER_LEVEL, user.getLevel());
        values.put(DatabaseContract.COLUMN_USER_EXP, user.getExperience());
        values.put(DatabaseContract.COLUMN_USER_SESSIONS, user.getTotalSessions());
        values.put(DatabaseContract.COLUMN_USER_CALORIES, user.getTotalCalories());
        values.put(DatabaseContract.COLUMN_USER_HOURS, user.getTotalHours());
        values.put(DatabaseContract.COLUMN_USER_STREAK, user.getCurrentStreak());
        
        return database.insert(DatabaseContract.TABLE_USER, null, values);
    }
    
    // Get user (always returns user with id = 1)
    public User getUser() {
        User user = null;
        Cursor cursor = database.query(
            DatabaseContract.TABLE_USER,
            null,
            DatabaseContract.COLUMN_ID + " = ?",
            new String[] { "1" },
            null,
            null,
            null
        );
        
        if (cursor != null && cursor.moveToFirst()) {
            user = cursorToUser(cursor);
            cursor.close();
        }
        
        // Return default user if none exists
        if (user == null) {
            user = createDefaultUser();
        }
        
        return user;
    }
    
    // Update user
    public int update(User user) {
        ContentValues values = new ContentValues();
        values.put(DatabaseContract.COLUMN_USER_NAME, user.getName());
        values.put(DatabaseContract.COLUMN_USER_LEVEL, user.getLevel());
        values.put(DatabaseContract.COLUMN_USER_EXP, user.getExperience());
        values.put(DatabaseContract.COLUMN_USER_SESSIONS, user.getTotalSessions());
        values.put(DatabaseContract.COLUMN_USER_CALORIES, user.getTotalCalories());
        values.put(DatabaseContract.COLUMN_USER_HOURS, user.getTotalHours());
        values.put(DatabaseContract.COLUMN_USER_STREAK, user.getCurrentStreak());
        
        return database.update(
            DatabaseContract.TABLE_USER,
            values,
            DatabaseContract.COLUMN_ID + " = ?",
            new String[] { "1" }
        );
    }
    
    // Update user stats after workout
    public void updateAfterWorkout(int duration) {
        User user = getUser();
        user.addSession(duration);
        update(user);
    }
    
    // Insert default user
    public void insertDefaultUser() {
        User defaultUser = new User(
            1,
            "Alex Player",
            12,
            750,
            147,
            42580,
            73.5f,
            7
        );
        insert(defaultUser);
    }
    
    // Create default user instance
    private User createDefaultUser() {
        return new User(
            1,
            "Player",
            1,
            0,
            0,
            0,
            0,
            0
        );
    }
    
    // Helper method to convert cursor to user
    private User cursorToUser(Cursor cursor) {
        User user = new User();
        user.setId(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_ID)));
        user.setName(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_USER_NAME)));
        user.setLevel(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_USER_LEVEL)));
        user.setExperience(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_USER_EXP)));
        user.setTotalSessions(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_USER_SESSIONS)));
        user.setTotalCalories(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_USER_CALORIES)));
        user.setTotalHours(cursor.getFloat(cursor.getColumnIndex(DatabaseContract.COLUMN_USER_HOURS)));
        user.setCurrentStreak(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_USER_STREAK)));
        return user;
    }
}
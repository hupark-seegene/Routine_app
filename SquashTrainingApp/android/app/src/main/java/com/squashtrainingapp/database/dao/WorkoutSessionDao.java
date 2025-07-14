package com.squashtrainingapp.database.dao;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import com.squashtrainingapp.database.DatabaseContract;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.WorkoutSession;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class WorkoutSessionDao {
    private SQLiteDatabase database;
    private DatabaseHelper dbHelper;
    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
    
    public WorkoutSessionDao(DatabaseHelper dbHelper) {
        this.dbHelper = dbHelper;
    }
    
    public WorkoutSessionDao(SQLiteDatabase database) {
        this.database = database;
    }
    
    private SQLiteDatabase getDb() {
        if (database != null) {
            return database;
        }
        return dbHelper.getWritableDatabase();
    }
    
    // Insert new workout session
    public long insertSession(WorkoutSession session) {
        ContentValues values = new ContentValues();
        values.put(DatabaseContract.COLUMN_SESSION_PROGRAM_ID, session.getProgramId());
        values.put(DatabaseContract.COLUMN_SESSION_NAME, session.getSessionName());
        values.put(DatabaseContract.COLUMN_SESSION_SCHEDULED_DATE, dateFormat.format(session.getScheduledDate()));
        values.put(DatabaseContract.COLUMN_SESSION_DURATION_MINUTES, session.getDurationMinutes());
        values.put(DatabaseContract.COLUMN_SESSION_STATUS, session.getStatus());
        values.put(DatabaseContract.COLUMN_SESSION_NOTES, session.getNotes());
        
        long id = getDb().insert(DatabaseContract.TABLE_WORKOUT_SESSIONS, null, values);
        session.setId(id);
        return id;
    }
    
    // Get all sessions
    public List<WorkoutSession> getAllSessions() {
        List<WorkoutSession> sessions = new ArrayList<>();
        Cursor cursor = getDb().query(
            DatabaseContract.TABLE_WORKOUT_SESSIONS,
            null,
            null,
            null,
            null,
            null,
            DatabaseContract.COLUMN_SESSION_SCHEDULED_DATE + " ASC"
        );
        
        while (cursor.moveToNext()) {
            sessions.add(cursorToSession(cursor));
        }
        cursor.close();
        return sessions;
    }
    
    // Get upcoming sessions
    public List<WorkoutSession> getUpcomingSessions() {
        List<WorkoutSession> sessions = new ArrayList<>();
        String currentDate = dateFormat.format(new Date());
        
        Cursor cursor = getDb().query(
            DatabaseContract.TABLE_WORKOUT_SESSIONS,
            null,
            DatabaseContract.COLUMN_SESSION_SCHEDULED_DATE + " >= ? AND " + 
            DatabaseContract.COLUMN_SESSION_STATUS + " = ?",
            new String[]{currentDate, "scheduled"},
            null,
            null,
            DatabaseContract.COLUMN_SESSION_SCHEDULED_DATE + " ASC"
        );
        
        while (cursor.moveToNext()) {
            sessions.add(cursorToSession(cursor));
        }
        cursor.close();
        return sessions;
    }
    
    // Get sessions by program
    public List<WorkoutSession> getSessionsByProgram(long programId) {
        List<WorkoutSession> sessions = new ArrayList<>();
        
        Cursor cursor = getDb().query(
            DatabaseContract.TABLE_WORKOUT_SESSIONS,
            null,
            DatabaseContract.COLUMN_SESSION_PROGRAM_ID + " = ?",
            new String[]{String.valueOf(programId)},
            null,
            null,
            DatabaseContract.COLUMN_SESSION_SCHEDULED_DATE + " ASC"
        );
        
        while (cursor.moveToNext()) {
            sessions.add(cursorToSession(cursor));
        }
        cursor.close();
        return sessions;
    }
    
    // Update session status
    public int updateSessionStatus(long sessionId, String status) {
        ContentValues values = new ContentValues();
        values.put(DatabaseContract.COLUMN_SESSION_STATUS, status);
        values.put(DatabaseContract.COLUMN_SESSION_UPDATED_AT, dateFormat.format(new Date()));
        
        return getDb().update(
            DatabaseContract.TABLE_WORKOUT_SESSIONS,
            values,
            DatabaseContract.COLUMN_ID + " = ?",
            new String[]{String.valueOf(sessionId)}
        );
    }
    
    // Delete session
    public int deleteSession(long sessionId) {
        return getDb().delete(
            DatabaseContract.TABLE_WORKOUT_SESSIONS,
            DatabaseContract.COLUMN_ID + " = ?",
            new String[]{String.valueOf(sessionId)}
        );
    }
    
    // Convert cursor to WorkoutSession
    private WorkoutSession cursorToSession(Cursor cursor) {
        WorkoutSession session = new WorkoutSession();
        
        int idIndex = cursor.getColumnIndex(DatabaseContract.COLUMN_ID);
        int programIdIndex = cursor.getColumnIndex(DatabaseContract.COLUMN_SESSION_PROGRAM_ID);
        int nameIndex = cursor.getColumnIndex(DatabaseContract.COLUMN_SESSION_NAME);
        int dateIndex = cursor.getColumnIndex(DatabaseContract.COLUMN_SESSION_SCHEDULED_DATE);
        int durationIndex = cursor.getColumnIndex(DatabaseContract.COLUMN_SESSION_DURATION_MINUTES);
        int statusIndex = cursor.getColumnIndex(DatabaseContract.COLUMN_SESSION_STATUS);
        int notesIndex = cursor.getColumnIndex(DatabaseContract.COLUMN_SESSION_NOTES);
        
        if (idIndex != -1) session.setId(cursor.getLong(idIndex));
        if (programIdIndex != -1) session.setProgramId(cursor.getLong(programIdIndex));
        if (nameIndex != -1) session.setSessionName(cursor.getString(nameIndex));
        if (durationIndex != -1) session.setDurationMinutes(cursor.getInt(durationIndex));
        if (statusIndex != -1) session.setStatus(cursor.getString(statusIndex));
        if (notesIndex != -1) session.setNotes(cursor.getString(notesIndex));
        
        if (dateIndex != -1) {
            try {
                session.setScheduledDate(dateFormat.parse(cursor.getString(dateIndex)));
            } catch (Exception e) {
                session.setScheduledDate(new Date());
            }
        }
        
        return session;
    }
}
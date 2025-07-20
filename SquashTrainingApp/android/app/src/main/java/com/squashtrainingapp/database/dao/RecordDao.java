package com.squashtrainingapp.database.dao;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import com.squashtrainingapp.models.Record;
import com.squashtrainingapp.database.DatabaseContract;
import java.util.ArrayList;
import java.util.List;

public class RecordDao {
    
    private SQLiteDatabase database;
    
    public RecordDao(SQLiteDatabase database) {
        this.database = database;
    }
    
    // Insert record
    public long insert(Record record) {
        ContentValues values = new ContentValues();
        values.put(DatabaseContract.COLUMN_RECORD_EXERCISE, record.getExerciseName());
        values.put(DatabaseContract.COLUMN_RECORD_SETS, record.getSets());
        values.put(DatabaseContract.COLUMN_RECORD_REPS, record.getReps());
        values.put(DatabaseContract.COLUMN_RECORD_DURATION, record.getDuration());
        values.put(DatabaseContract.COLUMN_RECORD_INTENSITY, record.getIntensity());
        values.put(DatabaseContract.COLUMN_RECORD_CONDITION, record.getCondition());
        values.put(DatabaseContract.COLUMN_RECORD_FATIGUE, record.getFatigue());
        values.put(DatabaseContract.COLUMN_RECORD_MEMO, record.getMemo());
        
        return database.insert(DatabaseContract.TABLE_RECORDS, null, values);
    }
    
    // Get all records
    public List<Record> getAllRecords() {
        List<Record> records = new ArrayList<>();
        String selectQuery = "SELECT * FROM " + DatabaseContract.TABLE_RECORDS + 
                           " ORDER BY " + DatabaseContract.COLUMN_RECORD_DATE + " DESC";
        
        Cursor cursor = database.rawQuery(selectQuery, null);
        
        if (cursor.moveToFirst()) {
            do {
                Record record = cursorToRecord(cursor);
                records.add(record);
            } while (cursor.moveToNext());
        }
        
        cursor.close();
        return records;
    }
    
    // Get records by date range
    public List<Record> getRecordsByDateRange(String startDate, String endDate) {
        List<Record> records = new ArrayList<>();
        String selection = DatabaseContract.COLUMN_RECORD_DATE + " BETWEEN ? AND ?";
        String[] selectionArgs = { startDate, endDate };
        
        Cursor cursor = database.query(
            DatabaseContract.TABLE_RECORDS,
            null,
            selection,
            selectionArgs,
            null,
            null,
            DatabaseContract.COLUMN_RECORD_DATE + " DESC"
        );
        
        if (cursor.moveToFirst()) {
            do {
                Record record = cursorToRecord(cursor);
                records.add(record);
            } while (cursor.moveToNext());
        }
        
        cursor.close();
        return records;
    }
    
    // Get records between dates (using timestamp)
    public List<Record> getRecordsBetweenDates(long startTime, long endTime) {
        List<Record> records = new ArrayList<>();
        // Convert timestamps to date strings for comparison
        String startDate = new java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.getDefault()).format(new java.util.Date(startTime));
        String endDate = new java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.getDefault()).format(new java.util.Date(endTime));
        
        String selection = DatabaseContract.COLUMN_RECORD_DATE + " BETWEEN ? AND ?";
        String[] selectionArgs = { startDate, endDate };
        
        Cursor cursor = database.query(
            DatabaseContract.TABLE_RECORDS,
            null,
            selection,
            selectionArgs,
            null,
            null,
            DatabaseContract.COLUMN_RECORD_DATE + " DESC"
        );
        
        if (cursor.moveToFirst()) {
            do {
                Record record = cursorToRecord(cursor);
                records.add(record);
            } while (cursor.moveToNext());
        }
        
        cursor.close();
        return records;
    }
    
    // Get records count
    public int getRecordsCount() {
        String countQuery = "SELECT COUNT(*) FROM " + DatabaseContract.TABLE_RECORDS;
        Cursor cursor = database.rawQuery(countQuery, null);
        int count = 0;
        
        if (cursor.moveToFirst()) {
            count = cursor.getInt(0);
        }
        
        cursor.close();
        return count;
    }
    
    // Delete record
    public int delete(int id) {
        return database.delete(
            DatabaseContract.TABLE_RECORDS,
            DatabaseContract.COLUMN_ID + " = ?",
            new String[] { String.valueOf(id) }
        );
    }
    
    // Get statistics
    public int getTotalDuration() {
        String sumQuery = "SELECT SUM(" + DatabaseContract.COLUMN_RECORD_DURATION + ") FROM " + 
                         DatabaseContract.TABLE_RECORDS;
        Cursor cursor = database.rawQuery(sumQuery, null);
        int total = 0;
        
        if (cursor.moveToFirst()) {
            total = cursor.getInt(0);
        }
        
        cursor.close();
        return total;
    }
    
    // Helper method to convert cursor to record
    private Record cursorToRecord(Cursor cursor) {
        Record record = new Record();
        record.setId(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_ID)));
        record.setExerciseName(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_RECORD_EXERCISE)));
        record.setSets(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_RECORD_SETS)));
        record.setReps(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_RECORD_REPS)));
        record.setDuration(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_RECORD_DURATION)));
        record.setIntensity(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_RECORD_INTENSITY)));
        record.setCondition(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_RECORD_CONDITION)));
        record.setFatigue(cursor.getInt(cursor.getColumnIndex(DatabaseContract.COLUMN_RECORD_FATIGUE)));
        record.setMemo(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_RECORD_MEMO)));
        record.setDate(cursor.getString(cursor.getColumnIndex(DatabaseContract.COLUMN_RECORD_DATE)));
        return record;
    }
}
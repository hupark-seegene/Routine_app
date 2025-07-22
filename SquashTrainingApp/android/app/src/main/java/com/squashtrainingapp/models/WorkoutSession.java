package com.squashtrainingapp.models;

import java.util.Date;

public class WorkoutSession {
    private long id;
    private long programId;
    private String sessionName;
    private Date scheduledDate;
    private int durationMinutes;
    private String status; // scheduled, completed, cancelled
    private String notes;
    private Date createdAt;
    private Date updatedAt;
    
    // Constructor
    public WorkoutSession() {
        this.createdAt = new Date();
        this.updatedAt = new Date();
        this.status = "scheduled";
    }
    
    // Constructor with parameters
    public WorkoutSession(long programId, String sessionName, Date scheduledDate, int durationMinutes) {
        this();
        this.programId = programId;
        this.sessionName = sessionName;
        this.scheduledDate = scheduledDate;
        this.durationMinutes = durationMinutes;
    }
    
    // Getters and Setters
    public long getId() {
        return id;
    }
    
    public void setId(long id) {
        this.id = id;
    }
    
    public long getProgramId() {
        return programId;
    }
    
    public void setProgramId(long programId) {
        this.programId = programId;
    }
    
    public String getSessionName() {
        return sessionName;
    }
    
    public void setSessionName(String sessionName) {
        this.sessionName = sessionName;
    }
    
    public Date getScheduledDate() {
        return scheduledDate;
    }
    
    public void setScheduledDate(Date scheduledDate) {
        this.scheduledDate = scheduledDate;
    }
    
    public int getDurationMinutes() {
        return durationMinutes;
    }
    
    public void setDurationMinutes(int durationMinutes) {
        this.durationMinutes = durationMinutes;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
    
    public Date getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
    
    public Date getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    // Additional methods for GPT4CoachingService
    public int getDuration() {
        return durationMinutes * 60; // Return duration in seconds
    }
    
    public String getIntensity() {
        // Return intensity based on duration or notes
        if (durationMinutes >= 60) return "High";
        else if (durationMinutes >= 30) return "Medium";
        else return "Low";
    }
    
    public String getExerciseTypes() {
        // Return exercise types from session name or default
        return sessionName != null ? sessionName : "General Training";
    }
}
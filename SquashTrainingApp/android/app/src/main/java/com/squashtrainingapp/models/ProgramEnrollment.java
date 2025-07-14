package com.squashtrainingapp.models;

import java.util.Date;

public class ProgramEnrollment {
    private long id;
    private long userId;
    private long programId;
    private Date startDate;
    private Date endDate;
    private int currentWeek;
    private int currentDay;
    private float progressPercentage;
    private String status; // Active, Completed, Paused, Cancelled
    private Date lastActivityDate;
    private Date createdAt;
    private Date updatedAt;
    
    // Constructor
    public ProgramEnrollment() {
        this.createdAt = new Date();
        this.updatedAt = new Date();
        this.currentWeek = 1;
        this.currentDay = 1;
        this.progressPercentage = 0.0f;
        this.status = "Active";
    }
    
    public ProgramEnrollment(long userId, long programId, Date startDate, Date endDate) {
        this.userId = userId;
        this.programId = programId;
        this.startDate = startDate;
        this.endDate = endDate;
        this.currentWeek = 1;
        this.currentDay = 1;
        this.progressPercentage = 0.0f;
        this.status = "Active";
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }
    
    // Calculate progress based on current week and total duration
    public void updateProgress(int totalWeeks) {
        if (totalWeeks > 0) {
            this.progressPercentage = ((float) currentWeek / totalWeeks) * 100;
            this.updatedAt = new Date();
        }
    }
    
    // Getters and Setters
    public long getId() {
        return id;
    }
    
    public void setId(long id) {
        this.id = id;
    }
    
    public long getUserId() {
        return userId;
    }
    
    public void setUserId(long userId) {
        this.userId = userId;
        this.updatedAt = new Date();
    }
    
    public long getProgramId() {
        return programId;
    }
    
    public void setProgramId(long programId) {
        this.programId = programId;
        this.updatedAt = new Date();
    }
    
    public Date getStartDate() {
        return startDate;
    }
    
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
        this.updatedAt = new Date();
    }
    
    public Date getEndDate() {
        return endDate;
    }
    
    public void setEndDate(Date endDate) {
        this.endDate = endDate;
        this.updatedAt = new Date();
    }
    
    public int getCurrentWeek() {
        return currentWeek;
    }
    
    public void setCurrentWeek(int currentWeek) {
        this.currentWeek = currentWeek;
        this.updatedAt = new Date();
    }
    
    public int getCurrentDay() {
        return currentDay;
    }
    
    public void setCurrentDay(int currentDay) {
        this.currentDay = currentDay;
        this.updatedAt = new Date();
    }
    
    public float getProgressPercentage() {
        return progressPercentage;
    }
    
    public void setProgressPercentage(float progressPercentage) {
        this.progressPercentage = progressPercentage;
        this.updatedAt = new Date();
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = new Date();
    }
    
    public Date getLastActivityDate() {
        return lastActivityDate;
    }
    
    public void setLastActivityDate(Date lastActivityDate) {
        this.lastActivityDate = lastActivityDate;
        this.updatedAt = new Date();
    }
    
    public Date getCreatedAt() {
        return createdAt;
    }
    
    public Date getUpdatedAt() {
        return updatedAt;
    }
}
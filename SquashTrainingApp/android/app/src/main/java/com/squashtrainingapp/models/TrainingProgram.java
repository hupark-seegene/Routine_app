package com.squashtrainingapp.models;

import java.util.Date;

public class TrainingProgram {
    private long id;
    private String name;
    private String description;
    private int durationWeeks;
    private String difficulty; // Beginner, Intermediate, Advanced
    private String type; // Focus, Master, Season
    private String imageUrl;
    private Date createdAt;
    private Date updatedAt;
    
    // Constructor
    public TrainingProgram() {
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }
    
    public TrainingProgram(String name, String description, int durationWeeks, 
                          String difficulty, String type) {
        this.name = name;
        this.description = description;
        this.durationWeeks = durationWeeks;
        this.difficulty = difficulty;
        this.type = type;
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }
    
    // Getters and Setters
    public long getId() {
        return id;
    }
    
    public void setId(long id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
        this.updatedAt = new Date();
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
        this.updatedAt = new Date();
    }
    
    public int getDurationWeeks() {
        return durationWeeks;
    }
    
    public void setDurationWeeks(int durationWeeks) {
        this.durationWeeks = durationWeeks;
        this.updatedAt = new Date();
    }
    
    public String getDifficulty() {
        return difficulty;
    }
    
    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
        this.updatedAt = new Date();
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
        this.updatedAt = new Date();
    }
    
    public String getImageUrl() {
        return imageUrl;
    }
    
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
        this.updatedAt = new Date();
    }
    
    public Date getCreatedAt() {
        return createdAt;
    }
    
    public Date getUpdatedAt() {
        return updatedAt;
    }
}
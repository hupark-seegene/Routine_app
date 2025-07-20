package com.squashtrainingapp.models;

import java.io.Serializable;

public class WorkoutRecommendation implements Serializable {
    private String title;
    private String description;
    private String type;
    private int difficulty;
    private int duration; // in minutes
    private String programId;
    private double score;
    private String imageUrl;
    private boolean isNew;
    private boolean isTrending;
    
    public WorkoutRecommendation(String title, String description, String type, 
                               int difficulty, int duration, String programId) {
        this.title = title;
        this.description = description;
        this.type = type;
        this.difficulty = difficulty;
        this.duration = duration;
        this.programId = programId;
        this.score = 0.0;
        this.isNew = false;
        this.isTrending = false;
    }
    
    // Getters and setters
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public int getDifficulty() {
        return difficulty;
    }
    
    public void setDifficulty(int difficulty) {
        this.difficulty = difficulty;
    }
    
    public int getDuration() {
        return duration;
    }
    
    public void setDuration(int duration) {
        this.duration = duration;
    }
    
    public String getProgramId() {
        return programId;
    }
    
    public void setProgramId(String programId) {
        this.programId = programId;
    }
    
    public double getScore() {
        return score;
    }
    
    public void setScore(double score) {
        this.score = score;
    }
    
    public String getImageUrl() {
        return imageUrl;
    }
    
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    
    public boolean isNew() {
        return isNew;
    }
    
    public void setNew(boolean isNew) {
        this.isNew = isNew;
    }
    
    public boolean isTrending() {
        return isTrending;
    }
    
    public void setTrending(boolean trending) {
        isTrending = trending;
    }
    
    // Helper methods
    public String getDifficultyText() {
        if (difficulty <= 3) {
            return "초급";
        } else if (difficulty <= 7) {
            return "중급";
        } else {
            return "상급";
        }
    }
    
    public String getDurationText() {
        if (duration < 60) {
            return duration + "분";
        } else {
            int hours = duration / 60;
            int mins = duration % 60;
            if (mins == 0) {
                return hours + "시간";
            } else {
                return hours + "시간 " + mins + "분";
            }
        }
    }
    
    public String getTypeIcon() {
        switch (type) {
            case "cardio":
                return "🏃";
            case "strength":
                return "💪";
            case "technique":
                return "🎯";
            case "footwork":
                return "👟";
            case "mental":
                return "🧠";
            default:
                return "🏸";
        }
    }
}
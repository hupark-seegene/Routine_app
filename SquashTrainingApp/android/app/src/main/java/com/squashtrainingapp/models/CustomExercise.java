package com.squashtrainingapp.models;

import java.io.Serializable;
import java.util.UUID;

public class CustomExercise implements Serializable {
    
    public enum Category {
        FOREHAND("포핸드"),
        BACKHAND("백핸드"),
        SERVE("서브"),
        VOLLEY("발리"),
        DROP("드롭샷"),
        BOAST("보스트"),
        FOOTWORK("풋워크"),
        FITNESS("체력"),
        CUSTOM("커스텀");
        
        private String korean;
        
        Category(String korean) {
            this.korean = korean;
        }
        
        public String getKorean() {
            return korean;
        }
    }
    
    public enum Difficulty {
        EASY("쉬움"),
        MEDIUM("중간"),
        HARD("어려움");
        
        private String korean;
        
        Difficulty(String korean) {
            this.korean = korean;
        }
        
        public String getKorean() {
            return korean;
        }
    }
    
    private String id;
    private String name;
    private String description;
    private Category category;
    private Difficulty difficulty;
    private int duration; // in minutes
    private int sets;
    private int reps;
    private String instructions;
    private String tips;
    private boolean isUserCreated;
    private long createdDate;
    private long lastUsedDate;
    private int timesUsed;
    
    public CustomExercise() {
        this.id = UUID.randomUUID().toString();
        this.isUserCreated = true;
        this.createdDate = System.currentTimeMillis();
        this.timesUsed = 0;
    }
    
    public CustomExercise(String name, String description, Category category, 
                         Difficulty difficulty, int duration) {
        this();
        this.name = name;
        this.description = description;
        this.category = category;
        this.difficulty = difficulty;
        this.duration = duration;
    }
    
    // Getters and setters
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Category getCategory() {
        return category;
    }
    
    public void setCategory(Category category) {
        this.category = category;
    }
    
    public Difficulty getDifficulty() {
        return difficulty;
    }
    
    public void setDifficulty(Difficulty difficulty) {
        this.difficulty = difficulty;
    }
    
    public int getDuration() {
        return duration;
    }
    
    public void setDuration(int duration) {
        this.duration = duration;
    }
    
    public int getSets() {
        return sets;
    }
    
    public void setSets(int sets) {
        this.sets = sets;
    }
    
    public int getReps() {
        return reps;
    }
    
    public void setReps(int reps) {
        this.reps = reps;
    }
    
    public String getInstructions() {
        return instructions;
    }
    
    public void setInstructions(String instructions) {
        this.instructions = instructions;
    }
    
    public String getTips() {
        return tips;
    }
    
    public void setTips(String tips) {
        this.tips = tips;
    }
    
    public boolean isUserCreated() {
        return isUserCreated;
    }
    
    public void setUserCreated(boolean userCreated) {
        isUserCreated = userCreated;
    }
    
    public long getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(long createdDate) {
        this.createdDate = createdDate;
    }
    
    public long getLastUsedDate() {
        return lastUsedDate;
    }
    
    public void setLastUsedDate(long lastUsedDate) {
        this.lastUsedDate = lastUsedDate;
    }
    
    public int getTimesUsed() {
        return timesUsed;
    }
    
    public void setTimesUsed(int timesUsed) {
        this.timesUsed = timesUsed;
    }
    
    public void incrementUsage() {
        this.timesUsed++;
        this.lastUsedDate = System.currentTimeMillis();
    }
    
    // Helper methods
    public String getCategoryIcon() {
        switch (category) {
            case FOREHAND:
                return "🎾";
            case BACKHAND:
                return "🏓";
            case SERVE:
                return "🚀";
            case VOLLEY:
                return "⚡";
            case DROP:
                return "💧";
            case BOAST:
                return "🔄";
            case FOOTWORK:
                return "👣";
            case FITNESS:
                return "💪";
            case CUSTOM:
                return "⭐";
            default:
                return "🎯";
        }
    }
    
    public String getDifficultyIcon() {
        switch (difficulty) {
            case EASY:
                return "🟢";
            case MEDIUM:
                return "🟡";
            case HARD:
                return "🔴";
            default:
                return "⚪";
        }
    }
    
    public String getFormattedDuration() {
        if (duration < 60) {
            return duration + "분";
        } else {
            int hours = duration / 60;
            int minutes = duration % 60;
            if (minutes == 0) {
                return hours + "시간";
            } else {
                return hours + "시간 " + minutes + "분";
            }
        }
    }
}
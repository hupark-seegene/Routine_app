package com.squashtrainingapp.models;

import java.io.Serializable;

public class VideoTutorial implements Serializable {
    
    public enum Level {
        BEGINNER("초급"),
        INTERMEDIATE("중급"),
        ADVANCED("고급"),
        ALL("모든 레벨");
        
        private String korean;
        
        Level(String korean) {
            this.korean = korean;
        }
        
        public String getKorean() {
            return korean;
        }
    }
    
    public enum Category {
        TECHNIQUE("기술"),
        FITNESS("체력"),
        TACTICS("전술"),
        MENTAL("정신력"),
        DRILLS("드릴");
        
        private String korean;
        
        Category(String korean) {
            this.korean = korean;
        }
        
        public String getKorean() {
            return korean;
        }
    }
    
    private String id;
    private String title;
    private String description;
    private String url;
    private String duration;
    private Level level;
    private Category category;
    private int viewCount;
    private boolean isFavorite;
    private boolean isCompleted;
    
    public VideoTutorial(String id, String title, String description, String url, 
                        String duration, Level level, Category category) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.url = url;
        this.duration = duration;
        this.level = level;
        this.category = category;
        this.viewCount = 0;
        this.isFavorite = false;
        this.isCompleted = false;
    }
    
    // Getters and setters
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
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
    
    public String getUrl() {
        return url;
    }
    
    public void setUrl(String url) {
        this.url = url;
    }
    
    public String getDuration() {
        return duration;
    }
    
    public void setDuration(String duration) {
        this.duration = duration;
    }
    
    public Level getLevel() {
        return level;
    }
    
    public void setLevel(Level level) {
        this.level = level;
    }
    
    public Category getCategory() {
        return category;
    }
    
    public void setCategory(Category category) {
        this.category = category;
    }
    
    public int getViewCount() {
        return viewCount;
    }
    
    public void setViewCount(int viewCount) {
        this.viewCount = viewCount;
    }
    
    public void incrementViewCount() {
        this.viewCount++;
    }
    
    public boolean isFavorite() {
        return isFavorite;
    }
    
    public void setFavorite(boolean favorite) {
        isFavorite = favorite;
    }
    
    public boolean isCompleted() {
        return isCompleted;
    }
    
    public void setCompleted(boolean completed) {
        isCompleted = completed;
    }
    
    // Helper methods
    public String getLevelIcon() {
        switch (level) {
            case BEGINNER:
                return "🌱";
            case INTERMEDIATE:
                return "🌿";
            case ADVANCED:
                return "🌳";
            default:
                return "🎯";
        }
    }
    
    public String getCategoryIcon() {
        switch (category) {
            case TECHNIQUE:
                return "🎾";
            case FITNESS:
                return "💪";
            case TACTICS:
                return "🧠";
            case MENTAL:
                return "🧘";
            case DRILLS:
                return "🔄";
            default:
                return "📹";
        }
    }
}
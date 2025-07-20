package com.squashtrainingapp.models;

import java.io.Serializable;

public class Achievement implements Serializable {
    
    public enum AchievementType {
        WORKOUT_COUNT("운동 횟수"),
        STREAK("연속 운동"),
        CALORIES("칼로리 소모"),
        TIME("운동 시간"),
        LEVEL("레벨 달성"),
        PROGRAM("프로그램 완료"),
        SKILL("기술 마스터"),
        SPECIAL("특별 업적");
        
        private String korean;
        
        AchievementType(String korean) {
            this.korean = korean;
        }
        
        public String getKorean() {
            return korean;
        }
    }
    
    public enum AchievementRank {
        BRONZE("브론즈", "#CD7F32"),
        SILVER("실버", "#C0C0C0"),
        GOLD("골드", "#FFD700"),
        PLATINUM("플래티넘", "#E5E5E5"),
        DIAMOND("다이아몬드", "#B9F2FF");
        
        private String korean;
        private String color;
        
        AchievementRank(String korean, String color) {
            this.korean = korean;
            this.color = color;
        }
        
        public String getKorean() {
            return korean;
        }
        
        public String getColor() {
            return color;
        }
    }
    
    private String id;
    private String name;
    private String description;
    private AchievementType type;
    private AchievementRank rank;
    private int targetValue;
    private int currentValue;
    private boolean isUnlocked;
    private long unlockedDate;
    private String iconEmoji;
    private int points;
    
    public Achievement(String id, String name, String description, 
                      AchievementType type, AchievementRank rank, 
                      int targetValue, String iconEmoji, int points) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.type = type;
        this.rank = rank;
        this.targetValue = targetValue;
        this.currentValue = 0;
        this.isUnlocked = false;
        this.iconEmoji = iconEmoji;
        this.points = points;
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
    
    public AchievementType getType() {
        return type;
    }
    
    public void setType(AchievementType type) {
        this.type = type;
    }
    
    public AchievementRank getRank() {
        return rank;
    }
    
    public void setRank(AchievementRank rank) {
        this.rank = rank;
    }
    
    public int getTargetValue() {
        return targetValue;
    }
    
    public void setTargetValue(int targetValue) {
        this.targetValue = targetValue;
    }
    
    public int getCurrentValue() {
        return currentValue;
    }
    
    public void setCurrentValue(int currentValue) {
        this.currentValue = currentValue;
        checkUnlock();
    }
    
    public boolean isUnlocked() {
        return isUnlocked;
    }
    
    public void setUnlocked(boolean unlocked) {
        isUnlocked = unlocked;
        if (unlocked) {
            unlockedDate = System.currentTimeMillis();
        }
    }
    
    public long getUnlockedDate() {
        return unlockedDate;
    }
    
    public void setUnlockedDate(long unlockedDate) {
        this.unlockedDate = unlockedDate;
    }
    
    public String getIconEmoji() {
        return iconEmoji;
    }
    
    public void setIconEmoji(String iconEmoji) {
        this.iconEmoji = iconEmoji;
    }
    
    public int getPoints() {
        return points;
    }
    
    public void setPoints(int points) {
        this.points = points;
    }
    
    // Helper methods
    public void incrementProgress(int amount) {
        if (!isUnlocked) {
            currentValue += amount;
            checkUnlock();
        }
    }
    
    private void checkUnlock() {
        if (!isUnlocked && currentValue >= targetValue) {
            setUnlocked(true);
        }
    }
    
    public float getProgressPercentage() {
        if (isUnlocked) {
            return 100f;
        }
        return (float) currentValue / targetValue * 100;
    }
    
    public String getProgressText() {
        if (isUnlocked) {
            return "완료!";
        }
        return currentValue + " / " + targetValue;
    }
    
    public String getRankIcon() {
        switch (rank) {
            case BRONZE:
                return "🥉";
            case SILVER:
                return "🥈";
            case GOLD:
                return "🥇";
            case PLATINUM:
                return "🏆";
            case DIAMOND:
                return "💎";
            default:
                return "🎯";
        }
    }
}
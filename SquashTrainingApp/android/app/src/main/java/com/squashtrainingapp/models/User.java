package com.squashtrainingapp.models;

public class User {
    private int id;
    private String name;
    private int level;
    private int experience;
    private int totalSessions;
    private int totalCalories;
    private float totalHours;
    private int currentStreak;

    // Constructors
    public User() {
        this.id = 1;
        this.name = "Player";
        this.level = 1;
        this.experience = 0;
        this.totalSessions = 0;
        this.totalCalories = 0;
        this.totalHours = 0;
        this.currentStreak = 0;
    }

    public User(int id, String name, int level, int experience, 
                int totalSessions, int totalCalories, float totalHours, int currentStreak) {
        this.id = id;
        this.name = name;
        this.level = level;
        this.experience = experience;
        this.totalSessions = totalSessions;
        this.totalCalories = totalCalories;
        this.totalHours = totalHours;
        this.currentStreak = currentStreak;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getLevel() { return level; }
    public void setLevel(int level) { this.level = level; }

    public int getExperience() { return experience; }
    public void setExperience(int experience) { this.experience = experience; }

    public int getTotalSessions() { return totalSessions; }
    public void setTotalSessions(int totalSessions) { this.totalSessions = totalSessions; }

    public int getTotalCalories() { return totalCalories; }
    public void setTotalCalories(int totalCalories) { this.totalCalories = totalCalories; }

    public float getTotalHours() { return totalHours; }
    public void setTotalHours(float totalHours) { this.totalHours = totalHours; }

    public int getCurrentStreak() { return currentStreak; }
    public void setCurrentStreak(int currentStreak) { this.currentStreak = currentStreak; }

    // Helper methods
    public void addSession(int duration) {
        totalSessions++;
        totalHours += duration / 60.0f;
        totalCalories += duration * 10; // Rough estimate: 10 cal/min
        experience += 50; // 50 XP per session
        
        // Check for level up
        if (experience >= 1000) {
            level++;
            experience -= 1000;
        }
    }

    public int getNextLevelXP() {
        return 1000;
    }

    public int getCurrentLevelProgress() {
        return experience;
    }

    public float getLevelProgressPercentage() {
        return (experience / 1000.0f) * 100;
    }
}
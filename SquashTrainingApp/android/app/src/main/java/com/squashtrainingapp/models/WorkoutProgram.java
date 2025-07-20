package com.squashtrainingapp.models;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class WorkoutProgram implements Serializable {
    
    public enum ProgramType {
        BEGINNER("초급자 프로그램"),
        INTERMEDIATE("중급자 프로그램"),
        ADVANCED("고급자 프로그램"),
        TECHNIQUE("기술 향상 프로그램"),
        FITNESS("체력 향상 프로그램"),
        TOURNAMENT("대회 준비 프로그램"),
        CUSTOM("커스텀 프로그램");
        
        private String korean;
        
        ProgramType(String korean) {
            this.korean = korean;
        }
        
        public String getKorean() {
            return korean;
        }
    }
    
    public enum Duration {
        WEEK_1("1주", 7),
        WEEK_2("2주", 14),
        WEEK_4("4주", 28),
        WEEK_8("8주", 56),
        WEEK_12("12주", 84),
        CUSTOM("커스텀", 0);
        
        private String korean;
        private int days;
        
        Duration(String korean, int days) {
            this.korean = korean;
            this.days = days;
        }
        
        public String getKorean() {
            return korean;
        }
        
        public int getDays() {
            return days;
        }
    }
    
    private String id;
    private String name;
    private String description;
    private ProgramType type;
    private Duration duration;
    private int daysPerWeek;
    private List<ProgramDay> programDays;
    private long startDate;
    private long endDate;
    private boolean isActive;
    private int completedDays;
    private float progressPercentage;
    private long createdDate;
    private boolean isUserCreated;
    
    public WorkoutProgram() {
        this.id = UUID.randomUUID().toString();
        this.programDays = new ArrayList<>();
        this.createdDate = System.currentTimeMillis();
        this.isActive = false;
        this.completedDays = 0;
        this.progressPercentage = 0f;
    }
    
    public WorkoutProgram(String name, String description, ProgramType type, Duration duration) {
        this();
        this.name = name;
        this.description = description;
        this.type = type;
        this.duration = duration;
    }
    
    // Program Day class
    public static class ProgramDay implements Serializable {
        private int dayNumber;
        private String dayName;
        private List<String> exerciseIds;
        private boolean isCompleted;
        private long completedDate;
        private String notes;
        
        public ProgramDay(int dayNumber, String dayName) {
            this.dayNumber = dayNumber;
            this.dayName = dayName;
            this.exerciseIds = new ArrayList<>();
            this.isCompleted = false;
        }
        
        // Getters and setters
        public int getDayNumber() {
            return dayNumber;
        }
        
        public void setDayNumber(int dayNumber) {
            this.dayNumber = dayNumber;
        }
        
        public String getDayName() {
            return dayName;
        }
        
        public void setDayName(String dayName) {
            this.dayName = dayName;
        }
        
        public List<String> getExerciseIds() {
            return exerciseIds;
        }
        
        public void setExerciseIds(List<String> exerciseIds) {
            this.exerciseIds = exerciseIds;
        }
        
        public boolean isCompleted() {
            return isCompleted;
        }
        
        public void setCompleted(boolean completed) {
            isCompleted = completed;
            if (completed) {
                completedDate = System.currentTimeMillis();
            }
        }
        
        public long getCompletedDate() {
            return completedDate;
        }
        
        public void setCompletedDate(long completedDate) {
            this.completedDate = completedDate;
        }
        
        public String getNotes() {
            return notes;
        }
        
        public void setNotes(String notes) {
            this.notes = notes;
        }
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
    
    public ProgramType getType() {
        return type;
    }
    
    public void setType(ProgramType type) {
        this.type = type;
    }
    
    public Duration getDuration() {
        return duration;
    }
    
    public void setDuration(Duration duration) {
        this.duration = duration;
    }
    
    public int getDaysPerWeek() {
        return daysPerWeek;
    }
    
    public void setDaysPerWeek(int daysPerWeek) {
        this.daysPerWeek = daysPerWeek;
    }
    
    public List<ProgramDay> getProgramDays() {
        return programDays;
    }
    
    public void setProgramDays(List<ProgramDay> programDays) {
        this.programDays = programDays;
    }
    
    public long getStartDate() {
        return startDate;
    }
    
    public void setStartDate(long startDate) {
        this.startDate = startDate;
        if (duration != Duration.CUSTOM) {
            this.endDate = startDate + (duration.getDays() * 24 * 60 * 60 * 1000L);
        }
    }
    
    public long getEndDate() {
        return endDate;
    }
    
    public void setEndDate(long endDate) {
        this.endDate = endDate;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    public int getCompletedDays() {
        return completedDays;
    }
    
    public void setCompletedDays(int completedDays) {
        this.completedDays = completedDays;
        updateProgress();
    }
    
    public float getProgressPercentage() {
        return progressPercentage;
    }
    
    public void setProgressPercentage(float progressPercentage) {
        this.progressPercentage = progressPercentage;
    }
    
    public long getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(long createdDate) {
        this.createdDate = createdDate;
    }
    
    public boolean isUserCreated() {
        return isUserCreated;
    }
    
    public void setUserCreated(boolean userCreated) {
        isUserCreated = userCreated;
    }
    
    // Helper methods
    public void addProgramDay(ProgramDay day) {
        programDays.add(day);
    }
    
    public void markDayCompleted(int dayNumber) {
        for (ProgramDay day : programDays) {
            if (day.getDayNumber() == dayNumber) {
                day.setCompleted(true);
                completedDays++;
                updateProgress();
                break;
            }
        }
    }
    
    private void updateProgress() {
        if (programDays.isEmpty()) {
            progressPercentage = 0f;
        } else {
            progressPercentage = (float) completedDays / programDays.size() * 100;
        }
    }
    
    public ProgramDay getCurrentDay() {
        for (ProgramDay day : programDays) {
            if (!day.isCompleted()) {
                return day;
            }
        }
        return null; // All days completed
    }
    
    public int getRemainingDays() {
        return programDays.size() - completedDays;
    }
    
    public String getTypeIcon() {
        switch (type) {
            case BEGINNER:
                return "🌱";
            case INTERMEDIATE:
                return "🌿";
            case ADVANCED:
                return "🌳";
            case TECHNIQUE:
                return "🎯";
            case FITNESS:
                return "💪";
            case TOURNAMENT:
                return "🏆";
            case CUSTOM:
                return "⭐";
            default:
                return "🎾";
        }
    }
    
    public boolean isCompleted() {
        return completedDays >= programDays.size();
    }
}
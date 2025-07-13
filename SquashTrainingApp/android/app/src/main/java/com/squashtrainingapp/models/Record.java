package com.squashtrainingapp.models;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class Record {
    private int id;
    private String exerciseName;
    private int sets;
    private int reps;
    private int duration;
    private int intensity;
    private int condition;
    private int fatigue;
    private String memo;
    private String date;

    // Constructors
    public Record() {
        this.date = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date());
    }

    public Record(String exerciseName, int sets, int reps, int duration,
                  int intensity, int condition, int fatigue, String memo) {
        this();
        this.exerciseName = exerciseName;
        this.sets = sets;
        this.reps = reps;
        this.duration = duration;
        this.intensity = intensity;
        this.condition = condition;
        this.fatigue = fatigue;
        this.memo = memo;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getExerciseName() { return exerciseName; }
    public void setExerciseName(String exerciseName) { this.exerciseName = exerciseName; }

    public int getSets() { return sets; }
    public void setSets(int sets) { this.sets = sets; }

    public int getReps() { return reps; }
    public void setReps(int reps) { this.reps = reps; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public int getIntensity() { return intensity; }
    public void setIntensity(int intensity) { this.intensity = intensity; }

    public int getCondition() { return condition; }
    public void setCondition(int condition) { this.condition = condition; }

    public int getFatigue() { return fatigue; }
    public void setFatigue(int fatigue) { this.fatigue = fatigue; }

    public String getMemo() { return memo; }
    public void setMemo(String memo) { this.memo = memo; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    // Helper methods
    public String getFormattedDate() {
        try {
            if (date != null && date.length() >= 19) {
                return date.substring(0, 19);
            }
        } catch (Exception e) {
            // Return original date if formatting fails
        }
        return date;
    }

    public String getStatsString() {
        StringBuilder stats = new StringBuilder();
        if (sets > 0) stats.append("Sets: ").append(sets).append(" ");
        if (reps > 0) stats.append("Reps: ").append(reps).append(" ");
        if (duration > 0) stats.append("Duration: ").append(duration).append("min");
        return stats.toString();
    }

    public String getRatingsString() {
        return String.format("Intensity: %d/10 | Condition: %d/10 | Fatigue: %d/10",
                             intensity, condition, fatigue);
    }

    public int getEstimatedCalories() {
        return duration * 10; // Rough estimate: 10 cal/min
    }
}
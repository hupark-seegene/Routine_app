package com.squashtrainingapp;

public class Exercise {
    private String name;
    private String category;
    private int sets;
    private int reps;
    private int duration; // in minutes
    private boolean completed;
    
    public Exercise(String name, String category, int sets, int reps, int duration) {
        this.name = name;
        this.category = category;
        this.sets = sets;
        this.reps = reps;
        this.duration = duration;
        this.completed = false;
    }
    
    // Getters and setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public int getSets() { return sets; }
    public void setSets(int sets) { this.sets = sets; }
    
    public int getReps() { return reps; }
    public void setReps(int reps) { this.reps = reps; }
    
    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }
    
    public boolean isCompleted() { return completed; }
    public void setCompleted(boolean completed) { this.completed = completed; }
    
    public String getDisplayText() {
        if (duration > 0) {
            return duration + " minutes";
        } else if (sets > 0 && reps > 0) {
            return sets + " x " + reps;
        }
        return "";
    }
}

package com.squashtrainingapp.models;

public class Exercise {
    private int id;
    private String name;
    private String category;
    private String description;
    private boolean isChecked;

    // Constructors
    public Exercise() {
        this.isChecked = false;
    }

    public Exercise(String name, String category, String description) {
        this.name = name;
        this.category = category;
        this.description = description;
        this.isChecked = false;
    }

    public Exercise(int id, String name, String category, String description, boolean isChecked) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.description = description;
        this.isChecked = isChecked;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isChecked() { return isChecked; }
    public void setChecked(boolean checked) { isChecked = checked; }

    // Helper methods
    public void toggleChecked() {
        isChecked = !isChecked;
    }

    public String getCategoryIcon() {
        switch (category) {
            case "Movement":
                return "🏃";
            case "Technique":
                return "🎯";
            case "Match Play":
                return "🏆";
            default:
                return "📌";
        }
    }
}
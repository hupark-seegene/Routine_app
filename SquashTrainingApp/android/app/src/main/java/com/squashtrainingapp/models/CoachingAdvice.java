package com.squashtrainingapp.models;

import java.io.Serializable;
import java.util.Date;

public class CoachingAdvice implements Serializable {
    private String id;
    private String type;
    private String title;
    private String message;
    private String actionable;
    private int priority;
    private Date createdAt;
    private boolean isRead;
    private boolean isDismissed;
    private String category;
    private String iconUrl;
    
    public CoachingAdvice() {
        this.id = generateId();
        this.createdAt = new Date();
        this.isRead = false;
        this.isDismissed = false;
    }
    
    private String generateId() {
        return "advice_" + System.currentTimeMillis();
    }
    
    // Getters and setters
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public String getActionable() {
        return actionable;
    }
    
    public void setActionable(String actionable) {
        this.actionable = actionable;
    }
    
    public int getPriority() {
        return priority;
    }
    
    public void setPriority(int priority) {
        this.priority = priority;
    }
    
    public Date getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
    
    public boolean isRead() {
        return isRead;
    }
    
    public void setRead(boolean read) {
        isRead = read;
    }
    
    public boolean isDismissed() {
        return isDismissed;
    }
    
    public void setDismissed(boolean dismissed) {
        isDismissed = dismissed;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public String getIconUrl() {
        return iconUrl;
    }
    
    public void setIconUrl(String iconUrl) {
        this.iconUrl = iconUrl;
    }
    
    // Helper methods
    public String getTypeIcon() {
        switch (type) {
            case "motivational":
                return "🔥";
            case "technical":
                return "📚";
            case "strategic":
                return "🎯";
            case "recovery":
                return "🌙";
            case "goal":
                return "🏆";
            default:
                return "💡";
        }
    }
    
    public String getTypeColor() {
        switch (type) {
            case "motivational":
                return "#FF6B6B";
            case "technical":
                return "#4ECDC4";
            case "strategic":
                return "#45B7D1";
            case "recovery":
                return "#96CEB4";
            case "goal":
                return "#F7DC6F";
            default:
                return "#95A5A6";
        }
    }
    
    public boolean isHighPriority() {
        return priority <= 3;
    }
    
    public boolean isActionable() {
        return actionable != null && !actionable.isEmpty();
    }
}
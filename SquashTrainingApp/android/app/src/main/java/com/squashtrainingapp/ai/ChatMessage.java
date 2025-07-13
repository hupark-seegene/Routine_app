package com.squashtrainingapp.ai;

public class ChatMessage {
    public enum MessageType {
        USER,
        AI,
        SYSTEM
    }
    
    private String message;
    private MessageType type;
    private long timestamp;
    
    public ChatMessage(String message, MessageType type) {
        this.message = message;
        this.type = type;
        this.timestamp = System.currentTimeMillis();
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public MessageType getType() {
        return type;
    }
    
    public void setType(MessageType type) {
        this.type = type;
    }
    
    public long getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }
}
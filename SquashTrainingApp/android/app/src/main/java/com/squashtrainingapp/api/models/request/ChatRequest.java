package com.squashtrainingapp.api.models.request;

import java.util.ArrayList;
import java.util.List;

public class ChatRequest {
    private String model;
    private List<Message> messages;
    private int max_tokens;
    private double temperature;
    
    public static class Message {
        private String role;
        private String content;
        
        public Message(String role, String content) {
            this.role = role;
            this.content = content;
        }
        
        public String getRole() { return role; }
        public String getContent() { return content; }
    }
    
    private ChatRequest() {
        this.messages = new ArrayList<>();
    }
    
    public static class Builder {
        private String model = "gpt-3.5-turbo";
        private List<Message> messages = new ArrayList<>();
        private int maxTokens = 1000;
        private double temperature = 0.7;
        
        public Builder model(String model) {
            this.model = model;
            return this;
        }
        
        public Builder addMessage(String role, String content) {
            this.messages.add(new Message(role, content));
            return this;
        }
        
        public Builder messages(List<Message> messages) {
            this.messages = messages;
            return this;
        }
        
        public Builder maxTokens(int maxTokens) {
            this.maxTokens = maxTokens;
            return this;
        }
        
        public Builder temperature(double temperature) {
            this.temperature = temperature;
            return this;
        }
        
        public ChatRequest build() {
            ChatRequest request = new ChatRequest();
            request.model = this.model;
            request.messages = this.messages;
            request.max_tokens = this.maxTokens;
            request.temperature = this.temperature;
            return request;
        }
    }
    
    // Getters
    public String getModel() { return model; }
    public List<Message> getMessages() { return messages; }
    public int getMaxTokens() { return max_tokens; }
    public double getTemperature() { return temperature; }
}
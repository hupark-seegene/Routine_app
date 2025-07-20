package com.squashtrainingapp.api.models.response;

import java.util.List;

public class ChatResponse {
    private String id;
    private String object;
    private long created;
    private String model;
    private List<Choice> choices;
    private Usage usage;
    
    public static class Choice {
        private int index;
        private Message message;
        private String finish_reason;
        
        public int getIndex() { return index; }
        public Message getMessage() { return message; }
        public String getFinishReason() { return finish_reason; }
    }
    
    public static class Message {
        private String role;
        private String content;
        
        public String getRole() { return role; }
        public String getContent() { return content; }
    }
    
    public static class Usage {
        private int prompt_tokens;
        private int completion_tokens;
        private int total_tokens;
        
        public int getPromptTokens() { return prompt_tokens; }
        public int getCompletionTokens() { return completion_tokens; }
        public int getTotalTokens() { return total_tokens; }
    }
    
    // Getters
    public String getId() { return id; }
    public String getObject() { return object; }
    public long getCreated() { return created; }
    public String getModel() { return model; }
    public List<Choice> getChoices() { return choices; }
    public Usage getUsage() { return usage; }
    
    // Helper method to get the first response
    public String getFirstResponseContent() {
        if (choices != null && !choices.isEmpty() && choices.get(0).getMessage() != null) {
            return choices.get(0).getMessage().getContent();
        }
        return "";
    }
}
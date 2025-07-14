package com.squashtrainingapp.ai;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class OpenAIClient {
    private static final String TAG = "OpenAIClient";
    private static final String API_URL = "https://api.openai.com/v1/chat/completions";
    private static final String MODEL = "gpt-4-turbo-preview";
    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");
    
    private final Context context;
    private final OkHttpClient client;
    private final Gson gson;
    private String apiKey;
    private List<Message> conversationHistory;
    
    public interface OpenAICallback {
        void onSuccess(String response);
        void onError(String error);
    }
    
    private static class Message {
        String role;
        String content;
        
        Message(String role, String content) {
            this.role = role;
            this.content = content;
        }
    }
    
    public OpenAIClient(Context context) {
        this.context = context;
        this.gson = new Gson();
        this.conversationHistory = new ArrayList<>();
        
        // Initialize with system message
        conversationHistory.add(new Message("system", 
            "You are an expert squash coach AI assistant. You provide personalized training advice, " +
            "technique tips, and motivation. You're encouraging, knowledgeable, and adapt your " +
            "responses to the user's skill level. Keep responses concise but helpful. " +
            "IMPORTANT: Always respond in the same language as the user's message. " +
            "If the user writes in Korean, respond in Korean. If in English, respond in English."
        ));
        
        this.client = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .build();
        
        // Load API key from SharedPreferences
        SharedPreferences prefs = context.getSharedPreferences("ai_settings", Context.MODE_PRIVATE);
        this.apiKey = prefs.getString("openai_api_key", null);
    }
    
    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
        // Save to SharedPreferences
        SharedPreferences prefs = context.getSharedPreferences("ai_settings", Context.MODE_PRIVATE);
        prefs.edit().putString("openai_api_key", apiKey).apply();
    }
    
    public boolean hasApiKey() {
        return apiKey != null && !apiKey.isEmpty();
    }
    
    public void sendMessage(String userMessage, OpenAICallback callback) {
        if (!hasApiKey()) {
            callback.onError("OpenAI API key not configured. Please set it in settings.");
            return;
        }
        
        // Add user message to history
        conversationHistory.add(new Message("user", userMessage));
        
        // Keep only last 10 messages to manage context size
        if (conversationHistory.size() > 11) {
            conversationHistory = new ArrayList<>(conversationHistory.subList(
                conversationHistory.size() - 11, conversationHistory.size()
            ));
            // Always keep system message at start
            if (!conversationHistory.get(0).role.equals("system")) {
                conversationHistory.add(0, new Message("system", 
                    "You are an expert squash coach AI assistant."
                ));
            }
        }
        
        // Build request
        JsonObject requestJson = new JsonObject();
        requestJson.addProperty("model", MODEL);
        requestJson.addProperty("temperature", 0.7);
        requestJson.addProperty("max_tokens", 500);
        
        JsonArray messages = new JsonArray();
        for (Message msg : conversationHistory) {
            JsonObject msgObj = new JsonObject();
            msgObj.addProperty("role", msg.role);
            msgObj.addProperty("content", msg.content);
            messages.add(msgObj);
        }
        requestJson.add("messages", messages);
        
        RequestBody body = RequestBody.create(requestJson.toString(), JSON);
        Request request = new Request.Builder()
            .url(API_URL)
            .header("Authorization", "Bearer " + apiKey)
            .header("Content-Type", "application/json")
            .post(body)
            .build();
        
        // Execute async
        new Thread(() -> {
            try {
                Response response = client.newCall(request).execute();
                String responseBody = response.body().string();
                
                if (response.isSuccessful()) {
                    JsonObject jsonResponse = gson.fromJson(responseBody, JsonObject.class);
                    String aiResponse = jsonResponse.getAsJsonArray("choices")
                        .get(0).getAsJsonObject()
                        .getAsJsonObject("message")
                        .get("content").getAsString();
                    
                    // Add AI response to history
                    conversationHistory.add(new Message("assistant", aiResponse));
                    
                    callback.onSuccess(aiResponse);
                } else {
                    Log.e(TAG, "OpenAI API error: " + responseBody);
                    callback.onError("API error: " + response.code());
                }
            } catch (IOException e) {
                Log.e(TAG, "Network error", e);
                callback.onError("Network error: " + e.getMessage());
            } catch (Exception e) {
                Log.e(TAG, "Unexpected error", e);
                callback.onError("Unexpected error: " + e.getMessage());
            }
        }).start();
    }
    
    public void clearHistory() {
        conversationHistory.clear();
        // Re-add system message
        conversationHistory.add(new Message("system", 
            "You are an expert squash coach AI assistant. You provide personalized training advice, " +
            "technique tips, and motivation. You're encouraging, knowledgeable, and adapt your " +
            "responses to the user's skill level. Keep responses concise but helpful. " +
            "IMPORTANT: Always respond in the same language as the user's message. " +
            "If the user writes in Korean, respond in Korean. If in English, respond in English."
        ));
    }
}
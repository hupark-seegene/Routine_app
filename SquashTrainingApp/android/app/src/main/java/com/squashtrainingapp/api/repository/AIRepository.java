package com.squashtrainingapp.api.repository;

import android.content.Context;
import android.util.Log;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import com.squashtrainingapp.api.config.ApiKeyManager;
import com.squashtrainingapp.api.config.NetworkConfig;
import com.squashtrainingapp.api.services.OpenAIService;
import com.squashtrainingapp.api.models.request.ChatRequest;
import com.squashtrainingapp.api.models.response.ChatResponse;
import java.util.ArrayList;
import java.util.List;

public class AIRepository {
    private static final String TAG = "AIRepository";
    private static AIRepository instance;
    
    private OpenAIService openAIService;
    private ApiKeyManager apiKeyManager;
    private List<ChatRequest.Message> conversationHistory;
    
    private MutableLiveData<String> chatResponse = new MutableLiveData<>();
    private MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private MutableLiveData<String> error = new MutableLiveData<>();
    
    private AIRepository(Context context) {
        apiKeyManager = ApiKeyManager.getInstance(context);
        conversationHistory = new ArrayList<>();
        initializeService();
    }
    
    public static synchronized AIRepository getInstance(Context context) {
        if (instance == null) {
            instance = new AIRepository(context.getApplicationContext());
        }
        return instance;
    }
    
    private void initializeService() {
        String apiKey = apiKeyManager.getOpenAIKey();
        if (!apiKey.isEmpty()) {
            openAIService = NetworkConfig.getOpenAIClient(apiKey)
                .create(OpenAIService.class);
        }
    }
    
    public void updateApiKey(String newApiKey) {
        apiKeyManager.saveOpenAIKey(newApiKey);
        NetworkConfig.resetClient();
        initializeService();
    }
    
    public void sendChatMessage(String userMessage) {
        if (openAIService == null) {
            error.setValue("API key not configured. Please set up your OpenAI API key in settings.");
            return;
        }
        
        isLoading.setValue(true);
        error.setValue(null);
        
        // Add user message to history
        conversationHistory.add(new ChatRequest.Message("user", userMessage));
        
        // Build request with system prompt
        ChatRequest request = new ChatRequest.Builder()
            .addMessage("system", "You are a professional squash coach with 20 years of experience. " +
                "Provide helpful, specific advice for improving squash skills, fitness, and strategy. " +
                "Keep responses concise but informative.")
            .messages(new ArrayList<>(conversationHistory))
            .maxTokens(500)
            .temperature(0.7)
            .build();
            
        openAIService.createChatCompletion(request).enqueue(new Callback<ChatResponse>() {
            @Override
            public void onResponse(Call<ChatResponse> call, Response<ChatResponse> response) {
                isLoading.setValue(false);
                
                if (response.isSuccessful() && response.body() != null) {
                    String reply = response.body().getFirstResponseContent();
                    if (!reply.isEmpty()) {
                        // Add AI response to history
                        conversationHistory.add(new ChatRequest.Message("assistant", reply));
                        chatResponse.setValue(reply);
                        
                        // Keep conversation history manageable (last 10 messages)
                        if (conversationHistory.size() > 10) {
                            conversationHistory = conversationHistory.subList(
                                conversationHistory.size() - 10, conversationHistory.size()
                            );
                        }
                    } else {
                        error.setValue("Empty response from AI");
                    }
                } else {
                    handleErrorResponse(response);
                }
            }
            
            @Override
            public void onFailure(Call<ChatResponse> call, Throwable t) {
                isLoading.setValue(false);
                Log.e(TAG, "API call failed", t);
                error.setValue("Network error: " + t.getMessage());
            }
        });
    }
    
    private void handleErrorResponse(Response<ChatResponse> response) {
        String errorMsg;
        switch (response.code()) {
            case 401:
                errorMsg = "Invalid API key. Please check your OpenAI API key.";
                break;
            case 429:
                errorMsg = "Rate limit exceeded. Please try again later.";
                break;
            case 500:
            case 503:
                errorMsg = "OpenAI service is temporarily unavailable.";
                break;
            default:
                errorMsg = "Error: " + response.code() + " " + response.message();
        }
        error.setValue(errorMsg);
    }
    
    public void clearConversation() {
        conversationHistory.clear();
    }
    
    // LiveData getters
    public LiveData<String> getChatResponse() { return chatResponse; }
    public LiveData<Boolean> getIsLoading() { return isLoading; }
    public LiveData<String> getError() { return error; }
    public boolean hasApiKey() { return apiKeyManager.hasValidOpenAIKey(); }
}
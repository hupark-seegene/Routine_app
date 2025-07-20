package com.squashtrainingapp.ai;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import com.squashtrainingapp.api.repository.AIRepository;

public class APIAIResponseEngine extends AIResponseEngine {
    private AIRepository aiRepository;
    private Handler mainHandler;
    
    public APIAIResponseEngine(Context context) {
        super(context);
        aiRepository = AIRepository.getInstance(context);
        mainHandler = new Handler(Looper.getMainLooper());
        observeRepository();
    }
    
    private void observeRepository() {
        // Since we're not in an Activity/Fragment, we'll use a different approach
        // We'll check the LiveData values periodically or use callbacks
    }
    
    @Override
    public void getResponse(String userInput) {
        if (!aiRepository.hasApiKey()) {
            // Fallback to local responses
            super.getResponse(userInput);
            return;
        }
        
        // Send to OpenAI API
        aiRepository.sendChatMessage(userInput);
        
        // Set up a handler to check for response
        mainHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                // Check if we have a response
                if (aiRepository.getChatResponse().getValue() != null) {
                    String response = aiRepository.getChatResponse().getValue();
                    if (listener != null) {
                        listener.onResponse(response);
                    }
                } else if (aiRepository.getError().getValue() != null) {
                    // Handle error
                    if (listener != null) {
                        // Fallback to local response
                        APIAIResponseEngine.super.getResponse(userInput);
                    }
                } else if (Boolean.TRUE.equals(aiRepository.getIsLoading().getValue())) {
                    // Still loading, check again
                    mainHandler.postDelayed(this, 500);
                }
            }
        }, 500);
    }
    
    @Override
    public boolean isApiAvailable() {
        return aiRepository.hasApiKey();
    }
}
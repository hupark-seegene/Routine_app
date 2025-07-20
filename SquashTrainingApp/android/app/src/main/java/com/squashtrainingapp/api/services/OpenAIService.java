package com.squashtrainingapp.api.services;

import retrofit2.Call;
import retrofit2.http.*;
import com.squashtrainingapp.api.models.request.ChatRequest;
import com.squashtrainingapp.api.models.response.ChatResponse;

public interface OpenAIService {
    @POST("chat/completions")
    Call<ChatResponse> createChatCompletion(@Body ChatRequest request);
}
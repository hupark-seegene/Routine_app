package com.squashtrainingapp.api.interceptors;

import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;
import java.io.IOException;

public class AuthInterceptor implements Interceptor {
    private String apiKey;
    
    public AuthInterceptor(String apiKey) {
        this.apiKey = apiKey;
    }
    
    @Override
    public Response intercept(Chain chain) throws IOException {
        Request original = chain.request();
        
        Request.Builder requestBuilder = original.newBuilder()
            .header("Content-Type", "application/json");
            
        // Add authorization header if API key is provided
        if (apiKey != null && !apiKey.isEmpty()) {
            requestBuilder.header("Authorization", "Bearer " + apiKey);
        }
        
        Request request = requestBuilder.build();
        return chain.proceed(request);
    }
    
    public void updateApiKey(String newApiKey) {
        this.apiKey = newApiKey;
    }
}
package com.squashtrainingapp.api.config;

import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.squashtrainingapp.api.interceptors.AuthInterceptor;
import java.util.concurrent.TimeUnit;

public class NetworkConfig {
    private static Retrofit retrofitOpenAI;
    private static AuthInterceptor authInterceptor;
    
    public static Retrofit getOpenAIClient(String apiKey) {
        if (retrofitOpenAI == null || authInterceptor == null) {
            // Create logging interceptor
            HttpLoggingInterceptor loggingInterceptor = new HttpLoggingInterceptor();
            loggingInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
            
            // Create auth interceptor
            authInterceptor = new AuthInterceptor(apiKey);
            
            // Build OkHttpClient
            OkHttpClient client = new OkHttpClient.Builder()
                .connectTimeout(ApiConfig.CONNECT_TIMEOUT, TimeUnit.SECONDS)
                .readTimeout(ApiConfig.READ_TIMEOUT, TimeUnit.SECONDS)
                .writeTimeout(ApiConfig.WRITE_TIMEOUT, TimeUnit.SECONDS)
                .addInterceptor(authInterceptor)
                .addInterceptor(loggingInterceptor)
                .build();
                
            // Configure Gson
            Gson gson = new GsonBuilder()
                .setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                .create();
                
            // Build Retrofit
            retrofitOpenAI = new Retrofit.Builder()
                .baseUrl(ApiConfig.OPENAI_BASE_URL)
                .client(client)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .build();
        } else {
            // Update API key if needed
            authInterceptor.updateApiKey(apiKey);
        }
        
        return retrofitOpenAI;
    }
    
    public static void resetClient() {
        retrofitOpenAI = null;
        authInterceptor = null;
    }
}
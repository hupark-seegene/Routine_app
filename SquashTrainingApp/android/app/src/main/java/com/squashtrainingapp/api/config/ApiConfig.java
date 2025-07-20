package com.squashtrainingapp.api.config;

public class ApiConfig {
    // Base URLs
    public static final String OPENAI_BASE_URL = "https://api.openai.com/v1/";
    public static final String GOOGLE_SPEECH_BASE_URL = "https://speech.googleapis.com/v1/";
    public static final String YOUTUBE_BASE_URL = "https://www.googleapis.com/youtube/v3/";
    
    // Timeouts (in seconds)
    public static final int CONNECT_TIMEOUT = 30;
    public static final int READ_TIMEOUT = 30;
    public static final int WRITE_TIMEOUT = 30;
    
    // API Versions
    public static final String API_VERSION = "v1";
    
    // OpenAI Models
    public static final String GPT_MODEL = "gpt-3.5-turbo";
    public static final int MAX_TOKENS = 1000;
    public static final double TEMPERATURE = 0.7;
    
    // Response codes
    public static final int SUCCESS = 200;
    public static final int UNAUTHORIZED = 401;
    public static final int RATE_LIMIT = 429;
    public static final int SERVER_ERROR = 500;
}
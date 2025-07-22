package com.squashtrainingapp.ai;

import android.content.Context;
import android.util.Log;

import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.User;
import com.squashtrainingapp.models.WorkoutSession;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class GPT4CoachingService {
    private static final String TAG = "GPT4CoachingService";
    private static final String API_URL = "https://api.openai.com/v1/chat/completions";
    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");
    
    private Context context;
    private OkHttpClient client;
    private String apiKey;
    private DatabaseHelper databaseHelper;
    
    // Coaching modes
    public enum CoachingMode {
        FORM_ANALYSIS,
        TACTICAL_ADVICE,
        FITNESS_PLANNING,
        MENTAL_COACHING,
        INJURY_PREVENTION,
        NUTRITION_GUIDANCE,
        MATCH_PREPARATION
    }
    
    public interface GPT4Callback {
        void onSuccess(String response);
        void onError(String error);
    }
    
    public GPT4CoachingService(Context context) {
        this.context = context;
        this.databaseHelper = DatabaseHelper.getInstance(context);
        
        // Initialize OkHttp client with timeout settings
        this.client = new OkHttpClient.Builder()
                .connectTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .build();
        
        // Get API key from shared preferences
        this.apiKey = context.getSharedPreferences("app_settings", Context.MODE_PRIVATE)
                .getString("openai_api_key", "");
    }
    
    // Analyze user's playing form based on session data
    public void analyzeForm(WorkoutSession session, GPT4Callback callback) {
        String prompt = buildFormAnalysisPrompt(session);
        sendGPT4Request(prompt, CoachingMode.FORM_ANALYSIS, callback);
    }
    
    // Get tactical advice based on user's skill level and goals
    public void getTacticalAdvice(String userQuery, GPT4Callback callback) {
        User user = databaseHelper.getUserDao().getUser();
        String prompt = buildTacticalPrompt(user, userQuery);
        sendGPT4Request(prompt, CoachingMode.TACTICAL_ADVICE, callback);
    }
    
    // Create personalized fitness plan
    public void createFitnessPlan(int weeklyFrequency, String primaryGoal, GPT4Callback callback) {
        User user = databaseHelper.getUserDao().getUser();
        String prompt = buildFitnessPlanPrompt(user, weeklyFrequency, primaryGoal);
        sendGPT4Request(prompt, CoachingMode.FITNESS_PLANNING, callback);
    }
    
    // Get mental coaching advice
    public void getMentalCoaching(String situation, GPT4Callback callback) {
        String prompt = buildMentalCoachingPrompt(situation);
        sendGPT4Request(prompt, CoachingMode.MENTAL_COACHING, callback);
    }
    
    // Injury prevention recommendations
    public void getInjuryPrevention(String bodyPart, GPT4Callback callback) {
        String prompt = buildInjuryPreventionPrompt(bodyPart);
        sendGPT4Request(prompt, CoachingMode.INJURY_PREVENTION, callback);
    }
    
    // Nutrition guidance for squash players
    public void getNutritionGuidance(String mealTime, GPT4Callback callback) {
        String prompt = buildNutritionPrompt(mealTime);
        sendGPT4Request(prompt, CoachingMode.NUTRITION_GUIDANCE, callback);
    }
    
    // Match preparation advice
    public void getMatchPreparation(int hoursBeforeMatch, GPT4Callback callback) {
        String prompt = buildMatchPrepPrompt(hoursBeforeMatch);
        sendGPT4Request(prompt, CoachingMode.MATCH_PREPARATION, callback);
    }
    
    // Conversational coaching
    public void chatWithCoach(String userMessage, List<String> conversationHistory, GPT4Callback callback) {
        String prompt = buildConversationalPrompt(userMessage, conversationHistory);
        sendGPT4Request(prompt, CoachingMode.TACTICAL_ADVICE, callback);
    }
    
    private void sendGPT4Request(String prompt, CoachingMode mode, GPT4Callback callback) {
        if (apiKey.isEmpty()) {
            callback.onError("OpenAI API key not configured. Please set it in settings.");
            return;
        }
        
        try {
            JSONObject requestBody = new JSONObject();
            requestBody.put("model", "gpt-4-turbo-preview");
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 1000);
            
            JSONArray messages = new JSONArray();
            
            // System message to set coaching context
            JSONObject systemMessage = new JSONObject();
            systemMessage.put("role", "system");
            systemMessage.put("content", getSystemPrompt(mode));
            messages.put(systemMessage);
            
            // User message with the actual prompt
            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");
            userMessage.put("content", prompt);
            messages.put(userMessage);
            
            requestBody.put("messages", messages);
            
            Request request = new Request.Builder()
                    .url(API_URL)
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json")
                    .post(RequestBody.create(requestBody.toString(), JSON))
                    .build();
            
            client.newCall(request).enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    Log.e(TAG, "GPT-4 request failed", e);
                    callback.onError("Network error: " + e.getMessage());
                }
                
                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    try {
                        if (!response.isSuccessful()) {
                            callback.onError("API error: " + response.code());
                            return;
                        }
                        
                        String responseBody = response.body().string();
                        JSONObject jsonResponse = new JSONObject(responseBody);
                        JSONArray choices = jsonResponse.getJSONArray("choices");
                        
                        if (choices.length() > 0) {
                            JSONObject choice = choices.getJSONObject(0);
                            JSONObject message = choice.getJSONObject("message");
                            String content = message.getString("content");
                            callback.onSuccess(content);
                        } else {
                            callback.onError("No response from GPT-4");
                        }
                    } catch (JSONException e) {
                        Log.e(TAG, "Failed to parse GPT-4 response", e);
                        callback.onError("Failed to parse response");
                    }
                }
            });
            
        } catch (JSONException e) {
            Log.e(TAG, "Failed to create request", e);
            callback.onError("Failed to create request");
        }
    }
    
    private String getSystemPrompt(CoachingMode mode) {
        switch (mode) {
            case FORM_ANALYSIS:
                return "You are an expert squash coach specializing in biomechanics and form analysis. " +
                       "Provide detailed, actionable advice to improve the player's technique. " +
                       "Be specific about body positioning, racket preparation, and movement patterns.";
                       
            case TACTICAL_ADVICE:
                return "You are a world-class squash tactician with 20+ years of coaching experience. " +
                       "Provide strategic insights, shot selection advice, and game plans. " +
                       "Consider the player's skill level and adapt your advice accordingly.";
                       
            case FITNESS_PLANNING:
                return "You are a sports fitness specialist for squash players. " +
                       "Create detailed, progressive training plans that improve squash-specific fitness. " +
                       "Include exercises for agility, speed, endurance, and power.";
                       
            case MENTAL_COACHING:
                return "You are a sports psychologist specializing in racket sports. " +
                       "Provide mental strategies for focus, confidence, and handling pressure. " +
                       "Use proven psychological techniques adapted for squash players.";
                       
            case INJURY_PREVENTION:
                return "You are a sports physiotherapist with expertise in squash injuries. " +
                       "Provide preventive exercises, stretches, and recovery protocols. " +
                       "Focus on common squash injuries and biomechanical corrections.";
                       
            case NUTRITION_GUIDANCE:
                return "You are a sports nutritionist for elite squash players. " +
                       "Provide practical nutrition advice for performance and recovery. " +
                       "Consider timing, hydration, and energy requirements for squash.";
                       
            case MATCH_PREPARATION:
                return "You are a professional squash coach preparing players for competition. " +
                       "Provide detailed pre-match routines, warm-ups, and mental preparation. " +
                       "Consider all aspects: physical, tactical, and psychological.";
                       
            default:
                return "You are an expert squash coach providing personalized advice.";
        }
    }
    
    private String buildFormAnalysisPrompt(WorkoutSession session) {
        return String.format(
            "Analyze this squash training session and provide form improvement tips:\n" +
            "Duration: %d minutes\n" +
            "Intensity: %s\n" +
            "Focus areas: %s\n" +
            "Player notes: %s\n\n" +
            "Provide 3-5 specific technique improvements with explanations.",
            session.getDuration() / 60,
            session.getIntensity(),
            session.getExerciseTypes(),
            session.getNotes()
        );
    }
    
    private String buildTacticalPrompt(User user, String query) {
        return String.format(
            "Player profile:\n" +
            "Level: %s\n" +
            "Experience: %d sessions\n" +
            "Current streak: %d days\n\n" +
            "Question: %s\n\n" +
            "Provide tactical advice suited to this player's level.",
            user.getLevel(),
            user.getTotalSessions(),
            user.getCurrentStreak(),
            query
        );
    }
    
    private String buildFitnessPlanPrompt(User user, int weeklyFrequency, String goal) {
        return String.format(
            "Create a 4-week squash fitness plan:\n" +
            "Player level: %s\n" +
            "Weekly training frequency: %d days\n" +
            "Primary goal: %s\n\n" +
            "Include:\n" +
            "1. Weekly schedule\n" +
            "2. Specific exercises with sets/reps\n" +
            "3. Progression guidelines\n" +
            "4. Recovery recommendations",
            user.getLevel(),
            weeklyFrequency,
            goal
        );
    }
    
    private String buildMentalCoachingPrompt(String situation) {
        return String.format(
            "Provide mental coaching for this squash situation:\n%s\n\n" +
            "Include:\n" +
            "1. Psychological analysis\n" +
            "2. Practical mental strategies\n" +
            "3. Visualization exercises\n" +
            "4. Pre-match routines",
            situation
        );
    }
    
    private String buildInjuryPreventionPrompt(String bodyPart) {
        return String.format(
            "Provide injury prevention advice for squash players experiencing %s issues.\n\n" +
            "Include:\n" +
            "1. Common causes in squash\n" +
            "2. Preventive exercises (3-5)\n" +
            "3. Proper warm-up routine\n" +
            "4. Recovery protocols\n" +
            "5. When to seek professional help",
            bodyPart
        );
    }
    
    private String buildNutritionPrompt(String mealTime) {
        return String.format(
            "Provide squash-specific nutrition advice for %s.\n\n" +
            "Include:\n" +
            "1. Meal suggestions (3 options)\n" +
            "2. Timing recommendations\n" +
            "3. Hydration guidelines\n" +
            "4. Supplements (if applicable)\n" +
            "5. Foods to avoid",
            mealTime
        );
    }
    
    private String buildMatchPrepPrompt(int hoursBeforeMatch) {
        return String.format(
            "Create a match preparation plan for %d hours before a squash match.\n\n" +
            "Include:\n" +
            "1. Timeline of activities\n" +
            "2. Nutrition and hydration\n" +
            "3. Physical warm-up routine\n" +
            "4. Mental preparation\n" +
            "5. Equipment checklist",
            hoursBeforeMatch
        );
    }
    
    private String buildConversationalPrompt(String userMessage, List<String> history) {
        StringBuilder prompt = new StringBuilder();
        
        // Add conversation history for context
        if (history != null && !history.isEmpty()) {
            prompt.append("Previous conversation:\n");
            for (int i = Math.max(0, history.size() - 5); i < history.size(); i++) {
                prompt.append(history.get(i)).append("\n");
            }
            prompt.append("\n");
        }
        
        prompt.append("User: ").append(userMessage);
        return prompt.toString();
    }
    
    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
        // Save to preferences
        context.getSharedPreferences("app_settings", Context.MODE_PRIVATE)
                .edit()
                .putString("openai_api_key", apiKey)
                .apply();
    }
    
    public boolean hasApiKey() {
        return !apiKey.isEmpty();
    }
}
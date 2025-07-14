package com.squashtrainingapp.ai;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.User;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class AIResponseEngine {
    private static final String TAG = "AIResponseEngine";
    
    private Context context;
    private DatabaseHelper databaseHelper;
    private ExecutorService executorService;
    private Handler mainHandler;
    private AIResponseListener listener;
    private Random random;
    private OpenAIClient openAIClient;
    
    // Local responses for when API is not available
    private static final String[] GREETING_RESPONSES = {
        "Hello! Ready for some great squash training today?",
        "Hi there! Let's work on improving your squash game!",
        "Welcome back! How can I help with your training?"
    };
    
    private static final String[] WORKOUT_SUGGESTIONS = {
        "Try focusing on your footwork today with ladder drills and ghosting exercises.",
        "Work on your serves - aim for 20 serves to each corner, alternating between hard and soft serves.",
        "Practice your drops and boasts - these are crucial for controlling the T.",
        "Do some solo hitting focusing on straight drives. Aim for 50 on each side.",
        "Try the butterfly drill to improve your movement and shot accuracy."
    };
    
    private static final String[] TECHNIQUE_TIPS = {
        "Keep your racket up and ready between shots - this will improve your reaction time.",
        "Focus on hitting through the ball rather than at it for more power and control.",
        "Watch the ball all the way to your racket - this simple tip improves accuracy significantly.",
        "Use your non-racket arm for balance, especially on the backhand.",
        "Bend your knees more - lower body position gives you better court coverage."
    };
    
    private static final String[] MOTIVATION_QUOTES = {
        "Every champion was once a beginner who refused to give up!",
        "The only bad workout is the one you didn't do.",
        "Consistency beats perfection - keep showing up!",
        "Your biggest opponent is the voice in your head telling you to quit.",
        "Progress is progress, no matter how small."
    };
    
    public interface AIResponseListener {
        void onResponse(String response);
        void onAIError(String error);
    }
    
    public AIResponseEngine(Context context) {
        this.context = context;
        this.databaseHelper = DatabaseHelper.getInstance(context);
        this.executorService = Executors.newSingleThreadExecutor();
        this.mainHandler = new Handler(Looper.getMainLooper());
        this.random = new Random();
        this.openAIClient = new OpenAIClient(context);
    }
    
    public void setAIResponseListener(AIResponseListener listener) {
        this.listener = listener;
    }
    
    public void getResponse(String userInput) {
        // Try OpenAI first if available
        if (openAIClient.hasApiKey()) {
            openAIClient.sendMessage(userInput, new OpenAIClient.OpenAICallback() {
                @Override
                public void onSuccess(String response) {
                    mainHandler.post(() -> {
                        if (listener != null) {
                            listener.onResponse(response);
                        }
                    });
                }
                
                @Override
                public void onError(String error) {
                    // Fallback to local response on error
                    Log.w(TAG, "OpenAI error, falling back to local: " + error);
                    executorService.execute(() -> {
                        String response = generateLocalResponse(userInput);
                        mainHandler.post(() -> {
                            if (listener != null) {
                                listener.onResponse(response);
                            }
                        });
                    });
                }
            });
        } else {
            // Use local response generation
            executorService.execute(() -> {
                try {
                    // Simulate processing time
                    Thread.sleep(1000);
                    
                    String response = generateLocalResponse(userInput);
                    
                    mainHandler.post(() -> {
                        if (listener != null) {
                            listener.onResponse(response);
                        }
                    });
                } catch (Exception e) {
                    Log.e(TAG, "Error generating response", e);
                    mainHandler.post(() -> {
                        if (listener != null) {
                            listener.onAIError(e.getMessage());
                        }
                    });
                }
            });
        }
    }
    
    private String generateLocalResponse(String userInput) {
        String input = userInput.toLowerCase();
        
        // Greetings
        if (input.matches(".*(hello|hi|hey|good morning|good afternoon).*")) {
            return GREETING_RESPONSES[random.nextInt(GREETING_RESPONSES.length)];
        }
        
        // Workout requests
        if (input.matches(".*(workout|exercise|training|practice).*")) {
            return WORKOUT_SUGGESTIONS[random.nextInt(WORKOUT_SUGGESTIONS.length)];
        }
        
        // Technique questions
        if (input.matches(".*(technique|how to|improve|better|form).*")) {
            return TECHNIQUE_TIPS[random.nextInt(TECHNIQUE_TIPS.length)];
        }
        
        // Motivation
        if (input.matches(".*(motivat|inspir|tired|difficult|hard|struggle).*")) {
            return MOTIVATION_QUOTES[random.nextInt(MOTIVATION_QUOTES.length)];
        }
        
        // Progress questions
        if (input.matches(".*(progress|improve|stats|how am i doing).*")) {
            return generateProgressResponse();
        }
        
        // Equipment questions
        if (input.matches(".*(racket|string|shoes|ball|equipment).*")) {
            return "For equipment, I recommend: Racket tension around 24-28 lbs, proper court shoes with good lateral support, and double yellow dot balls for intermediate players.";
        }
        
        // Rules questions
        if (input.matches(".*(rules|score|let|stroke|interference).*")) {
            return "In squash, games are played to 11 points (win by 2). A 'let' is played when interference occurs without advantage. A 'stroke' is awarded when the opponent prevents a clear winning shot.";
        }
        
        // Default response
        return "That's an interesting question! For personalized advice, try being more specific about what aspect of squash you'd like to work on - technique, fitness, strategy, or mental game?";
    }
    
    private String generateProgressResponse() {
        // For now, return a generic response
        // TODO: Implement user stats retrieval
        return "Keep tracking your workouts to see your progress. Every session counts! You're doing great!";
    }
    
    public void shutdown() {
        executorService.shutdown();
    }
}
package com.squashtrainingapp;

import android.os.Bundle;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import java.util.Random;

public class CoachActivity extends AppCompatActivity {
    
    // UI components
    private TextView dailyTipText;
    private TextView techniqueAdviceText;
    private TextView motivationalQuoteText;
    private TextView workoutSuggestionText;
    private Button refreshTipsButton;
    private Button askAiButton;
    
    // Tips and advice arrays
    private String[] dailyTips = {
        "Focus on your footwork - good positioning is key to powerful shots",
        "Keep your racket up between shots for faster reaction time",
        "Practice your serves daily - consistency wins matches",
        "Watch the ball all the way to your racket for better control",
        "Use the walls strategically - angles create opportunities"
    };
    
    private String[] techniqueAdvice = {
        "Straight Drive: Keep the ball tight to the wall and aim for good length",
        "Cross Court: Hit with slight angle and ensure the ball reaches the back corner",
        "Drop Shot: Disguise your preparation and use soft hands",
        "Volley: Stay on your toes and punch through the ball",
        "Boast: Hit the side wall first, aiming for the front corner"
    };
    
    private String[] motivationalQuotes = {
        "Champions are made in training, not in matches",
        "Every shot is an opportunity to improve",
        "Consistency beats power every time",
        "Your only opponent is yesterday's performance",
        "Success is the sum of small efforts repeated daily"
    };
    
    private String[] workoutSuggestions = {
        "Ghosting Drill: 30 seconds work, 30 seconds rest x 10 sets",
        "Wall Practice: 100 straight drives each side, focus on consistency",
        "Court Sprints: Baseline to front wall x 20, build explosive power",
        "Shadow Swings: 50 forehand, 50 backhand - perfect your technique",
        "Reaction Drill: Partner feeds random shots for 5 minutes"
    };
    
    private Random random = new Random();
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_coach);
        
        initializeViews();
        loadRandomContent();
        setupButtons();
    }
    
    private void initializeViews() {
        dailyTipText = findViewById(R.id.daily_tip_text);
        techniqueAdviceText = findViewById(R.id.technique_advice_text);
        motivationalQuoteText = findViewById(R.id.motivational_quote_text);
        workoutSuggestionText = findViewById(R.id.workout_suggestion_text);
        refreshTipsButton = findViewById(R.id.refresh_tips_button);
        askAiButton = findViewById(R.id.ask_ai_button);
    }
    
    private void loadRandomContent() {
        // Set random content for each section
        dailyTipText.setText(dailyTips[random.nextInt(dailyTips.length)]);
        techniqueAdviceText.setText(techniqueAdvice[random.nextInt(techniqueAdvice.length)]);
        motivationalQuoteText.setText(motivationalQuotes[random.nextInt(motivationalQuotes.length)]);
        workoutSuggestionText.setText(workoutSuggestions[random.nextInt(workoutSuggestions.length)]);
    }
    
    private void setupButtons() {
        refreshTipsButton.setOnClickListener(v -> {
            loadRandomContent();
            android.widget.Toast.makeText(this, "Tips refreshed!", android.widget.Toast.LENGTH_SHORT).show();
        });
        
        askAiButton.setOnClickListener(v -> {
            android.widget.Toast.makeText(this, "AI Coach coming soon! (OpenAI integration)", android.widget.Toast.LENGTH_LONG).show();
        });
    }
}
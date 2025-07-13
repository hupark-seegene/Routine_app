package com.squashtrainingapp;

import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

public class ProfileActivity extends AppCompatActivity {
    
    // User info views
    private TextView userNameText;
    private TextView levelText;
    private TextView experienceText;
    private ProgressBar experienceBar;
    private ImageView avatarImage;
    
    // Stats views
    private TextView sessionsCountText;
    private TextView caloriesCountText;
    private TextView hoursCountText;
    private TextView streakCountText;
    
    // Achievement views
    private LinearLayout achievementsLayout;
    private TextView recentAchievementText;
    
    // Settings button
    private Button settingsButton;
    
    // Mock data
    private String userName = "Alex Player";
    private int userLevel = 12;
    private int currentExp = 750;
    private int maxExp = 1000;
    private int totalSessions = 147;
    private int totalCalories = 42580;
    private int totalHours = 89;
    private int currentStreak = 7;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);
        
        initializeViews();
        loadUserData();
        displayStats();
        displayAchievements();
        setupSettingsButton();
    }
    
    private void initializeViews() {
        // User info
        userNameText = findViewById(R.id.user_name_text);
        levelText = findViewById(R.id.level_text);
        experienceText = findViewById(R.id.experience_text);
        experienceBar = findViewById(R.id.experience_bar);
        avatarImage = findViewById(R.id.avatar_image);
        
        // Stats
        sessionsCountText = findViewById(R.id.sessions_count);
        caloriesCountText = findViewById(R.id.calories_count);
        hoursCountText = findViewById(R.id.hours_count);
        streakCountText = findViewById(R.id.streak_count);
        
        // Achievements
        achievementsLayout = findViewById(R.id.achievements_layout);
        recentAchievementText = findViewById(R.id.recent_achievement);
        
        // Settings
        settingsButton = findViewById(R.id.settings_button);
    }
    
    private void loadUserData() {
        userNameText.setText(userName);
        levelText.setText("Level " + userLevel);
        experienceText.setText(currentExp + " / " + maxExp + " XP");
        
        // Set experience bar progress
        experienceBar.setMax(maxExp);
        experienceBar.setProgress(currentExp);
        
        // Set avatar (placeholder)
        avatarImage.setBackgroundColor(getResources().getColor(R.color.volt_green));
    }
    
    private void displayStats() {
        sessionsCountText.setText(String.valueOf(totalSessions));
        caloriesCountText.setText(formatNumber(totalCalories));
        hoursCountText.setText(String.valueOf(totalHours));
        streakCountText.setText(currentStreak + " days");
    }
    
    private void displayAchievements() {
        // Recent achievement
        recentAchievementText.setText("Completed 7-Day Streak!");
        
        // Achievement badges (mock data)
        String[] achievements = {
            "First Workout",
            "Week Warrior",
            "Century Club",
            "Calorie Crusher",
            "Speed Demon"
        };
        
        // Add achievement badges dynamically
        for (int i = 0; i < Math.min(achievements.length, 3); i++) {
            TextView badge = new TextView(this);
            badge.setText(achievements[i]);
            badge.setTextColor(getResources().getColor(R.color.volt_green));
            badge.setPadding(0, 8, 0, 8);
            achievementsLayout.addView(badge);
        }
    }
    
    private void setupSettingsButton() {
        settingsButton.setOnClickListener(v -> {
            // TODO: Navigate to settings
            android.widget.Toast.makeText(this, "Settings coming soon!", android.widget.Toast.LENGTH_SHORT).show();
        });
    }
    
    private String formatNumber(int number) {
        if (number >= 1000) {
            return String.format("%.1fK", number / 1000.0);
        }
        return String.valueOf(number);
    }
}
package com.squashtrainingapp.ui.activities;

import com.squashtrainingapp.R;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.User;

import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.content.Intent;

public class ProfileActivity extends BaseActivity {
    
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
    
    // User data
    private String userName = "Alex Player";
    private int userLevel = 1;
    private int currentExp = 0;
    private int maxExp = 1000;
    private int totalSessions = 0;
    private int totalCalories = 0;
    private int totalHours = 0;
    private int currentStreak = 0;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);
        
        // Load from database
        DatabaseHelper dbHelper = DatabaseHelper.getInstance(this);
        User user = dbHelper.getUserDao().getUser();
        
        // Update UI with database values
        userName = user.getName();
        userLevel = user.getLevel();
        currentExp = user.getExperience();
        maxExp = 1000;
        totalSessions = user.getTotalSessions();
        totalCalories = user.getTotalCalories();
        totalHours = Math.round(user.getTotalHours());
        currentStreak = user.getCurrentStreak();
        
        initializeViews();
        loadUserData();
        displayStats();
        displayAchievements();
        setupSettingsButton();
        setupNavigationBar();
        setupBottomNavigation();
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
        levelText.setText(getString(R.string.level) + " " + userLevel);
        experienceText.setText(currentExp + " / " + maxExp + " " + getString(R.string.xp));
        
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
        streakCountText.setText(currentStreak + " " + getString(R.string.days_streak));
    }
    
    private void displayAchievements() {
        // Recent achievement
        recentAchievementText.setText(getString(R.string.completed_7_day_streak));
        
        // Achievement badges (mock data)
        String[] achievements = {
            getString(R.string.first_workout),
            getString(R.string.week_warrior),
            getString(R.string.century_club),
            getString(R.string.achievement_calorie_crusher),
            getString(R.string.achievement_speed_demon)
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
            Intent intent = new Intent(this, SettingsActivity.class);
            startActivity(intent);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
    }
    
    @Override
    protected String getActivityTitle() {
        return "Profile";
    }
    
    private String formatNumber(int number) {
        if (number >= 1000) {
            return String.format("%.1fK", number / 1000.0);
        }
        return String.valueOf(number);
    }
}
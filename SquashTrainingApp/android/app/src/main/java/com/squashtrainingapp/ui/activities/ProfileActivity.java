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
import android.view.View;
import android.widget.Toast;
import android.content.SharedPreferences;
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
    
    // User data
    private String userName = "Alex Player";
    private int userLevel = 1;
    private int currentExp = 0;
    private int maxExp = 1000;
    private int totalSessions = 0;
    private int totalCalories = 0;
    private int totalHours = 0;
    private int currentStreak = 0;
    
    // Developer mode
    private boolean isDeveloperModeEnabled = false;
    private int versionTapCount = 0;
    private TextView versionText;
    private LinearLayout developerOptionsLayout;
    private SharedPreferences prefs;
    
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
        setupDeveloperMode();
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
        
        // Stats button
        Button viewStatsButton = findViewById(R.id.view_stats_button);
        if (viewStatsButton != null) {
            viewStatsButton.setOnClickListener(v -> {
                Intent intent = new Intent(this, StatsActivity.class);
                startActivity(intent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            });
        }
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
    
    
    private String formatNumber(int number) {
        if (number >= 1000) {
            return String.format("%.1fK", number / 1000.0);
        }
        return String.valueOf(number);
    }
    
    private void setupDeveloperMode() {
        prefs = getSharedPreferences("app_prefs", MODE_PRIVATE);
        isDeveloperModeEnabled = prefs.getBoolean("developer_mode", false);
        
        // Find version text
        versionText = findViewById(R.id.version_text);
        if (versionText == null) {
            // Add version text at the bottom
            versionText = new TextView(this);
            versionText.setId(View.generateViewId());
            versionText.setText("Version 1.0.0");
            versionText.setTextColor(getResources().getColor(R.color.text_secondary));
            versionText.setTextSize(12);
            versionText.setPadding(16, 16, 16, 16);
            versionText.setGravity(android.view.Gravity.CENTER);
            
            // Find the main scroll view or content layout
            LinearLayout contentLayout = findViewById(R.id.content_layout);
            if (contentLayout != null) {
                contentLayout.addView(versionText);
            }
        }
        
        // Setup tap listener for developer mode
        versionText.setOnClickListener(v -> {
            versionTapCount++;
            if (versionTapCount >= 5) {
                enableDeveloperMode();
                versionTapCount = 0;
            } else if (versionTapCount >= 3) {
                Toast.makeText(this, (5 - versionTapCount) + " more taps to enable developer mode", Toast.LENGTH_SHORT).show();
            }
        });
        
        // Create developer options container
        developerOptionsLayout = findViewById(R.id.developer_options_layout);
        if (developerOptionsLayout == null) {
            developerOptionsLayout = new LinearLayout(this);
            developerOptionsLayout.setId(View.generateViewId());
            developerOptionsLayout.setOrientation(LinearLayout.VERTICAL);
            developerOptionsLayout.setPadding(16, 16, 16, 16);
            developerOptionsLayout.setVisibility(View.GONE);
            
            LinearLayout contentLayout = findViewById(R.id.content_layout);
            if (contentLayout != null) {
                // Add before version text
                int versionIndex = contentLayout.indexOfChild(versionText);
                if (versionIndex > 0) {
                    contentLayout.addView(developerOptionsLayout, versionIndex);
                } else {
                    contentLayout.addView(developerOptionsLayout);
                }
            }
        }
        
        // Show developer options if already enabled
        if (isDeveloperModeEnabled) {
            showDeveloperOptions();
        }
    }
    
    private void enableDeveloperMode() {
        isDeveloperModeEnabled = true;
        prefs.edit().putBoolean("developer_mode", true).apply();
        Toast.makeText(this, "Developer mode enabled!", Toast.LENGTH_LONG).show();
        showDeveloperOptions();
    }
    
    private void showDeveloperOptions() {
        if (developerOptionsLayout == null) return;
        
        developerOptionsLayout.removeAllViews();
        
        // Add developer options title
        TextView titleText = new TextView(this);
        titleText.setText("Developer Options");
        titleText.setTextColor(getResources().getColor(R.color.volt_green));
        titleText.setTextSize(18);
        titleText.setPadding(0, 0, 0, 16);
        developerOptionsLayout.addView(titleText);
        
        
        // Add Clear Data button
        Button clearDataButton = new Button(this);
        clearDataButton.setText("Clear All Data");
        clearDataButton.setBackgroundTintList(getResources().getColorStateList(R.color.dark_surface));
        clearDataButton.setTextColor(getResources().getColor(R.color.text_primary));
        clearDataButton.setOnClickListener(v -> {
            // Clear database
            DatabaseHelper db = DatabaseHelper.getInstance(this);
            db.clearAllData();
            Toast.makeText(this, "All data cleared", Toast.LENGTH_SHORT).show();
            
            // Reload data
            User user = db.getUserDao().getUser();
            userName = user.getName();
            userLevel = user.getLevel();
            currentExp = user.getExperience();
            totalSessions = user.getTotalSessions();
            totalCalories = user.getTotalCalories();
            totalHours = Math.round(user.getTotalHours());
            currentStreak = user.getCurrentStreak();
            
            loadUserData();
            displayStats();
        });
        developerOptionsLayout.addView(clearDataButton);
        
        // Add Disable Developer Mode button
        Button disableButton = new Button(this);
        disableButton.setText("Disable Developer Mode");
        disableButton.setBackgroundTintList(getResources().getColorStateList(android.R.color.holo_red_dark));
        disableButton.setTextColor(getResources().getColor(R.color.text_primary));
        disableButton.setOnClickListener(v -> {
            isDeveloperModeEnabled = false;
            prefs.edit().putBoolean("developer_mode", false).apply();
            developerOptionsLayout.setVisibility(View.GONE);
            versionTapCount = 0;
            Toast.makeText(this, "Developer mode disabled", Toast.LENGTH_SHORT).show();
        });
        developerOptionsLayout.addView(disableButton);
        
        developerOptionsLayout.setVisibility(View.VISIBLE);
    }
}
package com.squashtrainingapp;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;

import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.User;
import com.squashtrainingapp.ui.activities.*;

public class SimpleMainActivity extends AppCompatActivity {
    
    // UI components
    private CardView cardProfile;
    private CardView cardChecklist;
    private CardView cardRecord;
    private CardView cardHistory;
    private CardView cardCoach;
    private CardView cardSettings;
    
    // Stats views
    private TextView streakCountText;
    private TextView sessionsCountText;
    private TextView levelText;
    
    // Database
    private DatabaseHelper databaseHelper;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_simple_main);
        
        // Initialize database
        databaseHelper = DatabaseHelper.getInstance(this);
        
        // Initialize views
        initializeViews();
        
        // Setup click listeners
        setupClickListeners();
        
        // Load user stats
        loadUserStats();
        
        // Show welcome message
        showWelcomeToast();
    }
    
    private void initializeViews() {
        // Cards
        cardProfile = findViewById(R.id.card_profile);
        cardChecklist = findViewById(R.id.card_checklist);
        cardRecord = findViewById(R.id.card_record);
        cardHistory = findViewById(R.id.card_history);
        cardCoach = findViewById(R.id.card_coach);
        cardSettings = findViewById(R.id.card_settings);
        
        // Stats
        streakCountText = findViewById(R.id.streak_count);
        sessionsCountText = findViewById(R.id.sessions_count);
        levelText = findViewById(R.id.level_text);
    }
    
    private void setupClickListeners() {
        // Profile
        cardProfile.setOnClickListener(v -> {
            startActivity(new Intent(this, ProfileActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
        
        // Checklist
        cardChecklist.setOnClickListener(v -> {
            startActivity(new Intent(this, ChecklistActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
        
        // Record
        cardRecord.setOnClickListener(v -> {
            startActivity(new Intent(this, RecordActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
        
        // History
        cardHistory.setOnClickListener(v -> {
            startActivity(new Intent(this, HistoryActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
        
        // Coach
        cardCoach.setOnClickListener(v -> {
            startActivity(new Intent(this, CoachActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
        
        // Settings
        cardSettings.setOnClickListener(v -> {
            startActivity(new Intent(this, SettingsActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
    }
    
    private void loadUserStats() {
        // Load user data from database
        User user = databaseHelper.getUserDao().getUser();
        
        // Update UI
        streakCountText.setText(String.valueOf(user.getCurrentStreak()));
        sessionsCountText.setText(String.valueOf(user.getTotalSessions()));
        levelText.setText(String.valueOf(user.getLevel()));
    }
    
    private void showWelcomeToast() {
        String welcomeMessage = getString(R.string.welcome_back);
        Toast.makeText(this, welcomeMessage, Toast.LENGTH_SHORT).show();
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        // Refresh stats when returning to main screen
        loadUserStats();
    }
}
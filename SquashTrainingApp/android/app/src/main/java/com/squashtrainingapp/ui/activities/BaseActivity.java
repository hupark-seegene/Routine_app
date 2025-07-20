package com.squashtrainingapp.ui.activities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageButton;
import android.widget.TextView;
import com.squashtrainingapp.MainActivity;
import com.squashtrainingapp.R;

public abstract class BaseActivity extends Activity {
    
    protected ImageButton backButton;
    protected ImageButton homeButton;
    protected TextView titleText;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
    
    protected void setupNavigationBar() {
        // Find navigation views
        backButton = findViewById(R.id.back_button);
        homeButton = findViewById(R.id.home_button);
        titleText = findViewById(R.id.title_text);
        
        // Setup back button
        if (backButton != null) {
            backButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onBackPressed();
                }
            });
        }
        
        // Setup home button
        if (homeButton != null) {
            homeButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    navigateToHome();
                }
            });
        }
        
        // Set title if available
        if (titleText != null) {
            titleText.setText(getActivityTitle());
        }
    }
    
    protected void navigateToHome() {
        Intent intent = new Intent(this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(intent);
        finish();
    }
    
    protected void navigateToActivity(Class<?> activityClass) {
        Intent intent = new Intent(this, activityClass);
        startActivity(intent);
    }
    
    protected void navigateToActivityAndFinish(Class<?> activityClass) {
        Intent intent = new Intent(this, activityClass);
        startActivity(intent);
        finish();
    }
    
    @Override
    public void onBackPressed() {
        super.onBackPressed();
        // Add slide animation when going back
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }
    
    protected void setupBottomNavigation() {
        View profileNav = findViewById(R.id.nav_profile);
        View checklistNav = findViewById(R.id.nav_checklist);
        View coachNav = findViewById(R.id.nav_coach);
        View recordNav = findViewById(R.id.nav_record);
        View historyNav = findViewById(R.id.nav_history);
        
        if (profileNav != null) {
            profileNav.setOnClickListener(v -> navigateToActivity(ProfileActivity.class));
        }
        if (checklistNav != null) {
            checklistNav.setOnClickListener(v -> navigateToActivity(ChecklistActivity.class));
        }
        if (coachNav != null) {
            coachNav.setOnClickListener(v -> navigateToActivity(CoachActivity.class));
        }
        if (recordNav != null) {
            recordNav.setOnClickListener(v -> navigateToActivity(RecordActivity.class));
        }
        if (historyNav != null) {
            historyNav.setOnClickListener(v -> navigateToActivity(HistoryActivity.class));
        }
    }
    
    // Abstract method to get activity title
    protected abstract String getActivityTitle();
}
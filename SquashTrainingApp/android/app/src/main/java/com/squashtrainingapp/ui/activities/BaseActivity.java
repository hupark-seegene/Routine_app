package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageButton;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.squashtrainingapp.R;

public abstract class BaseActivity extends AppCompatActivity {
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
    
    protected void setupNavigationBar() {
        // Find the navigation bar
        View navigationBar = findViewById(R.id.navigation_bar);
        if (navigationBar != null) {
            // Set title
            TextView titleText = navigationBar.findViewById(R.id.title_text);
            if (titleText != null) {
                titleText.setText(getActivityTitle());
            }
            
            // Set back button
            ImageButton backButton = navigationBar.findViewById(R.id.back_button);
            if (backButton != null) {
                backButton.setOnClickListener(v -> finish());
            }
        }
    }
    
    protected void setupBottomNavigation() {
        BottomNavigationView bottomNav = findViewById(R.id.bottom_navigation);
        if (bottomNav != null) {
            // Set up bottom navigation if needed
        }
    }
    
    protected abstract String getActivityTitle();
}
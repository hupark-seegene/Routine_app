package com.squashtrainingapp;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Button;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.bottomnavigation.BottomNavigationView;

public class MainActivity extends AppCompatActivity {
    
    private FrameLayout contentFrame;
    private TextView contentText;
    private BottomNavigationView navigation;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_navigation);
        
        contentFrame = findViewById(R.id.content_frame);
        contentText = findViewById(R.id.content_text);
        navigation = findViewById(R.id.bottom_navigation);
        
        navigation.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                int itemId = item.getItemId();
                
                if (itemId == R.id.navigation_home) {
                    showContent("Home Screen");
                    return true;
                } else if (itemId == R.id.navigation_checklist) {
                    // Start ChecklistActivity with proper flags
                    Intent intent = new Intent(MainActivity.this, ChecklistActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                    startActivity(intent);
                    // Don't finish MainActivity
                    return true;
                } else if (itemId == R.id.navigation_record) {
                    // Start RecordActivity with proper flags
                    Intent intent = new Intent(MainActivity.this, RecordActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                    startActivity(intent);
                    // Don't finish MainActivity
                    return true;
                } else if (itemId == R.id.navigation_profile) {
                    // Start ProfileActivity with proper flags
                    Intent intent = new Intent(MainActivity.this, ProfileActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                    startActivity(intent);
                    // Don't finish MainActivity
                    return true;
                } else if (itemId == R.id.navigation_coach) {
                    // Start CoachActivity with proper flags
                    Intent intent = new Intent(MainActivity.this, CoachActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                    startActivity(intent);
                    // Don't finish MainActivity
                    return true;
                }
                
                return false;
            }
        });
        
                // Set default selection
        navigation.setSelectedItemId(R.id.navigation_home);
        
        // History button
        Button historyButton = findViewById(R.id.history_button);
        if (historyButton != null) {
            historyButton.setOnClickListener(v -> {
                Intent intent = new Intent(MainActivity.this, HistoryActivity.class);
                startActivity(intent);
            });
        }
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        // Reset to home when returning from other activities
        if (navigation != null) {
            navigation.setSelectedItemId(R.id.navigation_home);
        }
    }
    
    private void showContent(String screenName) {
        contentText.setText(screenName);
    }
}
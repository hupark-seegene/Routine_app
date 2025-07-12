package com.squashtrainingapp;

import android.os.Bundle;
import android.view.MenuItem;
import android.widget.FrameLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.bottomnavigation.BottomNavigationView;

public class MainActivity extends AppCompatActivity {
    
    private FrameLayout contentFrame;
    private TextView contentText;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_navigation);
        
        contentFrame = findViewById(R.id.content_frame);
        contentText = findViewById(R.id.content_text);
        BottomNavigationView navigation = findViewById(R.id.bottom_navigation);
        
        navigation.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                int itemId = item.getItemId();
                
                if (itemId == R.id.navigation_home) {
                    showContent("Home Screen");
                    return true;
                } else if (itemId == R.id.navigation_checklist) {
                    showContent("Checklist Screen");
                    return true;
                } else if (itemId == R.id.navigation_record) {
                    showContent("Record Screen");
                    return true;
                } else if (itemId == R.id.navigation_profile) {
                    showContent("Profile Screen");
                    return true;
                } else if (itemId == R.id.navigation_coach) {
                    showContent("Coach Screen");
                    return true;
                }
                
                return false;
            }
        });
        
        // Set default selection
        navigation.setSelectedItemId(R.id.navigation_home);
    }
    
    private void showContent(String screenName) {
        contentText.setText(screenName);
    }
}

package com.squashtrainingapp;

import android.os.Bundle;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.graphics.Color;
import android.view.Gravity;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Create basic UI programmatically
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setBackgroundColor(Color.BLACK);
        layout.setGravity(Gravity.CENTER);
        layout.setPadding(50, 50, 50, 50);
        
        // App title
        TextView title = new TextView(this);
        title.setText("Squash Training App");
        title.setTextColor(Color.parseColor("#C9FF00")); // Volt green
        title.setTextSize(28);
        title.setGravity(Gravity.CENTER);
        layout.addView(title);
        
        // Version info
        TextView version = new TextView(this);
        version.setText("Version: 1.0.12 (Cycle 12)");
        version.setTextColor(Color.WHITE);
        version.setTextSize(16);
        version.setGravity(Gravity.CENTER);
        version.setPadding(0, 20, 0, 0);
        layout.addView(version);
        
        // Status info
        TextView status = new TextView(this);
        status.setText("Basic Android Foundation - Working!");
        status.setTextColor(Color.parseColor("#C9FF00"));
        status.setTextSize(18);
        status.setGravity(Gravity.CENTER);
        status.setPadding(0, 30, 0, 0);
        layout.addView(status);
        
        // Build info
        TextView buildInfo = new TextView(this);
        buildInfo.setText("Build: 2025-07-13 01:46:30");
        buildInfo.setTextColor(Color.GRAY);
        buildInfo.setTextSize(12);
        buildInfo.setGravity(Gravity.CENTER);
        buildInfo.setPadding(0, 40, 0, 0);
        layout.addView(buildInfo);
        
        setContentView(layout);
    }
}

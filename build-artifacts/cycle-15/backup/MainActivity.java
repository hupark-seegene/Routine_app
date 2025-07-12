package com.squashtrainingapp;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        
        // Initialize UI components
        setupButtons();
    }
    
    private void setupButtons() {
        Button startTrainingButton = findViewById(R.id.startTrainingButton);
        Button viewProgramButton = findViewById(R.id.viewProgramButton);
        Button aiCoachButton = findViewById(R.id.aiCoachButton);
        
        startTrainingButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(MainActivity.this, 
                    "Training mode coming soon!", 
                    Toast.LENGTH_SHORT).show();
            }
        });
        
        viewProgramButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(MainActivity.this, 
                    "Program view coming soon!", 
                    Toast.LENGTH_SHORT).show();
            }
        });
        
        aiCoachButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(MainActivity.this, 
                    "AI Coach coming soon!", 
                    Toast.LENGTH_SHORT).show();
            }
        });
    }
}

package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.squashtrainingapp.R;

public class CreateChallengeActivity extends AppCompatActivity {
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_simple_placeholder);
        
        // Back button
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        Toast.makeText(this, "챌린지 생성 기능 준비 중", Toast.LENGTH_SHORT).show();
    }
}
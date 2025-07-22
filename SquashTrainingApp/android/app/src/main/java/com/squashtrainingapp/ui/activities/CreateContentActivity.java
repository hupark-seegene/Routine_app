package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.squashtrainingapp.R;

public class CreateContentActivity extends AppCompatActivity {
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_content);
        
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        // Placeholder for content creation
        Toast.makeText(this, "콘텐츠 생성 기능 준비 중", Toast.LENGTH_SHORT).show();
    }
}
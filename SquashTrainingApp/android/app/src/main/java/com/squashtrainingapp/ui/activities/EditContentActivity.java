package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.squashtrainingapp.R;

public class EditContentActivity extends AppCompatActivity {
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_content);
        
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        String contentId = getIntent().getStringExtra("content_id");
        
        // Placeholder for content editing
        Toast.makeText(this, "콘텐츠 편집 기능 준비 중", Toast.LENGTH_SHORT).show();
    }
}
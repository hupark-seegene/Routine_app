package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.squashtrainingapp.R;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.database.dao.TrainingProgramDao;
import com.squashtrainingapp.models.TrainingProgram;

public class ProgramDetailActivity extends AppCompatActivity {
    
    private TrainingProgram program;
    private TrainingProgramDao programDao;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_program_detail);
        
        // Get program ID from intent
        long programId = getIntent().getLongExtra("program_id", -1);
        String programName = getIntent().getStringExtra("program_name");
        
        if (programId == -1) {
            Toast.makeText(this, "Error loading program", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }
        
        initializeViews(programName);
        loadProgramDetails(programId);
    }
    
    private void initializeViews(String programName) {
        // Back button
        ImageView backButton = findViewById(R.id.back_button);
        backButton.setOnClickListener(v -> finish());
        
        // Title
        TextView titleText = findViewById(R.id.title_text);
        titleText.setText(programName != null ? programName : "PROGRAM DETAILS");
    }
    
    private void loadProgramDetails(long programId) {
        programDao = new TrainingProgramDao(DatabaseHelper.getInstance(this));
        program = programDao.getProgramById(programId);
        
        if (program != null) {
            displayProgramDetails();
        } else {
            Toast.makeText(this, "Program not found", Toast.LENGTH_SHORT).show();
            finish();
        }
    }
    
    private void displayProgramDetails() {
        TextView nameText = findViewById(R.id.program_name);
        TextView descriptionText = findViewById(R.id.program_description);
        TextView durationText = findViewById(R.id.program_duration);
        TextView difficultyText = findViewById(R.id.program_difficulty);
        Button enrollButton = findViewById(R.id.enroll_button);
        
        nameText.setText(program.getName());
        descriptionText.setText(program.getDescription());
        durationText.setText(program.getDurationWeeks() + " WEEK PROGRAM");
        difficultyText.setText("Difficulty: " + program.getDifficulty());
        
        enrollButton.setOnClickListener(v -> {
            Toast.makeText(this, "Enrollment coming in next cycle!", Toast.LENGTH_SHORT).show();
        });
    }
}
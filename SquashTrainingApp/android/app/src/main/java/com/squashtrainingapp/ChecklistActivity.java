package com.squashtrainingapp;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class ChecklistActivity extends AppCompatActivity {
    
    private RecyclerView exerciseRecyclerView;
    private ExerciseAdapter exerciseAdapter;
    private List<Exercise> exerciseList;
    private TextView completionText;
    private int completedCount = 0;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_checklist);
        
        // Initialize views
        exerciseRecyclerView = findViewById(R.id.exercise_recycler_view);
        completionText = findViewById(R.id.completion_text);
        
        // Setup RecyclerView
        exerciseList = getMockExercises();
        exerciseAdapter = new ExerciseAdapter(exerciseList, new ExerciseAdapter.OnExerciseCheckListener() {
            @Override
            public void onExerciseChecked(int position, boolean isChecked) {
                exerciseList.get(position).setCompleted(isChecked);
                updateCompletionStatus();
                
                String message = isChecked ? "Exercise completed!" : "Exercise unchecked";
                Toast.makeText(ChecklistActivity.this, message, Toast.LENGTH_SHORT).show();
            }
        });
        
        exerciseRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        exerciseRecyclerView.setAdapter(exerciseAdapter);
        
        updateCompletionStatus();
    }
    
    private void updateCompletionStatus() {
        completedCount = 0;
        for (Exercise exercise : exerciseList) {
            if (exercise.isCompleted()) {
                completedCount++;
            }
        }
        
        String status = "Completed: " + completedCount + " / " + exerciseList.size();
        completionText.setText(status);
        
        if (completedCount == exerciseList.size()) {
            completionText.setTextColor(getColor(R.color.volt_green));
        } else {
            completionText.setTextColor(getColor(R.color.text_primary));
        }
    }
    
    private List<Exercise> getMockExercises() {
        List<Exercise> exercises = new ArrayList<>();
        
        // Skill exercises
        exercises.add(new Exercise("Straight Drive", "Skill", 3, 10, 0));
        exercises.add(new Exercise("Cross Court Drive", "Skill", 3, 10, 0));
        exercises.add(new Exercise("Boast Practice", "Skill", 2, 15, 0));
        
        // Cardio exercises
        exercises.add(new Exercise("Court Sprints", "Cardio", 0, 0, 20));
        
        // Fitness exercises
        exercises.add(new Exercise("Lunges", "Fitness", 3, 15, 0));
        
        // Strength exercises
        exercises.add(new Exercise("Core Rotation", "Strength", 3, 20, 0));
        
        return exercises;
    }
}

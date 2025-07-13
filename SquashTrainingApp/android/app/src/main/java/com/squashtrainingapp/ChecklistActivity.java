package com.squashtrainingapp;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class ChecklistActivity extends AppCompatActivity {
    
    private RecyclerView recyclerView;
    private ExerciseAdapter adapter;
    private DatabaseHelper databaseHelper;
    private List<DatabaseHelper.Exercise> exercises;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_checklist);
        
        databaseHelper = DatabaseHelper.getInstance(this);
        
        recyclerView = findViewById(R.id.exercise_recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        loadExercises();
    }
    
    private void loadExercises() {
        exercises = databaseHelper.getAllExercises();
        adapter = new ExerciseAdapter();
        recyclerView.setAdapter(adapter);
    }
    
    private class ExerciseAdapter extends RecyclerView.Adapter<ExerciseAdapter.ViewHolder> {
        
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_exercise, parent, false);
            return new ViewHolder(view);
        }
        
        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            DatabaseHelper.Exercise exercise = exercises.get(position);
            holder.exerciseName.setText(exercise.name);
            holder.exerciseCategory.setText(exercise.category);
            holder.checkbox.setChecked(exercise.isChecked);
            
            holder.checkbox.setOnCheckedChangeListener((buttonView, isChecked) -> {
                exercise.isChecked = isChecked;
                databaseHelper.updateExerciseChecked(exercise.id, isChecked);
                
                if (isChecked) {
                    Toast.makeText(ChecklistActivity.this, 
                        exercise.name + " completed!", Toast.LENGTH_SHORT).show();
                }
            });
        }
        
        @Override
        public int getItemCount() {
            return exercises.size();
        }
        
        class ViewHolder extends RecyclerView.ViewHolder {
            TextView exerciseName;
            TextView exerciseCategory;
            CheckBox checkbox;
            
            ViewHolder(View itemView) {
                super(itemView);
                exerciseName = itemView.findViewById(R.id.exercise_name);
                exerciseCategory = itemView.findViewById(R.id.exercise_category);
                checkbox = itemView.findViewById(R.id.exercise_checkbox);
            }
        }
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        // Refresh data when returning to this screen
        loadExercises();
    }
}
package com.squashtrainingapp.ui.activities;

import com.squashtrainingapp.R;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.Exercise;
import com.squashtrainingapp.ui.adapters.ExerciseAdapter;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.TextView;
import android.widget.Toast;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class ChecklistActivity extends BaseActivity {
    
    private RecyclerView recyclerView;
    private ExerciseAdapter adapter;
    private DatabaseHelper databaseHelper;
    private List<Exercise> exercises;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_checklist);
        
        databaseHelper = DatabaseHelper.getInstance(this);
        
        recyclerView = findViewById(R.id.exercise_recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        loadExercises();
        setupNavigationBar();
        setupBottomNavigation();
    }
    
    private void loadExercises() {
        exercises = databaseHelper.getExerciseDao().getAllExercises();
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
            Exercise exercise = exercises.get(position);
            holder.exerciseName.setText(exercise.getName());
            holder.exerciseCategory.setText(exercise.getCategory());
            holder.checkbox.setChecked(exercise.isChecked());
            
            holder.checkbox.setOnCheckedChangeListener((buttonView, isChecked) -> {
                exercise.setChecked(isChecked);
                databaseHelper.getExerciseDao().updateCheckedStatus(exercise.getId(), isChecked);
                
                if (isChecked) {
                    Toast.makeText(ChecklistActivity.this, 
                        exercise.getName() + " completed!", Toast.LENGTH_SHORT).show();
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
    
    @Override
    protected String getActivityTitle() {
        return "Daily Checklist";
    }
}
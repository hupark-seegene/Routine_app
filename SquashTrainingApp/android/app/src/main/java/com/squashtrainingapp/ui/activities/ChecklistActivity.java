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
import androidx.appcompat.app.AppCompatActivity;

public class ChecklistActivity extends AppCompatActivity {
    
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
    }
    
    private void loadExercises() {
        exercises = databaseHelper.getExerciseDao().getAllExercises();
        
        // If no exercises, add default daily workout
        if (exercises.isEmpty()) {
            addDefaultExercises();
            exercises = databaseHelper.getExerciseDao().getAllExercises();
        }
        
        // Update progress
        updateProgress();
        
        adapter = new ExerciseAdapter();
        recyclerView.setAdapter(adapter);
    }
    
    private void addDefaultExercises() {
        // Add default squash training exercises
        String[][] defaultExercises = {
            {"워밍업 러닝", "Cardio", "10분간 가벼운 조깅으로 몸을 준비합니다"},
            {"고스팅 드릴", "Skill", "코트 코너를 터치하며 움직임 연습 (3세트 x 30초)"},
            {"포핸드 스윙 연습", "Skill", "벽에 대고 포핸드 스윙 50회"},
            {"백핸드 스윙 연습", "Skill", "벽에 대고 백핸드 스윙 50회"},
            {"런지 운동", "Strength", "각 다리 15회씩 3세트"},
            {"플랭크", "Strength", "30초 유지 x 3세트"},
            {"서브 연습", "Skill", "다양한 서브 각 10회씩"},
            {"쿨다운 스트레칭", "Recovery", "10분간 전신 스트레칭"}
        };
        
        for (String[] ex : defaultExercises) {
            Exercise exercise = new Exercise();
            exercise.setName(ex[0]);
            exercise.setCategory(ex[1]);
            exercise.setDescription(ex[2]);
            exercise.setChecked(false);
            databaseHelper.getExerciseDao().insert(exercise);
        }
        
        Toast.makeText(this, "일일 운동 체크리스트가 준비되었습니다!", Toast.LENGTH_SHORT).show();
    }
    
    private void updateProgress() {
        int completed = 0;
        for (Exercise ex : exercises) {
            if (ex.isChecked()) completed++;
        }
        
        TextView progressText = findViewById(R.id.progress_text);
        if (progressText != null) {
            progressText.setText(String.format("오늘의 진행도: %d/%d (%d%%)", 
                completed, exercises.size(), (completed * 100) / Math.max(exercises.size(), 1)));
        }
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
    
}
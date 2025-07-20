package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.squashtrainingapp.R;
import com.squashtrainingapp.managers.CustomExerciseManager;
import com.squashtrainingapp.models.CustomExercise;
import com.squashtrainingapp.ui.adapters.CustomExerciseAdapter;

import java.util.ArrayList;
import java.util.List;

public class CustomExerciseActivity extends AppCompatActivity implements 
    CustomExerciseAdapter.ExerciseClickListener {
    
    private RecyclerView recyclerView;
    private CustomExerciseAdapter adapter;
    private CustomExerciseManager exerciseManager;
    private FloatingActionButton fabAdd;
    private ImageButton backButton;
    private TextView titleText;
    private TextView emptyText;
    private Spinner filterSpinner;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_custom_exercise);
        
        initializeViews();
        setupFilterSpinner();
        loadExercises();
    }
    
    private void initializeViews() {
        backButton = findViewById(R.id.back_button);
        titleText = findViewById(R.id.title_text);
        recyclerView = findViewById(R.id.exercises_recycler_view);
        fabAdd = findViewById(R.id.fab_add_exercise);
        emptyText = findViewById(R.id.empty_text);
        filterSpinner = findViewById(R.id.filter_spinner);
        
        // Initialize manager
        exerciseManager = new CustomExerciseManager(this);
        
        // Setup RecyclerView
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        adapter = new CustomExerciseAdapter(this);
        recyclerView.setAdapter(adapter);
        
        // Back button
        backButton.setOnClickListener(v -> finish());
        
        // FAB
        fabAdd.setOnClickListener(v -> showCreateExerciseDialog());
        
        titleText.setText("커스텀 운동");
    }
    
    private void setupFilterSpinner() {
        String[] filters = {"모든 운동", "포핸드", "백핸드", "서브", 
                          "발리", "드롭샷", "보스트", "풋워크", 
                          "체력", "커스텀", "최근 사용", "자주 사용"};
        
        ArrayAdapter<String> filterAdapter = new ArrayAdapter<>(
            this, android.R.layout.simple_spinner_item, filters);
        filterAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        filterSpinner.setAdapter(filterAdapter);
        
        filterSpinner.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(android.widget.AdapterView<?> parent, View view, int position, long id) {
                filterExercises(position);
            }
            
            @Override
            public void onNothingSelected(android.widget.AdapterView<?> parent) {}
        });
    }
    
    private void loadExercises() {
        List<CustomExercise> exercises = exerciseManager.getAllExercises();
        updateExerciseList(exercises);
    }
    
    private void filterExercises(int filterPosition) {
        List<CustomExercise> exercises;
        
        switch (filterPosition) {
            case 0: // All
                exercises = exerciseManager.getAllExercises();
                break;
            case 1: // Forehand
                exercises = exerciseManager.getExercisesByCategory(CustomExercise.Category.FOREHAND);
                break;
            case 2: // Backhand
                exercises = exerciseManager.getExercisesByCategory(CustomExercise.Category.BACKHAND);
                break;
            case 3: // Serve
                exercises = exerciseManager.getExercisesByCategory(CustomExercise.Category.SERVE);
                break;
            case 4: // Volley
                exercises = exerciseManager.getExercisesByCategory(CustomExercise.Category.VOLLEY);
                break;
            case 5: // Drop
                exercises = exerciseManager.getExercisesByCategory(CustomExercise.Category.DROP);
                break;
            case 6: // Boast
                exercises = exerciseManager.getExercisesByCategory(CustomExercise.Category.BOAST);
                break;
            case 7: // Footwork
                exercises = exerciseManager.getExercisesByCategory(CustomExercise.Category.FOOTWORK);
                break;
            case 8: // Fitness
                exercises = exerciseManager.getExercisesByCategory(CustomExercise.Category.FITNESS);
                break;
            case 9: // Custom
                exercises = exerciseManager.getExercisesByCategory(CustomExercise.Category.CUSTOM);
                break;
            case 10: // Recently used
                exercises = exerciseManager.getRecentlyUsedExercises(10);
                break;
            case 11: // Most used
                exercises = exerciseManager.getMostUsedExercises(10);
                break;
            default:
                exercises = exerciseManager.getAllExercises();
        }
        
        updateExerciseList(exercises);
    }
    
    private void updateExerciseList(List<CustomExercise> exercises) {
        adapter.setExercises(exercises);
        
        if (exercises.isEmpty()) {
            recyclerView.setVisibility(View.GONE);
            emptyText.setVisibility(View.VISIBLE);
        } else {
            recyclerView.setVisibility(View.VISIBLE);
            emptyText.setVisibility(View.GONE);
        }
    }
    
    private void showCreateExerciseDialog() {
        View dialogView = getLayoutInflater().inflate(R.layout.dialog_create_exercise, null);
        
        EditText nameInput = dialogView.findViewById(R.id.input_name);
        EditText descriptionInput = dialogView.findViewById(R.id.input_description);
        Spinner categorySpinner = dialogView.findViewById(R.id.spinner_category);
        Spinner difficultySpinner = dialogView.findViewById(R.id.spinner_difficulty);
        EditText durationInput = dialogView.findViewById(R.id.input_duration);
        EditText setsInput = dialogView.findViewById(R.id.input_sets);
        EditText repsInput = dialogView.findViewById(R.id.input_reps);
        EditText instructionsInput = dialogView.findViewById(R.id.input_instructions);
        EditText tipsInput = dialogView.findViewById(R.id.input_tips);
        
        // Setup spinners
        String[] categories = {"포핸드", "백핸드", "서브", "발리", 
                             "드롭샷", "보스트", "풋워크", "체력", "커스텀"};
        ArrayAdapter<String> categoryAdapter = new ArrayAdapter<>(
            this, android.R.layout.simple_spinner_item, categories);
        categorySpinner.setAdapter(categoryAdapter);
        
        String[] difficulties = {"쉬움", "중간", "어려움"};
        ArrayAdapter<String> difficultyAdapter = new ArrayAdapter<>(
            this, android.R.layout.simple_spinner_item, difficulties);
        difficultySpinner.setAdapter(difficultyAdapter);
        
        new AlertDialog.Builder(this)
            .setTitle("새 운동 만들기")
            .setView(dialogView)
            .setPositiveButton("생성", (dialog, which) -> {
                String name = nameInput.getText().toString().trim();
                String description = descriptionInput.getText().toString().trim();
                
                if (name.isEmpty()) {
                    Toast.makeText(this, "운동 이름을 입력해주세요", Toast.LENGTH_SHORT).show();
                    return;
                }
                
                CustomExercise exercise = new CustomExercise();
                exercise.setName(name);
                exercise.setDescription(description);
                exercise.setCategory(CustomExercise.Category.values()[categorySpinner.getSelectedItemPosition()]);
                exercise.setDifficulty(CustomExercise.Difficulty.values()[difficultySpinner.getSelectedItemPosition()]);
                
                try {
                    exercise.setDuration(Integer.parseInt(durationInput.getText().toString()));
                    exercise.setSets(Integer.parseInt(setsInput.getText().toString()));
                    exercise.setReps(Integer.parseInt(repsInput.getText().toString()));
                } catch (NumberFormatException e) {
                    // Use defaults if parsing fails
                    exercise.setDuration(15);
                    exercise.setSets(3);
                    exercise.setReps(10);
                }
                
                exercise.setInstructions(instructionsInput.getText().toString());
                exercise.setTips(tipsInput.getText().toString());
                
                exerciseManager.addExercise(exercise);
                loadExercises();
                Toast.makeText(this, "운동이 추가되었습니다", Toast.LENGTH_SHORT).show();
            })
            .setNegativeButton("취소", null)
            .show();
    }
    
    @Override
    public void onExerciseClick(CustomExercise exercise) {
        // Record usage
        exerciseManager.recordExerciseUsage(exercise.getId());
        
        // Show exercise details or start workout
        showExerciseDetailsDialog(exercise);
    }
    
    @Override
    public void onExerciseEdit(CustomExercise exercise) {
        showEditExerciseDialog(exercise);
    }
    
    @Override
    public void onExerciseDelete(CustomExercise exercise) {
        new AlertDialog.Builder(this)
            .setTitle("운동 삭제")
            .setMessage(exercise.getName() + "을(를) 삭제하시겠습니까?")
            .setPositiveButton("삭제", (dialog, which) -> {
                exerciseManager.deleteExercise(exercise.getId());
                loadExercises();
                Toast.makeText(this, "운동이 삭제되었습니다", Toast.LENGTH_SHORT).show();
            })
            .setNegativeButton("취소", null)
            .show();
    }
    
    private void showExerciseDetailsDialog(CustomExercise exercise) {
        View dialogView = getLayoutInflater().inflate(R.layout.dialog_exercise_details, null);
        
        TextView nameText = dialogView.findViewById(R.id.exercise_name);
        TextView categoryText = dialogView.findViewById(R.id.exercise_category);
        TextView difficultyText = dialogView.findViewById(R.id.exercise_difficulty);
        TextView durationText = dialogView.findViewById(R.id.exercise_duration);
        TextView setsRepsText = dialogView.findViewById(R.id.exercise_sets_reps);
        TextView instructionsText = dialogView.findViewById(R.id.exercise_instructions);
        TextView tipsText = dialogView.findViewById(R.id.exercise_tips);
        TextView usageText = dialogView.findViewById(R.id.exercise_usage);
        
        nameText.setText(exercise.getName());
        categoryText.setText(exercise.getCategoryIcon() + " " + exercise.getCategory().getKorean());
        difficultyText.setText(exercise.getDifficultyIcon() + " " + exercise.getDifficulty().getKorean());
        durationText.setText(exercise.getFormattedDuration());
        setsRepsText.setText(exercise.getSets() + "세트 x " + exercise.getReps() + "회");
        instructionsText.setText(exercise.getInstructions());
        tipsText.setText(exercise.getTips());
        usageText.setText("사용 횟수: " + exercise.getTimesUsed() + "회");
        
        new AlertDialog.Builder(this)
            .setTitle("운동 상세 정보")
            .setView(dialogView)
            .setPositiveButton("시작", (dialog, which) -> {
                // Start workout with this exercise
                Toast.makeText(this, exercise.getName() + " 운동을 시작합니다", Toast.LENGTH_SHORT).show();
                // TODO: Navigate to workout screen with this exercise
            })
            .setNegativeButton("닫기", null)
            .show();
    }
    
    private void showEditExerciseDialog(CustomExercise exercise) {
        // Similar to create dialog but with pre-filled values
        // Implementation would be similar to showCreateExerciseDialog
        // but with exercise data pre-populated
    }
}
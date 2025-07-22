package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

import com.squashtrainingapp.R;
import com.squashtrainingapp.services.WorkoutVoiceGuide;

public class VoiceGuidedWorkoutActivity extends AppCompatActivity implements WorkoutVoiceGuide.VoiceGuideListener {
    
    private WorkoutVoiceGuide voiceGuide;
    
    // UI components
    private TextView exerciseNameText;
    private TextView setProgressText;
    private TextView statusText;
    private ProgressBar progressBar;
    private Button startButton;
    private Button pauseButton;
    private Button stopButton;
    private Button motivationButton;
    
    // Workout state
    private boolean isWorkoutActive = false;
    private boolean isPaused = false;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_voice_guided_workout);
        
        initializeViews();
        setupVoiceGuide();
        setupButtons();
        
        // Get workout parameters from intent
        String exerciseName = getIntent().getStringExtra("exercise_name");
        int sets = getIntent().getIntExtra("sets", 3);
        int reps = getIntent().getIntExtra("reps", 10);
        int restSeconds = getIntent().getIntExtra("rest_seconds", 30);
        boolean isTimeBased = getIntent().getBooleanExtra("is_time_based", false);
        int duration = getIntent().getIntExtra("duration", 30);
        
        if (exerciseName != null) {
            exerciseNameText.setText(exerciseName);
            setProgressText.setText("0/" + sets + " 세트");
        }
    }
    
    private void initializeViews() {
        exerciseNameText = findViewById(R.id.exercise_name_text);
        setProgressText = findViewById(R.id.set_progress_text);
        statusText = findViewById(R.id.status_text);
        progressBar = findViewById(R.id.workout_progress_bar);
        startButton = findViewById(R.id.start_workout_button);
        pauseButton = findViewById(R.id.pause_workout_button);
        stopButton = findViewById(R.id.stop_workout_button);
        motivationButton = findViewById(R.id.motivation_button);
        
        // Initial state
        pauseButton.setEnabled(false);
        stopButton.setEnabled(false);
        motivationButton.setEnabled(false);
    }
    
    private void setupVoiceGuide() {
        voiceGuide = new WorkoutVoiceGuide(this);
        voiceGuide.setVoiceGuideListener(this);
    }
    
    private void setupButtons() {
        startButton.setOnClickListener(v -> startWorkout());
        pauseButton.setOnClickListener(v -> togglePause());
        stopButton.setOnClickListener(v -> stopWorkout());
        motivationButton.setOnClickListener(v -> voiceGuide.provideMotivation());
    }
    
    private void startWorkout() {
        String exerciseName = getIntent().getStringExtra("exercise_name");
        int sets = getIntent().getIntExtra("sets", 3);
        int reps = getIntent().getIntExtra("reps", 10);
        int restSeconds = getIntent().getIntExtra("rest_seconds", 30);
        boolean isTimeBased = getIntent().getBooleanExtra("is_time_based", false);
        int duration = getIntent().getIntExtra("duration", 30);
        
        if (exerciseName == null) {
            exerciseName = "스쿼시 드릴";
        }
        
        isWorkoutActive = true;
        updateButtonStates();
        
        if (isTimeBased) {
            voiceGuide.startTimeBasedWorkout(exerciseName, sets, duration, restSeconds);
        } else {
            voiceGuide.startWorkout(exerciseName, sets, reps, restSeconds);
        }
    }
    
    private void togglePause() {
        if (isPaused) {
            voiceGuide.resumeWorkout();
            pauseButton.setText("일시정지");
            isPaused = false;
        } else {
            voiceGuide.pauseWorkout();
            pauseButton.setText("재개");
            isPaused = true;
        }
    }
    
    private void stopWorkout() {
        voiceGuide.stopWorkout();
        isWorkoutActive = false;
        isPaused = false;
        updateButtonStates();
        statusText.setText("운동이 중단되었습니다");
        progressBar.setProgress(0);
    }
    
    private void updateButtonStates() {
        startButton.setEnabled(!isWorkoutActive);
        pauseButton.setEnabled(isWorkoutActive);
        stopButton.setEnabled(isWorkoutActive);
        motivationButton.setEnabled(isWorkoutActive);
    }
    
    // WorkoutVoiceGuide.VoiceGuideListener implementation
    @Override
    public void onExerciseStarted(String exerciseName) {
        runOnUiThread(() -> {
            statusText.setText("운동 시작: " + exerciseName);
            progressBar.setProgress(0);
        });
    }
    
    @Override
    public void onExerciseCompleted(String exerciseName) {
        runOnUiThread(() -> {
            statusText.setText("운동 완료: " + exerciseName);
            progressBar.setProgress(100);
        });
    }
    
    @Override
    public void onSetCompleted(int setNumber, int totalSets) {
        runOnUiThread(() -> {
            setProgressText.setText(setNumber + "/" + totalSets + " 세트");
            int progress = (int) ((float) setNumber / totalSets * 100);
            progressBar.setProgress(progress);
        });
    }
    
    @Override
    public void onRestStarted(int restDuration) {
        runOnUiThread(() -> {
            statusText.setText("휴식 중... " + restDuration + "초");
        });
    }
    
    @Override
    public void onRestCompleted() {
        runOnUiThread(() -> {
            statusText.setText("휴식 완료");
        });
    }
    
    @Override
    public void onWorkoutCompleted() {
        runOnUiThread(() -> {
            isWorkoutActive = false;
            updateButtonStates();
            statusText.setText("축하합니다! 운동을 완료했습니다!");
            progressBar.setProgress(100);
        });
    }
    
    @Override
    public void onVoiceGuideError(String error) {
        runOnUiThread(() -> {
            statusText.setText("오류: " + error);
        });
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (voiceGuide != null) {
            voiceGuide.destroy();
        }
    }
}
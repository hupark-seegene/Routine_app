package com.squashtrainingapp;

import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.SeekBar;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class RecordActivity extends AppCompatActivity {
    
    // Form fields
    private EditText exerciseNameInput;
    private EditText setsInput;
    private EditText repsInput;
    private EditText durationInput;
    
    // Rating sliders
    private SeekBar intensitySlider;
    private SeekBar conditionSlider;
    private SeekBar fatigueSlider;
    private TextView intensityValue;
    private TextView conditionValue;
    private TextView fatigueValue;
    
    // Memo fields
    private EditText memoInput;
    private Button saveButton;
    
    // Tab host
    private TabHost tabHost;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_record);
        
        initializeViews();
        setupTabs();
        setupSliders();
        setupSaveButton();
    }
    
    private void initializeViews() {
        // Exercise input fields
        exerciseNameInput = findViewById(R.id.exercise_name_input);
        setsInput = findViewById(R.id.sets_input);
        repsInput = findViewById(R.id.reps_input);
        durationInput = findViewById(R.id.duration_input);
        
        // Sliders and labels
        intensitySlider = findViewById(R.id.intensity_slider);
        conditionSlider = findViewById(R.id.condition_slider);
        fatigueSlider = findViewById(R.id.fatigue_slider);
        intensityValue = findViewById(R.id.intensity_value);
        conditionValue = findViewById(R.id.condition_value);
        fatigueValue = findViewById(R.id.fatigue_value);
        
        // Memo and save
        memoInput = findViewById(R.id.memo_input);
        saveButton = findViewById(R.id.save_button);
        
        // Tab host
        tabHost = findViewById(R.id.record_tab_host);
    }
    
    private void setupTabs() {
        tabHost.setup();
        
        // Tab 1: Exercise Details
        TabHost.TabSpec exerciseTab = tabHost.newTabSpec("Exercise");
        exerciseTab.setContent(R.id.exercise_tab);
        exerciseTab.setIndicator("Exercise");
        tabHost.addTab(exerciseTab);
        
        // Tab 2: Ratings
        TabHost.TabSpec ratingsTab = tabHost.newTabSpec("Ratings");
        ratingsTab.setContent(R.id.ratings_tab);
        ratingsTab.setIndicator("Ratings");
        tabHost.addTab(ratingsTab);
        
        // Tab 3: Memo
        TabHost.TabSpec memoTab = tabHost.newTabSpec("Memo");
        memoTab.setContent(R.id.memo_tab);
        memoTab.setIndicator("Memo");
        tabHost.addTab(memoTab);
    }
    
    private void setupSliders() {
        // Intensity slider
        intensitySlider.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                intensityValue.setText(progress + "/10");
            }
            
            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}
            
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        
        // Condition slider
        conditionSlider.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                conditionValue.setText(progress + "/10");
            }
            
            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}
            
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        
        // Fatigue slider
        fatigueSlider.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                fatigueValue.setText(progress + "/10");
            }
            
            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}
            
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        
        // Set initial values
        intensitySlider.setProgress(5);
        conditionSlider.setProgress(5);
        fatigueSlider.setProgress(5);
    }
    
    private void setupSaveButton() {
        saveButton.setOnClickListener(v -> {
            saveRecord();
        });
    }
    
    private void saveRecord() {
        String exerciseName = exerciseNameInput.getText().toString();
        String sets = setsInput.getText().toString();
        String reps = repsInput.getText().toString();
        String duration = durationInput.getText().toString();
        String memo = memoInput.getText().toString();
        
        int intensity = intensitySlider.getProgress();
        int condition = conditionSlider.getProgress();
        int fatigue = fatigueSlider.getProgress();
        
        // Validation
        if (exerciseName.isEmpty()) {
            Toast.makeText(this, "Please enter exercise name", Toast.LENGTH_SHORT).show();
            return;
        }
        
        // Create record string for display
        String record = String.format(
            "Exercise: %s\nSets: %s, Reps: %s, Duration: %s\nIntensity: %d/10, Condition: %d/10, Fatigue: %d/10\nMemo: %s",
            exerciseName, sets.isEmpty() ? "-" : sets, reps.isEmpty() ? "-" : reps, duration.isEmpty() ? "-" : duration,
            intensity, condition, fatigue, memo.isEmpty() ? "No memo" : memo
        );
        
        Toast.makeText(this, "Record saved!\n" + record, Toast.LENGTH_LONG).show();
        
        // Clear form
        clearForm();
    }
    
    private void clearForm() {
        exerciseNameInput.setText("");
        setsInput.setText("");
        repsInput.setText("");
        durationInput.setText("");
        memoInput.setText("");
        intensitySlider.setProgress(5);
        conditionSlider.setProgress(5);
        fatigueSlider.setProgress(5);
        tabHost.setCurrentTab(0);
    }
}

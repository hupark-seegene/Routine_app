package com.squashtrainingapp.ui.activities;

import com.squashtrainingapp.R;
import com.squashtrainingapp.ai.ExtendedVoiceCommands;
import com.squashtrainingapp.ai.ImprovedVoiceRecognitionManager;
import com.squashtrainingapp.ai.MultilingualVoiceProcessor;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.Record;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.Locale;

public class VoiceEnabledRecordActivity extends AppCompatActivity {
    
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
    
    // Voice components
    private ImageButton voiceButton;
    private TextView voiceStatusText;
    private LinearLayout voiceOverlay;
    private ImprovedVoiceRecognitionManager voiceManager;
    private boolean isVoiceActive = false;
    
    // Tab host
    private TabHost tabHost;
    
    // Temporary storage for voice input
    private String pendingExerciseName = null;
    private Integer pendingSets = null;
    private Integer pendingReps = null;
    private Integer pendingDuration = null;
    private Integer pendingIntensity = null;
    private Integer pendingFatigue = null;
    private String pendingNote = null;
    
    private static final int PERMISSION_REQUEST_AUDIO = 1001;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_voice_record);
        
        initializeViews();
        setupTabs();
        setupSliders();
        setupSaveButton();
        setupVoiceRecognition();
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
        
        // Voice components
        voiceButton = findViewById(R.id.voice_button);
        voiceStatusText = findViewById(R.id.voice_status_text);
        voiceOverlay = findViewById(R.id.voice_overlay);
        
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
    
    private void setupVoiceRecognition() {
        voiceManager = new ImprovedVoiceRecognitionManager(this);
        voiceManager.setLanguage(Locale.KOREAN);
        voiceManager.setConfidenceThreshold(0.6f);
        
        voiceManager.setVoiceRecognitionListener(new ImprovedVoiceRecognitionManager.VoiceRecognitionListener() {
            @Override
            public void onResults(String recognizedText, float confidence) {
                processVoiceCommand(recognizedText);
                hideVoiceOverlay();
            }
            
            @Override
            public void onPartialResults(String partialText) {
                voiceStatusText.setText("들은 내용: " + partialText);
            }
            
            @Override
            public void onError(String error) {
                Toast.makeText(VoiceEnabledRecordActivity.this, error, Toast.LENGTH_SHORT).show();
                hideVoiceOverlay();
            }
            
            @Override
            public void onReadyForSpeech() {
                voiceStatusText.setText("말씀해주세요...");
            }
            
            @Override
            public void onEndOfSpeech() {
                voiceStatusText.setText("처리 중...");
            }
            
            @Override
            public void onVolumeChanged(float volume) {
                // Could update a volume indicator here
            }
            
            @Override
            public void onSpeakingStateChanged(boolean isSpeaking) {
                // Update UI if needed
            }
        });
        
        voiceButton.setOnClickListener(v -> {
            if (checkAudioPermission()) {
                toggleVoiceInput();
            } else {
                requestAudioPermission();
            }
        });
    }
    
    private void processVoiceCommand(String voiceInput) {
        // Use multilingual processor for better handling of mixed language input
        ExtendedVoiceCommands.Command command = MultilingualVoiceProcessor.processMixedLanguageCommand(voiceInput);
        
        // Adjust TTS language based on input
        Locale preferredLocale = MultilingualVoiceProcessor.detectPreferredLocale(this, voiceInput);
        voiceManager.setLanguage(preferredLocale);
        
        switch (command.type) {
            case LOG_EXERCISE:
                if (command.extras.containsKey("exercise_name")) {
                    pendingExerciseName = command.extras.get("exercise_name");
                    exerciseNameInput.setText(pendingExerciseName);
                    voiceManager.speak("운동 이름을 '" + pendingExerciseName + "'로 설정했습니다.");
                }
                break;
                
            case LOG_SETS:
                if (command.extras.containsKey("value")) {
                    pendingSets = Integer.parseInt(command.extras.get("value"));
                    setsInput.setText(String.valueOf(pendingSets));
                    voiceManager.speak(pendingSets + " 세트를 입력했습니다.");
                }
                break;
                
            case LOG_REPS:
                if (command.extras.containsKey("value")) {
                    pendingReps = Integer.parseInt(command.extras.get("value"));
                    repsInput.setText(String.valueOf(pendingReps));
                    voiceManager.speak(pendingReps + " 회를 입력했습니다.");
                }
                break;
                
            case LOG_DURATION:
                if (command.extras.containsKey("value")) {
                    int value = Integer.parseInt(command.extras.get("value"));
                    String unit = command.extras.get("unit");
                    
                    // Convert to minutes if needed
                    if ("seconds".equals(unit)) {
                        pendingDuration = value / 60;
                    } else if ("hours".equals(unit)) {
                        pendingDuration = value * 60;
                    } else {
                        pendingDuration = value;
                    }
                    
                    durationInput.setText(String.valueOf(pendingDuration));
                    voiceManager.speak(value + (unit.equals("seconds") ? "초" : unit.equals("hours") ? "시간" : "분") + "을 입력했습니다.");
                }
                break;
                
            case LOG_INTENSITY:
                if (command.extras.containsKey("value")) {
                    pendingIntensity = Integer.parseInt(command.extras.get("value"));
                    pendingIntensity = Math.min(10, Math.max(0, pendingIntensity));
                    intensitySlider.setProgress(pendingIntensity);
                    voiceManager.speak("강도를 " + pendingIntensity + "로 설정했습니다.");
                    tabHost.setCurrentTab(1); // Switch to ratings tab
                }
                break;
                
            case LOG_FATIGUE:
                if (command.extras.containsKey("value")) {
                    pendingFatigue = Integer.parseInt(command.extras.get("value"));
                    pendingFatigue = Math.min(10, Math.max(0, pendingFatigue));
                    fatigueSlider.setProgress(pendingFatigue);
                    voiceManager.speak("피로도를 " + pendingFatigue + "로 설정했습니다.");
                    tabHost.setCurrentTab(1); // Switch to ratings tab
                }
                break;
                
            case LOG_NOTE:
                if (command.extras.containsKey("note_content")) {
                    pendingNote = command.extras.get("note_content");
                    memoInput.setText(pendingNote);
                    voiceManager.speak("메모를 추가했습니다.");
                    tabHost.setCurrentTab(2); // Switch to memo tab
                }
                break;
                
            case CONFIRM:
                saveRecord();
                break;
                
            case CANCEL:
                voiceManager.speak("취소했습니다.");
                break;
                
            default:
                voiceManager.speak("운동 기록과 관련된 명령을 말씀해주세요. 예: '3세트 기록해줘', '15회 했어', '30분 운동했어'");
        }
    }
    
    private void toggleVoiceInput() {
        if (isVoiceActive) {
            voiceManager.stopListening();
            hideVoiceOverlay();
        } else {
            voiceManager.startListening();
            showVoiceOverlay();
        }
        isVoiceActive = !isVoiceActive;
    }
    
    private void showVoiceOverlay() {
        voiceOverlay.setVisibility(View.VISIBLE);
        voiceButton.setImageResource(R.drawable.ic_mic_off);
    }
    
    private void hideVoiceOverlay() {
        voiceOverlay.setVisibility(View.GONE);
        voiceButton.setImageResource(R.drawable.ic_mic);
        isVoiceActive = false;
    }
    
    private boolean checkAudioPermission() {
        return ContextCompat.checkSelfPermission(this, 
                Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED;
    }
    
    private void requestAudioPermission() {
        ActivityCompat.requestPermissions(this,
                new String[]{Manifest.permission.RECORD_AUDIO},
                PERMISSION_REQUEST_AUDIO);
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_AUDIO) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                toggleVoiceInput();
            } else {
                Toast.makeText(this, "음성 인식을 사용하려면 마이크 권한이 필요합니다.", Toast.LENGTH_LONG).show();
            }
        }
    }
    
    private void saveRecord() {
        String exerciseName = exerciseNameInput.getText().toString().trim();
        String setsText = setsInput.getText().toString().trim();
        String repsText = repsInput.getText().toString().trim();
        String durationText = durationInput.getText().toString().trim();
        String memo = memoInput.getText().toString().trim();
        
        if (exerciseName.isEmpty()) {
            Toast.makeText(this, "운동 이름을 입력해주세요", Toast.LENGTH_SHORT).show();
            return;
        }
        
        int sets = setsText.isEmpty() ? 0 : Integer.parseInt(setsText);
        int reps = repsText.isEmpty() ? 0 : Integer.parseInt(repsText);
        int duration = durationText.isEmpty() ? 0 : Integer.parseInt(durationText);
        int intensity = intensitySlider.getProgress();
        int condition = conditionSlider.getProgress();
        int fatigue = fatigueSlider.getProgress();
        
        // Save to database
        DatabaseHelper dbHelper = DatabaseHelper.getInstance(this);
        Record record = new Record(exerciseName, sets, reps, duration, intensity, condition, fatigue, memo);
        long recordId = dbHelper.getRecordDao().insert(record);
        
        // Update user stats
        dbHelper.getUserDao().updateAfterWorkout(duration);
        
        if (recordId > 0) {
            voiceManager.speak("운동이 성공적으로 저장되었습니다!");
            Toast.makeText(this, "운동이 저장되었습니다!", Toast.LENGTH_LONG).show();
            
            // Clear form
            clearForm();
            
            // Go back to first tab
            tabHost.setCurrentTab(0);
        } else {
            Toast.makeText(this, "저장 중 오류가 발생했습니다", Toast.LENGTH_SHORT).show();
        }
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
        
        // Clear pending values
        pendingExerciseName = null;
        pendingSets = null;
        pendingReps = null;
        pendingDuration = null;
        pendingIntensity = null;
        pendingFatigue = null;
        pendingNote = null;
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (voiceManager != null) {
            voiceManager.destroy();
        }
    }
}
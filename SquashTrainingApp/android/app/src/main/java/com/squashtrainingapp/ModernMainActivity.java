package com.squashtrainingapp;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.squashtrainingapp.ai.AIChatbotActivity;
import com.squashtrainingapp.ai.ImprovedAIResponseEngine;
import com.squashtrainingapp.ai.VoiceRecognitionManager;
import com.squashtrainingapp.ui.activities.ChecklistActivity;
import com.squashtrainingapp.ui.activities.CoachActivity;
import com.squashtrainingapp.ui.activities.ProfileActivity;
import com.squashtrainingapp.ui.activities.RecordActivity;
import com.squashtrainingapp.ui.activities.SettingsActivity;
import com.squashtrainingapp.mascot.AnimatedMascotView;
import android.view.ViewGroup;
import android.view.LayoutInflater;

public class ModernMainActivity extends AppCompatActivity implements 
        VoiceRecognitionManager.VoiceRecognitionListener {
    
    private static final int PERMISSION_REQUEST_RECORD_AUDIO = 1001;
    
    private TextView dailyTipText;
    private FloatingActionButton voiceFab;
    private VoiceRecognitionManager voiceManager;
    private ImprovedAIResponseEngine aiEngine;
    private AnimatedMascotView animatedMascot;
    private ViewGroup floatingMascotContainer;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_modern);
        
        setupToolbar();
        setupViews();
        setupBottomNavigation();
        setupVoiceFeatures();
        setupFloatingMascot();
        loadDailyTip();
    }
    
    private void setupToolbar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
    }
    
    private void setupViews() {
        dailyTipText = findViewById(R.id.daily_tip_text);
        voiceFab = findViewById(R.id.voice_fab);
        
        Button quickWorkoutButton = findViewById(R.id.quick_workout_button);
        Button aiCoachButton = findViewById(R.id.ai_coach_button);
        
        quickWorkoutButton.setOnClickListener(v -> {
            Intent intent = new Intent(this, RecordActivity.class);
            startActivity(intent);
        });
        
        aiCoachButton.setOnClickListener(v -> {
            Intent intent = new Intent(this, AIChatbotActivity.class);
            startActivity(intent);
        });
        
        voiceFab.setOnClickListener(v -> {
            if (checkVoicePermission()) {
                startVoiceCommand();
            }
        });
    }
    
    private void setupBottomNavigation() {
        BottomNavigationView bottomNav = findViewById(R.id.bottom_navigation);
        bottomNav.setSelectedItemId(R.id.navigation_home);
        
        bottomNav.setOnNavigationItemSelectedListener(item -> {
            int itemId = item.getItemId();
            
            if (itemId == R.id.navigation_home) {
                // Already on home
                return true;
            } else if (itemId == R.id.navigation_checklist) {
                startActivity(new Intent(this, ChecklistActivity.class));
                return true;
            } else if (itemId == R.id.navigation_record) {
                startActivity(new Intent(this, RecordActivity.class));
                return true;
            } else if (itemId == R.id.navigation_profile) {
                startActivity(new Intent(this, ProfileActivity.class));
                return true;
            } else if (itemId == R.id.navigation_coach) {
                startActivity(new Intent(this, CoachActivity.class));
                return true;
            }
            
            return false;
        });
    }
    
    private void setupVoiceFeatures() {
        aiEngine = new ImprovedAIResponseEngine(this);
        
        if (ContextCompat.checkSelfPermission(this, 
                Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
            voiceManager = new VoiceRecognitionManager(this);
            voiceManager.setVoiceRecognitionListener(this);
        }
    }
    
    private boolean checkVoicePermission() {
        if (ContextCompat.checkSelfPermission(this, 
                Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    PERMISSION_REQUEST_RECORD_AUDIO);
            return false;
        }
        return true;
    }
    
    private void startVoiceCommand() {
        if (voiceManager != null) {
            voiceManager.startListening();
            voiceFab.setImageResource(R.drawable.ic_mic_active);
        }
    }
    
    private void setupFloatingMascot() {
        // Inflate floating mascot overlay
        LayoutInflater inflater = LayoutInflater.from(this);
        floatingMascotContainer = (ViewGroup) inflater.inflate(
            R.layout.floating_mascot_overlay, null
        );
        
        animatedMascot = floatingMascotContainer.findViewById(R.id.animated_mascot);
        
        // Add click listener to mascot
        animatedMascot.setOnClickListener(v -> {
            // Start voice command when mascot is clicked
            if (checkVoicePermission()) {
                startVoiceCommand();
                animatedMascot.startListeningAnimation();
            }
        });
        
        // Add mascot to the root view
        ViewGroup rootView = findViewById(android.R.id.content);
        rootView.addView(floatingMascotContainer);
    }
    
    private void loadDailyTip() {
        // Get a random tip from the AI engine
        String[] tips = {
            "Focus on your footwork today. Good movement is the foundation of great squash!",
            "Practice your serves - consistency in serving can give you a huge advantage.",
            "Watch the front wall, not your opponent. This helps you track the ball better.",
            "Stay hydrated! Drink water before, during, and after your matches.",
            "Work on your T-position recovery. Always return to the center after your shot."
        };
        
        int randomIndex = (int) (Math.random() * tips.length);
        dailyTipText.setText(tips[randomIndex]);
    }
    
    // VoiceRecognitionListener methods
    @Override
    public void onResults(String recognizedText) {
        voiceFab.setImageResource(R.drawable.ic_mic);
        if (animatedMascot != null) {
            animatedMascot.stopListeningAnimation();
        }
        processVoiceCommand(recognizedText);
    }
    
    @Override
    public void onError(String error) {
        voiceFab.setImageResource(R.drawable.ic_mic);
        if (animatedMascot != null) {
            animatedMascot.stopListeningAnimation();
        }
        Toast.makeText(this, getString(R.string.voice_error, error), Toast.LENGTH_SHORT).show();
    }
    
    @Override
    public void onReadyForSpeech() {
        // Voice recognition ready
    }
    
    @Override
    public void onEndOfSpeech() {
        voiceFab.setImageResource(R.drawable.ic_mic);
        if (animatedMascot != null) {
            animatedMascot.stopListeningAnimation();
        }
    }
    
    private void processVoiceCommand(String command) {
        String lowerCommand = command.toLowerCase();
        
        if (lowerCommand.contains("profile") || lowerCommand.contains("프로필")) {
            startActivity(new Intent(this, ProfileActivity.class));
        } else if (lowerCommand.contains("checklist") || lowerCommand.contains("체크리스트")) {
            startActivity(new Intent(this, ChecklistActivity.class));
        } else if (lowerCommand.contains("record") || lowerCommand.contains("기록")) {
            startActivity(new Intent(this, RecordActivity.class));
        } else if (lowerCommand.contains("coach") || lowerCommand.contains("코치")) {
            startActivity(new Intent(this, CoachActivity.class));
        } else if (lowerCommand.contains("chat") || lowerCommand.contains("채팅")) {
            startActivity(new Intent(this, AIChatbotActivity.class));
        } else if (lowerCommand.contains("settings") || lowerCommand.contains("설정")) {
            startActivity(new Intent(this, SettingsActivity.class));
        } else {
            // If no navigation command, open AI chat with the question
            Intent intent = new Intent(this, AIChatbotActivity.class);
            intent.putExtra("initial_message", command);
            startActivity(intent);
        }
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_RECORD_AUDIO) {
            if (grantResults.length > 0 && 
                    grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                setupVoiceFeatures();
                Toast.makeText(this, getString(R.string.voice_commands_enabled), 
                        Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, getString(R.string.voice_commands_disabled), 
                        Toast.LENGTH_LONG).show();
            }
        }
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (voiceManager != null) {
            voiceManager.destroy();
        }
    }
}
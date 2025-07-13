package com.squashtrainingapp;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.squashtrainingapp.mascot.MascotView;
import com.squashtrainingapp.mascot.DragHandler;
import com.squashtrainingapp.mascot.ZoneManager;
import com.squashtrainingapp.mascot.AnimationController;
import com.squashtrainingapp.ai.VoiceRecognitionManager;
import com.squashtrainingapp.ai.VoiceCommands;
import com.squashtrainingapp.ai.AIChatbotActivity;
import com.squashtrainingapp.ui.activities.ChecklistActivity;
import com.squashtrainingapp.ui.activities.RecordActivity;
import com.squashtrainingapp.ui.activities.ProfileActivity;
import com.squashtrainingapp.ui.activities.CoachActivity;
import com.squashtrainingapp.ui.activities.HistoryActivity;
import com.squashtrainingapp.ui.activities.SettingsActivity;

public class MainActivity extends AppCompatActivity implements 
        MascotView.OnMascotInteractionListener,
        DragHandler.OnZoneChangeListener,
        VoiceRecognitionManager.VoiceRecognitionListener {
    
    private static final int PERMISSION_REQUEST_RECORD_AUDIO = 1;
    
    private MascotView mascotView;
    private ZoneManager zoneManager;
    private AnimationController animationController;
    private VoiceRecognitionManager voiceManager;
    private DragHandler dragHandler;
    
    private boolean isVoiceActive = false;
    private Handler navigationHandler = new Handler();
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_mascot);
        
        initializeViews();
        setupMascot();
        setupVoiceRecognition();
        checkPermissions();
        
        // Show welcome message
        showToast("Welcome! Drag me to any zone or hold me for 2 seconds to talk!");
    }
    
    private void initializeViews() {
        mascotView = findViewById(R.id.mascot_view);
        zoneManager = findViewById(R.id.zone_manager);
    }
    
    private void setupMascot() {
        // Set up mascot interaction listener
        mascotView.setOnMascotInteractionListener(this);
        
        // Get drag handler from zone manager
        dragHandler = zoneManager.getDragHandler();
        dragHandler.setOnZoneChangeListener(this);
        
        // Create animation controller for mascot
        animationController = new AnimationController(mascotView);
        animationController.startIdleBounce();
    }
    
    private void setupVoiceRecognition() {
        voiceManager = new VoiceRecognitionManager(this);
        voiceManager.setVoiceRecognitionListener(this);
    }
    
    private void checkPermissions() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    PERMISSION_REQUEST_RECORD_AUDIO);
        }
    }
    
    // MascotView.OnMascotInteractionListener methods
    @Override
    public void onMascotDragged(float x, float y) {
        dragHandler.updatePosition(x, y);
    }
    
    @Override
    public void onMascotReleased(float x, float y) {
        dragHandler.handleRelease(x, y);
    }
    
    @Override
    public void onMascotLongPress() {
        if (!isVoiceActive) {
            startVoiceRecognition();
        }
    }
    
    @Override
    public void onMascotTapped() {
        animationController.startWiggleAnimation();
        showToast("Drag me to a zone or hold me to talk!");
    }
    
    // DragHandler.OnZoneChangeListener methods
    @Override
    public void onZoneEntered(String zoneName) {
        zoneManager.highlightZone(zoneName);
        animationController.startZoneEnterAnimation();
    }
    
    @Override
    public void onZoneExited(String zoneName) {
        zoneManager.clearHighlight();
    }
    
    @Override
    public void onZoneActivated(String zoneName) {
        animationController.startReleaseAnimation();
        navigateToZone(zoneName);
    }
    
    private void navigateToZone(String zoneName) {
        // Add slight delay for animation
        navigationHandler.postDelayed(() -> {
            Intent intent = null;
            
            switch (zoneName) {
                case "profile":
                    intent = new Intent(this, ProfileActivity.class);
                    break;
                case "checklist":
                    intent = new Intent(this, ChecklistActivity.class);
                    break;
                case "record":
                    intent = new Intent(this, RecordActivity.class);
                    break;
                case "history":
                    intent = new Intent(this, HistoryActivity.class);
                    break;
                case "coach":
                    intent = new Intent(this, CoachActivity.class);
                    break;
                case "settings":
                    if (SettingsActivity.class != null) {
                        intent = new Intent(this, SettingsActivity.class);
                    } else {
                        showToast("Settings coming soon!");
                        return;
                    }
                    break;
            }
            
            if (intent != null) {
                startActivity(intent);
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            }
        }, 300);
    }
    
    private void startVoiceRecognition() {
        isVoiceActive = true;
        voiceManager.startListening();
        showToast("Listening... Say a command!");
    }
    
    // VoiceRecognitionListener methods
    @Override
    public void onResults(String recognizedText) {
        isVoiceActive = false;
        
        // Parse the voice command
        VoiceCommands.Command command = VoiceCommands.parseCommand(recognizedText);
        
        if (command.type != VoiceCommands.CommandType.UNKNOWN) {
            handleVoiceCommand(command);
        } else {
            // Open AI chatbot for natural conversation
            Intent intent = new Intent(this, AIChatbotActivity.class);
            intent.putExtra("initial_message", recognizedText);
            startActivity(intent);
        }
    }
    
    @Override
    public void onError(String error) {
        isVoiceActive = false;
        showToast("Voice error: " + error);
    }
    
    @Override
    public void onReadyForSpeech() {
        // Voice recognition ready
    }
    
    @Override
    public void onEndOfSpeech() {
        // Speech ended
    }
    
    private void handleVoiceCommand(VoiceCommands.Command command) {
        String response = VoiceCommands.getResponseForCommand(command);
        voiceManager.speak(response);
        
        switch (command.type) {
            case NAVIGATE_PROFILE:
                navigateToZone("profile");
                break;
            case NAVIGATE_CHECKLIST:
                navigateToZone("checklist");
                break;
            case NAVIGATE_RECORD:
                navigateToZone("record");
                break;
            case NAVIGATE_HISTORY:
                navigateToZone("history");
                break;
            case NAVIGATE_COACH:
                navigateToZone("coach");
                break;
            case NAVIGATE_SETTINGS:
                navigateToZone("settings");
                break;
            default:
                // Open AI chatbot for other commands
                Intent intent = new Intent(this, AIChatbotActivity.class);
                startActivity(intent);
                break;
        }
    }
    
    private void showToast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        
        if (requestCode == PERMISSION_REQUEST_RECORD_AUDIO) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted
            } else {
                showToast("Voice recognition requires microphone permission");
            }
        }
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (voiceManager != null) {
            voiceManager.destroy();
        }
        if (animationController != null) {
            animationController.stopCurrentAnimation();
        }
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        if (animationController != null) {
            animationController.startIdleBounce();
        }
    }
    
    @Override
    protected void onPause() {
        super.onPause();
        if (animationController != null) {
            animationController.stopCurrentAnimation();
        }
    }
}
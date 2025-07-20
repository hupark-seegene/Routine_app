package com.squashtrainingapp;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.squashtrainingapp.ai.VoiceRecognitionManager;
import com.squashtrainingapp.ai.VoiceCommands;
import com.squashtrainingapp.mascot.MascotView;
import com.squashtrainingapp.mascot.ZoneManager;
import com.squashtrainingapp.ui.activities.*;

public class MainActivity extends Activity implements 
        MascotView.OnMascotInteractionListener,
        VoiceRecognitionManager.VoiceRecognitionListener {
    
    private static final String TAG = "MainActivity";
    private static final int PERMISSION_REQUEST_RECORD_AUDIO = 1001;
    private static final long LONG_PRESS_DURATION = 2000; // 2 seconds
    
    private MascotView mascotView;
    private ZoneManager zoneManager;
    private VoiceRecognitionManager voiceManager;
    // VoiceCommands uses static methods
    
    // Voice overlay views
    private RelativeLayout voiceOverlay;
    private TextView voiceStatusText;
    private TextView recognizedText;
    
    // Long press detection
    private Handler longPressHandler;
    private Runnable longPressRunnable;
    private boolean isLongPressing = false;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_mascot);
        
        initializeViews();
        setupMascotInteraction();
        checkAudioPermission(); // This will setup voice recognition if permission granted
    }
    
    private void initializeViews() {
        mascotView = findViewById(R.id.mascot_view);
        zoneManager = findViewById(R.id.zone_manager);
        
        // Voice overlay views
        voiceOverlay = findViewById(R.id.voice_overlay);
        voiceStatusText = findViewById(R.id.voice_status_text);
        recognizedText = findViewById(R.id.recognized_text);
        
        // Cancel voice button
        View cancelVoice = findViewById(R.id.cancel_voice);
        if (cancelVoice != null) {
            cancelVoice.setOnClickListener(v -> hideVoiceOverlay());
        }
        
        // Set mascot listener
        if (mascotView != null) {
            mascotView.setOnMascotInteractionListener(this);
        }
        
        longPressHandler = new Handler();
    }
    
    private void checkAudioPermission() {
        if (ContextCompat.checkSelfPermission(this, 
                Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    PERMISSION_REQUEST_RECORD_AUDIO);
        } else {
            // Permission already granted, setup voice recognition
            setupVoiceRecognition();
        }
    }
    
    private void setupMascotInteraction() {
        if (mascotView == null) return;
        
        mascotView.setOnTouchListener(new View.OnTouchListener() {
            private float startX, startY;
            private long touchStartTime;
            
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        startX = event.getX();
                        startY = event.getY();
                        touchStartTime = System.currentTimeMillis();
                        
                        // Start long press detection
                        isLongPressing = false;
                        longPressRunnable = new Runnable() {
                            @Override
                            public void run() {
                                isLongPressing = true;
                                activateVoiceRecognition();
                            }
                        };
                        longPressHandler.postDelayed(longPressRunnable, LONG_PRESS_DURATION);
                        
                        return mascotView.onTouchEvent(event);
                        
                    case MotionEvent.ACTION_MOVE:
                        // Cancel long press if user moves too much
                        float deltaX = Math.abs(event.getX() - startX);
                        float deltaY = Math.abs(event.getY() - startY);
                        if (deltaX > 50 || deltaY > 50) {
                            cancelLongPress();
                        }
                        return mascotView.onTouchEvent(event);
                        
                    case MotionEvent.ACTION_UP:
                    case MotionEvent.ACTION_CANCEL:
                        cancelLongPress();
                        return mascotView.onTouchEvent(event);
                }
                return false;
            }
        });
    }
    
    private void cancelLongPress() {
        if (longPressRunnable != null) {
            longPressHandler.removeCallbacks(longPressRunnable);
            longPressRunnable = null;
        }
        isLongPressing = false;
    }
    
    private void setupVoiceRecognition() {
        // Only setup if we have permission
        if (ContextCompat.checkSelfPermission(this, 
                Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
            voiceManager = new VoiceRecognitionManager(this);
            voiceManager.setVoiceRecognitionListener(this);
            Log.d(TAG, "Voice recognition initialized");
        } else {
            Log.d(TAG, "Voice recognition not initialized - no permission");
        }
        
        // VoiceCommands uses static methods, no initialization needed
    }
    
    private void activateVoiceRecognition() {
        Log.d(TAG, "Activating voice recognition");
        
        // Check permission first
        if (ContextCompat.checkSelfPermission(this, 
                Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            Log.d(TAG, "No audio permission - requesting");
            // Request permission if not granted
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    PERMISSION_REQUEST_RECORD_AUDIO);
            return;
        }
        
        // Always show overlay first
        showVoiceOverlay();
        
        // If we have permission and voice manager is initialized
        if (voiceManager != null) {
            Log.d(TAG, "Starting voice listening");
            voiceManager.startListening();
        } else {
            Log.d(TAG, "Voice manager not initialized - setting up");
            // Try to initialize voice manager
            setupVoiceRecognition();
            if (voiceManager != null) {
                Log.d(TAG, "Voice manager initialized - starting listening");
                voiceManager.startListening();
            } else {
                Log.e(TAG, "Failed to initialize voice manager");
                voiceStatusText.setText(getString(R.string.voice_recognition_not_available));
                new Handler().postDelayed(this::hideVoiceOverlay, 2000);
            }
        }
    }
    
    private void showVoiceOverlay() {
        if (voiceOverlay != null) {
            Log.d(TAG, "Showing voice overlay");
            voiceOverlay.setVisibility(View.VISIBLE);
            voiceStatusText.setText(getString(R.string.listening));
            recognizedText.setText("");
            
            // Start voice wave animation
            com.squashtrainingapp.ui.widgets.VoiceWaveView waveView = 
                voiceOverlay.findViewById(R.id.voice_wave_view);
            if (waveView != null) {
                waveView.startAnimation();
            }
        } else {
            Log.e(TAG, "Voice overlay is null!");
        }
    }
    
    private void hideVoiceOverlay() {
        if (voiceOverlay != null) {
            Log.d(TAG, "Hiding voice overlay");
            voiceOverlay.setVisibility(View.GONE);
            
            // Stop voice wave animation
            com.squashtrainingapp.ui.widgets.VoiceWaveView waveView = 
                voiceOverlay.findViewById(R.id.voice_wave_view);
            if (waveView != null) {
                waveView.stopAnimation();
            }
        }
        if (voiceManager != null) {
            voiceManager.stopListening();
        }
    }
    
    // MascotView.OnMascotInteractionListener implementation
    @Override
    public void onMascotDragged(float x, float y) {
        // Update zone highlighting in ZoneManager
        if (zoneManager != null) {
            zoneManager.updateMascotPosition(x, y);
            
            // Get the current zone and highlight it
            String currentZone = zoneManager.checkZoneAtPosition(x, y);
            if (currentZone != null) {
                zoneManager.highlightZone(currentZone);
                
                // Notify mascot it's in a zone for visual feedback
                if (mascotView != null) {
                    mascotView.setInZone(true);
                }
            } else {
                zoneManager.clearHighlight();
                
                // Notify mascot it's not in a zone
                if (mascotView != null) {
                    mascotView.setInZone(false);
                }
            }
        }
    }
    
    @Override
    public void onMascotReleased(float x, float y) {
        // Clear zone highlighting
        if (zoneManager != null) {
            zoneManager.clearHighlight();
            
            // Check if mascot was released in a zone
            String zone = zoneManager.checkZoneAtPosition(x, y);
            if (zone != null) {
                Log.d(TAG, "Mascot released in zone: " + zone);
                
                // Provide visual confirmation before navigation
                String enteringText = getString(R.string.entering_zone, zone.toUpperCase());
                Toast.makeText(this, enteringText, 
                        Toast.LENGTH_SHORT).show();
                
                navigateToZone(zone);
            }
        }
        
        // Always clear the zone state for mascot
        if (mascotView != null) {
            mascotView.setInZone(false);
        }
    }
    
    @Override
    public void onMascotLongPress() {
        // Long press already handled in touch listener
        Log.d(TAG, "Mascot long press detected");
    }
    
    @Override
    public void onMascotTapped() {
        if (!isLongPressing) {
            // Short tap - show enhanced hint with zone instructions
            if (zoneManager != null) {
                zoneManager.toggleInstructions();
            }
            
            Toast.makeText(this, getString(R.string.drag_hint_extended), 
                    Toast.LENGTH_LONG).show();
        }
    }
    
    private void navigateToZone(String zoneName) {
        // Always hide voice overlay before navigating
        hideVoiceOverlay();
        
        Intent intent = null;
        
        switch (zoneName.toLowerCase()) {
            case "profile":
                intent = new Intent(this, ProfileActivity.class);
                break;
            case "checklist":
                intent = new Intent(this, ChecklistActivity.class);
                break;
            case "coach":
            case "ai coach":
                intent = new Intent(this, CoachActivity.class);
                break;
            case "record":
                intent = new Intent(this, RecordActivity.class);
                break;
            case "history":
                intent = new Intent(this, HistoryActivity.class);
                break;
            case "settings":
                intent = new Intent(this, SettingsActivity.class);
                break;
        }
        
        if (intent != null) {
            startActivity(intent);
            // Add slide animation when navigating to new activity
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        }
    }
    
    // VoiceRecognitionManager.VoiceRecognitionListener implementation
    @Override
    public void onResults(String recognizedText) {
        Log.d(TAG, "Voice recognized: " + recognizedText);
        this.recognizedText.setText(recognizedText);
        
        // Process voice command using static methods
        VoiceCommands.Command command = VoiceCommands.parseCommand(recognizedText);
        String response = VoiceCommands.getResponseForCommand(this, command);
        
        // Handle navigation commands
        switch (command.type) {
            case NAVIGATE_PROFILE:
                hideVoiceOverlay();
                navigateToZone("profile");
                break;
            case NAVIGATE_CHECKLIST:
                hideVoiceOverlay();
                navigateToZone("checklist");
                break;
            case NAVIGATE_COACH:
                hideVoiceOverlay();
                navigateToZone("coach");
                break;
            case NAVIGATE_RECORD:
                hideVoiceOverlay();
                navigateToZone("record");
                break;
            case NAVIGATE_HISTORY:
                hideVoiceOverlay();
                navigateToZone("history");
                break;
            case NAVIGATE_SETTINGS:
                hideVoiceOverlay();
                navigateToZone("settings");
                break;
            default:
                // Show response
                voiceStatusText.setText(response);
                voiceManager.speak(response);
                // Hide overlay after response
                new Handler().postDelayed(this::hideVoiceOverlay, 3000);
                break;
        }
    }
    
    @Override
    public void onError(String error) {
        Log.e(TAG, "Voice recognition error: " + error);
        
        // If overlay is visible, update status text
        if (voiceOverlay != null && voiceOverlay.getVisibility() == View.VISIBLE) {
            if (error.contains("permissions")) {
                voiceStatusText.setText(getString(R.string.audio_permission_required));
            } else if (error.contains("No match")) {
                voiceStatusText.setText(getString(R.string.no_speech_detected));
            } else if (error.contains("Network")) {
                voiceStatusText.setText(getString(R.string.network_error_try_again));
            } else {
                voiceStatusText.setText(getString(R.string.voice_error, error));
            }
            
            // Hide overlay after showing error
            new Handler().postDelayed(this::hideVoiceOverlay, 2000);
        } else if (error.contains("permissions")) {
            // Permission error without overlay - request permissions
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    PERMISSION_REQUEST_RECORD_AUDIO);
        } else {
            // Other errors - show toast
            Toast.makeText(this, getString(R.string.voice_error, error), Toast.LENGTH_SHORT).show();
        }
    }
    
    @Override
    public void onReadyForSpeech() {
        Log.d(TAG, "Voice ready for speech");
        if (voiceStatusText != null) {
            voiceStatusText.setText(getString(R.string.speak_now));
        }
    }
    
    @Override
    public void onEndOfSpeech() {
        Log.d(TAG, "Voice end of speech");
        if (voiceStatusText != null) {
            voiceStatusText.setText(getString(R.string.processing));
        }
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, 
            int[] grantResults) {
        if (requestCode == PERMISSION_REQUEST_RECORD_AUDIO) {
            if (grantResults.length > 0 && 
                    grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "Audio permission granted");
                // Setup voice recognition now that we have permission
                setupVoiceRecognition();
                Toast.makeText(this, 
                        getString(R.string.voice_commands_enabled), 
                        Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, 
                        getString(R.string.voice_commands_disabled), 
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
        if (longPressHandler != null && longPressRunnable != null) {
            longPressHandler.removeCallbacks(longPressRunnable);
        }
    }
}
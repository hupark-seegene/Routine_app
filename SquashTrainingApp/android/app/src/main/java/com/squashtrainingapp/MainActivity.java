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
        // Check permission first
        if (ContextCompat.checkSelfPermission(this, 
                Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            // Request permission if not granted
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    PERMISSION_REQUEST_RECORD_AUDIO);
            return;
        }
        
        // If we have permission and voice manager is initialized
        if (voiceManager != null) {
            showVoiceOverlay();
            voiceManager.startListening();
        } else {
            // Try to initialize voice manager
            setupVoiceRecognition();
            if (voiceManager != null) {
                showVoiceOverlay();
                voiceManager.startListening();
            }
        }
    }
    
    private void showVoiceOverlay() {
        if (voiceOverlay != null) {
            voiceOverlay.setVisibility(View.VISIBLE);
            voiceStatusText.setText("Listening...");
            recognizedText.setText("");
        }
    }
    
    private void hideVoiceOverlay() {
        if (voiceOverlay != null) {
            voiceOverlay.setVisibility(View.GONE);
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
        }
    }
    
    @Override
    public void onMascotReleased(float x, float y) {
        // Check if mascot was released in a zone
        if (zoneManager != null) {
            String zone = zoneManager.checkZoneAtPosition(x, y);
            if (zone != null) {
                Log.d(TAG, "Mascot released in zone: " + zone);
                navigateToZone(zone);
            }
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
            // Short tap - show hint
            Toast.makeText(this, "Drag me to a zone or hold me to talk!", 
                    Toast.LENGTH_SHORT).show();
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
        }
    }
    
    // VoiceRecognitionManager.VoiceRecognitionListener implementation
    @Override
    public void onResults(String recognizedText) {
        Log.d(TAG, "Voice recognized: " + recognizedText);
        this.recognizedText.setText(recognizedText);
        
        // Process voice command using static methods
        VoiceCommands.Command command = VoiceCommands.parseCommand(recognizedText);
        String response = VoiceCommands.getResponseForCommand(command);
        
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
        // Don't show overlay for permission errors
        if (!error.contains("permissions")) {
            voiceStatusText.setText("Error: " + error);
            showVoiceOverlay();
            new Handler().postDelayed(this::hideVoiceOverlay, 2000);
        } else {
            // Just log permission errors
            Log.w(TAG, "Voice permissions not granted");
        }
    }
    
    @Override
    public void onReadyForSpeech() {
        voiceStatusText.setText("Speak now...");
    }
    
    @Override
    public void onEndOfSpeech() {
        voiceStatusText.setText("Processing...");
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
                        "Voice commands enabled! Hold the mascot to speak", 
                        Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, 
                        "Voice commands disabled. You can still use all other features", 
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
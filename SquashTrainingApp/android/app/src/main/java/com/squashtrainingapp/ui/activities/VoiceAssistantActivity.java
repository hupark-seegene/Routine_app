package com.squashtrainingapp.ui.activities;

import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.speech.RecognizerIntent;
import android.view.View;
import android.view.WindowManager;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.squashtrainingapp.R;
import com.squashtrainingapp.ai.VoiceRecognitionManager;
import com.squashtrainingapp.ai.AIResponseEngine;
import com.squashtrainingapp.ai.ImprovedAIResponseEngine;
import com.squashtrainingapp.ui.views.CircularPulseButton;
import com.squashtrainingapp.ui.views.WaveformView;

import java.util.Locale;

public class VoiceAssistantActivity extends AppCompatActivity implements 
        VoiceRecognitionManager.VoiceRecognitionListener,
        AIResponseEngine.AIResponseListener {
    
    private static final int RECORD_AUDIO_PERMISSION_REQUEST = 1001;
    private static final long RESPONSE_DISPLAY_DURATION = 5000; // 5 seconds
    
    private CircularPulseButton voiceButton;
    private WaveformView waveformView;
    private TextView statusText;
    private TextView responseText;
    private View backgroundGradient;
    
    private VoiceRecognitionManager voiceManager;
    private AIResponseEngine aiEngine;
    private Handler uiHandler;
    
    private boolean isListening = false;
    private boolean isProcessing = false;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Set fullscreen and dark status bar
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
        getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE |
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
                View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
        
        setContentView(R.layout.activity_voice_assistant);
        
        initializeViews();
        setupAIEngine();
        checkPermissions();
        
        uiHandler = new Handler(Looper.getMainLooper());
    }
    
    private void initializeViews() {
        voiceButton = findViewById(R.id.voice_button);
        waveformView = findViewById(R.id.waveform_view);
        statusText = findViewById(R.id.status_text);
        responseText = findViewById(R.id.response_text);
        backgroundGradient = findViewById(R.id.background_gradient);
        
        // Settings button
        View settingsButton = findViewById(R.id.settings_button);
        settingsButton.setOnClickListener(v -> openSettings());
        
        // Close button
        View closeButton = findViewById(R.id.close_button);
        closeButton.setOnClickListener(v -> finish());
        
        voiceButton.setOnClickListener(v -> toggleListening());
        
        // Set initial states
        waveformView.setVisibility(View.INVISIBLE);
        responseText.setAlpha(0f);
    }
    
    private void setupAIEngine() {
        aiEngine = new ImprovedAIResponseEngine(this);
        aiEngine.setAIResponseListener(this);
    }
    
    private void checkPermissions() {
        if (ContextCompat.checkSelfPermission(this, 
                Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    RECORD_AUDIO_PERMISSION_REQUEST);
        } else {
            setupVoiceRecognition();
        }
    }
    
    private void setupVoiceRecognition() {
        voiceManager = new VoiceRecognitionManager(this);
        voiceManager.setVoiceRecognitionListener(this);
        voiceManager.setLanguage(Locale.KOREAN); // Support Korean
    }
    
    private void toggleListening() {
        if (isProcessing) return;
        
        if (isListening) {
            stopListening();
        } else {
            startListening();
        }
    }
    
    private void startListening() {
        if (voiceManager == null) {
            Toast.makeText(this, R.string.voice_input_not_available, Toast.LENGTH_SHORT).show();
            return;
        }
        
        isListening = true;
        voiceButton.startPulseAnimation();
        
        // Show waveform with animation
        waveformView.setVisibility(View.VISIBLE);
        waveformView.setAlpha(0f);
        waveformView.animate()
                .alpha(1f)
                .setDuration(300)
                .start();
        waveformView.startAnimation();
        
        statusText.setText(R.string.listening);
        
        // Clear previous response
        fadeOutResponse();
        
        voiceManager.startListening();
    }
    
    private void stopListening() {
        isListening = false;
        voiceButton.stopPulseAnimation();
        
        // Hide waveform with animation
        waveformView.animate()
                .alpha(0f)
                .setDuration(300)
                .withEndAction(() -> {
                    waveformView.setVisibility(View.INVISIBLE);
                    waveformView.stopAnimation();
                })
                .start();
        
        statusText.setText("");
        
        if (voiceManager != null) {
            voiceManager.stopListening();
        }
    }
    
    private void showThinking() {
        isProcessing = true;
        voiceButton.startRotationAnimation();
        statusText.setText(R.string.processing);
    }
    
    private void hideThinking() {
        isProcessing = false;
        voiceButton.stopRotationAnimation();
        statusText.setText("");
    }
    
    private void showResponse(String response) {
        responseText.setText(response);
        responseText.animate()
                .alpha(1f)
                .setDuration(500)
                .start();
        
        // Auto-hide response after delay
        uiHandler.postDelayed(this::fadeOutResponse, RESPONSE_DISPLAY_DURATION);
    }
    
    private void fadeOutResponse() {
        responseText.animate()
                .alpha(0f)
                .setDuration(500)
                .start();
    }
    
    private void openSettings() {
        Intent intent = new Intent(this, SettingsActivity.class);
        startActivity(intent);
    }
    
    private void animateBackgroundPulse() {
        ValueAnimator animator = ValueAnimator.ofFloat(0.8f, 1.0f, 0.8f);
        animator.setDuration(2000);
        animator.setInterpolator(new AccelerateDecelerateInterpolator());
        animator.addUpdateListener(animation -> {
            float value = (float) animation.getAnimatedValue();
            backgroundGradient.setAlpha(value);
        });
        animator.start();
    }
    
    @Override
    public void onVoiceRecognitionReady() {
        // Voice recognition is ready
    }
    
    @Override
    public void onVoiceRecognitionStarted() {
        // Already handled in startListening
    }
    
    @Override
    public void onVoiceRecognitionResult(String result) {
        stopListening();
        showThinking();
        
        // Process with AI
        aiEngine.processUserInput(result);
    }
    
    @Override
    public void onVoiceRecognitionError(String error) {
        stopListening();
        Toast.makeText(this, error, Toast.LENGTH_SHORT).show();
    }
    
    @Override
    public void onVoiceRecognitionPartialResult(String partialResult) {
        // Could show partial results if desired
    }
    
    @Override
    public void onAIResponse(String response) {
        hideThinking();
        showResponse(response);
        animateBackgroundPulse();
    }
    
    @Override
    public void onAIError(String error) {
        hideThinking();
        showResponse(getString(R.string.processing_error));
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        
        if (requestCode == RECORD_AUDIO_PERMISSION_REQUEST) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                setupVoiceRecognition();
            } else {
                Toast.makeText(this, R.string.voice_commands_disabled, Toast.LENGTH_LONG).show();
            }
        }
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (voiceManager != null) {
            voiceManager.destroy();
        }
        uiHandler.removeCallbacksAndMessages(null);
    }
}
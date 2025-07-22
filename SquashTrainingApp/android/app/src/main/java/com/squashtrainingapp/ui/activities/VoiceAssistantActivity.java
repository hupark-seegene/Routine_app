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
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.squashtrainingapp.R;
import com.squashtrainingapp.ai.VoiceRecognitionManager;
import com.squashtrainingapp.ai.AIResponseEngine;
import com.squashtrainingapp.ai.ImprovedAIResponseEngine;
import com.squashtrainingapp.ui.views.CircularPulseButton;
import com.squashtrainingapp.ui.views.WaveformView;
import com.squashtrainingapp.ui.adapters.ChatAdapter;
import com.squashtrainingapp.models.ChatMessage;

import java.util.Locale;

public class VoiceAssistantActivity extends AppCompatActivity implements 
        VoiceRecognitionManager.VoiceRecognitionListener,
        AIResponseEngine.AIResponseListener {
    
    private static final int RECORD_AUDIO_PERMISSION_REQUEST = 1001;
    private static final long RESPONSE_DISPLAY_DURATION = 5000; // 5 seconds
    
    private CircularPulseButton voiceButton;
    private WaveformView waveformView;
    private TextView statusText;
    private TextView typingIndicator;
    private View voiceModeContainer;
    private RecyclerView chatRecyclerView;
    private EditText messageInput;
    private ImageButton sendButton;
    private ImageButton modeToggleButton;
    
    private VoiceRecognitionManager voiceManager;
    private ImprovedAIResponseEngine aiEngine;
    private Handler uiHandler;
    private ChatAdapter chatAdapter;
    
    private boolean isListening = false;
    private boolean isProcessing = false;
    private boolean isVoiceMode = false;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Set light status bar for light theme
        getWindow().getDecorView().setSystemUiVisibility(
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
        typingIndicator = findViewById(R.id.typing_indicator);
        voiceModeContainer = findViewById(R.id.voice_mode_container);
        chatRecyclerView = findViewById(R.id.chat_recycler_view);
        messageInput = findViewById(R.id.message_input);
        sendButton = findViewById(R.id.send_button);
        modeToggleButton = findViewById(R.id.mode_toggle_button);
        
        // Settings button
        View settingsButton = findViewById(R.id.settings_button);
        settingsButton.setOnClickListener(v -> openSettings());
        
        // Close button
        View closeButton = findViewById(R.id.close_button);
        closeButton.setOnClickListener(v -> finish());
        
        voiceButton.setOnClickListener(v -> toggleListening());
        sendButton.setOnClickListener(v -> sendMessage());
        modeToggleButton.setOnClickListener(v -> toggleMode());
        
        // Set up chat RecyclerView
        chatAdapter = new ChatAdapter();
        chatRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        chatRecyclerView.setAdapter(chatAdapter);
        
        // Set initial states
        waveformView.setVisibility(View.INVISIBLE);
        
        // Add welcome message
        chatAdapter.addMessage(new ChatMessage("안녕하세요! 스쿼시 트레이닝에 대해 무엇이든 물어보세요.", false));
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
        // Korean language support is handled by system locale
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
        if (isVoiceMode) {
            // In voice mode, show as status text briefly
            statusText.setText(response);
            uiHandler.postDelayed(() -> statusText.setText(""), RESPONSE_DISPLAY_DURATION);
        } else {
            // In chat mode, add to chat history
            chatAdapter.addMessage(new ChatMessage(response, false));
            scrollToBottom();
        }
    }
    
    private void openSettings() {
        Intent intent = new Intent(this, SettingsActivity.class);
        startActivity(intent);
    }
    
    private void sendMessage() {
        String message = messageInput.getText().toString().trim();
        if (message.isEmpty()) return;
        
        // Add user message to chat
        chatAdapter.addMessage(new ChatMessage(message, true));
        messageInput.setText("");
        scrollToBottom();
        
        // Show typing indicator
        showTypingIndicator();
        
        // Process with AI
        aiEngine.getResponse(message);
    }
    
    private void toggleMode() {
        isVoiceMode = !isVoiceMode;
        
        if (isVoiceMode) {
            // Switch to voice mode
            voiceModeContainer.setVisibility(View.VISIBLE);
            chatRecyclerView.setVisibility(View.GONE);
            modeToggleButton.setImageResource(R.drawable.ic_keyboard);
            messageInput.setEnabled(false);
            sendButton.setEnabled(false);
        } else {
            // Switch to chat mode
            voiceModeContainer.setVisibility(View.GONE);
            chatRecyclerView.setVisibility(View.VISIBLE);
            modeToggleButton.setImageResource(R.drawable.ic_mic);
            messageInput.setEnabled(true);
            sendButton.setEnabled(true);
        }
    }
    
    private void showTypingIndicator() {
        typingIndicator.setVisibility(View.VISIBLE);
    }
    
    private void hideTypingIndicator() {
        typingIndicator.setVisibility(View.GONE);
    }
    
    private void scrollToBottom() {
        chatRecyclerView.scrollToPosition(chatAdapter.getItemCount() - 1);
    }
    
    @Override
    public void onReadyForSpeech() {
        // Voice recognition is ready
    }
    
    @Override
    public void onEndOfSpeech() {
        // Speech ended
    }
    
    @Override
    public void onResults(String result) {
        stopListening();
        showThinking();
        
        // In voice mode, also show in chat
        if (isVoiceMode) {
            chatAdapter.addMessage(new ChatMessage(result, true));
            scrollToBottom();
        }
        
        // Process with AI
        aiEngine.getResponse(result);
    }
    
    @Override
    public void onError(String error) {
        stopListening();
        Toast.makeText(this, error, Toast.LENGTH_SHORT).show();
    }
    
    @Override
    public void onResponse(String response) {
        hideThinking();
        hideTypingIndicator();
        showResponse(response);
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
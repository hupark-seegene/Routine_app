package com.squashtrainingapp.services;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import com.squashtrainingapp.R;
import com.squashtrainingapp.SimpleMainActivity;
import com.squashtrainingapp.ai.ExtendedVoiceCommands;
import com.squashtrainingapp.ai.ImprovedVoiceRecognitionManager;
import com.squashtrainingapp.ai.MultilingualVoiceProcessor;
import com.squashtrainingapp.ui.activities.*;
import com.squashtrainingapp.ui.widgets.VoiceWaveView;

import java.util.Locale;

public class GlobalVoiceCommandService extends Service {
    private static final String TAG = "GlobalVoiceCommandService";
    private static final String CHANNEL_ID = "voice_command_channel";
    private static final int NOTIFICATION_ID = 1001;
    
    private WindowManager windowManager;
    private View floatingButton;
    private View voiceOverlay;
    private ImprovedVoiceRecognitionManager voiceManager;
    private boolean isListening = false;
    private boolean isWakeWordActive = false;
    private Handler wakeWordTimeoutHandler;
    private static final long WAKE_WORD_TIMEOUT = 10000; // 10 seconds
    
    // UI Components
    private ImageButton floatingMicButton;
    private TextView voiceStatusText;
    private VoiceWaveView voiceWaveView;
    private LinearLayout commandSuggestions;
    
    @Override
    public void onCreate() {
        super.onCreate();
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        wakeWordTimeoutHandler = new Handler(Looper.getMainLooper());
        setupVoiceRecognition();
        createNotificationChannel();
        startForeground(NOTIFICATION_ID, createNotification());
        createFloatingButton();
    }
    
    private void setupVoiceRecognition() {
        voiceManager = new ImprovedVoiceRecognitionManager(this);
        voiceManager.setLanguage(Locale.KOREAN);
        voiceManager.setConfidenceThreshold(0.5f);
        voiceManager.setContinuousMode(true);
        
        voiceManager.setVoiceRecognitionListener(new ImprovedVoiceRecognitionManager.VoiceRecognitionListener() {
            @Override
            public void onResults(String recognizedText, float confidence) {
                processVoiceCommand(recognizedText);
            }
            
            @Override
            public void onPartialResults(String partialText) {
                if (voiceStatusText != null && isWakeWordActive) {
                    voiceStatusText.setText(partialText);
                }
            }
            
            @Override
            public void onError(String error) {
                // Silently continue listening for wake word
                if (!isWakeWordActive && voiceManager != null) {
                    voiceManager.startListening();
                }
            }
            
            @Override
            public void onReadyForSpeech() {
                if (voiceStatusText != null && isWakeWordActive) {
                    voiceStatusText.setText("듣고 있습니다...");
                }
            }
            
            @Override
            public void onEndOfSpeech() {
                // Continue listening if wake word not active
                if (!isWakeWordActive) {
                    new Handler().postDelayed(() -> {
                        if (voiceManager != null && !isWakeWordActive) {
                            voiceManager.startListening();
                        }
                    }, 500);
                }
            }
            
            @Override
            public void onVolumeChanged(float volume) {
                if (voiceWaveView != null && isWakeWordActive) {
                    voiceWaveView.setAmplitude(volume);
                }
            }
            
            @Override
            public void onSpeakingStateChanged(boolean isSpeaking) {
                // Update UI if needed
            }
        });
    }
    
    private void processVoiceCommand(String voiceInput) {
        // Use multilingual processor for better language handling
        ExtendedVoiceCommands.Command command = MultilingualVoiceProcessor.processMixedLanguageCommand(voiceInput);
        
        // Check for wake word first
        if (command.type == ExtendedVoiceCommands.CommandType.WAKE_WORD && !isWakeWordActive) {
            // Detect preferred language and adjust TTS accordingly
            Locale preferredLocale = MultilingualVoiceProcessor.detectPreferredLocale(this, voiceInput);
            voiceManager.setLanguage(preferredLocale);
            activateWakeWord();
            return;
        }
        
        // If wake word is not active, ignore other commands
        if (!isWakeWordActive) {
            return;
        }
        
        // Process command
        switch (command.type) {
            case NAVIGATE_PROFILE:
                launchActivity(ProfileActivity.class);
                voiceManager.speak("프로필을 열고 있습니다.");
                break;
                
            case NAVIGATE_CHECKLIST:
                launchActivity(ChecklistActivity.class);
                voiceManager.speak("체크리스트를 열고 있습니다.");
                break;
                
            case NAVIGATE_RECORD:
                launchActivity(VoiceEnabledRecordActivity.class);
                voiceManager.speak("운동 기록 화면을 열고 있습니다.");
                break;
                
            case NAVIGATE_HISTORY:
                launchActivity(HistoryActivity.class);
                voiceManager.speak("운동 기록을 보여드립니다.");
                break;
                
            case NAVIGATE_COACH:
                launchActivity(CoachActivity.class);
                voiceManager.speak("AI 코치를 열고 있습니다.");
                break;
                
            case NAVIGATE_SETTINGS:
                launchActivity(SettingsActivity.class);
                voiceManager.speak("설정을 열고 있습니다.");
                break;
                
            case NAVIGATE_HOME:
                launchActivity(SimpleMainActivity.class);
                voiceManager.speak("홈 화면으로 이동합니다.");
                break;
                
            case START_WORKOUT:
                launchActivity(RecordActivity.class);
                voiceManager.speak("운동을 시작합니다! 화이팅!");
                break;
                
            case SHOW_PROGRESS:
                launchActivity(StatsActivity.class);
                voiceManager.speak("진행 상황을 보여드립니다.");
                break;
                
            case SET_TIMER:
                if (command.extras.containsKey("duration")) {
                    String duration = command.extras.get("duration");
                    String unit = command.extras.get("unit");
                    voiceManager.speak(duration + unit + " 타이머를 설정합니다.");
                    // TODO: Implement timer functionality
                }
                break;
                
            case HELP:
                showCommandSuggestions();
                voiceManager.speak("음성 명령 도움말을 표시합니다.");
                break;
                
            case CANCEL:
                deactivateWakeWord();
                voiceManager.speak("취소했습니다.");
                break;
                
            default:
                voiceManager.speak("죄송합니다. 이해하지 못했습니다. '도움말'이라고 말씀해주세요.");
        }
        
        // Reset wake word timeout
        resetWakeWordTimeout();
    }
    
    private void activateWakeWord() {
        isWakeWordActive = true;
        showVoiceOverlay();
        voiceManager.speak("네, 무엇을 도와드릴까요?");
        voiceManager.setContinuousMode(false);
        
        // Set timeout
        resetWakeWordTimeout();
    }
    
    private void deactivateWakeWord() {
        isWakeWordActive = false;
        hideVoiceOverlay();
        voiceManager.setContinuousMode(true);
        voiceManager.startListening();
        wakeWordTimeoutHandler.removeCallbacksAndMessages(null);
    }
    
    private void resetWakeWordTimeout() {
        wakeWordTimeoutHandler.removeCallbacksAndMessages(null);
        wakeWordTimeoutHandler.postDelayed(() -> {
            if (isWakeWordActive) {
                deactivateWakeWord();
                voiceManager.speak("대기 모드로 전환합니다.");
            }
        }, WAKE_WORD_TIMEOUT);
    }
    
    private void createFloatingButton() {
        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        floatingButton = inflater.inflate(R.layout.floating_voice_button, null);
        
        floatingMicButton = floatingButton.findViewById(R.id.floating_mic_button);
        floatingMicButton.setOnClickListener(v -> {
            if (isWakeWordActive) {
                deactivateWakeWord();
            } else {
                activateWakeWord();
            }
        });
        
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY :
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        );
        
        params.gravity = Gravity.BOTTOM | Gravity.END;
        params.x = 16;
        params.y = 100;
        
        windowManager.addView(floatingButton, params);
    }
    
    private void showVoiceOverlay() {
        if (voiceOverlay != null) {
            voiceOverlay.setVisibility(View.VISIBLE);
            if (voiceWaveView != null) {
                voiceWaveView.startAnimation();
            }
            return;
        }
        
        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        voiceOverlay = inflater.inflate(R.layout.global_voice_overlay, null);
        
        voiceStatusText = voiceOverlay.findViewById(R.id.voice_status_text);
        voiceWaveView = voiceOverlay.findViewById(R.id.voice_wave_view);
        commandSuggestions = voiceOverlay.findViewById(R.id.command_suggestions);
        
        View closeButton = voiceOverlay.findViewById(R.id.close_overlay_button);
        closeButton.setOnClickListener(v -> deactivateWakeWord());
        
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY :
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        );
        
        windowManager.addView(voiceOverlay, params);
        voiceWaveView.startAnimation();
    }
    
    private void hideVoiceOverlay() {
        if (voiceOverlay != null) {
            if (voiceWaveView != null) {
                voiceWaveView.stopAnimation();
            }
            windowManager.removeView(voiceOverlay);
            voiceOverlay = null;
        }
    }
    
    private void showCommandSuggestions() {
        if (commandSuggestions != null) {
            commandSuggestions.setVisibility(View.VISIBLE);
            // TODO: Populate with command suggestions
        }
    }
    
    private void launchActivity(Class<?> activityClass) {
        Intent intent = new Intent(this, activityClass);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
        
        // Deactivate wake word after launching activity
        new Handler().postDelayed(this::deactivateWakeWord, 1000);
    }
    
    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                "Voice Command Service",
                NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Global voice command service for hands-free control");
            
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }
    
    private Notification createNotification() {
        Intent notificationIntent = new Intent(this, SimpleMainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, 
            notificationIntent, PendingIntent.FLAG_IMMUTABLE);
        
        return new NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("음성 명령 활성화됨")
            .setContentText("'헤이 코치'라고 말씀해주세요")
            .setSmallIcon(R.drawable.ic_mic)
            .setContentIntent(pendingIntent)
            .build();
    }
    
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (checkAudioPermission()) {
            voiceManager.startListening();
        }
        return START_STICKY;
    }
    
    private boolean checkAudioPermission() {
        return ContextCompat.checkSelfPermission(this, 
            android.Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED;
    }
    
    @Override
    public void onDestroy() {
        super.onDestroy();
        if (voiceManager != null) {
            voiceManager.destroy();
        }
        if (floatingButton != null) {
            windowManager.removeView(floatingButton);
        }
        if (voiceOverlay != null) {
            windowManager.removeView(voiceOverlay);
        }
        wakeWordTimeoutHandler.removeCallbacksAndMessages(null);
    }
    
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
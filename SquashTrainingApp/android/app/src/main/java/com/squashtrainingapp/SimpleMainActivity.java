package com.squashtrainingapp;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.firebase.auth.FirebaseUser;
import com.squashtrainingapp.ai.AdvancedAIResponseEngine;
import com.squashtrainingapp.ai.ExtendedVoiceCommands;
import com.squashtrainingapp.ai.ImprovedVoiceRecognitionManager;
import com.squashtrainingapp.ai.PersonalizedCoachingEngine;
import com.squashtrainingapp.ai.SmartRecommendationEngine;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.CoachingAdvice;
import com.squashtrainingapp.models.User;
import com.squashtrainingapp.models.WorkoutRecommendation;
import com.squashtrainingapp.ui.activities.*;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.ui.dialogs.PremiumFeatureDialog;

import java.util.List;

public class SimpleMainActivity extends AppCompatActivity implements
        ImprovedVoiceRecognitionManager.VoiceRecognitionListener {
    
    private static final int PERMISSION_REQUEST_RECORD_AUDIO = 1;
    
    // UI components
    private CardView cardProfile;
    private CardView cardChecklist;
    private CardView cardRecord;
    private CardView cardHistory;
    private CardView cardCoach;
    private CardView cardSettings;
    private FloatingActionButton fabVoice;
    private TextView coachingAdviceText;
    
    // Stats views
    private TextView streakCountText;
    private TextView sessionsCountText;
    private TextView levelText;
    
    // Database
    private DatabaseHelper databaseHelper;
    private User currentUser;
    
    // AI components
    private ImprovedVoiceRecognitionManager voiceManager;
    private AdvancedAIResponseEngine aiEngine;
    private PersonalizedCoachingEngine coachingEngine;
    private SmartRecommendationEngine recommendationEngine;
    private Handler handler = new Handler();
    private FirebaseAuthManager authManager;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Initialize auth manager
        authManager = FirebaseAuthManager.getInstance(this);
        
        // Check if user needs to login
        if (!getIntent().getBooleanExtra("isGuest", false)) {
            if (!authManager.isUserLoggedIn()) {
                // Redirect to login - temporarily commented for build
                /*
                Intent intent = new Intent(this, LoginActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                startActivity(intent);
                finish();
                return;
                */
            }
        }
        
        setContentView(R.layout.activity_simple_main);
        
        // Initialize database
        databaseHelper = DatabaseHelper.getInstance(this);
        
        // Initialize AI components
        initializeAIComponents();
        
        // Initialize views
        initializeViews();
        
        // Setup click listeners
        setupClickListeners();
        
        // Load user stats
        loadUserStats();
        
        // Show personalized coaching
        showPersonalizedCoaching();
        
        // Check voice permission
        checkVoicePermission();
    }
    
    private void initializeViews() {
        // Cards
        cardProfile = findViewById(R.id.card_profile);
        cardChecklist = findViewById(R.id.card_checklist);
        cardRecord = findViewById(R.id.card_record);
        cardHistory = findViewById(R.id.card_history);
        cardCoach = findViewById(R.id.card_coach);
        cardSettings = findViewById(R.id.card_settings);
        
        // Stats
        streakCountText = findViewById(R.id.streak_count);
        sessionsCountText = findViewById(R.id.sessions_count);
        levelText = findViewById(R.id.level_text);
        
        // Voice FAB
        fabVoice = findViewById(R.id.fab_voice);
        if (fabVoice == null) {
            // Create FAB programmatically if not in layout
            addVoiceFAB();
        }
        
        // Coaching advice text
        coachingAdviceText = findViewById(R.id.coaching_advice_text);
    }
    
    private void setupClickListeners() {
        // Profile
        cardProfile.setOnClickListener(v -> {
            startActivity(new Intent(this, ProfileActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
        
        // Checklist
        cardChecklist.setOnClickListener(v -> {
            startActivity(new Intent(this, ChecklistActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
        
        // Record
        cardRecord.setOnClickListener(v -> {
            startActivity(new Intent(this, RecordActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
        
        // History
        cardHistory.setOnClickListener(v -> {
            startActivity(new Intent(this, HistoryActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
        
        // Coach (Premium feature)
        cardCoach.setOnClickListener(v -> {
            if (checkPremiumForAICoach()) {
                startActivity(new Intent(this, CoachActivity.class));
                overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
            }
        });
        
        // Settings
        cardSettings.setOnClickListener(v -> {
            startActivity(new Intent(this, SettingsActivity.class));
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
        
        // Voice FAB
        if (fabVoice != null) {
            fabVoice.setOnClickListener(v -> startVoiceRecognition());
        }
    }
    
    private void loadUserStats() {
        // Load user data from database
        currentUser = databaseHelper.getUserDao().getUser();
        
        // Update UI
        streakCountText.setText(String.valueOf(currentUser.getCurrentStreak()));
        sessionsCountText.setText(String.valueOf(currentUser.getTotalSessions()));
        levelText.setText(String.valueOf(currentUser.getLevel()));
    }
    
    private void initializeAIComponents() {
        aiEngine = new AdvancedAIResponseEngine(this);
        coachingEngine = new PersonalizedCoachingEngine(this);
        recommendationEngine = new SmartRecommendationEngine(this);
    }
    
    private void showPersonalizedCoaching() {
        // Get personalized advice
        List<CoachingAdvice> adviceList = coachingEngine.getPersonalizedAdvice();
        if (!adviceList.isEmpty()) {
            CoachingAdvice topAdvice = adviceList.get(0);
            
            // Show in coaching text view if available
            if (coachingAdviceText != null) {
                coachingAdviceText.setText(topAdvice.getTypeIcon() + " " + topAdvice.getMessage());
            } else {
                // Fallback to toast
                Toast.makeText(this, topAdvice.getMessage(), Toast.LENGTH_LONG).show();
            }
        }
        
        // Get workout recommendations
        List<WorkoutRecommendation> recommendations = recommendationEngine.getPersonalizedRecommendations();
        if (!recommendations.isEmpty()) {
            // Store for quick access when user clicks cards
            storeRecommendations(recommendations);
        }
    }
    
    private void checkVoicePermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                != PackageManager.PERMISSION_GRANTED) {
            // Show explanation if needed
            if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.RECORD_AUDIO)) {
                Toast.makeText(this, "음성 명령을 사용하려면 마이크 권한이 필요합니다", 
                    Toast.LENGTH_LONG).show();
            }
            // Request permission
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    PERMISSION_REQUEST_RECORD_AUDIO);
        } else {
            // Permission granted, initialize voice manager
            initializeVoiceManager();
        }
    }
    
    private void initializeVoiceManager() {
        voiceManager = new ImprovedVoiceRecognitionManager(this);
        voiceManager.setVoiceRecognitionListener(this);
        voiceManager.setLanguage(java.util.Locale.KOREAN);
        voiceManager.setConfidenceThreshold(0.7f);
    }
    
    private void startVoiceRecognition() {
        if (voiceManager != null) {
            voiceManager.startListening();
            Toast.makeText(this, "음성 명령을 말씀해주세요", Toast.LENGTH_SHORT).show();
        } else {
            Toast.makeText(this, "음성 인식을 사용할 수 없습니다", Toast.LENGTH_SHORT).show();
        }
    }
    
    private void addVoiceFAB() {
        // This would add a FAB programmatically if needed
        // Implementation depends on your layout structure
    }
    
    private void storeRecommendations(List<WorkoutRecommendation> recommendations) {
        // Store recommendations for later use
        // Could use SharedPreferences or in-memory cache
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        // Refresh stats when returning to main screen
        loadUserStats();
        // Update coaching advice
        showPersonalizedCoaching();
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (voiceManager != null) {
            voiceManager.destroy();
        }
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, 
            int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_RECORD_AUDIO) {
            if (grantResults.length > 0 && 
                    grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted
                initializeVoiceManager();
                Toast.makeText(this, "음성 명령이 활성화되었습니다", Toast.LENGTH_SHORT).show();
            } else {
                // Permission denied
                Toast.makeText(this, "음성 명령을 사용하려면 권한이 필요합니다", 
                    Toast.LENGTH_SHORT).show();
            }
        }
    }
    
    // VoiceRecognitionListener implementation
    @Override
    public void onResults(String recognizedText, float confidence) {
        // Parse voice command
        ExtendedVoiceCommands.Command command = ExtendedVoiceCommands.parseCommand(recognizedText);
        
        // Execute command
        executeVoiceCommand(command);
    }
    
    @Override
    public void onPartialResults(String partialText) {
        // Could show partial results in UI
    }
    
    @Override
    public void onError(String error) {
        Toast.makeText(this, "음성 인식 오류: " + error, Toast.LENGTH_SHORT).show();
    }
    
    @Override
    public void onReadyForSpeech() {
        // Could show listening indicator
    }
    
    @Override
    public void onEndOfSpeech() {
        // Could hide listening indicator
    }
    
    @Override
    public void onVolumeChanged(float volume) {
        // Could show volume indicator
    }
    
    @Override
    public void onSpeakingStateChanged(boolean isSpeaking) {
        // Could show speaking indicator
    }
    
    private void executeVoiceCommand(ExtendedVoiceCommands.Command command) {
        switch (command.type) {
            case NAVIGATE_PROFILE:
                cardProfile.performClick();
                break;
            case NAVIGATE_CHECKLIST:
                cardChecklist.performClick();
                break;
            case NAVIGATE_RECORD:
            case START_WORKOUT:
                cardRecord.performClick();
                break;
            case NAVIGATE_HISTORY:
                cardHistory.performClick();
                break;
            case NAVIGATE_COACH:
                // Check if premium for AI coach
                if (checkPremiumForAICoach()) {
                    cardCoach.performClick();
                }
                break;
            case NAVIGATE_SETTINGS:
                cardSettings.performClick();
                break;
            case SHOW_PROGRESS:
                // Show progress dialog or navigate to stats
                showProgressSummary();
                break;
            default:
                // Use AI engine for other queries - premium feature
                if (checkPremiumForAICoach()) {
                    String response = aiEngine.generateContextualResponse(command.parameters);
                    voiceManager.speak(response);
                    Toast.makeText(this, response, Toast.LENGTH_LONG).show();
                }
        }
    }
    
    private void showProgressSummary() {
        String summary = "현재 레벨 " + currentUser.getLevel() + 
                        ", " + currentUser.getCurrentStreak() + "일 연속 운동 중!";
        voiceManager.speak(summary);
        Toast.makeText(this, summary, Toast.LENGTH_LONG).show();
    }
    
    private boolean checkPremiumForAICoach() {
        // Temporarily simplified for build
        return true;
        /*
        FirebaseUser user = authManager.getCurrentUser();
        if (user != null && authManager.isPremiumUser()) {
            return true;
        } else {
            PremiumFeatureDialog dialog = new PremiumFeatureDialog(this);
            dialog.showForAICoach();
            return false;
        }
        */
    }
    
    private boolean checkPremiumForAnalytics() {
        // Temporarily simplified for build
        return true;
        /*
        FirebaseUser user = authManager.getCurrentUser();
        if (user != null && authManager.isPremiumUser()) {
            return true;
        } else {
            PremiumFeatureDialog dialog = new PremiumFeatureDialog(this);
            dialog.showForAdvancedAnalytics();
            return false;
        }
        */
    }
}
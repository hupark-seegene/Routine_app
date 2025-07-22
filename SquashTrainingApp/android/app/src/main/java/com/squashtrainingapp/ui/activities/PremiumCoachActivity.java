package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.squashtrainingapp.R;
import com.squashtrainingapp.ai.GPT4CoachingService;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.User;
import com.squashtrainingapp.models.WorkoutSession;
import com.squashtrainingapp.ui.adapters.ChatMessageAdapter;
import com.squashtrainingapp.ui.dialogs.PremiumFeatureDialog;

import java.util.ArrayList;
import java.util.List;

public class PremiumCoachActivity extends AppCompatActivity {
    
    // UI Components
    private RecyclerView chatRecyclerView;
    private EditText messageInput;
    private ImageButton sendButton;
    private ChipGroup quickActionsChipGroup;
    private ProgressBar progressBar;
    private TextView coachStatusText;
    private ScrollView coachingModesScrollView;
    
    // Coaching mode cards
    private CardView formAnalysisCard;
    private CardView tacticalAdviceCard;
    private CardView fitnessCard;
    private CardView mentalCard;
    private CardView injuryCard;
    private CardView nutritionCard;
    private CardView matchPrepCard;
    
    // Services and data
    private GPT4CoachingService gpt4Service;
    private FirebaseAuthManager authManager;
    private DatabaseHelper databaseHelper;
    private ChatMessageAdapter chatAdapter;
    private List<ChatMessage> messages;
    private User currentUser;
    
    // Current coaching mode
    private GPT4CoachingService.CoachingMode currentMode = GPT4CoachingService.CoachingMode.TACTICAL_ADVICE;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_premium_coach);
        
        // Check premium status
        authManager = FirebaseAuthManager.getInstance(this);
        if (!authManager.isPremiumUser()) {
            PremiumFeatureDialog dialog = new PremiumFeatureDialog(this);
            dialog.showForAICoach();
            finish();
            return;
        }
        
        initializeServices();
        initializeViews();
        setupClickListeners();
        loadUserData();
        showWelcomeMessage();
    }
    
    private void initializeServices() {
        gpt4Service = new GPT4CoachingService(this);
        databaseHelper = DatabaseHelper.getInstance(this);
        messages = new ArrayList<>();
    }
    
    private void initializeViews() {
        // Back button
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        // Chat components
        chatRecyclerView = findViewById(R.id.chat_recycler_view);
        messageInput = findViewById(R.id.message_input);
        sendButton = findViewById(R.id.send_button);
        progressBar = findViewById(R.id.progress_bar);
        coachStatusText = findViewById(R.id.coach_status_text);
        
        // Quick actions
        quickActionsChipGroup = findViewById(R.id.quick_actions_chip_group);
        coachingModesScrollView = findViewById(R.id.coaching_modes_scroll_view);
        
        // Coaching mode cards
        formAnalysisCard = findViewById(R.id.form_analysis_card);
        tacticalAdviceCard = findViewById(R.id.tactical_advice_card);
        fitnessCard = findViewById(R.id.fitness_planning_card);
        mentalCard = findViewById(R.id.mental_coaching_card);
        injuryCard = findViewById(R.id.injury_prevention_card);
        nutritionCard = findViewById(R.id.nutrition_guidance_card);
        matchPrepCard = findViewById(R.id.match_preparation_card);
        
        // Setup chat recycler view
        chatAdapter = new ChatMessageAdapter(messages);
        chatRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        chatRecyclerView.setAdapter(chatAdapter);
        
        // Add quick action chips
        addQuickActionChips();
    }
    
    private void setupClickListeners() {
        sendButton.setOnClickListener(v -> sendMessage());
        
        // Coaching mode cards
        formAnalysisCard.setOnClickListener(v -> {
            currentMode = GPT4CoachingService.CoachingMode.FORM_ANALYSIS;
            analyzeLastSession();
        });
        
        tacticalAdviceCard.setOnClickListener(v -> {
            currentMode = GPT4CoachingService.CoachingMode.TACTICAL_ADVICE;
            showModeSelected("전술 조언 모드");
        });
        
        fitnessCard.setOnClickListener(v -> {
            currentMode = GPT4CoachingService.CoachingMode.FITNESS_PLANNING;
            createFitnessPlan();
        });
        
        mentalCard.setOnClickListener(v -> {
            currentMode = GPT4CoachingService.CoachingMode.MENTAL_COACHING;
            showModeSelected("멘탈 코칭 모드");
        });
        
        injuryCard.setOnClickListener(v -> {
            currentMode = GPT4CoachingService.CoachingMode.INJURY_PREVENTION;
            showModeSelected("부상 예방 모드");
        });
        
        nutritionCard.setOnClickListener(v -> {
            currentMode = GPT4CoachingService.CoachingMode.NUTRITION_GUIDANCE;
            showModeSelected("영양 가이드 모드");
        });
        
        matchPrepCard.setOnClickListener(v -> {
            currentMode = GPT4CoachingService.CoachingMode.MATCH_PREPARATION;
            getMatchPreparation();
        });
    }
    
    private void addQuickActionChips() {
        String[] quickActions = {
            "오늘의 운동 추천",
            "폼 체크",
            "전술 팁",
            "스트레칭 가이드",
            "경기 준비"
        };
        
        for (String action : quickActions) {
            Chip chip = new Chip(this);
            chip.setText(action);
            chip.setClickable(true);
            chip.setOnClickListener(v -> handleQuickAction(action));
            quickActionsChipGroup.addView(chip);
        }
    }
    
    private void handleQuickAction(String action) {
        String message = "";
        switch (action) {
            case "오늘의 운동 추천":
                message = "오늘 할 수 있는 효과적인 스쿼시 운동을 추천해주세요.";
                break;
            case "폼 체크":
                message = "포핸드 스윙의 올바른 폼을 설명해주세요.";
                break;
            case "전술 팁":
                message = "상대방을 압박하는 효과적인 전술을 알려주세요.";
                break;
            case "스트레칭 가이드":
                message = "스쿼시 전후 필수 스트레칭을 알려주세요.";
                break;
            case "경기 준비":
                message = "경기 2시간 전 준비 루틴을 알려주세요.";
                break;
        }
        
        messageInput.setText(message);
        sendMessage();
    }
    
    private void loadUserData() {
        currentUser = databaseHelper.getUserDao().getUser();
    }
    
    private void showWelcomeMessage() {
        if (!gpt4Service.hasApiKey()) {
            addMessage("AI 코치를 사용하려면 설정에서 OpenAI API 키를 입력해주세요.", false);
            coachStatusText.setText("API 키 필요");
            sendButton.setEnabled(false);
        } else {
            addMessage("안녕하세요! AI 스쿼시 코치입니다. 무엇을 도와드릴까요?", false);
            coachStatusText.setText("온라인");
        }
    }
    
    private void sendMessage() {
        String message = messageInput.getText().toString().trim();
        if (message.isEmpty()) return;
        
        // Add user message
        addMessage(message, true);
        messageInput.setText("");
        
        // Show loading
        progressBar.setVisibility(View.VISIBLE);
        coachStatusText.setText("답변 생성 중...");
        
        // Get conversation history
        List<String> history = new ArrayList<>();
        for (ChatMessage msg : messages) {
            history.add((msg.isUser ? "User: " : "Coach: ") + msg.message);
        }
        
        // Send to GPT-4
        gpt4Service.chatWithCoach(message, history, new GPT4CoachingService.GPT4Callback() {
            @Override
            public void onSuccess(String response) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    coachStatusText.setText("온라인");
                    addMessage(response, false);
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    coachStatusText.setText("오류 발생");
                    addMessage("죄송합니다. 오류가 발생했습니다: " + error, false);
                });
            }
        });
    }
    
    private void analyzeLastSession() {
        // Get last workout session - simplified for now
        // In a real app, you would get this from the database
        WorkoutSession lastSession = new WorkoutSession();
        lastSession.setSessionName("스쿼시 트레이닝");
        lastSession.setDurationMinutes(45);
        lastSession.setNotes("포핸드 연습 중점");
        
        progressBar.setVisibility(View.VISIBLE);
        coachStatusText.setText("폼 분석 중...");
        
        gpt4Service.analyzeForm(lastSession, new GPT4CoachingService.GPT4Callback() {
            @Override
            public void onSuccess(String response) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    coachStatusText.setText("온라인");
                    addMessage("최근 운동 세션 분석 결과:\n\n" + response, false);
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    coachStatusText.setText("오류 발생");
                    addMessage("분석 중 오류가 발생했습니다: " + error, false);
                });
            }
        });
    }
    
    private void createFitnessPlan() {
        // Get user preferences
        int weeklyFrequency = getSharedPreferences("user_goals", MODE_PRIVATE)
                .getInt("workoutFrequency", 3);
        String primaryGoal = getSharedPreferences("user_goals", MODE_PRIVATE)
                .getString("primaryGoal", "fitness");
        
        progressBar.setVisibility(View.VISIBLE);
        coachStatusText.setText("운동 계획 생성 중...");
        
        gpt4Service.createFitnessPlan(weeklyFrequency, primaryGoal, new GPT4CoachingService.GPT4Callback() {
            @Override
            public void onSuccess(String response) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    coachStatusText.setText("온라인");
                    addMessage("맞춤형 4주 운동 계획:\n\n" + response, false);
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    coachStatusText.setText("오류 발생");
                    addMessage("계획 생성 중 오류가 발생했습니다: " + error, false);
                });
            }
        });
    }
    
    private void getMatchPreparation() {
        progressBar.setVisibility(View.VISIBLE);
        coachStatusText.setText("경기 준비 가이드 생성 중...");
        
        gpt4Service.getMatchPreparation(2, new GPT4CoachingService.GPT4Callback() {
            @Override
            public void onSuccess(String response) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    coachStatusText.setText("온라인");
                    addMessage("경기 2시간 전 준비 가이드:\n\n" + response, false);
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    coachStatusText.setText("오류 발생");
                    addMessage("가이드 생성 중 오류가 발생했습니다: " + error, false);
                });
            }
        });
    }
    
    private void showModeSelected(String modeName) {
        Toast.makeText(this, modeName + " 활성화됨", Toast.LENGTH_SHORT).show();
        coachingModesScrollView.setVisibility(View.GONE);
        addMessage(modeName + "로 전환되었습니다. 질문해주세요!", false);
    }
    
    private void addMessage(String message, boolean isUser) {
        ChatMessage chatMessage = new ChatMessage(message, isUser);
        messages.add(chatMessage);
        chatAdapter.notifyItemInserted(messages.size() - 1);
        chatRecyclerView.scrollToPosition(messages.size() - 1);
    }
    
    // Simple chat message model
    public static class ChatMessage {
        public String message;
        public boolean isUser;
        public long timestamp;
        
        public ChatMessage(String message, boolean isUser) {
            this.message = message;
            this.isUser = isUser;
            this.timestamp = System.currentTimeMillis();
        }
    }
}
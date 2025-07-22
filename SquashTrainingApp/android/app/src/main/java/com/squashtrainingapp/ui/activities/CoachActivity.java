package com.squashtrainingapp.ui.activities;

import com.squashtrainingapp.R;

import android.os.Bundle;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import androidx.cardview.widget.CardView;
import java.util.Random;
import androidx.appcompat.app.AppCompatActivity;

public class CoachActivity extends AppCompatActivity {
    
    // UI components
    private TextView dailyTipText;
    private TextView techniqueAdviceText;
    private TextView motivationalQuoteText;
    private TextView workoutSuggestionText;
    private Button refreshTipsButton;
    private Button askAiButton;
    
    // Tips and advice arrays - Enhanced with Korean and more practical advice
    private String[] dailyTips = {
        "발놀림에 집중하세요 - 좋은 포지셔닝이 강력한 샷의 핵심입니다",
        "샷 사이에 라켓을 높이 유지하여 반응 시간을 단축하세요",
        "서브는 매일 연습하세요 - 일관성이 승부를 결정합니다",
        "공을 끝까지 주시하면 컨트롤이 향상됩니다",
        "벽을 전략적으로 활용하세요 - 각도가 기회를 만듭니다",
        "체력 관리가 중요합니다 - 3세트를 뛸 수 있는 스태미나를 기르세요",
        "상대의 약점을 파악하고 그곳을 집중 공략하세요",
        "T 포지션을 항상 의식하며 플레이하세요"
    };
    
    private String[] techniqueAdvice = {
        "스트레이트 드라이브: 벽에 타이트하게 붙이고 깊은 길이를 목표로",
        "크로스 코트: 약간의 각도로 치되 백 코너까지 도달하도록",
        "드롭샷: 준비 동작을 숨기고 부드러운 손목 사용",
        "발리: 발끝으로 서서 공을 밀어내듯 타격",
        "보스트: 사이드 월을 먼저 맞추고 프론트 코너를 겨냥",
        "백핸드: 어깨를 충분히 돌리고 체중 이동 활용",
        "로브: 상대가 앞에 있을 때 높고 깊게 보내기",
        "킬샷: 낮고 강하게, 하지만 정확도가 우선"
    };
    
    private String[] motivationalQuotes = {
        "챔피언은 훈련장에서 만들어집니다",
        "모든 샷이 실력 향상의 기회입니다",
        "파워보다 일관성이 승리를 가져옵니다",
        "어제의 나보다 나은 오늘의 나를 만드세요",
        "성공은 작은 노력의 반복입니다",
        "포기하지 않는 자가 결국 승리합니다",
        "실수를 두려워하지 마세요, 그것이 성장의 길입니다",
        "멘탈이 기술만큼 중요합니다"
    };
    
    private String[] workoutSuggestions = {
        "고스팅 드릴: 30초 운동, 30초 휴식 x 10세트 (중급자용)",
        "벽 연습: 각 사이드 100개씩 스트레이트 드라이브 (일관성 중점)",
        "코트 스프린트: 베이스라인-프론트월 x 20회 (폭발력 향상)",
        "섀도우 스윙: 포핸드 50회, 백핸드 50회 (자세 교정)",
        "반응 드릴: 파트너가 5분간 랜덤 샷 공급",
        "간격 러닝: 1분 빠르게, 2분 천천히 x 10라운드",
        "코어 운동: 플랭크 1분 x 3세트 + 러시안 트위스트",
        "민첩성 사다리: 다양한 발놀림 패턴 연습"
    };
    
    private Random random = new Random();
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_coach);
        
        initializeViews();
        loadRandomContent();
        setupButtons();
    }
    
    private void initializeViews() {
        dailyTipText = findViewById(R.id.daily_tip_text);
        techniqueAdviceText = findViewById(R.id.technique_advice_text);
        motivationalQuoteText = findViewById(R.id.motivational_quote_text);
        workoutSuggestionText = findViewById(R.id.workout_suggestion_text);
        refreshTipsButton = findViewById(R.id.refresh_tips_button);
        askAiButton = findViewById(R.id.ask_ai_button);
    }
    
    private void loadRandomContent() {
        // Set random content for each section
        dailyTipText.setText(dailyTips[random.nextInt(dailyTips.length)]);
        techniqueAdviceText.setText(techniqueAdvice[random.nextInt(techniqueAdvice.length)]);
        motivationalQuoteText.setText(motivationalQuotes[random.nextInt(motivationalQuotes.length)]);
        workoutSuggestionText.setText(workoutSuggestions[random.nextInt(workoutSuggestions.length)]);
    }
    
    private void setupButtons() {
        refreshTipsButton.setOnClickListener(v -> {
            loadRandomContent();
            android.widget.Toast.makeText(this, "Tips refreshed!", android.widget.Toast.LENGTH_SHORT).show();
        });
        
        askAiButton.setOnClickListener(v -> {
            // Launch Voice Assistant Activity (ChatGPT-style UI)
            android.content.Intent intent = new android.content.Intent(this, VoiceAssistantActivity.class);
            startActivity(intent);
            overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        });
    }
    
}
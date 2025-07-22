package com.squashtrainingapp.ui.dialogs;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.material.button.MaterialButton;
import com.squashtrainingapp.R;
import com.squashtrainingapp.ui.activities.SubscriptionActivity;

public class PremiumFeatureDialog {
    
    private Context context;
    private Dialog dialog;
    
    public PremiumFeatureDialog(Context context) {
        this.context = context;
        setupDialog();
    }
    
    private void setupDialog() {
        dialog = new Dialog(context);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_premium_feature, null);
        dialog.setContentView(view);
        
        if (dialog.getWindow() != null) {
            dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
            dialog.getWindow().setLayout(
                    (int) (context.getResources().getDisplayMetrics().widthPixels * 0.9),
                    dialog.getWindow().getAttributes().height
            );
        }
        
        dialog.setCancelable(true);
        
        // Initialize views
        ImageView closeButton = view.findViewById(R.id.close_button);
        TextView titleText = view.findViewById(R.id.title_text);
        TextView descriptionText = view.findViewById(R.id.description_text);
        MaterialButton upgradeButton = view.findViewById(R.id.upgrade_button);
        Button maybeLaterButton = view.findViewById(R.id.maybe_later_button);
        
        // Set click listeners
        closeButton.setOnClickListener(v -> dismiss());
        maybeLaterButton.setOnClickListener(v -> dismiss());
        
        upgradeButton.setOnClickListener(v -> {
            dismiss();
            Intent intent = new Intent(context, SubscriptionActivity.class);
            context.startActivity(intent);
        });
    }
    
    public void show(String featureName, String featureDescription) {
        TextView titleText = dialog.findViewById(R.id.title_text);
        TextView descriptionText = dialog.findViewById(R.id.description_text);
        
        titleText.setText(featureName);
        descriptionText.setText(featureDescription);
        
        dialog.show();
    }
    
    public void showForAICoach() {
        show(
            "AI 개인 코치 🤖",
            "GPT-4 기반 AI 코치가 당신의 실력을 분석하고 맞춤형 트레이닝을 제공합니다.\n\n" +
            "• 실시간 폼 분석\n" +
            "• 개인화된 운동 계획\n" +
            "• 음성 대화형 코칭\n" +
            "• 부상 예방 조언"
        );
    }
    
    public void showForAdvancedAnalytics() {
        show(
            "고급 분석 📊",
            "상세한 성과 분석으로 더 빠른 실력 향상을 경험하세요.\n\n" +
            "• 성과 예측 모델\n" +
            "• 약점 자동 분석\n" +
            "• 경쟁자 비교\n" +
            "• PDF 리포트 생성"
        );
    }
    
    public void showForGlobalLeaderboard() {
        show(
            "글로벌 리더보드 🏆",
            "전 세계 플레이어들과 실력을 겨뤄보세요.\n\n" +
            "• 실시간 글로벌 랭킹\n" +
            "• 주간/월간 챌린지\n" +
            "• 팀 대결 모드\n" +
            "• 성과 배지 시스템"
        );
    }
    
    public void showForPremiumVideos() {
        show(
            "프리미엄 비디오 🎥",
            "프로 선수들의 독점 트레이닝 비디오를 시청하세요.\n\n" +
            "• 프로 선수 튜토리얼\n" +
            "• 고급 기술 강좌\n" +
            "• 전술 분석 영상\n" +
            "• 오프라인 다운로드"
        );
    }
    
    public void showForAnalytics() {
        show(
            "고급 분석 대시보드 📈",
            "데이터 기반의 상세한 분석으로 실력을 향상시키세요.\n\n" +
            "• 성능 추세 분석\n" +
            "• 기술 레벨 측정\n" +
            "• 체력 통계 추적\n" +
            "• AI 인사이트 제공"
        );
    }
    
    public void showForMarketplace() {
        show(
            "콘텐츠 마켓플레이스 🛒",
            "프리미엄 트레이닝 콘텐츠에 접근하고 자신의 콘텐츠를 판매하세요.\n\n" +
            "• 프로 코치 프로그램\n" +
            "• 고급 드릴 컬렉션\n" +
            "• 영양 및 체력 계획\n" +
            "• 콘텐츠 제작자 수익 공유"
        );
    }
    
    public void dismiss() {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }
}
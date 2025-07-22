package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;

import com.android.billingclient.api.ProductDetails;
import com.google.android.material.button.MaterialButton;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.squashtrainingapp.R;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.billing.SubscriptionManager;

import java.util.List;

public class SubscriptionActivity extends AppCompatActivity implements 
        SubscriptionManager.SubscriptionListener {
    
    private TextView currentPlanText;
    private TextView trialDaysText;
    private LinearLayout premiumFeaturesContainer;
    private CardView monthlyPlanCard;
    private CardView yearlyPlanCard;
    private TextView monthlyPriceText;
    private TextView yearlyPriceText;
    private TextView yearlySavingsText;
    private MaterialButton monthlySubscribeButton;
    private MaterialButton yearlySubscribeButton;
    private Button restorePurchasesButton;
    private ProgressBar progressBar;
    
    private SubscriptionManager subscriptionManager;
    private FirebaseAuthManager authManager;
    private boolean isPremium = false;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_subscription);
        
        subscriptionManager = SubscriptionManager.getInstance(this);
        subscriptionManager.setSubscriptionListener(this);
        authManager = FirebaseAuthManager.getInstance(this);
        
        initializeViews();
        setupClickListeners();
        checkCurrentSubscription();
    }
    
    private void initializeViews() {
        currentPlanText = findViewById(R.id.current_plan_text);
        trialDaysText = findViewById(R.id.trial_days_text);
        premiumFeaturesContainer = findViewById(R.id.premium_features_container);
        monthlyPlanCard = findViewById(R.id.monthly_plan_card);
        yearlyPlanCard = findViewById(R.id.yearly_plan_card);
        monthlyPriceText = findViewById(R.id.monthly_price_text);
        yearlyPriceText = findViewById(R.id.yearly_price_text);
        yearlySavingsText = findViewById(R.id.yearly_savings_text);
        monthlySubscribeButton = findViewById(R.id.monthly_subscribe_button);
        yearlySubscribeButton = findViewById(R.id.yearly_subscribe_button);
        restorePurchasesButton = findViewById(R.id.restore_purchases_button);
        progressBar = findViewById(R.id.progress_bar);
        
        // Back button
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        // Set pricing
        monthlyPriceText.setText(subscriptionManager.getMonthlyPrice() + "/월");
        yearlyPriceText.setText(subscriptionManager.getYearlyPrice() + "/년");
        yearlySavingsText.setText(subscriptionManager.getYearlySavings() + " 할인");
        
        // Add premium features
        addPremiumFeature("🤖 GPT-4 기반 AI 개인 코치");
        addPremiumFeature("📊 상세 성과 분석 및 예측");
        addPremiumFeature("🎥 프로 선수 독점 비디오");
        addPremiumFeature("🏆 글로벌 리더보드 및 챌린지");
        addPremiumFeature("👥 팀 생성 및 친구 대결");
        addPremiumFeature("🎯 AI 맞춤 운동 프로그램");
        addPremiumFeature("☁️ 모든 기기 동기화");
        addPremiumFeature("🚫 광고 없는 경험");
        addPremiumFeature("💬 우선 고객 지원");
    }
    
    private void addPremiumFeature(String feature) {
        TextView featureText = new TextView(this);
        featureText.setText(feature);
        featureText.setTextSize(16);
        featureText.setPadding(0, 8, 0, 8);
        premiumFeaturesContainer.addView(featureText);
    }
    
    private void setupClickListeners() {
        monthlySubscribeButton.setOnClickListener(v -> {
            if (!isPremium) {
                purchaseSubscription(SubscriptionManager.MONTHLY_SUBSCRIPTION_ID);
            }
        });
        
        yearlySubscribeButton.setOnClickListener(v -> {
            if (!isPremium) {
                purchaseSubscription(SubscriptionManager.YEARLY_SUBSCRIPTION_ID);
            }
        });
        
        restorePurchasesButton.setOnClickListener(v -> {
            showLoading(true);
            subscriptionManager.restorePurchases();
        });
        
        // Highlight yearly plan
        yearlyPlanCard.setCardElevation(16);
    }
    
    private void checkCurrentSubscription() {
        showLoading(true);
        
        FirebaseUser user = authManager.getCurrentUser();
        if (user != null) {
            authManager.getUserSubscription(user.getUid(), task -> {
                if (task.isSuccessful()) {
                    FirebaseAuthManager.SubscriptionStatus status = task.getResult();
                    updateUIForSubscriptionStatus(status);
                }
                showLoading(false);
            });
        }
        
        // Also check with Google Play
        subscriptionManager.checkExistingPurchases();
    }
    
    private void updateUIForSubscriptionStatus(FirebaseAuthManager.SubscriptionStatus status) {
        switch (status) {
            case PREMIUM:
                currentPlanText.setText("현재 플랜: 프리미엄 ⭐");
                trialDaysText.setVisibility(View.GONE);
                monthlySubscribeButton.setText("현재 이용 중");
                monthlySubscribeButton.setEnabled(false);
                yearlySubscribeButton.setText("플랜 변경");
                isPremium = true;
                break;
                
            case TRIAL:
                currentPlanText.setText("현재 플랜: 무료 체험");
                // Calculate remaining trial days
                trialDaysText.setText("무료 체험 5일 남음");
                trialDaysText.setVisibility(View.VISIBLE);
                break;
                
            case FREE:
            default:
                currentPlanText.setText("현재 플랜: 무료");
                trialDaysText.setVisibility(View.GONE);
                break;
        }
    }
    
    private void purchaseSubscription(String productId) {
        showLoading(true);
        subscriptionManager.purchaseSubscription(this, productId);
    }
    
    private void showLoading(boolean show) {
        progressBar.setVisibility(show ? View.VISIBLE : View.GONE);
        monthlyPlanCard.setAlpha(show ? 0.5f : 1.0f);
        yearlyPlanCard.setAlpha(show ? 0.5f : 1.0f);
        monthlyPlanCard.setEnabled(!show);
        yearlyPlanCard.setEnabled(!show);
    }
    
    // SubscriptionListener callbacks
    @Override
    public void onSubscriptionStatusChanged(boolean isPremium) {
        this.isPremium = isPremium;
        runOnUiThread(() -> {
            if (isPremium) {
                updateUIForSubscriptionStatus(FirebaseAuthManager.SubscriptionStatus.PREMIUM);
                Toast.makeText(this, "프리미엄 구독이 활성화되었습니다! 🎉", Toast.LENGTH_LONG).show();
            }
        });
    }
    
    @Override
    public void onPurchaseSuccess(String productId) {
        runOnUiThread(() -> {
            showLoading(false);
            Toast.makeText(this, "구매해 주셔서 감사합니다!", Toast.LENGTH_SHORT).show();
            finish(); // Return to previous screen
        });
    }
    
    @Override
    public void onPurchaseError(String error) {
        runOnUiThread(() -> {
            showLoading(false);
            Toast.makeText(this, error, Toast.LENGTH_LONG).show();
        });
    }
    
    @Override
    public void onProductsLoaded(List<ProductDetails> products) {
        runOnUiThread(() -> {
            // Update prices if needed
            monthlyPriceText.setText(subscriptionManager.getMonthlyPrice() + "/월");
            yearlyPriceText.setText(subscriptionManager.getYearlyPrice() + "/년");
            yearlySavingsText.setText(subscriptionManager.getYearlySavings() + " 할인");
        });
    }
}
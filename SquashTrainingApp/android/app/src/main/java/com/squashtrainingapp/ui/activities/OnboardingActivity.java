package com.squashtrainingapp.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.squashtrainingapp.R;
import com.squashtrainingapp.SimpleMainActivity;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.onboarding.PremiumOnboardingManager;
import com.squashtrainingapp.ui.adapters.OnboardingAdapter;

import java.util.ArrayList;
import java.util.List;

public class OnboardingActivity extends AppCompatActivity {
    
    private ViewPager2 viewPager;
    private TabLayout tabLayout;
    private Button nextButton;
    private Button skipButton;
    private TextView startTrialButton;
    private OnboardingAdapter adapter;
    
    private PremiumOnboardingManager onboardingManager;
    private FirebaseAuthManager authManager;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_onboarding);
        
        onboardingManager = PremiumOnboardingManager.getInstance(this);
        authManager = FirebaseAuthManager.getInstance(this);
        
        // Assign A/B test variant
        onboardingManager.assignABTestVariant();
        
        initializeViews();
        setupOnboarding();
    }
    
    private void initializeViews() {
        viewPager = findViewById(R.id.onboarding_viewpager);
        tabLayout = findViewById(R.id.onboarding_tab_layout);
        nextButton = findViewById(R.id.next_button);
        skipButton = findViewById(R.id.skip_button);
        startTrialButton = findViewById(R.id.start_trial_button);
    }
    
    private void setupOnboarding() {
        List<OnboardingItem> items = new ArrayList<>();
        
        // Customize based on A/B test variant
        PremiumOnboardingManager.ABTestVariant variant = onboardingManager.getABTestVariant();
        
        switch (variant) {
            case VARIANT_A:
                // Immediate premium offer
                items.add(createPremiumOfferItem());
                items.add(createWelcomeItem());
                items.add(createAICoachItem());
                items.add(createPersonalizationItem());
                items.add(createStartItem());
                break;
                
            case VARIANT_B:
                // Premium offer after personalization
                items.add(createWelcomeItem());
                items.add(createPersonalizationItem());
                items.add(createAICoachItem());
                items.add(createPremiumOfferItem());
                items.add(createStartItem());
                break;
                
            case VARIANT_C:
                // Soft premium features showcase
                items.add(createWelcomeItem());
                items.add(createAICoachItem());
                items.add(createAnalyticsItem());
                items.add(createMarketplaceItem());
                items.add(createPersonalizationItem());
                items.add(createStartItem());
                break;
                
            default:
                // Control group
                items.add(createWelcomeItem());
                items.add(createAICoachItem());
                items.add(createPersonalizationItem());
                items.add(createStartItem());
                break;
        }
        
        adapter = new OnboardingAdapter(items, this);
        viewPager.setAdapter(adapter);
        
        // Setup tab layout
        new TabLayoutMediator(tabLayout, viewPager, (tab, position) -> {
            // Empty - just dots
        }).attach();
        
        // Setup navigation
        setupNavigation();
    }
    
    private void setupNavigation() {
        nextButton.setOnClickListener(v -> {
            int currentItem = viewPager.getCurrentItem();
            if (currentItem < adapter.getItemCount() - 1) {
                viewPager.setCurrentItem(currentItem + 1);
            } else {
                completeOnboarding();
            }
        });
        
        skipButton.setOnClickListener(v -> {
            // Go to last page (personalization)
            viewPager.setCurrentItem(adapter.getItemCount() - 2);
        });
        
        startTrialButton.setOnClickListener(v -> {
            // Start premium trial
            Intent intent = new Intent(this, SubscriptionActivity.class);
            intent.putExtra("show_trial", true);
            startActivity(intent);
        });
        
        // Update button visibility based on page
        viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                updateButtonVisibility(position);
            }
        });
    }
    
    private void updateButtonVisibility(int position) {
        boolean isLastPage = position == adapter.getItemCount() - 1;
        boolean isPremiumPage = adapter.getItem(position).getType() == OnboardingItem.Type.PREMIUM_OFFER;
        
        nextButton.setText(isLastPage ? "시작하기" : "다음");
        skipButton.setVisibility(isLastPage ? View.GONE : View.VISIBLE);
        
        // Show trial button on premium pages
        if (isPremiumPage && !authManager.isPremiumUser()) {
            startTrialButton.setVisibility(View.VISIBLE);
            nextButton.setText("나중에");
        } else {
            startTrialButton.setVisibility(View.GONE);
        }
    }
    
    private void completeOnboarding() {
        onboardingManager.setOnboardingCompleted();
        
        Intent intent;
        if (authManager.isLoggedIn()) {
            intent = new Intent(this, SimpleMainActivity.class);
        } else {
            intent = new Intent(this, LoginActivity.class);
        }
        
        startActivity(intent);
        finish();
    }
    
    // Onboarding item creators
    private OnboardingItem createWelcomeItem() {
        return new OnboardingItem(
                OnboardingItem.Type.WELCOME,
                "스쿼시 트레이닝의 새로운 기준",
                "AI 코치와 함께하는 맞춤형 트레이닝으로\n실력을 한 단계 업그레이드하세요",
                R.drawable.ic_squash_racket,
                R.raw.onboarding_animation_1
        );
    }
    
    private OnboardingItem createAICoachItem() {
        return new OnboardingItem(
                OnboardingItem.Type.FEATURE,
                "GPT-4 기반 AI 개인 코치",
                "24시간 당신만을 위한 코치가 실시간으로\n폼 분석과 전술 조언을 제공합니다",
                R.drawable.ic_coach,
                R.raw.onboarding_animation_2
        );
    }
    
    private OnboardingItem createAnalyticsItem() {
        return new OnboardingItem(
                OnboardingItem.Type.FEATURE,
                "고급 분석 대시보드",
                "상세한 성과 분석과 예측 모델로\n약점을 파악하고 빠르게 개선하세요",
                R.drawable.ic_analytics,
                0
        );
    }
    
    private OnboardingItem createMarketplaceItem() {
        return new OnboardingItem(
                OnboardingItem.Type.FEATURE,
                "프리미엄 콘텐츠 마켓플레이스",
                "프로 코치들의 독점 트레이닝 프로그램과\n비디오 튜토리얼을 만나보세요",
                R.drawable.ic_marketplace,
                0
        );
    }
    
    private OnboardingItem createPremiumOfferItem() {
        onboardingManager.setPremiumOfferShown(true);
        return new OnboardingItem(
                OnboardingItem.Type.PREMIUM_OFFER,
                "프리미엄으로 더 빠른 성장을",
                "7일 무료 체험 후 월 9,900원\n언제든지 취소 가능합니다",
                R.drawable.ic_premium_crown,
                R.raw.onboarding_animation_4
        );
    }
    
    private OnboardingItem createPersonalizationItem() {
        return new OnboardingItem(
                OnboardingItem.Type.PERSONALIZATION,
                "당신에게 맞는 설정",
                "몇 가지 질문으로 최적화된\n트레이닝 계획을 만들어드립니다",
                R.drawable.ic_settings,
                0
        );
    }
    
    private OnboardingItem createStartItem() {
        return new OnboardingItem(
                OnboardingItem.Type.GET_STARTED,
                "준비되셨나요?",
                onboardingManager.getPersonalizedWelcome(),
                R.drawable.ic_sports,
                R.raw.onboarding_animation_5
        );
    }
    
    // OnboardingItem class
    public static class OnboardingItem {
        public enum Type {
            WELCOME,
            FEATURE,
            PREMIUM_OFFER,
            PERSONALIZATION,
            GET_STARTED
        }
        
        private Type type;
        private String title;
        private String description;
        private int imageResId;
        private int animationResId;
        
        public OnboardingItem(Type type, String title, String description, 
                            int imageResId, int animationResId) {
            this.type = type;
            this.title = title;
            this.description = description;
            this.imageResId = imageResId;
            this.animationResId = animationResId;
        }
        
        // Getters
        public Type getType() { return type; }
        public String getTitle() { return title; }
        public String getDescription() { return description; }
        public int getImageResId() { return imageResId; }
        public int getAnimationResId() { return animationResId; }
    }
}
package com.squashtrainingapp.onboarding;

import android.content.Context;
import android.content.SharedPreferences;

public class PremiumOnboardingManager {
    
    private static final String PREFS_NAME = "onboarding_prefs";
    private static final String KEY_ONBOARDING_COMPLETED = "onboarding_completed";
    private static final String KEY_ONBOARDING_VERSION = "onboarding_version";
    private static final String KEY_USER_LEVEL = "user_level";
    private static final String KEY_USER_GOAL = "user_goal";
    private static final String KEY_WORKOUT_FREQUENCY = "workout_frequency";
    private static final String KEY_PREFERRED_TIME = "preferred_time";
    private static final String KEY_SHOWED_PREMIUM_OFFER = "showed_premium_offer";
    private static final String KEY_AB_TEST_VARIANT = "ab_test_variant";
    
    private static final int CURRENT_ONBOARDING_VERSION = 1;
    
    private static PremiumOnboardingManager instance;
    private SharedPreferences prefs;
    
    // User levels
    public enum UserLevel {
        BEGINNER("beginner"),
        INTERMEDIATE("intermediate"),
        ADVANCED("advanced"),
        PROFESSIONAL("professional");
        
        private final String value;
        
        UserLevel(String value) {
            this.value = value;
        }
        
        public String getValue() {
            return value;
        }
    }
    
    // User goals
    public enum UserGoal {
        FITNESS("fitness"),
        COMPETITION("competition"),
        TECHNIQUE("technique"),
        WEIGHT_LOSS("weight_loss"),
        SOCIAL("social");
        
        private final String value;
        
        UserGoal(String value) {
            this.value = value;
        }
        
        public String getValue() {
            return value;
        }
    }
    
    // A/B test variants
    public enum ABTestVariant {
        CONTROL("control"),
        VARIANT_A("variant_a"), // Immediate premium offer
        VARIANT_B("variant_b"), // Premium offer after personalization
        VARIANT_C("variant_c"); // Soft premium features showcase
        
        private final String value;
        
        ABTestVariant(String value) {
            this.value = value;
        }
        
        public String getValue() {
            return value;
        }
    }
    
    private PremiumOnboardingManager(Context context) {
        prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }
    
    public static synchronized PremiumOnboardingManager getInstance(Context context) {
        if (instance == null) {
            instance = new PremiumOnboardingManager(context.getApplicationContext());
        }
        return instance;
    }
    
    // Check if onboarding has been completed
    public boolean hasCompletedOnboarding() {
        int completedVersion = prefs.getInt(KEY_ONBOARDING_VERSION, 0);
        return completedVersion >= CURRENT_ONBOARDING_VERSION;
    }
    
    // Mark onboarding as completed
    public void setOnboardingCompleted() {
        prefs.edit()
                .putBoolean(KEY_ONBOARDING_COMPLETED, true)
                .putInt(KEY_ONBOARDING_VERSION, CURRENT_ONBOARDING_VERSION)
                .apply();
    }
    
    // Save user level
    public void setUserLevel(UserLevel level) {
        prefs.edit().putString(KEY_USER_LEVEL, level.getValue()).apply();
    }
    
    public UserLevel getUserLevel() {
        String levelStr = prefs.getString(KEY_USER_LEVEL, UserLevel.BEGINNER.getValue());
        for (UserLevel level : UserLevel.values()) {
            if (level.getValue().equals(levelStr)) {
                return level;
            }
        }
        return UserLevel.BEGINNER;
    }
    
    // Save user goal
    public void setUserGoal(UserGoal goal) {
        prefs.edit().putString(KEY_USER_GOAL, goal.getValue()).apply();
    }
    
    public UserGoal getUserGoal() {
        String goalStr = prefs.getString(KEY_USER_GOAL, UserGoal.FITNESS.getValue());
        for (UserGoal goal : UserGoal.values()) {
            if (goal.getValue().equals(goalStr)) {
                return goal;
            }
        }
        return UserGoal.FITNESS;
    }
    
    // Save workout frequency (days per week)
    public void setWorkoutFrequency(int frequency) {
        prefs.edit().putInt(KEY_WORKOUT_FREQUENCY, frequency).apply();
    }
    
    public int getWorkoutFrequency() {
        return prefs.getInt(KEY_WORKOUT_FREQUENCY, 3);
    }
    
    // Save preferred workout time
    public void setPreferredTime(String time) {
        prefs.edit().putString(KEY_PREFERRED_TIME, time).apply();
    }
    
    public String getPreferredTime() {
        return prefs.getString(KEY_PREFERRED_TIME, "evening");
    }
    
    // Track if premium offer was shown
    public void setPremiumOfferShown(boolean shown) {
        prefs.edit().putBoolean(KEY_SHOWED_PREMIUM_OFFER, shown).apply();
    }
    
    public boolean wasPremiumOfferShown() {
        return prefs.getBoolean(KEY_SHOWED_PREMIUM_OFFER, false);
    }
    
    // A/B test variant management
    public void assignABTestVariant() {
        if (!prefs.contains(KEY_AB_TEST_VARIANT)) {
            // Randomly assign variant
            ABTestVariant[] variants = ABTestVariant.values();
            int randomIndex = (int) (Math.random() * variants.length);
            ABTestVariant variant = variants[randomIndex];
            
            prefs.edit().putString(KEY_AB_TEST_VARIANT, variant.getValue()).apply();
        }
    }
    
    public ABTestVariant getABTestVariant() {
        String variantStr = prefs.getString(KEY_AB_TEST_VARIANT, ABTestVariant.CONTROL.getValue());
        for (ABTestVariant variant : ABTestVariant.values()) {
            if (variant.getValue().equals(variantStr)) {
                return variant;
            }
        }
        return ABTestVariant.CONTROL;
    }
    
    // Reset onboarding (for testing)
    public void resetOnboarding() {
        prefs.edit().clear().apply();
    }
    
    // Get personalized welcome message
    public String getPersonalizedWelcome() {
        UserLevel level = getUserLevel();
        UserGoal goal = getUserGoal();
        
        if (level == UserLevel.BEGINNER) {
            return "스쿼시를 시작하는 당신을 환영합니다! 기초부터 차근차근 배워보세요.";
        } else if (goal == UserGoal.COMPETITION) {
            return "챔피언을 꿈꾸는 당신! 프로 수준의 트레이닝을 시작하세요.";
        } else if (goal == UserGoal.FITNESS) {
            return "건강한 삶을 위한 최고의 선택! 재미있게 운동해요.";
        }
        
        return "당신만의 스쿼시 여정을 시작하세요!";
    }
}
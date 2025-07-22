package com.squashtrainingapp.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.airbnb.lottie.LottieAnimationView;
import com.squashtrainingapp.R;
import com.squashtrainingapp.SimpleMainActivity;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.onboarding.PremiumOnboardingManager;

public class SplashActivity extends AppCompatActivity {
    
    private static final int SPLASH_DURATION = 3000; // 3 seconds
    
    private LottieAnimationView lottieView;
    private ImageView logoImage;
    private TextView appNameText;
    private TextView taglineText;
    
    private FirebaseAuthManager authManager;
    private PremiumOnboardingManager onboardingManager;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Hide status bar for full screen experience
        getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_FULLSCREEN | 
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | 
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        
        setContentView(R.layout.activity_splash);
        
        initializeViews();
        initializeServices();
        startAnimations();
        
        // Navigate after delay
        new Handler().postDelayed(this::navigateToNextScreen, SPLASH_DURATION);
    }
    
    private void initializeViews() {
        lottieView = findViewById(R.id.lottie_animation);
        logoImage = findViewById(R.id.logo_image);
        appNameText = findViewById(R.id.app_name_text);
        taglineText = findViewById(R.id.tagline_text);
        
        // Start Lottie animation
        if (lottieView != null) {
            lottieView.playAnimation();
        }
    }
    
    private void initializeServices() {
        authManager = FirebaseAuthManager.getInstance(this);
        onboardingManager = PremiumOnboardingManager.getInstance(this);
    }
    
    private void startAnimations() {
        // Logo scale animation
        ScaleAnimation scaleAnim = new ScaleAnimation(
                0.5f, 1.0f,
                0.5f, 1.0f,
                Animation.RELATIVE_TO_SELF, 0.5f,
                Animation.RELATIVE_TO_SELF, 0.5f
        );
        scaleAnim.setDuration(1000);
        scaleAnim.setFillAfter(true);
        
        // App name fade in
        AlphaAnimation fadeInName = new AlphaAnimation(0.0f, 1.0f);
        fadeInName.setDuration(1500);
        fadeInName.setStartOffset(500);
        fadeInName.setFillAfter(true);
        
        // Tagline fade in
        AlphaAnimation fadeInTagline = new AlphaAnimation(0.0f, 1.0f);
        fadeInTagline.setDuration(1500);
        fadeInTagline.setStartOffset(1000);
        fadeInTagline.setFillAfter(true);
        
        // Apply animations
        if (logoImage != null) {
            logoImage.startAnimation(scaleAnim);
        }
        if (appNameText != null) {
            appNameText.startAnimation(fadeInName);
        }
        if (taglineText != null) {
            taglineText.startAnimation(fadeInTagline);
        }
    }
    
    private void navigateToNextScreen() {
        Intent intent;
        
        // ALWAYS go to main screen first - let users experience the app!
        intent = new Intent(this, SimpleMainActivity.class);
        
        // Pass guest mode flag if not logged in
        if (!authManager.isLoggedIn()) {
            intent.putExtra("isGuest", true);
        }
        
        // Pass first time user flag for optional onboarding
        if (!onboardingManager.hasCompletedOnboarding()) {
            intent.putExtra("showOnboardingHint", true);
        }
        
        startActivity(intent);
        
        // Add fade transition
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
        
        finish();
    }
}
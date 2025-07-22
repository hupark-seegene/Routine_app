package com.squashtrainingapp.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;
import com.kakao.sdk.common.KakaoSdk;
import com.squashtrainingapp.R;
import com.squashtrainingapp.SimpleMainActivity;
import com.squashtrainingapp.auth.FirebaseAuthManager;

public class LoginActivity extends AppCompatActivity {
    
    private static final int RC_SIGN_IN = 9001;
    
    // UI elements
    private TextInputLayout emailLayout, passwordLayout;
    private TextInputEditText emailInput, passwordInput;
    private MaterialButton signInButton, signUpButton;
    private LinearLayout socialLoginContainer;
    private CardView googleSignInButton, kakaoSignInButton, appleSignInButton;
    private TextView forgotPasswordText, skipLoginText;
    private ProgressBar progressBar;
    private View contentContainer;
    
    private FirebaseAuthManager authManager;
    private boolean isSignUpMode = false;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        
        // Initialize Kakao SDK
        KakaoSdk.init(this, getString(R.string.kakao_app_key));
        
        authManager = FirebaseAuthManager.getInstance(this);
        
        // Check if user is already logged in
        if (authManager.isUserLoggedIn()) {
            navigateToMain();
            return;
        }
        
        initializeViews();
        setupClickListeners();
    }
    
    private void initializeViews() {
        emailLayout = findViewById(R.id.email_layout);
        passwordLayout = findViewById(R.id.password_layout);
        emailInput = findViewById(R.id.email_input);
        passwordInput = findViewById(R.id.password_input);
        signInButton = findViewById(R.id.sign_in_button);
        signUpButton = findViewById(R.id.sign_up_button);
        socialLoginContainer = findViewById(R.id.social_login_container);
        googleSignInButton = findViewById(R.id.google_sign_in_button);
        kakaoSignInButton = findViewById(R.id.kakao_sign_in_button);
        appleSignInButton = findViewById(R.id.apple_sign_in_button);
        forgotPasswordText = findViewById(R.id.forgot_password_text);
        skipLoginText = findViewById(R.id.skip_login_text);
        progressBar = findViewById(R.id.progress_bar);
        contentContainer = findViewById(R.id.content_container);
    }
    
    private void setupClickListeners() {
        signInButton.setOnClickListener(v -> {
            if (isSignUpMode) {
                performSignUp();
            } else {
                performSignIn();
            }
        });
        
        signUpButton.setOnClickListener(v -> toggleSignUpMode());
        
        googleSignInButton.setOnClickListener(v -> signInWithGoogle());
        
        kakaoSignInButton.setOnClickListener(v -> signInWithKakao());
        
        appleSignInButton.setOnClickListener(v -> {
            Toast.makeText(this, "Apple Sign-In coming soon", Toast.LENGTH_SHORT).show();
        });
        
        forgotPasswordText.setOnClickListener(v -> showPasswordResetDialog());
        
        skipLoginText.setOnClickListener(v -> {
            // Navigate to main with limited features
            Intent intent = new Intent(this, SimpleMainActivity.class);
            intent.putExtra("isGuest", true);
            startActivity(intent);
            finish();
        });
    }
    
    private void toggleSignUpMode() {
        isSignUpMode = !isSignUpMode;
        
        if (isSignUpMode) {
            signInButton.setText("회원가입");
            signUpButton.setText("로그인으로 전환");
            forgotPasswordText.setVisibility(View.GONE);
        } else {
            signInButton.setText("로그인");
            signUpButton.setText("회원가입");
            forgotPasswordText.setVisibility(View.VISIBLE);
        }
    }
    
    private void performSignIn() {
        String email = emailInput.getText().toString().trim();
        String password = passwordInput.getText().toString().trim();
        
        if (!validateInput(email, password)) {
            return;
        }
        
        showLoading(true);
        
        authManager.signInWithEmail(email, password, new FirebaseAuthManager.AuthCallback() {
            @Override
            public void onSuccess(com.google.firebase.auth.FirebaseUser user) {
                showLoading(false);
                navigateToMain();
            }
            
            @Override
            public void onError(String error) {
                showLoading(false);
                Toast.makeText(LoginActivity.this, error, Toast.LENGTH_LONG).show();
            }
        });
    }
    
    private void performSignUp() {
        String email = emailInput.getText().toString().trim();
        String password = passwordInput.getText().toString().trim();
        
        if (!validateInput(email, password)) {
            return;
        }
        
        showLoading(true);
        
        // Extract display name from email
        String displayName = email.substring(0, email.indexOf('@'));
        
        authManager.signUpWithEmail(email, password, displayName, new FirebaseAuthManager.AuthCallback() {
            @Override
            public void onSuccess(com.google.firebase.auth.FirebaseUser user) {
                showLoading(false);
                Toast.makeText(LoginActivity.this, "회원가입 성공! 7일 무료 체험이 시작되었습니다.", Toast.LENGTH_LONG).show();
                navigateToOnboarding();
            }
            
            @Override
            public void onError(String error) {
                showLoading(false);
                Toast.makeText(LoginActivity.this, error, Toast.LENGTH_LONG).show();
            }
        });
    }
    
    private void signInWithGoogle() {
        showLoading(true);
        Intent signInIntent = authManager.getGoogleSignInIntent();
        startActivityForResult(signInIntent, RC_SIGN_IN);
    }
    
    private void signInWithKakao() {
        showLoading(true);
        authManager.signInWithKakao(this, new FirebaseAuthManager.AuthCallback() {
            @Override
            public void onSuccess(com.google.firebase.auth.FirebaseUser user) {
                showLoading(false);
                navigateToMain();
            }
            
            @Override
            public void onError(String error) {
                showLoading(false);
                Toast.makeText(LoginActivity.this, error, Toast.LENGTH_LONG).show();
            }
        });
    }
    
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        
        if (requestCode == RC_SIGN_IN) {
            authManager.handleGoogleSignInResult(data, new FirebaseAuthManager.AuthCallback() {
                @Override
                public void onSuccess(com.google.firebase.auth.FirebaseUser user) {
                    showLoading(false);
                    navigateToMain();
                }
                
                @Override
                public void onError(String error) {
                    showLoading(false);
                    Toast.makeText(LoginActivity.this, error, Toast.LENGTH_LONG).show();
                }
            });
        }
    }
    
    private boolean validateInput(String email, String password) {
        boolean isValid = true;
        
        if (TextUtils.isEmpty(email)) {
            emailLayout.setError("이메일을 입력해주세요");
            isValid = false;
        } else if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            emailLayout.setError("올바른 이메일 형식이 아닙니다");
            isValid = false;
        } else {
            emailLayout.setError(null);
        }
        
        if (TextUtils.isEmpty(password)) {
            passwordLayout.setError("비밀번호를 입력해주세요");
            isValid = false;
        } else if (password.length() < 6) {
            passwordLayout.setError("비밀번호는 6자 이상이어야 합니다");
            isValid = false;
        } else {
            passwordLayout.setError(null);
        }
        
        return isValid;
    }
    
    private void showPasswordResetDialog() {
        // TODO: Implement password reset dialog
        String email = emailInput.getText().toString().trim();
        if (TextUtils.isEmpty(email)) {
            Toast.makeText(this, "이메일을 먼저 입력해주세요", Toast.LENGTH_SHORT).show();
            return;
        }
        
        authManager.sendPasswordResetEmail(email, task -> {
            if (task.isSuccessful()) {
                Toast.makeText(this, "비밀번호 재설정 이메일을 보냈습니다", Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(this, "이메일 전송 실패: " + task.getException().getMessage(), Toast.LENGTH_LONG).show();
            }
        });
    }
    
    private void showLoading(boolean show) {
        progressBar.setVisibility(show ? View.VISIBLE : View.GONE);
        contentContainer.setAlpha(show ? 0.5f : 1.0f);
        contentContainer.setEnabled(!show);
    }
    
    private void navigateToMain() {
        Intent intent = new Intent(this, SimpleMainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        finish();
    }
    
    private void navigateToOnboarding() {
        Intent intent = new Intent(this, OnboardingActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
        finish();
    }
}
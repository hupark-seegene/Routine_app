package com.squashtrainingapp.ui.dialogs;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.EditText;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;

import com.google.android.material.button.MaterialButton;
import com.squashtrainingapp.R;
import com.squashtrainingapp.marketing.ShareManager;

public class InviteDialog extends Dialog {
    
    private EditText emailInput;
    private MaterialButton sendEmailButton;
    private LinearLayout socialShareContainer;
    private MaterialButton kakaoButton;
    private MaterialButton facebookButton;
    private MaterialButton instagramButton;
    private MaterialButton whatsappButton;
    private MaterialButton shareButton;
    
    private ShareManager shareManager;
    
    public InviteDialog(@NonNull Context context) {
        super(context);
        shareManager = new ShareManager(context);
    }
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.dialog_invite_friends);
        
        initializeViews();
        setupClickListeners();
    }
    
    private void initializeViews() {
        emailInput = findViewById(R.id.email_input);
        sendEmailButton = findViewById(R.id.send_email_button);
        socialShareContainer = findViewById(R.id.social_share_container);
        kakaoButton = findViewById(R.id.kakao_button);
        facebookButton = findViewById(R.id.facebook_button);
        instagramButton = findViewById(R.id.instagram_button);
        whatsappButton = findViewById(R.id.whatsapp_button);
        shareButton = findViewById(R.id.share_button);
        
        // Close button
        findViewById(R.id.close_button).setOnClickListener(v -> dismiss());
    }
    
    private void setupClickListeners() {
        sendEmailButton.setOnClickListener(v -> {
            String email = emailInput.getText().toString().trim();
            if (isValidEmail(email)) {
                sendInviteEmail(email);
                emailInput.setText("");
            } else {
                emailInput.setError("올바른 이메일을 입력하세요");
            }
        });
        
        kakaoButton.setOnClickListener(v -> {
            shareManager.shareToPlatform(getInviteText(), ShareManager.Platform.KAKAOTALK);
            dismiss();
        });
        
        facebookButton.setOnClickListener(v -> {
            shareManager.shareToPlatform(getInviteText(), ShareManager.Platform.FACEBOOK);
            dismiss();
        });
        
        instagramButton.setOnClickListener(v -> {
            shareManager.shareToPlatform(getInviteText(), ShareManager.Platform.INSTAGRAM);
            dismiss();
        });
        
        whatsappButton.setOnClickListener(v -> {
            shareManager.shareToPlatform(getInviteText(), ShareManager.Platform.WHATSAPP);
            dismiss();
        });
        
        shareButton.setOnClickListener(v -> {
            shareManager.shareReferralLink();
            dismiss();
        });
    }
    
    private boolean isValidEmail(String email) {
        return android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches();
    }
    
    private void sendInviteEmail(String email) {
        // In a real app, this would send an email through backend
        // For now, just show success message
        android.widget.Toast.makeText(getContext(), 
                email + "로 초대장을 발송했습니다", 
                android.widget.Toast.LENGTH_SHORT).show();
    }
    
    private String getInviteText() {
        return "스쿼시 트레이닝 앱에 초대합니다! AI 코치와 함께 운동해요 💪";
    }
}
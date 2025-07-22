package com.squashtrainingapp.ui.activities;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;
import com.squashtrainingapp.R;
import com.squashtrainingapp.marketing.ReferralService;
import com.squashtrainingapp.marketing.ShareManager;
import com.squashtrainingapp.ui.adapters.ReferralAdapter;
import com.squashtrainingapp.ui.dialogs.InviteDialog;

import java.util.ArrayList;

public class ReferralActivity extends AppCompatActivity {
    
    // UI Components
    private TextView referralCodeText;
    private MaterialButton copyCodeButton;
    private MaterialButton shareButton;
    private TextView totalReferralsText;
    private TextView completedReferralsText;
    private TextView totalRewardText;
    private TextView nextMilestoneText;
    private TextView milestoneRewardText;
    private ProgressBar milestoneProgress;
    private RecyclerView referralsRecyclerView;
    private ProgressBar loadingProgress;
    private LinearLayout emptyStateLayout;
    private CardView statsCard;
    
    // Services
    private ReferralService referralService;
    private ShareManager shareManager;
    private ReferralAdapter adapter;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_referral);
        
        initializeServices();
        initializeViews();
        loadReferralData();
    }
    
    private void initializeServices() {
        referralService = new ReferralService(this);
        shareManager = new ShareManager(this);
    }
    
    private void initializeViews() {
        // Back button
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        // Referral code section
        referralCodeText = findViewById(R.id.referral_code_text);
        copyCodeButton = findViewById(R.id.copy_code_button);
        shareButton = findViewById(R.id.share_button);
        
        // Stats section
        totalReferralsText = findViewById(R.id.total_referrals_text);
        completedReferralsText = findViewById(R.id.completed_referrals_text);
        totalRewardText = findViewById(R.id.total_reward_text);
        nextMilestoneText = findViewById(R.id.next_milestone_text);
        milestoneRewardText = findViewById(R.id.milestone_reward_text);
        milestoneProgress = findViewById(R.id.milestone_progress);
        statsCard = findViewById(R.id.stats_card);
        
        // Referrals list
        referralsRecyclerView = findViewById(R.id.referrals_recycler_view);
        loadingProgress = findViewById(R.id.loading_progress);
        emptyStateLayout = findViewById(R.id.empty_state_layout);
        
        // Setup RecyclerView
        referralsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        adapter = new ReferralAdapter(new ArrayList<>());
        referralsRecyclerView.setAdapter(adapter);
        
        // Setup click listeners
        setupClickListeners();
    }
    
    private void setupClickListeners() {
        copyCodeButton.setOnClickListener(v -> copyReferralCode());
        
        shareButton.setOnClickListener(v -> {
            shareManager.shareReferralLink();
        });
        
        // Invite more button in empty state
        Button inviteMoreButton = findViewById(R.id.invite_more_button);
        if (inviteMoreButton != null) {
            inviteMoreButton.setOnClickListener(v -> {
                InviteDialog dialog = new InviteDialog(this);
                dialog.show();
            });
        }
    }
    
    private void loadReferralData() {
        loadingProgress.setVisibility(View.VISIBLE);
        
        // Load referral code
        referralService.generateReferralCode(new ReferralService.ReferralCallback() {
            @Override
            public void onSuccess(String referralCode) {
                runOnUiThread(() -> {
                    referralCodeText.setText(referralCode);
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    Toast.makeText(ReferralActivity.this, error, Toast.LENGTH_SHORT).show();
                });
            }
        });
        
        // Load referral stats
        referralService.getReferralStats(task -> {
            if (task.isSuccessful()) {
                ReferralService.ReferralStats stats = task.getResult();
                runOnUiThread(() -> updateStats(stats));
            }
        });
        
        // Load referrals list
        referralService.getUserReferrals(new ReferralService.ReferralListCallback() {
            @Override
            public void onSuccess(java.util.List<ReferralService.Referral> referrals) {
                runOnUiThread(() -> {
                    loadingProgress.setVisibility(View.GONE);
                    
                    if (referrals.isEmpty()) {
                        emptyStateLayout.setVisibility(View.VISIBLE);
                        referralsRecyclerView.setVisibility(View.GONE);
                    } else {
                        emptyStateLayout.setVisibility(View.GONE);
                        referralsRecyclerView.setVisibility(View.VISIBLE);
                        adapter.updateData(referrals);
                    }
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    loadingProgress.setVisibility(View.GONE);
                    Toast.makeText(ReferralActivity.this, error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    private void updateStats(ReferralService.ReferralStats stats) {
        totalReferralsText.setText(String.valueOf(stats.totalReferrals));
        completedReferralsText.setText(String.valueOf(stats.completedReferrals));
        totalRewardText.setText(stats.totalRewardDays + "일");
        
        // Milestone progress
        if (stats.nextMilestone > 0) {
            nextMilestoneText.setText(stats.completedReferrals + " / " + stats.nextMilestone);
            milestoneRewardText.setText(stats.nextMilestoneReward);
            
            int progress = (int) ((float) stats.completedReferrals / stats.nextMilestone * 100);
            milestoneProgress.setProgress(progress);
        } else {
            nextMilestoneText.setText("모든 마일스톤 달성!");
            milestoneRewardText.setText("축하합니다! 🎉");
            milestoneProgress.setProgress(100);
        }
        
        // Animate stats card
        statsCard.setAlpha(0f);
        statsCard.animate()
                .alpha(1f)
                .setDuration(500)
                .start();
    }
    
    private void copyReferralCode() {
        String code = referralCodeText.getText().toString();
        if (!code.isEmpty()) {
            ClipboardManager clipboard = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
            ClipData clip = ClipData.newPlainText("Referral Code", code);
            clipboard.setPrimaryClip(clip);
            
            Toast.makeText(this, "추천 코드가 복사되었습니다", Toast.LENGTH_SHORT).show();
            
            // Animate button
            copyCodeButton.setText("복사됨 ✓");
            copyCodeButton.postDelayed(() -> {
                copyCodeButton.setText("코드 복사");
            }, 2000);
        }
    }
}
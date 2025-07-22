package com.squashtrainingapp.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.squashtrainingapp.R;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.social.ChallengeService;
import com.squashtrainingapp.ui.adapters.ChallengesAdapter;
import com.squashtrainingapp.ui.adapters.ChallengesPagerAdapter;

import java.util.ArrayList;
import java.util.List;

public class ChallengesActivity extends AppCompatActivity implements ChallengesAdapter.ChallengeClickListener {
    
    private ViewPager2 viewPager;
    private TabLayout tabLayout;
    private RecyclerView challengesRecyclerView;
    private MaterialButton createChallengeButton;
    private ProgressBar progressBar;
    private TextView emptyView;
    
    private ChallengeService challengeService;
    private FirebaseAuthManager authManager;
    private ChallengesAdapter challengesAdapter;
    
    private int currentTab = 0; // 0: Available, 1: My Challenges, 2: Completed
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_challenges);
        
        authManager = FirebaseAuthManager.getInstance(this);
        
        initializeServices();
        initializeViews();
        setupTabs();
        loadChallenges();
    }
    
    private void initializeServices() {
        challengeService = new ChallengeService(this);
    }
    
    private void initializeViews() {
        // Back button
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        viewPager = findViewById(R.id.challenges_viewpager);
        tabLayout = findViewById(R.id.challenges_tabs);
        challengesRecyclerView = findViewById(R.id.challenges_recycler_view);
        createChallengeButton = findViewById(R.id.create_challenge_button);
        progressBar = findViewById(R.id.progress_bar);
        emptyView = findViewById(R.id.empty_view);
        
        // Setup RecyclerView
        challengesAdapter = new ChallengesAdapter(this);
        challengesRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        challengesRecyclerView.setAdapter(challengesAdapter);
        
        // Create challenge button (premium feature)
        createChallengeButton.setOnClickListener(v -> {
            if (authManager.isPremiumUser()) {
                startActivity(new Intent(this, CreateChallengeActivity.class));
            } else {
                Toast.makeText(this, "프리미엄 기능입니다", Toast.LENGTH_SHORT).show();
            }
        });
    }
    
    private void setupTabs() {
        List<String> tabTitles = new ArrayList<>();
        tabTitles.add("참여 가능");
        tabTitles.add("내 챌린지");
        tabTitles.add("완료됨");
        
        ChallengesPagerAdapter pagerAdapter = new ChallengesPagerAdapter(this, tabTitles.size());
        viewPager.setAdapter(pagerAdapter);
        
        new TabLayoutMediator(tabLayout, viewPager, (tab, position) -> {
            tab.setText(tabTitles.get(position));
        }).attach();
        
        viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                currentTab = position;
                loadChallenges();
            }
        });
    }
    
    private void loadChallenges() {
        progressBar.setVisibility(View.VISIBLE);
        emptyView.setVisibility(View.GONE);
        challengesRecyclerView.setVisibility(View.GONE);
        
        switch (currentTab) {
            case 0: // Available
                loadAvailableChallenges();
                break;
            case 1: // My Challenges
                loadMyChallenges();
                break;
            case 2: // Completed
                loadCompletedChallenges();
                break;
        }
    }
    
    private void loadAvailableChallenges() {
        challengeService.getAvailableChallenges(new ChallengeService.ChallengeCallback() {
            @Override
            public void onSuccess(List<ChallengeService.Challenge> challenges) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    if (challenges.isEmpty()) {
                        emptyView.setVisibility(View.VISIBLE);
                        emptyView.setText("현재 참여 가능한 챌린지가 없습니다");
                    } else {
                        challengesRecyclerView.setVisibility(View.VISIBLE);
                        challengesAdapter.setChallenges(challenges);
                    }
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(ChallengesActivity.this, error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    private void loadMyChallenges() {
        String userId = authManager.getCurrentUser().getUid();
        challengeService.getUserChallenges(userId, new ChallengeService.ChallengeCallback() {
            @Override
            public void onSuccess(List<ChallengeService.Challenge> challenges) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    if (challenges.isEmpty()) {
                        emptyView.setVisibility(View.VISIBLE);
                        emptyView.setText("참여 중인 챌린지가 없습니다");
                        createChallengeButton.setVisibility(View.VISIBLE);
                    } else {
                        challengesRecyclerView.setVisibility(View.VISIBLE);
                        challengesAdapter.setChallenges(challenges);
                        createChallengeButton.setVisibility(View.GONE);
                    }
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(ChallengesActivity.this, error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    private void loadCompletedChallenges() {
        // This would load completed challenges
        // For now, show empty state
        progressBar.setVisibility(View.GONE);
        emptyView.setVisibility(View.VISIBLE);
        emptyView.setText("완료된 챌린지가 없습니다");
    }
    
    @Override
    public void onChallengeClick(ChallengeService.Challenge challenge) {
        Intent intent = new Intent(this, ChallengeDetailActivity.class);
        intent.putExtra("challengeId", challenge.id);
        startActivity(intent);
    }
    
    @Override
    public void onJoinChallenge(ChallengeService.Challenge challenge) {
        challengeService.joinChallenge(challenge.id, new ChallengeService.ChallengeActionCallback() {
            @Override
            public void onSuccess(String message) {
                runOnUiThread(() -> {
                    Toast.makeText(ChallengesActivity.this, message, Toast.LENGTH_SHORT).show();
                    loadChallenges(); // Refresh list
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    Toast.makeText(ChallengesActivity.this, error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        loadChallenges(); // Refresh when returning from create challenge
    }
}
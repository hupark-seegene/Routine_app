package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.squashtrainingapp.R;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.social.LeaderboardService;
import com.squashtrainingapp.ui.adapters.LeaderboardAdapter;
import com.squashtrainingapp.ui.adapters.LeaderboardPagerAdapter;
import com.squashtrainingapp.ui.dialogs.PremiumFeatureDialog;

import java.util.ArrayList;
import java.util.List;

public class LeaderboardActivity extends AppCompatActivity {
    
    private ViewPager2 viewPager;
    private TabLayout tabLayout;
    private ChipGroup typeChipGroup;
    private ChipGroup periodChipGroup;
    private RecyclerView leaderboardRecyclerView;
    private ProgressBar progressBar;
    private TextView emptyView;
    private TextView userRankText;
    
    private LeaderboardService leaderboardService;
    private FirebaseAuthManager authManager;
    private LeaderboardAdapter leaderboardAdapter;
    
    private LeaderboardService.LeaderboardType currentType = LeaderboardService.LeaderboardType.GLOBAL_POINTS;
    private LeaderboardService.TimePeriod currentPeriod = LeaderboardService.TimePeriod.ALL_TIME;
    private int currentTab = 0; // 0: Global, 1: Friends, 2: Regional
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_leaderboard);
        
        authManager = FirebaseAuthManager.getInstance(this);
        
        // Check premium status for global leaderboard
        if (!authManager.isPremiumUser() && currentTab == 0) {
            PremiumFeatureDialog dialog = new PremiumFeatureDialog(this);
            dialog.showForGlobalLeaderboard();
            finish();
            return;
        }
        
        initializeServices();
        initializeViews();
        setupChips();
        setupTabs();
        loadLeaderboard();
    }
    
    private void initializeServices() {
        leaderboardService = new LeaderboardService(this);
    }
    
    private void initializeViews() {
        // Back button
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        viewPager = findViewById(R.id.leaderboard_viewpager);
        tabLayout = findViewById(R.id.leaderboard_tabs);
        typeChipGroup = findViewById(R.id.type_chip_group);
        periodChipGroup = findViewById(R.id.period_chip_group);
        leaderboardRecyclerView = findViewById(R.id.leaderboard_recycler_view);
        progressBar = findViewById(R.id.progress_bar);
        emptyView = findViewById(R.id.empty_view);
        userRankText = findViewById(R.id.user_rank_text);
        
        // Setup RecyclerView
        leaderboardAdapter = new LeaderboardAdapter();
        leaderboardRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        leaderboardRecyclerView.setAdapter(leaderboardAdapter);
    }
    
    private void setupChips() {
        // Type chips
        String[] types = {"포인트", "주간 운동", "월간 칼로리", "연속 기록", "레벨", "챌린지 승리"};
        LeaderboardService.LeaderboardType[] typeValues = {
            LeaderboardService.LeaderboardType.GLOBAL_POINTS,
            LeaderboardService.LeaderboardType.WEEKLY_SESSIONS,
            LeaderboardService.LeaderboardType.MONTHLY_CALORIES,
            LeaderboardService.LeaderboardType.STREAK_DAYS,
            LeaderboardService.LeaderboardType.LEVEL_RANKING,
            LeaderboardService.LeaderboardType.CHALLENGE_WINS
        };
        
        for (int i = 0; i < types.length; i++) {
            Chip chip = new Chip(this);
            chip.setText(types[i]);
            chip.setCheckable(true);
            chip.setChecked(i == 0);
            
            int index = i;
            chip.setOnClickListener(v -> {
                currentType = typeValues[index];
                loadLeaderboard();
            });
            
            typeChipGroup.addView(chip);
        }
        
        // Period chips
        String[] periods = {"전체", "일간", "주간", "월간"};
        LeaderboardService.TimePeriod[] periodValues = {
            LeaderboardService.TimePeriod.ALL_TIME,
            LeaderboardService.TimePeriod.DAILY,
            LeaderboardService.TimePeriod.WEEKLY,
            LeaderboardService.TimePeriod.MONTHLY
        };
        
        for (int i = 0; i < periods.length; i++) {
            Chip chip = new Chip(this);
            chip.setText(periods[i]);
            chip.setCheckable(true);
            chip.setChecked(i == 0);
            
            int index = i;
            chip.setOnClickListener(v -> {
                currentPeriod = periodValues[index];
                loadLeaderboard();
            });
            
            periodChipGroup.addView(chip);
        }
    }
    
    private void setupTabs() {
        List<String> tabTitles = new ArrayList<>();
        tabTitles.add("글로벌");
        tabTitles.add("친구");
        tabTitles.add("지역");
        
        LeaderboardPagerAdapter pagerAdapter = new LeaderboardPagerAdapter(this, tabTitles.size());
        viewPager.setAdapter(pagerAdapter);
        
        new TabLayoutMediator(tabLayout, viewPager, (tab, position) -> {
            tab.setText(tabTitles.get(position));
            
            // Add premium badge to global tab
            if (position == 0) {
                View customView = getLayoutInflater().inflate(R.layout.tab_with_badge, null);
                TextView tabText = customView.findViewById(R.id.tab_text);
                TextView badgeText = customView.findViewById(R.id.badge_text);
                
                tabText.setText(tabTitles.get(position));
                if (!authManager.isPremiumUser()) {
                    badgeText.setVisibility(View.VISIBLE);
                    badgeText.setText("PRO");
                } else {
                    badgeText.setVisibility(View.GONE);
                }
                
                tab.setCustomView(customView);
            }
        }).attach();
        
        viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                currentTab = position;
                
                // Check premium for global tab
                if (position == 0 && !authManager.isPremiumUser()) {
                    PremiumFeatureDialog dialog = new PremiumFeatureDialog(LeaderboardActivity.this);
                    dialog.showForGlobalLeaderboard();
                    viewPager.setCurrentItem(1); // Switch to friends tab
                    return;
                }
                
                loadLeaderboard();
            }
        });
    }
    
    private void loadLeaderboard() {
        progressBar.setVisibility(View.VISIBLE);
        emptyView.setVisibility(View.GONE);
        leaderboardRecyclerView.setVisibility(View.GONE);
        
        switch (currentTab) {
            case 0: // Global
                loadGlobalLeaderboard();
                break;
            case 1: // Friends
                loadFriendsLeaderboard();
                break;
            case 2: // Regional
                loadRegionalLeaderboard();
                break;
        }
        
        // Update user rank
        updateUserRank();
    }
    
    private void loadGlobalLeaderboard() {
        leaderboardService.getGlobalLeaderboard(currentType, currentPeriod, 100, 
                new LeaderboardService.LeaderboardCallback() {
            @Override
            public void onSuccess(List<LeaderboardService.LeaderboardEntry> entries) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    if (entries.isEmpty()) {
                        emptyView.setVisibility(View.VISIBLE);
                        emptyView.setText("아직 순위가 없습니다");
                    } else {
                        leaderboardRecyclerView.setVisibility(View.VISIBLE);
                        leaderboardAdapter.setEntries(entries);
                    }
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(LeaderboardActivity.this, error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    private void loadFriendsLeaderboard() {
        leaderboardService.getFriendsLeaderboard(currentType, currentPeriod, 
                new LeaderboardService.LeaderboardCallback() {
            @Override
            public void onSuccess(List<LeaderboardService.LeaderboardEntry> entries) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    if (entries.isEmpty()) {
                        emptyView.setVisibility(View.VISIBLE);
                        emptyView.setText("친구를 추가하여 경쟁해보세요!");
                    } else {
                        leaderboardRecyclerView.setVisibility(View.VISIBLE);
                        leaderboardAdapter.setEntries(entries);
                    }
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(LeaderboardActivity.this, error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    private void loadRegionalLeaderboard() {
        // Get user's region from preferences or profile
        String region = getSharedPreferences("user_prefs", MODE_PRIVATE)
                .getString("region", "KR");
        
        leaderboardService.getRegionalLeaderboard(region, currentType, currentPeriod, 100,
                new LeaderboardService.LeaderboardCallback() {
            @Override
            public void onSuccess(List<LeaderboardService.LeaderboardEntry> entries) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    if (entries.isEmpty()) {
                        emptyView.setVisibility(View.VISIBLE);
                        emptyView.setText("지역 순위가 없습니다");
                    } else {
                        leaderboardRecyclerView.setVisibility(View.VISIBLE);
                        leaderboardAdapter.setEntries(entries);
                    }
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(LeaderboardActivity.this, error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    private void updateUserRank() {
        String userId = authManager.getCurrentUser().getUid();
        
        leaderboardService.getUserRank(userId, currentType, currentPeriod, task -> {
            if (task.isSuccessful() && task.getResult() != null) {
                int rank = task.getResult();
                runOnUiThread(() -> {
                    userRankText.setText("나의 순위: #" + rank);
                    userRankText.setVisibility(View.VISIBLE);
                });
            } else {
                runOnUiThread(() -> userRankText.setVisibility(View.GONE));
            }
        });
    }
}
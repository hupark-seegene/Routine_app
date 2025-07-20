package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.tabs.TabLayout;
import com.squashtrainingapp.R;
import com.squashtrainingapp.managers.AchievementManager;
import com.squashtrainingapp.models.Achievement;
import com.squashtrainingapp.ui.adapters.AchievementAdapter;

import java.util.List;

public class AchievementsActivity extends AppCompatActivity {
    
    private RecyclerView recyclerView;
    private AchievementAdapter adapter;
    private AchievementManager achievementManager;
    private TabLayout tabLayout;
    private ImageButton backButton;
    private TextView titleText;
    private TextView pointsText;
    private TextView completionText;
    private ProgressBar completionProgress;
    private TextView emptyText;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_achievements);
        
        initializeViews();
        setupTabs();
        loadAchievements(0);
        updateStats();
    }
    
    private void initializeViews() {
        backButton = findViewById(R.id.back_button);
        titleText = findViewById(R.id.title_text);
        pointsText = findViewById(R.id.points_text);
        completionText = findViewById(R.id.completion_text);
        completionProgress = findViewById(R.id.completion_progress);
        recyclerView = findViewById(R.id.achievements_recycler_view);
        tabLayout = findViewById(R.id.tab_layout);
        emptyText = findViewById(R.id.empty_text);
        
        // Initialize manager
        achievementManager = new AchievementManager(this);
        
        // Setup RecyclerView with grid layout
        recyclerView.setLayoutManager(new GridLayoutManager(this, 2));
        adapter = new AchievementAdapter();
        recyclerView.setAdapter(adapter);
        
        // Back button
        backButton.setOnClickListener(v -> finish());
        
        titleText.setText("업적");
    }
    
    private void setupTabs() {
        tabLayout.addTab(tabLayout.newTab().setText("모든 업적"));
        tabLayout.addTab(tabLayout.newTab().setText("운동"));
        tabLayout.addTab(tabLayout.newTab().setText("연속"));
        tabLayout.addTab(tabLayout.newTab().setText("칼로리"));
        tabLayout.addTab(tabLayout.newTab().setText("특별"));
        
        tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                loadAchievements(tab.getPosition());
            }
            
            @Override
            public void onTabUnselected(TabLayout.Tab tab) {}
            
            @Override
            public void onTabReselected(TabLayout.Tab tab) {}
        });
    }
    
    private void loadAchievements(int tabPosition) {
        List<Achievement> achievements;
        
        switch (tabPosition) {
            case 0: // All
                achievements = achievementManager.getAllAchievements();
                break;
            case 1: // Workout
                achievements = achievementManager.getAchievementsByType(
                    Achievement.AchievementType.WORKOUT_COUNT);
                break;
            case 2: // Streak
                achievements = achievementManager.getAchievementsByType(
                    Achievement.AchievementType.STREAK);
                break;
            case 3: // Calories
                achievements = achievementManager.getAchievementsByType(
                    Achievement.AchievementType.CALORIES);
                break;
            case 4: // Special
                achievements = achievementManager.getAchievementsByType(
                    Achievement.AchievementType.SPECIAL);
                break;
            default:
                achievements = achievementManager.getAllAchievements();
        }
        
        updateAchievementList(achievements);
    }
    
    private void updateAchievementList(List<Achievement> achievements) {
        adapter.setAchievements(achievements);
        
        if (achievements.isEmpty()) {
            recyclerView.setVisibility(View.GONE);
            emptyText.setVisibility(View.VISIBLE);
            emptyText.setText("해당하는 업적이 없습니다");
        } else {
            recyclerView.setVisibility(View.VISIBLE);
            emptyText.setVisibility(View.GONE);
        }
    }
    
    private void updateStats() {
        // Points
        int totalPoints = achievementManager.getTotalPoints();
        pointsText.setText(totalPoints + " 포인트");
        
        // Completion
        int unlocked = achievementManager.getUnlockedCount();
        int total = achievementManager.getTotalCount();
        float percentage = achievementManager.getCompletionPercentage();
        
        completionText.setText(String.format("%.0f%% 완료 (%d/%d)", percentage, unlocked, total));
        completionProgress.setProgress((int) percentage);
    }
}
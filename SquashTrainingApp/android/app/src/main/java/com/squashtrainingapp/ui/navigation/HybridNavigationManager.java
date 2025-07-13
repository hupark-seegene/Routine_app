package com.squashtrainingapp.ui.navigation;

import android.app.Activity;
import android.content.Intent;
import android.view.View;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.squashtrainingapp.R;
import com.squashtrainingapp.ui.activities.*;

public class HybridNavigationManager {
    
    private Activity activity;
    private BottomNavigationView navigationView;
    private OnNavigationItemSelectedListener listener;
    
    public interface OnNavigationItemSelectedListener {
        void onHomeSelected();
        void onChecklistSelected();
        void onRecordSelected();
        void onProfileSelected();
        void onCoachSelected();
    }
    
    public HybridNavigationManager(Activity activity, BottomNavigationView navigationView) {
        this.activity = activity;
        this.navigationView = navigationView;
        setupNavigation();
    }
    
    private void setupNavigation() {
        // Set up navigation listener
        navigationView.setOnItemSelectedListener(item -> {
            int itemId = item.getItemId();
            
            if (itemId == R.id.navigation_home) {
                if (listener != null) listener.onHomeSelected();
                return true;
            } else if (itemId == R.id.navigation_checklist) {
                launchActivity(ChecklistActivity.class);
                if (listener != null) listener.onChecklistSelected();
                return true;
            } else if (itemId == R.id.navigation_record) {
                launchActivity(RecordActivity.class);
                if (listener != null) listener.onRecordSelected();
                return true;
            } else if (itemId == R.id.navigation_profile) {
                launchActivity(ProfileActivity.class);
                if (listener != null) listener.onProfileSelected();
                return true;
            } else if (itemId == R.id.navigation_coach) {
                launchActivity(CoachActivity.class);
                if (listener != null) listener.onCoachSelected();
                return true;
            }
            
            return false;
        });
        
        // Add manual click listeners as fallback
        addManualClickListeners();
    }
    
    private void addManualClickListeners() {
        // Get navigation menu items and add direct click listeners
        View navHome = navigationView.findViewById(R.id.navigation_home);
        View navChecklist = navigationView.findViewById(R.id.navigation_checklist);
        View navRecord = navigationView.findViewById(R.id.navigation_record);
        View navProfile = navigationView.findViewById(R.id.navigation_profile);
        View navCoach = navigationView.findViewById(R.id.navigation_coach);
        
        if (navHome != null) {
            navHome.setOnClickListener(v -> {
                navigationView.setSelectedItemId(R.id.navigation_home);
            });
        }
        
        if (navChecklist != null) {
            navChecklist.setOnClickListener(v -> {
                navigationView.setSelectedItemId(R.id.navigation_checklist);
            });
        }
        
        if (navRecord != null) {
            navRecord.setOnClickListener(v -> {
                navigationView.setSelectedItemId(R.id.navigation_record);
            });
        }
        
        if (navProfile != null) {
            navProfile.setOnClickListener(v -> {
                navigationView.setSelectedItemId(R.id.navigation_profile);
            });
        }
        
        if (navCoach != null) {
            navCoach.setOnClickListener(v -> {
                navigationView.setSelectedItemId(R.id.navigation_coach);
            });
        }
    }
    
    private void launchActivity(Class<?> activityClass) {
        if (!activity.getClass().equals(activityClass)) {
            Intent intent = new Intent(activity, activityClass);
            activity.startActivity(intent);
        }
    }
    
    public void setSelectedItem(int itemId) {
        navigationView.setSelectedItemId(itemId);
    }
    
    public void setOnNavigationItemSelectedListener(OnNavigationItemSelectedListener listener) {
        this.listener = listener;
    }
    
    // Static method to setup navigation in any activity
    public static void setupBottomNavigation(Activity activity, int selectedItemId) {
        BottomNavigationView navigation = activity.findViewById(R.id.bottom_navigation);
        if (navigation != null) {
            HybridNavigationManager manager = new HybridNavigationManager(activity, navigation);
            manager.setSelectedItem(selectedItemId);
        }
    }
}
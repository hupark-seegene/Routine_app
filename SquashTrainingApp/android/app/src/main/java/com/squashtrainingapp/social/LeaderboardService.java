package com.squashtrainingapp.social;

import android.content.Context;
import android.util.Log;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.models.User;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LeaderboardService {
    private static final String TAG = "LeaderboardService";
    
    private Context context;
    private FirebaseFirestore db;
    private FirebaseAuthManager authManager;
    
    // Leaderboard types
    public enum LeaderboardType {
        GLOBAL_POINTS,      // Total points earned
        WEEKLY_SESSIONS,    // Sessions this week
        MONTHLY_CALORIES,   // Calories burned this month
        STREAK_DAYS,        // Current streak
        LEVEL_RANKING,      // Player level
        CHALLENGE_WINS      // Challenge victories
    }
    
    // Time periods
    public enum TimePeriod {
        DAILY,
        WEEKLY,
        MONTHLY,
        ALL_TIME
    }
    
    public interface LeaderboardCallback {
        void onSuccess(List<LeaderboardEntry> entries);
        void onError(String error);
    }
    
    public LeaderboardService(Context context) {
        this.context = context;
        this.db = FirebaseFirestore.getInstance();
        this.authManager = FirebaseAuthManager.getInstance(context);
    }
    
    // Get global leaderboard
    public void getGlobalLeaderboard(LeaderboardType type, TimePeriod period, int limit, LeaderboardCallback callback) {
        String field = getFieldForType(type);
        long startTime = getStartTimeForPeriod(period);
        
        Query query = db.collection("users")
                .orderBy(field, Query.Direction.DESCENDING)
                .limit(limit);
        
        query.get().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                List<LeaderboardEntry> entries = new ArrayList<>();
                int rank = 1;
                
                for (QueryDocumentSnapshot document : task.getResult()) {
                    LeaderboardEntry entry = parseLeaderboardEntry(document, rank++, type);
                    if (entry != null) {
                        entries.add(entry);
                    }
                }
                
                callback.onSuccess(entries);
            } else {
                Log.e(TAG, "Failed to get leaderboard", task.getException());
                callback.onError("Failed to load leaderboard");
            }
        });
    }
    
    // Get friends leaderboard
    public void getFriendsLeaderboard(LeaderboardType type, TimePeriod period, LeaderboardCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        // First get user's friends list
        db.collection("users").document(userId).get()
                .addOnSuccessListener(document -> {
                    List<String> friendIds = (List<String>) document.get("friends");
                    if (friendIds == null || friendIds.isEmpty()) {
                        callback.onSuccess(new ArrayList<>());
                        return;
                    }
                    
                    // Add current user to the list
                    friendIds.add(userId);
                    
                    // Get friends' data
                    getFriendsData(friendIds, type, period, callback);
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to get friends list", e);
                    callback.onError("Failed to load friends");
                });
    }
    
    // Get regional leaderboard
    public void getRegionalLeaderboard(String region, LeaderboardType type, TimePeriod period, int limit, LeaderboardCallback callback) {
        String field = getFieldForType(type);
        
        Query query = db.collection("users")
                .whereEqualTo("region", region)
                .orderBy(field, Query.Direction.DESCENDING)
                .limit(limit);
        
        query.get().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                List<LeaderboardEntry> entries = new ArrayList<>();
                int rank = 1;
                
                for (QueryDocumentSnapshot document : task.getResult()) {
                    LeaderboardEntry entry = parseLeaderboardEntry(document, rank++, type);
                    if (entry != null) {
                        entries.add(entry);
                    }
                }
                
                callback.onSuccess(entries);
            } else {
                Log.e(TAG, "Failed to get regional leaderboard", task.getException());
                callback.onError("Failed to load regional leaderboard");
            }
        });
    }
    
    // Get user's rank in a specific leaderboard
    public void getUserRank(String userId, LeaderboardType type, TimePeriod period, OnCompleteListener<Integer> callback) {
        String field = getFieldForType(type);
        
        // Get user's value
        db.collection("users").document(userId).get()
                .addOnSuccessListener(userDoc -> {
                    if (!userDoc.exists()) {
                        callback.onComplete(null);
                        return;
                    }
                    
                    Number userValue = userDoc.getLong(field);
                    if (userValue == null) userValue = 0;
                    
                    // Count users with higher values
                    db.collection("users")
                            .whereGreaterThan(field, userValue)
                            .get()
                            .addOnSuccessListener(querySnapshot -> {
                                int rank = querySnapshot.size() + 1;
                                callback.onComplete(com.google.android.gms.tasks.Tasks.forResult(rank));
                            })
                            .addOnFailureListener(e -> callback.onComplete(null));
                })
                .addOnFailureListener(e -> callback.onComplete(null));
    }
    
    // Update user's leaderboard stats
    public void updateUserStats(String userId, Map<String, Object> updates) {
        // Add timestamp for period-based queries
        updates.put("lastUpdated", System.currentTimeMillis());
        
        db.collection("users").document(userId)
                .update(updates)
                .addOnFailureListener(e -> Log.e(TAG, "Failed to update user stats", e));
    }
    
    // Submit a new score/achievement
    public void submitScore(LeaderboardType type, int value) {
        String userId = authManager.getCurrentUser().getUid();
        String field = getFieldForType(type);
        
        Map<String, Object> updates = new HashMap<>();
        updates.put(field, value);
        
        // For period-based scores, also update period-specific fields
        if (type == LeaderboardType.WEEKLY_SESSIONS) {
            updates.put("weeklySessionsStartDate", getStartOfWeek());
        } else if (type == LeaderboardType.MONTHLY_CALORIES) {
            updates.put("monthlyCaloriesStartDate", getStartOfMonth());
        }
        
        updateUserStats(userId, updates);
    }
    
    private void getFriendsData(List<String> friendIds, LeaderboardType type, TimePeriod period, LeaderboardCallback callback) {
        String field = getFieldForType(type);
        List<LeaderboardEntry> entries = new ArrayList<>();
        
        // Get data for all friends
        for (String friendId : friendIds) {
            db.collection("users").document(friendId).get()
                    .addOnSuccessListener(document -> {
                        if (document.exists()) {
                            LeaderboardEntry entry = parseLeaderboardEntry(document, 0, type);
                            if (entry != null) {
                                entries.add(entry);
                            }
                        }
                        
                        // Check if all friends loaded
                        if (entries.size() == friendIds.size()) {
                            // Sort by value and assign ranks
                            entries.sort((a, b) -> Integer.compare(b.value, a.value));
                            for (int i = 0; i < entries.size(); i++) {
                                entries.get(i).rank = i + 1;
                            }
                            callback.onSuccess(entries);
                        }
                    });
        }
    }
    
    private LeaderboardEntry parseLeaderboardEntry(DocumentSnapshot document, int rank, LeaderboardType type) {
        try {
            String userId = document.getId();
            String displayName = document.getString("displayName");
            String profilePicture = document.getString("profilePicture");
            String level = document.getString("level");
            
            int value = 0;
            String field = getFieldForType(type);
            Number numValue = document.getLong(field);
            if (numValue != null) {
                value = numValue.intValue();
            }
            
            return new LeaderboardEntry(
                    userId,
                    displayName != null ? displayName : "Anonymous",
                    profilePicture,
                    rank,
                    value,
                    level != null ? level : "beginner",
                    userId.equals(authManager.getCurrentUser().getUid())
            );
        } catch (Exception e) {
            Log.e(TAG, "Failed to parse leaderboard entry", e);
            return null;
        }
    }
    
    private String getFieldForType(LeaderboardType type) {
        switch (type) {
            case GLOBAL_POINTS:
                return "points";
            case WEEKLY_SESSIONS:
                return "weeklySessions";
            case MONTHLY_CALORIES:
                return "monthlyCalories";
            case STREAK_DAYS:
                return "currentStreak";
            case LEVEL_RANKING:
                return "levelNumeric"; // Numeric representation of level
            case CHALLENGE_WINS:
                return "challengeWins";
            default:
                return "points";
        }
    }
    
    private long getStartTimeForPeriod(TimePeriod period) {
        long now = System.currentTimeMillis();
        switch (period) {
            case DAILY:
                return now - (24 * 60 * 60 * 1000); // 24 hours
            case WEEKLY:
                return getStartOfWeek();
            case MONTHLY:
                return getStartOfMonth();
            case ALL_TIME:
            default:
                return 0;
        }
    }
    
    private long getStartOfWeek() {
        // Get start of current week (Monday)
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.set(java.util.Calendar.DAY_OF_WEEK, java.util.Calendar.MONDAY);
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
        cal.set(java.util.Calendar.MINUTE, 0);
        cal.set(java.util.Calendar.SECOND, 0);
        cal.set(java.util.Calendar.MILLISECOND, 0);
        return cal.getTimeInMillis();
    }
    
    private long getStartOfMonth() {
        // Get start of current month
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
        cal.set(java.util.Calendar.MINUTE, 0);
        cal.set(java.util.Calendar.SECOND, 0);
        cal.set(java.util.Calendar.MILLISECOND, 0);
        return cal.getTimeInMillis();
    }
    
    // Leaderboard entry model
    public static class LeaderboardEntry {
        public String userId;
        public String displayName;
        public String profilePicture;
        public int rank;
        public int value;
        public String level;
        public boolean isCurrentUser;
        
        public LeaderboardEntry(String userId, String displayName, String profilePicture, 
                              int rank, int value, String level, boolean isCurrentUser) {
            this.userId = userId;
            this.displayName = displayName;
            this.profilePicture = profilePicture;
            this.rank = rank;
            this.value = value;
            this.level = level;
            this.isCurrentUser = isCurrentUser;
        }
    }
}
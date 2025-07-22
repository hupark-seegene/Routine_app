package com.squashtrainingapp.social;

import android.content.Context;
import android.util.Log;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.squashtrainingapp.auth.FirebaseAuthManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChallengeService {
    private static final String TAG = "ChallengeService";
    
    private Context context;
    private FirebaseFirestore db;
    private FirebaseAuthManager authManager;
    
    // Challenge types
    public enum ChallengeType {
        DAILY_WORKOUT,      // Complete a workout today
        WEEKLY_STREAK,      // Maintain streak for a week
        CALORIE_BURN,       // Burn X calories
        SESSION_DURATION,   // Complete X minutes
        SKILL_CHALLENGE,    // Complete specific exercises
        TEAM_CHALLENGE,     // Team-based competition
        TOURNAMENT          // Multi-round competition
    }
    
    // Challenge status
    public enum ChallengeStatus {
        PENDING,            // Waiting to start
        ACTIVE,             // Currently running
        COMPLETED,          // Successfully completed
        FAILED,             // Failed to complete
        EXPIRED             // Time expired
    }
    
    public interface ChallengeCallback {
        void onSuccess(List<Challenge> challenges);
        void onError(String error);
    }
    
    public interface ChallengeActionCallback {
        void onSuccess(String message);
        void onError(String error);
    }
    
    public ChallengeService(Context context) {
        this.context = context;
        this.db = FirebaseFirestore.getInstance();
        this.authManager = FirebaseAuthManager.getInstance(context);
    }
    
    // Get available challenges
    public void getAvailableChallenges(ChallengeCallback callback) {
        long currentTime = System.currentTimeMillis();
        
        db.collection("challenges")
                .whereEqualTo("status", ChallengeStatus.ACTIVE.name())
                .whereLessThan("startTime", currentTime)
                .whereGreaterThan("endTime", currentTime)
                .orderBy("endTime")
                .limit(20)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        List<Challenge> challenges = new ArrayList<>();
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            Challenge challenge = parseChallengeDocument(doc);
                            if (challenge != null) {
                                challenges.add(challenge);
                            }
                        }
                        callback.onSuccess(challenges);
                    } else {
                        Log.e(TAG, "Failed to get challenges", task.getException());
                        callback.onError("Failed to load challenges");
                    }
                });
    }
    
    // Get user's active challenges
    public void getUserChallenges(String userId, ChallengeCallback callback) {
        db.collection("userChallenges")
                .whereEqualTo("userId", userId)
                .whereEqualTo("status", ChallengeStatus.ACTIVE.name())
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        List<Challenge> challenges = new ArrayList<>();
                        List<String> challengeIds = new ArrayList<>();
                        
                        // Get challenge IDs
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            challengeIds.add(doc.getString("challengeId"));
                        }
                        
                        if (challengeIds.isEmpty()) {
                            callback.onSuccess(challenges);
                            return;
                        }
                        
                        // Fetch challenge details
                        fetchChallengeDetails(challengeIds, callback);
                    } else {
                        Log.e(TAG, "Failed to get user challenges", task.getException());
                        callback.onError("Failed to load your challenges");
                    }
                });
    }
    
    // Join a challenge
    public void joinChallenge(String challengeId, ChallengeActionCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        // First check if already joined
        db.collection("userChallenges")
                .whereEqualTo("userId", userId)
                .whereEqualTo("challengeId", challengeId)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful() && !task.getResult().isEmpty()) {
                        callback.onError("Already joined this challenge");
                        return;
                    }
                    
                    // Create user challenge entry
                    Map<String, Object> userChallenge = new HashMap<>();
                    userChallenge.put("userId", userId);
                    userChallenge.put("challengeId", challengeId);
                    userChallenge.put("status", ChallengeStatus.ACTIVE.name());
                    userChallenge.put("joinedAt", System.currentTimeMillis());
                    userChallenge.put("progress", 0);
                    
                    db.collection("userChallenges")
                            .add(userChallenge)
                            .addOnSuccessListener(ref -> {
                                // Increment participant count
                                incrementParticipants(challengeId);
                                callback.onSuccess("Successfully joined challenge!");
                            })
                            .addOnFailureListener(e -> {
                                Log.e(TAG, "Failed to join challenge", e);
                                callback.onError("Failed to join challenge");
                            });
                });
    }
    
    // Create a new challenge
    public void createChallenge(Challenge challenge, ChallengeActionCallback callback) {
        String creatorId = authManager.getCurrentUser().getUid();
        
        Map<String, Object> challengeData = new HashMap<>();
        challengeData.put("creatorId", creatorId);
        challengeData.put("title", challenge.title);
        challengeData.put("description", challenge.description);
        challengeData.put("type", challenge.type.name());
        challengeData.put("status", ChallengeStatus.ACTIVE.name());
        challengeData.put("startTime", challenge.startTime);
        challengeData.put("endTime", challenge.endTime);
        challengeData.put("targetValue", challenge.targetValue);
        challengeData.put("rewardPoints", challenge.rewardPoints);
        challengeData.put("participantCount", 0);
        challengeData.put("createdAt", System.currentTimeMillis());
        
        if (challenge.isTeamChallenge) {
            challengeData.put("isTeamChallenge", true);
            challengeData.put("maxTeamSize", challenge.maxTeamSize);
        }
        
        db.collection("challenges")
                .add(challengeData)
                .addOnSuccessListener(ref -> {
                    // Auto-join creator to the challenge
                    joinChallenge(ref.getId(), new ChallengeActionCallback() {
                        @Override
                        public void onSuccess(String message) {
                            callback.onSuccess("Challenge created successfully!");
                        }
                        
                        @Override
                        public void onError(String error) {
                            callback.onSuccess("Challenge created! Join manually to participate.");
                        }
                    });
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to create challenge", e);
                    callback.onError("Failed to create challenge");
                });
    }
    
    // Update challenge progress
    public void updateProgress(String challengeId, int progress, ChallengeActionCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        db.collection("userChallenges")
                .whereEqualTo("userId", userId)
                .whereEqualTo("challengeId", challengeId)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful() && !task.getResult().isEmpty()) {
                        DocumentSnapshot doc = task.getResult().getDocuments().get(0);
                        String docId = doc.getId();
                        
                        Map<String, Object> updates = new HashMap<>();
                        updates.put("progress", progress);
                        updates.put("lastUpdated", System.currentTimeMillis());
                        
                        // Check if challenge completed
                        db.collection("challenges").document(challengeId).get()
                                .addOnSuccessListener(challengeDoc -> {
                                    int targetValue = challengeDoc.getLong("targetValue").intValue();
                                    if (progress >= targetValue) {
                                        updates.put("status", ChallengeStatus.COMPLETED.name());
                                        updates.put("completedAt", System.currentTimeMillis());
                                        
                                        // Award points
                                        int rewardPoints = challengeDoc.getLong("rewardPoints").intValue();
                                        awardPoints(userId, rewardPoints);
                                        
                                        // Update progress
                                        db.collection("userChallenges").document(docId)
                                                .update(updates)
                                                .addOnSuccessListener(aVoid -> {
                                                    callback.onSuccess("Challenge completed! You earned " + rewardPoints + " points!");
                                                })
                                                .addOnFailureListener(e -> {
                                                    Log.e(TAG, "Failed to update progress", e);
                                                    callback.onError("Failed to update progress");
                                                });
                                    } else {
                                        // Update progress
                                        db.collection("userChallenges").document(docId)
                                                .update(updates)
                                                .addOnSuccessListener(aVoid -> {
                                                    callback.onSuccess("Progress updated: " + progress + "/" + targetValue);
                                                })
                                                .addOnFailureListener(e -> {
                                                    Log.e(TAG, "Failed to update progress", e);
                                                    callback.onError("Failed to update progress");
                                                });
                                    }
                                });
                    } else {
                        callback.onError("Challenge not found");
                    }
                });
    }
    
    // Get challenge leaderboard
    public void getChallengeLeaderboard(String challengeId, OnCompleteListener<List<ChallengeParticipant>> callback) {
        db.collection("userChallenges")
                .whereEqualTo("challengeId", challengeId)
                .orderBy("progress", Query.Direction.DESCENDING)
                .limit(50)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        List<ChallengeParticipant> participants = new ArrayList<>();
                        int rank = 1;
                        
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            ChallengeParticipant participant = new ChallengeParticipant(
                                    doc.getString("userId"),
                                    "",  // Will be filled from user data
                                    doc.getLong("progress").intValue(),
                                    rank++,
                                    ChallengeStatus.valueOf(doc.getString("status"))
                            );
                            participants.add(participant);
                        }
                        
                        // Fetch user names
                        fetchParticipantNames(participants, callback);
                    } else {
                        Log.e(TAG, "Failed to get leaderboard", task.getException());
                        callback.onComplete(com.google.android.gms.tasks.Tasks.forException(task.getException()));
                    }
                });
    }
    
    private void fetchChallengeDetails(List<String> challengeIds, ChallengeCallback callback) {
        List<Challenge> challenges = new ArrayList<>();
        
        for (String id : challengeIds) {
            db.collection("challenges").document(id).get()
                    .addOnSuccessListener(doc -> {
                        Challenge challenge = parseChallengeDocument(doc);
                        if (challenge != null) {
                            challenges.add(challenge);
                        }
                        
                        if (challenges.size() == challengeIds.size()) {
                            callback.onSuccess(challenges);
                        }
                    });
        }
    }
    
    private void fetchParticipantNames(List<ChallengeParticipant> participants, 
                                     OnCompleteListener<List<ChallengeParticipant>> callback) {
        if (participants.isEmpty()) {
            callback.onComplete(com.google.android.gms.tasks.Tasks.forResult(participants));
            return;
        }
        
        int[] completed = {0};
        for (ChallengeParticipant participant : participants) {
            db.collection("users").document(participant.userId).get()
                    .addOnSuccessListener(doc -> {
                        participant.displayName = doc.getString("displayName");
                        completed[0]++;
                        
                        if (completed[0] == participants.size()) {
                            callback.onComplete(com.google.android.gms.tasks.Tasks.forResult(participants));
                        }
                    });
        }
    }
    
    private Challenge parseChallengeDocument(DocumentSnapshot doc) {
        try {
            Challenge challenge = new Challenge();
            challenge.id = doc.getId();
            challenge.title = doc.getString("title");
            challenge.description = doc.getString("description");
            challenge.type = ChallengeType.valueOf(doc.getString("type"));
            challenge.status = ChallengeStatus.valueOf(doc.getString("status"));
            challenge.startTime = doc.getLong("startTime");
            challenge.endTime = doc.getLong("endTime");
            challenge.targetValue = doc.getLong("targetValue").intValue();
            challenge.rewardPoints = doc.getLong("rewardPoints").intValue();
            challenge.participantCount = doc.getLong("participantCount").intValue();
            challenge.creatorId = doc.getString("creatorId");
            challenge.isTeamChallenge = doc.getBoolean("isTeamChallenge") != null ? 
                    doc.getBoolean("isTeamChallenge") : false;
            
            return challenge;
        } catch (Exception e) {
            Log.e(TAG, "Failed to parse challenge", e);
            return null;
        }
    }
    
    private void incrementParticipants(String challengeId) {
        db.collection("challenges").document(challengeId)
                .update("participantCount", com.google.firebase.firestore.FieldValue.increment(1));
    }
    
    private void awardPoints(String userId, int points) {
        Map<String, Object> updates = new HashMap<>();
        updates.put("points", com.google.firebase.firestore.FieldValue.increment(points));
        updates.put("challengeWins", com.google.firebase.firestore.FieldValue.increment(1));
        
        db.collection("users").document(userId).update(updates);
    }
    
    // Challenge model
    public static class Challenge {
        public String id;
        public String title;
        public String description;
        public ChallengeType type;
        public ChallengeStatus status;
        public long startTime;
        public long endTime;
        public int targetValue;
        public int rewardPoints;
        public int participantCount;
        public String creatorId;
        public boolean isTeamChallenge;
        public int maxTeamSize;
        
        public Challenge() {}
        
        public Challenge(String title, String description, ChallengeType type, 
                        long startTime, long endTime, int targetValue, int rewardPoints) {
            this.title = title;
            this.description = description;
            this.type = type;
            this.startTime = startTime;
            this.endTime = endTime;
            this.targetValue = targetValue;
            this.rewardPoints = rewardPoints;
            this.status = ChallengeStatus.ACTIVE;
        }
    }
    
    // Challenge participant model
    public static class ChallengeParticipant {
        public String userId;
        public String displayName;
        public int progress;
        public int rank;
        public ChallengeStatus status;
        
        public ChallengeParticipant(String userId, String displayName, int progress, 
                                   int rank, ChallengeStatus status) {
            this.userId = userId;
            this.displayName = displayName;
            this.progress = progress;
            this.rank = rank;
            this.status = status;
        }
    }
}
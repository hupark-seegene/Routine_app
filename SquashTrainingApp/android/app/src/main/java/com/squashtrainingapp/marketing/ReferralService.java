package com.squashtrainingapp.marketing;

import android.content.Context;
import android.util.Log;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.squashtrainingapp.auth.FirebaseAuthManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

public class ReferralService {
    private static final String TAG = "ReferralService";
    
    private Context context;
    private FirebaseFirestore db;
    private FirebaseAuthManager authManager;
    
    // Referral status
    public enum ReferralStatus {
        PENDING,        // Invited but not signed up
        COMPLETED,      // Signed up
        REWARDED        // Reward claimed
    }
    
    // Reward types
    public enum RewardType {
        REFERRER_MONTH_FREE(30),        // 30 days free for referrer
        REFEREE_HALF_PRICE(50),         // 50% discount for referee
        BONUS_WEEK(7),                  // Bonus week for milestones
        PREMIUM_CONTENT(0);             // Access to premium content
        
        private final int value;
        
        RewardType(int value) {
            this.value = value;
        }
        
        public int getValue() {
            return value;
        }
    }
    
    public interface ReferralCallback {
        void onSuccess(String referralCode);
        void onError(String error);
    }
    
    public interface ReferralListCallback {
        void onSuccess(List<Referral> referrals);
        void onError(String error);
    }
    
    public interface RewardCallback {
        void onSuccess(String message);
        void onError(String error);
    }
    
    public ReferralService(Context context) {
        this.context = context;
        this.db = FirebaseFirestore.getInstance();
        this.authManager = FirebaseAuthManager.getInstance(context);
    }
    
    // Generate unique referral code for user
    public void generateReferralCode(ReferralCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        // Check if user already has a code
        db.collection("referralCodes")
                .whereEqualTo("userId", userId)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful() && !task.getResult().isEmpty()) {
                        // Return existing code
                        DocumentSnapshot doc = task.getResult().getDocuments().get(0);
                        String existingCode = doc.getString("code");
                        callback.onSuccess(existingCode);
                    } else {
                        // Generate new code
                        createNewReferralCode(userId, callback);
                    }
                });
    }
    
    private void createNewReferralCode(String userId, ReferralCallback callback) {
        String code = generateUniqueCode();
        
        // Check if code is unique
        db.collection("referralCodes")
                .whereEqualTo("code", code)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful() && task.getResult().isEmpty()) {
                        // Code is unique, save it
                        Map<String, Object> referralData = new HashMap<>();
                        referralData.put("userId", userId);
                        referralData.put("code", code);
                        referralData.put("createdAt", System.currentTimeMillis());
                        referralData.put("usageCount", 0);
                        referralData.put("totalRewards", 0);
                        
                        db.collection("referralCodes")
                                .add(referralData)
                                .addOnSuccessListener(ref -> {
                                    callback.onSuccess(code);
                                })
                                .addOnFailureListener(e -> {
                                    Log.e(TAG, "Failed to save referral code", e);
                                    callback.onError("Failed to generate referral code");
                                });
                    } else {
                        // Code exists, try again
                        createNewReferralCode(userId, callback);
                    }
                });
    }
    
    // Apply referral code
    public void applyReferralCode(String code, RewardCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        // Validate code
        db.collection("referralCodes")
                .whereEqualTo("code", code.toUpperCase())
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful() && !task.getResult().isEmpty()) {
                        DocumentSnapshot codeDoc = task.getResult().getDocuments().get(0);
                        String referrerId = codeDoc.getString("userId");
                        
                        if (referrerId.equals(userId)) {
                            callback.onError("자신의 추천 코드는 사용할 수 없습니다");
                            return;
                        }
                        
                        // Check if already used a referral code
                        checkReferralUsage(userId, referrerId, code, callback);
                    } else {
                        callback.onError("유효하지 않은 추천 코드입니다");
                    }
                });
    }
    
    private void checkReferralUsage(String userId, String referrerId, String code, RewardCallback callback) {
        db.collection("referrals")
                .whereEqualTo("refereeId", userId)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful() && task.getResult().isEmpty()) {
                        // First time using referral
                        createReferral(referrerId, userId, code, callback);
                    } else {
                        callback.onError("이미 추천 코드를 사용하셨습니다");
                    }
                });
    }
    
    private void createReferral(String referrerId, String refereeId, String code, RewardCallback callback) {
        Map<String, Object> referralData = new HashMap<>();
        referralData.put("referrerId", referrerId);
        referralData.put("refereeId", refereeId);
        referralData.put("code", code);
        referralData.put("status", ReferralStatus.COMPLETED.name());
        referralData.put("createdAt", System.currentTimeMillis());
        referralData.put("referrerRewarded", false);
        referralData.put("refereeRewarded", false);
        
        db.collection("referrals")
                .add(referralData)
                .addOnSuccessListener(ref -> {
                    // Apply rewards
                    applyReferralRewards(referrerId, refereeId, ref.getId(), callback);
                    
                    // Update code usage count
                    incrementCodeUsage(code);
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to create referral", e);
                    callback.onError("추천 등록에 실패했습니다");
                });
    }
    
    private void applyReferralRewards(String referrerId, String refereeId, String referralId, RewardCallback callback) {
        // Apply referrer reward (1 month free)
        applyReward(referrerId, RewardType.REFERRER_MONTH_FREE, referralId, true);
        
        // Apply referee reward (50% discount)
        applyReward(refereeId, RewardType.REFEREE_HALF_PRICE, referralId, false);
        
        callback.onSuccess("추천 코드가 적용되었습니다! 첫 달 50% 할인 혜택을 받으세요.");
    }
    
    private void applyReward(String userId, RewardType rewardType, String referralId, boolean isReferrer) {
        Map<String, Object> rewardData = new HashMap<>();
        rewardData.put("userId", userId);
        rewardData.put("type", rewardType.name());
        rewardData.put("value", rewardType.getValue());
        rewardData.put("referralId", referralId);
        rewardData.put("isReferrer", isReferrer);
        rewardData.put("applied", false);
        rewardData.put("createdAt", System.currentTimeMillis());
        
        db.collection("rewards").add(rewardData);
        
        // Update referral status
        Map<String, Object> update = new HashMap<>();
        update.put(isReferrer ? "referrerRewarded" : "refereeRewarded", true);
        db.collection("referrals").document(referralId).update(update);
    }
    
    // Get user's referrals
    public void getUserReferrals(ReferralListCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        db.collection("referrals")
                .whereEqualTo("referrerId", userId)
                .orderBy("createdAt", com.google.firebase.firestore.Query.Direction.DESCENDING)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        List<Referral> referrals = new ArrayList<>();
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            Referral referral = parseReferralDocument(doc);
                            if (referral != null) {
                                referrals.add(referral);
                            }
                        }
                        
                        // Fetch user names
                        fetchReferralUserNames(referrals, callback);
                    } else {
                        Log.e(TAG, "Failed to get referrals", task.getException());
                        callback.onError("추천 내역을 불러올 수 없습니다");
                    }
                });
    }
    
    // Get referral statistics
    public void getReferralStats(OnCompleteListener<ReferralStats> callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        db.collection("referrals")
                .whereEqualTo("referrerId", userId)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        ReferralStats stats = new ReferralStats();
                        stats.totalReferrals = task.getResult().size();
                        
                        int completed = 0;
                        int pending = 0;
                        
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            String status = doc.getString("status");
                            if (ReferralStatus.COMPLETED.name().equals(status) || 
                                ReferralStatus.REWARDED.name().equals(status)) {
                                completed++;
                            } else {
                                pending++;
                            }
                        }
                        
                        stats.completedReferrals = completed;
                        stats.pendingReferrals = pending;
                        stats.totalRewardDays = completed * RewardType.REFERRER_MONTH_FREE.getValue();
                        
                        // Check for milestone rewards
                        stats.nextMilestone = getNextMilestone(completed);
                        stats.nextMilestoneReward = getMilestoneReward(stats.nextMilestone);
                        
                        callback.onComplete(com.google.android.gms.tasks.Tasks.forResult(stats));
                    } else {
                        callback.onComplete(com.google.android.gms.tasks.Tasks.forException(task.getException()));
                    }
                });
    }
    
    private String generateUniqueCode() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder code = new StringBuilder();
        Random random = new Random();
        
        for (int i = 0; i < 6; i++) {
            code.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        return code.toString();
    }
    
    private void incrementCodeUsage(String code) {
        db.collection("referralCodes")
                .whereEqualTo("code", code)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful() && !task.getResult().isEmpty()) {
                        String docId = task.getResult().getDocuments().get(0).getId();
                        db.collection("referralCodes").document(docId)
                                .update("usageCount", com.google.firebase.firestore.FieldValue.increment(1));
                    }
                });
    }
    
    private void fetchReferralUserNames(List<Referral> referrals, ReferralListCallback callback) {
        if (referrals.isEmpty()) {
            callback.onSuccess(referrals);
            return;
        }
        
        int[] completed = {0};
        for (Referral referral : referrals) {
            db.collection("users").document(referral.refereeId).get()
                    .addOnSuccessListener(doc -> {
                        referral.refereeName = doc.getString("displayName");
                        referral.refereeEmail = doc.getString("email");
                        
                        completed[0]++;
                        if (completed[0] == referrals.size()) {
                            callback.onSuccess(referrals);
                        }
                    });
        }
    }
    
    private Referral parseReferralDocument(DocumentSnapshot doc) {
        try {
            Referral referral = new Referral();
            referral.id = doc.getId();
            referral.referrerId = doc.getString("referrerId");
            referral.refereeId = doc.getString("refereeId");
            referral.code = doc.getString("code");
            referral.status = ReferralStatus.valueOf(doc.getString("status"));
            referral.createdAt = doc.getLong("createdAt");
            referral.referrerRewarded = doc.getBoolean("referrerRewarded");
            referral.refereeRewarded = doc.getBoolean("refereeRewarded");
            
            return referral;
        } catch (Exception e) {
            Log.e(TAG, "Failed to parse referral", e);
            return null;
        }
    }
    
    private int getNextMilestone(int currentReferrals) {
        int[] milestones = {3, 5, 10, 25, 50, 100};
        for (int milestone : milestones) {
            if (currentReferrals < milestone) {
                return milestone;
            }
        }
        return 0; // No more milestones
    }
    
    private String getMilestoneReward(int milestone) {
        switch (milestone) {
            case 3:
                return "보너스 1주";
            case 5:
                return "프리미엄 콘텐츠 접근권";
            case 10:
                return "보너스 1개월";
            case 25:
                return "VIP 배지 + 보너스 2개월";
            case 50:
                return "평생 20% 할인";
            case 100:
                return "평생 무료 이용권";
            default:
                return "";
        }
    }
    
    // Models
    public static class Referral {
        public String id;
        public String referrerId;
        public String refereeId;
        public String refereeName;
        public String refereeEmail;
        public String code;
        public ReferralStatus status;
        public long createdAt;
        public boolean referrerRewarded;
        public boolean refereeRewarded;
    }
    
    public static class ReferralStats {
        public int totalReferrals;
        public int completedReferrals;
        public int pendingReferrals;
        public int totalRewardDays;
        public int nextMilestone;
        public String nextMilestoneReward;
    }
}
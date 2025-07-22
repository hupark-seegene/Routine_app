package com.squashtrainingapp.marketplace;

import android.content.Context;
import android.util.Log;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.squashtrainingapp.auth.FirebaseAuthManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MarketplaceService {
    private static final String TAG = "MarketplaceService";
    
    private Context context;
    private FirebaseFirestore db;
    private FirebaseStorage storage;
    private FirebaseAuthManager authManager;
    
    // Content types
    public enum ContentType {
        TRAINING_PROGRAM,       // Complete training programs
        DRILL_COLLECTION,       // Sets of drills
        VIDEO_TUTORIAL,         // Video lessons
        TECHNIQUE_GUIDE,        // Written guides
        NUTRITION_PLAN,         // Diet plans
        FITNESS_ROUTINE,        // Workout routines
        MATCH_ANALYSIS,         // Pro match breakdowns
        AUDIO_COACHING          // Audio coaching sessions
    }
    
    // Content status
    public enum ContentStatus {
        DRAFT,                  // Being created
        PENDING_REVIEW,         // Submitted for review
        APPROVED,               // Available for sale
        REJECTED,               // Needs revision
        ARCHIVED                // No longer available
    }
    
    // Pricing tiers
    public enum PriceTier {
        FREE(0),
        BASIC(499),             // $4.99
        STANDARD(999),          // $9.99
        PREMIUM(1999),          // $19.99
        PRO(2999);              // $29.99
        
        private final int priceInCents;
        
        PriceTier(int priceInCents) {
            this.priceInCents = priceInCents;
        }
        
        public int getPriceInCents() {
            return priceInCents;
        }
    }
    
    public interface ContentCallback {
        void onSuccess(List<MarketplaceContent> contents);
        void onError(String error);
    }
    
    public interface PurchaseCallback {
        void onSuccess(String message);
        void onError(String error);
    }
    
    public interface UploadCallback {
        void onProgress(int progress);
        void onSuccess(String contentId);
        void onError(String error);
    }
    
    public MarketplaceService(Context context) {
        this.context = context;
        this.db = FirebaseFirestore.getInstance();
        this.storage = FirebaseStorage.getInstance();
        this.authManager = FirebaseAuthManager.getInstance(context);
    }
    
    // Browse marketplace content
    public void browseContent(ContentType type, String sortBy, int limit, ContentCallback callback) {
        Query query = db.collection("marketplaceContent")
                .whereEqualTo("status", ContentStatus.APPROVED.name())
                .limit(limit);
        
        if (type != null) {
            query = query.whereEqualTo("type", type.name());
        }
        
        // Apply sorting
        if ("popular".equals(sortBy)) {
            query = query.orderBy("purchaseCount", Query.Direction.DESCENDING);
        } else if ("newest".equals(sortBy)) {
            query = query.orderBy("createdAt", Query.Direction.DESCENDING);
        } else if ("rating".equals(sortBy)) {
            query = query.orderBy("averageRating", Query.Direction.DESCENDING);
        } else if ("price_low".equals(sortBy)) {
            query = query.orderBy("priceInCents", Query.Direction.ASCENDING);
        } else if ("price_high".equals(sortBy)) {
            query = query.orderBy("priceInCents", Query.Direction.DESCENDING);
        }
        
        query.get().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                List<MarketplaceContent> contents = new ArrayList<>();
                for (QueryDocumentSnapshot doc : task.getResult()) {
                    MarketplaceContent content = parseContentDocument(doc);
                    if (content != null) {
                        contents.add(content);
                    }
                }
                callback.onSuccess(contents);
            } else {
                Log.e(TAG, "Failed to browse content", task.getException());
                callback.onError("Failed to load marketplace content");
            }
        });
    }
    
    // Search content
    public void searchContent(String query, ContentCallback callback) {
        // In a production app, you'd use a proper search service like Algolia
        // For now, we'll do a simple title search
        db.collection("marketplaceContent")
                .whereEqualTo("status", ContentStatus.APPROVED.name())
                .whereGreaterThanOrEqualTo("title", query)
                .whereLessThanOrEqualTo("title", query + "\uf8ff")
                .limit(20)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        List<MarketplaceContent> contents = new ArrayList<>();
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            MarketplaceContent content = parseContentDocument(doc);
                            if (content != null) {
                                contents.add(content);
                            }
                        }
                        callback.onSuccess(contents);
                    } else {
                        Log.e(TAG, "Failed to search content", task.getException());
                        callback.onError("Search failed");
                    }
                });
    }
    
    // Get user's purchased content
    public void getPurchasedContent(ContentCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        db.collection("userPurchases")
                .whereEqualTo("userId", userId)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        List<String> contentIds = new ArrayList<>();
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            contentIds.add(doc.getString("contentId"));
                        }
                        
                        if (contentIds.isEmpty()) {
                            callback.onSuccess(new ArrayList<>());
                            return;
                        }
                        
                        // Fetch content details
                        fetchContentDetails(contentIds, callback);
                    } else {
                        Log.e(TAG, "Failed to get purchases", task.getException());
                        callback.onError("Failed to load purchased content");
                    }
                });
    }
    
    // Get user's created content
    public void getCreatedContent(ContentCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        db.collection("marketplaceContent")
                .whereEqualTo("creatorId", userId)
                .orderBy("createdAt", Query.Direction.DESCENDING)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        List<MarketplaceContent> contents = new ArrayList<>();
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            MarketplaceContent content = parseContentDocument(doc);
                            if (content != null) {
                                contents.add(content);
                            }
                        }
                        callback.onSuccess(contents);
                    } else {
                        Log.e(TAG, "Failed to get created content", task.getException());
                        callback.onError("Failed to load your content");
                    }
                });
    }
    
    // Purchase content
    public void purchaseContent(String contentId, PurchaseCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        // First check if already purchased
        db.collection("userPurchases")
                .whereEqualTo("userId", userId)
                .whereEqualTo("contentId", contentId)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful() && !task.getResult().isEmpty()) {
                        callback.onError("You already own this content");
                        return;
                    }
                    
                    // Get content details
                    db.collection("marketplaceContent").document(contentId).get()
                            .addOnSuccessListener(doc -> {
                                int priceInCents = doc.getLong("priceInCents").intValue();
                                
                                if (priceInCents == 0) {
                                    // Free content - grant access immediately
                                    grantContentAccess(userId, contentId, callback);
                                } else {
                                    // Paid content - initiate payment flow
                                    // In a real app, you'd integrate with Google Play Billing here
                                    processPurchase(userId, contentId, priceInCents, callback);
                                }
                            })
                            .addOnFailureListener(e -> {
                                Log.e(TAG, "Failed to get content details", e);
                                callback.onError("Failed to process purchase");
                            });
                });
    }
    
    // Create new content
    public void createContent(MarketplaceContent content, UploadCallback callback) {
        String creatorId = authManager.getCurrentUser().getUid();
        
        Map<String, Object> contentData = new HashMap<>();
        contentData.put("creatorId", creatorId);
        contentData.put("title", content.title);
        contentData.put("description", content.description);
        contentData.put("type", content.type.name());
        contentData.put("status", ContentStatus.DRAFT.name());
        contentData.put("priceInCents", content.priceInCents);
        contentData.put("tags", content.tags);
        contentData.put("difficulty", content.difficulty);
        contentData.put("duration", content.duration);
        contentData.put("createdAt", System.currentTimeMillis());
        contentData.put("purchaseCount", 0);
        contentData.put("averageRating", 0.0);
        contentData.put("ratingCount", 0);
        
        db.collection("marketplaceContent")
                .add(contentData)
                .addOnSuccessListener(ref -> {
                    content.id = ref.getId();
                    
                    // Upload associated files if any
                    if (content.fileUrl != null) {
                        uploadContentFile(content.id, content.fileUrl, callback);
                    } else {
                        callback.onSuccess(content.id);
                    }
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to create content", e);
                    callback.onError("Failed to create content");
                });
    }
    
    // Submit content for review
    public void submitForReview(String contentId, PurchaseCallback callback) {
        Map<String, Object> updates = new HashMap<>();
        updates.put("status", ContentStatus.PENDING_REVIEW.name());
        updates.put("submittedAt", System.currentTimeMillis());
        
        db.collection("marketplaceContent").document(contentId)
                .update(updates)
                .addOnSuccessListener(aVoid -> {
                    callback.onSuccess("Content submitted for review");
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to submit for review", e);
                    callback.onError("Failed to submit content");
                });
    }
    
    // Rate content
    public void rateContent(String contentId, float rating, String review, PurchaseCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        // Check if user has purchased the content
        db.collection("userPurchases")
                .whereEqualTo("userId", userId)
                .whereEqualTo("contentId", contentId)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful() && task.getResult().isEmpty()) {
                        callback.onError("You must purchase this content to rate it");
                        return;
                    }
                    
                    // Save rating
                    Map<String, Object> ratingData = new HashMap<>();
                    ratingData.put("userId", userId);
                    ratingData.put("contentId", contentId);
                    ratingData.put("rating", rating);
                    ratingData.put("review", review);
                    ratingData.put("createdAt", System.currentTimeMillis());
                    
                    db.collection("contentRatings")
                            .add(ratingData)
                            .addOnSuccessListener(ref -> {
                                // Update content's average rating
                                updateContentRating(contentId);
                                callback.onSuccess("Thank you for your review!");
                            })
                            .addOnFailureListener(e -> {
                                Log.e(TAG, "Failed to save rating", e);
                                callback.onError("Failed to submit rating");
                            });
                });
    }
    
    // Get content statistics for creators
    public void getContentStats(String contentId, OnCompleteListener<ContentStats> callback) {
        db.collection("marketplaceContent").document(contentId).get()
                .addOnSuccessListener(doc -> {
                    ContentStats stats = new ContentStats();
                    stats.purchaseCount = doc.getLong("purchaseCount").intValue();
                    stats.totalRevenue = stats.purchaseCount * doc.getLong("priceInCents").intValue();
                    stats.averageRating = doc.getDouble("averageRating").floatValue();
                    stats.ratingCount = doc.getLong("ratingCount").intValue();
                    
                    // Get view count
                    db.collection("contentViews")
                            .whereEqualTo("contentId", contentId)
                            .get()
                            .addOnCompleteListener(viewTask -> {
                                if (viewTask.isSuccessful()) {
                                    stats.viewCount = viewTask.getResult().size();
                                }
                                callback.onComplete(com.google.android.gms.tasks.Tasks.forResult(stats));
                            });
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to get stats", e);
                    callback.onComplete(com.google.android.gms.tasks.Tasks.forException(e));
                });
    }
    
    private void fetchContentDetails(List<String> contentIds, ContentCallback callback) {
        List<MarketplaceContent> contents = new ArrayList<>();
        int[] completed = {0};
        
        for (String id : contentIds) {
            db.collection("marketplaceContent").document(id).get()
                    .addOnSuccessListener(doc -> {
                        MarketplaceContent content = parseContentDocument(doc);
                        if (content != null) {
                            contents.add(content);
                        }
                        
                        completed[0]++;
                        if (completed[0] == contentIds.size()) {
                            callback.onSuccess(contents);
                        }
                    });
        }
    }
    
    private MarketplaceContent parseContentDocument(DocumentSnapshot doc) {
        try {
            MarketplaceContent content = new MarketplaceContent();
            content.id = doc.getId();
            content.title = doc.getString("title");
            content.description = doc.getString("description");
            content.type = ContentType.valueOf(doc.getString("type"));
            content.status = ContentStatus.valueOf(doc.getString("status"));
            content.creatorId = doc.getString("creatorId");
            content.creatorName = doc.getString("creatorName");
            content.priceInCents = doc.getLong("priceInCents").intValue();
            content.thumbnailUrl = doc.getString("thumbnailUrl");
            content.fileUrl = doc.getString("fileUrl");
            content.tags = (List<String>) doc.get("tags");
            content.difficulty = doc.getString("difficulty");
            content.duration = doc.getString("duration");
            content.purchaseCount = doc.getLong("purchaseCount").intValue();
            content.averageRating = doc.getDouble("averageRating").floatValue();
            content.createdAt = doc.getLong("createdAt");
            
            return content;
        } catch (Exception e) {
            Log.e(TAG, "Failed to parse content", e);
            return null;
        }
    }
    
    private void grantContentAccess(String userId, String contentId, PurchaseCallback callback) {
        Map<String, Object> purchase = new HashMap<>();
        purchase.put("userId", userId);
        purchase.put("contentId", contentId);
        purchase.put("purchasedAt", System.currentTimeMillis());
        purchase.put("priceInCents", 0);
        
        db.collection("userPurchases")
                .add(purchase)
                .addOnSuccessListener(ref -> {
                    // Increment purchase count
                    db.collection("marketplaceContent").document(contentId)
                            .update("purchaseCount", com.google.firebase.firestore.FieldValue.increment(1));
                    
                    callback.onSuccess("Content added to your library!");
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to grant access", e);
                    callback.onError("Failed to add content");
                });
    }
    
    private void processPurchase(String userId, String contentId, int priceInCents, PurchaseCallback callback) {
        // In a real app, this would integrate with Google Play Billing
        // For now, we'll simulate a successful purchase
        
        Map<String, Object> purchase = new HashMap<>();
        purchase.put("userId", userId);
        purchase.put("contentId", contentId);
        purchase.put("purchasedAt", System.currentTimeMillis());
        purchase.put("priceInCents", priceInCents);
        
        db.collection("userPurchases")
                .add(purchase)
                .addOnSuccessListener(ref -> {
                    // Update purchase count and creator earnings
                    db.collection("marketplaceContent").document(contentId)
                            .update("purchaseCount", com.google.firebase.firestore.FieldValue.increment(1));
                    
                    // Record earnings for creator (70% revenue share)
                    recordCreatorEarnings(contentId, (int) (priceInCents * 0.7));
                    
                    callback.onSuccess("Purchase successful! Content added to your library.");
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to process purchase", e);
                    callback.onError("Purchase failed");
                });
    }
    
    private void recordCreatorEarnings(String contentId, int earningsInCents) {
        db.collection("marketplaceContent").document(contentId).get()
                .addOnSuccessListener(doc -> {
                    String creatorId = doc.getString("creatorId");
                    
                    Map<String, Object> earnings = new HashMap<>();
                    earnings.put("creatorId", creatorId);
                    earnings.put("contentId", contentId);
                    earnings.put("amountInCents", earningsInCents);
                    earnings.put("createdAt", System.currentTimeMillis());
                    
                    db.collection("creatorEarnings").add(earnings);
                });
    }
    
    private void uploadContentFile(String contentId, String fileUrl, UploadCallback callback) {
        // In a real app, you'd upload the actual file to Firebase Storage
        // For now, we'll simulate the upload
        callback.onProgress(50);
        
        new android.os.Handler().postDelayed(() -> {
            callback.onProgress(100);
            callback.onSuccess(contentId);
        }, 1000);
    }
    
    private void updateContentRating(String contentId) {
        db.collection("contentRatings")
                .whereEqualTo("contentId", contentId)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        float totalRating = 0;
                        int count = 0;
                        
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            totalRating += doc.getDouble("rating").floatValue();
                            count++;
                        }
                        
                        if (count > 0) {
                            float averageRating = totalRating / count;
                            
                            Map<String, Object> updates = new HashMap<>();
                            updates.put("averageRating", averageRating);
                            updates.put("ratingCount", count);
                            
                            db.collection("marketplaceContent").document(contentId).update(updates);
                        }
                    }
                });
    }
    
    // Content model
    public static class MarketplaceContent {
        public String id;
        public String title;
        public String description;
        public ContentType type;
        public ContentStatus status;
        public String creatorId;
        public String creatorName;
        public int priceInCents;
        public String thumbnailUrl;
        public String fileUrl;
        public List<String> tags;
        public String difficulty;  // Beginner, Intermediate, Advanced
        public String duration;    // e.g., "4 weeks", "30 minutes"
        public int purchaseCount;
        public float averageRating;
        public long createdAt;
        
        public MarketplaceContent() {}
        
        public String getFormattedPrice() {
            if (priceInCents == 0) return "무료";
            return String.format("$%.2f", priceInCents / 100.0);
        }
    }
    
    // Content statistics
    public static class ContentStats {
        public int viewCount;
        public int purchaseCount;
        public int totalRevenue;
        public float averageRating;
        public int ratingCount;
    }
}
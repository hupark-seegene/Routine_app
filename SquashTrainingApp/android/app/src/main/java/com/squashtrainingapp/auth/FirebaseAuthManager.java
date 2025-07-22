package com.squashtrainingapp.auth;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FirebaseFirestore;
import com.kakao.sdk.auth.model.OAuthToken;
import com.kakao.sdk.user.UserApiClient;
import com.squashtrainingapp.R;

import java.util.HashMap;
import java.util.Map;

import kotlin.Unit;
import kotlin.jvm.functions.Function2;

public class FirebaseAuthManager {
    private static final String TAG = "FirebaseAuthManager";
    private static final int RC_SIGN_IN = 9001;
    
    private static FirebaseAuthManager instance;
    private FirebaseAuth mAuth;
    private FirebaseFirestore db;
    private GoogleSignInClient googleSignInClient;
    private Context context;
    private AuthStateListener authStateListener;
    
    // User subscription status
    public enum SubscriptionStatus {
        FREE,
        PREMIUM,
        TRIAL
    }
    
    public interface AuthStateListener {
        void onAuthStateChanged(FirebaseUser user);
        void onAuthError(String error);
    }
    
    public interface AuthCallback {
        void onSuccess(FirebaseUser user);
        void onError(String error);
    }
    
    private FirebaseAuthManager(Context context) {
        this.context = context.getApplicationContext();
        mAuth = FirebaseAuth.getInstance();
        db = FirebaseFirestore.getInstance();
        
        // Configure Google Sign-In
        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken(context.getString(R.string.default_web_client_id))
                .requestEmail()
                .build();
        
        googleSignInClient = GoogleSignIn.getClient(context, gso);
    }
    
    public static synchronized FirebaseAuthManager getInstance(Context context) {
        if (instance == null) {
            instance = new FirebaseAuthManager(context);
        }
        return instance;
    }
    
    // Current user getter
    public FirebaseUser getCurrentUser() {
        return mAuth.getCurrentUser();
    }
    
    public boolean isUserLoggedIn() {
        return getCurrentUser() != null;
    }
    
    // Email/Password Authentication
    public void signUpWithEmail(String email, String password, String displayName, AuthCallback callback) {
        mAuth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        FirebaseUser user = mAuth.getCurrentUser();
                        if (user != null) {
                            // Create user profile in Firestore
                            createUserProfile(user, displayName, callback);
                        }
                    } else {
                        callback.onError(task.getException() != null ? 
                                task.getException().getMessage() : "Sign up failed");
                    }
                });
    }
    
    public void signInWithEmail(String email, String password, AuthCallback callback) {
        mAuth.signInWithEmailAndPassword(email, password)
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        FirebaseUser user = mAuth.getCurrentUser();
                        callback.onSuccess(user);
                        updateLastLogin(user);
                    } else {
                        callback.onError(task.getException() != null ? 
                                task.getException().getMessage() : "Sign in failed");
                    }
                });
    }
    
    // Google Sign-In
    public Intent getGoogleSignInIntent() {
        return googleSignInClient.getSignInIntent();
    }
    
    public void handleGoogleSignInResult(Intent data, AuthCallback callback) {
        Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
        try {
            GoogleSignInAccount account = task.getResult(ApiException.class);
            firebaseAuthWithGoogle(account.getIdToken(), callback);
        } catch (ApiException e) {
            Log.w(TAG, "Google sign in failed", e);
            callback.onError("Google sign in failed: " + e.getMessage());
        }
    }
    
    private void firebaseAuthWithGoogle(String idToken, AuthCallback callback) {
        AuthCredential credential = GoogleAuthProvider.getCredential(idToken, null);
        mAuth.signInWithCredential(credential)
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        FirebaseUser user = mAuth.getCurrentUser();
                        checkAndCreateUserProfile(user, callback);
                    } else {
                        callback.onError(task.getException() != null ? 
                                task.getException().getMessage() : "Authentication failed");
                    }
                });
    }
    
    // Kakao Sign-In
    public void signInWithKakao(Activity activity, AuthCallback callback) {
        Function2<OAuthToken, Throwable, Unit> kakaoCallback = (oAuthToken, throwable) -> {
            if (throwable != null) {
                callback.onError("Kakao login failed: " + throwable.getMessage());
            } else {
                // Get Kakao user info and create custom token
                UserApiClient.getInstance().me((user, error) -> {
                    if (error != null) {
                        callback.onError("Failed to get user info: " + error.getMessage());
                    } else if (user != null) {
                        // For production, you would call your backend to create a custom token
                        // For now, we'll create an anonymous account linked to Kakao ID
                        signInAnonymouslyAndLinkKakao(user.getId().toString(), 
                                user.getKakaoAccount().getProfile().getNickname(), callback);
                    }
                    return Unit.INSTANCE;
                });
            }
            return Unit.INSTANCE;
        };
        
        if (UserApiClient.getInstance().isKakaoTalkLoginAvailable(activity)) {
            UserApiClient.getInstance().loginWithKakaoTalk(activity, kakaoCallback);
        } else {
            UserApiClient.getInstance().loginWithKakaoAccount(activity, kakaoCallback);
        }
    }
    
    private void signInAnonymouslyAndLinkKakao(String kakaoId, String displayName, AuthCallback callback) {
        // In production, you would authenticate with your backend
        // For MVP, we'll use anonymous auth with Kakao metadata
        mAuth.signInAnonymously()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        FirebaseUser user = mAuth.getCurrentUser();
                        createUserProfileWithKakao(user, kakaoId, displayName, callback);
                    } else {
                        callback.onError("Authentication failed");
                    }
                });
    }
    
    // User Profile Management
    private void createUserProfile(FirebaseUser user, String displayName, AuthCallback callback) {
        Map<String, Object> userProfile = new HashMap<>();
        userProfile.put("uid", user.getUid());
        userProfile.put("email", user.getEmail());
        userProfile.put("displayName", displayName);
        userProfile.put("subscriptionStatus", SubscriptionStatus.TRIAL.name());
        userProfile.put("trialStartDate", System.currentTimeMillis());
        userProfile.put("createdAt", System.currentTimeMillis());
        userProfile.put("lastLogin", System.currentTimeMillis());
        userProfile.put("totalWorkouts", 0);
        userProfile.put("currentStreak", 0);
        userProfile.put("level", "beginner");
        userProfile.put("points", 0);
        
        db.collection("users").document(user.getUid())
                .set(userProfile)
                .addOnSuccessListener(aVoid -> callback.onSuccess(user))
                .addOnFailureListener(e -> callback.onError("Failed to create profile: " + e.getMessage()));
    }
    
    private void createUserProfileWithKakao(FirebaseUser user, String kakaoId, String displayName, AuthCallback callback) {
        Map<String, Object> userProfile = new HashMap<>();
        userProfile.put("uid", user.getUid());
        userProfile.put("kakaoId", kakaoId);
        userProfile.put("displayName", displayName);
        userProfile.put("authProvider", "kakao");
        userProfile.put("subscriptionStatus", SubscriptionStatus.TRIAL.name());
        userProfile.put("trialStartDate", System.currentTimeMillis());
        userProfile.put("createdAt", System.currentTimeMillis());
        userProfile.put("lastLogin", System.currentTimeMillis());
        userProfile.put("totalWorkouts", 0);
        userProfile.put("currentStreak", 0);
        userProfile.put("level", "beginner");
        userProfile.put("points", 0);
        
        db.collection("users").document(user.getUid())
                .set(userProfile)
                .addOnSuccessListener(aVoid -> callback.onSuccess(user))
                .addOnFailureListener(e -> callback.onError("Failed to create profile: " + e.getMessage()));
    }
    
    private void checkAndCreateUserProfile(FirebaseUser user, AuthCallback callback) {
        db.collection("users").document(user.getUid()).get()
                .addOnSuccessListener(documentSnapshot -> {
                    if (documentSnapshot.exists()) {
                        updateLastLogin(user);
                        callback.onSuccess(user);
                    } else {
                        createUserProfile(user, user.getDisplayName(), callback);
                    }
                })
                .addOnFailureListener(e -> callback.onError("Failed to check profile: " + e.getMessage()));
    }
    
    private void updateLastLogin(FirebaseUser user) {
        if (user != null) {
            db.collection("users").document(user.getUid())
                    .update("lastLogin", System.currentTimeMillis())
                    .addOnFailureListener(e -> Log.e(TAG, "Failed to update last login", e));
        }
    }
    
    // Password Reset
    public void sendPasswordResetEmail(String email, OnCompleteListener<Void> listener) {
        mAuth.sendPasswordResetEmail(email).addOnCompleteListener(listener);
    }
    
    // Sign Out
    public void signOut() {
        // Sign out from Firebase
        mAuth.signOut();
        
        // Sign out from Google
        googleSignInClient.signOut();
        
        // Sign out from Kakao
        UserApiClient.getInstance().logout(error -> {
            if (error != null) {
                Log.e(TAG, "Kakao logout failed", error);
            }
            return Unit.INSTANCE;
        });
    }
    
    // Get user subscription status
    public void getUserSubscription(String userId, OnCompleteListener<SubscriptionStatus> listener) {
        db.collection("users").document(userId).get()
                .addOnSuccessListener(documentSnapshot -> {
                    if (documentSnapshot.exists()) {
                        String status = documentSnapshot.getString("subscriptionStatus");
                        SubscriptionStatus subscriptionStatus = SubscriptionStatus.valueOf(
                                status != null ? status : SubscriptionStatus.FREE.name()
                        );
                        listener.onComplete(Tasks.forResult(subscriptionStatus));
                    } else {
                        listener.onComplete(Tasks.forResult(SubscriptionStatus.FREE));
                    }
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to get subscription status", e);
                    listener.onComplete(Tasks.forResult(SubscriptionStatus.FREE));
                });
    }
    
    // Update subscription status (called after successful payment)
    public void updateSubscriptionStatus(String userId, SubscriptionStatus status) {
        Map<String, Object> update = new HashMap<>();
        update.put("subscriptionStatus", status.name());
        update.put("subscriptionUpdatedAt", System.currentTimeMillis());
        
        if (status == SubscriptionStatus.PREMIUM) {
            update.put("premiumStartDate", System.currentTimeMillis());
        }
        
        db.collection("users").document(userId)
                .update(update)
                .addOnFailureListener(e -> Log.e(TAG, "Failed to update subscription status", e));
    }
    
    public void setAuthStateListener(AuthStateListener listener) {
        this.authStateListener = listener;
        
        mAuth.addAuthStateListener(firebaseAuth -> {
            if (authStateListener != null) {
                authStateListener.onAuthStateChanged(firebaseAuth.getCurrentUser());
            }
        });
    }
    
    // Check if user is premium
    public boolean isPremiumUser() {
        // Check cached status first
        SharedPreferences prefs = context.getSharedPreferences("subscription_prefs", Context.MODE_PRIVATE);
        return prefs.getBoolean("is_premium", false);
    }
    
    // Update user premium status in cache
    public void updatePremiumStatusCache(boolean isPremium) {
        SharedPreferences prefs = context.getSharedPreferences("subscription_prefs", Context.MODE_PRIVATE);
        prefs.edit().putBoolean("is_premium", isPremium).apply();
    }
    
    // Update user profile with additional data
    public void updateUserProfile(String userId, Map<String, Object> updates, OnCompleteListener<Void> listener) {
        db.collection("users").document(userId)
                .update(updates)
                .addOnCompleteListener(listener);
    }
}
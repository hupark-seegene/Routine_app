package com.squashtrainingapp.api.config;

import android.content.Context;
import android.content.SharedPreferences;
import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKey;
import java.io.IOException;
import java.security.GeneralSecurityException;

public class ApiKeyManager {
    private static final String PREFS_NAME = "encrypted_api_keys";
    private static final String KEY_OPENAI = "openai_api_key";
    private static final String KEY_GOOGLE = "google_api_key";
    private static final String KEY_YOUTUBE = "youtube_api_key";
    
    private SharedPreferences encryptedPrefs;
    private static ApiKeyManager instance;
    
    private ApiKeyManager(Context context) {
        try {
            MasterKey masterKey = new MasterKey.Builder(context)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .build();
                
            encryptedPrefs = EncryptedSharedPreferences.create(
                context,
                PREFS_NAME,
                masterKey,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            );
        } catch (GeneralSecurityException | IOException e) {
            e.printStackTrace();
        }
    }
    
    public static synchronized ApiKeyManager getInstance(Context context) {
        if (instance == null) {
            instance = new ApiKeyManager(context.getApplicationContext());
        }
        return instance;
    }
    
    public void saveOpenAIKey(String apiKey) {
        if (encryptedPrefs != null) {
            encryptedPrefs.edit().putString(KEY_OPENAI, apiKey).apply();
        }
    }
    
    public String getOpenAIKey() {
        if (encryptedPrefs != null) {
            return encryptedPrefs.getString(KEY_OPENAI, "");
        }
        return "";
    }
    
    public void saveGoogleKey(String apiKey) {
        if (encryptedPrefs != null) {
            encryptedPrefs.edit().putString(KEY_GOOGLE, apiKey).apply();
        }
    }
    
    public String getGoogleKey() {
        if (encryptedPrefs != null) {
            return encryptedPrefs.getString(KEY_GOOGLE, "");
        }
        return "";
    }
    
    public void saveYouTubeKey(String apiKey) {
        if (encryptedPrefs != null) {
            encryptedPrefs.edit().putString(KEY_YOUTUBE, apiKey).apply();
        }
    }
    
    public String getYouTubeKey() {
        if (encryptedPrefs != null) {
            return encryptedPrefs.getString(KEY_YOUTUBE, "");
        }
        return "";
    }
    
    public boolean hasValidOpenAIKey() {
        String key = getOpenAIKey();
        return key != null && !key.isEmpty();
    }
    
    public void clearAllKeys() {
        if (encryptedPrefs != null) {
            encryptedPrefs.edit().clear().apply();
        }
    }
}
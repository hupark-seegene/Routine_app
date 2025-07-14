package com.squashtrainingapp.ui.activities;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import com.squashtrainingapp.R;

public class SettingsActivity extends AppCompatActivity {
    
    private SharedPreferences prefs;
    private Switch themeSwitch;
    private Switch soundSwitch;
    private Switch vibrationSwitch;
    private TextView apiKeyStatus;
    private RadioGroup languageGroup;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        
        prefs = getSharedPreferences("app_settings", Context.MODE_PRIVATE);
        
        initializeViews();
        loadSettings();
        setupListeners();
    }
    
    private void initializeViews() {
        // Back button
        ImageView backButton = findViewById(R.id.back_button);
        backButton.setOnClickListener(v -> finish());
        
        // Switches
        themeSwitch = findViewById(R.id.theme_switch);
        soundSwitch = findViewById(R.id.sound_switch);
        vibrationSwitch = findViewById(R.id.vibration_switch);
        
        // API Key
        apiKeyStatus = findViewById(R.id.api_key_status);
        CardView apiKeyCard = findViewById(R.id.api_key_card);
        
        // Language
        languageGroup = findViewById(R.id.language_group);
    }
    
    private void loadSettings() {
        // Theme
        boolean isDarkTheme = prefs.getBoolean("dark_theme", true);
        themeSwitch.setChecked(isDarkTheme);
        
        // Sound
        boolean soundEnabled = prefs.getBoolean("sound_enabled", true);
        soundSwitch.setChecked(soundEnabled);
        
        // Vibration
        boolean vibrationEnabled = prefs.getBoolean("vibration_enabled", true);
        vibrationSwitch.setChecked(vibrationEnabled);
        
        // API Key
        SharedPreferences aiPrefs = getSharedPreferences("ai_settings", Context.MODE_PRIVATE);
        String apiKey = aiPrefs.getString("openai_api_key", "");
        updateApiKeyStatus(!apiKey.isEmpty());
        
        // Language
        String language = prefs.getString("language", "auto");
        if (language.equals("ko")) {
            languageGroup.check(R.id.radio_korean);
        } else if (language.equals("en")) {
            languageGroup.check(R.id.radio_english);
        } else {
            languageGroup.check(R.id.radio_auto);
        }
    }
    
    private void setupListeners() {
        // Theme switch
        themeSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {
            prefs.edit().putBoolean("dark_theme", isChecked).apply();
            // Apply theme change
            recreate();
        });
        
        // Sound switch
        soundSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {
            prefs.edit().putBoolean("sound_enabled", isChecked).apply();
        });
        
        // Vibration switch
        vibrationSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {
            prefs.edit().putBoolean("vibration_enabled", isChecked).apply();
        });
        
        // API Key card click
        CardView apiKeyCard = findViewById(R.id.api_key_card);
        apiKeyCard.setOnClickListener(v -> showApiKeyDialog());
        
        // Language selection
        languageGroup.setOnCheckedChangeListener((group, checkedId) -> {
            String language = "auto";
            if (checkedId == R.id.radio_korean) {
                language = "ko";
            } else if (checkedId == R.id.radio_english) {
                language = "en";
            }
            prefs.edit().putString("language", language).apply();
            // Update app language
            updateAppLanguage(language);
        });
        
        // Clear cache button
        Button clearCacheButton = findViewById(R.id.clear_cache_button);
        clearCacheButton.setOnClickListener(v -> {
            clearCache();
            Toast.makeText(this, "Cache cleared successfully", Toast.LENGTH_SHORT).show();
        });
        
        // About button
        Button aboutButton = findViewById(R.id.about_button);
        aboutButton.setOnClickListener(v -> showAboutDialog());
    }
    
    private void showApiKeyDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("OpenAI API Key");
        
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(50, 40, 50, 10);
        
        final EditText input = new EditText(this);
        input.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        input.setHint("Enter your OpenAI API key");
        
        SharedPreferences aiPrefs = getSharedPreferences("ai_settings", Context.MODE_PRIVATE);
        String currentKey = aiPrefs.getString("openai_api_key", "");
        if (!currentKey.isEmpty()) {
            input.setText(currentKey);
        }
        
        layout.addView(input);
        builder.setView(layout);
        
        builder.setPositiveButton("Save", (dialog, which) -> {
            String apiKey = input.getText().toString().trim();
            if (!apiKey.isEmpty()) {
                aiPrefs.edit().putString("openai_api_key", apiKey).apply();
                updateApiKeyStatus(true);
                Toast.makeText(this, "API key saved successfully", Toast.LENGTH_SHORT).show();
            }
        });
        
        builder.setNegativeButton("Cancel", (dialog, which) -> dialog.cancel());
        
        builder.setNeutralButton("Remove", (dialog, which) -> {
            aiPrefs.edit().remove("openai_api_key").apply();
            updateApiKeyStatus(false);
            Toast.makeText(this, "API key removed", Toast.LENGTH_SHORT).show();
        });
        
        builder.show();
    }
    
    private void updateApiKeyStatus(boolean hasKey) {
        if (hasKey) {
            apiKeyStatus.setText("Configured");
            apiKeyStatus.setTextColor(getResources().getColor(R.color.volt_green));
        } else {
            apiKeyStatus.setText("Not configured");
            apiKeyStatus.setTextColor(getResources().getColor(R.color.text_secondary));
        }
    }
    
    private void updateAppLanguage(String language) {
        // In a real app, this would update the locale
        // For now, just show a toast
        String message = "Language changed. Restart app to apply.";
        if (language.equals("ko")) {
            message = "언어가 변경되었습니다. 앱을 재시작하세요.";
        }
        Toast.makeText(this, message, Toast.LENGTH_LONG).show();
    }
    
    private void clearCache() {
        // Clear conversation history
        SharedPreferences chatPrefs = getSharedPreferences("chat_history", Context.MODE_PRIVATE);
        chatPrefs.edit().clear().apply();
        
        // Clear other caches as needed
    }
    
    private void showAboutDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("About");
        builder.setMessage("Squash Training Pro\nVersion 1.0.0\n\nYour AI-powered squash training companion.\n\n© 2025 Squash Training Pro");
        builder.setPositiveButton("OK", null);
        builder.show();
    }
}
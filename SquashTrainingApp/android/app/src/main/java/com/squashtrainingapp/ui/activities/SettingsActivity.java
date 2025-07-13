package com.squashtrainingapp.ui.activities;

import com.squashtrainingapp.R;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.CompoundButton;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;

public class SettingsActivity extends AppCompatActivity {
    
    // UI Components
    private Switch darkModeSwitch;
    private Switch notificationsSwitch;
    private SeekBar reminderIntervalSeekBar;
    private TextView reminderIntervalText;
    private Switch soundEffectsSwitch;
    private Switch vibrationSwitch;
    
    // Preferences
    private SharedPreferences preferences;
    private SharedPreferences.Editor editor;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        
        preferences = getSharedPreferences("app_settings", MODE_PRIVATE);
        editor = preferences.edit();
        
        initializeViews();
        loadSettings();
        setupListeners();
    }
    
    private void initializeViews() {
        darkModeSwitch = findViewById(R.id.dark_mode_switch);
        notificationsSwitch = findViewById(R.id.notifications_switch);
        reminderIntervalSeekBar = findViewById(R.id.reminder_interval_seekbar);
        reminderIntervalText = findViewById(R.id.reminder_interval_text);
        soundEffectsSwitch = findViewById(R.id.sound_effects_switch);
        vibrationSwitch = findViewById(R.id.vibration_switch);
    }
    
    private void loadSettings() {
        // Load saved preferences
        if (darkModeSwitch != null) {
            darkModeSwitch.setChecked(preferences.getBoolean("dark_mode", true));
        }
        
        if (notificationsSwitch != null) {
            notificationsSwitch.setChecked(preferences.getBoolean("notifications", true));
        }
        
        if (soundEffectsSwitch != null) {
            soundEffectsSwitch.setChecked(preferences.getBoolean("sound_effects", true));
        }
        
        if (vibrationSwitch != null) {
            vibrationSwitch.setChecked(preferences.getBoolean("vibration", true));
        }
        
        if (reminderIntervalSeekBar != null) {
            int interval = preferences.getInt("reminder_interval", 1);
            reminderIntervalSeekBar.setProgress(interval - 1);
            updateReminderIntervalText(interval);
        }
    }
    
    private void setupListeners() {
        if (darkModeSwitch != null) {
            darkModeSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {
                editor.putBoolean("dark_mode", isChecked).apply();
                
                // Apply theme change
                if (isChecked) {
                    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
                } else {
                    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
                }
            });
        }
        
        if (notificationsSwitch != null) {
            notificationsSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {
                editor.putBoolean("notifications", isChecked).apply();
                showToast(isChecked ? "Notifications enabled" : "Notifications disabled");
            });
        }
        
        if (soundEffectsSwitch != null) {
            soundEffectsSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {
                editor.putBoolean("sound_effects", isChecked).apply();
            });
        }
        
        if (vibrationSwitch != null) {
            vibrationSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {
                editor.putBoolean("vibration", isChecked).apply();
            });
        }
        
        if (reminderIntervalSeekBar != null) {
            reminderIntervalSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    int interval = progress + 1;
                    updateReminderIntervalText(interval);
                    editor.putInt("reminder_interval", interval).apply();
                }
                
                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {}
                
                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {}
            });
        }
    }
    
    private void updateReminderIntervalText(int days) {
        if (reminderIntervalText != null) {
            String text = days == 1 ? "Daily reminders" : "Remind every " + days + " days";
            reminderIntervalText.setText(text);
        }
    }
    
    private void showToast(String message) {
        android.widget.Toast.makeText(this, message, android.widget.Toast.LENGTH_SHORT).show();
    }
}
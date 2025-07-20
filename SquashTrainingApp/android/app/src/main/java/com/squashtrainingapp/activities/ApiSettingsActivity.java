package com.squashtrainingapp.activities;

import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.squashtrainingapp.R;
import com.squashtrainingapp.api.config.ApiKeyManager;
import com.squashtrainingapp.api.repository.AIRepository;

public class ApiSettingsActivity extends AppCompatActivity {
    private EditText apiKeyEditText;
    private Button saveButton;
    private Button testButton;
    private TextView statusTextView;
    private ProgressBar progressBar;
    private ImageButton toggleVisibilityButton;
    private boolean isApiKeyVisible = false;
    
    private ApiKeyManager apiKeyManager;
    private AIRepository aiRepository;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_api_settings);
        
        initializeViews();
        setupManagers();
        loadExistingKey();
        setupListeners();
    }
    
    private void initializeViews() {
        apiKeyEditText = findViewById(R.id.api_key_edit_text);
        saveButton = findViewById(R.id.save_button);
        testButton = findViewById(R.id.test_button);
        statusTextView = findViewById(R.id.status_text_view);
        progressBar = findViewById(R.id.progress_bar);
        toggleVisibilityButton = findViewById(R.id.toggle_visibility_button);
        
        // Back button
        View backButton = findViewById(R.id.back_button);
        if (backButton != null) {
            backButton.setOnClickListener(v -> finish());
        }
    }
    
    private void setupManagers() {
        apiKeyManager = ApiKeyManager.getInstance(this);
        aiRepository = AIRepository.getInstance(this);
    }
    
    private void loadExistingKey() {
        String existingKey = apiKeyManager.getOpenAIKey();
        if (!existingKey.isEmpty()) {
            // Show masked version
            apiKeyEditText.setText(maskApiKey(existingKey));
            statusTextView.setText("API key is configured");
            statusTextView.setTextColor(getColor(R.color.volt_green));
        } else {
            statusTextView.setText("No API key configured");
            statusTextView.setTextColor(getColor(R.color.text_secondary));
        }
    }
    
    private String maskApiKey(String apiKey) {
        if (apiKey.length() <= 8) return apiKey;
        return apiKey.substring(0, 4) + "..." + apiKey.substring(apiKey.length() - 4);
    }
    
    private void setupListeners() {
        toggleVisibilityButton.setOnClickListener(v -> toggleApiKeyVisibility());
        
        saveButton.setOnClickListener(v -> saveApiKey());
        
        testButton.setOnClickListener(v -> testApiConnection());
    }
    
    private void toggleApiKeyVisibility() {
        isApiKeyVisible = !isApiKeyVisible;
        if (isApiKeyVisible) {
            apiKeyEditText.setInputType(InputType.TYPE_CLASS_TEXT);
            toggleVisibilityButton.setImageResource(R.drawable.ic_visibility_off);
            // Load actual key if showing masked version
            String existingKey = apiKeyManager.getOpenAIKey();
            if (!existingKey.isEmpty() && apiKeyEditText.getText().toString().contains("...")) {
                apiKeyEditText.setText(existingKey);
            }
        } else {
            apiKeyEditText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
            toggleVisibilityButton.setImageResource(R.drawable.ic_visibility);
        }
    }
    
    private void saveApiKey() {
        String apiKey = apiKeyEditText.getText().toString().trim();
        
        // Don't save if it's the masked version
        if (apiKey.contains("...")) {
            Toast.makeText(this, "Please enter a new API key", Toast.LENGTH_SHORT).show();
            return;
        }
        
        if (apiKey.isEmpty()) {
            Toast.makeText(this, "Please enter an API key", Toast.LENGTH_SHORT).show();
            return;
        }
        
        if (!apiKey.startsWith("sk-")) {
            Toast.makeText(this, "Invalid API key format", Toast.LENGTH_SHORT).show();
            return;
        }
        
        // Save the key
        apiKeyManager.saveOpenAIKey(apiKey);
        aiRepository.updateApiKey(apiKey);
        
        // Update UI
        statusTextView.setText("API key saved successfully");
        statusTextView.setTextColor(getColor(R.color.volt_green));
        Toast.makeText(this, "API key saved!", Toast.LENGTH_SHORT).show();
        
        // Mask the key in the input field
        if (!isApiKeyVisible) {
            apiKeyEditText.setText(maskApiKey(apiKey));
        }
    }
    
    private void testApiConnection() {
        if (!aiRepository.hasApiKey()) {
            Toast.makeText(this, "Please save an API key first", Toast.LENGTH_SHORT).show();
            return;
        }
        
        progressBar.setVisibility(View.VISIBLE);
        testButton.setEnabled(false);
        statusTextView.setText("Testing connection...");
        
        // Send a test message
        aiRepository.sendChatMessage("Hello, can you respond with a brief greeting?");
        
        // Observe the response
        aiRepository.getChatResponse().observe(this, response -> {
            if (response != null) {
                progressBar.setVisibility(View.GONE);
                testButton.setEnabled(true);
                statusTextView.setText("Connection successful!");
                statusTextView.setTextColor(getColor(R.color.volt_green));
                Toast.makeText(this, "API connection successful!", Toast.LENGTH_LONG).show();
            }
        });
        
        aiRepository.getError().observe(this, error -> {
            if (error != null) {
                progressBar.setVisibility(View.GONE);
                testButton.setEnabled(true);
                statusTextView.setText("Connection failed: " + error);
                statusTextView.setTextColor(getColor(android.R.color.holo_red_light));
            }
        });
    }
}
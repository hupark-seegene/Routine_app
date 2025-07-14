package com.squashtrainingapp.ai;

import android.os.Bundle;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.squashtrainingapp.R;

public class AIChatbotActivity extends AppCompatActivity implements 
        VoiceRecognitionManager.VoiceRecognitionListener,
        AIResponseEngine.AIResponseListener {
    
    private static final String TAG = "AIChatbotActivity";
    
    private RecyclerView chatRecyclerView;
    private ChatAdapter chatAdapter;
    private EditText inputEditText;
    private ImageButton sendButton;
    private ImageButton voiceButton;
    private ProgressBar progressBar;
    
    private VoiceRecognitionManager voiceManager;
    private AIResponseEngine aiEngine;
    private boolean isProcessing = false;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ai_chatbot);
        
        initializeViews();
        setupRecyclerView();
        setupVoiceRecognition();
        setupAIEngine();
        setupListeners();
        
        // Welcome message
        addMessage("Hello! I'm your AI squash coach. How can I help you today?", ChatMessage.MessageType.AI);
    }
    
    private void initializeViews() {
        chatRecyclerView = findViewById(R.id.chat_recycler_view);
        inputEditText = findViewById(R.id.input_edit_text);
        sendButton = findViewById(R.id.send_button);
        voiceButton = findViewById(R.id.voice_button);
        progressBar = findViewById(R.id.progress_bar);
        
        // Back button
        View backButton = findViewById(R.id.back_button);
        if (backButton != null) {
            backButton.setOnClickListener(v -> finish());
        }
    }
    
    private void setupRecyclerView() {
        chatAdapter = new ChatAdapter();
        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        layoutManager.setStackFromEnd(true);
        chatRecyclerView.setLayoutManager(layoutManager);
        chatRecyclerView.setAdapter(chatAdapter);
    }
    
    private void setupVoiceRecognition() {
        // Temporarily disabled to avoid permission issues
        // voiceManager = new VoiceRecognitionManager(this);
        // voiceManager.setVoiceRecognitionListener(this);
    }
    
    private void setupAIEngine() {
        aiEngine = new AIResponseEngine(this);
        aiEngine.setAIResponseListener(this);
    }
    
    private void setupListeners() {
        sendButton.setOnClickListener(v -> sendMessage());
        
        voiceButton.setOnClickListener(v -> {
            // Temporarily disabled
            Toast.makeText(this, "Voice input temporarily disabled", Toast.LENGTH_SHORT).show();
        });
        
        inputEditText.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEND) {
                sendMessage();
                return true;
            }
            return false;
        });
    }
    
    private void sendMessage() {
        String message = inputEditText.getText().toString().trim();
        if (!message.isEmpty() && !isProcessing) {
            addMessage(message, ChatMessage.MessageType.USER);
            inputEditText.setText("");
            processUserInput(message);
        }
    }
    
    private void processUserInput(String input) {
        isProcessing = true;
        progressBar.setVisibility(View.VISIBLE);
        
        // First, check if it's a voice command
        VoiceCommands.Command command = VoiceCommands.parseCommand(input);
        
        if (command.type != VoiceCommands.CommandType.UNKNOWN) {
            // Handle navigation commands
            String response = VoiceCommands.getResponseForCommand(command);
            addMessage(response, ChatMessage.MessageType.AI);
            
            // Execute the command
            executeCommand(command);
            
            isProcessing = false;
            progressBar.setVisibility(View.GONE);
        } else {
            // Send to AI for natural conversation
            aiEngine.getResponse(input);
        }
    }
    
    private void executeCommand(VoiceCommands.Command command) {
        // In a real implementation, this would navigate to the appropriate screen
        // For now, just show a toast
        switch (command.type) {
            case NAVIGATE_PROFILE:
            case NAVIGATE_CHECKLIST:
            case NAVIGATE_RECORD:
            case NAVIGATE_HISTORY:
            case NAVIGATE_COACH:
            case NAVIGATE_SETTINGS:
                Toast.makeText(this, "Navigating to " + command.type.name(), Toast.LENGTH_SHORT).show();
                break;
            default:
                // Other commands handled by AI
                break;
        }
    }
    
    private void addMessage(String message, ChatMessage.MessageType type) {
        ChatMessage chatMessage = new ChatMessage(message, type);
        chatAdapter.addMessage(chatMessage);
        chatRecyclerView.scrollToPosition(chatAdapter.getItemCount() - 1);
    }
    
    // VoiceRecognitionListener methods
    @Override
    public void onResults(String recognizedText) {
        voiceButton.setImageResource(R.drawable.ic_mic);
        inputEditText.setText(recognizedText);
        sendMessage();
    }
    
    @Override
    public void onError(String error) {
        voiceButton.setImageResource(R.drawable.ic_mic);
        Toast.makeText(this, "Voice error: " + error, Toast.LENGTH_SHORT).show();
    }
    
    @Override
    public void onReadyForSpeech() {
        // Voice recognition ready
    }
    
    @Override
    public void onEndOfSpeech() {
        voiceButton.setImageResource(R.drawable.ic_mic);
    }
    
    // AIResponseListener methods
    @Override
    public void onResponse(String response) {
        runOnUiThread(() -> {
            addMessage(response, ChatMessage.MessageType.AI);
            // voiceManager.speak(response); // Temporarily disabled
            isProcessing = false;
            progressBar.setVisibility(View.GONE);
        });
    }
    
    // This method is now named differently to avoid conflict with VoiceRecognitionListener.onError
    public void onAIError(String error) {
        runOnUiThread(() -> {
            addMessage("I'm having trouble processing that. Please try again.", ChatMessage.MessageType.AI);
            isProcessing = false;
            progressBar.setVisibility(View.GONE);
        });
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        // if (voiceManager != null) {
        //     voiceManager.destroy();
        // }
    }
}
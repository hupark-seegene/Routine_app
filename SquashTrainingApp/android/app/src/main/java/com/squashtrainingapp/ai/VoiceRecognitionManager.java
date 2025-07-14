package com.squashtrainingapp.ai;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import androidx.core.content.ContextCompat;
import java.util.ArrayList;
import java.util.Locale;

public class VoiceRecognitionManager implements RecognitionListener, TextToSpeech.OnInitListener {
    private static final String TAG = "VoiceRecognitionManager";
    
    private Activity activity;
    private SpeechRecognizer speechRecognizer;
    private TextToSpeech textToSpeech;
    private Intent recognizerIntent;
    private boolean isListening = false;
    private VoiceRecognitionListener listener;
    
    public interface VoiceRecognitionListener {
        void onResults(String recognizedText);
        void onError(String error);
        void onReadyForSpeech();
        void onEndOfSpeech();
    }
    
    public VoiceRecognitionManager(Activity activity) {
        this.activity = activity;
        initializeSpeechRecognizer();
        initializeTextToSpeech();
    }
    
    private void initializeSpeechRecognizer() {
        // Check permission first
        if (ContextCompat.checkSelfPermission(activity, 
                Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            Log.w(TAG, "No RECORD_AUDIO permission - skipping speech recognizer initialization");
            return;
        }
        
        if (SpeechRecognizer.isRecognitionAvailable(activity)) {
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(activity);
            speechRecognizer.setRecognitionListener(this);
            
            recognizerIntent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
            recognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                    RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
            recognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault());
            recognizerIntent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1);
            recognizerIntent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
            
            Log.d(TAG, "Speech recognizer initialized successfully");
        } else {
            Log.e(TAG, "Speech recognition not available on this device");
        }
    }
    
    private void initializeTextToSpeech() {
        textToSpeech = new TextToSpeech(activity, this);
    }
    
    public void startListening() {
        if (!isListening && speechRecognizer != null) {
            isListening = true;
            activity.runOnUiThread(() -> {
                speechRecognizer.startListening(recognizerIntent);
            });
        }
    }
    
    public void stopListening() {
        if (isListening && speechRecognizer != null) {
            isListening = false;
            activity.runOnUiThread(() -> {
                speechRecognizer.stopListening();
            });
        }
    }
    
    public void speak(String text) {
        if (textToSpeech != null) {
            textToSpeech.speak(text, TextToSpeech.QUEUE_FLUSH, null, null);
        }
    }
    
    public void setVoiceRecognitionListener(VoiceRecognitionListener listener) {
        this.listener = listener;
    }
    
    // RecognitionListener methods
    @Override
    public void onReadyForSpeech(Bundle params) {
        Log.d(TAG, "Ready for speech");
        if (listener != null) {
            listener.onReadyForSpeech();
        }
    }
    
    @Override
    public void onBeginningOfSpeech() {
        Log.d(TAG, "Beginning of speech");
    }
    
    @Override
    public void onRmsChanged(float rmsdB) {
        // Volume level changed
    }
    
    @Override
    public void onBufferReceived(byte[] buffer) {
        // Buffer received
    }
    
    @Override
    public void onEndOfSpeech() {
        Log.d(TAG, "End of speech");
        isListening = false;
        if (listener != null) {
            listener.onEndOfSpeech();
        }
    }
    
    @Override
    public void onError(int error) {
        String errorMessage = getErrorText(error);
        Log.e(TAG, "Error: " + errorMessage);
        isListening = false;
        if (listener != null) {
            listener.onError(errorMessage);
        }
    }
    
    @Override
    public void onResults(Bundle results) {
        ArrayList<String> matches = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
        if (matches != null && !matches.isEmpty()) {
            String recognizedText = matches.get(0);
            Log.d(TAG, "Recognized: " + recognizedText);
            if (listener != null) {
                listener.onResults(recognizedText);
            }
        }
    }
    
    @Override
    public void onPartialResults(Bundle partialResults) {
        // Partial results
    }
    
    @Override
    public void onEvent(int eventType, Bundle params) {
        // Reserved for future events
    }
    
    // TextToSpeech.OnInitListener
    @Override
    public void onInit(int status) {
        if (status == TextToSpeech.SUCCESS) {
            int result = textToSpeech.setLanguage(Locale.getDefault());
            if (result == TextToSpeech.LANG_MISSING_DATA ||
                result == TextToSpeech.LANG_NOT_SUPPORTED) {
                Log.e(TAG, "Language not supported");
            }
        } else {
            Log.e(TAG, "TextToSpeech initialization failed");
        }
    }
    
    private String getErrorText(int errorCode) {
        switch (errorCode) {
            case SpeechRecognizer.ERROR_AUDIO:
                return "Audio recording error";
            case SpeechRecognizer.ERROR_CLIENT:
                return "Client side error";
            case SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS:
                return "Insufficient permissions";
            case SpeechRecognizer.ERROR_NETWORK:
                return "Network error";
            case SpeechRecognizer.ERROR_NETWORK_TIMEOUT:
                return "Network timeout";
            case SpeechRecognizer.ERROR_NO_MATCH:
                return "No match found";
            case SpeechRecognizer.ERROR_RECOGNIZER_BUSY:
                return "Recognition service busy";
            case SpeechRecognizer.ERROR_SERVER:
                return "Server error";
            case SpeechRecognizer.ERROR_SPEECH_TIMEOUT:
                return "No speech input";
            default:
                return "Unknown error";
        }
    }
    
    public void destroy() {
        if (speechRecognizer != null) {
            speechRecognizer.destroy();
        }
        if (textToSpeech != null) {
            textToSpeech.stop();
            textToSpeech.shutdown();
        }
    }
}
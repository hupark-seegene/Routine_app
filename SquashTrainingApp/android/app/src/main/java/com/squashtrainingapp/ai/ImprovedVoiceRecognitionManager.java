package com.squashtrainingapp.ai;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.util.Log;
import androidx.core.content.ContextCompat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Locale;
import java.util.Queue;

public class ImprovedVoiceRecognitionManager implements RecognitionListener, TextToSpeech.OnInitListener {
    private static final String TAG = "ImprovedVoiceRecognition";
    
    private Activity activity;
    private SpeechRecognizer speechRecognizer;
    private TextToSpeech textToSpeech;
    private Intent recognizerIntent;
    private boolean isListening = false;
    private boolean isSpeaking = false;
    private VoiceRecognitionListener listener;
    
    // Improved features
    private boolean continuousMode = false;
    private Handler retryHandler;
    private int retryCount = 0;
    private static final int MAX_RETRY = 3;
    private Queue<String> speechQueue = new LinkedList<>();
    private float confidenceThreshold = 0.5f;
    private Locale currentLocale = Locale.KOREAN; // Default to Korean
    
    // Voice activity detection
    private long silenceTimeout = 2000; // 2 seconds
    private Handler silenceHandler;
    private boolean detectingSilence = false;
    
    public interface VoiceRecognitionListener {
        void onResults(String recognizedText, float confidence);
        void onPartialResults(String partialText);
        void onError(String error);
        void onReadyForSpeech();
        void onEndOfSpeech();
        void onVolumeChanged(float volume);
        void onSpeakingStateChanged(boolean isSpeaking);
    }
    
    public ImprovedVoiceRecognitionManager(Activity activity) {
        this.activity = activity;
        this.retryHandler = new Handler(Looper.getMainLooper());
        this.silenceHandler = new Handler(Looper.getMainLooper());
        initializeSpeechRecognizer();
        initializeTextToSpeech();
    }
    
    private void initializeSpeechRecognizer() {
        if (ContextCompat.checkSelfPermission(activity, 
                Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            Log.w(TAG, "No RECORD_AUDIO permission");
            return;
        }
        
        if (SpeechRecognizer.isRecognitionAvailable(activity)) {
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(activity);
            speechRecognizer.setRecognitionListener(this);
            
            setupRecognizerIntent();
            Log.d(TAG, "Speech recognizer initialized with Korean support");
        } else {
            Log.e(TAG, "Speech recognition not available");
        }
    }
    
    private void setupRecognizerIntent() {
        recognizerIntent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        recognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        recognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, currentLocale.toString());
        recognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, currentLocale.toString());
        recognizerIntent.putExtra(RecognizerIntent.EXTRA_ONLY_RETURN_LANGUAGE_PREFERENCE, currentLocale.toString());
        recognizerIntent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3);
        recognizerIntent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
        recognizerIntent.putExtra(RecognizerIntent.EXTRA_CONFIDENCE_SCORES, true);
        
        // Speech timeout settings
        recognizerIntent.putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 1500);
        recognizerIntent.putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 500);
    }
    
    private void initializeTextToSpeech() {
        textToSpeech = new TextToSpeech(activity, this);
        textToSpeech.setOnUtteranceProgressListener(new UtteranceProgressListener() {
            @Override
            public void onStart(String utteranceId) {
                isSpeaking = true;
                if (listener != null) {
                    activity.runOnUiThread(() -> listener.onSpeakingStateChanged(true));
                }
            }
            
            @Override
            public void onDone(String utteranceId) {
                isSpeaking = false;
                if (listener != null) {
                    activity.runOnUiThread(() -> listener.onSpeakingStateChanged(false));
                }
                
                // Process next in queue
                if (!speechQueue.isEmpty()) {
                    String nextText = speechQueue.poll();
                    if (nextText != null) {
                        speakInternal(nextText);
                    }
                }
                
                // Resume listening in continuous mode
                if (continuousMode && !isListening) {
                    retryHandler.postDelayed(() -> startListening(), 500);
                }
            }
            
            @Override
            public void onError(String utteranceId) {
                isSpeaking = false;
                if (listener != null) {
                    activity.runOnUiThread(() -> listener.onSpeakingStateChanged(false));
                }
            }
        });
    }
    
    public void setLanguage(Locale locale) {
        this.currentLocale = locale;
        setupRecognizerIntent();
        
        if (textToSpeech != null) {
            int result = textToSpeech.setLanguage(locale);
            if (result == TextToSpeech.LANG_MISSING_DATA ||
                result == TextToSpeech.LANG_NOT_SUPPORTED) {
                Log.e(TAG, "Language not supported: " + locale);
            } else {
                // Adjust speech rate for Korean
                if (locale.equals(Locale.KOREAN)) {
                    textToSpeech.setSpeechRate(0.9f);
                } else {
                    textToSpeech.setSpeechRate(1.0f);
                }
            }
        }
    }
    
    public void setContinuousMode(boolean enabled) {
        this.continuousMode = enabled;
        if (enabled && !isListening && !isSpeaking) {
            startListening();
        }
    }
    
    public void setConfidenceThreshold(float threshold) {
        this.confidenceThreshold = threshold;
    }
    
    public void startListening() {
        if (!isListening && speechRecognizer != null && !isSpeaking) {
            isListening = true;
            retryCount = 0;
            activity.runOnUiThread(() -> {
                try {
                    speechRecognizer.startListening(recognizerIntent);
                } catch (Exception e) {
                    Log.e(TAG, "Error starting speech recognition", e);
                    isListening = false;
                    if (listener != null) {
                        listener.onError("Failed to start speech recognition");
                    }
                }
            });
        }
    }
    
    public void stopListening() {
        continuousMode = false;
        if (isListening && speechRecognizer != null) {
            isListening = false;
            activity.runOnUiThread(() -> {
                speechRecognizer.stopListening();
                speechRecognizer.cancel();
            });
        }
        retryHandler.removeCallbacksAndMessages(null);
        silenceHandler.removeCallbacksAndMessages(null);
    }
    
    public void speak(String text) {
        if (text == null || text.isEmpty()) return;
        
        // Stop listening while speaking
        if (isListening) {
            speechRecognizer.cancel();
            isListening = false;
        }
        
        // Add to queue if already speaking
        if (isSpeaking) {
            speechQueue.offer(text);
        } else {
            speakInternal(text);
        }
    }
    
    private void speakInternal(String text) {
        if (textToSpeech != null) {
            HashMap<String, String> params = new HashMap<>();
            params.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, String.valueOf(System.currentTimeMillis()));
            textToSpeech.speak(text, TextToSpeech.QUEUE_FLUSH, params);
        }
    }
    
    public void setVoiceRecognitionListener(VoiceRecognitionListener listener) {
        this.listener = listener;
    }
    
    // RecognitionListener methods
    @Override
    public void onReadyForSpeech(Bundle params) {
        Log.d(TAG, "Ready for speech");
        detectingSilence = true;
        if (listener != null) {
            listener.onReadyForSpeech();
        }
    }
    
    @Override
    public void onBeginningOfSpeech() {
        Log.d(TAG, "Beginning of speech");
        detectingSilence = false;
        silenceHandler.removeCallbacksAndMessages(null);
    }
    
    @Override
    public void onRmsChanged(float rmsdB) {
        // Convert to 0-1 scale
        float volume = Math.max(0, Math.min(1, (rmsdB + 2) / 10));
        if (listener != null) {
            listener.onVolumeChanged(volume);
        }
        
        // Reset silence timer on voice activity
        if (detectingSilence && rmsdB > -2) {
            silenceHandler.removeCallbacksAndMessages(null);
            silenceHandler.postDelayed(this::handleSilenceTimeout, silenceTimeout);
        }
    }
    
    @Override
    public void onBufferReceived(byte[] buffer) {
        // Not used
    }
    
    @Override
    public void onEndOfSpeech() {
        Log.d(TAG, "End of speech");
        isListening = false;
        detectingSilence = false;
        if (listener != null) {
            listener.onEndOfSpeech();
        }
    }
    
    @Override
    public void onError(int error) {
        String errorMessage = getErrorText(error);
        Log.e(TAG, "Error: " + errorMessage);
        isListening = false;
        
        // Handle specific errors
        if (error == SpeechRecognizer.ERROR_NO_MATCH || 
            error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT) {
            // Silent retry in continuous mode
            if (continuousMode && retryCount < MAX_RETRY) {
                retryCount++;
                retryHandler.postDelayed(() -> startListening(), 1000);
                return;
            }
        }
        
        if (listener != null) {
            listener.onError(errorMessage);
        }
        
        // Auto-restart in continuous mode
        if (continuousMode && !isSpeaking) {
            retryHandler.postDelayed(() -> startListening(), 2000);
        }
    }
    
    @Override
    public void onResults(Bundle results) {
        ArrayList<String> matches = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
        float[] confidences = results.getFloatArray(SpeechRecognizer.CONFIDENCE_SCORES);
        
        if (matches != null && !matches.isEmpty()) {
            String bestMatch = matches.get(0);
            float confidence = (confidences != null && confidences.length > 0) ? confidences[0] : 1.0f;
            
            Log.d(TAG, "Recognized: " + bestMatch + " (confidence: " + confidence + ")");
            
            // Only accept high confidence results
            if (confidence >= confidenceThreshold) {
                if (listener != null) {
                    listener.onResults(bestMatch, confidence);
                }
            } else {
                // Low confidence, request clarification
                if (listener != null) {
                    listener.onError("Low confidence. Please speak more clearly.");
                }
            }
        }
        
        // Continue listening in continuous mode
        if (continuousMode && !isSpeaking) {
            retryHandler.postDelayed(() -> startListening(), 500);
        }
    }
    
    @Override
    public void onPartialResults(Bundle partialResults) {
        ArrayList<String> partial = partialResults.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
        if (partial != null && !partial.isEmpty() && listener != null) {
            listener.onPartialResults(partial.get(0));
        }
    }
    
    @Override
    public void onEvent(int eventType, Bundle params) {
        // Not used
    }
    
    // TextToSpeech.OnInitListener
    @Override
    public void onInit(int status) {
        if (status == TextToSpeech.SUCCESS) {
            setLanguage(currentLocale);
            Log.d(TAG, "TextToSpeech initialized successfully");
        } else {
            Log.e(TAG, "TextToSpeech initialization failed");
        }
    }
    
    private String getErrorText(int errorCode) {
        switch (errorCode) {
            case SpeechRecognizer.ERROR_AUDIO:
                return "오디오 녹음 오류";
            case SpeechRecognizer.ERROR_CLIENT:
                return "클라이언트 오류";
            case SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS:
                return "권한이 부족합니다";
            case SpeechRecognizer.ERROR_NETWORK:
                return "네트워크 오류";
            case SpeechRecognizer.ERROR_NETWORK_TIMEOUT:
                return "네트워크 시간 초과";
            case SpeechRecognizer.ERROR_NO_MATCH:
                return "인식할 수 없습니다";
            case SpeechRecognizer.ERROR_RECOGNIZER_BUSY:
                return "음성 인식 서비스가 바쁩니다";
            case SpeechRecognizer.ERROR_SERVER:
                return "서버 오류";
            case SpeechRecognizer.ERROR_SPEECH_TIMEOUT:
                return "음성 입력을 기다리는 중...";
            default:
                return "알 수 없는 오류";
        }
    }
    
    private void handleSilenceTimeout() {
        if (isListening && detectingSilence) {
            Log.d(TAG, "Silence timeout - stopping recognition");
            speechRecognizer.stopListening();
        }
    }
    
    public void destroy() {
        stopListening();
        if (speechRecognizer != null) {
            speechRecognizer.destroy();
        }
        if (textToSpeech != null) {
            textToSpeech.stop();
            textToSpeech.shutdown();
        }
    }
    
    public boolean isListening() {
        return isListening;
    }
    
    public boolean isSpeaking() {
        return isSpeaking;
    }
}
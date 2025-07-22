package com.squashtrainingapp.services;

import android.content.Context;
import android.media.AudioManager;
import android.media.SoundPool;
import android.os.Handler;
import android.os.Looper;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.util.Log;

import com.squashtrainingapp.R;
import com.squashtrainingapp.models.Exercise;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Locale;
import java.util.Queue;

public class WorkoutVoiceGuide implements TextToSpeech.OnInitListener {
    private static final String TAG = "WorkoutVoiceGuide";
    
    private Context context;
    private TextToSpeech textToSpeech;
    private SoundPool soundPool;
    private Handler handler;
    
    // Sound effect IDs
    private int soundBeep;
    private int soundSuccess;
    private int soundCountdown;
    private int soundRest;
    
    // Voice guide state
    private boolean isActive = false;
    private boolean isPaused = false;
    private Queue<VoiceCommand> commandQueue;
    private WorkoutSession currentSession;
    
    // Callbacks
    private VoiceGuideListener listener;
    
    public interface VoiceGuideListener {
        void onExerciseStarted(String exerciseName);
        void onExerciseCompleted(String exerciseName);
        void onSetCompleted(int setNumber, int totalSets);
        void onRestStarted(int restDuration);
        void onRestCompleted();
        void onWorkoutCompleted();
        void onVoiceGuideError(String error);
    }
    
    private static class VoiceCommand {
        String text;
        int delayMs;
        boolean playSound;
        int soundId;
        
        VoiceCommand(String text, int delayMs) {
            this.text = text;
            this.delayMs = delayMs;
            this.playSound = false;
        }
        
        VoiceCommand(String text, int delayMs, int soundId) {
            this.text = text;
            this.delayMs = delayMs;
            this.playSound = true;
            this.soundId = soundId;
        }
    }
    
    private static class WorkoutSession {
        String exerciseName;
        int totalSets;
        int currentSet;
        int repsPerSet;
        int restBetweenSets;
        boolean isTimeBased;
        int durationSeconds;
        
        WorkoutSession(String exerciseName, int sets, int reps, int restSeconds) {
            this.exerciseName = exerciseName;
            this.totalSets = sets;
            this.currentSet = 0;
            this.repsPerSet = reps;
            this.restBetweenSets = restSeconds;
            this.isTimeBased = false;
        }
        
        WorkoutSession(String exerciseName, int sets, int durationSeconds, int restSeconds, boolean timeBased) {
            this.exerciseName = exerciseName;
            this.totalSets = sets;
            this.currentSet = 0;
            this.durationSeconds = durationSeconds;
            this.restBetweenSets = restSeconds;
            this.isTimeBased = timeBased;
        }
    }
    
    public WorkoutVoiceGuide(Context context) {
        this.context = context;
        this.handler = new Handler(Looper.getMainLooper());
        this.commandQueue = new LinkedList<>();
        
        initializeTextToSpeech();
        initializeSoundPool();
    }
    
    private void initializeTextToSpeech() {
        textToSpeech = new TextToSpeech(context, this);
        textToSpeech.setOnUtteranceProgressListener(new UtteranceProgressListener() {
            @Override
            public void onStart(String utteranceId) {
                Log.d(TAG, "Speaking: " + utteranceId);
            }
            
            @Override
            public void onDone(String utteranceId) {
                processNextCommand();
            }
            
            @Override
            public void onError(String utteranceId) {
                Log.e(TAG, "TTS Error: " + utteranceId);
                processNextCommand();
            }
        });
    }
    
    private void initializeSoundPool() {
        soundPool = new SoundPool.Builder()
            .setMaxStreams(4)
            .build();
        
        // Load sound effects (these would need to be added to res/raw/)
        try {
            soundBeep = soundPool.load(context, R.raw.beep, 1);
            soundSuccess = soundPool.load(context, R.raw.success, 1);
            soundCountdown = soundPool.load(context, R.raw.countdown, 1);
            soundRest = soundPool.load(context, R.raw.rest, 1);
        } catch (Exception e) {
            Log.w(TAG, "Some sound effects may not be available");
        }
    }
    
    @Override
    public void onInit(int status) {
        if (status == TextToSpeech.SUCCESS) {
            int result = textToSpeech.setLanguage(Locale.KOREAN);
            if (result == TextToSpeech.LANG_MISSING_DATA ||
                result == TextToSpeech.LANG_NOT_SUPPORTED) {
                Log.e(TAG, "Korean language not supported");
                textToSpeech.setLanguage(Locale.US);
            }
            textToSpeech.setSpeechRate(0.9f);
            textToSpeech.setPitch(1.0f);
        } else {
            Log.e(TAG, "TextToSpeech initialization failed");
            if (listener != null) {
                listener.onVoiceGuideError("음성 가이드 초기화 실패");
            }
        }
    }
    
    public void setVoiceGuideListener(VoiceGuideListener listener) {
        this.listener = listener;
    }
    
    public void startWorkout(String exerciseName, int sets, int reps, int restSeconds) {
        currentSession = new WorkoutSession(exerciseName, sets, reps, restSeconds);
        isActive = true;
        isPaused = false;
        
        // Initial announcement
        addCommand("운동을 시작합니다!", 1000);
        addCommand(exerciseName + ", " + sets + "세트, 각 " + reps + "회씩 진행합니다.", 2000);
        addCommand("준비하세요!", 1000, soundBeep);
        
        if (listener != null) {
            listener.onExerciseStarted(exerciseName);
        }
        
        // Start first set
        handler.postDelayed(this::startNextSet, 5000);
    }
    
    public void startTimeBasedWorkout(String exerciseName, int sets, int durationSeconds, int restSeconds) {
        currentSession = new WorkoutSession(exerciseName, sets, durationSeconds, restSeconds, true);
        isActive = true;
        isPaused = false;
        
        // Initial announcement
        addCommand("시간 기반 운동을 시작합니다!", 1000);
        addCommand(exerciseName + ", " + sets + "세트, 각 " + durationSeconds + "초씩 진행합니다.", 2000);
        addCommand("준비하세요!", 1000, soundBeep);
        
        if (listener != null) {
            listener.onExerciseStarted(exerciseName);
        }
        
        // Start first set
        handler.postDelayed(this::startNextSet, 5000);
    }
    
    private void startNextSet() {
        if (!isActive || isPaused || currentSession == null) return;
        
        currentSession.currentSet++;
        
        if (currentSession.currentSet > currentSession.totalSets) {
            completeWorkout();
            return;
        }
        
        // Announce set start
        addCommand(currentSession.currentSet + "세트 시작!", 500, soundBeep);
        
        if (currentSession.isTimeBased) {
            startTimedExercise();
        } else {
            startRepBasedExercise();
        }
    }
    
    private void startRepBasedExercise() {
        // Count reps with voice
        int repDelay = 2000; // 2 seconds per rep
        
        for (int i = 1; i <= currentSession.repsPerSet; i++) {
            final int rep = i;
            handler.postDelayed(() -> {
                if (isActive && !isPaused) {
                    speak(String.valueOf(rep));
                    if (rep == currentSession.repsPerSet) {
                        playSound(soundSuccess);
                        completeSet();
                    }
                }
            }, i * repDelay);
        }
    }
    
    private void startTimedExercise() {
        // Countdown timer
        int[] checkpoints = {30, 20, 10, 5, 3, 2, 1}; // Seconds to announce
        
        for (int checkpoint : checkpoints) {
            if (checkpoint <= currentSession.durationSeconds) {
                handler.postDelayed(() -> {
                    if (isActive && !isPaused) {
                        if (checkpoint <= 5) {
                            speak(checkpoint + "초!", soundCountdown);
                        } else {
                            speak(checkpoint + "초 남았습니다");
                        }
                    }
                }, (currentSession.durationSeconds - checkpoint) * 1000);
            }
        }
        
        // Complete set after duration
        handler.postDelayed(() -> {
            if (isActive && !isPaused) {
                playSound(soundSuccess);
                speak("세트 완료!");
                completeSet();
            }
        }, currentSession.durationSeconds * 1000);
    }
    
    private void completeSet() {
        if (listener != null) {
            listener.onSetCompleted(currentSession.currentSet, currentSession.totalSets);
        }
        
        if (currentSession.currentSet < currentSession.totalSets) {
            // Start rest period
            startRest();
        } else {
            // All sets completed
            handler.postDelayed(this::completeWorkout, 2000);
        }
    }
    
    private void startRest() {
        addCommand("휴식 시간입니다. " + currentSession.restBetweenSets + "초간 쉬세요.", 1000, soundRest);
        
        if (listener != null) {
            listener.onRestStarted(currentSession.restBetweenSets);
        }
        
        // Countdown during rest
        int[] restCheckpoints = {30, 20, 10, 5};
        for (int checkpoint : restCheckpoints) {
            if (checkpoint <= currentSession.restBetweenSets) {
                handler.postDelayed(() -> {
                    if (isActive && !isPaused) {
                        if (checkpoint == 5) {
                            speak("5초 후 다음 세트!");
                        } else {
                            speak(checkpoint + "초");
                        }
                    }
                }, (currentSession.restBetweenSets - checkpoint) * 1000);
            }
        }
        
        // End rest and start next set
        handler.postDelayed(() -> {
            if (isActive && !isPaused) {
                if (listener != null) {
                    listener.onRestCompleted();
                }
                startNextSet();
            }
        }, currentSession.restBetweenSets * 1000);
    }
    
    private void completeWorkout() {
        isActive = false;
        addCommand("훌륭합니다! 모든 세트를 완료했습니다!", 1000, soundSuccess);
        addCommand("오늘도 수고하셨습니다. 충분한 휴식을 취하세요.", 2000);
        
        if (listener != null) {
            listener.onExerciseCompleted(currentSession.exerciseName);
            listener.onWorkoutCompleted();
        }
        
        currentSession = null;
    }
    
    public void pauseWorkout() {
        isPaused = true;
        handler.removeCallbacksAndMessages(null);
        speak("운동을 일시정지합니다.");
    }
    
    public void resumeWorkout() {
        isPaused = false;
        speak("운동을 재개합니다.");
        // TODO: Implement proper resume logic based on current state
    }
    
    public void stopWorkout() {
        isActive = false;
        isPaused = false;
        handler.removeCallbacksAndMessages(null);
        commandQueue.clear();
        
        if (textToSpeech != null) {
            textToSpeech.stop();
        }
        
        speak("운동을 중단합니다.");
        currentSession = null;
    }
    
    private void addCommand(String text, int delayMs) {
        commandQueue.offer(new VoiceCommand(text, delayMs));
        if (commandQueue.size() == 1) {
            processNextCommand();
        }
    }
    
    private void addCommand(String text, int delayMs, int soundId) {
        commandQueue.offer(new VoiceCommand(text, delayMs, soundId));
        if (commandQueue.size() == 1) {
            processNextCommand();
        }
    }
    
    private void processNextCommand() {
        if (commandQueue.isEmpty()) return;
        
        VoiceCommand command = commandQueue.poll();
        if (command == null) return;
        
        handler.postDelayed(() -> {
            if (command.playSound) {
                playSound(command.soundId);
            }
            speak(command.text);
        }, command.delayMs);
    }
    
    private void speak(String text) {
        if (textToSpeech != null) {
            HashMap<String, String> params = new HashMap<>();
            params.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, text);
            textToSpeech.speak(text, TextToSpeech.QUEUE_FLUSH, params);
        }
    }
    
    private void speak(String text, int soundId) {
        playSound(soundId);
        speak(text);
    }
    
    private void playSound(int soundId) {
        if (soundPool != null && soundId != 0) {
            soundPool.play(soundId, 1.0f, 1.0f, 1, 0, 1.0f);
        }
    }
    
    public void provideMotivation() {
        String[] motivations = {
            "힘내세요! 할 수 있어요!",
            "좋아요! 계속 이 페이스를 유지하세요!",
            "훌륭합니다! 거의 다 왔어요!",
            "최고예요! 오늘 정말 잘하고 있어요!",
            "화이팅! 조금만 더 힘내세요!"
        };
        
        int randomIndex = (int) (Math.random() * motivations.length);
        speak(motivations[randomIndex]);
    }
    
    public void provideTechniqueTip(String exercise) {
        // Provide exercise-specific tips
        String tip = "";
        
        if (exercise.contains("포핸드") || exercise.contains("forehand")) {
            tip = "라켓을 뒤로 빼고, 공을 향해 스윙하세요. 팔로우스루를 잊지 마세요!";
        } else if (exercise.contains("백핸드") || exercise.contains("backhand")) {
            tip = "어깨를 돌려 준비하고, 두 손으로 안정적으로 스윙하세요.";
        } else if (exercise.contains("서브") || exercise.contains("serve")) {
            tip = "토스를 일정하게 하고, 최고점에서 공을 치세요.";
        } else if (exercise.contains("풋워크") || exercise.contains("footwork")) {
            tip = "발을 가볍게 움직이고, 항상 준비 자세를 유지하세요.";
        } else {
            tip = "자세를 바르게 유지하고, 호흡을 잊지 마세요.";
        }
        
        speak(tip);
    }
    
    public void destroy() {
        stopWorkout();
        
        if (textToSpeech != null) {
            textToSpeech.stop();
            textToSpeech.shutdown();
        }
        
        if (soundPool != null) {
            soundPool.release();
        }
        
        handler.removeCallbacksAndMessages(null);
    }
}
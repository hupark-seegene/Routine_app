package com.squashtrainingapp.managers;

import android.content.Context;
import android.content.SharedPreferences;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.squashtrainingapp.models.CustomExercise;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class CustomExerciseManager {
    
    private static final String PREFS_NAME = "custom_exercises";
    private static final String KEY_EXERCISES = "exercises";
    
    private Context context;
    private SharedPreferences prefs;
    private Gson gson;
    private List<CustomExercise> exercises;
    
    public CustomExerciseManager(Context context) {
        this.context = context;
        this.prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        this.gson = new Gson();
        loadExercises();
    }
    
    private void loadExercises() {
        String json = prefs.getString(KEY_EXERCISES, null);
        if (json != null) {
            Type type = new TypeToken<List<CustomExercise>>() {}.getType();
            exercises = gson.fromJson(json, type);
        } else {
            exercises = new ArrayList<>();
            initializeDefaultExercises();
        }
    }
    
    private void saveExercises() {
        String json = gson.toJson(exercises);
        prefs.edit().putString(KEY_EXERCISES, json).apply();
    }
    
    private void initializeDefaultExercises() {
        // Add some default exercises
        CustomExercise exercise1 = new CustomExercise(
            "포핸드 크로스코트",
            "코트 코너로 포핸드 드라이브 연습",
            CustomExercise.Category.FOREHAND,
            CustomExercise.Difficulty.MEDIUM,
            15
        );
        exercise1.setSets(3);
        exercise1.setReps(10);
        exercise1.setInstructions("서브 박스에서 시작하여 대각선으로 코트 코너를 향해 포핸드 드라이브");
        exercise1.setTips("라켓을 고르게 흔들며 팔로우 스루 동작을 유지하세요");
        exercise1.setUserCreated(false);
        
        CustomExercise exercise2 = new CustomExercise(
            "백핸드 부스트",
            "뒤쪽 코트에서 백핸드 부스트 연습",
            CustomExercise.Category.BOAST,
            CustomExercise.Difficulty.HARD,
            20
        );
        exercise2.setSets(3);
        exercise2.setReps(8);
        exercise2.setInstructions("뒤쪽 코트에서 백핸드로 발을 사용하여 전방 벽으로 부스트");
        exercise2.setTips("소프트 터치로 볼을 출발시키고 선수자차를 피하도록 주의하세요");
        exercise2.setUserCreated(false);
        
        CustomExercise exercise3 = new CustomExercise(
            "서브 정확도 향상",
            "목표 지점에 서브 넣기",
            CustomExercise.Category.SERVE,
            CustomExercise.Difficulty.EASY,
            10
        );
        exercise3.setSets(5);
        exercise3.setReps(5);
        exercise3.setInstructions("코트에 표시된 목표 지점으로 서브를 넣으세요");
        exercise3.setTips("토스 높이와 타이밍을 일정하게 유지하세요");
        exercise3.setUserCreated(false);
        
        exercises.add(exercise1);
        exercises.add(exercise2);
        exercises.add(exercise3);
        
        saveExercises();
    }
    
    // CRUD operations
    public void addExercise(CustomExercise exercise) {
        exercises.add(exercise);
        saveExercises();
    }
    
    public void updateExercise(CustomExercise exercise) {
        for (int i = 0; i < exercises.size(); i++) {
            if (exercises.get(i).getId().equals(exercise.getId())) {
                exercises.set(i, exercise);
                saveExercises();
                break;
            }
        }
    }
    
    public void deleteExercise(String exerciseId) {
        exercises.removeIf(e -> e.getId().equals(exerciseId));
        saveExercises();
    }
    
    public CustomExercise getExerciseById(String id) {
        for (CustomExercise exercise : exercises) {
            if (exercise.getId().equals(id)) {
                return exercise;
            }
        }
        return null;
    }
    
    // Query methods
    public List<CustomExercise> getAllExercises() {
        return new ArrayList<>(exercises);
    }
    
    public List<CustomExercise> getUserCreatedExercises() {
        return exercises.stream()
            .filter(CustomExercise::isUserCreated)
            .collect(Collectors.toList());
    }
    
    public List<CustomExercise> getExercisesByCategory(CustomExercise.Category category) {
        return exercises.stream()
            .filter(e -> e.getCategory() == category)
            .collect(Collectors.toList());
    }
    
    public List<CustomExercise> getExercisesByDifficulty(CustomExercise.Difficulty difficulty) {
        return exercises.stream()
            .filter(e -> e.getDifficulty() == difficulty)
            .collect(Collectors.toList());
    }
    
    public List<CustomExercise> getRecentlyUsedExercises(int limit) {
        return exercises.stream()
            .filter(e -> e.getLastUsedDate() > 0)
            .sorted((e1, e2) -> Long.compare(e2.getLastUsedDate(), e1.getLastUsedDate()))
            .limit(limit)
            .collect(Collectors.toList());
    }
    
    public List<CustomExercise> getMostUsedExercises(int limit) {
        return exercises.stream()
            .filter(e -> e.getTimesUsed() > 0)
            .sorted((e1, e2) -> Integer.compare(e2.getTimesUsed(), e1.getTimesUsed()))
            .limit(limit)
            .collect(Collectors.toList());
    }
    
    public List<CustomExercise> searchExercises(String query) {
        String lowerQuery = query.toLowerCase();
        return exercises.stream()
            .filter(e -> e.getName().toLowerCase().contains(lowerQuery) ||
                        e.getDescription().toLowerCase().contains(lowerQuery) ||
                        e.getCategory().getKorean().contains(query))
            .collect(Collectors.toList());
    }
    
    // Utility methods
    public void recordExerciseUsage(String exerciseId) {
        CustomExercise exercise = getExerciseById(exerciseId);
        if (exercise != null) {
            exercise.incrementUsage();
            saveExercises();
        }
    }
    
    public int getTotalExerciseCount() {
        return exercises.size();
    }
    
    public int getUserCreatedCount() {
        return (int) exercises.stream()
            .filter(CustomExercise::isUserCreated)
            .count();
    }
}
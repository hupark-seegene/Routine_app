package com.squashtrainingapp.managers;

import android.content.Context;
import android.content.SharedPreferences;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.squashtrainingapp.models.Achievement;
import com.squashtrainingapp.models.User;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class AchievementManager {
    
    private static final String PREFS_NAME = "achievements";
    private static final String KEY_ACHIEVEMENTS = "achievements";
    private static final String KEY_TOTAL_POINTS = "total_points";
    
    private Context context;
    private SharedPreferences prefs;
    private Gson gson;
    private Map<String, Achievement> achievements;
    private int totalPoints;
    
    // Achievement IDs
    public static final String FIRST_WORKOUT = "first_workout";
    public static final String WORKOUT_10 = "workout_10";
    public static final String WORKOUT_50 = "workout_50";
    public static final String WORKOUT_100 = "workout_100";
    public static final String STREAK_7 = "streak_7";
    public static final String STREAK_30 = "streak_30";
    public static final String STREAK_100 = "streak_100";
    public static final String CALORIES_1000 = "calories_1000";
    public static final String CALORIES_10000 = "calories_10000";
    public static final String CALORIES_50000 = "calories_50000";
    public static final String LEVEL_5 = "level_5";
    public static final String LEVEL_10 = "level_10";
    public static final String PROGRAM_COMPLETE = "program_complete";
    public static final String SPEED_DEMON = "speed_demon";
    public static final String EARLY_BIRD = "early_bird";
    public static final String NIGHT_OWL = "night_owl";
    
    public AchievementManager(Context context) {
        this.context = context;
        this.prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        this.gson = new Gson();
        loadAchievements();
    }
    
    private void loadAchievements() {
        String json = prefs.getString(KEY_ACHIEVEMENTS, null);
        if (json != null) {
            Type type = new TypeToken<Map<String, Achievement>>() {}.getType();
            achievements = gson.fromJson(json, type);
        } else {
            achievements = new HashMap<>();
            initializeAchievements();
        }
        totalPoints = prefs.getInt(KEY_TOTAL_POINTS, 0);
    }
    
    private void saveAchievements() {
        String json = gson.toJson(achievements);
        prefs.edit()
            .putString(KEY_ACHIEVEMENTS, json)
            .putInt(KEY_TOTAL_POINTS, totalPoints)
            .apply();
    }
    
    private void initializeAchievements() {
        // Workout count achievements
        achievements.put(FIRST_WORKOUT, new Achievement(
            FIRST_WORKOUT, 
            "첫 발걸음",
            "첫 운동을 완료했습니다!",
            Achievement.AchievementType.WORKOUT_COUNT,
            Achievement.AchievementRank.BRONZE,
            1, "🎆", 10
        ));
        
        achievements.put(WORKOUT_10, new Achievement(
            WORKOUT_10,
            "워밍업 완료",
            "10회 운동을 완료했습니다",
            Achievement.AchievementType.WORKOUT_COUNT,
            Achievement.AchievementRank.BRONZE,
            10, "🎯", 50
        ));
        
        achievements.put(WORKOUT_50, new Achievement(
            WORKOUT_50,
            "운동 마니아",
            "50회 운동을 완료했습니다",
            Achievement.AchievementType.WORKOUT_COUNT,
            Achievement.AchievementRank.SILVER,
            50, "💪", 100
        ));
        
        achievements.put(WORKOUT_100, new Achievement(
            WORKOUT_100,
            "백전백승",
            "100회 운동을 완료했습니다",
            Achievement.AchievementType.WORKOUT_COUNT,
            Achievement.AchievementRank.GOLD,
            100, "🏆", 200
        ));
        
        // Streak achievements
        achievements.put(STREAK_7, new Achievement(
            STREAK_7,
            "주간 전사",
            "7일 연속 운동을 달성했습니다",
            Achievement.AchievementType.STREAK,
            Achievement.AchievementRank.BRONZE,
            7, "🔥", 50
        ));
        
        achievements.put(STREAK_30, new Achievement(
            STREAK_30,
            "월간 챙피언",
            "30일 연속 운동을 달성했습니다",
            Achievement.AchievementType.STREAK,
            Achievement.AchievementRank.SILVER,
            30, "⚡", 150
        ));
        
        achievements.put(STREAK_100, new Achievement(
            STREAK_100,
            "철인",
            "100일 연속 운동을 달성했습니다",
            Achievement.AchievementType.STREAK,
            Achievement.AchievementRank.DIAMOND,
            100, "💎", 500
        ));
        
        // Calorie achievements
        achievements.put(CALORIES_1000, new Achievement(
            CALORIES_1000,
            "칼로리 버니",
            "1,000 칼로리를 소모했습니다",
            Achievement.AchievementType.CALORIES,
            Achievement.AchievementRank.BRONZE,
            1000, "🔥", 30
        ));
        
        achievements.put(CALORIES_10000, new Achievement(
            CALORIES_10000,
            "에너지 폭발",
            "10,000 칼로리를 소모했습니다",
            Achievement.AchievementType.CALORIES,
            Achievement.AchievementRank.SILVER,
            10000, "💥", 100
        ));
        
        // Level achievements
        achievements.put(LEVEL_5, new Achievement(
            LEVEL_5,
            "중급자 달성",
            "레벨 5를 달성했습니다",
            Achievement.AchievementType.LEVEL,
            Achievement.AchievementRank.SILVER,
            5, "🌟", 100
        ));
        
        achievements.put(LEVEL_10, new Achievement(
            LEVEL_10,
            "마스터 플레이어",
            "레벨 10을 달성했습니다",
            Achievement.AchievementType.LEVEL,
            Achievement.AchievementRank.GOLD,
            10, "👑", 250
        ));
        
        // Special achievements
        achievements.put(SPEED_DEMON, new Achievement(
            SPEED_DEMON,
            "스피드 데몬",
            "평균 속도 200+ 달성",
            Achievement.AchievementType.SPECIAL,
            Achievement.AchievementRank.GOLD,
            1, "🚀", 150
        ));
        
        achievements.put(EARLY_BIRD, new Achievement(
            EARLY_BIRD,
            "아침형 인간",
            "오전 6시 이전에 운동 완료",
            Achievement.AchievementType.SPECIAL,
            Achievement.AchievementRank.BRONZE,
            1, "🌅", 50
        ));
        
        achievements.put(NIGHT_OWL, new Achievement(
            NIGHT_OWL,
            "야간 전사",
            "오후 10시 이후에 운동 완료",
            Achievement.AchievementType.SPECIAL,
            Achievement.AchievementRank.BRONZE,
            1, "🌙", 50
        ));
        
        saveAchievements();
    }
    
    // Check and update achievements
    public List<Achievement> checkWorkoutAchievements(int totalWorkouts) {
        List<Achievement> newlyUnlocked = new ArrayList<>();
        
        updateAchievementProgress(FIRST_WORKOUT, totalWorkouts, newlyUnlocked);
        updateAchievementProgress(WORKOUT_10, totalWorkouts, newlyUnlocked);
        updateAchievementProgress(WORKOUT_50, totalWorkouts, newlyUnlocked);
        updateAchievementProgress(WORKOUT_100, totalWorkouts, newlyUnlocked);
        
        return newlyUnlocked;
    }
    
    public List<Achievement> checkStreakAchievements(int currentStreak) {
        List<Achievement> newlyUnlocked = new ArrayList<>();
        
        updateAchievementProgress(STREAK_7, currentStreak, newlyUnlocked);
        updateAchievementProgress(STREAK_30, currentStreak, newlyUnlocked);
        updateAchievementProgress(STREAK_100, currentStreak, newlyUnlocked);
        
        return newlyUnlocked;
    }
    
    public List<Achievement> checkCalorieAchievements(int totalCalories) {
        List<Achievement> newlyUnlocked = new ArrayList<>();
        
        updateAchievementProgress(CALORIES_1000, totalCalories, newlyUnlocked);
        updateAchievementProgress(CALORIES_10000, totalCalories, newlyUnlocked);
        updateAchievementProgress(CALORIES_50000, totalCalories, newlyUnlocked);
        
        return newlyUnlocked;
    }
    
    public List<Achievement> checkLevelAchievements(int level) {
        List<Achievement> newlyUnlocked = new ArrayList<>();
        
        updateAchievementProgress(LEVEL_5, level, newlyUnlocked);
        updateAchievementProgress(LEVEL_10, level, newlyUnlocked);
        
        return newlyUnlocked;
    }
    
    public List<Achievement> checkSpecialAchievements(String type, Object data) {
        List<Achievement> newlyUnlocked = new ArrayList<>();
        
        switch (type) {
            case "speed":
                if ((int) data >= 200) {
                    updateAchievementProgress(SPEED_DEMON, 1, newlyUnlocked);
                }
                break;
            case "early_bird":
                updateAchievementProgress(EARLY_BIRD, 1, newlyUnlocked);
                break;
            case "night_owl":
                updateAchievementProgress(NIGHT_OWL, 1, newlyUnlocked);
                break;
        }
        
        return newlyUnlocked;
    }
    
    private void updateAchievementProgress(String achievementId, int value, 
                                          List<Achievement> newlyUnlocked) {
        Achievement achievement = achievements.get(achievementId);
        if (achievement != null && !achievement.isUnlocked()) {
            boolean wasUnlocked = achievement.isUnlocked();
            achievement.setCurrentValue(value);
            
            if (!wasUnlocked && achievement.isUnlocked()) {
                newlyUnlocked.add(achievement);
                totalPoints += achievement.getPoints();
                saveAchievements();
            }
        }
    }
    
    // Query methods
    public List<Achievement> getAllAchievements() {
        return new ArrayList<>(achievements.values());
    }
    
    public List<Achievement> getUnlockedAchievements() {
        return achievements.values().stream()
            .filter(Achievement::isUnlocked)
            .collect(Collectors.toList());
    }
    
    public List<Achievement> getLockedAchievements() {
        return achievements.values().stream()
            .filter(a -> !a.isUnlocked())
            .collect(Collectors.toList());
    }
    
    public List<Achievement> getAchievementsByType(Achievement.AchievementType type) {
        return achievements.values().stream()
            .filter(a -> a.getType() == type)
            .collect(Collectors.toList());
    }
    
    public Achievement getAchievement(String id) {
        return achievements.get(id);
    }
    
    public int getTotalPoints() {
        return totalPoints;
    }
    
    public int getUnlockedCount() {
        return (int) achievements.values().stream()
            .filter(Achievement::isUnlocked)
            .count();
    }
    
    public int getTotalCount() {
        return achievements.size();
    }
    
    public float getCompletionPercentage() {
        if (achievements.isEmpty()) {
            return 0f;
        }
        return (float) getUnlockedCount() / getTotalCount() * 100;
    }
}
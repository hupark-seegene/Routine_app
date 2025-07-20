package com.squashtrainingapp.ai;

import android.content.Context;
import android.util.Log;

import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.User;
import com.squashtrainingapp.models.WorkoutRecommendation;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

public class SmartRecommendationEngine {
    private static final String TAG = "SmartRecommendation";
    
    private Context context;
    private DatabaseHelper dbHelper;
    private User currentUser;
    
    // Recommendation parameters
    private static final int BEGINNER_LEVEL = 1;
    private static final int INTERMEDIATE_LEVEL = 5;
    private static final int ADVANCED_LEVEL = 10;
    
    // Exercise types
    private static final String TYPE_CARDIO = "cardio";
    private static final String TYPE_STRENGTH = "strength";
    private static final String TYPE_TECHNIQUE = "technique";
    private static final String TYPE_FOOTWORK = "footwork";
    private static final String TYPE_MENTAL = "mental";
    
    // Recommendation weights
    private static final double PERFORMANCE_WEIGHT = 0.3;
    private static final double VARIETY_WEIGHT = 0.2;
    private static final double DIFFICULTY_WEIGHT = 0.2;
    private static final double RECENT_WEIGHT = 0.15;
    private static final double PREFERENCE_WEIGHT = 0.15;
    
    public SmartRecommendationEngine(Context context) {
        this.context = context;
        this.dbHelper = DatabaseHelper.getInstance(context);
        this.currentUser = dbHelper.getUserDao().getUser();
    }
    
    public List<WorkoutRecommendation> getPersonalizedRecommendations() {
        List<WorkoutRecommendation> recommendations = new ArrayList<>();
        
        // Analyze user's workout history
        UserProfile profile = analyzeUserProfile();
        
        // Get recommendations based on different criteria
        recommendations.addAll(getProgressBasedRecommendations(profile));
        recommendations.addAll(getVarietyRecommendations(profile));
        recommendations.addAll(getWeaknessRecommendations(profile));
        recommendations.addAll(getTimeBasedRecommendations(profile));
        
        // Score and sort recommendations
        scoreRecommendations(recommendations, profile);
        Collections.sort(recommendations, (r1, r2) -> 
            Double.compare(r2.getScore(), r1.getScore()));
        
        // Return top recommendations
        return recommendations.subList(0, Math.min(10, recommendations.size()));
    }
    
    private UserProfile analyzeUserProfile() {
        UserProfile profile = new UserProfile();
        
        // Simplified analysis without database access
        // In a real implementation, would fetch from database
        
        profile.totalWorkouts = currentUser.getTotalSessions();
        profile.level = currentUser.getLevel();
        profile.currentStreak = currentUser.getCurrentStreak();
        
        // Mock exercise type distribution
        Map<String, Integer> typeCount = new HashMap<>();
        typeCount.put(TYPE_CARDIO, 10);
        typeCount.put(TYPE_STRENGTH, 8);
        typeCount.put(TYPE_TECHNIQUE, 12);
        typeCount.put(TYPE_FOOTWORK, 6);
        typeCount.put(TYPE_MENTAL, 4);
        
        Map<String, Double> typePerformance = new HashMap<>();
        typePerformance.put(TYPE_CARDIO, 0.8);
        typePerformance.put(TYPE_STRENGTH, 0.7);
        typePerformance.put(TYPE_TECHNIQUE, 0.85);
        typePerformance.put(TYPE_FOOTWORK, 0.6);
        typePerformance.put(TYPE_MENTAL, 0.75);
        
        profile.exerciseTypeDistribution = typeCount;
        profile.exerciseTypePerformance = typePerformance;
        
        // Find weakest areas
        profile.weakestAreas = findWeakestAreas(typePerformance);
        
        // Calculate workout frequency (mock)
        profile.workoutFrequency = 3.5;
        
        return profile;
    }
    
    private List<WorkoutRecommendation> getProgressBasedRecommendations(UserProfile profile) {
        List<WorkoutRecommendation> recommendations = new ArrayList<>();
        
        // Recommend based on user level
        if (profile.level < INTERMEDIATE_LEVEL) {
            // Beginner recommendations
            recommendations.add(new WorkoutRecommendation(
                "기초 체력 향상 프로그램",
                "초보자를 위한 점진적 체력 향상 프로그램입니다.",
                TYPE_CARDIO,
                profile.level + 1,
                30,
                "foundation"
            ));
            
            recommendations.add(new WorkoutRecommendation(
                "기본 기술 마스터",
                "스쿼시 기본 스트로크와 움직임을 익히는 프로그램입니다.",
                TYPE_TECHNIQUE,
                profile.level,
                45,
                "basics"
            ));
        } else if (profile.level < ADVANCED_LEVEL) {
            // Intermediate recommendations
            recommendations.add(new WorkoutRecommendation(
                "전술 개발 훈련",
                "경기 전략과 포지셔닝을 향상시키는 프로그램입니다.",
                TYPE_MENTAL,
                profile.level + 1,
                60,
                "tactics"
            ));
            
            recommendations.add(new WorkoutRecommendation(
                "파워 & 스피드 강화",
                "폭발적인 움직임과 반응 속도를 개선합니다.",
                TYPE_STRENGTH,
                profile.level + 1,
                45,
                "power"
            ));
        } else {
            // Advanced recommendations
            recommendations.add(new WorkoutRecommendation(
                "엘리트 컨디셔닝",
                "최고 수준의 체력과 지구력을 위한 고강도 프로그램입니다.",
                TYPE_CARDIO,
                profile.level,
                90,
                "elite"
            ));
            
            recommendations.add(new WorkoutRecommendation(
                "정신력 강화 훈련",
                "압박 상황에서의 집중력과 의사결정을 향상시킵니다.",
                TYPE_MENTAL,
                profile.level,
                30,
                "mental"
            ));
        }
        
        return recommendations;
    }
    
    private List<WorkoutRecommendation> getVarietyRecommendations(UserProfile profile) {
        List<WorkoutRecommendation> recommendations = new ArrayList<>();
        
        // Find least practiced exercise types
        String[] allTypes = {TYPE_CARDIO, TYPE_STRENGTH, TYPE_TECHNIQUE, 
                           TYPE_FOOTWORK, TYPE_MENTAL};
        
        for (String type : allTypes) {
            int count = profile.exerciseTypeDistribution.getOrDefault(type, 0);
            if (count < profile.totalWorkouts / allTypes.length) {
                // This type is underrepresented
                recommendations.add(createVarietyRecommendation(type, profile.level));
            }
        }
        
        return recommendations;
    }
    
    private List<WorkoutRecommendation> getWeaknessRecommendations(UserProfile profile) {
        List<WorkoutRecommendation> recommendations = new ArrayList<>();
        
        for (String weakArea : profile.weakestAreas) {
            WorkoutRecommendation rec = createWeaknessRecommendation(weakArea, profile.level);
            if (rec != null) {
                recommendations.add(rec);
            }
        }
        
        return recommendations;
    }
    
    private List<WorkoutRecommendation> getTimeBasedRecommendations(UserProfile profile) {
        List<WorkoutRecommendation> recommendations = new ArrayList<>();
        
        Calendar cal = Calendar.getInstance();
        int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
        int hour = cal.get(Calendar.HOUR_OF_DAY);
        
        // Morning recommendations (6-10 AM)
        if (hour >= 6 && hour <= 10) {
            recommendations.add(new WorkoutRecommendation(
                "모닝 에너지 부스터",
                "하루를 활기차게 시작하는 중강도 운동입니다.",
                TYPE_CARDIO,
                profile.level,
                30,
                "morning"
            ));
        }
        
        // Weekend recommendations
        if (dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY) {
            recommendations.add(new WorkoutRecommendation(
                "주말 집중 훈련",
                "시간이 충분한 주말을 위한 종합 훈련 프로그램입니다.",
                TYPE_TECHNIQUE,
                profile.level,
                90,
                "weekend"
            ));
        }
        
        // Recovery day recommendation
        if (profile.currentStreak >= 5) {
            recommendations.add(new WorkoutRecommendation(
                "액티브 리커버리",
                "피로 회복과 유연성 향상을 위한 저강도 운동입니다.",
                TYPE_FOOTWORK,
                Math.max(1, profile.level - 2),
                30,
                "recovery"
            ));
        }
        
        return recommendations;
    }
    
    private void scoreRecommendations(List<WorkoutRecommendation> recommendations, 
                                    UserProfile profile) {
        for (WorkoutRecommendation rec : recommendations) {
            double score = 0;
            
            // Performance score
            double avgPerformance = profile.exerciseTypePerformance
                .getOrDefault(rec.getType(), 0.5);
            score += (1 - avgPerformance) * PERFORMANCE_WEIGHT;
            
            // Variety score
            int typeCount = profile.exerciseTypeDistribution
                .getOrDefault(rec.getType(), 0);
            double varietyScore = 1.0 - (typeCount / (double) profile.totalWorkouts);
            score += varietyScore * VARIETY_WEIGHT;
            
            // Difficulty score (should match user level)
            double difficultyMatch = 1.0 - Math.abs(rec.getDifficulty() - profile.level) / 10.0;
            score += difficultyMatch * DIFFICULTY_WEIGHT;
            
            // Recent score (prefer exercises not done recently)
            score += RECENT_WEIGHT; // Simplified - would check actual recent history
            
            // Preference score (based on past performance)
            if (avgPerformance > 0.7) {
                score += avgPerformance * PREFERENCE_WEIGHT;
            }
            
            rec.setScore(score);
        }
    }
    
    private double calculatePerformance(String exerciseType, int difficulty) {
        // Simple performance calculation
        // In real implementation, would consider actual session data
        Random random = new Random();
        return 0.5 + (random.nextDouble() * 0.5);
    }
    
    private List<String> findWeakestAreas(Map<String, Double> performance) {
        List<Map.Entry<String, Double>> entries = new ArrayList<>(performance.entrySet());
        Collections.sort(entries, Map.Entry.comparingByValue());
        
        List<String> weakest = new ArrayList<>();
        for (int i = 0; i < Math.min(2, entries.size()); i++) {
            if (entries.get(i).getValue() < 0.6) {
                weakest.add(entries.get(i).getKey());
            }
        }
        
        return weakest;
    }
    
    private WorkoutRecommendation createVarietyRecommendation(String type, int level) {
        switch (type) {
            case TYPE_CARDIO:
                return new WorkoutRecommendation(
                    "인터벌 트레이닝",
                    "심폐 지구력 향상을 위한 고강도 인터벌 훈련입니다.",
                    type, level, 30, "interval"
                );
            case TYPE_STRENGTH:
                return new WorkoutRecommendation(
                    "코어 강화 운동",
                    "스쿼시에 필요한 핵심 근력을 강화합니다.",
                    type, level, 45, "core"
                );
            case TYPE_TECHNIQUE:
                return new WorkoutRecommendation(
                    "스트로크 정교화",
                    "정확성과 일관성을 향상시키는 기술 훈련입니다.",
                    type, level, 60, "strokes"
                );
            case TYPE_FOOTWORK:
                return new WorkoutRecommendation(
                    "민첩성 드릴",
                    "빠른 방향 전환과 균형을 개선합니다.",
                    type, level, 30, "agility"
                );
            case TYPE_MENTAL:
                return new WorkoutRecommendation(
                    "집중력 훈련",
                    "경기 중 집중력 유지를 위한 정신 훈련입니다.",
                    type, level, 20, "focus"
                );
            default:
                return null;
        }
    }
    
    private WorkoutRecommendation createWeaknessRecommendation(String weakArea, int level) {
        // Create targeted recommendations for weak areas
        return new WorkoutRecommendation(
            weakArea + " 강화 프로그램",
            "약점을 보완하고 균형잡힌 실력을 만들어갑니다.",
            weakArea,
            Math.max(1, level - 1),
            45,
            "weakness_" + weakArea
        );
    }
    
    // Inner class for user profile analysis
    private static class UserProfile {
        int totalWorkouts;
        int level;
        int currentStreak;
        double workoutFrequency;
        Map<String, Integer> exerciseTypeDistribution = new HashMap<>();
        Map<String, Double> exerciseTypePerformance = new HashMap<>();
        List<String> weakestAreas = new ArrayList<>();
    }
}
package com.squashtrainingapp.analytics;

import android.content.Context;
import android.util.Log;

import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.WorkoutSession;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class AnalyticsService {
    private static final String TAG = "AnalyticsService";
    
    private Context context;
    private FirebaseFirestore db;
    private FirebaseAuthManager authManager;
    private DatabaseHelper databaseHelper;
    
    // Analytics data types
    public enum AnalyticsType {
        PERFORMANCE_METRICS,    // Speed, power, accuracy
        CONSISTENCY_TRENDS,     // Workout frequency, streak
        SKILL_PROGRESSION,      // Technique improvements
        FITNESS_TRACKING,       // Calories, duration, intensity
        GOAL_ACHIEVEMENT,       // Goal completion rates
        COMPARISON_DATA,        // vs past self, vs others
        INJURY_PREVENTION      // Rest days, fatigue levels
    }
    
    // Time periods for analysis
    public enum TimePeriod {
        WEEK(7),
        MONTH(30),
        THREE_MONTHS(90),
        SIX_MONTHS(180),
        YEAR(365),
        ALL_TIME(9999);
        
        private final int days;
        
        TimePeriod(int days) {
            this.days = days;
        }
        
        public int getDays() {
            return days;
        }
    }
    
    public interface AnalyticsCallback {
        void onSuccess(AnalyticsData data);
        void onError(String error);
    }
    
    public AnalyticsService(Context context) {
        this.context = context;
        this.db = FirebaseFirestore.getInstance();
        this.authManager = FirebaseAuthManager.getInstance(context);
        this.databaseHelper = DatabaseHelper.getInstance(context);
    }
    
    // Get comprehensive analytics data
    public void getAnalyticsDashboard(TimePeriod period, AnalyticsCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        long startTime = getStartTime(period);
        
        AnalyticsData analyticsData = new AnalyticsData();
        
        // Fetch multiple data sources in parallel
        fetchWorkoutStats(userId, startTime, analyticsData);
        fetchPerformanceMetrics(userId, startTime, analyticsData);
        fetchProgressionData(userId, startTime, analyticsData);
        fetchGoalCompletion(userId, startTime, analyticsData);
        fetchComparisonData(userId, startTime, analyticsData);
        
        // Wait for all data to be fetched (simplified for now)
        new android.os.Handler().postDelayed(() -> {
            callback.onSuccess(analyticsData);
        }, 1000);
    }
    
    // Get performance metrics
    public void getPerformanceMetrics(TimePeriod period, AnalyticsCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        long startTime = getStartTime(period);
        
        db.collection("workoutMetrics")
                .whereEqualTo("userId", userId)
                .whereGreaterThan("timestamp", startTime)
                .orderBy("timestamp", Query.Direction.DESCENDING)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        AnalyticsData data = new AnalyticsData();
                        List<PerformanceMetric> metrics = new ArrayList<>();
                        
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            PerformanceMetric metric = parsePerformanceMetric(doc);
                            if (metric != null) {
                                metrics.add(metric);
                            }
                        }
                        
                        data.performanceMetrics = calculateAverageMetrics(metrics);
                        data.performanceTrend = calculateTrend(metrics);
                        
                        callback.onSuccess(data);
                    } else {
                        Log.e(TAG, "Failed to get performance metrics", task.getException());
                        callback.onError("Failed to load performance metrics");
                    }
                });
    }
    
    // Get skill progression analysis
    public void getSkillProgression(TimePeriod period, AnalyticsCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        AnalyticsData data = new AnalyticsData();
        data.skillProgression = new SkillProgression();
        
        // Analyze technique improvements
        analyzeTechnique(userId, period, data.skillProgression);
        
        // Analyze consistency
        analyzeConsistency(userId, period, data.skillProgression);
        
        // Analyze accuracy
        analyzeAccuracy(userId, period, data.skillProgression);
        
        callback.onSuccess(data);
    }
    
    // Get fitness tracking data
    public void getFitnessData(TimePeriod period, AnalyticsCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        long startTime = getStartTime(period);
        
        // Get workout sessions from local database
        // In a real app, you would get this from the database
        // For now, create mock data
        List<WorkoutSession> sessions = new ArrayList<>();
        
        // Add some mock sessions
        for (int i = 0; i < 5; i++) {
            WorkoutSession session = new WorkoutSession();
            session.setSessionName("스쿼시 트레이닝 " + (i + 1));
            session.setDurationMinutes(45 + (i * 10));
            session.setScheduledDate(new Date(System.currentTimeMillis() - (i * 24 * 60 * 60 * 1000)));
            sessions.add(session);
        }
        
        AnalyticsData data = new AnalyticsData();
        data.fitnessStats = new FitnessStats();
        
        // Calculate totals
        int totalCalories = 0;
        int totalDuration = 0;
        int totalSessions = sessions.size();
        Map<String, Integer> exerciseFrequency = new HashMap<>();
        
        for (WorkoutSession session : sessions) {
            totalDuration += session.getDurationMinutes();
            totalCalories += calculateCalories(session);
            
            String exerciseType = session.getExerciseTypes();
            exerciseFrequency.put(exerciseType, 
                    exerciseFrequency.getOrDefault(exerciseType, 0) + 1);
        }
        
        data.fitnessStats.totalCaloriesBurned = totalCalories;
        data.fitnessStats.totalMinutesExercised = totalDuration;
        data.fitnessStats.averageSessionDuration = totalSessions > 0 ? 
                totalDuration / totalSessions : 0;
        data.fitnessStats.workoutFrequency = calculateFrequency(sessions, period);
        data.fitnessStats.mostFrequentExercise = getMostFrequent(exerciseFrequency);
        
        callback.onSuccess(data);
    }
    
    // Get goal achievement data
    public void getGoalAchievement(AnalyticsCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        db.collection("userGoals")
                .whereEqualTo("userId", userId)
                .get()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        AnalyticsData data = new AnalyticsData();
                        data.goalStats = new GoalStats();
                        
                        int totalGoals = 0;
                        int completedGoals = 0;
                        int activeGoals = 0;
                        
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            totalGoals++;
                            String status = doc.getString("status");
                            if ("completed".equals(status)) {
                                completedGoals++;
                            } else if ("active".equals(status)) {
                                activeGoals++;
                            }
                        }
                        
                        data.goalStats.totalGoals = totalGoals;
                        data.goalStats.completedGoals = completedGoals;
                        data.goalStats.activeGoals = activeGoals;
                        data.goalStats.completionRate = totalGoals > 0 ? 
                                (float) completedGoals / totalGoals * 100 : 0;
                        
                        callback.onSuccess(data);
                    } else {
                        Log.e(TAG, "Failed to get goals", task.getException());
                        callback.onError("Failed to load goal data");
                    }
                });
    }
    
    // Get injury prevention insights
    public void getInjuryPreventionInsights(AnalyticsCallback callback) {
        String userId = authManager.getCurrentUser().getUid();
        
        AnalyticsData data = new AnalyticsData();
        data.injuryPrevention = new InjuryPreventionData();
        
        // Analyze rest days
        analyzeRestDays(userId, data.injuryPrevention);
        
        // Analyze workout intensity patterns
        analyzeIntensityPatterns(userId, data.injuryPrevention);
        
        // Generate recommendations
        generateInjuryPreventionTips(data.injuryPrevention);
        
        callback.onSuccess(data);
    }
    
    // Record workout metrics
    public void recordWorkoutMetrics(WorkoutMetrics metrics) {
        String userId = authManager.getCurrentUser().getUid();
        
        Map<String, Object> data = new HashMap<>();
        data.put("userId", userId);
        data.put("sessionId", metrics.sessionId);
        data.put("timestamp", System.currentTimeMillis());
        data.put("averageHeartRate", metrics.averageHeartRate);
        data.put("maxHeartRate", metrics.maxHeartRate);
        data.put("caloriesBurned", metrics.caloriesBurned);
        data.put("shotAccuracy", metrics.shotAccuracy);
        data.put("rallyLength", metrics.averageRallyLength);
        data.put("courtCoverage", metrics.courtCoveragePercent);
        data.put("powerRating", metrics.powerRating);
        data.put("speedRating", metrics.speedRating);
        
        db.collection("workoutMetrics")
                .add(data)
                .addOnSuccessListener(ref -> {
                    Log.d(TAG, "Metrics recorded successfully");
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to record metrics", e);
                });
    }
    
    // Helper methods
    private long getStartTime(TimePeriod period) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_YEAR, -period.getDays());
        return cal.getTimeInMillis();
    }
    
    private void fetchWorkoutStats(String userId, long startTime, AnalyticsData data) {
        // Implementation for fetching workout statistics
        data.workoutStats = new WorkoutStats();
        // This would be filled with actual data from Firebase
    }
    
    private void fetchPerformanceMetrics(String userId, long startTime, AnalyticsData data) {
        // Implementation for fetching performance metrics
        data.performanceMetrics = new PerformanceMetrics();
    }
    
    private void fetchProgressionData(String userId, long startTime, AnalyticsData data) {
        // Implementation for fetching progression data
        data.skillProgression = new SkillProgression();
    }
    
    private void fetchGoalCompletion(String userId, long startTime, AnalyticsData data) {
        // Implementation for fetching goal completion data
        data.goalStats = new GoalStats();
    }
    
    private void fetchComparisonData(String userId, long startTime, AnalyticsData data) {
        // Implementation for fetching comparison data
        data.comparisonData = new ComparisonData();
    }
    
    private PerformanceMetric parsePerformanceMetric(DocumentSnapshot doc) {
        try {
            PerformanceMetric metric = new PerformanceMetric();
            metric.timestamp = doc.getLong("timestamp");
            metric.shotAccuracy = doc.getDouble("shotAccuracy").floatValue();
            metric.powerRating = doc.getDouble("powerRating").floatValue();
            metric.speedRating = doc.getDouble("speedRating").floatValue();
            return metric;
        } catch (Exception e) {
            Log.e(TAG, "Failed to parse metric", e);
            return null;
        }
    }
    
    private PerformanceMetrics calculateAverageMetrics(List<PerformanceMetric> metrics) {
        PerformanceMetrics avg = new PerformanceMetrics();
        if (metrics.isEmpty()) return avg;
        
        float totalAccuracy = 0, totalPower = 0, totalSpeed = 0;
        for (PerformanceMetric metric : metrics) {
            totalAccuracy += metric.shotAccuracy;
            totalPower += metric.powerRating;
            totalSpeed += metric.speedRating;
        }
        
        int count = metrics.size();
        avg.averageShotAccuracy = totalAccuracy / count;
        avg.averagePowerRating = totalPower / count;
        avg.averageSpeedRating = totalSpeed / count;
        
        return avg;
    }
    
    private float calculateTrend(List<PerformanceMetric> metrics) {
        if (metrics.size() < 2) return 0;
        
        // Simple trend calculation - compare first half to second half
        int midPoint = metrics.size() / 2;
        float firstHalfAvg = 0, secondHalfAvg = 0;
        
        for (int i = 0; i < midPoint; i++) {
            firstHalfAvg += metrics.get(i).getOverallScore();
        }
        firstHalfAvg /= midPoint;
        
        for (int i = midPoint; i < metrics.size(); i++) {
            secondHalfAvg += metrics.get(i).getOverallScore();
        }
        secondHalfAvg /= (metrics.size() - midPoint);
        
        return ((secondHalfAvg - firstHalfAvg) / firstHalfAvg) * 100;
    }
    
    private int calculateCalories(WorkoutSession session) {
        // Rough calculation: 10 calories per minute for moderate intensity
        int baseCalories = session.getDurationMinutes() * 10;
        
        // Adjust based on intensity
        String intensity = session.getIntensity();
        if ("High".equals(intensity)) {
            return (int) (baseCalories * 1.5);
        } else if ("Low".equals(intensity)) {
            return (int) (baseCalories * 0.7);
        }
        
        return baseCalories;
    }
    
    private float calculateFrequency(List<WorkoutSession> sessions, TimePeriod period) {
        if (sessions.isEmpty()) return 0;
        
        long daysCovered = TimeUnit.MILLISECONDS.toDays(
                System.currentTimeMillis() - sessions.get(sessions.size() - 1)
                        .getScheduledDate().getTime());
        
        if (daysCovered == 0) daysCovered = 1;
        
        return (float) sessions.size() / daysCovered * 7; // Sessions per week
    }
    
    private String getMostFrequent(Map<String, Integer> frequency) {
        String mostFrequent = "General Training";
        int maxCount = 0;
        
        for (Map.Entry<String, Integer> entry : frequency.entrySet()) {
            if (entry.getValue() > maxCount) {
                maxCount = entry.getValue();
                mostFrequent = entry.getKey();
            }
        }
        
        return mostFrequent;
    }
    
    private void analyzeTechnique(String userId, TimePeriod period, SkillProgression progression) {
        // Implementation for technique analysis
        progression.techniqueScore = 75; // Mock value
        progression.techniqueImprovement = 12.5f; // Mock improvement percentage
    }
    
    private void analyzeConsistency(String userId, TimePeriod period, SkillProgression progression) {
        // Implementation for consistency analysis
        progression.consistencyScore = 85;
        progression.streakDays = 14;
    }
    
    private void analyzeAccuracy(String userId, TimePeriod period, SkillProgression progression) {
        // Implementation for accuracy analysis
        progression.accuracyScore = 78;
        progression.accuracyTrend = 8.3f;
    }
    
    private void analyzeRestDays(String userId, InjuryPreventionData data) {
        // Implementation for rest day analysis
        data.restDaysPerWeek = 2;
        data.recommendedRestDays = 2;
    }
    
    private void analyzeIntensityPatterns(String userId, InjuryPreventionData data) {
        // Implementation for intensity pattern analysis
        data.highIntensityPercentage = 30;
        data.fatigueLevel = "Moderate";
    }
    
    private void generateInjuryPreventionTips(InjuryPreventionData data) {
        data.recommendations = new ArrayList<>();
        
        if (data.restDaysPerWeek < data.recommendedRestDays) {
            data.recommendations.add("충분한 휴식일을 가지세요. 주 " + 
                    data.recommendedRestDays + "일을 권장합니다.");
        }
        
        if (data.highIntensityPercentage > 40) {
            data.recommendations.add("고강도 운동 비율이 높습니다. 중강도 운동을 늘려보세요.");
        }
        
        data.recommendations.add("운동 전후 충분한 스트레칭을 하세요.");
        data.recommendations.add("수분 섭취를 충분히 하세요.");
    }
    
    // Data models
    public static class AnalyticsData {
        public WorkoutStats workoutStats;
        public PerformanceMetrics performanceMetrics;
        public float performanceTrend;
        public SkillProgression skillProgression;
        public FitnessStats fitnessStats;
        public GoalStats goalStats;
        public ComparisonData comparisonData;
        public InjuryPreventionData injuryPrevention;
    }
    
    public static class WorkoutStats {
        public int totalSessions;
        public int totalMinutes;
        public int currentStreak;
        public int longestStreak;
        public float averageSessionsPerWeek;
    }
    
    public static class PerformanceMetrics {
        public float averageShotAccuracy;
        public float averagePowerRating;
        public float averageSpeedRating;
        public float averageRallyLength;
        public float courtCoveragePercent;
    }
    
    public static class PerformanceMetric {
        public long timestamp;
        public float shotAccuracy;
        public float powerRating;
        public float speedRating;
        
        public float getOverallScore() {
            return (shotAccuracy + powerRating + speedRating) / 3;
        }
    }
    
    public static class SkillProgression {
        public int techniqueScore;
        public float techniqueImprovement;
        public int consistencyScore;
        public int streakDays;
        public int accuracyScore;
        public float accuracyTrend;
    }
    
    public static class FitnessStats {
        public int totalCaloriesBurned;
        public int totalMinutesExercised;
        public int averageSessionDuration;
        public float workoutFrequency;
        public String mostFrequentExercise;
    }
    
    public static class GoalStats {
        public int totalGoals;
        public int completedGoals;
        public int activeGoals;
        public float completionRate;
    }
    
    public static class ComparisonData {
        public float performanceVsPastMonth;
        public float performanceVsAverage;
        public int globalRanking;
        public int friendsRanking;
    }
    
    public static class InjuryPreventionData {
        public int restDaysPerWeek;
        public int recommendedRestDays;
        public int highIntensityPercentage;
        public String fatigueLevel;
        public List<String> recommendations;
    }
    
    public static class WorkoutMetrics {
        public long sessionId;
        public int averageHeartRate;
        public int maxHeartRate;
        public int caloriesBurned;
        public float shotAccuracy;
        public float averageRallyLength;
        public float courtCoveragePercent;
        public int powerRating;
        public int speedRating;
    }
}
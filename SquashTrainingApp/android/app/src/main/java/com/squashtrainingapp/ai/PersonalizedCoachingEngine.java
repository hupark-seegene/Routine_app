package com.squashtrainingapp.ai;

import android.content.Context;
import android.util.Log;

import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.CoachingAdvice;
import com.squashtrainingapp.models.User;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Random;

public class PersonalizedCoachingEngine {
    private static final String TAG = "PersonalizedCoaching";
    
    private Context context;
    private DatabaseHelper dbHelper;
    private User currentUser;
    private SmartRecommendationEngine recommendationEngine;
    
    // Coaching types
    private static final String COACH_MOTIVATIONAL = "motivational";
    private static final String COACH_TECHNICAL = "technical";
    private static final String COACH_STRATEGIC = "strategic";
    private static final String COACH_RECOVERY = "recovery";
    private static final String COACH_GOAL = "goal";
    
    // Performance thresholds
    private static final double EXCELLENT_PERFORMANCE = 0.9;
    private static final double GOOD_PERFORMANCE = 0.7;
    private static final double NEEDS_IMPROVEMENT = 0.5;
    
    public PersonalizedCoachingEngine(Context context) {
        this.context = context;
        this.dbHelper = DatabaseHelper.getInstance(context);
        this.currentUser = dbHelper.getUserDao().getUser();
        this.recommendationEngine = new SmartRecommendationEngine(context);
    }
    
    public List<CoachingAdvice> getPersonalizedAdvice() {
        List<CoachingAdvice> adviceList = new ArrayList<>();
        
        // Analyze current performance
        PerformanceAnalysis analysis = analyzeRecentPerformance();
        
        // Generate advice based on different factors
        adviceList.add(getMotivationalAdvice(analysis));
        adviceList.add(getTechnicalAdvice(analysis));
        adviceList.add(getStrategicAdvice(analysis));
        adviceList.add(getRecoveryAdvice(analysis));
        adviceList.add(getGoalBasedAdvice(analysis));
        
        // Add contextual advice
        adviceList.addAll(getContextualAdvice(analysis));
        
        return adviceList;
    }
    
    public String getInstantFeedback(String exerciseType, boolean completed) {
        double performance = completed ? 0.8 : 0.4;
        Random random = new Random();
        performance += random.nextDouble() * 0.2;
        
        StringBuilder feedback = new StringBuilder();
        
        // Performance-based feedback
        if (performance >= EXCELLENT_PERFORMANCE) {
            feedback.append("훌륭해요! 최고의 퍼포먼스를 보여주셨네요! 💪\n");
            feedback.append("이 페이스를 유지한다면 곧 다음 레벨로 올라갈 수 있을 거예요.");
        } else if (performance >= GOOD_PERFORMANCE) {
            feedback.append("잘하고 있어요! 좋은 진전을 보이고 있습니다. 👍\n");
            feedback.append("조금만 더 집중하면 완벽한 수행이 가능할 거예요.");
        } else {
            feedback.append("수고하셨어요! 모든 훈련이 성장의 기회입니다. 💡\n");
            feedback.append("다음에는 더 나은 결과를 얻을 수 있을 거예요.");
        }
        
        // Type-specific tips
        feedback.append("\n\n");
        feedback.append(getExerciseSpecificTip(exerciseType, performance));
        
        return feedback.toString();
    }
    
    public String getAdaptiveResponse(String userQuery) {
        String query = userQuery.toLowerCase();
        
        // Analyze query intent
        if (query.contains("피곤") || query.contains("힘들")) {
            return getRecoveryFocusedResponse();
        } else if (query.contains("동기") || query.contains("의욕")) {
            return getMotivationalResponse();
        } else if (query.contains("기술") || query.contains("자세")) {
            return getTechnicalResponse();
        } else if (query.contains("목표") || query.contains("계획")) {
            return getGoalOrientedResponse();
        } else if (query.contains("분석") || query.contains("통계")) {
            return getAnalyticalResponse();
        } else {
            return getGeneralCoachingResponse();
        }
    }
    
    private PerformanceAnalysis analyzeRecentPerformance() {
        PerformanceAnalysis analysis = new PerformanceAnalysis();
        
        // Simplified analysis without database access
        // In real implementation, would fetch actual session data
        
        analysis.totalSessions = Math.min(7, currentUser.getTotalSessions());
        analysis.currentStreak = currentUser.getCurrentStreak();
        analysis.userLevel = currentUser.getLevel();
        
        // Mock performance metrics
        Random random = new Random();
        analysis.averagePerformance = 0.6 + (random.nextDouble() * 0.3);
        analysis.completionRate = 0.7 + (random.nextDouble() * 0.2);
        
        // Check consistency
        analysis.isConsistent = analysis.totalSessions >= 5;
        
        // Mock improvement trend
        analysis.isImproving = random.nextBoolean();
        
        return analysis;
    }
    
    private CoachingAdvice getMotivationalAdvice(PerformanceAnalysis analysis) {
        CoachingAdvice advice = new CoachingAdvice();
        advice.setType(COACH_MOTIVATIONAL);
        advice.setPriority(1);
        
        if (analysis.currentStreak >= 7) {
            advice.setTitle("연속 운동 1주일 달성! 🔥");
            advice.setMessage("대단해요! " + analysis.currentStreak + "일 연속으로 운동하고 계시네요. "
                + "이 기세를 계속 유지해보세요!");
            advice.setActionable("오늘도 짧게라도 운동하여 스트릭을 이어가세요");
        } else if (analysis.currentStreak == 0) {
            advice.setTitle("다시 시작할 시간! 💪");
            advice.setMessage("오늘부터 새로운 시작입니다. 작은 목표부터 차근차근 달성해보세요.");
            advice.setActionable("오늘 10분이라도 운동을 시작해보세요");
        } else {
            advice.setTitle("잘 하고 있어요! 👍");
            advice.setMessage(analysis.currentStreak + "일째 운동 중! 꾸준함이 실력을 만듭니다.");
            advice.setActionable("목표를 향해 한 걸음 더 나아가세요");
        }
        
        return advice;
    }
    
    private CoachingAdvice getTechnicalAdvice(PerformanceAnalysis analysis) {
        CoachingAdvice advice = new CoachingAdvice();
        advice.setType(COACH_TECHNICAL);
        advice.setPriority(2);
        
        // Level-based technical advice
        if (analysis.userLevel < 5) {
            advice.setTitle("기본기 다지기 📚");
            advice.setMessage("현재 레벨에서는 기본 스트로크의 정확성에 집중하는 것이 중요합니다.");
            advice.setActionable("포핸드와 백핸드 스트로크를 각각 50회씩 연습해보세요");
        } else if (analysis.userLevel < 10) {
            advice.setTitle("전술적 플레이 향상 🎯");
            advice.setMessage("이제 다양한 샷과 코트 포지셔닝을 연습할 시기입니다.");
            advice.setActionable("드롭샷과 로브샷을 번갈아가며 연습해보세요");
        } else {
            advice.setTitle("고급 기술 마스터 🏆");
            advice.setMessage("디셉션과 파워 컨트롤을 통해 상대를 압도하세요.");
            advice.setActionable("같은 자세에서 다른 샷을 구사하는 연습을 해보세요");
        }
        
        return advice;
    }
    
    private CoachingAdvice getStrategicAdvice(PerformanceAnalysis analysis) {
        CoachingAdvice advice = new CoachingAdvice();
        advice.setType(COACH_STRATEGIC);
        advice.setPriority(3);
        
        if (analysis.averagePerformance < NEEDS_IMPROVEMENT) {
            advice.setTitle("훈련 강도 조절 필요 ⚖️");
            advice.setMessage("현재 훈련이 너무 어려울 수 있습니다. 난이도를 조금 낮춰보세요.");
            advice.setActionable("다음 운동은 현재보다 한 단계 낮은 난이도로 시도해보세요");
        } else if (analysis.averagePerformance > EXCELLENT_PERFORMANCE) {
            advice.setTitle("도전 레벨 상승 시기 📈");
            advice.setMessage("현재 레벨을 충분히 마스터하셨습니다. 더 높은 도전이 필요해요!");
            advice.setActionable("다음 레벨의 운동 프로그램을 시작해보세요");
        } else {
            advice.setTitle("균형잡힌 발전 중 ⚡");
            advice.setMessage("적절한 난이도로 꾸준히 발전하고 있습니다.");
            advice.setActionable("약한 부분을 집중적으로 보완해보세요");
        }
        
        return advice;
    }
    
    private CoachingAdvice getRecoveryAdvice(PerformanceAnalysis analysis) {
        CoachingAdvice advice = new CoachingAdvice();
        advice.setType(COACH_RECOVERY);
        advice.setPriority(4);
        
        if (analysis.totalSessions >= 6) {
            advice.setTitle("휴식이 필요한 시기 🌙");
            advice.setMessage("이번 주에 많은 운동을 하셨네요. 적절한 휴식도 중요합니다.");
            advice.setActionable("내일은 가벼운 스트레칭이나 요가로 대체해보세요");
        } else {
            advice.setTitle("충분한 회복 시간 ✨");
            advice.setMessage("운동과 휴식의 균형이 잘 맞춰져 있습니다.");
            advice.setActionable("운동 후 충분한 수분 섭취를 잊지 마세요");
        }
        
        return advice;
    }
    
    private CoachingAdvice getGoalBasedAdvice(PerformanceAnalysis analysis) {
        CoachingAdvice advice = new CoachingAdvice();
        advice.setType(COACH_GOAL);
        advice.setPriority(5);
        
        // Calculate progress to next level
        int sessionsToNextLevel = (analysis.userLevel + 1) * 10 - currentUser.getTotalSessions();
        
        if (sessionsToNextLevel <= 5) {
            advice.setTitle("레벨업이 코앞! 🎉");
            advice.setMessage("다음 레벨까지 " + sessionsToNextLevel + "개의 세션만 더 완료하면 됩니다!");
            advice.setActionable("이번 주 안에 레벨업을 달성해보세요");
        } else {
            advice.setTitle("꾸준한 성장 중 📊");
            advice.setMessage("현재 페이스로는 " + (sessionsToNextLevel / 5) + "주 후에 레벨업이 예상됩니다.");
            advice.setActionable("주 5회 운동을 목표로 해보세요");
        }
        
        return advice;
    }
    
    private List<CoachingAdvice> getContextualAdvice(PerformanceAnalysis analysis) {
        List<CoachingAdvice> contextualAdvice = new ArrayList<>();
        
        Calendar cal = Calendar.getInstance();
        int hour = cal.get(Calendar.HOUR_OF_DAY);
        int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
        
        // Time-based advice
        if (hour < 6) {
            CoachingAdvice earlyAdvice = new CoachingAdvice();
            earlyAdvice.setType(COACH_MOTIVATIONAL);
            earlyAdvice.setTitle("새벽 운동의 힘! 🌅");
            earlyAdvice.setMessage("이른 시간에 운동하시는군요! 하루를 활기차게 시작하세요.");
            earlyAdvice.setActionable("운동 전 충분한 워밍업을 잊지 마세요");
            earlyAdvice.setPriority(10);
            contextualAdvice.add(earlyAdvice);
        }
        
        // Weekend advice
        if (dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY) {
            CoachingAdvice weekendAdvice = new CoachingAdvice();
            weekendAdvice.setType(COACH_STRATEGIC);
            weekendAdvice.setTitle("주말 특별 훈련 🏃‍♂️");
            weekendAdvice.setMessage("주말은 새로운 기술을 익히기 좋은 시간입니다.");
            weekendAdvice.setActionable("평소보다 긴 세션으로 깊이 있는 연습을 해보세요");
            weekendAdvice.setPriority(11);
            contextualAdvice.add(weekendAdvice);
        }
        
        return contextualAdvice;
    }
    
    private double calculateSessionPerformance(boolean completed, int difficulty) {
        // Simple performance calculation
        double baseScore = completed ? 0.7 : 0.3;
        
        // Add bonus for difficulty
        if (difficulty > currentUser.getLevel()) {
            baseScore += 0.2;
        }
        
        return Math.min(1.0, baseScore);
    }
    
    private boolean checkImprovementTrend() {
        // Simplified trend check
        Random random = new Random();
        return currentUser.getCurrentStreak() > 3 || random.nextBoolean();
    }
    
    private String getExerciseSpecificTip(String type, double performance) {
        switch (type) {
            case "cardio":
                return performance >= GOOD_PERFORMANCE ? 
                    "💡 팁: 호흡 리듬을 일정하게 유지하면 더 오래 운동할 수 있어요." :
                    "💡 팁: 처음엔 짧은 인터벌로 시작해서 점진적으로 늘려보세요.";
                    
            case "strength":
                return performance >= GOOD_PERFORMANCE ?
                    "💡 팁: 동작의 속도를 조절하여 근육에 더 많은 자극을 주세요." :
                    "💡 팁: 올바른 자세가 부상 예방과 효과 향상의 핵심입니다.";
                    
            case "technique":
                return performance >= GOOD_PERFORMANCE ?
                    "💡 팁: 일관성 있는 스트로크를 위해 그립을 점검해보세요." :
                    "💡 팁: 거울을 보며 동작을 확인하면 빠른 교정이 가능해요.";
                    
            default:
                return "💡 팁: 꾸준한 연습이 실력 향상의 지름길입니다.";
        }
    }
    
    // Response generation methods
    private String getRecoveryFocusedResponse() {
        return "피곤하신가요? 충분한 휴식도 훈련의 일부입니다. " +
               "오늘은 가벼운 스트레칭이나 요가로 몸을 풀어주는 것은 어떨까요? " +
               "내일 더 좋은 컨디션으로 운동할 수 있을 거예요. 💪";
    }
    
    private String getMotivationalResponse() {
        String[] motivations = {
            "당신은 이미 시작했다는 것만으로도 대단해요! 매일 조금씩 나아지고 있습니다. 🌟",
            "챔피언도 처음엔 초보자였습니다. 당신의 여정을 믿고 계속 나아가세요! 🏆",
            "오늘의 작은 노력이 내일의 큰 성과를 만듭니다. 화이팅! 💪"
        };
        return motivations[new Random().nextInt(motivations.length)];
    }
    
    private String getTechnicalResponse() {
        return "기술 향상을 원하시는군요! 현재 레벨에서는 " +
               (currentUser.getLevel() < 5 ? "기본 스트로크의 정확성" : "고급 기술과 전술") +
               "에 집중하는 것이 좋습니다. 구체적으로 어떤 기술을 연습하고 싶으신가요?";
    }
    
    private String getGoalOrientedResponse() {
        return "목표 설정은 성공의 첫걸음입니다! 현재 레벨 " + currentUser.getLevel() + 
               "에서 다음 목표는 레벨 " + (currentUser.getLevel() + 1) + " 달성입니다. " +
               "이를 위해 주 5회, 각 30분 이상의 운동을 추천드립니다. 📈";
    }
    
    private String getAnalyticalResponse() {
        PerformanceAnalysis analysis = analyzeRecentPerformance();
        return "최근 7일간 통계: 총 " + analysis.totalSessions + "회 운동, " +
               "평균 성과 " + Math.round(analysis.averagePerformance * 100) + "%, " +
               "완료율 " + Math.round(analysis.completionRate * 100) + "%. " +
               (analysis.isImproving ? "훌륭한 향상세를 보이고 있어요! 📊" : "꾸준히 노력하면 곧 향상될 거예요! 💪");
    }
    
    private String getGeneralCoachingResponse() {
        return "안녕하세요! 오늘은 어떤 도움이 필요하신가요? " +
               "운동 추천, 기술 조언, 동기 부여 등 무엇이든 물어보세요. " +
               "당신의 스쿼시 여정을 함께하겠습니다! 🏸";
    }
    
    // Inner classes
    private static class PerformanceAnalysis {
        int totalSessions;
        int currentStreak;
        int userLevel;
        double averagePerformance;
        double completionRate;
        boolean isConsistent;
        boolean isImproving;
    }
}
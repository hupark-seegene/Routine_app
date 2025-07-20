package com.squashtrainingapp.ai;

import android.content.Context;
import android.util.Log;

import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.CoachingAdvice;
import com.squashtrainingapp.models.User;
import com.squashtrainingapp.models.WorkoutRecommendation;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

public class AdvancedAIResponseEngine {
    private static final String TAG = "AdvancedAIResponse";
    
    private Context context;
    private PersonalizedCoachingEngine coachingEngine;
    private SmartRecommendationEngine recommendationEngine;
    private ConversationContext conversationContext;
    private DatabaseHelper dbHelper;
    private User currentUser;
    
    // Conversation states
    private static final String STATE_GREETING = "greeting";
    private static final String STATE_GOAL_SETTING = "goal_setting";
    private static final String STATE_WORKOUT_PLANNING = "workout_planning";
    private static final String STATE_TECHNIQUE_DISCUSSION = "technique_discussion";
    private static final String STATE_PROGRESS_REVIEW = "progress_review";
    private static final String STATE_GENERAL = "general";
    
    // Intent patterns (Korean and English)
    private static final Map<String, Pattern[]> INTENT_PATTERNS = new HashMap<>();
    
    static {
        // Greeting patterns
        INTENT_PATTERNS.put("greeting", new Pattern[]{
            Pattern.compile("(안녕|하이|반가|hello|hi|hey)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(좋은\\s*(아침|오후|저녁)|good\\s*(morning|afternoon|evening))", Pattern.CASE_INSENSITIVE)
        });
        
        // Goal-related patterns
        INTENT_PATTERNS.put("goal", new Pattern[]{
            Pattern.compile("(목표|계획|달성|레벨|goal|plan|achieve|level)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(언제.*될|how.*long|when.*reach)", Pattern.CASE_INSENSITIVE)
        });
        
        // Workout request patterns
        INTENT_PATTERNS.put("workout", new Pattern[]{
            Pattern.compile("(운동|훈련|연습|추천|workout|training|practice|recommend)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(오늘.*뭐.*해|what.*today|suggest.*exercise)", Pattern.CASE_INSENSITIVE)
        });
        
        // Technique patterns
        INTENT_PATTERNS.put("technique", new Pattern[]{
            Pattern.compile("(기술|자세|폼|스트로크|technique|form|stroke)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(어떻게|개선|향상|how\\s*to|improve|better)", Pattern.CASE_INSENSITIVE)
        });
        
        // Progress patterns
        INTENT_PATTERNS.put("progress", new Pattern[]{
            Pattern.compile("(진전|향상|발전|통계|분석|progress|improvement|stats|analysis)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(얼마나.*잘|how.*doing|performance)", Pattern.CASE_INSENSITIVE)
        });
        
        // Fatigue/Recovery patterns
        INTENT_PATTERNS.put("fatigue", new Pattern[]{
            Pattern.compile("(피곤|힘들|쉬고|회복|tired|hard|rest|recover)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(너무.*많이|too\\s*much|exhausted)", Pattern.CASE_INSENSITIVE)
        });
        
        // Motivation patterns
        INTENT_PATTERNS.put("motivation", new Pattern[]{
            Pattern.compile("(동기|의욕|힘내|motivat|inspir|encourage)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(포기|그만|quit|give\\s*up)", Pattern.CASE_INSENSITIVE)
        });
    }
    
    public AdvancedAIResponseEngine(Context context) {
        this.context = context;
        this.coachingEngine = new PersonalizedCoachingEngine(context);
        this.recommendationEngine = new SmartRecommendationEngine(context);
        this.conversationContext = new ConversationContext();
        this.dbHelper = DatabaseHelper.getInstance(context);
        this.currentUser = dbHelper.getUserDao().getUser();
    }
    
    public String generateContextualResponse(String userInput) {
        // Detect intent
        String intent = detectIntent(userInput);
        
        // Update conversation context
        conversationContext.addUserMessage(userInput);
        conversationContext.setLastIntent(intent);
        
        // Generate response based on intent and context
        String response;
        switch (intent) {
            case "greeting":
                response = handleGreeting();
                break;
            case "goal":
                response = handleGoalDiscussion();
                break;
            case "workout":
                response = handleWorkoutRequest();
                break;
            case "technique":
                response = handleTechniqueQuestion(userInput);
                break;
            case "progress":
                response = handleProgressInquiry();
                break;
            case "fatigue":
                response = handleFatigueExpression();
                break;
            case "motivation":
                response = handleMotivationRequest();
                break;
            default:
                response = handleGeneralQuery(userInput);
        }
        
        // Add response to context
        conversationContext.addAIResponse(response);
        
        return response;
    }
    
    private String detectIntent(String input) {
        for (Map.Entry<String, Pattern[]> entry : INTENT_PATTERNS.entrySet()) {
            for (Pattern pattern : entry.getValue()) {
                if (pattern.matcher(input).find()) {
                    return entry.getKey();
                }
            }
        }
        return "general";
    }
    
    private String handleGreeting() {
        conversationContext.setState(STATE_GREETING);
        
        // Get personalized greeting based on time and user stats
        StringBuilder greeting = new StringBuilder();
        
        int hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY);
        if (hour < 12) {
            greeting.append("좋은 아침이에요! ");
        } else if (hour < 18) {
            greeting.append("좋은 오후예요! ");
        } else {
            greeting.append("좋은 저녁이에요! ");
        }
        
        // Add personalized touch
        if (currentUser.getCurrentStreak() > 0) {
            greeting.append(currentUser.getName()).append("님, ")
                   .append(currentUser.getCurrentStreak()).append("일 연속 운동 중이시네요! 👏\n\n");
        } else {
            greeting.append(currentUser.getName()).append("님, 다시 만나서 반가워요!\n\n");
        }
        
        // Add coaching advice
        List<CoachingAdvice> adviceList = coachingEngine.getPersonalizedAdvice();
        if (!adviceList.isEmpty()) {
            CoachingAdvice topAdvice = adviceList.get(0);
            greeting.append(topAdvice.getMessage());
        }
        
        return greeting.toString();
    }
    
    private String handleGoalDiscussion() {
        conversationContext.setState(STATE_GOAL_SETTING);
        
        StringBuilder response = new StringBuilder();
        
        // Calculate progress to next level
        int currentLevel = currentUser.getLevel();
        int totalSessions = currentUser.getTotalSessions();
        int sessionsForNextLevel = (currentLevel + 1) * 10;
        int sessionsNeeded = sessionsForNextLevel - totalSessions;
        
        response.append("현재 레벨 ").append(currentLevel).append("에서 ")
               .append("레벨 ").append(currentLevel + 1).append("까지 ")
               .append(sessionsNeeded).append("개의 세션이 필요해요.\n\n");
        
        // Add time estimate
        double avgSessionsPerWeek = calculateAverageSessionsPerWeek();
        if (avgSessionsPerWeek > 0) {
            int weeksNeeded = (int) Math.ceil(sessionsNeeded / avgSessionsPerWeek);
            response.append("현재 페이스(주 ").append(String.format("%.1f", avgSessionsPerWeek))
                   .append("회)로는 약 ").append(weeksNeeded).append("주 후에 달성 가능합니다.\n\n");
        }
        
        // Add goal recommendation
        response.append("💡 추천: 주 5회 운동을 목표로 하면 ")
               .append((int) Math.ceil(sessionsNeeded / 5.0)).append("주 만에 레벨업할 수 있어요!");
        
        return response.toString();
    }
    
    private String handleWorkoutRequest() {
        conversationContext.setState(STATE_WORKOUT_PLANNING);
        
        // Get personalized recommendations
        List<WorkoutRecommendation> recommendations = recommendationEngine.getPersonalizedRecommendations();
        
        if (recommendations.isEmpty()) {
            return "죄송해요, 현재 추천할 운동을 찾을 수 없습니다. 잠시 후 다시 시도해주세요.";
        }
        
        StringBuilder response = new StringBuilder();
        response.append("오늘의 맞춤 운동을 추천해드릴게요:\n\n");
        
        // Show top 3 recommendations
        int count = Math.min(3, recommendations.size());
        for (int i = 0; i < count; i++) {
            WorkoutRecommendation rec = recommendations.get(i);
            response.append(i + 1).append(". ").append(rec.getTypeIcon()).append(" ")
                   .append(rec.getTitle()).append("\n")
                   .append("   - ").append(rec.getDescription()).append("\n")
                   .append("   - 난이도: ").append(rec.getDifficultyText())
                   .append(", 시간: ").append(rec.getDurationText()).append("\n\n");
        }
        
        response.append("어떤 운동을 선택하시겠어요? 번호로 답해주세요!");
        
        return response.toString();
    }
    
    private String handleTechniqueQuestion(String input) {
        conversationContext.setState(STATE_TECHNIQUE_DISCUSSION);
        
        // Extract specific technique mentioned
        String technique = extractTechnique(input);
        
        StringBuilder response = new StringBuilder();
        
        if (technique != null) {
            response.append(getTechniqueAdvice(technique));
        } else {
            // General technique advice based on level
            response.append("현재 레벨 ").append(currentUser.getLevel())
                   .append("에서 중요한 기술 포인트:\n\n");
            
            if (currentUser.getLevel() < 5) {
                response.append("🎯 기본기 마스터:\n")
                       .append("1. 그립: 콘티넨탈 그립으로 일관성 유지\n")
                       .append("2. 스탠스: 어깨 너비로 안정적인 자세\n")
                       .append("3. 스윙: 컴팩트하고 부드러운 동작\n")
                       .append("4. 팔로우스루: 목표 방향으로 완전히 마무리");
            } else {
                response.append("🎯 고급 기술:\n")
                       .append("1. 디셉션: 같은 준비 동작에서 다양한 샷\n")
                       .append("2. 코트 커버리지: T존 중심의 효율적 움직임\n")
                       .append("3. 샷 선택: 상황에 맞는 전술적 판단\n")
                       .append("4. 압박 플레이: 상대에게 시간적 압박 가하기");
            }
        }
        
        return response.toString();
    }
    
    private String handleProgressInquiry() {
        conversationContext.setState(STATE_PROGRESS_REVIEW);
        
        // Get adaptive response from coaching engine
        return coachingEngine.getAdaptiveResponse("분석해줘");
    }
    
    private String handleFatigueExpression() {
        // Get recovery advice
        return coachingEngine.getAdaptiveResponse("피곤해");
    }
    
    private String handleMotivationRequest() {
        // Get motivational response
        return coachingEngine.getAdaptiveResponse("동기부여");
    }
    
    private String handleGeneralQuery(String input) {
        conversationContext.setState(STATE_GENERAL);
        
        // Use coaching engine for general queries
        return coachingEngine.getAdaptiveResponse(input);
    }
    
    private String extractTechnique(String input) {
        String lowerInput = input.toLowerCase();
        
        if (lowerInput.contains("백핸드") || lowerInput.contains("backhand")) {
            return "backhand";
        } else if (lowerInput.contains("포핸드") || lowerInput.contains("forehand")) {
            return "forehand";
        } else if (lowerInput.contains("서브") || lowerInput.contains("serve")) {
            return "serve";
        } else if (lowerInput.contains("드롭") || lowerInput.contains("drop")) {
            return "drop";
        } else if (lowerInput.contains("발리") || lowerInput.contains("volley")) {
            return "volley";
        }
        
        return null;
    }
    
    private String getTechniqueAdvice(String technique) {
        switch (technique) {
            case "backhand":
                return "백핸드 개선 포인트:\n\n" +
                       "1. 준비 자세: 어깨를 충분히 돌려 라켓을 뒤로\n" +
                       "2. 그립: 백핸드 그립으로 변경 (V자가 왼쪽으로)\n" +
                       "3. 스윙: 팔꿈치를 먼저 이끌고 손목은 고정\n" +
                       "4. 타점: 앞발 옆에서 임팩트\n" +
                       "5. 팔로우스루: 높게 마무리하여 깊이 조절\n\n" +
                       "💡 연습법: 벽에 대고 백핸드만 100회 반복하세요!";
                       
            case "serve":
                return "서브 마스터하기:\n\n" +
                       "1. 스탠스: 한 발을 서비스 박스 안에\n" +
                       "2. 토스: 일정한 높이 (라켓 최고점)\n" +
                       "3. 타격: 공의 뒤쪽을 때려 스핀 생성\n" +
                       "4. 목표: 상대 백핸드 쪽 깊은 코너\n" +
                       "5. 변화: 하드/소프트 서브 번갈아 사용\n\n" +
                       "💡 연습법: 각 코너에 20개씩, 총 80개 서브 연습!";
                       
            default:
                return "기술 향상을 위한 일반적인 조언입니다. 구체적인 기술명을 말씀해주시면 더 자세히 설명드릴게요!";
        }
    }
    
    private double calculateAverageSessionsPerWeek() {
        // Simple calculation - in real implementation would analyze actual data
        return 3.5; // Placeholder
    }
    
    // Inner class for maintaining conversation context
    private static class ConversationContext {
        private List<String> userMessages = new ArrayList<>();
        private List<String> aiResponses = new ArrayList<>();
        private String currentState = STATE_GENERAL;
        private String lastIntent = "";
        private long lastInteractionTime = System.currentTimeMillis();
        
        void addUserMessage(String message) {
            userMessages.add(message);
            if (userMessages.size() > 10) {
                userMessages.remove(0);
            }
            lastInteractionTime = System.currentTimeMillis();
        }
        
        void addAIResponse(String response) {
            aiResponses.add(response);
            if (aiResponses.size() > 10) {
                aiResponses.remove(0);
            }
        }
        
        void setState(String state) {
            this.currentState = state;
        }
        
        void setLastIntent(String intent) {
            this.lastIntent = intent;
        }
        
        boolean isNewConversation() {
            return System.currentTimeMillis() - lastInteractionTime > 300000; // 5 minutes
        }
    }
}
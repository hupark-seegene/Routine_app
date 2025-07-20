package com.squashtrainingapp.ai;

import android.content.Context;
import com.squashtrainingapp.R;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ExtendedVoiceCommands {
    private static final String TAG = "ExtendedVoiceCommands";
    
    public enum CommandType {
        // Navigation
        NAVIGATE_PROFILE,
        NAVIGATE_CHECKLIST,
        NAVIGATE_RECORD,
        NAVIGATE_HISTORY,
        NAVIGATE_COACH,
        NAVIGATE_SETTINGS,
        NAVIGATE_HOME,
        
        // Actions
        SHOW_PROGRESS,
        START_WORKOUT,
        STOP_WORKOUT,
        PAUSE_WORKOUT,
        GET_ADVICE,
        SET_TIMER,
        
        // Queries
        QUERY_TECHNIQUE,
        QUERY_EXERCISE,
        QUERY_STATS,
        QUERY_SCHEDULE,
        QUERY_LEVEL,
        
        // Specific exercises
        EXERCISE_CARDIO,
        EXERCISE_STRENGTH,
        EXERCISE_TECHNIQUE,
        EXERCISE_FOOTWORK,
        
        // Coaching
        COACHING_MOTIVATION,
        COACHING_RECOVERY,
        COACHING_STRATEGY,
        COACHING_MENTAL,
        
        // System
        HELP,
        CANCEL,
        CONFIRM,
        UNKNOWN
    }
    
    public static class Command {
        public CommandType type;
        public String parameters;
        public Map<String, String> extras;
        public float confidence;
        
        public Command(CommandType type, String parameters) {
            this.type = type;
            this.parameters = parameters;
            this.extras = new HashMap<>();
            this.confidence = 1.0f;
        }
    }
    
    private static final List<CommandPattern> commandPatterns = new ArrayList<>();
    
    static {
        // Navigation - Korean enhanced patterns
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(프로필|내\\s*정보|내\\s*프로필|마이\\s*페이지|나의\\s*정보).*", Pattern.CASE_INSENSITIVE),
            CommandType.NAVIGATE_PROFILE
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(체크\\s*리스트|운동\\s*목록|오늘\\s*운동|할\\s*일|체크\\s*리스트).*", Pattern.CASE_INSENSITIVE),
            CommandType.NAVIGATE_CHECKLIST
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(기록|운동\\s*시작|새\\s*운동|운동하기|운동\\s*기록|시작하자|운동\\s*하자).*", Pattern.CASE_INSENSITIVE),
            CommandType.NAVIGATE_RECORD
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(히스토리|기록\\s*보기|이력|과거\\s*기록|지난\\s*운동|운동\\s*기록).*", Pattern.CASE_INSENSITIVE),
            CommandType.NAVIGATE_HISTORY
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(코치|코칭|조언|팁|도움|가르쳐|알려줘|어떻게).*", Pattern.CASE_INSENSITIVE),
            CommandType.NAVIGATE_COACH
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(설정|환경\\s*설정|세팅|옵션|설정\\s*변경).*", Pattern.CASE_INSENSITIVE),
            CommandType.NAVIGATE_SETTINGS
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(홈|메인|처음|홈\\s*화면|메인\\s*화면).*", Pattern.CASE_INSENSITIVE),
            CommandType.NAVIGATE_HOME
        ));
        
        // Actions - Korean
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(진행|진척|통계|상태|현황|얼마나|어느\\s*정도).*", Pattern.CASE_INSENSITIVE),
            CommandType.SHOW_PROGRESS
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(운동.*시작|트레이닝.*시작|연습.*시작|시작해|운동하자|훈련\\s*시작).*", Pattern.CASE_INSENSITIVE),
            CommandType.START_WORKOUT
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(운동.*중지|그만|멈춰|정지|스톱|운동.*끝).*", Pattern.CASE_INSENSITIVE),
            CommandType.STOP_WORKOUT
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(잠시|일시.*정지|잠깐|pause|일시.*중지).*", Pattern.CASE_INSENSITIVE),
            CommandType.PAUSE_WORKOUT
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(타이머|시간.*설정|알람|시간.*맞춰).*", Pattern.CASE_INSENSITIVE),
            CommandType.SET_TIMER
        ));
        
        // Queries - Korean
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(기술|자세|폼|스트로크|어떻게.*치|백핸드|포핸드|서브).*", Pattern.CASE_INSENSITIVE),
            CommandType.QUERY_TECHNIQUE
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(운동.*추천|뭐.*할까|어떤.*운동|운동.*뭐|추천.*운동).*", Pattern.CASE_INSENSITIVE),
            CommandType.QUERY_EXERCISE
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(통계|분석|성과|실적|기록.*보여|데이터).*", Pattern.CASE_INSENSITIVE),
            CommandType.QUERY_STATS
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(일정|스케줄|언제|날짜|예약|계획).*", Pattern.CASE_INSENSITIVE),
            CommandType.QUERY_SCHEDULE
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(레벨|수준|실력|몇.*레벨|레벨.*몇).*", Pattern.CASE_INSENSITIVE),
            CommandType.QUERY_LEVEL
        ));
        
        // Specific exercise types - Korean
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(유산소|카디오|달리기|스프린트|체력|심폐).*", Pattern.CASE_INSENSITIVE),
            CommandType.EXERCISE_CARDIO
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(근력|근육|파워|힘|웨이트|무게).*", Pattern.CASE_INSENSITIVE),
            CommandType.EXERCISE_STRENGTH
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(기술.*운동|기술.*연습|스킬|드릴|기본기).*", Pattern.CASE_INSENSITIVE),
            CommandType.EXERCISE_TECHNIQUE
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(발놀림|풋워크|스텝|발.*움직임|민첩성).*", Pattern.CASE_INSENSITIVE),
            CommandType.EXERCISE_FOOTWORK
        ));
        
        // Coaching types - Korean
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(동기|의욕|힘내|화이팅|격려|응원|할.*수.*있).*", Pattern.CASE_INSENSITIVE),
            CommandType.COACHING_MOTIVATION
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(피곤|힘들|쉬고|회복|휴식|지쳤|피로).*", Pattern.CASE_INSENSITIVE),
            CommandType.COACHING_RECOVERY
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(전략|전술|작전|방법|계획|이기는).*", Pattern.CASE_INSENSITIVE),
            CommandType.COACHING_STRATEGY
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(정신|멘탈|집중|긴장|압박|스트레스).*", Pattern.CASE_INSENSITIVE),
            CommandType.COACHING_MENTAL
        ));
        
        // System commands - Korean
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(도움|도와|명령어|사용법|어떻게|뭐.*할.*수).*", Pattern.CASE_INSENSITIVE),
            CommandType.HELP
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(취소|아니|안.*해|그만|됐어).*", Pattern.CASE_INSENSITIVE),
            CommandType.CANCEL
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*(네|예|좋아|맞아|확인|오케이|ㅇㅋ).*", Pattern.CASE_INSENSITIVE),
            CommandType.CONFIRM
        ));
        
        // English patterns (basic support)
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*\\b(profile|my\\s*info)\\b.*", Pattern.CASE_INSENSITIVE),
            CommandType.NAVIGATE_PROFILE
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*\\b(checklist|exercises?|tasks?)\\b.*", Pattern.CASE_INSENSITIVE),
            CommandType.NAVIGATE_CHECKLIST
        ));
        
        commandPatterns.add(new CommandPattern(
            Pattern.compile(".*\\b(start|begin|new)\\s*(workout|exercise|training)\\b.*", Pattern.CASE_INSENSITIVE),
            CommandType.START_WORKOUT
        ));
    }
    
    // Pattern class for better organization
    private static class CommandPattern {
        Pattern pattern;
        CommandType type;
        
        CommandPattern(Pattern pattern, CommandType type) {
            this.pattern = pattern;
            this.type = type;
        }
    }
    
    public static Command parseCommand(String voiceInput) {
        if (voiceInput == null || voiceInput.trim().isEmpty()) {
            return new Command(CommandType.UNKNOWN, null);
        }
        
        String normalizedInput = voiceInput.trim();
        
        // Check all patterns
        for (CommandPattern cp : commandPatterns) {
            Matcher matcher = cp.pattern.matcher(normalizedInput);
            if (matcher.find()) {
                Command cmd = new Command(cp.type, voiceInput);
                
                // Extract additional parameters based on command type
                extractParameters(cmd, normalizedInput);
                
                return cmd;
            }
        }
        
        return new Command(CommandType.UNKNOWN, voiceInput);
    }
    
    private static void extractParameters(Command cmd, String input) {
        // Extract numbers for timer
        if (cmd.type == CommandType.SET_TIMER) {
            Pattern numberPattern = Pattern.compile("(\\d+)\\s*(분|초|시간)?");
            Matcher matcher = numberPattern.matcher(input);
            if (matcher.find()) {
                String duration = matcher.group(1);
                String unit = matcher.group(2) != null ? matcher.group(2) : "분";
                cmd.extras.put("duration", duration);
                cmd.extras.put("unit", unit);
            }
        }
        
        // Extract exercise specifics
        if (input.contains("백핸드") || input.contains("backhand")) {
            cmd.extras.put("technique", "backhand");
        } else if (input.contains("포핸드") || input.contains("forehand")) {
            cmd.extras.put("technique", "forehand");
        } else if (input.contains("서브") || input.contains("serve")) {
            cmd.extras.put("technique", "serve");
        }
        
        // Extract intensity levels
        if (input.contains("쉬운") || input.contains("초급") || input.contains("easy")) {
            cmd.extras.put("difficulty", "easy");
        } else if (input.contains("어려운") || input.contains("고급") || input.contains("hard")) {
            cmd.extras.put("difficulty", "hard");
        }
    }
    
    public static String getResponseForCommand(Context context, Command command) {
        // Generate contextual responses based on command type and parameters
        switch (command.type) {
            case NAVIGATE_PROFILE:
                return "프로필을 열고 있습니다...";
                
            case START_WORKOUT:
                if (command.extras.containsKey("difficulty")) {
                    String difficulty = command.extras.get("difficulty");
                    if ("easy".equals(difficulty)) {
                        return "쉬운 난이도로 운동을 시작합니다!";
                    } else if ("hard".equals(difficulty)) {
                        return "고급 난이도로 운동을 시작합니다! 화이팅!";
                    }
                }
                return "운동을 시작합니다! 오늘도 화이팅!";
                
            case SET_TIMER:
                if (command.extras.containsKey("duration")) {
                    String duration = command.extras.get("duration");
                    String unit = command.extras.get("unit");
                    return duration + unit + " 타이머를 설정했습니다.";
                }
                return "타이머를 설정합니다.";
                
            case QUERY_TECHNIQUE:
                if (command.extras.containsKey("technique")) {
                    String technique = command.extras.get("technique");
                    return technique + " 기술에 대해 설명해드리겠습니다.";
                }
                return "어떤 기술에 대해 알고 싶으신가요?";
                
            case COACHING_MOTIVATION:
                return "할 수 있어요! 당신의 노력이 곧 실력이 됩니다! 💪";
                
            case COACHING_RECOVERY:
                return "충분한 휴식도 훈련의 일부입니다. 오늘은 가볍게 스트레칭을 해보세요.";
                
            case HELP:
                return "다음과 같이 말씀해주세요:\n" +
                       "• '프로필 보여줘'\n" +
                       "• '운동 시작하자'\n" +
                       "• '오늘 뭐 할까?'\n" +
                       "• '백핸드 어떻게 치지?'\n" +
                       "• '5분 타이머 설정해줘'";
                
            default:
                return "명령을 처리하고 있습니다...";
        }
    }
    
    public static List<String> getSuggestions(CommandType lastCommand) {
        List<String> suggestions = new ArrayList<>();
        
        switch (lastCommand) {
            case NAVIGATE_PROFILE:
                suggestions.add("통계 보여줘");
                suggestions.add("레벨 확인해줘");
                suggestions.add("진행 상황 어때?");
                break;
                
            case START_WORKOUT:
                suggestions.add("타이머 5분 설정");
                suggestions.add("쉬운 운동으로 해줘");
                suggestions.add("유산소 운동 추천해줘");
                break;
                
            case NAVIGATE_COACH:
                suggestions.add("백핸드 팁 알려줘");
                suggestions.add("동기부여 해줘");
                suggestions.add("전략 조언해줘");
                break;
                
            default:
                suggestions.add("운동 시작하자");
                suggestions.add("오늘 뭐 할까?");
                suggestions.add("내 정보 보여줘");
        }
        
        return suggestions;
    }
}
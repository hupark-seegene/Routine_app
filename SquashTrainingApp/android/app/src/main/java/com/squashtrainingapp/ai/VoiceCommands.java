package com.squashtrainingapp.ai;

import android.content.Context;
import com.squashtrainingapp.R;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

public class VoiceCommands {
    private static final String TAG = "VoiceCommands";
    
    public enum CommandType {
        NAVIGATE_PROFILE,
        NAVIGATE_CHECKLIST,
        NAVIGATE_RECORD,
        NAVIGATE_HISTORY,
        NAVIGATE_COACH,
        NAVIGATE_SETTINGS,
        SHOW_PROGRESS,
        START_WORKOUT,
        GET_ADVICE,
        UNKNOWN
    }
    
    public static class Command {
        public CommandType type;
        public String parameters;
        
        public Command(CommandType type, String parameters) {
            this.type = type;
            this.parameters = parameters;
        }
    }
    
    private static final Map<Pattern, CommandType> commandPatterns = new HashMap<>();
    
    static {
        // Navigation commands - English
        commandPatterns.put(Pattern.compile(".*\\b(show|open|go to)\\b.*\\bprofile\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_PROFILE);
        commandPatterns.put(Pattern.compile(".*\\b(show|open|go to)\\b.*\\b(checklist|exercises?)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_CHECKLIST);
        commandPatterns.put(Pattern.compile(".*\\b(record|start|new)\\b.*\\bworkout\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_RECORD);
        commandPatterns.put(Pattern.compile(".*\\b(show|view|see)\\b.*\\b(history|past|previous)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_HISTORY);
        commandPatterns.put(Pattern.compile(".*\\b(coach|coaching|advice|tips?)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_COACH);
        commandPatterns.put(Pattern.compile(".*\\b(settings?|preferences?)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_SETTINGS);
        
        // Navigation commands - Korean
        commandPatterns.put(Pattern.compile(".*(프로필|내 정보).*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_PROFILE);
        commandPatterns.put(Pattern.compile(".*(체크리스트|운동 목록|체크 리스트).*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_CHECKLIST);
        commandPatterns.put(Pattern.compile(".*(기록|운동 시작|새 운동|운동하기).*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_RECORD);
        commandPatterns.put(Pattern.compile(".*(히스토리|기록 보기|이력|과거 기록).*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_HISTORY);
        commandPatterns.put(Pattern.compile(".*(코치|코칭|조언|팁).*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_COACH);
        commandPatterns.put(Pattern.compile(".*(설정|환경설정|세팅).*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_SETTINGS);
        
        // Action commands - English
        commandPatterns.put(Pattern.compile(".*\\b(show|view|check)\\b.*\\b(progress|stats?|statistics)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.SHOW_PROGRESS);
        commandPatterns.put(Pattern.compile(".*\\b(start|begin|do)\\b.*\\b(workout|exercise|training)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.START_WORKOUT);
        commandPatterns.put(Pattern.compile(".*\\b(what|how|advice|help|tip)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.GET_ADVICE);
        
        // Action commands - Korean
        commandPatterns.put(Pattern.compile(".*(진행|진척|통계|상태).*보기.*", Pattern.CASE_INSENSITIVE), CommandType.SHOW_PROGRESS);
        commandPatterns.put(Pattern.compile(".*(운동|트레이닝|연습).*시작.*", Pattern.CASE_INSENSITIVE), CommandType.START_WORKOUT);
        commandPatterns.put(Pattern.compile(".*(도움|조언|팁|어떻게|뭐|무엇).*", Pattern.CASE_INSENSITIVE), CommandType.GET_ADVICE);
    }
    
    public static Command parseCommand(String voiceInput) {
        if (voiceInput == null || voiceInput.trim().isEmpty()) {
            return new Command(CommandType.UNKNOWN, null);
        }
        
        String normalizedInput = voiceInput.trim().toLowerCase();
        
        for (Map.Entry<Pattern, CommandType> entry : commandPatterns.entrySet()) {
            if (entry.getKey().matcher(normalizedInput).matches()) {
                return new Command(entry.getValue(), voiceInput);
            }
        }
        
        return new Command(CommandType.UNKNOWN, voiceInput);
    }
    
    public static String getResponseForCommand(Context context, Command command) {
        if (context == null) {
            return getDefaultResponseForCommand(command);
        }
        switch (command.type) {
            case NAVIGATE_PROFILE:
                return context.getString(R.string.voice_response_opening_profile);
            case NAVIGATE_CHECKLIST:
                return context.getString(R.string.voice_response_showing_checklist);
            case NAVIGATE_RECORD:
                return context.getString(R.string.voice_response_starting_record);
            case NAVIGATE_HISTORY:
                return context.getString(R.string.voice_response_loading_history);
            case NAVIGATE_COACH:
                return context.getString(R.string.voice_response_getting_advice);
            case NAVIGATE_SETTINGS:
                return context.getString(R.string.voice_response_opening_settings);
            case SHOW_PROGRESS:
                return context.getString(R.string.voice_response_analyzing_progress);
            case START_WORKOUT:
                return context.getString(R.string.voice_response_start_workout);
            case GET_ADVICE:
                return context.getString(R.string.voice_response_let_me_help);
            default:
                return context.getString(R.string.voice_response_unknown_command);
        }
    }
    
    // Fallback method for backward compatibility
    public static String getResponseForCommand(Command command) {
        return getDefaultResponseForCommand(command);
    }
    
    private static String getDefaultResponseForCommand(Command command) {
        switch (command.type) {
            case NAVIGATE_PROFILE:
                return "Opening your profile...";
            case NAVIGATE_CHECKLIST:
                return "Showing your exercise checklist...";
            case NAVIGATE_RECORD:
                return "Starting workout recording...";
            case NAVIGATE_HISTORY:
                return "Loading your workout history...";
            case NAVIGATE_COACH:
                return "Getting coaching advice...";
            case NAVIGATE_SETTINGS:
                return "Opening settings...";
            case SHOW_PROGRESS:
                return "Analyzing your progress...";
            case START_WORKOUT:
                return "Let's start your workout!";
            case GET_ADVICE:
                return "Let me help you with that...";
            default:
                return "I didn't understand that. Try saying 'show profile' or 'start workout'.";
        }
    }
    
    public static String getHelpText(Context context) {
        if (context == null) {
            return getDefaultHelpText();
        }
        return context.getString(R.string.voice_help_text);
    }
    
    // Fallback method for backward compatibility
    public static String getHelpText() {
        return getDefaultHelpText();
    }
    
    private static String getDefaultHelpText() {
        return "You can say things like:\n" +
               "• \"Show my profile\"\n" +
               "• \"Open checklist\"\n" +
               "• \"Start a new workout\"\n" +
               "• \"Show my history\"\n" +
               "• \"Get coaching advice\"\n" +
               "• \"Check my progress\"";
    }
}
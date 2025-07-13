package com.squashtrainingapp.ai;

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
        // Navigation commands
        commandPatterns.put(Pattern.compile(".*\\b(show|open|go to)\\b.*\\bprofile\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_PROFILE);
        commandPatterns.put(Pattern.compile(".*\\b(show|open|go to)\\b.*\\b(checklist|exercises?)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_CHECKLIST);
        commandPatterns.put(Pattern.compile(".*\\b(record|start|new)\\b.*\\bworkout\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_RECORD);
        commandPatterns.put(Pattern.compile(".*\\b(show|view|see)\\b.*\\b(history|past|previous)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_HISTORY);
        commandPatterns.put(Pattern.compile(".*\\b(coach|coaching|advice|tips?)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_COACH);
        commandPatterns.put(Pattern.compile(".*\\b(settings?|preferences?)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.NAVIGATE_SETTINGS);
        
        // Action commands
        commandPatterns.put(Pattern.compile(".*\\b(show|view|check)\\b.*\\b(progress|stats?|statistics)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.SHOW_PROGRESS);
        commandPatterns.put(Pattern.compile(".*\\b(start|begin|do)\\b.*\\b(workout|exercise|training)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.START_WORKOUT);
        commandPatterns.put(Pattern.compile(".*\\b(what|how|advice|help|tip)\\b.*", Pattern.CASE_INSENSITIVE), CommandType.GET_ADVICE);
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
    
    public static String getResponseForCommand(Command command) {
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
    
    public static String getHelpText() {
        return "You can say things like:\n" +
               "• \"Show my profile\"\n" +
               "• \"Open checklist\"\n" +
               "• \"Start a new workout\"\n" +
               "• \"Show my history\"\n" +
               "• \"Get coaching advice\"\n" +
               "• \"Check my progress\"";
    }
}
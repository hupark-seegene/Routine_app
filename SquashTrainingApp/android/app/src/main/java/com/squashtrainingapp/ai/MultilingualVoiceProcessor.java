package com.squashtrainingapp.ai;

import android.content.Context;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MultilingualVoiceProcessor {
    private static final String TAG = "MultilingualVoiceProcessor";
    
    // Number patterns for both Korean and English
    private static final Map<String, Integer> KOREAN_NUMBERS = new HashMap<>();
    private static final Map<String, Integer> ENGLISH_NUMBERS = new HashMap<>();
    
    static {
        // Korean numbers
        KOREAN_NUMBERS.put("영", 0);
        KOREAN_NUMBERS.put("일", 1);
        KOREAN_NUMBERS.put("이", 2);
        KOREAN_NUMBERS.put("삼", 3);
        KOREAN_NUMBERS.put("사", 4);
        KOREAN_NUMBERS.put("오", 5);
        KOREAN_NUMBERS.put("육", 6);
        KOREAN_NUMBERS.put("칠", 7);
        KOREAN_NUMBERS.put("팔", 8);
        KOREAN_NUMBERS.put("구", 9);
        KOREAN_NUMBERS.put("십", 10);
        KOREAN_NUMBERS.put("이십", 20);
        KOREAN_NUMBERS.put("삼십", 30);
        KOREAN_NUMBERS.put("사십", 40);
        KOREAN_NUMBERS.put("오십", 50);
        KOREAN_NUMBERS.put("백", 100);
        
        // Native Korean numbers
        KOREAN_NUMBERS.put("하나", 1);
        KOREAN_NUMBERS.put("둘", 2);
        KOREAN_NUMBERS.put("셋", 3);
        KOREAN_NUMBERS.put("넷", 4);
        KOREAN_NUMBERS.put("다섯", 5);
        KOREAN_NUMBERS.put("여섯", 6);
        KOREAN_NUMBERS.put("일곱", 7);
        KOREAN_NUMBERS.put("여덟", 8);
        KOREAN_NUMBERS.put("아홉", 9);
        KOREAN_NUMBERS.put("열", 10);
        KOREAN_NUMBERS.put("스물", 20);
        KOREAN_NUMBERS.put("서른", 30);
        
        // English numbers
        ENGLISH_NUMBERS.put("zero", 0);
        ENGLISH_NUMBERS.put("one", 1);
        ENGLISH_NUMBERS.put("two", 2);
        ENGLISH_NUMBERS.put("three", 3);
        ENGLISH_NUMBERS.put("four", 4);
        ENGLISH_NUMBERS.put("five", 5);
        ENGLISH_NUMBERS.put("six", 6);
        ENGLISH_NUMBERS.put("seven", 7);
        ENGLISH_NUMBERS.put("eight", 8);
        ENGLISH_NUMBERS.put("nine", 9);
        ENGLISH_NUMBERS.put("ten", 10);
        ENGLISH_NUMBERS.put("eleven", 11);
        ENGLISH_NUMBERS.put("twelve", 12);
        ENGLISH_NUMBERS.put("thirteen", 13);
        ENGLISH_NUMBERS.put("fourteen", 14);
        ENGLISH_NUMBERS.put("fifteen", 15);
        ENGLISH_NUMBERS.put("twenty", 20);
        ENGLISH_NUMBERS.put("thirty", 30);
        ENGLISH_NUMBERS.put("forty", 40);
        ENGLISH_NUMBERS.put("fifty", 50);
    }
    
    // Common exercise terms mapping
    private static final Map<String, String> EXERCISE_TERM_MAPPING = new HashMap<>();
    static {
        // Korean to English
        EXERCISE_TERM_MAPPING.put("세트", "sets");
        EXERCISE_TERM_MAPPING.put("셋", "sets");
        EXERCISE_TERM_MAPPING.put("회", "reps");
        EXERCISE_TERM_MAPPING.put("개", "reps");
        EXERCISE_TERM_MAPPING.put("번", "reps");
        EXERCISE_TERM_MAPPING.put("분", "minutes");
        EXERCISE_TERM_MAPPING.put("초", "seconds");
        EXERCISE_TERM_MAPPING.put("시간", "hours");
        
        // Exercise names
        EXERCISE_TERM_MAPPING.put("스쿼시", "squash");
        EXERCISE_TERM_MAPPING.put("포핸드", "forehand");
        EXERCISE_TERM_MAPPING.put("백핸드", "backhand");
        EXERCISE_TERM_MAPPING.put("서브", "serve");
        EXERCISE_TERM_MAPPING.put("발리", "volley");
        EXERCISE_TERM_MAPPING.put("드롭샷", "drop shot");
        EXERCISE_TERM_MAPPING.put("드라이브", "drive");
        EXERCISE_TERM_MAPPING.put("풋워크", "footwork");
        EXERCISE_TERM_MAPPING.put("유산소", "cardio");
        EXERCISE_TERM_MAPPING.put("근력", "strength");
    }
    
    // Language detection
    public enum DetectedLanguage {
        KOREAN,
        ENGLISH,
        MIXED,
        UNKNOWN
    }
    
    public static class ProcessedInput {
        public String originalText;
        public String normalizedText;
        public DetectedLanguage language;
        public Map<String, Object> extractedData;
        
        public ProcessedInput(String original) {
            this.originalText = original;
            this.normalizedText = original;
            this.extractedData = new HashMap<>();
        }
    }
    
    public static ProcessedInput processInput(String input) {
        ProcessedInput result = new ProcessedInput(input);
        
        // Detect language
        result.language = detectLanguage(input);
        
        // Normalize and extract data
        result.normalizedText = normalizeText(input);
        extractNumbers(result);
        extractExerciseTerms(result);
        extractTimeUnits(result);
        
        return result;
    }
    
    private static DetectedLanguage detectLanguage(String text) {
        int koreanChars = 0;
        int englishChars = 0;
        
        for (char c : text.toCharArray()) {
            if (isKorean(c)) {
                koreanChars++;
            } else if (isEnglish(c)) {
                englishChars++;
            }
        }
        
        int total = koreanChars + englishChars;
        if (total == 0) return DetectedLanguage.UNKNOWN;
        
        float koreanRatio = (float) koreanChars / total;
        
        if (koreanRatio > 0.8) {
            return DetectedLanguage.KOREAN;
        } else if (koreanRatio < 0.2) {
            return DetectedLanguage.ENGLISH;
        } else {
            return DetectedLanguage.MIXED;
        }
    }
    
    private static boolean isKorean(char c) {
        return (c >= 0xAC00 && c <= 0xD7AF) || // Hangul syllables
               (c >= 0x1100 && c <= 0x11FF) || // Hangul Jamo
               (c >= 0x3130 && c <= 0x318F);   // Hangul compatibility Jamo
    }
    
    private static boolean isEnglish(char c) {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
    }
    
    private static String normalizeText(String text) {
        // Convert to lowercase
        text = text.toLowerCase().trim();
        
        // Replace common variations
        text = text.replaceAll("\\s+", " ");
        text = text.replaceAll("[!.,?]", "");
        
        // Normalize Korean particles
        text = text.replaceAll("(을|를|이|가|은|는|에|에서|으로|로)", " ");
        
        return text;
    }
    
    private static void extractNumbers(ProcessedInput input) {
        List<Integer> numbers = new ArrayList<>();
        String text = input.normalizedText;
        
        // Extract Arabic numerals
        Pattern digitPattern = Pattern.compile("\\d+");
        Matcher digitMatcher = digitPattern.matcher(text);
        while (digitMatcher.find()) {
            numbers.add(Integer.parseInt(digitMatcher.group()));
        }
        
        // Extract Korean numbers
        for (Map.Entry<String, Integer> entry : KOREAN_NUMBERS.entrySet()) {
            if (text.contains(entry.getKey())) {
                numbers.add(entry.getValue());
                // Handle compound numbers (e.g., "이십삼" = 23)
                int index = text.indexOf(entry.getKey());
                if (entry.getKey().contains("십") && index > 0) {
                    char prevChar = text.charAt(index - 1);
                    String prevStr = String.valueOf(prevChar);
                    if (KOREAN_NUMBERS.containsKey(prevStr)) {
                        int compound = KOREAN_NUMBERS.get(prevStr) * 10;
                        numbers.remove(Integer.valueOf(entry.getValue()));
                        numbers.add(compound);
                    }
                }
            }
        }
        
        // Extract English numbers
        String[] words = text.split(" ");
        for (String word : words) {
            if (ENGLISH_NUMBERS.containsKey(word)) {
                numbers.add(ENGLISH_NUMBERS.get(word));
            }
        }
        
        input.extractedData.put("numbers", numbers);
    }
    
    private static void extractExerciseTerms(ProcessedInput input) {
        List<String> exerciseTerms = new ArrayList<>();
        String text = input.normalizedText;
        
        for (Map.Entry<String, String> entry : EXERCISE_TERM_MAPPING.entrySet()) {
            if (text.contains(entry.getKey())) {
                exerciseTerms.add(entry.getValue());
            }
        }
        
        input.extractedData.put("exercise_terms", exerciseTerms);
    }
    
    private static void extractTimeUnits(ProcessedInput input) {
        String text = input.normalizedText;
        String timeUnit = "minutes"; // default
        
        if (text.contains("초") || text.contains("second")) {
            timeUnit = "seconds";
        } else if (text.contains("분") || text.contains("minute")) {
            timeUnit = "minutes";
        } else if (text.contains("시간") || text.contains("hour")) {
            timeUnit = "hours";
        }
        
        input.extractedData.put("time_unit", timeUnit);
    }
    
    // Utility methods for command generation
    public static String generateKoreanResponse(ExtendedVoiceCommands.Command command) {
        switch (command.type) {
            case LOG_SETS:
                return generateNumberResponse(command, "세트");
            case LOG_REPS:
                return generateNumberResponse(command, "회");
            case LOG_DURATION:
                return generateTimeResponse(command);
            default:
                return ExtendedVoiceCommands.getResponseForCommand(null, command);
        }
    }
    
    private static String generateNumberResponse(ExtendedVoiceCommands.Command command, String unit) {
        if (command.extras.containsKey("value")) {
            int value = Integer.parseInt(command.extras.get("value"));
            String koreanNumber = convertToKoreanNumber(value);
            return koreanNumber + " " + unit + "를 기록했습니다.";
        }
        return unit + "를 기록합니다.";
    }
    
    private static String generateTimeResponse(ExtendedVoiceCommands.Command command) {
        if (command.extras.containsKey("value")) {
            int value = Integer.parseInt(command.extras.get("value"));
            String unit = command.extras.get("unit");
            String koreanNumber = convertToKoreanNumber(value);
            String koreanUnit = unit.equals("seconds") ? "초" : unit.equals("hours") ? "시간" : "분";
            return koreanNumber + koreanUnit + "을 기록했습니다.";
        }
        return "시간을 기록합니다.";
    }
    
    private static String convertToKoreanNumber(int number) {
        // Simple conversion for common numbers
        if (number <= 10) {
            switch (number) {
                case 1: return "일";
                case 2: return "이";
                case 3: return "삼";
                case 4: return "사";
                case 5: return "오";
                case 6: return "육";
                case 7: return "칠";
                case 8: return "팔";
                case 9: return "구";
                case 10: return "십";
                default: return String.valueOf(number);
            }
        } else if (number <= 99) {
            int tens = number / 10;
            int ones = number % 10;
            String result = "";
            if (tens > 1) {
                result += convertToKoreanNumber(tens);
            }
            result += "십";
            if (ones > 0) {
                result += convertToKoreanNumber(ones);
            }
            return result;
        }
        return String.valueOf(number);
    }
    
    // Mixed language command processing
    public static ExtendedVoiceCommands.Command processMixedLanguageCommand(String input) {
        ProcessedInput processed = processInput(input);
        
        // Convert mixed input to normalized form
        String normalizedInput = processed.normalizedText;
        
        // Replace Korean exercise terms with English equivalents
        for (Map.Entry<String, String> entry : EXERCISE_TERM_MAPPING.entrySet()) {
            normalizedInput = normalizedInput.replace(entry.getKey(), entry.getValue());
        }
        
        // Process with standard command parser
        ExtendedVoiceCommands.Command command = ExtendedVoiceCommands.parseCommand(normalizedInput);
        
        // Enhance with extracted data
        if (processed.extractedData.containsKey("numbers")) {
            List<Integer> numbers = (List<Integer>) processed.extractedData.get("numbers");
            if (!numbers.isEmpty()) {
                command.extras.put("value", String.valueOf(numbers.get(0)));
            }
        }
        
        if (processed.extractedData.containsKey("time_unit")) {
            command.extras.put("unit", (String) processed.extractedData.get("time_unit"));
        }
        
        return command;
    }
    
    // Language preference detection
    public static Locale detectPreferredLocale(Context context, String input) {
        ProcessedInput processed = processInput(input);
        
        switch (processed.language) {
            case KOREAN:
                return Locale.KOREAN;
            case ENGLISH:
                return Locale.US;
            case MIXED:
                // Check system locale as tiebreaker
                Locale systemLocale = context.getResources().getConfiguration().locale;
                if (systemLocale.getLanguage().equals("ko")) {
                    return Locale.KOREAN;
                }
                return Locale.US;
            default:
                return Locale.getDefault();
        }
    }
}
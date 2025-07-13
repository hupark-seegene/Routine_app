package com.squashtrainingapp.ai;

import android.content.Context;
import com.squashtrainingapp.models.User;
import com.squashtrainingapp.models.Record;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class AIRecommendations {
    
    private Context context;
    private Random random = new Random();
    
    public AIRecommendations(Context context) {
        this.context = context;
    }
    
    // Exercise recommendations based on user level
    public List<String> getExerciseRecommendations(User user) {
        List<String> recommendations = new ArrayList<>();
        
        if (user.getLevel() < 5) {
            // Beginner recommendations
            recommendations.add("Focus on basic footwork - practice ghosting for 10 minutes");
            recommendations.add("Work on straight drives - aim for consistency over power");
            recommendations.add("Practice your serve - develop 2 reliable serve variations");
        } else if (user.getLevel() < 10) {
            // Intermediate recommendations
            recommendations.add("Improve court movement - practice figure-8 patterns");
            recommendations.add("Develop your cross-court game - work on width and height");
            recommendations.add("Practice deception - vary your racket preparation");
        } else {
            // Advanced recommendations
            recommendations.add("Master the volley drop - practice soft hands at the front");
            recommendations.add("Work on counter-drops - quick recovery is key");
            recommendations.add("Develop multiple serve variations - keep opponents guessing");
        }
        
        return recommendations;
    }
    
    // Training intensity recommendations
    public String getIntensityRecommendation(User user, List<Record> recentRecords) {
        if (recentRecords.isEmpty()) {
            return "Start with moderate intensity today - focus on form over power";
        }
        
        // Calculate average recent intensity
        int avgIntensity = 0;
        int avgFatigue = 0;
        for (Record record : recentRecords) {
            avgIntensity += record.getIntensity();
            avgFatigue += record.getFatigue();
        }
        avgIntensity /= recentRecords.size();
        avgFatigue /= recentRecords.size();
        
        if (avgFatigue > 7) {
            return "Consider a recovery session today - light movement and stretching";
        } else if (avgIntensity < 5) {
            return "You can push harder today - try increasing intensity by 10-15%";
        } else {
            return "Maintain current intensity - you're in the optimal training zone";
        }
    }
    
    // Personalized tips
    public String getDailyTip(User user) {
        String[] beginnerTips = {
            "Keep your eye on the ball through contact for better accuracy",
            "Practice your ready position between every shot",
            "Focus on hitting the ball at the top of the bounce"
        };
        
        String[] intermediateTips = {
            "Vary your pace to disrupt your opponent's rhythm",
            "Use height on the front wall to create time for recovery",
            "Practice hitting from uncomfortable positions"
        };
        
        String[] advancedTips = {
            "Study your opponent's patterns in the first few rallies",
            "Use holds and delays to create uncertainty",
            "Master the art of playing the percentages"
        };
        
        String[] tips;
        if (user.getLevel() < 5) {
            tips = beginnerTips;
        } else if (user.getLevel() < 10) {
            tips = intermediateTips;
        } else {
            tips = advancedTips;
        }
        
        return tips[random.nextInt(tips.length)];
    }
    
    // Achievement milestones
    public String checkAchievements(User user) {
        List<String> achievements = new ArrayList<>();
        
        // Session milestones
        if (user.getTotalSessions() == 10) {
            achievements.add("First 10 Sessions Complete! 🎉");
        } else if (user.getTotalSessions() == 50) {
            achievements.add("50 Sessions Milestone! 🏆");
        } else if (user.getTotalSessions() == 100) {
            achievements.add("Century Club Member! 💯");
        }
        
        // Streak achievements
        if (user.getCurrentStreak() == 7) {
            achievements.add("Week Warrior - 7 Day Streak! 🔥");
        } else if (user.getCurrentStreak() == 30) {
            achievements.add("Monthly Master - 30 Day Streak! 🌟");
        }
        
        // Level achievements
        if (user.getLevel() == 5) {
            achievements.add("Reached Level 5 - Intermediate Player! 📈");
        } else if (user.getLevel() == 10) {
            achievements.add("Level 10 - Advanced Player Status! 🎯");
        }
        
        return achievements.isEmpty() ? null : achievements.get(0);
    }
    
    // Workout suggestions
    public String suggestWorkout(User user, int availableMinutes) {
        if (availableMinutes < 30) {
            return "Quick Session: 5 min warm-up, 15 min technique work, 5 min cool-down";
        } else if (availableMinutes < 45) {
            return "Standard Session: 10 min warm-up, 20 min drills, 10 min game play, 5 min cool-down";
        } else {
            return "Full Session: 10 min warm-up, 15 min technique, 20 min match play, 10 min conditioning, 5 min cool-down";
        }
    }
}
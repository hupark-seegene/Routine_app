package com.squashtrainingapp.services;

import android.app.AlarmManager;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.squashtrainingapp.R;
import com.squashtrainingapp.SimpleMainActivity;
import com.squashtrainingapp.receivers.NotificationReceiver;

import java.util.Calendar;

public class NotificationService {
    
    private static final String CHANNEL_ID = "squash_training_channel";
    private static final String CHANNEL_NAME = "스쿼시 트레이닝 알림";
    private static final String CHANNEL_DESC = "운동 리마인더 및 동기부여 알림";
    
    private static final String PREFS_NAME = "notification_prefs";
    private static final String KEY_DAILY_ENABLED = "daily_notification_enabled";
    private static final String KEY_WORKOUT_REMINDER_ENABLED = "workout_reminder_enabled";
    private static final String KEY_ACHIEVEMENT_ENABLED = "achievement_notification_enabled";
    private static final String KEY_DAILY_HOUR = "daily_notification_hour";
    private static final String KEY_DAILY_MINUTE = "daily_notification_minute";
    
    // Notification IDs
    public static final int NOTIFICATION_ID_DAILY = 1001;
    public static final int NOTIFICATION_ID_WORKOUT_REMINDER = 1002;
    public static final int NOTIFICATION_ID_ACHIEVEMENT = 1003;
    public static final int NOTIFICATION_ID_STREAK_WARNING = 1004;
    
    private Context context;
    private NotificationManagerCompat notificationManager;
    private SharedPreferences prefs;
    private AlarmManager alarmManager;
    
    public NotificationService(Context context) {
        this.context = context;
        this.notificationManager = NotificationManagerCompat.from(context);
        this.prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        this.alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        
        createNotificationChannel();
    }
    
    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            );
            channel.setDescription(CHANNEL_DESC);
            channel.enableVibration(true);
            channel.setVibrationPattern(new long[]{0, 250, 250, 250});
            
            NotificationManager manager = context.getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }
    }
    
    // Show notifications
    public void showDailyMotivationNotification(String message) {
        if (!isDailyNotificationEnabled()) return;
        
        Intent intent = new Intent(context, SimpleMainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(
            context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("🎾 오늘의 동기부여")
            .setContentText(message)
            .setStyle(new NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true);
        
        notificationManager.notify(NOTIFICATION_ID_DAILY, builder.build());
    }
    
    public void showWorkoutReminderNotification() {
        if (!isWorkoutReminderEnabled()) return;
        
        Intent intent = new Intent(context, SimpleMainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(
            context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("💪 운동 시간이에요!")
            .setContentText("오늘의 스쿼시 트레이닝을 시작해볼까요?")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .addAction(R.drawable.ic_play_arrow, "시작하기", pendingIntent);
        
        notificationManager.notify(NOTIFICATION_ID_WORKOUT_REMINDER, builder.build());
    }
    
    public void showAchievementUnlockedNotification(String achievementName, int points) {
        if (!isAchievementNotificationEnabled()) return;
        
        Intent intent = new Intent(context, SimpleMainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(
            context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("🏆 업적 달성!")
            .setContentText(achievementName + " (+" + points + "P)")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true);
        
        notificationManager.notify(NOTIFICATION_ID_ACHIEVEMENT, builder.build());
    }
    
    public void showStreakWarningNotification(int currentStreak) {
        Intent intent = new Intent(context, SimpleMainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(
            context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("⚠️ 연속 기록이 끊길 위기에요!")
            .setContentText(현재 " + currentStreak + "일 연속 운동 중! 오늘도 계속해볼까요?")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true);
        
        notificationManager.notify(NOTIFICATION_ID_STREAK_WARNING, builder.build());
    }
    
    // Schedule notifications
    public void scheduleDailyNotification(int hour, int minute) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        calendar.set(Calendar.HOUR_OF_DAY, hour);
        calendar.set(Calendar.MINUTE, minute);
        calendar.set(Calendar.SECOND, 0);
        
        // If the time has passed today, schedule for tomorrow
        if (calendar.getTimeInMillis() <= System.currentTimeMillis()) {
            calendar.add(Calendar.DAY_OF_MONTH, 1);
        }
        
        Intent intent = new Intent(context, NotificationReceiver.class);
        intent.setAction("com.squashtrainingapp.DAILY_NOTIFICATION");
        
        PendingIntent pendingIntent = PendingIntent.getBroadcast(
            context, NOTIFICATION_ID_DAILY, intent, 
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        
        if (alarmManager != null) {
            alarmManager.setRepeating(
                AlarmManager.RTC_WAKEUP,
                calendar.getTimeInMillis(),
                AlarmManager.INTERVAL_DAY,
                pendingIntent
            );
        }
        
        // Save settings
        prefs.edit()
            .putBoolean(KEY_DAILY_ENABLED, true)
            .putInt(KEY_DAILY_HOUR, hour)
            .putInt(KEY_DAILY_MINUTE, minute)
            .apply();
    }
    
    public void cancelDailyNotification() {
        Intent intent = new Intent(context, NotificationReceiver.class);
        intent.setAction("com.squashtrainingapp.DAILY_NOTIFICATION");
        
        PendingIntent pendingIntent = PendingIntent.getBroadcast(
            context, NOTIFICATION_ID_DAILY, intent, 
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        
        if (alarmManager != null) {
            alarmManager.cancel(pendingIntent);
        }
        
        prefs.edit().putBoolean(KEY_DAILY_ENABLED, false).apply();
    }
    
    // Settings
    public boolean isDailyNotificationEnabled() {
        return prefs.getBoolean(KEY_DAILY_ENABLED, true);
    }
    
    public boolean isWorkoutReminderEnabled() {
        return prefs.getBoolean(KEY_WORKOUT_REMINDER_ENABLED, true);
    }
    
    public boolean isAchievementNotificationEnabled() {
        return prefs.getBoolean(KEY_ACHIEVEMENT_ENABLED, true);
    }
    
    public void setDailyNotificationEnabled(boolean enabled) {
        prefs.edit().putBoolean(KEY_DAILY_ENABLED, enabled).apply();
        if (!enabled) {
            cancelDailyNotification();
        }
    }
    
    public void setWorkoutReminderEnabled(boolean enabled) {
        prefs.edit().putBoolean(KEY_WORKOUT_REMINDER_ENABLED, enabled).apply();
    }
    
    public void setAchievementNotificationEnabled(boolean enabled) {
        prefs.edit().putBoolean(KEY_ACHIEVEMENT_ENABLED, enabled).apply();
    }
    
    public int getDailyNotificationHour() {
        return prefs.getInt(KEY_DAILY_HOUR, 8); // Default 8 AM
    }
    
    public int getDailyNotificationMinute() {
        return prefs.getInt(KEY_DAILY_MINUTE, 0);
    }
    
    // Motivational messages
    private static final String[] MOTIVATIONAL_MESSAGES = {
        "🌟 오늘도 코트에서 만나요! 당신의 실력은 매일 성장하고 있어요.",
        "💪 강한 멘탈이 강한 플레이어를 만듭니다. 오늘도 파이팅!",
        "🎯 목표에 한 걸음 더 가까워지는 날입니다. 시작해볼까요?",
        "⚡ 어제의 나보다 1% 더 나아지면 그것이 바로 성공입니다.",
        "🎆 스쿼시는 단순한 운동이 아닌 인생의 메타포입니다. 함께 성장해요!",
        "🔥 연속 기록을 이어가는 당신, 정말 멋져요!",
        "🏆 챙피언도 매일 연습합니다. 오늘은 당신의 연습일!",
        "🌟 코트 위에서만큼은 모두가 평등합니다. 자신감을 가지세요!"
    };
    
    public static String getRandomMotivationalMessage() {
        return MOTIVATIONAL_MESSAGES[(int) (Math.random() * MOTIVATIONAL_MESSAGES.length)];
    }
}
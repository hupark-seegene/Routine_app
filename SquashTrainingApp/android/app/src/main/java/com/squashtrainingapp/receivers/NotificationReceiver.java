package com.squashtrainingapp.receivers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.squashtrainingapp.services.NotificationService;

public class NotificationReceiver extends BroadcastReceiver {
    
    @Override
    public void onReceive(Context context, Intent intent) {
        NotificationService notificationService = new NotificationService(context);
        
        if (intent.getAction() != null) {
            switch (intent.getAction()) {
                case "com.squashtrainingapp.DAILY_NOTIFICATION":
                    String message = NotificationService.getRandomMotivationalMessage();
                    notificationService.showDailyMotivationNotification(message);
                    break;
                    
                case "com.squashtrainingapp.WORKOUT_REMINDER":
                    notificationService.showWorkoutReminderNotification();
                    break;
                    
                case Intent.ACTION_BOOT_COMPLETED:
                    // Reschedule notifications after device reboot
                    rescheduleNotifications(context);
                    break;
            }
        }
    }
    
    private void rescheduleNotifications(Context context) {
        NotificationService notificationService = new NotificationService(context);
        
        // Reschedule daily notification if enabled
        if (notificationService.isDailyNotificationEnabled()) {
            int hour = notificationService.getDailyNotificationHour();
            int minute = notificationService.getDailyNotificationMinute();
            notificationService.scheduleDailyNotification(hour, minute);
        }
    }
}
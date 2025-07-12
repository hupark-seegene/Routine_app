import { Alert, AppState, AppStateStatus, Platform } from 'react-native';
import { getDBConnection } from '../database/database';
import SQLite from 'react-native-sqlite-storage';

interface NotificationSchedule {
  id: string;
  type: 'workout_reminder' | 'missed_workout' | 'weekly_report' | 'custom';
  title: string;
  message: string;
  scheduledTime: Date;
  recurring: boolean;
  recurringPattern?: 'daily' | 'weekly';
  enabled: boolean;
  lastShown?: Date;
}

class SQLiteNotificationService {
  private db: SQLite.SQLiteDatabase | null = null;
  private appState: AppStateStatus = AppState.currentState;
  private checkInterval: NodeJS.Timeout | null = null;
  private isInitialized = false;

  constructor() {
    this.initDatabase();
    this.setupAppStateListener();
  }

  private async initDatabase() {
    try {
      this.db = await getDBConnection();
      
      // Create notifications table
      await this.db.executeSql(`
        CREATE TABLE IF NOT EXISTS notifications (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          scheduled_time DATETIME NOT NULL,
          recurring INTEGER DEFAULT 0,
          recurring_pattern TEXT,
          enabled INTEGER DEFAULT 1,
          last_shown DATETIME,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
      `);

      // Create index for better performance
      await this.db.executeSql(`
        CREATE INDEX IF NOT EXISTS idx_notifications_time ON notifications(scheduled_time);
      `);

      this.isInitialized = true;
      console.log('SQLiteNotificationService: Database initialized');
    } catch (error) {
      console.error('SQLiteNotificationService: Failed to initialize database', error);
    }
  }

  private setupAppStateListener() {
    AppState.addEventListener('change', this.handleAppStateChange);
  }

  private handleAppStateChange = (nextAppState: AppStateStatus) => {
    if (this.appState.match(/inactive|background/) && nextAppState === 'active') {
      // App has come to foreground - check for pending notifications
      this.checkPendingNotifications();
    }
    this.appState = nextAppState;
  };

  public async init(): Promise<void> {
    if (!this.isInitialized) {
      await this.initDatabase();
    }
    
    // Start periodic check for notifications
    this.startNotificationCheck();
    console.log('SQLiteNotificationService: Initialized successfully');
  }

  private startNotificationCheck() {
    // Check every minute when app is active
    if (this.checkInterval) {
      clearInterval(this.checkInterval);
    }

    this.checkInterval = setInterval(() => {
      if (this.appState === 'active') {
        this.checkPendingNotifications();
      }
    }, 60000); // Check every minute

    // Initial check
    this.checkPendingNotifications();
  }

  private async checkPendingNotifications() {
    if (!this.db) return;

    try {
      const now = new Date();
      const [result] = await this.db.executeSql(
        `SELECT * FROM notifications 
         WHERE enabled = 1 
         AND scheduled_time <= datetime('now')
         AND (last_shown IS NULL OR datetime(last_shown) < datetime(scheduled_time))
         ORDER BY scheduled_time ASC`
      );

      for (let i = 0; i < result.rows.length; i++) {
        const notification = result.rows.item(i);
        await this.showNotification(notification);
        await this.updateNotificationShown(notification);
      }
    } catch (error) {
      console.error('SQLiteNotificationService: Error checking notifications', error);
    }
  }

  private async showNotification(notification: any) {
    // Use React Native Alert as notification
    Alert.alert(
      notification.title,
      notification.message,
      [
        { text: 'Dismiss', style: 'cancel' },
        { text: 'View', onPress: () => this.handleNotificationPress(notification) }
      ],
      { cancelable: true }
    );
  }

  private handleNotificationPress(notification: any) {
    // Handle notification press based on type
    console.log('Notification pressed:', notification.type);
    // Navigation logic can be added here
  }

  private async updateNotificationShown(notification: any) {
    if (!this.db) return;

    try {
      await this.db.executeSql(
        `UPDATE notifications SET last_shown = datetime('now') WHERE id = ?`,
        [notification.id]
      );

      // If recurring, calculate next scheduled time
      if (notification.recurring && notification.recurring_pattern) {
        const nextTime = this.calculateNextScheduledTime(
          new Date(notification.scheduled_time),
          notification.recurring_pattern
        );
        
        await this.db.executeSql(
          `UPDATE notifications SET scheduled_time = ? WHERE id = ?`,
          [nextTime.toISOString(), notification.id]
        );
      }
    } catch (error) {
      console.error('SQLiteNotificationService: Error updating notification', error);
    }
  }

  private calculateNextScheduledTime(currentTime: Date, pattern: string): Date {
    const next = new Date(currentTime);
    
    switch (pattern) {
      case 'daily':
        next.setDate(next.getDate() + 1);
        break;
      case 'weekly':
        next.setDate(next.getDate() + 7);
        break;
      default:
        next.setDate(next.getDate() + 1);
    }
    
    return next;
  }

  // Public API methods

  async scheduleWorkoutReminder(time: string, enabled: boolean) {
    if (!this.db) return;

    try {
      const [hours, minutes] = time.split(':').map(Number);
      const scheduledTime = new Date();
      scheduledTime.setHours(hours, minutes, 0, 0);
      
      // If time has passed today, schedule for tomorrow
      if (scheduledTime < new Date()) {
        scheduledTime.setDate(scheduledTime.getDate() + 1);
      }

      await this.db.executeSql(
        `INSERT OR REPLACE INTO notifications 
         (id, type, title, message, scheduled_time, recurring, recurring_pattern, enabled) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          'workout_reminder',
          'workout_reminder',
          '🏸 Time to Train!',
          'Your squash workout is scheduled. Let\'s improve your game!',
          scheduledTime.toISOString(),
          1,
          'daily',
          enabled ? 1 : 0
        ]
      );

      console.log(`Workout reminder scheduled for ${time}, enabled: ${enabled}`);
    } catch (error) {
      console.error('Error scheduling workout reminder:', error);
    }
  }

  async cancelWorkoutReminder() {
    if (!this.db) return;

    try {
      await this.db.executeSql(
        `UPDATE notifications SET enabled = 0 WHERE id = ?`,
        ['workout_reminder']
      );
    } catch (error) {
      console.error('Error canceling workout reminder:', error);
    }
  }

  async scheduleMissedWorkoutReminder(enabled: boolean) {
    if (!this.db) return;

    try {
      const scheduledTime = new Date();
      scheduledTime.setHours(20, 0, 0, 0); // 8 PM check

      await this.db.executeSql(
        `INSERT OR REPLACE INTO notifications 
         (id, type, title, message, scheduled_time, recurring, recurring_pattern, enabled) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          'missed_workout',
          'missed_workout',
          '💪 Don\'t Break Your Streak!',
          'You haven\'t logged your workout today. Keep your momentum going!',
          scheduledTime.toISOString(),
          1,
          'daily',
          enabled ? 1 : 0
        ]
      );
    } catch (error) {
      console.error('Error scheduling missed workout reminder:', error);
    }
  }

  async cancelMissedWorkoutReminder() {
    if (!this.db) return;

    try {
      await this.db.executeSql(
        `UPDATE notifications SET enabled = 0 WHERE id = ?`,
        ['missed_workout']
      );
    } catch (error) {
      console.error('Error canceling missed workout reminder:', error);
    }
  }

  async scheduleWeeklyReport(enabled: boolean) {
    if (!this.db) return;

    try {
      const scheduledTime = new Date();
      // Schedule for Sunday at 10 AM
      scheduledTime.setDate(scheduledTime.getDate() + (7 - scheduledTime.getDay()));
      scheduledTime.setHours(10, 0, 0, 0);

      await this.db.executeSql(
        `INSERT OR REPLACE INTO notifications 
         (id, type, title, message, scheduled_time, recurring, recurring_pattern, enabled) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          'weekly_report',
          'weekly_report',
          '📊 Weekly Progress Report',
          'Check out your training summary for this week!',
          scheduledTime.toISOString(),
          1,
          'weekly',
          enabled ? 1 : 0
        ]
      );
    } catch (error) {
      console.error('Error scheduling weekly report:', error);
    }
  }

  async cancelWeeklyReport() {
    if (!this.db) return;

    try {
      await this.db.executeSql(
        `UPDATE notifications SET enabled = 0 WHERE id = ?`,
        ['weekly_report']
      );
    } catch (error) {
      console.error('Error canceling weekly report:', error);
    }
  }

  showTestNotification() {
    Alert.alert(
      '🎯 Test Notification',
      'This is a test notification from Squash Training App!',
      [{ text: 'OK' }]
    );
  }

  showWorkoutCompleteNotification(workoutType: string) {
    Alert.alert(
      '🎉 Workout Complete!',
      `Great job completing your ${workoutType} training! Keep up the excellent work!`,
      [{ text: 'Thanks!' }]
    );
  }

  showStreakNotification(days: number) {
    const milestones = [7, 14, 30, 50, 100];
    if (milestones.includes(days)) {
      Alert.alert(
        '🔥 Streak Milestone!',
        `Incredible! You've trained for ${days} days in a row! You're on fire!`,
        [{ text: 'Awesome!' }]
      );
    }
  }

  showPhaseChangeNotification(newPhase: string) {
    Alert.alert(
      '📈 Training Phase Update',
      `You've entered the ${newPhase} phase of your training program. Adjust your intensity accordingly!`,
      [{ text: 'Got it!' }]
    );
  }

  async cancelAllNotifications() {
    if (!this.db) return;

    try {
      await this.db.executeSql(
        `UPDATE notifications SET enabled = 0`
      );
      console.log('All notifications canceled');
    } catch (error) {
      console.error('Error canceling all notifications:', error);
    }
  }

  async requestPermissions(): Promise<boolean> {
    // Since we're using Alert API, no special permissions needed
    // This method is kept for API compatibility
    return Promise.resolve(true);
  }

  // Get all scheduled notifications (for debugging/UI)
  async getScheduledNotifications(): Promise<NotificationSchedule[]> {
    if (!this.db) return [];

    try {
      const [result] = await this.db.executeSql(
        `SELECT * FROM notifications WHERE enabled = 1 ORDER BY scheduled_time ASC`
      );

      const notifications: NotificationSchedule[] = [];
      for (let i = 0; i < result.rows.length; i++) {
        const row = result.rows.item(i);
        notifications.push({
          id: row.id,
          type: row.type,
          title: row.title,
          message: row.message,
          scheduledTime: new Date(row.scheduled_time),
          recurring: row.recurring === 1,
          recurringPattern: row.recurring_pattern,
          enabled: row.enabled === 1,
          lastShown: row.last_shown ? new Date(row.last_shown) : undefined,
        });
      }

      return notifications;
    } catch (error) {
      console.error('Error getting scheduled notifications:', error);
      return [];
    }
  }

  // Cleanup
  destroy() {
    if (this.checkInterval) {
      clearInterval(this.checkInterval);
      this.checkInterval = null;
    }
  }
}

export default new SQLiteNotificationService();
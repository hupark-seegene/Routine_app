// Dummy NotificationService - 알림 기능 일시 비활성화
// React Native 0.80.1과 react-native-push-notification 8.1.1 호환성 문제로 인해 임시 조치

class NotificationService {
  constructor() {
    console.log('NotificationService: Dummy implementation loaded');
  }
  
  // Public initialization method
  public async init(): Promise<void> {
    console.log('NotificationService: init() called (dummy)');
    return Promise.resolve();
  }

  // 일일 운동 알림 설정
  async scheduleWorkoutReminder(time: string, enabled: boolean) {
    console.log(`NotificationService: scheduleWorkoutReminder(${time}, ${enabled}) called (dummy)`);
  }

  cancelWorkoutReminder() {
    console.log('NotificationService: cancelWorkoutReminder() called (dummy)');
  }

  // 운동 미수행 알림
  scheduleMissedWorkoutReminder(enabled: boolean) {
    console.log(`NotificationService: scheduleMissedWorkoutReminder(${enabled}) called (dummy)`);
  }

  cancelMissedWorkoutReminder() {
    console.log('NotificationService: cancelMissedWorkoutReminder() called (dummy)');
  }

  // 주간 리포트 알림
  scheduleWeeklyReport(enabled: boolean) {
    console.log(`NotificationService: scheduleWeeklyReport(${enabled}) called (dummy)`);
  }

  cancelWeeklyReport() {
    console.log('NotificationService: cancelWeeklyReport() called (dummy)');
  }

  // 즉시 알림 (테스트용)
  showTestNotification() {
    console.log('NotificationService: showTestNotification() called (dummy)');
  }

  // 운동 완료 축하 알림
  showWorkoutCompleteNotification(workoutType: string) {
    console.log(`NotificationService: showWorkoutCompleteNotification(${workoutType}) called (dummy)`);
  }

  // 연속 운동 기록 알림
  showStreakNotification(days: number) {
    console.log(`NotificationService: showStreakNotification(${days}) called (dummy)`);
  }

  // 프로그램 단계 변경 알림
  showPhaseChangeNotification(newPhase: string) {
    console.log(`NotificationService: showPhaseChangeNotification(${newPhase}) called (dummy)`);
  }

  // 모든 알림 취소
  cancelAllNotifications() {
    console.log('NotificationService: cancelAllNotifications() called (dummy)');
  }

  // 알림 권한 요청
  async requestPermissions() {
    console.log('NotificationService: requestPermissions() called (dummy)');
    // 더미 구현이므로 항상 true 반환
    return Promise.resolve(true);
  }
}

export default new NotificationService();
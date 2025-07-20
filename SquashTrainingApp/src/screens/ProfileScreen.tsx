import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  SafeAreaView,
  Switch,
  Alert,
  ActivityIndicator,
  RefreshControl,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useNavigation, CompositeNavigationProp, useFocusEffect } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { RootStackParamList, MainTabParamList } from '../navigation/AppNavigator';
import { useAuth } from './auth/AuthContext';
import { Colors, DarkTheme, Typography, Spacing, BorderRadius } from '../styles';
import databaseService from '../services/databaseService';
import RNFS from 'react-native-fs';
import { ProfileQueries, Achievement } from '../database/ProfileQueries';
import AchievementCard from '../components/AchievementCard';

type ProfileScreenNavigationProp = CompositeNavigationProp<
  BottomTabNavigationProp<MainTabParamList, 'Profile'>,
  StackNavigationProp<RootStackParamList>
>;

const ProfileScreen = () => {
  const navigation = useNavigation<ProfileScreenNavigationProp>();
  const { isDeveloper, isDevModeEnabled, logout } = useAuth();
  const [reminderEnabled, setReminderEnabled] = useState(true);
  const [missedWorkoutReminder, setMissedWorkoutReminder] = useState(true);
  const [weeklyReport, setWeeklyReport] = useState(true);
  const [reminderTime, setReminderTime] = useState('08:00');
  const [devModeClickCount, setDevModeClickCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [userStats, setUserStats] = useState({
    totalWorkouts: 0,
    totalHours: 0,
    currentStreak: 0,
    longestStreak: 0,
    completionRate: 0,
    level: '중급',
  });
  const [userProfile, setUserProfile] = useState<any>(null);
  const [achievements, setAchievements] = useState<Achievement[]>([]);

  useEffect(() => {
    loadUserData();
  }, []);

  useFocusEffect(
    React.useCallback(() => {
      loadUserData();
    }, [])
  );

  const loadUserData = async () => {
    try {
      setLoading(true);
      
      // Get user profile
      const profile = await databaseService.getUserProfile();
      if (profile) {
        setUserProfile(profile);
      }
      
      // Get comprehensive stats using ProfileQueries
      const stats = await ProfileQueries.getUserStats(1);
      setUserStats(stats);
      
      // Get achievements
      const userAchievements = await ProfileQueries.getAchievements(1);
      setAchievements(userAchievements);
      
    } catch (error) {
      console.error('Error loading user data:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const calculateCurrentStreak = (workouts: any[]): number => {
    if (!workouts || workouts.length === 0) return 0;
    
    let streak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    for (let i = 0; i < 30; i++) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      
      const hasWorkout = workouts.some(w => 
        w.date === dateStr && w.completed
      );
      
      if (hasWorkout) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    
    return streak;
  };

  const calculateLongestStreak = (workouts: any[]): number => {
    if (!workouts || workouts.length === 0) return 0;
    
    // Sort workouts by date
    const sortedWorkouts = [...workouts].sort((a, b) => 
      new Date(a.date).getTime() - new Date(b.date).getTime()
    );
    
    let maxStreak = 0;
    let currentStreak = 0;
    let lastDate: Date | null = null;
    
    sortedWorkouts.forEach(workout => {
      if (!workout.completed) return;
      
      const workoutDate = new Date(workout.date);
      
      if (!lastDate) {
        currentStreak = 1;
      } else {
        const dayDiff = Math.floor(
          (workoutDate.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24)
        );
        
        if (dayDiff === 1) {
          currentStreak++;
        } else {
          maxStreak = Math.max(maxStreak, currentStreak);
          currentStreak = 1;
        }
      }
      
      lastDate = workoutDate;
    });
    
    return Math.max(maxStreak, currentStreak);
  };

  const onRefresh = () => {
    setRefreshing(true);
    loadUserData();
  };

  const handleLevelChange = () => {
    Alert.alert(
      '레벨 변경',
      '현재 중급에서 상급으로 가는 과정입니다. 계속 열심히 하세요!',
      [{ text: '확인' }]
    );
  };

  const handleTimeChange = () => {
    Alert.alert(
      '알림 시간 설정',
      '운동 알림을 받을 시간을 선택하세요',
      [
        { text: '07:00', onPress: () => setReminderTime('07:00') },
        { text: '08:00', onPress: () => setReminderTime('08:00') },
        { text: '18:00', onPress: () => setReminderTime('18:00') },
        { text: '19:00', onPress: () => setReminderTime('19:00') },
        { text: '취소', style: 'cancel' },
      ]
    );
  };

  const handleExportData = async () => {
    Alert.alert(
      '데이터 내보내기',
      '운동 기록을 CSV 파일로 내보내시겠습니까?',
      [
        { text: '취소', style: 'cancel' },
        { 
          text: '내보내기', 
          onPress: async () => {
            try {
              // Get all workout logs
              const workouts = await databaseService.getWorkoutLogs(1, 1000);
              const analytics = await databaseService.getAnalytics(1, 365);
              
              // Create CSV content
              let csv = 'Date,Exercise,Completed,Duration,Intensity,Condition,Fatigue\n';
              
              workouts.forEach(workout => {
                csv += `${workout.date},${workout.exercise_name || 'N/A'},${workout.completed ? 'Yes' : 'No'},`;
                csv += `${workout.duration_minutes || 0},${workout.intensity_level || 0},`;
                csv += `${workout.condition_score || 0},${workout.fatigue_level || 0}\n`;
              });
              
              // Save to file
              const fileName = `workout_export_${new Date().toISOString().split('T')[0]}.csv`;
              const path = `${RNFS.DocumentDirectoryPath}/${fileName}`;
              
              await RNFS.writeFile(path, csv, 'utf8');
              
              Alert.alert(
                '성공', 
                `데이터가 ${fileName}으로 내보내졌습니다.\n\n경로: ${path}`,
                [
                  { text: '확인' },
                  { 
                    text: '공유', 
                    onPress: () => {
                      // In production, use Share API
                      Alert.alert('공유', 'Share API would be used here');
                    }
                  }
                ]
              );
            } catch (error) {
              console.error('Export error:', error);
              Alert.alert('오류', '데이터 내보내기에 실패했습니다.');
            }
          }
        },
      ]
    );
  };

  const handleResetProgress = () => {
    Alert.alert(
      '진행 상황 초기화',
      '정말로 모든 진행 상황을 초기화하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
      [
        { text: '취소', style: 'cancel' },
        { 
          text: '초기화', 
          style: 'destructive', 
          onPress: async () => {
            try {
              // Create backup before reset
              const backupPath = await databaseService.createBackup('before_reset');
              
              Alert.alert(
                '백업 생성됨',
                '초기화 전 백업이 생성되었습니다. 계속하시겠습니까?',
                [
                  { text: '취소', style: 'cancel' },
                  {
                    text: '계속',
                    style: 'destructive',
                    onPress: async () => {
                      // Reset would be implemented here
                      // For now, just show completion
                      Alert.alert('완료', `백업 위치: ${backupPath}\n\n초기화 기능은 안전을 위해 수동으로 수행해주세요.`);
                      loadUserData();
                    }
                  }
                ]
              );
            } catch (error) {
              Alert.alert('오류', '백업 생성에 실패했습니다.');
            }
          }
        },
      ]
    );
  };

  const handleAppVersionClick = () => {
    if (!isDevModeEnabled) return;
    
    setDevModeClickCount(prev => prev + 1);
    if (devModeClickCount >= 4) {
      if (isDeveloper) {
        Alert.alert('Developer Mode', 'You are already in developer mode.', [
          { text: 'Log Out', onPress: () => logout() },
          { text: 'OK', style: 'cancel' },
        ]);
      } else {
        navigation.navigate('DevLogin');
      }
      setDevModeClickCount(0);
    }
  };

  if (loading && !refreshing) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={Colors.accentVolt} />
          <Text style={styles.loadingText}>데이터 로딩 중...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView 
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        {/* User Info Section */}
        <View style={styles.userSection}>
          <View style={styles.userIcon}>
            <Icon name="person" size={50} color="#4CAF50" />
          </View>
          <Text style={styles.userName}>{userProfile?.name || '스쿼시 플레이어'}</Text>
          <TouchableOpacity style={styles.levelBadge} onPress={handleLevelChange}>
            <Text style={styles.levelText}>{userStats.level} → 상급</Text>
          </TouchableOpacity>
        </View>

        {/* Stats Grid */}
        <View style={styles.statsSection}>
          <Text style={styles.sectionTitle}>나의 기록</Text>
          <View style={styles.statsGrid}>
            <View style={styles.statItem}>
              <Icon name="fitness-center" size={24} color="#4CAF50" />
              <Text style={styles.statNumber}>{userStats.totalWorkouts}</Text>
              <Text style={styles.statLabel}>총 운동 횟수</Text>
            </View>
            <View style={styles.statItem}>
              <Icon name="timer" size={24} color="#FF6B6B" />
              <Text style={styles.statNumber}>{userStats.totalHours}시간</Text>
              <Text style={styles.statLabel}>총 운동 시간</Text>
            </View>
            <View style={styles.statItem}>
              <Icon name="local-fire-department" size={24} color="#FF9800" />
              <Text style={styles.statNumber}>{userStats.currentStreak}일</Text>
              <Text style={styles.statLabel}>연속 운동</Text>
            </View>
            <View style={styles.statItem}>
              <Icon name="trending-up" size={24} color="#4ECDC4" />
              <Text style={styles.statNumber}>{userStats.completionRate}%</Text>
              <Text style={styles.statLabel}>완료율</Text>
            </View>
          </View>
        </View>

        {/* Achievement Section */}
        <View style={styles.achievementSection}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>성취 배지</Text>
            <Text style={styles.achievementCount}>
              {achievements.filter(a => a.unlockedAt !== null).length}/{achievements.length}
            </Text>
          </View>
          {achievements.length > 0 ? (
            achievements.map((achievement) => (
              <AchievementCard 
                key={achievement.id}
                achievement={achievement}
                onPress={() => {
                  Alert.alert(
                    achievement.name,
                    `${achievement.description}\n\n진행도: ${achievement.progress}/${achievement.requirement}`,
                    [{ text: '확인' }]
                  );
                }}
              />
            ))
          ) : (
            <Text style={styles.noAchievements}>업적을 로드하고 있습니다...</Text>
          )}
        </View>

        {/* Settings Section */}
        <View style={styles.settingsSection}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>알림 설정</Text>
            <TouchableOpacity
              style={styles.settingsButton}
              onPress={() => navigation.navigate('Settings')}
            >
              <Icon name="settings" size={20} color={Colors.accentVolt} />
              <Text style={styles.settingsButtonText}>모든 설정</Text>
            </TouchableOpacity>
          </View>
          
          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Icon name="notifications" size={24} color="#666" />
              <Text style={styles.settingLabel}>운동 알림</Text>
            </View>
            <Switch
              value={reminderEnabled}
              onValueChange={setReminderEnabled}
              trackColor={{ false: '#e0e0e0', true: '#81C784' }}
              thumbColor={reminderEnabled ? '#4CAF50' : '#f4f3f4'}
            />
          </View>

          {reminderEnabled && (
            <TouchableOpacity style={styles.settingItem} onPress={handleTimeChange}>
              <View style={styles.settingInfo}>
                <Icon name="access-time" size={24} color="#666" />
                <Text style={styles.settingLabel}>알림 시간</Text>
              </View>
              <View style={styles.settingValue}>
                <Text style={styles.settingValueText}>{reminderTime}</Text>
                <Icon name="chevron-right" size={24} color="#999" />
              </View>
            </TouchableOpacity>
          )}

          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Icon name="warning" size={24} color="#666" />
              <Text style={styles.settingLabel}>운동 미수행 알림</Text>
            </View>
            <Switch
              value={missedWorkoutReminder}
              onValueChange={setMissedWorkoutReminder}
              trackColor={{ false: '#e0e0e0', true: '#81C784' }}
              thumbColor={missedWorkoutReminder ? '#4CAF50' : '#f4f3f4'}
            />
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Icon name="assessment" size={24} color="#666" />
              <Text style={styles.settingLabel}>주간 리포트</Text>
            </View>
            <Switch
              value={weeklyReport}
              onValueChange={setWeeklyReport}
              trackColor={{ false: '#e0e0e0', true: '#81C784' }}
              thumbColor={weeklyReport ? '#4CAF50' : '#f4f3f4'}
            />
          </View>
        </View>

        {/* Actions Section */}
        <View style={styles.actionsSection}>
          <TouchableOpacity style={styles.actionButton} onPress={handleExportData}>
            <Icon name="file-download" size={24} color="#4CAF50" />
            <Text style={styles.actionButtonText}>데이터 내보내기</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.actionButton, styles.dangerButton]} onPress={handleResetProgress}>
            <Icon name="refresh" size={24} color="#F44336" />
            <Text style={[styles.actionButtonText, { color: '#F44336' }]}>진행 상황 초기화</Text>
          </TouchableOpacity>
        </View>

        {/* Developer Mode Section (if enabled) */}
        {isDeveloper && (
          <View style={styles.developerSection}>
            <View style={styles.developerBadge}>
              <Icon name="code" size={20} color={Colors.accentVolt} />
              <Text style={styles.developerText}>Developer Mode Active</Text>
            </View>
            <TouchableOpacity style={styles.developerButton} onPress={() => logout()}>
              <Text style={styles.developerButtonText}>Log Out</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* App Info */}
        <TouchableOpacity 
          style={styles.appInfo} 
          onPress={handleAppVersionClick}
          activeOpacity={isDevModeEnabled ? 0.7 : 1}
        >
          <Text style={styles.appVersion}>버전 1.0.0</Text>
          <Text style={styles.appCopyright}>© 2024 Squash Training App</Text>
          {isDevModeEnabled && devModeClickCount > 0 && (
            <Text style={styles.devHint}>{5 - devModeClickCount} more taps...</Text>
          )}
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  userSection: {
    backgroundColor: '#fff',
    alignItems: 'center',
    paddingVertical: 30,
  },
  userIcon: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#e8f5e9',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
  },
  userName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  levelBadge: {
    backgroundColor: '#4CAF50',
    paddingHorizontal: 20,
    paddingVertical: 8,
    borderRadius: 20,
  },
  levelText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  statsSection: {
    backgroundColor: '#fff',
    marginTop: 10,
    padding: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  statItem: {
    width: '48%',
    backgroundColor: '#f8f8f8',
    borderRadius: 10,
    padding: 15,
    alignItems: 'center',
    marginBottom: 10,
  },
  statNumber: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginTop: 8,
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  achievementSection: {
    backgroundColor: '#f5f5f5',
    marginTop: 10,
    padding: 20,
  },
  achievementCount: {
    fontSize: 16,
    color: '#4CAF50',
    fontWeight: '600',
  },
  noAchievements: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
    marginTop: 20,
  },
  badgeGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  badge: {
    alignItems: 'center',
  },
  badgeIcon: {
    width: 50,
    height: 50,
    borderRadius: 25,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  badgeLabel: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
  },
  lockedBadge: {
    opacity: 0.5,
  },
  settingsSection: {
    backgroundColor: '#fff',
    marginTop: 10,
    padding: 20,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  settingsButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: Colors.backgroundLight,
  },
  settingsButtonText: {
    fontSize: 14,
    color: Colors.accentVolt,
    fontWeight: '600',
  },
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  settingInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingLabel: {
    fontSize: 16,
    color: '#333',
    marginLeft: 15,
  },
  settingValue: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingValueText: {
    fontSize: 16,
    color: '#666',
    marginRight: 5,
  },
  actionsSection: {
    backgroundColor: '#fff',
    marginTop: 10,
    padding: 20,
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 15,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#4CAF50',
    marginBottom: 10,
  },
  actionButtonText: {
    fontSize: 16,
    color: '#4CAF50',
    fontWeight: '600',
    marginLeft: 10,
  },
  dangerButton: {
    borderColor: '#F44336',
  },
  appInfo: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  appVersion: {
    fontSize: 14,
    color: '#999',
  },
  appCopyright: {
    fontSize: 12,
    color: '#999',
    marginTop: 5,
  },
  developerSection: {
    backgroundColor: DarkTheme.surface,
    margin: 20,
    padding: 20,
    borderRadius: BorderRadius.lg,
    borderWidth: 2,
    borderColor: Colors.accentVolt,
  },
  developerBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: Spacing.md,
  },
  developerText: {
    marginLeft: Spacing.sm,
    fontSize: 16,
    fontWeight: '600',
    color: Colors.accentVolt,
  },
  developerButton: {
    backgroundColor: Colors.accentVolt,
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.lg,
    borderRadius: BorderRadius.full,
    alignItems: 'center',
  },
  developerButtonText: {
    color: Colors.primaryBlack,
    fontWeight: '600',
  },
  devHint: {
    fontSize: 10,
    color: Colors.accentVolt,
    marginTop: 5,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#666',
  },
});

export default ProfileScreen;
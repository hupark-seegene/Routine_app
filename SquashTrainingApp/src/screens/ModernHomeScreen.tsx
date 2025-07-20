import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  StatusBar,
  RefreshControl,
  Alert,
  Animated,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import { useNavigation, CompositeNavigationProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import LinearGradient from 'react-native-linear-gradient';
import MaterialCommunityIcons from 'react-native-vector-icons/MaterialCommunityIcons';
import { RootStackParamList, MainTabParamList } from '../navigation/AppNavigator';
import { useAuth } from './auth/AuthContext';
import aiApi from '../services/api/aiApi';
import DatabaseService from '../services/DatabaseService';
import { WorkoutLog, TrainingProgram } from '../types';

// Components
import ModernHeroCard from '../components/home/ModernHeroCard';
import AICoachFAB from '../components/common/AICoachFAB';
import { LoadingState } from '../components/common';

// Styles
import {
  Colors,
  ModernTypography,
  ModernSpacing,
  BorderRadius,
  Shadows,
  Gradients,
  Glass,
  CardStyles,
  Animations,
} from '../styles';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

type HomeScreenNavigationProp = CompositeNavigationProp<
  BottomTabNavigationProp<MainTabParamList, 'Home'>,
  StackNavigationProp<RootStackParamList>
>;

const ModernHomeScreen = () => {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const { isDeveloper, developerApiKey } = useAuth();
  const [refreshing, setRefreshing] = useState(false);
  const [streak, setStreak] = useState(0);
  const [loading, setLoading] = useState(true);
  const scrollY = useRef(new Animated.Value(0)).current;
  const fadeAnim = useRef(new Animated.Value(0)).current;
  
  const [stats, setStats] = useState({
    totalWorkouts: 0,
    totalMinutes: 0,
    averageIntensity: 0,
    averageCondition: 0,
    completionRate: 0,
  });
  
  const [activeProgram, setActiveProgram] = useState<TrainingProgram | null>(null);
  const [todayWorkout, setTodayWorkout] = useState<any>(null);
  const [workouts, setWorkouts] = useState([
    {
      id: '1',
      icon: 'tennis',
      name: 'Technical Drills',
      details: 'Forehand • Backhand • Boast',
      duration: '45 min',
      completed: false,
      category: 'skill',
    },
    {
      id: '2',
      icon: 'dumbbell',
      name: 'Strength Training',
      details: 'Core • Legs • Upper Body',
      duration: '30 min',
      completed: false,
      category: 'strength',
    },
    {
      id: '3',
      icon: 'run-fast',
      name: 'HIIT Cardio',
      details: 'Intervals • Agility • Speed',
      duration: '20 min',
      completed: true,
      category: 'cardio',
    },
  ]);

  useEffect(() => {
    loadData();
    // Fade in animation
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 800,
      useNativeDriver: true,
    }).start();
  }, []);

  useEffect(() => {
    if (isDeveloper && developerApiKey) {
      aiApi.setDeveloperApiKey(developerApiKey);
    }
  }, [isDeveloper, developerApiKey]);

  const loadData = async () => {
    try {
      setLoading(true);
      await DatabaseService.init();
      
      const profile = await DatabaseService.getUserProfile();
      const userId = profile?.id || 1;
      
      const statistics = await DatabaseService.getTrainingStats(userId, 30);
      setStats(statistics);
      
      const weekStats = await DatabaseService.getWeeklyStats(userId);
      let currentStreak = 0;
      const today = new Date();
      for (let i = 0; i < 7; i++) {
        const checkDate = new Date(today);
        checkDate.setDate(today.getDate() - i);
        const dateStr = checkDate.toISOString().split('T')[0];
        if (weekStats.find(stat => stat.day === dateStr && stat.workouts > 0)) {
          currentStreak++;
        } else if (i > 0) {
          break;
        }
      }
      setStreak(currentStreak);
      
      const program = await DatabaseService.getActiveProgram();
      setActiveProgram(program);
      
      const workout = await DatabaseService.getTodayWorkout(userId);
      setTodayWorkout(workout);
      
      if (workout && workout.exercises) {
        const transformedWorkouts = workout.exercises.map((exercise, index) => ({
          id: String(exercise.id || index),
          icon: exercise.category === 'skill' ? 'tennis' : 
                exercise.category === 'fitness' ? 'dumbbell' : 'run-fast',
          name: exercise.name,
          details: exercise.instructions || '',
          duration: exercise.duration ? `${exercise.duration} min` : 
                   exercise.sets ? `${exercise.sets}x${exercise.reps}` : '30 min',
          completed: false,
          category: exercise.category || 'fitness',
        }));
        setWorkouts(transformedWorkouts);
      }
      
    } catch (error) {
      console.error('Error loading data:', error);
      Alert.alert('오류', '데이터를 불러오는데 실패했습니다.');
    } finally {
      setLoading(false);
    }
  };

  const getTodayDate = () => {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 
                    'July', 'August', 'September', 'October', 'November', 'December'];
    const today = new Date();
    return `${days[today.getDay()]}, ${months[today.getMonth()]} ${today.getDate()}`;
  };

  const handleStartWorkout = () => {
    Alert.alert('Start Workout', 'Ready to begin your Power & Precision training?', [
      { text: 'Not Yet', style: 'cancel' },
      { text: "Let's Go!", onPress: () => console.log('Starting workout...') },
    ]);
  };

  const handleWorkoutPress = (workoutId: string) => {
    const updatedWorkouts = workouts.map(w => 
      w.id === workoutId ? { ...w, completed: !w.completed } : w
    );
    setWorkouts(updatedWorkouts);
  };

  const handleAICoachPress = () => {
    navigation.navigate('Coach');
  };

  const calculateProgress = () => {
    const completed = workouts.filter(w => w.completed).length;
    return Math.round((completed / workouts.length) * 100);
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const headerOpacity = scrollY.interpolate({
    inputRange: [0, 100],
    outputRange: [0, 1],
    extrapolate: 'clamp',
  });

  const headerTranslateY = scrollY.interpolate({
    inputRange: [0, 100],
    outputRange: [-50, 0],
    extrapolate: 'clamp',
  });

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <LoadingState />
      </SafeAreaView>
    );
  }

  return (
    <>
      <StatusBar barStyle="light-content" backgroundColor={Colors.background} />
      <SafeAreaView style={styles.container}>
        {/* Animated Header */}
        <Animated.View
          style={[
            styles.header,
            {
              opacity: headerOpacity,
              transform: [{ translateY: headerTranslateY }],
            },
          ]}
        >
          <LinearGradient
            colors={[Colors.backgroundElevated, 'transparent']}
            style={styles.headerGradient}
          >
            <Text style={styles.headerTitle}>Squash Master</Text>
          </LinearGradient>
        </Animated.View>

        <Animated.ScrollView
          showsVerticalScrollIndicator={false}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              tintColor={Colors.primary}
              colors={[Colors.primary]}
            />
          }
          contentContainerStyle={styles.scrollContent}
          onScroll={Animated.event(
            [{ nativeEvent: { contentOffset: { y: scrollY } } }],
            { useNativeDriver: true }
          )}
          scrollEventThrottle={16}
          style={{ opacity: fadeAnim }}
        >
          {/* Welcome Section */}
          <View style={styles.welcomeSection}>
            <Text style={styles.welcomeText}>Welcome back,</Text>
            <Text style={styles.userName}>Champion 🏆</Text>
            <View style={styles.streakBadge}>
              <LinearGradient
                colors={[Colors.accent, Colors.accentDark]}
                style={styles.streakGradient}
              >
                <MaterialCommunityIcons name="fire" size={20} color={Colors.white} />
                <Text style={styles.streakText}>{streak} Day Streak</Text>
              </LinearGradient>
            </View>
          </View>

          {/* Hero Card */}
          <ModernHeroCard
            date={getTodayDate()}
            title={activeProgram?.name || "Start Your Journey"}
            subtitle={activeProgram ? `Week ${activeProgram.current_week}` : "Choose a training program"}
            onPress={handleStartWorkout}
            progress={calculateProgress()}
          />

          {/* Quick Stats Grid */}
          <View style={styles.statsGrid}>
            {[
              { 
                icon: 'lightning-bolt', 
                value: stats.averageIntensity.toFixed(1), 
                label: 'Intensity',
                color: Colors.primary,
              },
              { 
                icon: 'chart-line', 
                value: `${Math.round(stats.completionRate)}%`, 
                label: 'Consistency',
                color: Colors.accent,
              },
              { 
                icon: 'dumbbell', 
                value: `${stats.totalWorkouts}`, 
                label: 'Workouts',
                color: Colors.success,
              },
              { 
                icon: 'timer', 
                value: `${Math.round(stats.totalMinutes / 60)}h`, 
                label: 'Total Time',
                color: Colors.warning,
              },
            ].map((stat, index) => (
              <TouchableOpacity
                key={index}
                style={styles.statCard}
                activeOpacity={0.8}
              >
                <LinearGradient
                  colors={[`${stat.color}20`, `${stat.color}10`]}
                  style={styles.statGradient}
                >
                  <MaterialCommunityIcons
                    name={stat.icon}
                    size={24}
                    color={stat.color}
                    style={styles.statIcon}
                  />
                  <Text style={styles.statValue}>{stat.value}</Text>
                  <Text style={styles.statLabel}>{stat.label}</Text>
                </LinearGradient>
              </TouchableOpacity>
            ))}
          </View>

          {/* Today's Training */}
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <Text style={styles.sectionTitle}>Today's Training</Text>
              <TouchableOpacity>
                <Text style={styles.seeAll}>See All</Text>
              </TouchableOpacity>
            </View>
            
            {workouts.map((workout, index) => (
              <Animated.View
                key={workout.id}
                style={[
                  styles.workoutCard,
                  {
                    opacity: fadeAnim,
                    transform: [
                      {
                        translateY: fadeAnim.interpolate({
                          inputRange: [0, 1],
                          outputRange: [50, 0],
                        }),
                      },
                    ],
                  },
                ]}
              >
                <TouchableOpacity
                  onPress={() => handleWorkoutPress(workout.id)}
                  activeOpacity={0.9}
                >
                  <View style={[
                    styles.workoutCardContent,
                    Glass.card,
                    workout.completed && styles.workoutCompleted,
                  ]}>
                    <View style={[
                      styles.workoutIconContainer,
                      { backgroundColor: `${Colors[workout.category]}20` },
                    ]}>
                      <MaterialCommunityIcons
                        name={workout.icon}
                        size={24}
                        color={Colors[workout.category]}
                      />
                    </View>
                    <View style={styles.workoutInfo}>
                      <Text style={[
                        styles.workoutName,
                        workout.completed && styles.workoutTextCompleted,
                      ]}>
                        {workout.name}
                      </Text>
                      <Text style={styles.workoutDetails}>{workout.details}</Text>
                    </View>
                    <View style={styles.workoutRight}>
                      <Text style={styles.workoutDuration}>{workout.duration}</Text>
                      {workout.completed && (
                        <MaterialCommunityIcons
                          name="check-circle"
                          size={24}
                          color={Colors.success}
                        />
                      )}
                    </View>
                  </View>
                </TouchableOpacity>
              </Animated.View>
            ))}
          </View>

          {/* Achievements Section */}
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <Text style={styles.sectionTitle}>Recent Achievements</Text>
              <TouchableOpacity>
                <Text style={styles.seeAll}>View All</Text>
              </TouchableOpacity>
            </View>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.achievementsScroll}
            >
              {[
                { icon: '🏆', title: 'Week Warrior', desc: '7 days streak', unlocked: true },
                { icon: '⚡', title: 'Speed Demon', desc: 'Sub 0.4s reaction', unlocked: true },
                { icon: '🎯', title: 'Precision Pro', desc: '90% accuracy', unlocked: false },
                { icon: '🔥', title: 'On Fire', desc: '30 days streak', unlocked: false },
              ].map((achievement, index) => (
                <View
                  key={index}
                  style={[
                    styles.achievementCard,
                    !achievement.unlocked && styles.achievementLocked,
                  ]}
                >
                  <Text style={styles.achievementIcon}>{achievement.icon}</Text>
                  <Text style={styles.achievementTitle}>{achievement.title}</Text>
                  <Text style={styles.achievementDesc}>{achievement.desc}</Text>
                  {!achievement.unlocked && (
                    <View style={styles.lockedOverlay}>
                      <MaterialCommunityIcons name="lock" size={20} color={Colors.textMuted} />
                    </View>
                  )}
                </View>
              ))}
            </ScrollView>
          </View>

          {/* Bottom spacing */}
          <View style={{ height: 100 }} />
        </Animated.ScrollView>

        {/* AI Coach FAB */}
        <AICoachFAB onPress={handleAICoachPress} />
      </SafeAreaView>
    </>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  header: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 1000,
    height: 80,
  },
  headerGradient: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: ModernSpacing.lg,
    paddingTop: 40,
  },
  headerTitle: {
    ...ModernTypography.h2,
    color: Colors.text,
    fontWeight: '700',
  },
  scrollContent: {
    paddingBottom: ModernSpacing.xl,
  },
  welcomeSection: {
    paddingHorizontal: ModernSpacing.lg,
    paddingTop: ModernSpacing.xl,
    marginBottom: ModernSpacing.lg,
  },
  welcomeText: {
    ...ModernTypography.body,
    color: Colors.textSecondary,
  },
  userName: {
    ...ModernTypography.h1,
    color: Colors.text,
    marginBottom: ModernSpacing.md,
  },
  streakBadge: {
    alignSelf: 'flex-start',
  },
  streakGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: ModernSpacing.md,
    paddingVertical: ModernSpacing.sm,
    borderRadius: BorderRadius.round,
    gap: ModernSpacing.xs,
  },
  streakText: {
    ...ModernTypography.label,
    color: Colors.white,
    fontWeight: '600',
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: ModernSpacing.lg,
    marginBottom: ModernSpacing.xl,
    gap: ModernSpacing.md,
  },
  statCard: {
    flex: 1,
    minWidth: (SCREEN_WIDTH - ModernSpacing.lg * 2 - ModernSpacing.md) / 2 - 1,
  },
  statGradient: {
    borderRadius: BorderRadius.lg,
    padding: ModernSpacing.lg,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Colors.borderGlass,
  },
  statIcon: {
    marginBottom: ModernSpacing.sm,
  },
  statValue: {
    ...ModernTypography.h2,
    color: Colors.text,
    marginBottom: ModernSpacing.xs,
  },
  statLabel: {
    ...ModernTypography.caption,
    color: Colors.textSecondary,
  },
  section: {
    paddingHorizontal: ModernSpacing.lg,
    marginBottom: ModernSpacing.xl,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: ModernSpacing.lg,
  },
  sectionTitle: {
    ...ModernTypography.h3,
    color: Colors.text,
  },
  seeAll: {
    ...ModernTypography.bodySmall,
    color: Colors.primary,
    fontWeight: '600',
  },
  workoutCard: {
    marginBottom: ModernSpacing.md,
  },
  workoutCardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: ModernSpacing.lg,
    borderRadius: BorderRadius.lg,
  },
  workoutCompleted: {
    opacity: 0.7,
  },
  workoutIconContainer: {
    width: 48,
    height: 48,
    borderRadius: BorderRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: ModernSpacing.md,
  },
  workoutInfo: {
    flex: 1,
  },
  workoutName: {
    ...ModernTypography.body,
    color: Colors.text,
    fontWeight: '600',
    marginBottom: ModernSpacing.xs,
  },
  workoutTextCompleted: {
    textDecorationLine: 'line-through',
    color: Colors.textMuted,
  },
  workoutDetails: {
    ...ModernTypography.caption,
    color: Colors.textSecondary,
  },
  workoutRight: {
    alignItems: 'flex-end',
    gap: ModernSpacing.sm,
  },
  workoutDuration: {
    ...ModernTypography.caption,
    color: Colors.textMuted,
  },
  achievementsScroll: {
    paddingRight: ModernSpacing.lg,
    gap: ModernSpacing.md,
  },
  achievementCard: {
    backgroundColor: Colors.backgroundCard,
    borderRadius: BorderRadius.lg,
    padding: ModernSpacing.lg,
    width: 140,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Colors.border,
  },
  achievementLocked: {
    opacity: 0.5,
  },
  achievementIcon: {
    fontSize: 32,
    marginBottom: ModernSpacing.sm,
  },
  achievementTitle: {
    ...ModernTypography.label,
    color: Colors.text,
    fontWeight: '600',
    marginBottom: ModernSpacing.xs,
    textAlign: 'center',
  },
  achievementDesc: {
    ...ModernTypography.caption,
    color: Colors.textSecondary,
    textAlign: 'center',
  },
  lockedOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.5)',
    borderRadius: BorderRadius.lg,
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default ModernHomeScreen;
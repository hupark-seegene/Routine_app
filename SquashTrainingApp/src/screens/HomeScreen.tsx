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
} from 'react-native';
import { useNavigation, CompositeNavigationProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { RootStackParamList, MainTabParamList } from '../navigation/AppNavigator';
import { useAuth } from './auth/AuthContext';
import aiApi from '../services/api/aiApi';
import DatabaseService from '../services/DatabaseService';
import { WorkoutLog, TrainingProgram } from '../types';

// Components
import HeroCard from '../components/home/HeroCard';
import QuickStats from '../components/home/QuickStats';
import WorkoutCard from '../components/home/WorkoutCard';
import ProgressRing from '../components/home/ProgressRing';
import AchievementScroll from '../components/home/AchievementScroll';
import AICoachFAB from '../components/common/AICoachFAB';

// Styles
import {
  Colors,
  DarkTheme,
  Typography,
  Spacing,
  GlobalStyles,
} from '../styles';
import { LoadingState } from '../components/common';

type HomeScreenNavigationProp = CompositeNavigationProp<
  BottomTabNavigationProp<MainTabParamList, 'Home'>,
  StackNavigationProp<RootStackParamList>
>;

const HomeScreen = () => {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const { isDeveloper, developerApiKey } = useAuth();
  const [refreshing, setRefreshing] = useState(false);
  const [streak, setStreak] = useState(0);
  const [loading, setLoading] = useState(true);
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
    },
    {
      id: '2',
      icon: 'dumbbell',
      name: 'Strength Training',
      details: 'Core • Legs • Upper Body',
      duration: '30 min',
      completed: false,
    },
    {
      id: '3',
      icon: 'run-fast',
      name: 'HIIT Cardio',
      details: 'Intervals • Agility • Speed',
      duration: '20 min',
      completed: true,
    },
  ]);

  // Load data on mount
  useEffect(() => {
    loadData();
  }, []);

  // Set developer API key when available
  useEffect(() => {
    if (isDeveloper && developerApiKey) {
      aiApi.setDeveloperApiKey(developerApiKey);
    }
  }, [isDeveloper, developerApiKey]);

  const loadData = async () => {
    try {
      setLoading(true);
      await DatabaseService.init();
      
      // Get user profile
      const profile = await DatabaseService.getUserProfile();
      const userId = profile?.id || 1;
      
      // Get statistics
      const statistics = await DatabaseService.getTrainingStats(userId, 30);
      setStats(statistics);
      
      // Calculate streak
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
      
      // Get active program
      const program = await DatabaseService.getActiveProgram();
      setActiveProgram(program);
      
      // Get today's workout
      const workout = await DatabaseService.getTodayWorkout(userId);
      setTodayWorkout(workout);
      
      // Transform workout data for display
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

  const quickStats = [
    { value: stats.averageIntensity.toFixed(1), label: 'Avg Intensity' },
    { value: `${Math.round(stats.completionRate)}%`, label: 'Consistency' },
    { value: `${stats.totalWorkouts}`, label: 'Workouts' },
  ];

  const achievements = [
    {
      id: '1',
      icon: '🏆',
      name: 'Week Warrior',
      description: '7 days streak',
      unlocked: true,
    },
    {
      id: '2',
      icon: '⚡',
      name: 'Speed Demon',
      description: 'Sub 0.4s reaction',
      unlocked: true,
    },
    {
      id: '3',
      icon: '🎯',
      name: 'Precision Pro',
      description: '90% accuracy',
      unlocked: false,
    },
    {
      id: '4',
      icon: '🔥',
      name: 'On Fire',
      description: '30 days streak',
      unlocked: false,
    },
  ];

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <LoadingState />
      </SafeAreaView>
    );
  }

  return (
    <>
      <StatusBar barStyle="light-content" backgroundColor={Colors.primaryBlack} />
      <SafeAreaView style={styles.container}>
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.headerContent}>
            <Text style={styles.headerTitle}>Squash Master</Text>
            <View style={styles.streakBadge}>
              <Text style={styles.streakEmoji}>🔥</Text>
              <Text style={styles.streakText}>{streak} Days</Text>
            </View>
          </View>
        </View>

        <ScrollView
          showsVerticalScrollIndicator={false}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              tintColor={Colors.accentVolt}
              colors={[Colors.accentVolt]}
            />
          }
          contentContainerStyle={styles.scrollContent}
        >
          {/* Hero Section */}
          <View style={styles.section}>
            <HeroCard
              date={getTodayDate()}
              title={activeProgram?.name || "Start Your Journey"}
              subtitle={activeProgram ? `Week ${activeProgram.current_week}` : "Choose a training program"}
              onPress={handleStartWorkout}
            />
          </View>

          {/* Quick Stats */}
          <View style={styles.section}>
            <QuickStats stats={quickStats} />
          </View>

          {/* Today's Training */}
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <Text style={styles.sectionTitle}>Today's Training</Text>
              <Text style={styles.seeAll}>See All</Text>
            </View>
            
            {workouts.map((workout) => (
              <WorkoutCard
                key={workout.id}
                {...workout}
                onPress={() => handleWorkoutPress(workout.id)}
              />
            ))}
          </View>

          {/* Progress Ring */}
          <View style={styles.section}>
            <ProgressRing
              percentage={calculateProgress() * 0.7} // 70% of weekly goal
              workouts={workouts.filter(w => w.completed).length}
              totalWorkouts={6}
              minutes={285}
            />
          </View>

          {/* Achievements */}
          <View style={styles.achievementsSection}>
            <View style={styles.sectionHeader}>
              <Text style={styles.sectionTitle}>Achievements</Text>
              <Text style={styles.seeAll}>See All</Text>
            </View>
          </View>
          
          <AchievementScroll achievements={achievements} />

          {/* Bottom spacing */}
          <View style={{ height: 100 }} />
        </ScrollView>

        {/* AI Coach FAB */}
        <AICoachFAB onPress={handleAICoachPress} />
      </SafeAreaView>
    </>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: DarkTheme.background,
  },
  header: {
    backgroundColor: Colors.blackAlpha(0.95),
    paddingTop: 20,
    paddingHorizontal: Spacing.lg,
    paddingBottom: Spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: DarkTheme.border,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  headerTitle: {
    ...Typography.h1,
    color: DarkTheme.text,
  },
  streakBadge: {
    backgroundColor: Colors.accentVolt,
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.sm,
    borderRadius: 20,
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.xs,
  },
  streakEmoji: {
    fontSize: 16,
  },
  streakText: {
    ...Typography.labelTiny,
    color: Colors.primaryBlack,
    fontWeight: Typography.FontWeight.bold,
  },
  scrollContent: {
    paddingBottom: Spacing.xl,
  },
  section: {
    paddingHorizontal: Spacing.lg,
    marginBottom: Spacing.xl,
  },
  achievementsSection: {
    paddingHorizontal: Spacing.lg,
    marginBottom: Spacing.md,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.lg,
  },
  sectionTitle: {
    ...Typography.h3,
    color: DarkTheme.text,
  },
  seeAll: {
    ...Typography.bodySmall,
    color: Colors.accentVolt,
    fontWeight: Typography.FontWeight.semiBold,
  },
});

export default HomeScreen;
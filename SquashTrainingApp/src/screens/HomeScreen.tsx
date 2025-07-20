import React, { useState, useEffect, useRef, useCallback } from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  RefreshControl,
  Animated,
  Dimensions,
  StatusBar,
  Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import LinearGradient from 'react-native-linear-gradient';
import Haptics from 'react-native-haptic-feedback';

// Core Components
import { Text, Button, Card, Surface, Icon, Skeleton } from '../components/core';

// Design System
import {
  Palette,
  Spacing,
  BorderRadius,
  Animation,
  Typography,
  Layout,
} from '../styles/designSystem';

// Contexts
import { useTheme } from '../contexts/ThemeContext';
import { useAuth } from './auth/AuthContext';

// Services
import DatabaseService from '../services/DatabaseService';
import aiApi from '../services/api/aiApi';

// Types
import { WorkoutLog, TrainingProgram } from '../types';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

const HomeScreen = () => {
  const navigation = useNavigation();
  const { theme } = useTheme();
  const { isDeveloper, developerApiKey } = useAuth();
  
  // State
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [activeProgram, setActiveProgram] = useState<TrainingProgram | null>(null);
  const [stats, setStats] = useState({
    streak: 0,
    weeklyProgress: 0,
    totalWorkouts: 0,
    avgIntensity: 0,
  });
  const [todayWorkouts, setTodayWorkouts] = useState([]);
  const [recentAchievements, setRecentAchievements] = useState([]);
  
  // Animations
  const scrollY = useRef(new Animated.Value(0)).current;
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(50)).current;
  
  // Load data
  useEffect(() => {
    loadData();
    animateEntrance();
  }, []);
  
  // Set developer API key
  useEffect(() => {
    if (isDeveloper && developerApiKey) {
      aiApi.setDeveloperApiKey(developerApiKey);
    }
  }, [isDeveloper, developerApiKey]);
  
  const animateEntrance = () => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: Animation.duration.base,
        useNativeDriver: true,
      }),
      Animated.spring(slideAnim, {
        toValue: 0,
        ...Animation.easing.spring,
        useNativeDriver: true,
      }),
    ]).start();
  };
  
  const loadData = async () => {
    try {
      setLoading(true);
      await DatabaseService.init();
      
      // Simulate data loading
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Load user stats
      setStats({
        streak: 7,
        weeklyProgress: 75,
        totalWorkouts: 142,
        avgIntensity: 8.2,
      });
      
      // Load today's workouts
      setTodayWorkouts([
        {
          id: '1',
          name: 'Morning Drills',
          time: '07:00 AM',
          duration: 45,
          category: 'skill',
          completed: true,
        },
        {
          id: '2',
          name: 'Strength Training',
          time: '05:00 PM',
          duration: 30,
          category: 'strength',
          completed: false,
        },
        {
          id: '3',
          name: 'Evening Cardio',
          time: '07:30 PM',
          duration: 20,
          category: 'cardio',
          completed: false,
        },
      ]);
      
      // Load achievements
      setRecentAchievements([
        { id: '1', title: 'Week Warrior', icon: '🏆', unlocked: true },
        { id: '2', title: 'Speed Demon', icon: '⚡', unlocked: true },
        { id: '3', title: 'Consistency King', icon: '👑', unlocked: false },
      ]);
      
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };
  
  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    Haptics.trigger('impactLight');
    await loadData();
    setRefreshing(false);
  }, []);
  
  const handleStartWorkout = useCallback(() => {
    Haptics.trigger('impactMedium');
    navigation.navigate('Record');
  }, [navigation]);
  
  const handleWorkoutPress = useCallback((workout) => {
    Haptics.trigger('selection');
    // Navigate to workout detail
  }, []);
  
  const headerOpacity = scrollY.interpolate({
    inputRange: [0, 100],
    outputRange: [0, 1],
    extrapolate: 'clamp',
  });
  
  const heroScale = scrollY.interpolate({
    inputRange: [-100, 0, 100],
    outputRange: [1.1, 1, 0.9],
    extrapolate: 'clamp',
  });
  
  if (loading) {
    return <LoadingScreen />;
  }
  
  return (
    <>
      <StatusBar
        barStyle={theme === 'dark' ? 'light-content' : 'dark-content'}
        backgroundColor="transparent"
        translucent
      />
      
      <SafeAreaView style={styles.container} edges={['top']}>
        {/* Fixed Header */}
        <Animated.View
          style={[
            styles.header,
            {
              opacity: headerOpacity,
              transform: [
                {
                  translateY: headerOpacity.interpolate({
                    inputRange: [0, 1],
                    outputRange: [-20, 0],
                  }),
                },
              ],
            },
          ]}
        >
          <Surface level={2} style={styles.headerSurface}>
            <Text variant="h6">Squash Master</Text>
            <View style={styles.headerActions}>
              <Button
                variant="text"
                size="small"
                startIcon="bell-outline"
                onPress={() => {}}
              />
              <Button
                variant="text"
                size="small"
                startIcon="cog-outline"
                onPress={() => navigation.navigate('Profile')}
              />
            </View>
          </Surface>
        </Animated.View>
        
        <Animated.ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={styles.scrollContent}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              tintColor={Palette.primary[500]}
              colors={[Palette.primary[500]]}
            />
          }
          onScroll={Animated.event(
            [{ nativeEvent: { contentOffset: { y: scrollY } } }],
            { useNativeDriver: true }
          )}
          scrollEventThrottle={16}
        >
          {/* Hero Section */}
          <Animated.View
            style={[
              styles.heroSection,
              {
                opacity: fadeAnim,
                transform: [
                  { translateY: slideAnim },
                  { scale: heroScale },
                ],
              },
            ]}
          >
            <LinearGradient
              colors={
                theme === 'dark'
                  ? [Palette.primary[900], Palette.primary[800]]
                  : [Palette.primary[500], Palette.primary[600]]
              }
              style={styles.heroGradient}
            >
              <View style={styles.heroContent}>
                <Text variant="overline" color="textSecondary">
                  {new Date().toLocaleDateString('en-US', {
                    weekday: 'long',
                    month: 'long',
                    day: 'numeric',
                  })}
                </Text>
                <Text variant="h3" style={styles.heroTitle}>
                  Ready to Train?
                </Text>
                <Text variant="body1" style={styles.heroSubtitle}>
                  {stats.streak} day streak • {3 - todayWorkouts.filter(w => w.completed).length} workouts left
                </Text>
                
                <Button
                  variant="contained"
                  size="large"
                  color="secondary"
                  fullWidth
                  startIcon="play"
                  onPress={handleStartWorkout}
                  style={styles.heroButton}
                >
                  Start Today's Workout
                </Button>
              </View>
              
              {/* Decorative Elements */}
              <View style={styles.heroDecoration1} />
              <View style={styles.heroDecoration2} />
            </LinearGradient>
          </Animated.View>
          
          {/* Stats Grid */}
          <View style={styles.statsSection}>
            <Text variant="h6" style={styles.sectionTitle}>
              Your Progress
            </Text>
            <View style={styles.statsGrid}>
              <StatsCard
                icon="fire"
                value={stats.streak}
                label="Day Streak"
                color={Palette.semantic.error}
              />
              <StatsCard
                icon="trending-up"
                value={`${stats.weeklyProgress}%`}
                label="Weekly Goal"
                color={Palette.semantic.success}
              />
              <StatsCard
                icon="trophy"
                value={stats.totalWorkouts}
                label="Total Sessions"
                color={Palette.semantic.warning}
              />
              <StatsCard
                icon="lightning-bolt"
                value={stats.avgIntensity.toFixed(1)}
                label="Avg Intensity"
                color={Palette.semantic.info}
              />
            </View>
          </View>
          
          {/* Today's Schedule */}
          <View style={styles.scheduleSection}>
            <View style={styles.sectionHeader}>
              <Text variant="h6">Today's Schedule</Text>
              <Button
                variant="text"
                size="small"
                color="primary"
                onPress={() => navigation.navigate('Checklist')}
              >
                View All
              </Button>
            </View>
            
            {todayWorkouts.map((workout, index) => (
              <WorkoutCard
                key={workout.id}
                workout={workout}
                onPress={() => handleWorkoutPress(workout)}
                style={{ marginBottom: Spacing[3] }}
              />
            ))}
          </View>
          
          {/* Achievements */}
          <View style={styles.achievementsSection}>
            <Text variant="h6" style={styles.sectionTitle}>
              Recent Achievements
            </Text>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.achievementsScroll}
            >
              {recentAchievements.map((achievement) => (
                <AchievementCard
                  key={achievement.id}
                  achievement={achievement}
                />
              ))}
            </ScrollView>
          </View>
          
          {/* Bottom Spacing */}
          <View style={{ height: Spacing[20] }} />
        </Animated.ScrollView>
        
        {/* Floating Action Button */}
        <FloatingAICoach />
      </SafeAreaView>
    </>
  );
};

// Sub-components
const LoadingScreen = () => {
  const { theme } = useTheme();
  
  return (
    <SafeAreaView style={styles.loadingContainer}>
      <View style={styles.loadingContent}>
        <Skeleton variant="rectangular" height={200} style={{ marginBottom: Spacing[6] }} />
        <Skeleton variant="text" width="60%" style={{ marginBottom: Spacing[3] }} />
        <Skeleton variant="text" width="100%" style={{ marginBottom: Spacing[3] }} />
        <Skeleton variant="text" width="80%" style={{ marginBottom: Spacing[6] }} />
        
        <View style={styles.statsGrid}>
          {[1, 2, 3, 4].map((i) => (
            <Skeleton
              key={i}
              variant="rectangular"
              height={100}
              style={styles.statCardSkeleton}
            />
          ))}
        </View>
      </View>
    </SafeAreaView>
  );
};

const StatsCard = ({ icon, value, label, color }) => (
  <Card
    variant="filled"
    padding="medium"
    style={styles.statCard}
  >
    <Icon name={icon} size={24} color={color} style={styles.statIcon} />
    <Text variant="h4" weight="bold" style={styles.statValue}>
      {value}
    </Text>
    <Text variant="caption" color="textSecondary">
      {label}
    </Text>
  </Card>
);

const WorkoutCard = ({ workout, onPress, style }) => {
  const categoryColors = {
    skill: Palette.categories.skill,
    strength: Palette.categories.strength,
    cardio: Palette.categories.cardio,
  };
  
  return (
    <Card
      variant="elevated"
      onPress={onPress}
      style={[styles.workoutCard, style]}
    >
      <View style={styles.workoutContent}>
        <View
          style={[
            styles.workoutIcon,
            { backgroundColor: `${categoryColors[workout.category]}20` },
          ]}
        >
          <Icon
            name={
              workout.category === 'skill'
                ? 'tennis'
                : workout.category === 'strength'
                ? 'dumbbell'
                : 'run-fast'
            }
            size={24}
            color={categoryColors[workout.category]}
          />
        </View>
        
        <View style={styles.workoutInfo}>
          <Text variant="body1" weight="semibold">
            {workout.name}
          </Text>
          <Text variant="caption" color="textSecondary">
            {workout.time} • {workout.duration} min
          </Text>
        </View>
        
        <View style={styles.workoutStatus}>
          {workout.completed ? (
            <Icon name="check-circle" size={24} color={Palette.semantic.success} />
          ) : (
            <Icon name="chevron-right" size={24} color={Palette.neutral[400]} />
          )}
        </View>
      </View>
    </Card>
  );
};

const AchievementCard = ({ achievement }) => (
  <Card
    variant="outlined"
    padding="medium"
    style={[
      styles.achievementCard,
      !achievement.unlocked && styles.achievementLocked,
    ]}
  >
    <Text style={styles.achievementIcon}>{achievement.icon}</Text>
    <Text variant="body2" weight="semibold" align="center">
      {achievement.title}
    </Text>
    {!achievement.unlocked && (
      <View style={styles.lockedOverlay}>
        <Icon name="lock" size={20} color={Palette.neutral[500]} />
      </View>
    )}
  </Card>
);

const FloatingAICoach = () => {
  const navigation = useNavigation();
  const scaleAnim = useRef(new Animated.Value(0)).current;
  
  useEffect(() => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      delay: Animation.duration.slow,
      ...Animation.easing.bounce,
      useNativeDriver: true,
    }).start();
  }, []);
  
  return (
    <Animated.View
      style={[
        styles.fab,
        {
          transform: [{ scale: scaleAnim }],
        },
      ]}
    >
      <Button
        variant="gradient"
        size="large"
        startIcon="robot"
        onPress={() => navigation.navigate('Coach')}
        style={styles.fabButton}
      />
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loadingContainer: {
    flex: 1,
    padding: Spacing[6],
  },
  loadingContent: {
    flex: 1,
  },
  header: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 100,
    paddingTop: Layout.safeArea.top,
  },
  headerSurface: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing[4],
    paddingVertical: Spacing[3],
  },
  headerActions: {
    flexDirection: 'row',
    gap: Spacing[2],
  },
  scrollContent: {
    paddingTop: Layout.safeArea.top + 60,
  },
  heroSection: {
    marginHorizontal: Spacing[4],
    marginBottom: Spacing[6],
  },
  heroGradient: {
    borderRadius: BorderRadius.xl,
    padding: Spacing[6],
    position: 'relative',
    overflow: 'hidden',
  },
  heroContent: {
    zIndex: 1,
  },
  heroTitle: {
    color: Palette.neutral[0],
    marginVertical: Spacing[2],
  },
  heroSubtitle: {
    color: Palette.neutral[100],
    marginBottom: Spacing[4],
  },
  heroButton: {
    marginTop: Spacing[2],
  },
  heroDecoration1: {
    position: 'absolute',
    top: -50,
    right: -50,
    width: 150,
    height: 150,
    borderRadius: 75,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
  },
  heroDecoration2: {
    position: 'absolute',
    bottom: -30,
    left: -30,
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
  },
  statsSection: {
    paddingHorizontal: Spacing[4],
    marginBottom: Spacing[6],
  },
  sectionTitle: {
    marginBottom: Spacing[4],
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing[3],
  },
  statCard: {
    flex: 1,
    minWidth: (SCREEN_WIDTH - Spacing[4] * 2 - Spacing[3]) / 2 - 1,
    alignItems: 'center',
  },
  statCardSkeleton: {
    flex: 1,
    minWidth: (SCREEN_WIDTH - Spacing[4] * 2 - Spacing[3]) / 2 - 1,
  },
  statIcon: {
    marginBottom: Spacing[2],
  },
  statValue: {
    marginBottom: Spacing[1],
  },
  scheduleSection: {
    paddingHorizontal: Spacing[4],
    marginBottom: Spacing[6],
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing[4],
  },
  workoutCard: {
    padding: Spacing[4],
  },
  workoutContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  workoutIcon: {
    width: 48,
    height: 48,
    borderRadius: BorderRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing[3],
  },
  workoutInfo: {
    flex: 1,
  },
  workoutStatus: {
    marginLeft: Spacing[3],
  },
  achievementsSection: {
    paddingLeft: Spacing[4],
    marginBottom: Spacing[6],
  },
  achievementsScroll: {
    paddingRight: Spacing[4],
    gap: Spacing[3],
  },
  achievementCard: {
    width: 120,
    alignItems: 'center',
  },
  achievementIcon: {
    fontSize: 32,
    marginBottom: Spacing[2],
  },
  achievementLocked: {
    opacity: 0.5,
  },
  lockedOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    borderRadius: BorderRadius.lg,
    alignItems: 'center',
    justifyContent: 'center',
  },
  fab: {
    position: 'absolute',
    bottom: Spacing[6],
    right: Spacing[4],
  },
  fabButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
  },
});

export default HomeScreen;
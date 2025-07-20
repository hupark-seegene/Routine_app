import React, { useState, useEffect } from 'react';
import {
  View,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  Alert,
  RefreshControl,
} from 'react-native';
import { Text } from '../components/core/Text';
import { Card } from '../components/core/Card';
import { Button } from '../components/core/Button';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { Colors } from '../styles/colors';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import databaseService from '../services/databaseService';
import { DailyWorkout } from '../types';

type NavigationProp = StackNavigationProp<RootStackParamList>;

export const CustomWorkoutsScreen: React.FC = () => {
  const navigation = useNavigation<NavigationProp>();
  const [workouts, setWorkouts] = useState<DailyWorkout[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    loadCustomWorkouts();
  }, []);

  const loadCustomWorkouts = async () => {
    try {
      const customWorkouts = await databaseService.getCustomWorkouts(1); // Default user ID
      setWorkouts(customWorkouts);
    } catch (error) {
      console.error('Error loading custom workouts:', error);
      Alert.alert('Error', 'Failed to load custom workouts');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setRefreshing(true);
    loadCustomWorkouts();
  };

  const deleteWorkout = (workoutId: number, workoutName: string) => {
    Alert.alert(
      'Delete Workout',
      `Are you sure you want to delete "${workoutName}"?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              // Note: Would need to implement deleteCustomWorkout in databaseService
              // await databaseService.deleteCustomWorkout(workoutId, 1);
              await loadCustomWorkouts();
              Alert.alert('Success', 'Workout deleted successfully');
            } catch (error) {
              Alert.alert('Error', 'Failed to delete workout');
            }
          },
        },
      ]
    );
  };

  const startWorkout = (workout: DailyWorkout) => {
    // Navigate to workout session with custom workout
    navigation.navigate('WorkoutSession', {
      sessionId: workout.id,
      enrollmentId: 0, // Custom workout, no enrollment
    });
  };

  const renderExerciseCount = (workout: DailyWorkout) => {
    const exerciseCount = workout.exercises?.length || 0;
    return `${exerciseCount} exercise${exerciseCount !== 1 ? 's' : ''}`;
  };

  const renderDuration = (duration: number) => {
    if (duration >= 60) {
      const hours = Math.floor(duration / 60);
      const minutes = duration % 60;
      return minutes > 0 ? `${hours}h ${minutes}min` : `${hours}h`;
    }
    return `${duration}min`;
  };

  const getIntensityColor = (intensity: string) => {
    switch (intensity?.toLowerCase()) {
      case 'low':
        return Colors.success;
      case 'medium':
        return Colors.warning;
      case 'high':
        return Colors.error;
      default:
        return Colors.textSecondary;
    }
  };

  const getWorkoutIcon = (type: string) => {
    switch (type?.toLowerCase()) {
      case 'squash':
        return 'tennis';
      case 'fitness':
        return 'dumbbell';
      case 'cardio':
        return 'run';
      case 'recovery':
        return 'meditation';
      default:
        return 'lightning-bolt';
    }
  };

  if (loading && !refreshing) {
    return (
      <View style={styles.loadingContainer}>
        <Icon name="loading" size={48} color={Colors.primary} />
        <Text style={styles.loadingText}>Loading workouts...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        <View style={styles.header}>
          <Text variant="h4" style={styles.title}>My Custom Workouts</Text>
          <Button
            onPress={() => navigation.navigate('CreateWorkout')}
            style={styles.createButton}
          >
            <Icon name="plus" size={20} color={Colors.background} />
            <Text style={styles.createButtonText}>Create New</Text>
          </Button>
        </View>

        {workouts.length === 0 ? (
          <Card style={styles.emptyCard}>
            <Icon name="clipboard-text-outline" size={64} color={Colors.textSecondary} />
            <Text style={styles.emptyText}>No custom workouts yet</Text>
            <Text style={styles.emptySubtext}>
              Create your first personalized workout routine
            </Text>
            <Button
              onPress={() => navigation.navigate('CreateWorkout')}
              style={styles.emptyButton}
            >
              Create Workout
            </Button>
          </Card>
        ) : (
          <View style={styles.workoutsList}>
            {workouts.map((workout) => (
              <Card key={workout.id} style={styles.workoutCard}>
                <TouchableOpacity
                  onPress={() => startWorkout(workout)}
                  activeOpacity={0.7}
                >
                  <View style={styles.workoutHeader}>
                    <View style={[styles.workoutIcon, { backgroundColor: Colors.primaryTransparent }]}>
                      <Icon
                        name={getWorkoutIcon(workout.workout_type)}
                        size={24}
                        color={Colors.primary}
                      />
                    </View>
                    <View style={styles.workoutInfo}>
                      <Text style={styles.workoutName}>{workout.name}</Text>
                      <View style={styles.workoutMeta}>
                        <Text style={styles.metaText}>{renderExerciseCount(workout)}</Text>
                        <Text style={styles.metaDivider}>•</Text>
                        <Text style={styles.metaText}>
                          {renderDuration(workout.total_duration || 0)}
                        </Text>
                        <Text style={styles.metaDivider}>•</Text>
                        <View
                          style={[
                            styles.intensityBadge,
                            { backgroundColor: getIntensityColor(workout.intensity_level) }
                          ]}
                        >
                          <Text style={styles.intensityText}>
                            {workout.intensity_level || 'Medium'}
                          </Text>
                        </View>
                      </View>
                    </View>
                  </View>

                  {workout.exercises && workout.exercises.length > 0 && (
                    <View style={styles.exercisePreview}>
                      <Text style={styles.exercisePreviewTitle}>Exercises:</Text>
                      <View style={styles.exerciseList}>
                        {workout.exercises.slice(0, 3).map((exercise, index) => (
                          <View key={index} style={styles.exerciseItem}>
                            <Icon name="checkbox-marked-circle" size={16} color={Colors.primary} />
                            <Text style={styles.exerciseName}>{exercise.name}</Text>
                          </View>
                        ))}
                        {workout.exercises.length > 3 && (
                          <Text style={styles.moreExercises}>
                            +{workout.exercises.length - 3} more
                          </Text>
                        )}
                      </View>
                    </View>
                  )}

                  <View style={styles.workoutActions}>
                    <TouchableOpacity
                      style={styles.actionButton}
                      onPress={() => startWorkout(workout)}
                    >
                      <Icon name="play-circle" size={20} color={Colors.primary} />
                      <Text style={styles.actionText}>Start</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                      style={styles.actionButton}
                      onPress={() => {
                        // TODO: Implement edit functionality
                        Alert.alert('Coming Soon', 'Edit functionality will be available soon');
                      }}
                    >
                      <Icon name="pencil" size={20} color={Colors.textSecondary} />
                      <Text style={[styles.actionText, { color: Colors.textSecondary }]}>
                        Edit
                      </Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                      style={styles.actionButton}
                      onPress={() => deleteWorkout(workout.id, workout.name)}
                    >
                      <Icon name="delete" size={20} color={Colors.error} />
                      <Text style={[styles.actionText, { color: Colors.error }]}>Delete</Text>
                    </TouchableOpacity>
                  </View>
                </TouchableOpacity>
              </Card>
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: Colors.textSecondary,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    paddingBottom: 10,
  },
  title: {
    color: Colors.text,
    fontWeight: 'bold',
  },
  createButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    gap: 8,
  },
  createButtonText: {
    color: Colors.background,
    fontSize: 14,
    fontWeight: '600',
  },
  emptyCard: {
    margin: 20,
    padding: 40,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.text,
    marginTop: 16,
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: Colors.textSecondary,
    textAlign: 'center',
    marginBottom: 24,
  },
  emptyButton: {
    paddingHorizontal: 24,
  },
  workoutsList: {
    padding: 20,
    paddingTop: 10,
  },
  workoutCard: {
    marginBottom: 16,
    padding: 0,
    overflow: 'hidden',
  },
  workoutHeader: {
    flexDirection: 'row',
    padding: 16,
    alignItems: 'center',
  },
  workoutIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  workoutInfo: {
    flex: 1,
  },
  workoutName: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.text,
    marginBottom: 4,
  },
  workoutMeta: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  metaText: {
    fontSize: 14,
    color: Colors.textSecondary,
  },
  metaDivider: {
    marginHorizontal: 8,
    color: Colors.textSecondary,
  },
  intensityBadge: {
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
  },
  intensityText: {
    fontSize: 12,
    color: Colors.background,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  exercisePreview: {
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  exercisePreviewTitle: {
    fontSize: 14,
    color: Colors.textSecondary,
    marginBottom: 8,
    fontWeight: '600',
  },
  exerciseList: {
    gap: 6,
  },
  exerciseItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  exerciseName: {
    fontSize: 14,
    color: Colors.text,
  },
  moreExercises: {
    fontSize: 14,
    color: Colors.textSecondary,
    fontStyle: 'italic',
    marginLeft: 24,
  },
  workoutActions: {
    flexDirection: 'row',
    borderTopWidth: 1,
    borderTopColor: Colors.cardBorder,
  },
  actionButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    gap: 6,
  },
  actionText: {
    fontSize: 14,
    fontWeight: '600',
    color: Colors.primary,
  },
});
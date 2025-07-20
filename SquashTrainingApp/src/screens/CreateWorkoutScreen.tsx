import React, { useState } from 'react';
import {
  View,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  TextInput,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { Text } from '../components/core/Text';
import { Card } from '../components/core/Card';
import { Button } from '../components/core/Button';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { Colors } from '../styles/colors';
import { useNavigation } from '@react-navigation/native';
import databaseService from '../services/databaseService';

interface Exercise {
  name: string;
  category: string;
  sets: string;
  reps: string;
  duration: string;
  intensity: string;
  instructions: string;
}

export const CreateWorkoutScreen: React.FC = () => {
  const navigation = useNavigation();
  const [workoutName, setWorkoutName] = useState('');
  const [workoutType, setWorkoutType] = useState('squash');
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [showExerciseForm, setShowExerciseForm] = useState(false);
  const [currentExercise, setCurrentExercise] = useState<Exercise>({
    name: '',
    category: 'skill',
    sets: '',
    reps: '',
    duration: '',
    intensity: 'medium',
    instructions: '',
  });
  const [editingIndex, setEditingIndex] = useState<number | null>(null);

  const workoutTypes = [
    { id: 'squash', name: 'Squash Training', icon: 'tennis' },
    { id: 'fitness', name: 'Fitness', icon: 'dumbbell' },
    { id: 'cardio', name: 'Cardio', icon: 'run' },
    { id: 'recovery', name: 'Recovery', icon: 'meditation' },
  ];

  const categories = [
    { id: 'skill', name: 'Skill Work' },
    { id: 'fitness', name: 'Fitness' },
    { id: 'cardio', name: 'Cardio' },
    { id: 'strength', name: 'Strength' },
    { id: 'flexibility', name: 'Flexibility' },
    { id: 'mental', name: 'Mental' },
  ];

  const intensityLevels = [
    { id: 'low', name: 'Low', color: Colors.success },
    { id: 'medium', name: 'Medium', color: Colors.warning },
    { id: 'high', name: 'High', color: Colors.error },
  ];

  const presetExercises = {
    skill: [
      { name: 'Ghost Practice', category: 'skill', duration: '15' },
      { name: 'Boast Practice', category: 'skill', sets: '3', reps: '10' },
      { name: 'Drop Shot Drills', category: 'skill', sets: '3', reps: '10' },
      { name: 'Solo Hitting', category: 'skill', duration: '20' },
    ],
    fitness: [
      { name: 'Court Sprints', category: 'fitness', sets: '5', reps: '6' },
      { name: 'Burpees', category: 'fitness', sets: '3', reps: '15' },
      { name: 'Lunges', category: 'fitness', sets: '3', reps: '20' },
      { name: 'Plank', category: 'fitness', duration: '60' },
    ],
    cardio: [
      { name: 'Running', category: 'cardio', duration: '30' },
      { name: 'Cycling', category: 'cardio', duration: '45' },
      { name: 'Jump Rope', category: 'cardio', duration: '15' },
      { name: 'Rowing', category: 'cardio', duration: '20' },
    ],
  };

  const addExercise = () => {
    if (!currentExercise.name.trim()) {
      Alert.alert('Error', 'Please enter exercise name');
      return;
    }

    if (!currentExercise.duration && (!currentExercise.sets || !currentExercise.reps)) {
      Alert.alert('Error', 'Please enter either duration or sets & reps');
      return;
    }

    if (editingIndex !== null) {
      const updatedExercises = [...exercises];
      updatedExercises[editingIndex] = currentExercise;
      setExercises(updatedExercises);
      setEditingIndex(null);
    } else {
      setExercises([...exercises, currentExercise]);
    }

    setCurrentExercise({
      name: '',
      category: 'skill',
      sets: '',
      reps: '',
      duration: '',
      intensity: 'medium',
      instructions: '',
    });
    setShowExerciseForm(false);
  };

  const editExercise = (index: number) => {
    setCurrentExercise(exercises[index]);
    setEditingIndex(index);
    setShowExerciseForm(true);
  };

  const deleteExercise = (index: number) => {
    Alert.alert(
      'Delete Exercise',
      'Are you sure you want to delete this exercise?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => {
            const updatedExercises = exercises.filter((_, i) => i !== index);
            setExercises(updatedExercises);
          },
        },
      ]
    );
  };

  const addPresetExercise = (exercise: any) => {
    setCurrentExercise({
      ...exercise,
      intensity: 'medium',
      instructions: '',
    });
    setShowExerciseForm(true);
  };

  const saveWorkout = async () => {
    if (!workoutName.trim()) {
      Alert.alert('Error', 'Please enter workout name');
      return;
    }

    if (exercises.length === 0) {
      Alert.alert('Error', 'Please add at least one exercise');
      return;
    }

    try {
      // Save custom workout to database
      const workoutId = await databaseService.saveCustomWorkout({
        name: workoutName,
        type: workoutType,
        exercises: exercises,
        userId: 1, // Default user ID
      });

      Alert.alert(
        'Success',
        'Workout saved successfully!',
        [
          {
            text: 'OK',
            onPress: () => navigation.goBack(),
          },
        ]
      );
    } catch (error) {
      console.error('Save workout error:', error);
      Alert.alert('Error', 'Failed to save workout');
    }
  };

  const calculateTotalDuration = (): number => {
    return exercises.reduce((total, exercise) => {
      if (exercise.duration) {
        return total + parseInt(exercise.duration);
      } else if (exercise.sets && exercise.reps) {
        // Estimate 1 minute per set
        return total + parseInt(exercise.sets);
      }
      return total;
    }, 0);
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <Text variant="h4" style={styles.title}>Create Custom Workout</Text>
        </View>

        {/* Workout Name */}
        <Card style={styles.section}>
          <Text variant="h6" style={styles.sectionTitle}>Workout Details</Text>
          <TextInput
            style={styles.input}
            placeholder="Workout Name"
            placeholderTextColor={Colors.textSecondary}
            value={workoutName}
            onChangeText={setWorkoutName}
          />

          {/* Workout Type */}
          <Text style={styles.label}>Workout Type</Text>
          <View style={styles.typeGrid}>
            {workoutTypes.map((type) => (
              <TouchableOpacity
                key={type.id}
                style={[
                  styles.typeCard,
                  workoutType === type.id && styles.typeCardActive,
                ]}
                onPress={() => setWorkoutType(type.id)}
              >
                <Icon
                  name={type.icon}
                  size={24}
                  color={workoutType === type.id ? Colors.background : Colors.primary}
                />
                <Text
                  style={[
                    styles.typeText,
                    workoutType === type.id && styles.typeTextActive,
                  ]}
                >
                  {type.name}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </Card>

        {/* Exercises List */}
        <Card style={styles.section}>
          <View style={styles.exerciseHeader}>
            <Text variant="h6" style={styles.sectionTitle}>Exercises</Text>
            <TouchableOpacity
              style={styles.addButton}
              onPress={() => setShowExerciseForm(true)}
            >
              <Icon name="plus" size={20} color={Colors.background} />
              <Text style={styles.addButtonText}>Add Exercise</Text>
            </TouchableOpacity>
          </View>

          {exercises.length === 0 ? (
            <Text style={styles.emptyText}>No exercises added yet</Text>
          ) : (
            exercises.map((exercise, index) => (
              <View key={index} style={styles.exerciseItem}>
                <View style={styles.exerciseInfo}>
                  <Text style={styles.exerciseName}>{exercise.name}</Text>
                  <View style={styles.exerciseDetails}>
                    <Text style={styles.exerciseDetailText}>
                      {exercise.category}
                    </Text>
                    {exercise.duration ? (
                      <Text style={styles.exerciseDetailText}>
                        {exercise.duration} min
                      </Text>
                    ) : (
                      <Text style={styles.exerciseDetailText}>
                        {exercise.sets} × {exercise.reps}
                      </Text>
                    )}
                    <View
                      style={[
                        styles.intensityBadge,
                        { backgroundColor: intensityLevels.find(l => l.id === exercise.intensity)?.color },
                      ]}
                    >
                      <Text style={styles.intensityText}>{exercise.intensity}</Text>
                    </View>
                  </View>
                </View>
                <View style={styles.exerciseActions}>
                  <TouchableOpacity onPress={() => editExercise(index)}>
                    <Icon name="pencil" size={20} color={Colors.primary} />
                  </TouchableOpacity>
                  <TouchableOpacity onPress={() => deleteExercise(index)}>
                    <Icon name="delete" size={20} color={Colors.error} />
                  </TouchableOpacity>
                </View>
              </View>
            ))
          )}

          {/* Quick Add Presets */}
          {exercises.length < 10 && (
            <View style={styles.presetsSection}>
              <Text style={styles.presetsTitle}>Quick Add:</Text>
              <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                {Object.entries(presetExercises).map(([category, presets]) => (
                  presets.slice(0, 2).map((preset, index) => (
                    <TouchableOpacity
                      key={`${category}-${index}`}
                      style={styles.presetChip}
                      onPress={() => addPresetExercise(preset)}
                    >
                      <Text style={styles.presetText}>{preset.name}</Text>
                    </TouchableOpacity>
                  ))
                ))}
              </ScrollView>
            </View>
          )}
        </Card>

        {/* Summary */}
        {exercises.length > 0 && (
          <Card style={styles.summaryCard}>
            <Text variant="h6" style={styles.sectionTitle}>Summary</Text>
            <View style={styles.summaryRow}>
              <Text style={styles.summaryLabel}>Total Exercises:</Text>
              <Text style={styles.summaryValue}>{exercises.length}</Text>
            </View>
            <View style={styles.summaryRow}>
              <Text style={styles.summaryLabel}>Est. Duration:</Text>
              <Text style={styles.summaryValue}>{calculateTotalDuration()} min</Text>
            </View>
          </Card>
        )}

        {/* Save Button */}
        <Button
          onPress={saveWorkout}
          style={styles.saveButton}
          disabled={!workoutName || exercises.length === 0}
        >
          Save Workout
        </Button>
      </ScrollView>

      {/* Exercise Form Modal */}
      {showExerciseForm && (
        <View style={styles.modalOverlay}>
          <Card style={styles.modalContent}>
            <Text variant="h6" style={styles.modalTitle}>
              {editingIndex !== null ? 'Edit Exercise' : 'Add Exercise'}
            </Text>

            <TextInput
              style={styles.input}
              placeholder="Exercise Name"
              placeholderTextColor={Colors.textSecondary}
              value={currentExercise.name}
              onChangeText={(text) =>
                setCurrentExercise({ ...currentExercise, name: text })
              }
            />

            <Text style={styles.label}>Category</Text>
            <View style={styles.categoryGrid}>
              {categories.map((cat) => (
                <TouchableOpacity
                  key={cat.id}
                  style={[
                    styles.categoryChip,
                    currentExercise.category === cat.id && styles.categoryChipActive,
                  ]}
                  onPress={() =>
                    setCurrentExercise({ ...currentExercise, category: cat.id })
                  }
                >
                  <Text
                    style={[
                      styles.categoryChipText,
                      currentExercise.category === cat.id && styles.categoryChipTextActive,
                    ]}
                  >
                    {cat.name}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            <View style={styles.inputRow}>
              <View style={styles.inputGroup}>
                <Text style={styles.label}>Sets</Text>
                <TextInput
                  style={[styles.input, styles.smallInput]}
                  placeholder="0"
                  placeholderTextColor={Colors.textSecondary}
                  value={currentExercise.sets}
                  onChangeText={(text) =>
                    setCurrentExercise({ ...currentExercise, sets: text })
                  }
                  keyboardType="numeric"
                />
              </View>
              <View style={styles.inputGroup}>
                <Text style={styles.label}>Reps</Text>
                <TextInput
                  style={[styles.input, styles.smallInput]}
                  placeholder="0"
                  placeholderTextColor={Colors.textSecondary}
                  value={currentExercise.reps}
                  onChangeText={(text) =>
                    setCurrentExercise({ ...currentExercise, reps: text })
                  }
                  keyboardType="numeric"
                />
              </View>
              <View style={styles.inputGroup}>
                <Text style={styles.label}>Duration (min)</Text>
                <TextInput
                  style={[styles.input, styles.smallInput]}
                  placeholder="0"
                  placeholderTextColor={Colors.textSecondary}
                  value={currentExercise.duration}
                  onChangeText={(text) =>
                    setCurrentExercise({ ...currentExercise, duration: text })
                  }
                  keyboardType="numeric"
                />
              </View>
            </View>

            <Text style={styles.label}>Intensity</Text>
            <View style={styles.intensityGrid}>
              {intensityLevels.map((level) => (
                <TouchableOpacity
                  key={level.id}
                  style={[
                    styles.intensityOption,
                    currentExercise.intensity === level.id && {
                      backgroundColor: level.color,
                    },
                  ]}
                  onPress={() =>
                    setCurrentExercise({ ...currentExercise, intensity: level.id })
                  }
                >
                  <Text
                    style={[
                      styles.intensityOptionText,
                      currentExercise.intensity === level.id && styles.intensityOptionTextActive,
                    ]}
                  >
                    {level.name}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            <TextInput
              style={[styles.input, styles.textArea]}
              placeholder="Instructions (optional)"
              placeholderTextColor={Colors.textSecondary}
              value={currentExercise.instructions}
              onChangeText={(text) =>
                setCurrentExercise({ ...currentExercise, instructions: text })
              }
              multiline
              numberOfLines={3}
            />

            <View style={styles.modalButtons}>
              <Button
                variant="secondary"
                onPress={() => {
                  setShowExerciseForm(false);
                  setEditingIndex(null);
                  setCurrentExercise({
                    name: '',
                    category: 'skill',
                    sets: '',
                    reps: '',
                    duration: '',
                    intensity: 'medium',
                    instructions: '',
                  });
                }}
                style={styles.modalButton}
              >
                Cancel
              </Button>
              <Button onPress={addExercise} style={styles.modalButton}>
                {editingIndex !== null ? 'Update' : 'Add'}
              </Button>
            </View>
          </Card>
        </View>
      )}
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  header: {
    padding: 20,
    paddingBottom: 10,
  },
  title: {
    color: Colors.text,
    fontWeight: 'bold',
  },
  section: {
    marginHorizontal: 20,
    marginBottom: 20,
    padding: 20,
  },
  sectionTitle: {
    color: Colors.text,
    marginBottom: 16,
    fontWeight: '600',
  },
  input: {
    backgroundColor: Colors.background,
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: Colors.text,
    borderWidth: 1,
    borderColor: Colors.cardBorder,
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    color: Colors.textSecondary,
    marginBottom: 8,
    fontWeight: '600',
  },
  typeGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  typeCard: {
    flex: 1,
    minWidth: '45%',
    backgroundColor: Colors.background,
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: Colors.cardBorder,
  },
  typeCardActive: {
    backgroundColor: Colors.primary,
    borderColor: Colors.primary,
  },
  typeText: {
    marginTop: 8,
    fontSize: 12,
    color: Colors.text,
    fontWeight: '600',
  },
  typeTextActive: {
    color: Colors.background,
  },
  exerciseHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  addButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.primary,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  addButtonText: {
    color: Colors.background,
    fontSize: 14,
    fontWeight: '600',
    marginLeft: 4,
  },
  emptyText: {
    textAlign: 'center',
    color: Colors.textSecondary,
    marginVertical: 20,
  },
  exerciseItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: Colors.background,
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
  },
  exerciseInfo: {
    flex: 1,
  },
  exerciseName: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.text,
    marginBottom: 4,
  },
  exerciseDetails: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  exerciseDetailText: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  intensityBadge: {
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
  },
  intensityText: {
    fontSize: 10,
    color: Colors.background,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  exerciseActions: {
    flexDirection: 'row',
    gap: 12,
  },
  presetsSection: {
    marginTop: 16,
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: Colors.cardBorder,
  },
  presetsTitle: {
    fontSize: 14,
    color: Colors.textSecondary,
    marginBottom: 8,
  },
  presetChip: {
    backgroundColor: Colors.primaryTransparent,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
    marginRight: 8,
  },
  presetText: {
    fontSize: 12,
    color: Colors.primary,
    fontWeight: '600',
  },
  summaryCard: {
    marginHorizontal: 20,
    marginBottom: 20,
    padding: 20,
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  summaryLabel: {
    fontSize: 14,
    color: Colors.textSecondary,
  },
  summaryValue: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.text,
  },
  saveButton: {
    marginHorizontal: 20,
    marginBottom: 40,
  },
  modalOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    padding: 20,
  },
  modalContent: {
    maxHeight: '90%',
    padding: 20,
  },
  modalTitle: {
    color: Colors.text,
    marginBottom: 20,
    fontWeight: '600',
    textAlign: 'center',
  },
  categoryGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 16,
  },
  categoryChip: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: Colors.background,
    borderWidth: 1,
    borderColor: Colors.cardBorder,
  },
  categoryChipActive: {
    backgroundColor: Colors.primary,
    borderColor: Colors.primary,
  },
  categoryChipText: {
    fontSize: 14,
    color: Colors.text,
  },
  categoryChipTextActive: {
    color: Colors.background,
  },
  inputRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 16,
  },
  inputGroup: {
    flex: 1,
  },
  smallInput: {
    marginBottom: 0,
  },
  intensityGrid: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 16,
  },
  intensityOption: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 8,
    backgroundColor: Colors.background,
    borderWidth: 2,
    borderColor: Colors.cardBorder,
    alignItems: 'center',
  },
  intensityOptionText: {
    fontSize: 14,
    fontWeight: '600',
    color: Colors.text,
  },
  intensityOptionTextActive: {
    color: Colors.background,
  },
  textArea: {
    height: 80,
    textAlignVertical: 'top',
  },
  modalButtons: {
    flexDirection: 'row',
    gap: 12,
  },
  modalButton: {
    flex: 1,
  },
});
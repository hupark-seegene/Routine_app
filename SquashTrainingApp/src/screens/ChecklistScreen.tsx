import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  SafeAreaView,
  TextInput,
  Modal,
  Alert,
  ActivityIndicator,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Slider } from '../components/common';
import DatabaseService from '../services/DatabaseService';
import { DailyWorkout, Exercise as DBExercise, WorkoutLog } from '../types';
import { Colors } from '../styles/colors';

interface Exercise {
  id: number;
  name: string;
  category: string;
  sets?: number;
  reps?: number;
  duration?: number;
  completed: boolean;
}

interface ConditionData {
  intensity: number;
  condition: number;
  fatigue: number;
  muscleSoreness: number;
  sleepQuality: number;
}

const ChecklistScreen = () => {
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [loading, setLoading] = useState(true);
  const [dailyWorkout, setDailyWorkout] = useState<DailyWorkout | null>(null);
  const [workoutStartTime, setWorkoutStartTime] = useState<Date | null>(null);

  const [conditionModalVisible, setConditionModalVisible] = useState(false);
  const [selectedExercise, setSelectedExercise] = useState<Exercise | null>(null);
  const [conditionData, setConditionData] = useState<ConditionData>({
    intensity: 5,
    condition: 5,
    fatigue: 5,
    muscleSoreness: 3,
    sleepQuality: 7,
  });
  const [notes, setNotes] = useState('');

  // Load today's workout from database
  useEffect(() => {
    loadTodayWorkout();
  }, []);

  const loadTodayWorkout = async () => {
    try {
      setLoading(true);
      await DatabaseService.init();
      
      // Get user profile
      const profile = await DatabaseService.getUserProfile();
      const userId = profile?.id || 1;
      
      // Get today's workout
      const todayWorkout = await DatabaseService.getTodayWorkout(userId);
      
      if (todayWorkout && todayWorkout.exercises) {
        setDailyWorkout(todayWorkout);
        // Convert database exercises to checklist format
        const checklistExercises: Exercise[] = todayWorkout.exercises.map((ex: DBExercise) => ({
          id: ex.id,
          name: ex.name,
          category: ex.category,
          sets: ex.sets,
          reps: ex.reps,
          duration: ex.duration_minutes,
          completed: false,
        }));
        setExercises(checklistExercises);
      } else {
        // If no workout scheduled, use default exercises
        setExercises([
          { id: 1, name: '포핸드 드라이브 드릴', category: 'skill', sets: 3, reps: 20, completed: false },
          { id: 2, name: '백핸드 크로스코트', category: 'skill', sets: 3, reps: 20, completed: false },
          { id: 3, name: '부스터 샷 연습', category: 'skill', sets: 5, reps: 10, completed: false },
          { id: 4, name: '스쿼트', category: 'strength', sets: 4, reps: 12, completed: false },
          { id: 5, name: '런지', category: 'strength', sets: 3, reps: 15, completed: false },
          { id: 6, name: '인터벌 러닝', category: 'cardio', duration: 20, completed: false },
        ]);
      }
    } catch (error) {
      console.error('Error loading today\'s workout:', error);
      Alert.alert('오류', '운동 정보를 불러오는데 실패했습니다.');
    } finally {
      setLoading(false);
    }
  };

  const getCategoryColor = (category: string) => {
    switch (category) {
      case 'skill': return '#4ECDC4';
      case 'strength': return '#FF6B6B';
      case 'cardio': return '#45B7D1';
      case 'fitness': return '#FFA500';
      default: return '#999';
    }
  };

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'skill': return 'sports-tennis';
      case 'strength': return 'fitness-center';
      case 'cardio': return 'directions-run';
      case 'fitness': return 'accessibility';
      default: return 'check-circle';
    }
  };

  const toggleExercise = (id: number) => {
    const exercise = exercises.find(e => e.id === id);
    if (exercise && !exercise.completed) {
      if (!workoutStartTime) {
        setWorkoutStartTime(new Date());
      }
      setSelectedExercise(exercise);
      setConditionModalVisible(true);
    } else {
      setExercises(exercises.map(ex =>
        ex.id === id ? { ...ex, completed: !ex.completed } : ex
      ));
    }
  };

  const saveConditionData = async () => {
    if (selectedExercise) {
      try {
        // Update exercise as completed
        const updatedExercises = exercises.map(ex =>
          ex.id === selectedExercise.id ? { ...ex, completed: true } : ex
        );
        setExercises(updatedExercises);
        
        // Check if all exercises are completed
        const allCompleted = updatedExercises.every(ex => ex.completed);
        
        if (allCompleted && workoutStartTime) {
          // Save workout log to database
          const profile = await DatabaseService.getUserProfile();
          const userId = profile?.id || 1;
          const activeProgram = await DatabaseService.getActiveProgram();
          
          const workoutLog: Omit<WorkoutLog, 'id' | 'logged_at'> = {
            user_id: userId,
            program_id: activeProgram?.id || 0,
            workout_id: dailyWorkout?.id || 0,
            date: new Date().toISOString().split('T')[0],
            duration_minutes: Math.floor((new Date().getTime() - workoutStartTime.getTime()) / 60000),
            intensity_level: conditionData.intensity,
            fatigue_level: conditionData.fatigue,
            condition_score: conditionData.condition,
            exercises_completed: updatedExercises.map(ex => ex.id),
            notes: notes,
          };
          
          await DatabaseService.saveWorkoutLog(workoutLog);
          
          // Save AI advice context
          await DatabaseService.saveAIAdvice({
            user_id: userId,
            date: new Date().toISOString().split('T')[0],
            advice_type: 'post_workout',
            content: `Workout completed with intensity ${conditionData.intensity}/10, fatigue ${conditionData.fatigue}/10`,
            context_data: {
              ...conditionData,
              exercises: updatedExercises,
              duration: workoutLog.duration_minutes,
            },
            applied: false,
          });
          
          Alert.alert('운동 완료!', '오늘의 운동이 성공적으로 기록되었습니다.');
        } else {
          Alert.alert('저장 완료', '운동 기록이 저장되었습니다.');
        }
        
        setConditionModalVisible(false);
        setSelectedExercise(null);
        setNotes('');
      } catch (error) {
        console.error('Error saving workout data:', error);
        Alert.alert('오류', '운동 기록 저장에 실패했습니다.');
      }
    }
  };

  const getCompletionRate = () => {
    const completed = exercises.filter(ex => ex.completed).length;
    return Math.round((completed / exercises.length) * 100);
  };

  const renderSlider = (label: string, value: number, onChange: (value: number) => void) => (
    <View style={styles.sliderContainer}>
      <Text style={styles.sliderLabel}>{label}</Text>
      <View style={styles.sliderRow}>
        <Text style={styles.sliderValue}>1</Text>
        <Slider
          style={styles.slider}
          minimumValue={1}
          maximumValue={10}
          value={value}
          onValueChange={onChange}
          minimumTrackTintColor="#4CAF50"
          maximumTrackTintColor="#e0e0e0"
          thumbTintColor="#4CAF50"
        />
        <Text style={styles.sliderValue}>10</Text>
      </View>
      <Text style={styles.currentValue}>현재: {Math.round(value)}</Text>
    </View>
  );

  if (loading) {
    return (
      <SafeAreaView style={[styles.container, styles.loadingContainer]}>
        <ActivityIndicator size="large" color={Colors.primary} />
        <Text style={styles.loadingText}>운동 정보를 불러오는 중...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.date}>{new Date().toLocaleDateString('ko-KR', { 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric',
            weekday: 'long'
          })}</Text>
          <View style={styles.progressContainer}>
            <Text style={styles.progressText}>오늘의 완료율: {getCompletionRate()}%</Text>
            <View style={styles.progressBar}>
              <View style={[styles.progressFill, { width: `${getCompletionRate()}%` }]} />
            </View>
          </View>
        </View>

        {/* Exercise List */}
        <View style={styles.exerciseSection}>
          <Text style={styles.sectionTitle}>오늘의 운동</Text>
          {exercises.map((exercise) => (
            <TouchableOpacity
              key={exercise.id}
              style={[
                styles.exerciseCard,
                exercise.completed && styles.exerciseCardCompleted
              ]}
              onPress={() => toggleExercise(exercise.id)}
            >
              <View style={[styles.categoryIcon, { backgroundColor: getCategoryColor(exercise.category) }]}>
                <Icon name={getCategoryIcon(exercise.category)} size={24} color="#fff" />
              </View>
              <View style={styles.exerciseInfo}>
                <Text style={[
                  styles.exerciseName,
                  exercise.completed && styles.exerciseNameCompleted
                ]}>
                  {exercise.name}
                </Text>
                <Text style={styles.exerciseDetails}>
                  {exercise.sets && exercise.reps 
                    ? `${exercise.sets}세트 × ${exercise.reps}회`
                    : exercise.duration 
                    ? `${exercise.duration}분`
                    : ''
                  }
                </Text>
              </View>
              <Icon 
                name={exercise.completed ? 'check-circle' : 'radio-button-unchecked'} 
                size={24} 
                color={exercise.completed ? '#4CAF50' : '#999'} 
              />
            </TouchableOpacity>
          ))}
        </View>

        {/* Summary */}
        <View style={styles.summarySection}>
          <Text style={styles.sectionTitle}>오늘의 요약</Text>
          <View style={styles.summaryGrid}>
            <View style={styles.summaryCard}>
              <Icon name="fitness-center" size={30} color="#4CAF50" />
              <Text style={styles.summaryNumber}>
                {exercises.filter(ex => ex.completed).length}/{exercises.length}
              </Text>
              <Text style={styles.summaryLabel}>완료된 운동</Text>
            </View>
            <View style={styles.summaryCard}>
              <Icon name="timer" size={30} color="#FF6B6B" />
              <Text style={styles.summaryNumber}>45분</Text>
              <Text style={styles.summaryLabel}>운동 시간</Text>
            </View>
          </View>
        </View>
      </ScrollView>

      {/* Condition Modal */}
      <Modal
        animationType="slide"
        transparent={true}
        visible={conditionModalVisible}
        onRequestClose={() => setConditionModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>운동 완료 기록</Text>
            {selectedExercise && (
              <Text style={styles.modalExerciseName}>{selectedExercise.name}</Text>
            )}
            
            {renderSlider('운동 강도', conditionData.intensity, (value) => 
              setConditionData({...conditionData, intensity: value})
            )}
            {renderSlider('현재 컨디션', conditionData.condition, (value) => 
              setConditionData({...conditionData, condition: value})
            )}
            {renderSlider('피로도', conditionData.fatigue, (value) => 
              setConditionData({...conditionData, fatigue: value})
            )}
            {renderSlider('근육통', conditionData.muscleSoreness, (value) => 
              setConditionData({...conditionData, muscleSoreness: value})
            )}
            {renderSlider('수면 상태', conditionData.sleepQuality, (value) => 
              setConditionData({...conditionData, sleepQuality: value})
            )}

            <Text style={styles.notesLabel}>메모 (선택사항)</Text>
            <TextInput
              style={styles.notesInput}
              multiline
              numberOfLines={3}
              value={notes}
              onChangeText={setNotes}
              placeholder="오늘의 운동은 어땠나요?"
            />

            <View style={styles.modalButtons}>
              <TouchableOpacity
                style={[styles.modalButton, styles.cancelButton]}
                onPress={() => setConditionModalVisible(false)}
              >
                <Text style={styles.cancelButtonText}>취소</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.saveButton]}
                onPress={saveConditionData}
              >
                <Text style={styles.saveButtonText}>저장</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  loadingContainer: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: Colors.text,
  },
  header: {
    backgroundColor: '#fff',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  date: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginBottom: 10,
  },
  progressContainer: {
    marginTop: 10,
  },
  progressText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  progressBar: {
    height: 8,
    backgroundColor: '#e0e0e0',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#4CAF50',
  },
  exerciseSection: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  exerciseCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 15,
    marginBottom: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  exerciseCardCompleted: {
    opacity: 0.7,
  },
  categoryIcon: {
    width: 50,
    height: 50,
    borderRadius: 25,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 15,
  },
  exerciseInfo: {
    flex: 1,
  },
  exerciseName: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  exerciseNameCompleted: {
    textDecorationLine: 'line-through',
    color: '#999',
  },
  exerciseDetails: {
    fontSize: 14,
    color: '#666',
    marginTop: 3,
  },
  summarySection: {
    padding: 20,
  },
  summaryGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  summaryCard: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
    alignItems: 'center',
    flex: 1,
    marginHorizontal: 5,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  summaryNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginTop: 10,
  },
  summaryLabel: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
    maxHeight: '80%',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 10,
  },
  modalExerciseName: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 20,
  },
  sliderContainer: {
    marginBottom: 20,
  },
  sliderLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  sliderRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  slider: {
    flex: 1,
    height: 40,
  },
  sliderValue: {
    fontSize: 14,
    color: '#666',
    width: 20,
    textAlign: 'center',
  },
  currentValue: {
    fontSize: 14,
    color: '#4CAF50',
    textAlign: 'center',
    marginTop: 5,
  },
  notesLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 10,
  },
  notesInput: {
    borderWidth: 1,
    borderColor: '#e0e0e0',
    borderRadius: 10,
    padding: 10,
    fontSize: 14,
    minHeight: 80,
    textAlignVertical: 'top',
  },
  modalButtons: {
    flexDirection: 'row',
    marginTop: 20,
  },
  modalButton: {
    flex: 1,
    paddingVertical: 15,
    borderRadius: 10,
    marginHorizontal: 5,
  },
  cancelButton: {
    backgroundColor: '#f0f0f0',
  },
  saveButton: {
    backgroundColor: '#4CAF50',
  },
  cancelButtonText: {
    color: '#666',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  saveButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
});

export default ChecklistScreen;
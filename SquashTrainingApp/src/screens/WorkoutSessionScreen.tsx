import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  SafeAreaView,
  Alert,
  TextInput,
  ActivityIndicator,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import { ProgramQueries } from '../database/ProgramQueries';
import { Colors } from '../styles';

type WorkoutSessionRouteProp = RouteProp<RootStackParamList, 'WorkoutSession'>;
type WorkoutSessionNavigationProp = StackNavigationProp<RootStackParamList, 'WorkoutSession'>;

const WorkoutSessionScreen = () => {
  const navigation = useNavigation<WorkoutSessionNavigationProp>();
  const route = useRoute<WorkoutSessionRouteProp>();
  const { sessionId, enrollmentId } = route.params;
  
  const [loading, setLoading] = useState(true);
  const [session, setSession] = useState<any>(null);
  const [progress, setProgress] = useState<any>(null);
  const [startTime, setStartTime] = useState<Date | null>(null);
  const [duration, setDuration] = useState(0);
  const [notes, setNotes] = useState('');
  const [timerInterval, setTimerInterval] = useState<any>(null);
  const [completedExercises, setCompletedExercises] = useState<string[]>([]);
  
  useEffect(() => {
    loadSessionData();
    return () => {
      if (timerInterval) {
        clearInterval(timerInterval);
      }
    };
  }, []);
  
  const loadSessionData = async () => {
    try {
      setLoading(true);
      const programProgress = await ProgramQueries.getProgramProgress(enrollmentId);
      if (programProgress) {
        setProgress(programProgress);
        
        // Find current session
        const currentSession = programProgress.nextWorkout;
        if (currentSession && currentSession.id === sessionId) {
          setSession(currentSession);
        }
      }
    } catch (error) {
      console.error('Error loading session:', error);
      Alert.alert('오류', '세션 로드에 실패했습니다.');
    } finally {
      setLoading(false);
    }
  };
  
  const handleStartWorkout = () => {
    setStartTime(new Date());
    const interval = setInterval(() => {
      setDuration(prev => prev + 1);
    }, 1000);
    setTimerInterval(interval);
  };
  
  const handlePauseWorkout = () => {
    if (timerInterval) {
      clearInterval(timerInterval);
      setTimerInterval(null);
    }
  };
  
  const handleResumeWorkout = () => {
    const interval = setInterval(() => {
      setDuration(prev => prev + 1);
    }, 1000);
    setTimerInterval(interval);
  };
  
  const handleCompleteWorkout = () => {
    Alert.alert(
      '운동 완료',
      '이 운동을 완료하시겠습니까?',
      [
        { text: '취소', style: 'cancel' },
        {
          text: '완료',
          onPress: async () => {
            try {
              if (timerInterval) {
                clearInterval(timerInterval);
              }
              
              const finalDuration = Math.round(duration / 60); // Convert to minutes
              await ProgramQueries.completeWorkoutSession(sessionId, finalDuration, notes);
              
              Alert.alert(
                '축하합니다!',
                '운동을 완료했습니다!',
                [{ 
                  text: '확인', 
                  onPress: () => navigation.navigate('MainTabs', { screen: 'Home' })
                }]
              );
            } catch (error) {
              Alert.alert('오류', '운동 완료 처리에 실패했습니다.');
            }
          }
        }
      ]
    );
  };
  
  const toggleExercise = (exercise: string) => {
    setCompletedExercises(prev => {
      if (prev.includes(exercise)) {
        return prev.filter(e => e !== exercise);
      } else {
        return [...prev, exercise];
      }
    });
  };
  
  const formatDuration = (seconds: number) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    
    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    return `${minutes}:${secs.toString().padStart(2, '0')}`;
  };
  
  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={Colors.accentVolt} />
          <Text style={styles.loadingText}>세션 로딩 중...</Text>
        </View>
      </SafeAreaView>
    );
  }
  
  if (!session) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.errorContainer}>
          <Icon name="error-outline" size={60} color="#999" />
          <Text style={styles.errorText}>세션을 찾을 수 없습니다</Text>
          <TouchableOpacity 
            style={styles.backButton}
            onPress={() => navigation.goBack()}
          >
            <Text style={styles.backButtonText}>돌아가기</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }
  
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.weekDay}>
            Week {session.weekNumber}, Day {session.dayNumber}
          </Text>
          <Text style={styles.workoutType}>{session.workoutType}</Text>
        </View>
        
        {/* Timer Section */}
        <View style={styles.timerSection}>
          <Text style={styles.timerLabel}>운동 시간</Text>
          <Text style={styles.timer}>{formatDuration(duration)}</Text>
          
          <View style={styles.timerControls}>
            {!startTime ? (
              <TouchableOpacity 
                style={styles.startButton} 
                onPress={handleStartWorkout}
              >
                <Icon name="play-arrow" size={30} color="#fff" />
                <Text style={styles.controlButtonText}>시작</Text>
              </TouchableOpacity>
            ) : (
              <>
                {timerInterval ? (
                  <TouchableOpacity 
                    style={styles.pauseButton} 
                    onPress={handlePauseWorkout}
                  >
                    <Icon name="pause" size={30} color="#fff" />
                    <Text style={styles.controlButtonText}>일시정지</Text>
                  </TouchableOpacity>
                ) : (
                  <TouchableOpacity 
                    style={styles.resumeButton} 
                    onPress={handleResumeWorkout}
                  >
                    <Icon name="play-arrow" size={30} color="#fff" />
                    <Text style={styles.controlButtonText}>재개</Text>
                  </TouchableOpacity>
                )}
                <TouchableOpacity 
                  style={styles.stopButton} 
                  onPress={handleCompleteWorkout}
                >
                  <Icon name="stop" size={30} color="#fff" />
                  <Text style={styles.controlButtonText}>완료</Text>
                </TouchableOpacity>
              </>
            )}
          </View>
        </View>
        
        {/* Exercise List */}
        <View style={styles.exerciseSection}>
          <Text style={styles.sectionTitle}>운동 목록</Text>
          {session.exercises.map((exercise: string, index: number) => (
            <TouchableOpacity
              key={index}
              style={styles.exerciseItem}
              onPress={() => toggleExercise(exercise)}
            >
              <View style={styles.exerciseCheckbox}>
                {completedExercises.includes(exercise) && (
                  <Icon name="check" size={20} color="#4CAF50" />
                )}
              </View>
              <Text style={[
                styles.exerciseName,
                completedExercises.includes(exercise) && styles.completedExercise
              ]}>
                {exercise}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
        
        {/* Notes Section */}
        <View style={styles.notesSection}>
          <Text style={styles.sectionTitle}>메모</Text>
          <TextInput
            style={styles.notesInput}
            placeholder="운동에 대한 메모를 남겨보세요..."
            multiline
            value={notes}
            onChangeText={setNotes}
            textAlignVertical="top"
          />
        </View>
        
        {/* Progress Overview */}
        {progress && (
          <View style={styles.progressOverview}>
            <Text style={styles.sectionTitle}>전체 진행도</Text>
            <View style={styles.progressBar}>
              <View 
                style={[styles.progressFill, { width: `${progress.overallProgress}%` }]} 
              />
            </View>
            <Text style={styles.progressText}>
              프로그램 {progress.overallProgress}% 완료
            </Text>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
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
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  errorText: {
    fontSize: 18,
    color: '#666',
    marginTop: 10,
    marginBottom: 20,
  },
  backButton: {
    paddingHorizontal: 20,
    paddingVertical: 10,
    backgroundColor: '#4CAF50',
    borderRadius: 20,
  },
  backButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  header: {
    backgroundColor: '#fff',
    padding: 20,
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  weekDay: {
    fontSize: 16,
    color: '#666',
    marginBottom: 5,
  },
  workoutType: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
  },
  timerSection: {
    backgroundColor: '#fff',
    marginTop: 10,
    padding: 20,
    alignItems: 'center',
  },
  timerLabel: {
    fontSize: 16,
    color: '#666',
    marginBottom: 10,
  },
  timer: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
  },
  timerControls: {
    flexDirection: 'row',
    gap: 15,
  },
  startButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#4CAF50',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 25,
    gap: 10,
  },
  pauseButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FF9800',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 25,
    gap: 10,
  },
  resumeButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#4CAF50',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 25,
    gap: 10,
  },
  stopButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F44336',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 25,
    gap: 10,
  },
  controlButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  exerciseSection: {
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
  exerciseItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  exerciseCheckbox: {
    width: 24,
    height: 24,
    borderWidth: 2,
    borderColor: '#ddd',
    borderRadius: 4,
    marginRight: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  exerciseName: {
    fontSize: 16,
    color: '#333',
    flex: 1,
  },
  completedExercise: {
    textDecorationLine: 'line-through',
    color: '#999',
  },
  notesSection: {
    backgroundColor: '#fff',
    marginTop: 10,
    padding: 20,
  },
  notesInput: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    minHeight: 100,
    color: '#333',
  },
  progressOverview: {
    backgroundColor: '#fff',
    marginTop: 10,
    marginBottom: 20,
    padding: 20,
  },
  progressBar: {
    height: 8,
    backgroundColor: '#e0e0e0',
    borderRadius: 4,
    marginTop: 10,
    marginBottom: 5,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#4CAF50',
    borderRadius: 4,
  },
  progressText: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginTop: 5,
  },
});

export default WorkoutSessionScreen;
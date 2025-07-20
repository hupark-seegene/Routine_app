import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  SafeAreaView,
  Alert,
  ActivityIndicator,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import { ProgramQueries } from '../database/ProgramQueries';

type ProgramDetailRouteProp = RouteProp<RootStackParamList, 'ProgramDetail'>;
type ProgramDetailNavigationProp = StackNavigationProp<RootStackParamList, 'ProgramDetail'>;

const ProgramDetailScreen = () => {
  const navigation = useNavigation<ProgramDetailNavigationProp>();
  const route = useRoute<ProgramDetailRouteProp>();
  const { programId, programName } = route.params;
  
  const [loading, setLoading] = useState(false);
  const [enrollment, setEnrollment] = useState<any>(null);
  const [progress, setProgress] = useState<any>(null);

  // 프로그램별 상세 정보
  const programDetails = {
    1: {
      weeks: [
        {
          week: 1,
          phase: '준비 단계',
          focus: '기초 체력 및 적응',
          description: '운동에 몸을 적응시키고 기본기를 다지는 주간',
          workouts: [
            { day: '월', type: '피트니스', exercises: ['스쿼트', '런지', '플랭크'] },
            { day: '화', type: '스쿼시', exercises: ['포핸드 드라이브', '백핸드 연습'] },
            { day: '수', type: '피트니스', exercises: ['인터벌 러닝', '코어 운동'] },
            { day: '목', type: '휴식', exercises: [] },
            { day: '금', type: '스쿼시', exercises: ['볼리 연습', '서브 연습'] },
            { day: '토', type: '피트니스', exercises: ['전신 운동'] },
            { day: '일', type: '휴식', exercises: [] },
          ],
        },
        {
          week: 2,
          phase: '강도 증가',
          focus: '강도 증가 및 기술 연습',
          description: '운동 강도를 점진적으로 높이며 기술을 발전시키는 주간',
          workouts: [
            { day: '월', type: '스쿼시', exercises: ['고강도 드릴', '게임 시뮬레이션'] },
            { day: '화', type: '피트니스', exercises: ['웨이트 트레이닝', '민첩성 훈련'] },
            { day: '수', type: '스쿼시', exercises: ['전술 훈련', '포지션 연습'] },
            { day: '목', type: '피트니스', exercises: ['회복 운동', '스트레칭'] },
            { day: '금', type: '스쿼시', exercises: ['매치 플레이'] },
            { day: '토', type: '피트니스', exercises: ['고강도 인터벌'] },
            { day: '일', type: '휴식', exercises: [] },
          ],
        },
      ],
    },
    2: {
      weeks: [
        {
          week: 1,
          phase: '기초 구축',
          focus: '기초 체력 구축',
          description: '12주 프로그램의 첫 단계로 기초를 탄탄히 다지는 주간',
          workouts: [
            { day: '월', type: '피트니스', exercises: ['기초 근력 운동'] },
            { day: '화', type: '스쿼시', exercises: ['기본기 훈련'] },
            { day: '수', type: '피트니스', exercises: ['유산소 운동'] },
            { day: '목', type: '스쿼시', exercises: ['기술 연습'] },
            { day: '금', type: '피트니스', exercises: ['복합 운동'] },
            { day: '토', type: '스쿼시', exercises: ['게임 연습'] },
            { day: '일', type: '휴식', exercises: [] },
          ],
        },
      ],
    },
    3: {
      weeks: [
        {
          week: 1,
          phase: '시즌 준비',
          focus: '시즌 준비 단계',
          description: '1년 계획의 시작으로 전반적인 컨디션을 끌어올리는 주간',
          workouts: [
            { day: '월', type: '종합', exercises: ['체력 테스트', '기량 평가'] },
            { day: '화', type: '스쿼시', exercises: ['기술 점검'] },
            { day: '수', type: '피트니스', exercises: ['기초 체력'] },
            { day: '목', type: '스쿼시', exercises: ['전략 수립'] },
            { day: '금', type: '종합', exercises: ['복합 훈련'] },
            { day: '토', type: '스쿼시', exercises: ['실전 연습'] },
            { day: '일', type: '휴식', exercises: [] },
          ],
        },
      ],
    },
  };

  const currentProgram = programDetails[programId as keyof typeof programDetails] || programDetails[1];

  const getWorkoutTypeColor = (type: string) => {
    switch (type) {
      case '스쿼시': return '#4ECDC4';
      case '피트니스': return '#FF6B6B';
      case '휴식': return '#999';
      case '종합': return '#FF9800';
      default: return '#666';
    }
  };

  useEffect(() => {
    checkEnrollmentStatus();
  }, []);

  const checkEnrollmentStatus = async () => {
    try {
      setLoading(true);
      const activeEnrollment = await ProgramQueries.getActiveEnrollment(1); // userId = 1
      
      if (activeEnrollment && activeEnrollment.programId === programId) {
        setEnrollment(activeEnrollment);
        const programProgress = await ProgramQueries.getProgramProgress(activeEnrollment.id);
        setProgress(programProgress);
      }
    } catch (error) {
      console.error('Error checking enrollment:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStartProgram = async () => {
    if (enrollment) {
      // Already enrolled - navigate to current workout
      if (progress?.nextWorkout) {
        navigation.navigate('WorkoutSession', { 
          sessionId: progress.nextWorkout.id,
          enrollmentId: enrollment.id,
        });
      } else {
        Alert.alert('프로그램 완료', '축하합니다! 이 프로그램을 완료했습니다.');
      }
    } else {
      // New enrollment
      Alert.alert(
        '프로그램 시작',
        `${programName}을 시작하시겠습니까?`,
        [
          { text: '취소', style: 'cancel' },
          { 
            text: '시작',
            onPress: async () => {
              try {
                setLoading(true);
                const enrollmentId = await ProgramQueries.enrollInProgram(1, programId);
                Alert.alert(
                  '성공',
                  '프로그램이 시작되었습니다!',
                  [{ text: '확인', onPress: () => checkEnrollmentStatus() }]
                );
              } catch (error) {
                Alert.alert('오류', '프로그램 시작에 실패했습니다.');
              } finally {
                setLoading(false);
              }
            }
          }
        ]
      );
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Program Header */}
        <View style={styles.header}>
          <Text style={styles.programTitle}>{programName}</Text>
          <Text style={styles.programDescription}>
            {programId === 1 && '4주 동안 집중적으로 기초 체력과 스킬을 향상시키는 프로그램'}
            {programId === 2 && '12주에 걸쳐 체력, 기술, 전술을 균형있게 발전시키는 프로그램'}
            {programId === 3 && '1년 동안 시합 주기에 맞춰 체계적으로 훈련하는 프로그램'}
          </Text>
        </View>

        {/* Weekly Plans */}
        {currentProgram.weeks.map((week, index) => (
          <View key={index} style={styles.weekContainer}>
            <View style={styles.weekHeader}>
              <Text style={styles.weekNumber}>Week {week.week}</Text>
              <Text style={styles.weekPhase}>{week.phase}</Text>
            </View>
            <Text style={styles.weekFocus}>{week.focus}</Text>
            <Text style={styles.weekDescription}>{week.description}</Text>

            <View style={styles.dailySchedule}>
              {week.workouts.map((workout, dayIndex) => (
                <View key={dayIndex} style={styles.dayRow}>
                  <Text style={styles.dayName}>{workout.day}</Text>
                  <View style={[styles.workoutType, { backgroundColor: getWorkoutTypeColor(workout.type) }]}>
                    <Text style={styles.workoutTypeText}>{workout.type}</Text>
                  </View>
                  <View style={styles.exerciseList}>
                    {workout.exercises.length > 0 ? (
                      workout.exercises.map((exercise, exIndex) => (
                        <Text key={exIndex} style={styles.exerciseName}>• {exercise}</Text>
                      ))
                    ) : (
                      <Text style={styles.restDay}>휴식일</Text>
                    )}
                  </View>
                </View>
              ))}
            </View>
          </View>
        ))}

        {/* Key Features */}
        <View style={styles.featuresSection}>
          <Text style={styles.sectionTitle}>프로그램 특징</Text>
          <View style={styles.featureItem}>
            <Icon name="trending-up" size={24} color="#4CAF50" />
            <Text style={styles.featureText}>점진적 강도 증가로 부상 위험 최소화</Text>
          </View>
          <View style={styles.featureItem}>
            <Icon name="balance" size={24} color="#4CAF50" />
            <Text style={styles.featureText}>스쿼시 기술과 체력 훈련의 균형</Text>
          </View>
          <View style={styles.featureItem}>
            <Icon name="track-changes" size={24} color="#4CAF50" />
            <Text style={styles.featureText}>개인 컨디션에 따른 유연한 조정 가능</Text>
          </View>
          <View style={styles.featureItem}>
            <Icon name="psychology" size={24} color="#4CAF50" />
            <Text style={styles.featureText}>AI 기반 맞춤형 조언 제공</Text>
          </View>
        </View>

        {/* Progress Section */}
        {enrollment && progress && (
          <View style={styles.progressSection}>
            <Text style={styles.sectionTitle}>진행 상황</Text>
            <View style={styles.progressBar}>
              <View 
                style={[styles.progressFill, { width: `${progress.overallProgress}%` }]} 
              />
            </View>
            <Text style={styles.progressText}>
              {progress.completedWorkouts}/{progress.totalWorkouts} 운동 완료 ({progress.overallProgress}%)
            </Text>
            <View style={styles.currentStatus}>
              <Icon name="calendar-today" size={20} color="#666" />
              <Text style={styles.statusText}>
                현재: Week {enrollment.currentWeek}, Day {enrollment.currentDay}
              </Text>
            </View>
            {progress.nextWorkout && (
              <View style={styles.nextWorkout}>
                <Icon name="fitness-center" size={20} color="#4CAF50" />
                <Text style={styles.nextWorkoutText}>
                  다음 운동: {progress.nextWorkout.workoutType}
                </Text>
              </View>
            )}
          </View>
        )}

        {/* Start/Continue Button */}
        <TouchableOpacity 
          style={[styles.startButton, loading && styles.disabledButton]} 
          onPress={handleStartProgram}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.startButtonText}>
              {enrollment ? '운동 계속하기' : '프로그램 시작하기'}
            </Text>
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
  header: {
    backgroundColor: '#fff',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  programTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  programDescription: {
    fontSize: 16,
    color: '#666',
    lineHeight: 24,
  },
  weekContainer: {
    backgroundColor: '#fff',
    marginTop: 10,
    padding: 20,
  },
  weekHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  weekNumber: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  weekPhase: {
    fontSize: 14,
    color: '#4CAF50',
    fontWeight: '600',
  },
  weekFocus: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  weekDescription: {
    fontSize: 14,
    color: '#666',
    marginBottom: 15,
  },
  dailySchedule: {
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
    paddingTop: 15,
  },
  dayRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 10,
  },
  dayName: {
    width: 30,
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  workoutType: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
    marginHorizontal: 10,
  },
  workoutTypeText: {
    fontSize: 12,
    color: '#fff',
    fontWeight: '600',
  },
  exerciseList: {
    flex: 1,
  },
  exerciseName: {
    fontSize: 14,
    color: '#666',
    marginBottom: 2,
  },
  restDay: {
    fontSize: 14,
    color: '#999',
    fontStyle: 'italic',
  },
  featuresSection: {
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
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
  },
  featureText: {
    fontSize: 15,
    color: '#666',
    marginLeft: 15,
    flex: 1,
  },
  startButton: {
    backgroundColor: '#4CAF50',
    margin: 20,
    paddingVertical: 15,
    borderRadius: 25,
    alignItems: 'center',
  },
  startButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
  progressSection: {
    backgroundColor: '#fff',
    marginTop: 10,
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
    marginBottom: 15,
  },
  currentStatus: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  statusText: {
    fontSize: 15,
    color: '#333',
    marginLeft: 10,
  },
  nextWorkout: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#e8f5e9',
    padding: 10,
    borderRadius: 8,
  },
  nextWorkoutText: {
    fontSize: 15,
    color: '#4CAF50',
    fontWeight: '600',
    marginLeft: 10,
  },
  disabledButton: {
    opacity: 0.7,
  },
});

export default ProgramDetailScreen;
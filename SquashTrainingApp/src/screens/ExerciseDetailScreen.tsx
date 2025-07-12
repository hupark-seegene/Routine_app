import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useRoute, RouteProp } from '@react-navigation/native';
import { RootStackParamList } from '../navigation/AppNavigator';

type ExerciseDetailRouteProp = RouteProp<RootStackParamList, 'ExerciseDetail'>;

const ExerciseDetailScreen = () => {
  const route = useRoute<ExerciseDetailRouteProp>();
  const { exerciseId, exerciseName } = route.params;

  // 운동별 상세 정보 (실제 앱에서는 DB에서 가져옴)
  const exerciseDetails = {
    name: exerciseName,
    category: 'skill',
    difficulty: '중급',
    duration: '15-20분',
    equipment: '스쿼시 라켓, 공',
    targetMuscles: ['어깨', '팔', '코어'],
    description: '포핸드 드라이브는 스쿼시의 가장 기본적이면서도 중요한 샷입니다. 정확한 스윙 궤적과 타이밍이 중요합니다.',
    instructions: [
      '준비 자세: 어깨 너비로 발을 벌리고 무릎을 살짝 굽힙니다',
      '그립: 라켓을 V자 그립으로 잡습니다',
      '백스윙: 라켓을 어깨 높이까지 들어올립니다',
      '임팩트: 공을 정확한 타점에서 맞춥니다',
      '팔로우스루: 스윙을 끝까지 완성합니다',
    ],
    tips: [
      '체중 이동을 활용하여 파워를 증가시키세요',
      '공을 보는 시선을 끝까지 유지하세요',
      '리듬감 있게 스윙하는 것이 중요합니다',
    ],
    commonMistakes: [
      '타점이 너무 앞이나 뒤에 있는 경우',
      '손목만 사용하여 치는 경우',
      '스윙이 너무 크거나 작은 경우',
    ],
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Exercise Header */}
        <View style={styles.header}>
          <View style={styles.categoryBadge}>
            <Text style={styles.categoryText}>스킬 훈련</Text>
          </View>
          <Text style={styles.exerciseName}>{exerciseDetails.name}</Text>
          <Text style={styles.description}>{exerciseDetails.description}</Text>
        </View>

        {/* Quick Info */}
        <View style={styles.quickInfo}>
          <View style={styles.infoItem}>
            <Icon name="timer" size={20} color="#666" />
            <Text style={styles.infoLabel}>소요 시간</Text>
            <Text style={styles.infoValue}>{exerciseDetails.duration}</Text>
          </View>
          <View style={styles.infoItem}>
            <Icon name="trending-up" size={20} color="#666" />
            <Text style={styles.infoLabel}>난이도</Text>
            <Text style={styles.infoValue}>{exerciseDetails.difficulty}</Text>
          </View>
          <View style={styles.infoItem}>
            <Icon name="sports-tennis" size={20} color="#666" />
            <Text style={styles.infoLabel}>준비물</Text>
            <Text style={styles.infoValue}>{exerciseDetails.equipment}</Text>
          </View>
        </View>

        {/* Target Muscles */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>주요 근육</Text>
          <View style={styles.muscleList}>
            {exerciseDetails.targetMuscles.map((muscle, index) => (
              <View key={index} style={styles.muscleTag}>
                <Text style={styles.muscleText}>{muscle}</Text>
              </View>
            ))}
          </View>
        </View>

        {/* Instructions */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>운동 방법</Text>
          {exerciseDetails.instructions.map((instruction, index) => (
            <View key={index} style={styles.instructionItem}>
              <View style={styles.stepNumber}>
                <Text style={styles.stepNumberText}>{index + 1}</Text>
              </View>
              <Text style={styles.instructionText}>{instruction}</Text>
            </View>
          ))}
        </View>

        {/* Tips */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>운동 팁</Text>
          {exerciseDetails.tips.map((tip, index) => (
            <View key={index} style={styles.tipItem}>
              <Icon name="lightbulb" size={20} color="#FFA500" />
              <Text style={styles.tipText}>{tip}</Text>
            </View>
          ))}
        </View>

        {/* Common Mistakes */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>주의 사항</Text>
          {exerciseDetails.commonMistakes.map((mistake, index) => (
            <View key={index} style={styles.mistakeItem}>
              <Icon name="warning" size={20} color="#F44336" />
              <Text style={styles.mistakeText}>{mistake}</Text>
            </View>
          ))}
        </View>

        {/* Video Tutorial Placeholder */}
        <View style={styles.videoSection}>
          <Icon name="play-circle-outline" size={50} color="#999" />
          <Text style={styles.videoText}>동영상 튜토리얼</Text>
          <Text style={styles.videoSubtext}>준비 중입니다</Text>
        </View>
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
  },
  categoryBadge: {
    backgroundColor: '#4ECDC4',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 15,
    alignSelf: 'flex-start',
    marginBottom: 10,
  },
  categoryText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '600',
  },
  exerciseName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  description: {
    fontSize: 16,
    color: '#666',
    lineHeight: 24,
  },
  quickInfo: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    marginTop: 10,
    padding: 20,
    justifyContent: 'space-around',
  },
  infoItem: {
    alignItems: 'center',
  },
  infoLabel: {
    fontSize: 12,
    color: '#999',
    marginTop: 5,
  },
  infoValue: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginTop: 3,
  },
  section: {
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
  muscleList: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  muscleTag: {
    backgroundColor: '#e3f2fd',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 20,
    marginRight: 10,
    marginBottom: 10,
  },
  muscleText: {
    color: '#2196F3',
    fontSize: 14,
  },
  instructionItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 15,
  },
  stepNumber: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#4CAF50',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 15,
  },
  stepNumberText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  instructionText: {
    flex: 1,
    fontSize: 15,
    color: '#666',
    lineHeight: 22,
  },
  tipItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  tipText: {
    flex: 1,
    fontSize: 15,
    color: '#666',
    marginLeft: 10,
    lineHeight: 22,
  },
  mistakeItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  mistakeText: {
    flex: 1,
    fontSize: 15,
    color: '#666',
    marginLeft: 10,
    lineHeight: 22,
  },
  videoSection: {
    backgroundColor: '#fff',
    marginTop: 10,
    marginBottom: 20,
    padding: 40,
    alignItems: 'center',
  },
  videoText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#666',
    marginTop: 10,
  },
  videoSubtext: {
    fontSize: 14,
    color: '#999',
    marginTop: 5,
  },
});

export default ExerciseDetailScreen;
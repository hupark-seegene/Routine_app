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
  FlatList,
  Alert,
  ActivityIndicator,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useAuth } from './auth/AuthContext';
import DatabaseService from '../services/DatabaseService';
import { WorkoutLog, UserMemo } from '../types';
import { Colors } from '../styles/colors';

// Types are now imported from '../types'

const RecordScreen = () => {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState<'records' | 'memos'>('records');
  const [memoModalVisible, setMemoModalVisible] = useState(false);
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [memoContent, setMemoContent] = useState('');
  const [selectedMood, setSelectedMood] = useState('');
  const [loading, setLoading] = useState(true);
  const [workoutRecords, setWorkoutRecords] = useState<WorkoutLog[]>([]);
  const [memos, setMemos] = useState<UserMemo[]>([]);
  const [stats, setStats] = useState({
    totalWorkouts: 0,
    totalMinutes: 0,
    averageIntensity: 0,
    averageCondition: 0,
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      await DatabaseService.init();
      
      const profile = await DatabaseService.getUserProfile();
      const userId = profile?.id || 1;
      
      // Load workout records
      const logs = await DatabaseService.getWorkoutLogs(userId, 30);
      setWorkoutRecords(logs);
      
      // Load memos
      const userMemos = await DatabaseService.getMemos(userId, 20);
      setMemos(userMemos);
      
      // Load statistics
      const statistics = await DatabaseService.getTrainingStats(userId, 30);
      setStats(statistics);
      
    } catch (error) {
      console.error('Error loading data:', error);
      Alert.alert('오류', '데이터를 불러오는데 실패했습니다.');
    } finally {
      setLoading(false);
    }
  };

  const moods = [
    { id: 'happy', label: '기쁨', icon: 'mood', color: '#4CAF50' },
    { id: 'motivated', label: '의욕적', icon: 'flash-on', color: '#FF9800' },
    { id: 'tired', label: '피곤', icon: 'hotel', color: '#9C27B0' },
    { id: 'frustrated', label: '답답', icon: 'mood-bad', color: '#F44336' },
    { id: 'normal', label: '보통', icon: 'sentiment-neutral', color: '#607D8B' },
  ];

  const getMoodInfo = (moodId: string) => {
    return moods.find(m => m.id === moodId) || moods[4];
  };

  const renderWorkoutRecord = ({ item }: { item: WorkoutLog }) => (
    <TouchableOpacity style={styles.recordCard}>
      <View style={styles.recordHeader}>
        <Text style={styles.recordDate}>{formatDate(item.date)}</Text>
        <Text style={styles.recordDuration}>{item.duration_minutes}분</Text>
      </View>
      
      <View style={styles.exerciseList}>
        {item.exercises_completed && item.exercises_completed.map((exerciseId, index) => (
          <View key={index} style={styles.exerciseTag}>
            <Text style={styles.exerciseTagText}>운동 {exerciseId}</Text>
          </View>
        ))}
      </View>

      <View style={styles.metricsRow}>
        <View style={styles.metric}>
          <Text style={styles.metricLabel}>운동 강도</Text>
          <View style={styles.metricBar}>
            <View style={[styles.metricFill, { width: `${item.intensity_level * 10}%`, backgroundColor: '#FF6B6B' }]} />
          </View>
          <Text style={styles.metricValue}>{item.intensity_level}/10</Text>
        </View>
        <View style={styles.metric}>
          <Text style={styles.metricLabel}>컨디션</Text>
          <View style={styles.metricBar}>
            <View style={[styles.metricFill, { width: `${item.condition_score * 10}%`, backgroundColor: '#4CAF50' }]} />
          </View>
          <Text style={styles.metricValue}>{item.condition_score}/10</Text>
        </View>
      </View>

      {item.fatigue_level && (
        <View style={styles.metric}>
          <Text style={styles.metricLabel}>피로도</Text>
          <View style={styles.metricBar}>
            <View style={[styles.metricFill, { width: `${item.fatigue_level * 10}%`, backgroundColor: '#FFA500' }]} />
          </View>
          <Text style={styles.metricValue}>{item.fatigue_level}/10</Text>
        </View>
      )}

      {item.notes && (
        <View style={styles.notesContainer}>
          <Icon name="notes" size={16} color="#666" />
          <Text style={styles.notesText}>{item.notes}</Text>
        </View>
      )}
    </TouchableOpacity>
  );

  const renderMemo = ({ item }: { item: UserMemo }) => {
    const mood = item.tags || 'normal';
    const moodInfo = getMoodInfo(mood);
    return (
      <TouchableOpacity style={styles.memoCard}>
        <View style={styles.memoHeader}>
          <Text style={styles.memoDate}>{formatDate(item.date)}</Text>
          <View style={[styles.moodIcon, { backgroundColor: moodInfo.color }]}>
            <Icon name={moodInfo.icon} size={20} color="#fff" />
          </View>
        </View>
        <Text style={styles.memoContent}>{item.content}</Text>
        <Text style={styles.memoType}>{item.type === 'technique' ? '기술' : item.type === 'physical' ? '신체' : '일반'}</Text>
      </TouchableOpacity>
    );
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('ko-KR', {
      month: 'long',
      day: 'numeric',
      weekday: 'short',
    });
  };

  const saveMemo = async () => {
    if (!memoContent.trim()) {
      Alert.alert('알림', '메모 내용을 입력해주세요.');
      return;
    }
    if (!selectedMood) {
      Alert.alert('알림', '오늘의 기분을 선택해주세요.');
      return;
    }

    try {
      const profile = await DatabaseService.getUserProfile();
      const userId = profile?.id || 1;
      
      await DatabaseService.saveMemo({
        user_id: userId,
        workout_log_id: null,
        date: new Date().toISOString().split('T')[0],
        type: 'general',
        content: memoContent,
        tags: selectedMood,
      });
      
      Alert.alert('저장 완료', '메모가 저장되었습니다.');
      setMemoModalVisible(false);
      setMemoContent('');
      setSelectedMood('');
      
      // Reload memos
      loadData();
    } catch (error) {
      console.error('Error saving memo:', error);
      Alert.alert('오류', '메모 저장에 실패했습니다.');
    }
  };

  const renderStatistics = () => {
    return (
      <View style={styles.statsContainer}>
        <View style={styles.statCard}>
          <Icon name="event" size={24} color="#4CAF50" />
          <Text style={styles.statNumber}>{stats.totalWorkouts}</Text>
          <Text style={styles.statLabel}>총 운동 횟수</Text>
        </View>
        <View style={styles.statCard}>
          <Icon name="timer" size={24} color="#FF6B6B" />
          <Text style={styles.statNumber}>{stats.totalMinutes}분</Text>
          <Text style={styles.statLabel}>총 운동 시간</Text>
        </View>
        <View style={styles.statCard}>
          <Icon name="trending-up" size={24} color="#4ECDC4" />
          <Text style={styles.statNumber}>{stats.averageIntensity.toFixed(1)}</Text>
          <Text style={styles.statLabel}>평균 강도</Text>
        </View>
        <View style={styles.statCard}>
          <Icon name="favorite" size={24} color="#9C27B0" />
          <Text style={styles.statNumber}>{stats.averageCondition.toFixed(1)}</Text>
          <Text style={styles.statLabel}>평균 컨디션</Text>
        </View>
      </View>
    );
  };

  if (loading) {
    return (
      <SafeAreaView style={[styles.container, styles.loadingContainer]}>
        <ActivityIndicator size="large" color={Colors.primary} />
        <Text style={styles.loadingText}>데이터를 불러오는 중...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      {/* Tabs */}
      <View style={styles.tabContainer}>
        <TouchableOpacity
          style={[styles.tab, activeTab === 'records' && styles.activeTab]}
          onPress={() => setActiveTab('records')}
        >
          <Text style={[styles.tabText, activeTab === 'records' && styles.activeTabText]}>
            운동 기록
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, activeTab === 'memos' && styles.activeTab]}
          onPress={() => setActiveTab('memos')}
        >
          <Text style={[styles.tabText, activeTab === 'memos' && styles.activeTabText]}>
            메모
          </Text>
        </TouchableOpacity>
      </View>

      {/* Content */}
      {activeTab === 'records' ? (
        <>
          {renderStatistics()}
          <FlatList
            data={workoutRecords}
            renderItem={renderWorkoutRecord}
            keyExtractor={(item) => item.id.toString()}
            contentContainerStyle={styles.listContainer}
            showsVerticalScrollIndicator={false}
          />
        </>
      ) : (
        <>
          <FlatList
            data={memos}
            renderItem={renderMemo}
            keyExtractor={(item) => item.id.toString()}
            contentContainerStyle={styles.listContainer}
            showsVerticalScrollIndicator={false}
          />
          <TouchableOpacity
            style={styles.fab}
            onPress={() => setMemoModalVisible(true)}
          >
            <Icon name="add" size={24} color="#fff" />
          </TouchableOpacity>
        </>
      )}

      {/* Memo Modal */}
      <Modal
        animationType="slide"
        transparent={true}
        visible={memoModalVisible}
        onRequestClose={() => setMemoModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>새 메모 작성</Text>
            
            <Text style={styles.moodSectionTitle}>오늘의 기분</Text>
            <View style={styles.moodGrid}>
              {moods.map((mood) => (
                <TouchableOpacity
                  key={mood.id}
                  style={[
                    styles.moodOption,
                    selectedMood === mood.id && styles.selectedMoodOption,
                    { borderColor: mood.color }
                  ]}
                  onPress={() => setSelectedMood(mood.id)}
                >
                  <Icon name={mood.icon} size={24} color={mood.color} />
                  <Text style={[styles.moodLabel, { color: mood.color }]}>
                    {mood.label}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            <Text style={styles.memoInputLabel}>메모 내용</Text>
            <TextInput
              style={styles.memoInput}
              multiline
              numberOfLines={6}
              value={memoContent}
              onChangeText={setMemoContent}
              placeholder="오늘의 운동은 어땠나요? 느낀 점이나 개선할 점을 기록해보세요."
              textAlignVertical="top"
            />

            <View style={styles.modalButtons}>
              <TouchableOpacity
                style={[styles.modalButton, styles.cancelButton]}
                onPress={() => setMemoModalVisible(false)}
              >
                <Text style={styles.cancelButtonText}>취소</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.saveButton]}
                onPress={saveMemo}
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
  tabContainer: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  tab: {
    flex: 1,
    paddingVertical: 15,
    alignItems: 'center',
  },
  activeTab: {
    borderBottomWidth: 3,
    borderBottomColor: '#4CAF50',
  },
  tabText: {
    fontSize: 16,
    color: '#666',
  },
  activeTabText: {
    color: '#4CAF50',
    fontWeight: '600',
  },
  statsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    padding: 10,
    backgroundColor: '#fff',
    marginBottom: 10,
  },
  statCard: {
    width: '50%',
    padding: 15,
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginTop: 5,
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 3,
  },
  listContainer: {
    padding: 15,
  },
  recordCard: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 15,
    marginBottom: 15,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  recordHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  recordDate: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  recordDuration: {
    fontSize: 14,
    color: '#4CAF50',
  },
  exerciseList: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 10,
  },
  exerciseTag: {
    backgroundColor: '#e8f5e9',
    borderRadius: 15,
    paddingHorizontal: 10,
    paddingVertical: 5,
    marginRight: 5,
    marginBottom: 5,
  },
  exerciseTagText: {
    fontSize: 12,
    color: '#4CAF50',
  },
  metricsRow: {
    flexDirection: 'row',
    marginBottom: 10,
  },
  metric: {
    flex: 1,
    marginRight: 10,
  },
  metricLabel: {
    fontSize: 12,
    color: '#666',
    marginBottom: 3,
  },
  metricBar: {
    height: 6,
    backgroundColor: '#e0e0e0',
    borderRadius: 3,
    overflow: 'hidden',
  },
  metricFill: {
    height: '100%',
  },
  metricValue: {
    fontSize: 12,
    color: '#666',
    marginTop: 3,
  },
  notesContainer: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
    paddingTop: 10,
  },
  notesText: {
    fontSize: 14,
    color: '#666',
    marginLeft: 5,
    flex: 1,
  },
  memoCard: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 15,
    marginBottom: 15,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  memoHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  memoDate: {
    fontSize: 14,
    color: '#666',
  },
  moodIcon: {
    width: 30,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
  },
  memoContent: {
    fontSize: 15,
    color: '#333',
    lineHeight: 22,
  },
  memoType: {
    fontSize: 12,
    color: '#999',
    marginTop: 5,
    fontStyle: 'italic',
  },
  fab: {
    position: 'absolute',
    right: 20,
    bottom: 20,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#4CAF50',
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 6,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    paddingHorizontal: 20,
  },
  modalContent: {
    backgroundColor: '#fff',
    borderRadius: 20,
    padding: 20,
    maxHeight: '80%',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 20,
  },
  moodSectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 10,
  },
  moodGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  moodOption: {
    width: '18%',
    aspectRatio: 1,
    borderWidth: 2,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10,
  },
  selectedMoodOption: {
    backgroundColor: '#f0f0f0',
  },
  moodLabel: {
    fontSize: 10,
    marginTop: 3,
  },
  memoInputLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 10,
  },
  memoInput: {
    borderWidth: 1,
    borderColor: '#e0e0e0',
    borderRadius: 10,
    padding: 15,
    fontSize: 15,
    minHeight: 120,
    marginBottom: 20,
  },
  modalButtons: {
    flexDirection: 'row',
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

export default RecordScreen;
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  RefreshControl,
  Linking,
  Image,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import aiApi from '../services/api/aiApi';
import youtubeApi from '../services/api/youtubeApi';
import DatabaseService from '../services/DatabaseService';
import { Colors } from '../styles/colors';
import { WorkoutLog } from '../types';

interface TrainingData {
  skillLevel: string;
  recentScores: number[];
  practiceFrequency: number;
  weakAreas: string[];
  goals: string[];
}

const CoachScreen: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [aiAdvice, setAiAdvice] = useState<string>('');
  const [quickTip, setQuickTip] = useState<string>('');
  const [videos, setVideos] = useState<any[]>([]);
  const [trainingData, setTrainingData] = useState<TrainingData | null>(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // Get user training data from database
      const userData = await getUserTrainingData();
      setTrainingData(userData);

      // Get quick tip immediately
      const tip = await aiApi.getQuickTip(userData.skillLevel);
      setQuickTip(tip);

      // Get AI coaching advice
      try {
        const advice = await aiApi.getCoachingAdvice(userData);
        setAiAdvice(advice.advice);
      } catch (error) {
        console.log('AI advice not available, using quick tips');
        setAiAdvice('');
      }

      // Get video recommendations
      const recommendedVideos = await youtubeApi.getRecommendedVideos(
        userData.skillLevel,
        userData.weakAreas
      );
      setVideos(recommendedVideos);
    } catch (error) {
      console.error('Error loading coach data:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const getUserTrainingData = async (): Promise<TrainingData> => {
    try {
      await DatabaseService.init();
      
      // Get complete user training data including profile, workouts, and stats
      const profile = await DatabaseService.getUserProfile();
      const userId = profile?.id || 1;
      const data = await DatabaseService.getUserTrainingData(userId);
      
      // Get recent workout logs for analysis
      const recentWorkouts = data.recentWorkouts || [];
      const recentScores = recentWorkouts
        .map(w => w.condition_score)
        .filter(score => score !== null);

      // Calculate practice frequency from stats
      const weeklyStats = await DatabaseService.getWeeklyStats(userId);
      const practiceFrequency = weeklyStats.length;

      // Analyze weak areas from recent workouts
      const weakAreas = analyzeWeakAreas(recentWorkouts);

      return {
        skillLevel: data.profile?.level || 'intermediate',
        recentScores: recentScores as number[],
        practiceFrequency,
        weakAreas,
        goals: data.profile?.goals?.split(',') || ['Improve overall game'],
      };
    } catch (error) {
      console.error('Error getting training data:', error);
      // Return default data
      return {
        skillLevel: 'beginner',
        recentScores: [],
        practiceFrequency: 0,
        weakAreas: ['forehand', 'footwork'],
        goals: ['Improve overall game'],
      };
    }
  };

  const analyzeWeakAreas = (workouts: any[]): string[] => {
    // Analyze weak areas based on workout notes and low condition scores
    const areas = ['forehand', 'backhand', 'serve', 'footwork', 'tactics', 'stamina'];
    const weakAreaCount: Record<string, number> = {};

    workouts.forEach(workout => {
      // Check notes for mentions of difficulty
      const notes = workout.notes?.toLowerCase() || '';
      const negativeKeywords = ['struggle', 'difficult', 'weak', 'poor', 'bad', 'tired'];
      
      if (negativeKeywords.some(keyword => notes.includes(keyword))) {
        areas.forEach(area => {
          if (notes.includes(area)) {
            weakAreaCount[area] = (weakAreaCount[area] || 0) + 1;
          }
        });
      }
      
      // Also consider low condition/high fatigue as stamina issue
      if (workout.condition_score < 5 || workout.fatigue_level > 7) {
        weakAreaCount['stamina'] = (weakAreaCount['stamina'] || 0) + 1;
      }
    });

    // Sort by frequency and return top weak areas
    const sortedAreas = Object.entries(weakAreaCount)
      .sort(([, a], [, b]) => b - a)
      .map(([area]) => area);
    
    return sortedAreas.slice(0, 3).length > 0 ? sortedAreas.slice(0, 3) : ['forehand', 'footwork'];
  };

  const onRefresh = () => {
    setRefreshing(true);
    loadData();
  };

  const openVideo = (videoId: string) => {
    const url = `https://www.youtube.com/watch?v=${videoId}`;
    Linking.openURL(url);
  };

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color={Colors.primary} />
        <Text style={styles.loadingText}>Loading your coach...</Text>
      </View>
    );
  }

  return (
    <ScrollView
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      {/* Quick Tip Section */}
      <View style={styles.tipCard}>
        <Icon name="lightbulb-outline" size={24} color="#FFA726" />
        <Text style={styles.tipTitle}>Quick Tip</Text>
        <Text style={styles.tipText}>{quickTip}</Text>
      </View>

      {/* AI Coaching Advice */}
      {aiAdvice ? (
        <View style={styles.adviceCard}>
          <View style={styles.adviceHeader}>
            <Icon name="robot" size={24} color="#2196F3" />
            <Text style={styles.adviceTitle}>AI Coach Analysis</Text>
          </View>
          <Text style={styles.adviceText}>{aiAdvice}</Text>
          <View style={styles.confidenceContainer}>
            <Icon name="shield-check" size={16} color="#4CAF50" />
            <Text style={styles.confidenceText}>Based on your recent performance</Text>
          </View>
        </View>
      ) : null}

      {/* Training Stats Summary */}
      <View style={styles.statsCard}>
        <Text style={styles.sectionTitle}>Your Training Summary</Text>
        <View style={styles.statsRow}>
          <View style={styles.statItem}>
            <Icon name="trophy" size={20} color="#FFA726" />
            <Text style={styles.statLabel}>Level</Text>
            <Text style={styles.statValue}>
              {trainingData?.skillLevel || 'Beginner'}
            </Text>
          </View>
          <View style={styles.statItem}>
            <Icon name="calendar-check" size={20} color="#4CAF50" />
            <Text style={styles.statLabel}>This Week</Text>
            <Text style={styles.statValue}>
              {trainingData?.practiceFrequency || 0} sessions
            </Text>
          </View>
          <View style={styles.statItem}>
            <Icon name="trending-up" size={20} color="#2196F3" />
            <Text style={styles.statLabel}>Avg Score</Text>
            <Text style={styles.statValue}>
              {trainingData?.recentScores.length
                ? Math.round(
                    trainingData.recentScores.reduce((a, b) => a + b, 0) /
                      trainingData.recentScores.length
                  )
                : 'N/A'}
            </Text>
          </View>
        </View>
      </View>

      {/* Video Recommendations */}
      <View style={styles.videosSection}>
        <Text style={styles.sectionTitle}>Recommended Training Videos</Text>
        {videos.map((video, index) => (
          <TouchableOpacity
            key={video.id}
            style={styles.videoCard}
            onPress={() => openVideo(video.id)}
          >
            <Image
              source={{ uri: video.thumbnailUrl }}
              style={styles.videoThumbnail}
            />
            <View style={styles.videoInfo}>
              <Text style={styles.videoTitle} numberOfLines={2}>
                {video.title}
              </Text>
              <Text style={styles.videoChannel}>{video.channelTitle}</Text>
              <View style={styles.videoStats}>
                <Icon name="play-circle" size={14} color="#666" />
                <Text style={styles.videoDuration}>{video.duration}</Text>
                <Icon name="eye" size={14} color="#666" style={{ marginLeft: 10 }} />
                <Text style={styles.videoViews}>
                  {(video.viewCount / 1000).toFixed(0)}K views
                </Text>
              </View>
            </View>
          </TouchableOpacity>
        ))}
      </View>

      {/* Focus Areas */}
      <View style={styles.focusCard}>
        <Text style={styles.sectionTitle}>Areas to Focus On</Text>
        <View style={styles.focusAreas}>
          {trainingData?.weakAreas.map((area, index) => (
            <View key={index} style={styles.focusItem}>
              <Icon name="target" size={16} color="#FF5252" />
              <Text style={styles.focusText}>{area}</Text>
            </View>
          ))}
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#666',
  },
  tipCard: {
    backgroundColor: '#FFF8E1',
    margin: 16,
    padding: 16,
    borderRadius: 12,
    flexDirection: 'row',
    alignItems: 'center',
    elevation: 2,
  },
  tipTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#F57C00',
    marginLeft: 8,
  },
  tipText: {
    flex: 1,
    fontSize: 14,
    color: '#666',
    marginLeft: 8,
  },
  adviceCard: {
    backgroundColor: 'white',
    margin: 16,
    marginTop: 0,
    padding: 16,
    borderRadius: 12,
    elevation: 2,
  },
  adviceHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  adviceTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginLeft: 8,
  },
  adviceText: {
    fontSize: 15,
    color: '#444',
    lineHeight: 22,
  },
  confidenceContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 12,
  },
  confidenceText: {
    fontSize: 12,
    color: '#4CAF50',
    marginLeft: 4,
  },
  statsCard: {
    backgroundColor: 'white',
    margin: 16,
    marginTop: 0,
    padding: 16,
    borderRadius: 12,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 12,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  statItem: {
    alignItems: 'center',
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  statValue: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginTop: 2,
  },
  videosSection: {
    margin: 16,
    marginTop: 0,
  },
  videoCard: {
    backgroundColor: 'white',
    marginBottom: 12,
    borderRadius: 12,
    elevation: 2,
    flexDirection: 'row',
    padding: 12,
  },
  videoThumbnail: {
    width: 120,
    height: 67,
    borderRadius: 8,
  },
  videoInfo: {
    flex: 1,
    marginLeft: 12,
  },
  videoTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },
  videoChannel: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
  },
  videoStats: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  videoDuration: {
    fontSize: 12,
    color: '#666',
    marginLeft: 4,
  },
  videoViews: {
    fontSize: 12,
    color: '#666',
    marginLeft: 4,
  },
  focusCard: {
    backgroundColor: 'white',
    margin: 16,
    marginTop: 0,
    padding: 16,
    borderRadius: 12,
    elevation: 2,
    marginBottom: 32,
  },
  focusAreas: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  focusItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFEBEE',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
    marginRight: 8,
    marginBottom: 8,
  },
  focusText: {
    fontSize: 14,
    color: '#D32F2F',
    marginLeft: 4,
    textTransform: 'capitalize',
  },
});
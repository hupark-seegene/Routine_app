import React, { useState, useEffect } from 'react';
import {
  View,
  ScrollView,
  StyleSheet,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { Colors } from '../styles/colors';
import { Text } from '../components/core/Text';
import { Card } from '../components/core/Card';
import { Button } from '../components/core/Button';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import databaseService from '../services/databaseService';
import { AnalyticsData } from '../database/DatabaseOptimized';
import { AnimatedNumber } from '../components/core/AnimatedNumber';
import { ProgressChart } from '../components/core/ProgressChart';

export const AnalyticsScreen: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null);
  const [weakAreas, setWeakAreas] = useState<any[]>([]);
  const [dateRange, setDateRange] = useState(30);

  useEffect(() => {
    loadAnalytics();
  }, [dateRange]);

  const loadAnalytics = async () => {
    try {
      setLoading(true);
      const [analyticsData, weakAreaData] = await Promise.all([
        databaseService.getAnalytics(1, dateRange),
        databaseService.getWeakAreaAnalysis(1),
      ]);
      
      setAnalytics(analyticsData);
      setWeakAreas(weakAreaData);
    } catch (error) {
      console.error('Error loading analytics:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setRefreshing(true);
    loadAnalytics();
  };

  const getIntensityColor = (value: number) => {
    if (value >= 8) return Colors.error;
    if (value >= 6) return Colors.warning;
    if (value >= 4) return Colors.success;
    return Colors.info;
  };

  if (loading && !refreshing) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={Colors.primary} />
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
      <View style={styles.header}>
        <Text variant="h4" style={styles.title}>Performance Analytics</Text>
        <View style={styles.dateSelector}>
          {[7, 30, 90].map((days) => (
            <TouchableOpacity
              key={days}
              style={[
                styles.datePill,
                dateRange === days && styles.datePillActive,
              ]}
              onPress={() => setDateRange(days)}
            >
              <Text
                style={[
                  styles.datePillText,
                  dateRange === days && styles.datePillTextActive,
                ]}
              >
                {days}D
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {analytics && (
        <>
          <View style={styles.statsGrid}>
            <Card style={styles.statCard}>
              <Icon name="calendar-check" size={24} color={Colors.primary} />
              <AnimatedNumber
                value={analytics.totalWorkouts}
                style={styles.statNumber}
              />
              <Text style={styles.statLabel}>Total Workouts</Text>
            </Card>

            <Card style={styles.statCard}>
              <Icon name="percent" size={24} color={Colors.success} />
              <AnimatedNumber
                value={analytics.completionRate}
                suffix="%"
                style={styles.statNumber}
              />
              <Text style={styles.statLabel}>Completion Rate</Text>
            </Card>

            <Card style={styles.statCard}>
              <Icon name="fire" size={24} color={Colors.accent} />
              <AnimatedNumber
                value={analytics.averageIntensity}
                decimals={1}
                style={[
                  styles.statNumber,
                  { color: getIntensityColor(analytics.averageIntensity) },
                ]}
              />
              <Text style={styles.statLabel}>Avg Intensity</Text>
            </Card>
          </View>

          <Card style={styles.chartCard}>
            <Text variant="h6" style={styles.chartTitle}>Weekly Progress</Text>
            <ProgressChart
              data={analytics.weeklyProgress}
              height={200}
              color={Colors.primary}
            />
          </Card>

          <Card style={styles.trendCard}>
            <Text variant="h6" style={styles.chartTitle}>Performance Trends</Text>
            <View style={styles.trendGrid}>
              {['Intensity', 'Condition', 'Fatigue'].map((metric, index) => {
                const data = metric === 'Intensity' 
                  ? analytics.trendData.intensity
                  : metric === 'Condition'
                  ? analytics.trendData.condition
                  : analytics.trendData.fatigue;
                
                const avg = data.reduce((a, b) => a + b, 0) / data.length || 0;
                const trend = data.length > 1 
                  ? data[data.length - 1] - data[0]
                  : 0;
                
                return (
                  <View key={metric} style={styles.trendItem}>
                    <Text style={styles.trendLabel}>{metric}</Text>
                    <Text style={styles.trendValue}>{avg.toFixed(1)}</Text>
                    <View style={styles.trendIndicator}>
                      <Icon
                        name={trend > 0 ? 'trending-up' : trend < 0 ? 'trending-down' : 'trending-neutral'}
                        size={16}
                        color={
                          metric === 'Fatigue'
                            ? trend > 0 ? Colors.error : Colors.success
                            : trend > 0 ? Colors.success : Colors.error
                        }
                      />
                      <Text
                        style={[
                          styles.trendChange,
                          {
                            color:
                              metric === 'Fatigue'
                                ? trend > 0 ? Colors.error : Colors.success
                                : trend > 0 ? Colors.success : Colors.error,
                          },
                        ]}
                      >
                        {Math.abs(trend).toFixed(1)}
                      </Text>
                    </View>
                  </View>
                );
              })}
            </View>
          </Card>

          <Card style={styles.exerciseCard}>
            <Text variant="h6" style={styles.chartTitle}>Exercise Distribution</Text>
            {analytics.exerciseStats.map((stat) => (
              <View key={stat.category} style={styles.exerciseItem}>
                <View style={styles.exerciseInfo}>
                  <Text style={styles.exerciseName}>{stat.category}</Text>
                  <Text style={styles.exerciseCount}>{stat.count} sessions</Text>
                </View>
                <Text style={styles.exerciseDuration}>
                  {Math.round(stat.avgDuration)} min avg
                </Text>
              </View>
            ))}
          </Card>

          {weakAreas.length > 0 && (
            <Card style={styles.weakAreasCard}>
              <Text variant="h6" style={styles.chartTitle}>Areas for Improvement</Text>
              {weakAreas.map((area, index) => (
                <View key={index} style={styles.weakAreaItem}>
                  <Icon name="alert-circle" size={20} color={Colors.warning} />
                  <View style={styles.weakAreaInfo}>
                    <Text style={styles.weakAreaName}>{area.name}</Text>
                    <Text style={styles.weakAreaStats}>
                      Intensity: {area.avg_intensity?.toFixed(1) || 'N/A'} • 
                      Completion: {((area.completions / area.attempts) * 100).toFixed(0)}%
                    </Text>
                  </View>
                </View>
              ))}
            </Card>
          )}
        </>
      )}
    </ScrollView>
  );
};

import { TouchableOpacity } from 'react-native';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: Colors.background,
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
  dateSelector: {
    flexDirection: 'row',
    gap: 8,
  },
  datePill: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: Colors.card,
  },
  datePillActive: {
    backgroundColor: Colors.primary,
  },
  datePillText: {
    fontSize: 14,
    color: Colors.textSecondary,
    fontWeight: '600',
  },
  datePillTextActive: {
    color: Colors.background,
  },
  statsGrid: {
    flexDirection: 'row',
    paddingHorizontal: 20,
    gap: 10,
    marginBottom: 20,
  },
  statCard: {
    flex: 1,
    padding: 16,
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: Colors.text,
    marginTop: 8,
  },
  statLabel: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginTop: 4,
  },
  chartCard: {
    marginHorizontal: 20,
    marginBottom: 20,
    padding: 20,
  },
  chartTitle: {
    color: Colors.text,
    marginBottom: 16,
    fontWeight: '600',
  },
  trendCard: {
    marginHorizontal: 20,
    marginBottom: 20,
    padding: 20,
  },
  trendGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  trendItem: {
    alignItems: 'center',
  },
  trendLabel: {
    fontSize: 14,
    color: Colors.textSecondary,
    marginBottom: 8,
  },
  trendValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: Colors.text,
  },
  trendIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  trendChange: {
    fontSize: 12,
    marginLeft: 4,
    fontWeight: '600',
  },
  exerciseCard: {
    marginHorizontal: 20,
    marginBottom: 20,
    padding: 20,
  },
  exerciseItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: Colors.cardBorder,
  },
  exerciseInfo: {
    flex: 1,
  },
  exerciseName: {
    fontSize: 16,
    color: Colors.text,
    fontWeight: '500',
  },
  exerciseCount: {
    fontSize: 14,
    color: Colors.textSecondary,
    marginTop: 2,
  },
  exerciseDuration: {
    fontSize: 14,
    color: Colors.primary,
    fontWeight: '600',
  },
  weakAreasCard: {
    marginHorizontal: 20,
    marginBottom: 20,
    padding: 20,
  },
  weakAreaItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    gap: 12,
  },
  weakAreaInfo: {
    flex: 1,
  },
  weakAreaName: {
    fontSize: 16,
    color: Colors.text,
    fontWeight: '500',
  },
  weakAreaStats: {
    fontSize: 14,
    color: Colors.textSecondary,
    marginTop: 2,
  },
});
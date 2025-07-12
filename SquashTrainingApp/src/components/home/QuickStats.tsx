import React, { useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
} from 'react-native';
import {
  Colors,
  DarkTheme,
  Typography,
  Spacing,
  BorderRadius,
  AnimationDuration,
  createFadeInAnimation,
} from '../../styles';

interface StatItem {
  value: string | number;
  label: string;
  onPress?: () => void;
}

interface QuickStatsProps {
  stats: StatItem[];
}

const QuickStats: React.FC<QuickStatsProps> = ({ stats }) => {
  const fadeAnims = useRef(
    stats.map(() => new Animated.Value(0))
  ).current;

  useEffect(() => {
    const animations = fadeAnims.map((anim, index) =>
      createFadeInAnimation(anim, AnimationDuration.normal, index * 100)
    );
    Animated.parallel(animations).start();
  }, []);

  return (
    <View style={styles.container}>
      {stats.map((stat, index) => (
        <Animated.View
          key={index}
          style={[
            styles.statCard,
            { opacity: fadeAnims[index] },
          ]}
        >
          <TouchableOpacity
            onPress={stat.onPress}
            disabled={!stat.onPress}
            activeOpacity={stat.onPress ? 0.7 : 1}
          >
            <Text style={styles.value}>{stat.value}</Text>
            <Text style={styles.label}>{stat.label.toUpperCase()}</Text>
          </TouchableOpacity>
        </Animated.View>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: Spacing.md,
  },
  statCard: {
    flex: 1,
    backgroundColor: DarkTheme.surface,
    borderRadius: BorderRadius.lg,
    padding: Spacing.lg,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: DarkTheme.border,
  },
  value: {
    ...Typography.h2,
    color: Colors.accentVolt,
    marginBottom: Spacing.xs,
  },
  label: {
    ...Typography.labelTiny,
    color: DarkTheme.textSecondary,
    textAlign: 'center',
  },
});

export default QuickStats;
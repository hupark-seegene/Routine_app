import React, { useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Animated,
  Dimensions,
} from 'react-native';
import Svg, { Circle, Defs, LinearGradient as SvgGradient, Stop } from 'react-native-svg';
import {
  Colors,
  DarkTheme,
  Typography,
  Spacing,
  BorderRadius,
  AnimationDuration,
} from '../../styles';

const AnimatedCircle = Animated.createAnimatedComponent(Circle);

interface ProgressRingProps {
  percentage: number;
  workouts: number;
  totalWorkouts: number;
  minutes: number;
}

const ProgressRing: React.FC<ProgressRingProps> = ({
  percentage,
  workouts,
  totalWorkouts,
  minutes,
}) => {
  const size = 200;
  const strokeWidth = 12;
  const radius = (size - strokeWidth) / 2;
  const circumference = radius * 2 * Math.PI;
  
  const animatedValue = useRef(new Animated.Value(0)).current;
  
  useEffect(() => {
    Animated.timing(animatedValue, {
      toValue: percentage,
      duration: AnimationDuration.slow,
      useNativeDriver: true,
    }).start();
  }, [percentage]);

  const strokeDashoffset = animatedValue.interpolate({
    inputRange: [0, 100],
    outputRange: [circumference, 0],
  });

  return (
    <View style={styles.container}>
      <View style={styles.progressContainer}>
        <Svg width={size} height={size} style={styles.svg}>
          <Defs>
            <SvgGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
              <Stop offset="0%" stopColor={Colors.accentVolt} />
              <Stop offset="100%" stopColor={Colors.successGreen} />
            </SvgGradient>
          </Defs>
          
          {/* Background Circle */}
          <Circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            stroke={DarkTheme.border}
            strokeWidth={strokeWidth}
            fill="none"
          />
          
          {/* Progress Circle */}
          <AnimatedCircle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            stroke="url(#gradient)"
            strokeWidth={strokeWidth}
            fill="none"
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={strokeDashoffset}
            transform={`rotate(-90 ${size / 2} ${size / 2})`}
          />
        </Svg>
        
        <View style={styles.textContainer}>
          <Animated.Text style={styles.percentage}>
            {animatedValue.interpolate({
              inputRange: [0, 100],
              outputRange: ['0%', `${Math.round(percentage)}%`],
            })}
          </Animated.Text>
          <Text style={styles.label}>WEEKLY GOAL</Text>
        </View>
      </View>
      
      <View style={styles.statsContainer}>
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{workouts}/{totalWorkouts}</Text>
          <Text style={styles.statLabel}>WORKOUTS</Text>
        </View>
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{minutes}</Text>
          <Text style={styles.statLabel}>MINUTES</Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: DarkTheme.surface,
    borderRadius: BorderRadius.xl,
    padding: Spacing.xl,
    alignItems: 'center',
  },
  progressContainer: {
    width: 200,
    height: 200,
    marginBottom: Spacing.lg,
  },
  svg: {
    transform: [{ rotateZ: '0deg' }],
  },
  textContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  percentage: {
    ...Typography.display,
    color: Colors.accentVolt,
    marginBottom: Spacing.xs,
  },
  label: {
    ...Typography.label,
    color: DarkTheme.textSecondary,
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
  },
  statItem: {
    alignItems: 'center',
    flex: 1,
  },
  statValue: {
    ...Typography.h4,
    color: Colors.accentVolt,
    marginBottom: Spacing.xs,
  },
  statLabel: {
    ...Typography.labelTiny,
    color: DarkTheme.textSecondary,
  },
});

export default ProgressRing;
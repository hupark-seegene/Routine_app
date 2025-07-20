import React, { useEffect, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Dimensions,
  Platform,
} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
// Removed blur view import - will use custom implementation
import MaterialCommunityIcons from 'react-native-vector-icons/MaterialCommunityIcons';
import {
  Colors,
  ModernTypography,
  ModernSpacing,
  BorderRadius,
  Shadows,
  Gradients,
  Glass,
  Animations,
} from '../../styles';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

interface ModernHeroCardProps {
  date: string;
  title: string;
  subtitle: string;
  onPress: () => void;
  progress?: number;
}

const ModernHeroCard: React.FC<ModernHeroCardProps> = ({
  date,
  title,
  subtitle,
  onPress,
  progress = 0,
}) => {
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const rotateAnim = useRef(new Animated.Value(0)).current;
  const glowAnim = useRef(new Animated.Value(0)).current;
  const progressAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Initial entrance animation
    Animated.parallel([
      Animated.spring(scaleAnim, {
        toValue: 1,
        from: 0.9,
        ...Animations.spring,
      }),
      Animated.timing(rotateAnim, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
    ]).start();

    // Continuous glow animation
    Animated.loop(
      Animated.sequence([
        Animated.timing(glowAnim, {
          toValue: 1,
          duration: 2000,
          useNativeDriver: true,
        }),
        Animated.timing(glowAnim, {
          toValue: 0,
          duration: 2000,
          useNativeDriver: true,
        }),
      ])
    ).start();

    // Progress animation
    Animated.timing(progressAnim, {
      toValue: progress,
      duration: 1000,
      useNativeDriver: false,
    }).start();
  }, [progress]);

  const handlePressIn = () => {
    Animated.spring(scaleAnim, {
      toValue: 0.95,
      ...Animations.spring,
    }).start();
  };

  const handlePressOut = () => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      ...Animations.spring,
    }).start();
  };

  const rotate = rotateAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  const glowOpacity = glowAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.3, 0.6],
  });

  return (
    <Animated.View
      style={[
        styles.container,
        {
          transform: [{ scale: scaleAnim }],
        },
      ]}
    >
      <TouchableOpacity
        activeOpacity={0.9}
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
      >
        <LinearGradient
          colors={Gradients.purple.colors}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.gradient}
        >
          {/* Animated glow effect */}
          <Animated.View
            style={[
              styles.glowEffect,
              {
                opacity: glowOpacity,
              },
            ]}
          />

          {/* Glass overlay */}
          <View style={styles.glassOverlay}>
            <View style={[styles.blur, { backgroundColor: Glass.light.backgroundColor }]} />
          </View>

          {/* Content */}
          <View style={styles.content}>
            {/* Date badge */}
            <View style={styles.dateBadge}>
              <MaterialCommunityIcons name="calendar-today" size={16} color={Colors.primary} />
              <Text style={styles.dateText}>{date}</Text>
            </View>

            {/* Title and subtitle */}
            <Text style={styles.title}>{title}</Text>
            <Text style={styles.subtitle}>{subtitle}</Text>

            {/* Progress indicator */}
            <View style={styles.progressContainer}>
              <View style={styles.progressBackground}>
                <Animated.View
                  style={[
                    styles.progressFill,
                    {
                      width: progressAnim.interpolate({
                        inputRange: [0, 100],
                        outputRange: ['0%', '100%'],
                      }),
                    },
                  ]}
                />
              </View>
              <Text style={styles.progressText}>{Math.round(progress)}% Complete</Text>
            </View>

            {/* Action button */}
            <View style={styles.buttonContainer}>
              <LinearGradient
                colors={[Colors.primary, Colors.primaryDark]}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 0 }}
                style={styles.button}
              >
                <Text style={styles.buttonText}>START TRAINING</Text>
                <Animated.View
                  style={{
                    transform: [{ rotate }],
                  }}
                >
                  <MaterialCommunityIcons
                    name="rocket-launch"
                    size={20}
                    color={Colors.background}
                  />
                </Animated.View>
              </LinearGradient>
            </View>
          </View>

          {/* Decorative elements */}
          <View style={styles.decorativeCircle1} />
          <View style={styles.decorativeCircle2} />
        </LinearGradient>
      </TouchableOpacity>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginHorizontal: ModernSpacing.lg,
    marginVertical: ModernSpacing.md,
    ...Shadows.large,
  },
  gradient: {
    borderRadius: BorderRadius.card,
    overflow: 'hidden',
    minHeight: 240,
    position: 'relative',
  },
  glowEffect: {
    position: 'absolute',
    top: -20,
    left: -20,
    right: -20,
    bottom: -20,
    backgroundColor: Colors.glowCyan,
    borderRadius: BorderRadius.card + 20,
  },
  glassOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderRadius: BorderRadius.card,
    overflow: 'hidden',
  },
  blur: {
    flex: 1,
  },
  content: {
    padding: ModernSpacing.xl,
    zIndex: 1,
  },
  dateBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 245, 255, 0.1)',
    paddingHorizontal: ModernSpacing.md,
    paddingVertical: ModernSpacing.sm,
    borderRadius: BorderRadius.round,
    alignSelf: 'flex-start',
    marginBottom: ModernSpacing.lg,
    borderWidth: 1,
    borderColor: 'rgba(0, 245, 255, 0.3)',
  },
  dateText: {
    ...ModernTypography.caption,
    color: Colors.primary,
    marginLeft: ModernSpacing.xs,
    fontWeight: '600',
  },
  title: {
    ...ModernTypography.h1,
    color: Colors.white,
    marginBottom: ModernSpacing.sm,
    textShadowColor: 'rgba(0, 0, 0, 0.3)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 4,
  },
  subtitle: {
    ...ModernTypography.bodySmall,
    color: Colors.textSecondary,
    marginBottom: ModernSpacing.lg,
  },
  progressContainer: {
    marginBottom: ModernSpacing.xl,
  },
  progressBackground: {
    height: 6,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: BorderRadius.round,
    overflow: 'hidden',
    marginBottom: ModernSpacing.sm,
  },
  progressFill: {
    height: '100%',
    backgroundColor: Colors.primary,
    borderRadius: BorderRadius.round,
    shadowColor: Colors.primary,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 10,
  },
  progressText: {
    ...ModernTypography.caption,
    color: Colors.primary,
    fontWeight: '600',
  },
  buttonContainer: {
    marginTop: ModernSpacing.md,
  },
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: ModernSpacing.md,
    paddingHorizontal: ModernSpacing.xl,
    borderRadius: BorderRadius.round,
    gap: ModernSpacing.sm,
    ...Shadows.medium,
  },
  buttonText: {
    ...ModernTypography.button,
    color: Colors.background,
    fontWeight: '700',
  },
  decorativeCircle1: {
    position: 'absolute',
    top: -50,
    right: -50,
    width: 150,
    height: 150,
    borderRadius: 75,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
  },
  decorativeCircle2: {
    position: 'absolute',
    bottom: -30,
    left: -30,
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: 'rgba(0, 245, 255, 0.1)',
  },
});

export default ModernHeroCard;
import React, { useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Animated,
} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import {
  Colors,
  DarkTheme,
  Typography,
  FontWeight,
  Spacing,
  BorderRadius,
  AnimationDuration,
} from '../../styles';

interface Achievement {
  id: string;
  icon: string;
  name: string;
  description: string;
  unlocked: boolean;
  onPress?: () => void;
}

interface AchievementScrollProps {
  achievements: Achievement[];
}

const AchievementCard: React.FC<{ achievement: Achievement }> = ({ achievement }) => {
  const scaleAnim = useRef(new Animated.Value(1)).current;

  const handlePressIn = () => {
    Animated.timing(scaleAnim, {
      toValue: 0.95,
      duration: AnimationDuration.fast,
      useNativeDriver: true,
    }).start();
  };

  const handlePressOut = () => {
    Animated.timing(scaleAnim, {
      toValue: 1,
      duration: AnimationDuration.fast,
      useNativeDriver: true,
    }).start();
  };

  return (
    <TouchableOpacity
      onPress={achievement.onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      activeOpacity={0.8}
    >
      <Animated.View
        style={[
          styles.card,
          achievement.unlocked && styles.cardUnlocked,
          { transform: [{ scale: scaleAnim }] },
        ]}
      >
        {achievement.unlocked && (
          <LinearGradient
            colors={[Colors.voltAlpha(0.1), Colors.voltAlpha(0.05)]}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={StyleSheet.absoluteFillObject}
          />
        )}
        
        <Text
          style={[
            styles.icon,
            achievement.unlocked && styles.iconUnlocked,
          ]}
        >
          {achievement.icon}
        </Text>
        
        <Text style={styles.name}>{achievement.name}</Text>
        <Text style={styles.description}>{achievement.description}</Text>
      </Animated.View>
    </TouchableOpacity>
  );
};

const AchievementScroll: React.FC<AchievementScrollProps> = ({ achievements }) => {
  return (
    <ScrollView
      horizontal
      showsHorizontalScrollIndicator={false}
      contentContainerStyle={styles.scrollContent}
    >
      {achievements.map((achievement) => (
        <AchievementCard key={achievement.id} achievement={achievement} />
      ))}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  scrollContent: {
    paddingHorizontal: Spacing.lg,
    gap: Spacing.md,
  },
  card: {
    backgroundColor: DarkTheme.surface,
    borderRadius: BorderRadius.lg,
    padding: Spacing.lg,
    width: 150,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'transparent',
    overflow: 'hidden',
  },
  cardUnlocked: {
    borderColor: Colors.accentVolt,
  },
  icon: {
    fontSize: 48,
    marginBottom: Spacing.sm,
    opacity: 0.3,
  },
  iconUnlocked: {
    opacity: 1,
  },
  name: {
    ...Typography.bodySmall,
    fontWeight: FontWeight.semiBold,
    color: DarkTheme.text,
    marginBottom: Spacing.xs,
    textAlign: 'center',
  },
  description: {
    ...Typography.bodySmall,
    color: DarkTheme.textTertiary,
    textAlign: 'center',
  },
});

export default AchievementScroll;
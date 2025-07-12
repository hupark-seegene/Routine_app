import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {
  Colors,
  DarkTheme,
  Typography,
  Spacing,
  BorderRadius,
  AnimationDuration,
} from '../../styles';

interface WorkoutCardProps {
  icon: string;
  name: string;
  details: string;
  duration: string;
  completed?: boolean;
  onPress: () => void;
}

const WorkoutCard: React.FC<WorkoutCardProps> = ({
  icon,
  name,
  details,
  duration,
  completed = false,
  onPress,
}) => {
  const [isPressed, setIsPressed] = useState(false);
  const translateX = new Animated.Value(0);

  const handlePressIn = () => {
    setIsPressed(true);
    Animated.timing(translateX, {
      toValue: 5,
      duration: AnimationDuration.fast,
      useNativeDriver: true,
    }).start();
  };

  const handlePressOut = () => {
    setIsPressed(false);
    Animated.timing(translateX, {
      toValue: 0,
      duration: AnimationDuration.fast,
      useNativeDriver: true,
    }).start();
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      activeOpacity={0.9}
    >
      <Animated.View
        style={[
          styles.container,
          isPressed && styles.containerPressed,
          { transform: [{ translateX }] },
        ]}
      >
        {/* Icon */}
        <View style={[styles.iconContainer, completed && styles.iconCompleted]}>
          {completed ? (
            <View style={styles.completedIcon}>
              <Icon name={icon} size={28} color={DarkTheme.textTertiary} />
              <Icon
                name="check"
                size={20}
                color={Colors.successGreen}
                style={styles.checkIcon}
              />
            </View>
          ) : (
            <LinearGradient
              colors={Colors.gradients.voltToGreen}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.iconGradient}
            >
              <Icon name={icon} size={28} color={Colors.primaryBlack} />
            </LinearGradient>
          )}
        </View>

        {/* Info */}
        <View style={styles.info}>
          <Text style={[styles.name, completed && styles.nameCompleted]}>
            {name}
          </Text>
          <Text style={styles.details}>{details}</Text>
        </View>

        {/* Duration */}
        <Text style={[styles.duration, completed && styles.durationCompleted]}>
          {duration}
        </Text>
      </Animated.View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: DarkTheme.surface,
    borderRadius: BorderRadius.lg,
    padding: Spacing.lg,
    marginBottom: Spacing.md,
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.lg,
    borderWidth: 1,
    borderColor: DarkTheme.border,
  },
  containerPressed: {
    borderColor: Colors.accentVolt,
  },
  iconContainer: {
    width: 60,
    height: 60,
    borderRadius: BorderRadius.lg,
    overflow: 'hidden',
  },
  iconGradient: {
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  iconCompleted: {
    backgroundColor: DarkTheme.surfaceLight,
    justifyContent: 'center',
    alignItems: 'center',
  },
  completedIcon: {
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkIcon: {
    position: 'absolute',
    bottom: 5,
    right: 5,
  },
  info: {
    flex: 1,
  },
  name: {
    ...Typography.h5,
    color: DarkTheme.text,
    marginBottom: Spacing.xs,
  },
  nameCompleted: {
    color: DarkTheme.textSecondary,
    textDecorationLine: 'line-through',
  },
  details: {
    ...Typography.bodySmall,
    color: DarkTheme.textSecondary,
  },
  duration: {
    ...Typography.h6,
    color: Colors.accentVolt,
  },
  durationCompleted: {
    color: DarkTheme.textTertiary,
  },
});

export default WorkoutCard;
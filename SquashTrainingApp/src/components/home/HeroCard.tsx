import React, { useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
  Dimensions,
} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import Icon from 'react-native-vector-icons/MaterialIcons';
import {
  Colors,
  DarkTheme,
  Typography,
  Spacing,
  BorderRadius,
  AnimationDuration,
  createScaleAnimation,
  pulseAnimation,
} from '../../styles';

interface HeroCardProps {
  date: string;
  title: string;
  subtitle: string;
  onPress: () => void;
}

const HeroCard: React.FC<HeroCardProps> = ({ date, title, subtitle, onPress }) => {
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const pulseAnim = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    pulseAnimation(pulseAnim).start();
  }, []);

  const handlePressIn = () => {
    Animated.timing(scaleAnim, {
      toValue: 0.98,
      duration: AnimationDuration.fast,
      useNativeDriver: true,
    }).start();
  };

  const handlePressOut = () => {
    createScaleAnimation(scaleAnim, 1, AnimationDuration.fast).start();
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      activeOpacity={0.9}
    >
      <Animated.View style={{ transform: [{ scale: scaleAnim }] }}>
        <LinearGradient
          colors={Colors.gradients.orangeToRed}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.container}
        >
          {/* Background Pattern */}
          <View style={styles.pattern} />
          
          {/* Content */}
          <View style={styles.content}>
            <Text style={styles.date}>{date.toUpperCase()}</Text>
            <Text style={styles.title}>{title}</Text>
            <Text style={styles.subtitle}>{subtitle}</Text>
            
            <Animated.View
              style={[
                styles.button,
                { transform: [{ scale: pulseAnim }] },
              ]}
            >
              <Text style={styles.buttonText}>START WORKOUT</Text>
              <Icon name="arrow-forward" size={20} color={Colors.primaryWhite} />
            </Animated.View>
          </View>
        </LinearGradient>
      </Animated.View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: BorderRadius.xl,
    padding: Spacing.xl,
    overflow: 'hidden',
    elevation: 10,
    shadowColor: Colors.accentOrange,
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.3,
    shadowRadius: 20,
  },
  pattern: {
    position: 'absolute',
    top: '-50%',
    right: '-30%',
    width: '200%',
    height: '200%',
    backgroundColor: Colors.whiteAlpha(0.05),
    borderRadius: 200,
    transform: [{ rotate: '45deg' }],
  },
  content: {
    zIndex: 1,
  },
  date: {
    ...Typography.label,
    color: Colors.whiteAlpha(0.9),
    marginBottom: Spacing.sm,
    letterSpacing: 1,
  },
  title: {
    ...Typography.hero,
    color: Colors.primaryWhite,
    marginBottom: Spacing.xs,
  },
  subtitle: {
    ...Typography.h5,
    color: Colors.whiteAlpha(0.9),
    marginBottom: Spacing.lg,
  },
  button: {
    backgroundColor: Colors.primaryBlack,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: Spacing.md,
    paddingHorizontal: Spacing.xl,
    borderRadius: BorderRadius.full,
    gap: Spacing.sm,
    alignSelf: 'flex-start',
    shadowColor: Colors.primaryBlack,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 5,
  },
  buttonText: {
    ...Typography.button,
    color: Colors.primaryWhite,
  },
});

export default HeroCard;
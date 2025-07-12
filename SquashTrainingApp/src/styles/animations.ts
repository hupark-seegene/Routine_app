import { Animated, Easing } from 'react-native';

export const AnimationDuration = {
  instant: 0,
  fast: 150,
  normal: 300,
  slow: 500,
  verySlow: 1000,
};

export const AnimationEasing = {
  // Standard easing
  standard: Easing.bezier(0.4, 0.0, 0.2, 1),
  decelerate: Easing.bezier(0.0, 0.0, 0.2, 1),
  accelerate: Easing.bezier(0.4, 0.0, 1, 1),
  
  // Spring-like
  spring: Easing.bezier(0.175, 0.885, 0.32, 1.275),
  
  // Others
  linear: Easing.linear,
  ease: Easing.ease,
  bounce: Easing.bounce,
};

export const createFadeInAnimation = (
  animatedValue: Animated.Value,
  duration: number = AnimationDuration.normal,
  delay: number = 0
) => {
  return Animated.timing(animatedValue, {
    toValue: 1,
    duration,
    delay,
    easing: AnimationEasing.decelerate,
    useNativeDriver: true,
  });
};

export const createFadeOutAnimation = (
  animatedValue: Animated.Value,
  duration: number = AnimationDuration.normal,
  delay: number = 0
) => {
  return Animated.timing(animatedValue, {
    toValue: 0,
    duration,
    delay,
    easing: AnimationEasing.accelerate,
    useNativeDriver: true,
  });
};

export const createScaleAnimation = (
  animatedValue: Animated.Value,
  toValue: number = 1,
  duration: number = AnimationDuration.normal
) => {
  return Animated.spring(animatedValue, {
    toValue,
    tension: 40,
    friction: 7,
    useNativeDriver: true,
  });
};

export const createSlideInAnimation = (
  animatedValue: Animated.Value,
  fromValue: number = 100,
  duration: number = AnimationDuration.normal
) => {
  animatedValue.setValue(fromValue);
  return Animated.timing(animatedValue, {
    toValue: 0,
    duration,
    easing: AnimationEasing.decelerate,
    useNativeDriver: true,
  });
};

export const pulseAnimation = (animatedValue: Animated.Value) => {
  return Animated.loop(
    Animated.sequence([
      Animated.timing(animatedValue, {
        toValue: 1.1,
        duration: AnimationDuration.slow,
        easing: AnimationEasing.ease,
        useNativeDriver: true,
      }),
      Animated.timing(animatedValue, {
        toValue: 1,
        duration: AnimationDuration.slow,
        easing: AnimationEasing.ease,
        useNativeDriver: true,
      }),
    ])
  );
};

export const shimmerAnimation = (animatedValue: Animated.Value) => {
  return Animated.loop(
    Animated.timing(animatedValue, {
      toValue: 1,
      duration: AnimationDuration.verySlow,
      easing: AnimationEasing.linear,
      useNativeDriver: true,
    })
  );
};
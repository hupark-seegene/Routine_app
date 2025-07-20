import React, { useEffect, useRef } from 'react';
import { Text, TextStyle, Animated } from 'react-native';

interface AnimatedNumberProps {
  value: number;
  decimals?: number;
  prefix?: string;
  suffix?: string;
  duration?: number;
  style?: TextStyle;
}

export const AnimatedNumber: React.FC<AnimatedNumberProps> = ({
  value,
  decimals = 0,
  prefix = '',
  suffix = '',
  duration = 1000,
  style,
}) => {
  const animatedValue = useRef(new Animated.Value(0)).current;
  const currentValue = useRef(0);

  useEffect(() => {
    Animated.timing(animatedValue, {
      toValue: value,
      duration,
      useNativeDriver: false,
    }).start();

    animatedValue.addListener((v) => {
      currentValue.current = v.value;
    });

    return () => {
      animatedValue.removeAllListeners();
    };
  }, [value]);

  return (
    <Animated.Text style={style}>
      {animatedValue.interpolate({
        inputRange: [0, value],
        outputRange: [
          `${prefix}${(0).toFixed(decimals)}${suffix}`,
          `${prefix}${value.toFixed(decimals)}${suffix}`,
        ],
      })}
    </Animated.Text>
  );
};
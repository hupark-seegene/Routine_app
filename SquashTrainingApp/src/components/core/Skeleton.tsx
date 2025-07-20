import React, { useEffect, useRef } from 'react';
import {
  View,
  StyleSheet,
  Animated,
  ViewStyle,
  Dimensions,
} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import {
  BorderRadius,
  Animation,
  DarkTheme,
  LightTheme,
  Palette,
} from '../../styles/designSystem';
import { useTheme } from '../../contexts/ThemeContext';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

interface SkeletonProps {
  width?: number | string;
  height?: number | string;
  radius?: 'none' | 'small' | 'medium' | 'large' | 'round';
  variant?: 'text' | 'circular' | 'rectangular';
  animation?: 'pulse' | 'wave' | 'none';
  style?: ViewStyle;
}

const Skeleton: React.FC<SkeletonProps> = ({
  width,
  height = 20,
  radius = 'small',
  variant = 'text',
  animation = 'pulse',
  style,
}) => {
  const { theme } = useTheme();
  const pulseAnim = useRef(new Animated.Value(0)).current;
  const waveAnim = useRef(new Animated.Value(-1)).current;
  
  const baseColor = theme === 'dark' 
    ? Palette.neutral[800]
    : Palette.neutral[200];
  
  const highlightColor = theme === 'dark'
    ? Palette.neutral[700]
    : Palette.neutral[100];
  
  useEffect(() => {
    if (animation === 'pulse') {
      Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, {
            toValue: 1,
            duration: Animation.duration.slow,
            useNativeDriver: true,
          }),
          Animated.timing(pulseAnim, {
            toValue: 0,
            duration: Animation.duration.slow,
            useNativeDriver: true,
          }),
        ])
      ).start();
    } else if (animation === 'wave') {
      Animated.loop(
        Animated.timing(waveAnim, {
          toValue: 2,
          duration: Animation.duration.slower,
          useNativeDriver: true,
        })
      ).start();
    }
    
    return () => {
      pulseAnim.stopAnimation();
      waveAnim.stopAnimation();
    };
  }, [animation, pulseAnim, waveAnim]);
  
  const getRadius = () => {
    if (variant === 'circular') return 9999;
    
    switch (radius) {
      case 'none':
        return 0;
      case 'small':
        return BorderRadius.sm;
      case 'medium':
        return BorderRadius.base;
      case 'large':
        return BorderRadius.lg;
      case 'round':
        return BorderRadius.full;
      default:
        return BorderRadius.sm;
    }
  };
  
  const getDimensions = () => {
    let finalWidth = width;
    let finalHeight = height;
    
    switch (variant) {
      case 'text':
        finalWidth = width || '100%';
        finalHeight = 16;
        break;
      case 'circular':
        const size = width || height || 40;
        finalWidth = size;
        finalHeight = size;
        break;
      case 'rectangular':
        finalWidth = width || '100%';
        finalHeight = height || 100;
        break;
    }
    
    return { width: finalWidth, height: finalHeight };
  };
  
  const dimensions = getDimensions();
  const borderRadius = getRadius();
  
  const containerStyle = [
    styles.container,
    {
      width: dimensions.width,
      height: dimensions.height,
      borderRadius,
      backgroundColor: baseColor,
    },
    style,
  ];
  
  if (animation === 'pulse') {
    return (
      <Animated.View
        style={[
          containerStyle,
          {
            opacity: pulseAnim.interpolate({
              inputRange: [0, 1],
              outputRange: [1, 0.5],
            }),
          },
        ]}
      />
    );
  }
  
  if (animation === 'wave') {
    return (
      <View style={containerStyle}>
        <Animated.View
          style={[
            styles.wave,
            {
              transform: [
                {
                  translateX: waveAnim.interpolate({
                    inputRange: [-1, 2],
                    outputRange: [-SCREEN_WIDTH, SCREEN_WIDTH],
                  }),
                },
              ],
            },
          ]}
        >
          <LinearGradient
            colors={[
              baseColor,
              highlightColor,
              highlightColor,
              baseColor,
            ]}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
            style={styles.gradient}
          />
        </Animated.View>
      </View>
    );
  }
  
  return <View style={containerStyle} />;
};

const styles = StyleSheet.create({
  container: {
    overflow: 'hidden',
  },
  wave: {
    ...StyleSheet.absoluteFillObject,
    width: SCREEN_WIDTH,
  },
  gradient: {
    flex: 1,
  },
});

export default Skeleton;
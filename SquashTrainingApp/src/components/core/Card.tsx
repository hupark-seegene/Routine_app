import React, { useRef } from 'react';
import {
  View,
  ViewProps,
  StyleSheet,
  TouchableOpacity,
  Animated,
  ViewStyle,
} from 'react-native';
import {
  Spacing,
  BorderRadius,
  Shadows,
  States,
  Animation,
  DarkTheme,
  LightTheme,
} from '../../styles/designSystem';
import { useTheme } from '../../contexts/ThemeContext';

interface CardProps extends ViewProps {
  variant?: 'elevated' | 'outlined' | 'filled';
  onPress?: () => void;
  disabled?: boolean;
  padding?: 'none' | 'small' | 'medium' | 'large';
  radius?: 'small' | 'medium' | 'large';
  elevation?: 'none' | 'small' | 'medium' | 'large';
  style?: ViewStyle;
  children: React.ReactNode;
}

const Card: React.FC<CardProps> = ({
  variant = 'elevated',
  onPress,
  disabled = false,
  padding = 'medium',
  radius = 'medium',
  elevation = 'small',
  style,
  children,
  ...props
}) => {
  const { theme } = useTheme();
  const colors = theme === 'dark' ? DarkTheme.colors : LightTheme.colors;
  const scaleAnim = useRef(new Animated.Value(1)).current;
  
  const handlePressIn = () => {
    if (onPress && !disabled) {
      Animated.timing(scaleAnim, {
        toValue: States.pressed.scale,
        duration: Animation.duration.fast,
        useNativeDriver: true,
      }).start();
    }
  };
  
  const handlePressOut = () => {
    if (onPress && !disabled) {
      Animated.spring(scaleAnim, {
        toValue: 1,
        ...Animation.easing.spring,
        useNativeDriver: true,
      }).start();
    }
  };
  
  const getPadding = () => {
    switch (padding) {
      case 'none':
        return 0;
      case 'small':
        return Spacing[3];
      case 'large':
        return Spacing[6];
      case 'medium':
      default:
        return Spacing[4];
    }
  };
  
  const getBorderRadius = () => {
    switch (radius) {
      case 'small':
        return BorderRadius.sm;
      case 'large':
        return BorderRadius.xl;
      case 'medium':
      default:
        return BorderRadius.lg;
    }
  };
  
  const getElevation = () => {
    if (variant !== 'elevated') return {};
    
    switch (elevation) {
      case 'none':
        return Shadows.none;
      case 'small':
        return Shadows.sm;
      case 'large':
        return Shadows.lg;
      case 'medium':
      default:
        return Shadows.md;
    }
  };
  
  const getVariantStyles = (): ViewStyle => {
    switch (variant) {
      case 'elevated':
        return {
          backgroundColor: colors.surface,
          ...getElevation(),
        };
      case 'outlined':
        return {
          backgroundColor: colors.surface,
          borderWidth: 1,
          borderColor: colors.border,
        };
      case 'filled':
        return {
          backgroundColor: colors.surfaceVariant,
        };
      default:
        return {};
    }
  };
  
  const cardStyles = [
    styles.card,
    getVariantStyles(),
    {
      padding: getPadding(),
      borderRadius: getBorderRadius(),
    },
    disabled && styles.disabled,
    style,
  ];
  
  const content = (
    <View style={cardStyles} {...props}>
      {children}
    </View>
  );
  
  if (onPress) {
    return (
      <TouchableOpacity
        activeOpacity={0.8}
        disabled={disabled}
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        accessibilityRole="button"
        accessibilityState={{ disabled }}
      >
        <Animated.View
          style={{
            transform: [{ scale: scaleAnim }],
          }}
        >
          {content}
        </Animated.View>
      </TouchableOpacity>
    );
  }
  
  return content;
};

const styles = StyleSheet.create({
  card: {
    overflow: 'hidden',
  },
  disabled: {
    opacity: States.disabled.opacity,
  },
});

export default Card;
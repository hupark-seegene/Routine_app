import React, { useRef, useCallback } from 'react';
import {
  TouchableOpacity,
  TouchableOpacityProps,
  StyleSheet,
  View,
  ActivityIndicator,
  Animated,
  ViewStyle,
  TextStyle,
  Platform,
} from 'react-native';
import Haptics from 'react-native-haptic-feedback';
import LinearGradient from 'react-native-linear-gradient';
import Text from './Text';
import Icon from './Icon';
import {
  Palette,
  Spacing,
  BorderRadius,
  Shadows,
  Animation,
  A11y,
  States,
  DarkTheme,
  LightTheme,
} from '../../styles/designSystem';
import { useTheme } from '../../contexts/ThemeContext';

interface ButtonProps extends Omit<TouchableOpacityProps, 'style'> {
  variant?: 'contained' | 'outlined' | 'text' | 'gradient';
  size?: 'small' | 'medium' | 'large';
  color?: 'primary' | 'secondary' | 'error' | 'warning' | 'success';
  fullWidth?: boolean;
  loading?: boolean;
  disabled?: boolean;
  startIcon?: string;
  endIcon?: string;
  haptic?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
  children: React.ReactNode;
  onPress?: () => void;
}

const Button: React.FC<ButtonProps> = ({
  variant = 'contained',
  size = 'medium',
  color = 'primary',
  fullWidth = false,
  loading = false,
  disabled = false,
  startIcon,
  endIcon,
  haptic = true,
  style,
  textStyle,
  children,
  onPress,
  ...props
}) => {
  const { theme } = useTheme();
  const colors = theme === 'dark' ? DarkTheme.colors : LightTheme.colors;
  const scaleAnim = useRef(new Animated.Value(1)).current;
  
  const handlePressIn = useCallback(() => {
    Animated.spring(scaleAnim, {
      toValue: States.pressed.scale,
      ...Animation.easing.spring,
      useNativeDriver: true,
    }).start();
  }, [scaleAnim]);
  
  const handlePressOut = useCallback(() => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      ...Animation.easing.spring,
      useNativeDriver: true,
    }).start();
  }, [scaleAnim]);
  
  const handlePress = useCallback(() => {
    if (haptic && Platform.OS === 'ios') {
      Haptics.trigger('impactLight');
    }
    onPress?.();
  }, [haptic, onPress]);
  
  const getColorValue = () => {
    switch (color) {
      case 'primary':
        return colors.primary;
      case 'secondary':
        return colors.secondary;
      case 'error':
        return colors.error;
      case 'warning':
        return colors.warning;
      case 'success':
        return colors.success;
      default:
        return colors.primary;
    }
  };
  
  const getSizeStyles = (): ViewStyle => {
    switch (size) {
      case 'small':
        return {
          paddingHorizontal: Spacing[3],
          paddingVertical: Spacing[2],
          minHeight: 32,
        };
      case 'large':
        return {
          paddingHorizontal: Spacing[6],
          paddingVertical: Spacing[4],
          minHeight: 56,
        };
      case 'medium':
      default:
        return {
          paddingHorizontal: Spacing[4],
          paddingVertical: Spacing[3],
          minHeight: 44,
        };
    }
  };
  
  const getVariantStyles = (): ViewStyle => {
    const baseColor = getColorValue();
    
    switch (variant) {
      case 'contained':
        return {
          backgroundColor: disabled ? colors.surfaceVariant : baseColor,
          ...Shadows.sm,
        };
      case 'outlined':
        return {
          backgroundColor: 'transparent',
          borderWidth: 1,
          borderColor: disabled ? colors.border : baseColor,
        };
      case 'text':
        return {
          backgroundColor: 'transparent',
          paddingHorizontal: Spacing[2],
        };
      case 'gradient':
        return {
          overflow: 'hidden',
          ...Shadows.md,
        };
      default:
        return {};
    }
  };
  
  const getTextColor = () => {
    if (disabled) return colors.textTertiary;
    
    switch (variant) {
      case 'contained':
      case 'gradient':
        return theme === 'dark' ? Palette.neutral[950] : Palette.neutral[0];
      case 'outlined':
      case 'text':
        return getColorValue();
      default:
        return colors.text;
    }
  };
  
  const buttonStyles = [
    styles.button,
    getSizeStyles(),
    getVariantStyles(),
    fullWidth && styles.fullWidth,
    disabled && styles.disabled,
    style,
  ];
  
  const content = (
    <View style={styles.content}>
      {loading ? (
        <ActivityIndicator
          size="small"
          color={getTextColor()}
          style={styles.loader}
        />
      ) : (
        <>
          {startIcon && (
            <Icon
              name={startIcon}
              size={size === 'small' ? 16 : size === 'large' ? 24 : 20}
              color={getTextColor()}
              style={styles.startIcon}
            />
          )}
          <Text
            variant={size === 'small' ? 'button' : 'button'}
            style={[{ color: getTextColor() }, textStyle]}
          >
            {children}
          </Text>
          {endIcon && (
            <Icon
              name={endIcon}
              size={size === 'small' ? 16 : size === 'large' ? 24 : 20}
              color={getTextColor()}
              style={styles.endIcon}
            />
          )}
        </>
      )}
    </View>
  );
  
  return (
    <Animated.View
      style={[
        { transform: [{ scale: scaleAnim }] },
        fullWidth && styles.fullWidth,
      ]}
    >
      <TouchableOpacity
        activeOpacity={0.8}
        disabled={disabled || loading}
        onPress={handlePress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        accessibilityRole="button"
        accessibilityState={{ disabled: disabled || loading }}
        accessibilityLabel={typeof children === 'string' ? children : undefined}
        {...props}
        style={variant === 'gradient' ? undefined : buttonStyles}
      >
        {variant === 'gradient' ? (
          <LinearGradient
            colors={
              disabled
                ? [colors.surfaceVariant, colors.surface]
                : color === 'secondary'
                ? [Palette.secondary[400], Palette.secondary[600]]
                : [Palette.primary[400], Palette.primary[600]]
            }
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
            style={buttonStyles}
          >
            {content}
          </LinearGradient>
        ) : (
          content
        )}
      </TouchableOpacity>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: BorderRadius.md,
    minWidth: A11y.minTouchSize,
    position: 'relative',
  },
  fullWidth: {
    width: '100%',
  },
  disabled: {
    opacity: States.disabled.opacity,
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  startIcon: {
    marginRight: Spacing[2],
  },
  endIcon: {
    marginLeft: Spacing[2],
  },
  loader: {
    width: 20,
    height: 20,
  },
});

export default Button;
import React from 'react';
import {
  Text as RNText,
  TextProps as RNTextProps,
  StyleSheet,
  TextStyle,
  Animated,
} from 'react-native';
import { Typography, Palette, DarkTheme, LightTheme } from '../../styles/designSystem';
import { useTheme } from '../../contexts/ThemeContext';

interface TextProps extends RNTextProps {
  variant?: 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6' | 'body1' | 'body2' | 'caption' | 'button' | 'overline';
  color?: 'primary' | 'secondary' | 'text' | 'textSecondary' | 'textTertiary' | 'error' | 'warning' | 'success' | 'info';
  weight?: 'regular' | 'medium' | 'semibold' | 'bold' | 'black';
  align?: 'left' | 'center' | 'right' | 'justify';
  animated?: boolean;
  style?: TextStyle | TextStyle[];
  children: React.ReactNode;
}

const Text: React.FC<TextProps> = ({
  variant = 'body1',
  color = 'text',
  weight,
  align,
  animated = false,
  style,
  children,
  ...props
}) => {
  const { theme } = useTheme();
  const colors = theme === 'dark' ? DarkTheme.colors : LightTheme.colors;
  
  const TextComponent = animated ? Animated.Text : RNText;
  
  const getVariantStyles = (): TextStyle => {
    switch (variant) {
      case 'h1':
        return {
          fontSize: Typography.fontSize['5xl'],
          lineHeight: Typography.fontSize['5xl'] * Typography.lineHeight.tight,
          fontWeight: Typography.fontWeight.bold,
          letterSpacing: Typography.letterSpacing.tight,
        };
      case 'h2':
        return {
          fontSize: Typography.fontSize['4xl'],
          lineHeight: Typography.fontSize['4xl'] * Typography.lineHeight.tight,
          fontWeight: Typography.fontWeight.bold,
          letterSpacing: Typography.letterSpacing.tight,
        };
      case 'h3':
        return {
          fontSize: Typography.fontSize['3xl'],
          lineHeight: Typography.fontSize['3xl'] * Typography.lineHeight.snug,
          fontWeight: Typography.fontWeight.semibold,
        };
      case 'h4':
        return {
          fontSize: Typography.fontSize['2xl'],
          lineHeight: Typography.fontSize['2xl'] * Typography.lineHeight.snug,
          fontWeight: Typography.fontWeight.semibold,
        };
      case 'h5':
        return {
          fontSize: Typography.fontSize.xl,
          lineHeight: Typography.fontSize.xl * Typography.lineHeight.normal,
          fontWeight: Typography.fontWeight.semibold,
        };
      case 'h6':
        return {
          fontSize: Typography.fontSize.lg,
          lineHeight: Typography.fontSize.lg * Typography.lineHeight.normal,
          fontWeight: Typography.fontWeight.semibold,
        };
      case 'body1':
        return {
          fontSize: Typography.fontSize.base,
          lineHeight: Typography.fontSize.base * Typography.lineHeight.normal,
          fontWeight: Typography.fontWeight.regular,
        };
      case 'body2':
        return {
          fontSize: Typography.fontSize.sm,
          lineHeight: Typography.fontSize.sm * Typography.lineHeight.normal,
          fontWeight: Typography.fontWeight.regular,
        };
      case 'caption':
        return {
          fontSize: Typography.fontSize.xs,
          lineHeight: Typography.fontSize.xs * Typography.lineHeight.normal,
          fontWeight: Typography.fontWeight.regular,
          letterSpacing: Typography.letterSpacing.wide,
        };
      case 'button':
        return {
          fontSize: Typography.fontSize.sm,
          lineHeight: Typography.fontSize.sm * Typography.lineHeight.tight,
          fontWeight: Typography.fontWeight.medium,
          letterSpacing: Typography.letterSpacing.wider,
          textTransform: 'uppercase',
        };
      case 'overline':
        return {
          fontSize: Typography.fontSize.xs,
          lineHeight: Typography.fontSize.xs * Typography.lineHeight.tight,
          fontWeight: Typography.fontWeight.medium,
          letterSpacing: Typography.letterSpacing.widest,
          textTransform: 'uppercase',
        };
      default:
        return {};
    }
  };
  
  const getColorValue = (): string => {
    switch (color) {
      case 'primary':
        return colors.primary;
      case 'secondary':
        return colors.secondary;
      case 'text':
        return colors.text;
      case 'textSecondary':
        return colors.textSecondary;
      case 'textTertiary':
        return colors.textTertiary;
      case 'error':
        return colors.error;
      case 'warning':
        return colors.warning;
      case 'success':
        return colors.success;
      case 'info':
        return colors.info;
      default:
        return colors.text;
    }
  };
  
  const getFontWeight = (): string => {
    if (weight) {
      return Typography.fontWeight[weight];
    }
    return getVariantStyles().fontWeight || Typography.fontWeight.regular;
  };
  
  const textStyles = [
    styles.base,
    getVariantStyles(),
    {
      color: getColorValue(),
      fontWeight: getFontWeight(),
      textAlign: align,
      fontFamily: Typography.fontFamily.regular,
    },
    style,
  ];
  
  return (
    <TextComponent
      style={textStyles}
      allowFontScaling={true}
      maxFontSizeMultiplier={1.3}
      {...props}
    >
      {children}
    </TextComponent>
  );
};

const styles = StyleSheet.create({
  base: {
    includeFontPadding: false,
    textAlignVertical: 'center',
  },
});

export default Text;
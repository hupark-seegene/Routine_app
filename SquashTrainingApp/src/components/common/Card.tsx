import React from 'react';
import {
  View,
  StyleSheet,
  ViewStyle,
  TouchableOpacity,
  TouchableOpacityProps,
} from 'react-native';
import { Colors } from '../../styles/Colors';

interface CardProps {
  children: React.ReactNode;
  style?: ViewStyle;
  elevated?: boolean;
  variant?: 'default' | 'outlined' | 'filled';
  padding?: 'none' | 'small' | 'medium' | 'large';
  onPress?: () => void;
  touchableProps?: TouchableOpacityProps;
}

export const Card: React.FC<CardProps> = ({
  children,
  style,
  elevated = false,
  variant = 'default',
  padding = 'medium',
  onPress,
  touchableProps,
}) => {
  const getPaddingStyle = (): ViewStyle => {
    switch (padding) {
      case 'none':
        return { padding: 0 };
      case 'small':
        return { padding: 12 };
      case 'large':
        return { padding: 24 };
      default:
        return { padding: 16 };
    }
  };

  const getVariantStyle = (): ViewStyle => {
    switch (variant) {
      case 'outlined':
        return {
          backgroundColor: 'transparent',
          borderWidth: 1,
          borderColor: Colors.border,
        };
      case 'filled':
        return {
          backgroundColor: Colors.surface,
        };
      default:
        return {
          backgroundColor: Colors.card,
        };
    }
  };

  const cardStyle = [
    styles.card,
    getVariantStyle(),
    getPaddingStyle(),
    elevated && styles.elevated,
    style,
  ];

  if (onPress) {
    return (
      <TouchableOpacity
        style={cardStyle}
        onPress={onPress}
        activeOpacity={0.8}
        {...touchableProps}
      >
        {children}
      </TouchableOpacity>
    );
  }

  return <View style={cardStyle}>{children}</View>;
};

const styles = StyleSheet.create({
  card: {
    borderRadius: 12,
    marginBottom: 16,
  },
  elevated: {
    shadowColor: Colors.primary,
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
});
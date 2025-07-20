import React from 'react';
import { View, ViewProps, StyleSheet, ViewStyle } from 'react-native';
import { DarkTheme, LightTheme, BorderRadius, Shadows } from '../../styles/designSystem';
import { useTheme } from '../../contexts/ThemeContext';

interface SurfaceProps extends ViewProps {
  level?: 0 | 1 | 2 | 3 | 4 | 5;
  radius?: 'none' | 'small' | 'medium' | 'large';
  style?: ViewStyle;
  children: React.ReactNode;
}

const Surface: React.FC<SurfaceProps> = ({
  level = 0,
  radius = 'medium',
  style,
  children,
  ...props
}) => {
  const { theme } = useTheme();
  const colors = theme === 'dark' ? DarkTheme.colors : LightTheme.colors;
  
  const getBackgroundColor = () => {
    if (theme === 'light') {
      switch (level) {
        case 0:
          return colors.background;
        case 1:
          return colors.surface;
        case 2:
        case 3:
        case 4:
        case 5:
          return colors.surfaceVariant;
        default:
          return colors.surface;
      }
    } else {
      // Dark theme uses elevation overlays
      const opacity = level * 0.05;
      return `rgba(255, 255, 255, ${opacity})`;
    }
  };
  
  const getElevation = () => {
    switch (level) {
      case 0:
        return Shadows.none;
      case 1:
        return Shadows.sm;
      case 2:
        return Shadows.base;
      case 3:
        return Shadows.md;
      case 4:
        return Shadows.lg;
      case 5:
        return Shadows.xl;
      default:
        return Shadows.none;
    }
  };
  
  const getBorderRadius = () => {
    switch (radius) {
      case 'none':
        return 0;
      case 'small':
        return BorderRadius.sm;
      case 'large':
        return BorderRadius.xl;
      case 'medium':
      default:
        return BorderRadius.lg;
    }
  };
  
  const surfaceStyles = [
    styles.surface,
    {
      backgroundColor: theme === 'dark' && level > 0 ? colors.surface : getBackgroundColor(),
      borderRadius: getBorderRadius(),
      ...getElevation(),
    },
    theme === 'dark' && level > 0 && {
      position: 'relative' as const,
    },
    style,
  ];
  
  return (
    <View style={surfaceStyles} {...props}>
      {theme === 'dark' && level > 0 && (
        <View
          style={[
            styles.overlay,
            {
              backgroundColor: getBackgroundColor(),
              borderRadius: getBorderRadius(),
            },
          ]}
        />
      )}
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  surface: {
    overflow: 'hidden',
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    zIndex: 0,
  },
});

export default Surface;
import React from 'react';
import MaterialCommunityIcons from 'react-native-vector-icons/MaterialCommunityIcons';
import { ViewStyle } from 'react-native';
import { useTheme } from '../../contexts/ThemeContext';
import { DarkTheme, LightTheme } from '../../styles/designSystem';

interface IconProps {
  name: string;
  size?: number;
  color?: string;
  style?: ViewStyle;
}

const Icon: React.FC<IconProps> = ({
  name,
  size = 24,
  color,
  style,
}) => {
  const { theme } = useTheme();
  const colors = theme === 'dark' ? DarkTheme.colors : LightTheme.colors;
  const iconColor = color || colors.text;
  
  return (
    <MaterialCommunityIcons
      name={name}
      size={size}
      color={iconColor}
      style={style}
    />
  );
};

export default Icon;
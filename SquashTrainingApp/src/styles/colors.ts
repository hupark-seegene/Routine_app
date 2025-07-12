export const Colors = {
  // Primary colors
  primary: '#C9FF00', // Volt green
  primaryDark: '#A8D600',
  primaryLight: '#E0FF66',
  
  // Background colors
  background: '#000000',
  backgroundLight: '#0D0D0D',
  backgroundElevated: '#1A1A1A',
  
  // Text colors
  text: '#FFFFFF',
  textSecondary: '#B8B8B8',
  textMuted: '#808080',
  
  // UI colors
  border: '#333333',
  borderLight: '#4D4D4D',
  
  // Status colors
  success: '#4CAF50',
  warning: '#FFA500',
  error: '#FF6B6B',
  info: '#2196F3',
  
  // Exercise categories
  skill: '#4ECDC4',
  strength: '#FF6B6B',
  cardio: '#45B7D1',
  fitness: '#FFA500',
  
  // Additional colors
  white: '#FFFFFF',
  black: '#000000',
  gray: '#808080',
  lightGray: '#E0E0E0',
  darkGray: '#333333',
};

export const DarkTheme = {
  dark: true,
  colors: {
    primary: Colors.primary,
    background: Colors.background,
    card: Colors.backgroundElevated,
    text: Colors.text,
    border: Colors.border,
    notification: Colors.primary,
  },
};
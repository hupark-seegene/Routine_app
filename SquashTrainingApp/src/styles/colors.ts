export const Colors = {
  // Primary colors - Modern neon accent
  primary: '#00F5FF', // Cyan neon
  primaryDark: '#00C9D7',
  primaryLight: '#66F9FF',
  accent: '#FF006E', // Hot pink accent
  accentDark: '#D60059',
  accentLight: '#FF4D94',
  
  // Background colors - Deep dark with subtle purple tint
  background: '#0A0A0F',
  backgroundLight: '#12121A',
  backgroundElevated: '#1A1A25',
  backgroundCard: '#252538',
  
  // Glass effect backgrounds
  glass: 'rgba(255, 255, 255, 0.05)',
  glassLight: 'rgba(255, 255, 255, 0.08)',
  glassDark: 'rgba(0, 0, 0, 0.4)',
  
  // Text colors
  text: '#FFFFFF',
  textSecondary: '#C0C0CE',
  textMuted: '#8B8B9E',
  textAccent: '#00F5FF',
  
  // UI colors
  border: '#2A2A3E',
  borderLight: '#3A3A4E',
  borderGlass: 'rgba(255, 255, 255, 0.1)',
  
  // Status colors - Vibrant and modern
  success: '#00E676',
  successDark: '#00C853',
  warning: '#FFD600',
  warningDark: '#FFC107',
  error: '#FF1744',
  errorDark: '#D50000',
  info: '#00E5FF',
  infoDark: '#00B8D4',
  
  // Exercise categories - Gradient friendly colors
  skill: '#00BCD4',
  strength: '#E91E63',
  cardio: '#00E5FF',
  fitness: '#FF6F00',
  
  // Gradient colors
  gradientStart: '#667EEA',
  gradientMid: '#764BA2',
  gradientEnd: '#F093FB',
  
  // Neon gradients
  neonBlueStart: '#00F5FF',
  neonBlueEnd: '#0080FF',
  neonPinkStart: '#FF006E',
  neonPinkEnd: '#FF4D94',
  neonGreenStart: '#00E676',
  neonGreenEnd: '#00C853',
  
  // Shadow colors
  shadowDark: 'rgba(0, 0, 0, 0.8)',
  shadowMedium: 'rgba(0, 0, 0, 0.5)',
  shadowLight: 'rgba(0, 0, 0, 0.3)',
  glowCyan: 'rgba(0, 245, 255, 0.5)',
  glowPink: 'rgba(255, 0, 110, 0.5)',
  
  // Additional colors
  white: '#FFFFFF',
  black: '#000000',
  gray: '#808080',
  lightGray: '#E0E0E0',
  darkGray: '#333333',
  
  // Old volt color kept for compatibility
  accentVolt: '#C9FF00',
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
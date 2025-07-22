/**
 * Comprehensive Design System
 * Industry-standard design tokens and principles
 */

import { Dimensions, Platform } from 'react-native';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

// Brand Identity
export const Brand = {
  name: 'Squash Master',
  tagline: 'Train Smart, Play Better',
  primaryColor: '#F5E6D3',
  secondaryColor: '#4A5D3A',
};

// Refined Color Palette - Zen Minimal Design
export const Palette = {
  // Primary Colors - Warm beige tones
  primary: {
    50: '#FDFBF8',
    100: '#FAF5ED',
    200: '#F7EFE3',
    300: '#F5E6D3',
    400: '#F0DCC4',
    500: '#F5E6D3', // Main brand color - warm beige
    600: '#E6D4BC',
    700: '#D4C0A5',
    800: '#C2AC8E',
    900: '#A89577',
  },
  
  // Secondary Colors - Deep olive green
  secondary: {
    50: '#F0F2ED',
    100: '#E1E5DB',
    200: '#C3CBB7',
    300: '#A5B193',
    400: '#87976F',
    500: '#4A5D3A', // Secondary brand color - olive green
    600: '#3A4A2D',
    700: '#2D3A22',
    800: '#202A18',
    900: '#131A0E',
  },
  
  // Neutral Colors - True grays for better readability
  neutral: {
    0: '#FFFFFF',
    50: '#FAFAFA',
    100: '#F5F5F5',
    200: '#E5E5E5',
    300: '#D4D4D4',
    400: '#A3A3A3',
    500: '#737373',
    600: '#525252',
    700: '#404040',
    800: '#262626',
    900: '#171717',
    950: '#0A0A0A',
  },
  
  // Semantic Colors - Clear and accessible
  semantic: {
    success: '#10B981',
    successLight: '#D1FAE5',
    successDark: '#059669',
    
    warning: '#F59E0B',
    warningLight: '#FEF3C7',
    warningDark: '#D97706',
    
    error: '#EF4444',
    errorLight: '#FEE2E2',
    errorDark: '#DC2626',
    
    info: '#3B82F6',
    infoLight: '#DBEAFE',
    infoDark: '#2563EB',
  },
  
  // Exercise Categories - Muted earth tones
  categories: {
    skill: '#7B8F7B',      // Sage green
    strength: '#B08D7A',   // Warm taupe
    cardio: '#8FA68F',     // Soft green
    fitness: '#C2A878',    // Golden sand
    recovery: '#9B8B7E',   // Soft brown
  },
};

// Typography System - Consistent and scalable
export const Typography = {
  // Font Families
  fontFamily: {
    regular: Platform.select({
      ios: 'SF Pro Display',
      android: 'Roboto',
      default: 'System',
    }),
    medium: Platform.select({
      ios: 'SF Pro Display-Medium',
      android: 'Roboto-Medium',
      default: 'System',
    }),
    semibold: Platform.select({
      ios: 'SF Pro Display-Semibold',
      android: 'Roboto-Medium',
      default: 'System',
    }),
    bold: Platform.select({
      ios: 'SF Pro Display-Bold',
      android: 'Roboto-Bold',
      default: 'System',
    }),
  },
  
  // Type Scale - Using modular scale (1.25 ratio)
  fontSize: {
    xs: 12,
    sm: 14,
    base: 16,
    lg: 18,
    xl: 20,
    '2xl': 24,
    '3xl': 30,
    '4xl': 36,
    '5xl': 48,
    '6xl': 60,
  },
  
  // Line Heights
  lineHeight: {
    tight: 1.1,
    snug: 1.2,
    normal: 1.5,
    relaxed: 1.625,
    loose: 2,
  },
  
  // Letter Spacing
  letterSpacing: {
    tighter: -0.05,
    tight: -0.025,
    normal: 0,
    wide: 0.025,
    wider: 0.05,
    widest: 0.1,
  },
  
  // Font Weights
  fontWeight: {
    regular: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
    black: '900',
  },
};

// Spacing System - Based on 8pt grid
export const Spacing = {
  0: 0,
  1: 4,
  2: 8,
  3: 12,
  4: 16,
  5: 20,
  6: 24,
  8: 32,
  10: 40,
  12: 48,
  16: 64,
  20: 80,
  24: 96,
  32: 128,
};

// Layout System
export const Layout = {
  screenWidth: SCREEN_WIDTH,
  screenHeight: SCREEN_HEIGHT,
  
  // Breakpoints
  breakpoints: {
    xs: 0,
    sm: 360,
    md: 414,
    lg: 768,
    xl: 1024,
  },
  
  // Container widths
  container: {
    xs: '100%',
    sm: 540,
    md: 720,
    lg: 960,
    xl: 1140,
  },
  
  // Grid
  grid: {
    columns: 12,
    gutter: Spacing[4],
  },
  
  // Safe areas
  safeArea: {
    top: Platform.OS === 'ios' ? 44 : 24,
    bottom: Platform.OS === 'ios' ? 34 : 0,
  },
};

// Border Radius System
export const BorderRadius = {
  none: 0,
  sm: 4,
  base: 8,
  md: 12,
  lg: 16,
  xl: 24,
  '2xl': 32,
  '3xl': 48,
  full: 9999,
};

// Shadow System - Consistent elevation
export const Shadows = {
  none: {
    shadowColor: 'transparent',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0,
    shadowRadius: 0,
    elevation: 0,
  },
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  base: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 4,
    elevation: 2,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.12,
    shadowRadius: 8,
    elevation: 4,
  },
  lg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.15,
    shadowRadius: 16,
    elevation: 8,
  },
  xl: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.18,
    shadowRadius: 24,
    elevation: 12,
  },
  '2xl': {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 16 },
    shadowOpacity: 0.22,
    shadowRadius: 32,
    elevation: 16,
  },
  inner: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 4,
    elevation: -1,
  },
};

// Animation Timings
export const Animation = {
  duration: {
    instant: 0,
    fast: 150,
    base: 300,
    slow: 500,
    slower: 750,
    slowest: 1000,
  },
  
  easing: {
    linear: [0, 0, 1, 1],
    easeIn: [0.4, 0, 1, 1],
    easeOut: [0, 0, 0.2, 1],
    easeInOut: [0.4, 0, 0.2, 1],
    spring: { tension: 170, friction: 26 },
    bounce: { tension: 200, friction: 20 },
  },
};

// Z-Index Scale
export const ZIndex = {
  hide: -1,
  base: 0,
  dropdown: 10,
  sticky: 20,
  fixed: 30,
  modalBackdrop: 40,
  modal: 50,
  popover: 60,
  tooltip: 70,
  notification: 80,
  loading: 90,
  max: 99,
};

// Accessibility
export const A11y = {
  // Minimum touch target size
  minTouchSize: 44,
  
  // Focus indicators
  focusRing: {
    width: 2,
    color: Palette.primary[500],
    offset: 2,
  },
  
  // Contrast ratios
  contrast: {
    AA: 4.5,      // Normal text
    AAA: 7,       // Enhanced
    AALarge: 3,   // Large text
  },
  
  // Animation preferences
  reduceMotion: false,
  
  // Font scaling
  fontScale: {
    min: 0.85,
    max: 1.3,
  },
};

// Interaction States
export const States = {
  hover: {
    opacity: 0.8,
    scale: 1.02,
  },
  pressed: {
    opacity: 0.6,
    scale: 0.98,
  },
  disabled: {
    opacity: 0.5,
  },
  loading: {
    opacity: 0.7,
  },
};

// Export composite theme objects
export const LightTheme = {
  name: 'light',
  colors: {
    background: '#FAFAF8',
    surface: Palette.neutral[0],
    surfaceVariant: '#F5F5F0',
    primary: Palette.primary[500],
    primaryVariant: Palette.primary[600],
    secondary: Palette.secondary[500],
    secondaryVariant: Palette.secondary[600],
    text: '#2C2C2C',
    textSecondary: '#6B6B6B',
    textTertiary: '#8B8680',
    border: '#E5E5E0',
    divider: '#F0F0EC',
    ...Palette.semantic,
  },
  isDark: false,
};

export const DarkTheme = {
  name: 'dark',
  colors: {
    background: '#2C2C2C',
    surface: '#3A3A3A',
    surfaceVariant: '#424242',
    primary: Palette.primary[300],
    primaryVariant: Palette.primary[200],
    secondary: Palette.secondary[300],
    secondaryVariant: Palette.secondary[200],
    text: '#F5F5F5',
    textSecondary: '#C0C0C0',
    textTertiary: '#9A9A9A',
    border: '#4A4A4A',
    divider: '#3E3E3E',
    ...Palette.semantic,
  },
  isDark: true,
};

// Haptic Feedback Types
export const Haptics = {
  light: 'impactLight',
  medium: 'impactMedium',
  heavy: 'impactHeavy',
  selection: 'selection',
  success: 'notificationSuccess',
  warning: 'notificationWarning',
  error: 'notificationError',
};

export default {
  Brand,
  Palette,
  Typography,
  Spacing,
  Layout,
  BorderRadius,
  Shadows,
  Animation,
  ZIndex,
  A11y,
  States,
  LightTheme,
  DarkTheme,
  Haptics,
};
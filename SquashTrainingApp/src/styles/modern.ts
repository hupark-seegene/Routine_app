import { Platform, Dimensions } from 'react-native';
import { Colors } from './colors';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

// Modern shadow presets
export const Shadows = {
  small: {
    shadowColor: Colors.shadowDark,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
    elevation: 2,
  },
  medium: {
    shadowColor: Colors.shadowDark,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 6,
    elevation: 4,
  },
  large: {
    shadowColor: Colors.shadowDark,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.2,
    shadowRadius: 12,
    elevation: 8,
  },
  neonGlow: (color: string) => ({
    shadowColor: color,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 20,
    elevation: 10,
  }),
};

// Gradient presets
export const Gradients = {
  primary: {
    colors: [Colors.neonBlueStart, Colors.neonBlueEnd],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
  accent: {
    colors: [Colors.neonPinkStart, Colors.neonPinkEnd],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
  success: {
    colors: [Colors.neonGreenStart, Colors.neonGreenEnd],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
  glass: {
    colors: ['rgba(255,255,255,0.1)', 'rgba(255,255,255,0.05)'],
    start: { x: 0, y: 0 },
    end: { x: 0, y: 1 },
  },
  dark: {
    colors: [Colors.backgroundElevated, Colors.background],
    start: { x: 0, y: 0 },
    end: { x: 0, y: 1 },
  },
  purple: {
    colors: [Colors.gradientStart, Colors.gradientMid, Colors.gradientEnd],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
  radial: {
    colors: ['rgba(0,245,255,0.3)', 'rgba(0,245,255,0.1)', 'transparent'],
    start: { x: 0.5, y: 0.5 },
    end: { x: 1, y: 1 },
  },
};

// Glass morphism effects
export const Glass = {
  light: {
    backgroundColor: Colors.glass,
    backdropFilter: 'blur(10px)',
    borderWidth: 1,
    borderColor: Colors.borderGlass,
  },
  dark: {
    backgroundColor: Colors.glassDark,
    backdropFilter: 'blur(20px)',
    borderWidth: 1,
    borderColor: Colors.borderGlass,
  },
  card: {
    backgroundColor: 'rgba(255,255,255,0.08)',
    backdropFilter: 'blur(10px)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.15)',
    ...Shadows.medium,
  },
};

// Modern border radius presets
export const BorderRadius = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
  round: 9999,
  card: 20,
  modal: 28,
};

// Animation presets
export const Animations = {
  spring: {
    tension: 40,
    friction: 7,
    useNativeDriver: true,
  },
  smooth: {
    duration: 300,
    useNativeDriver: true,
  },
  quick: {
    duration: 150,
    useNativeDriver: true,
  },
  bounce: {
    duration: 400,
    useNativeDriver: true,
  },
};

// Modern spacing system
export const ModernSpacing = {
  xxs: 2,
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
  xxxl: 64,
};

// Layout utilities
export const Layout = {
  screenWidth: SCREEN_WIDTH,
  screenHeight: SCREEN_HEIGHT,
  isSmallDevice: SCREEN_WIDTH < 375,
  window: {
    width: SCREEN_WIDTH,
    height: SCREEN_HEIGHT,
  },
  isTablet: SCREEN_WIDTH >= 768,
};

// Modern typography with better font scaling
export const ModernTypography = {
  hero: {
    fontSize: Layout.isSmallDevice ? 48 : 56,
    fontWeight: '800' as const,
    letterSpacing: -1,
    lineHeight: Layout.isSmallDevice ? 52 : 60,
  },
  h1: {
    fontSize: Layout.isSmallDevice ? 32 : 36,
    fontWeight: '700' as const,
    letterSpacing: -0.5,
    lineHeight: Layout.isSmallDevice ? 36 : 40,
  },
  h2: {
    fontSize: Layout.isSmallDevice ? 24 : 28,
    fontWeight: '600' as const,
    letterSpacing: -0.3,
    lineHeight: Layout.isSmallDevice ? 28 : 32,
  },
  h3: {
    fontSize: Layout.isSmallDevice ? 20 : 22,
    fontWeight: '600' as const,
    letterSpacing: 0,
    lineHeight: Layout.isSmallDevice ? 24 : 26,
  },
  body: {
    fontSize: 16,
    fontWeight: '400' as const,
    letterSpacing: 0,
    lineHeight: 24,
  },
  bodySmall: {
    fontSize: 14,
    fontWeight: '400' as const,
    letterSpacing: 0.1,
    lineHeight: 20,
  },
  caption: {
    fontSize: 12,
    fontWeight: '400' as const,
    letterSpacing: 0.2,
    lineHeight: 16,
  },
  button: {
    fontSize: 16,
    fontWeight: '600' as const,
    letterSpacing: 0.5,
    lineHeight: 20,
    textTransform: 'uppercase' as const,
  },
  label: {
    fontSize: 14,
    fontWeight: '500' as const,
    letterSpacing: 0.1,
    lineHeight: 18,
  },
};

// Modern button styles
export const ButtonStyles = {
  primary: {
    backgroundColor: Colors.primary,
    borderRadius: BorderRadius.lg,
    paddingVertical: ModernSpacing.md,
    paddingHorizontal: ModernSpacing.lg,
    ...Shadows.medium,
  },
  glass: {
    ...Glass.card,
    borderRadius: BorderRadius.lg,
    paddingVertical: ModernSpacing.md,
    paddingHorizontal: ModernSpacing.lg,
  },
  outline: {
    backgroundColor: 'transparent',
    borderWidth: 2,
    borderColor: Colors.primary,
    borderRadius: BorderRadius.lg,
    paddingVertical: ModernSpacing.md - 2,
    paddingHorizontal: ModernSpacing.lg - 2,
  },
  floating: {
    backgroundColor: Colors.primary,
    borderRadius: BorderRadius.round,
    width: 56,
    height: 56,
    ...Shadows.large,
    ...Shadows.neonGlow(Colors.glowCyan),
  },
};

// Card styles
export const CardStyles = {
  modern: {
    backgroundColor: Colors.backgroundCard,
    borderRadius: BorderRadius.card,
    padding: ModernSpacing.lg,
    ...Shadows.medium,
  },
  glass: {
    ...Glass.card,
    borderRadius: BorderRadius.card,
    padding: ModernSpacing.lg,
  },
  gradient: {
    borderRadius: BorderRadius.card,
    padding: ModernSpacing.lg,
    overflow: 'hidden' as const,
    ...Shadows.large,
  },
  elevated: {
    backgroundColor: Colors.backgroundElevated,
    borderRadius: BorderRadius.card,
    padding: ModernSpacing.lg,
    borderWidth: 1,
    borderColor: Colors.border,
    ...Shadows.large,
  },
};

// Modern input styles
export const InputStyles = {
  modern: {
    backgroundColor: Colors.backgroundElevated,
    borderRadius: BorderRadius.md,
    borderWidth: 1,
    borderColor: Colors.border,
    paddingHorizontal: ModernSpacing.md,
    paddingVertical: Platform.OS === 'ios' ? ModernSpacing.md : ModernSpacing.sm,
    fontSize: ModernTypography.body.fontSize,
    color: Colors.text,
  },
  glass: {
    ...Glass.light,
    borderRadius: BorderRadius.md,
    paddingHorizontal: ModernSpacing.md,
    paddingVertical: Platform.OS === 'ios' ? ModernSpacing.md : ModernSpacing.sm,
    fontSize: ModernTypography.body.fontSize,
    color: Colors.text,
  },
  underline: {
    backgroundColor: 'transparent',
    borderBottomWidth: 2,
    borderBottomColor: Colors.border,
    paddingHorizontal: 0,
    paddingVertical: ModernSpacing.sm,
    fontSize: ModernTypography.body.fontSize,
    color: Colors.text,
  },
};

// Modern transitions
export const Transitions = {
  fadeIn: {
    from: { opacity: 0 },
    to: { opacity: 1 },
  },
  slideUp: {
    from: { translateY: 50, opacity: 0 },
    to: { translateY: 0, opacity: 1 },
  },
  slideDown: {
    from: { translateY: -50, opacity: 0 },
    to: { translateY: 0, opacity: 1 },
  },
  scaleIn: {
    from: { scale: 0.8, opacity: 0 },
    to: { scale: 1, opacity: 1 },
  },
  bounceIn: {
    from: { scale: 0.3, opacity: 0 },
    to: { scale: 1, opacity: 1 },
  },
};

export default {
  Colors,
  Shadows,
  Gradients,
  Glass,
  BorderRadius,
  Animations,
  ModernSpacing,
  Layout,
  ModernTypography,
  ButtonStyles,
  CardStyles,
  InputStyles,
  Transitions,
};
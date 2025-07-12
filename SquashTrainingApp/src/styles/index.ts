import { StyleSheet } from 'react-native';
import { Colors, DarkTheme } from './colors';
import { Typography, FontSize, FontWeight } from './typography';

export * from './colors';
export * from './typography';
export * from './animations';

// Global styles
export const GlobalStyles = StyleSheet.create({
  // Containers
  container: {
    flex: 1,
    backgroundColor: DarkTheme.background,
  },
  contentContainer: {
    padding: 20,
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: DarkTheme.background,
  },
  
  // Cards
  card: {
    backgroundColor: DarkTheme.surface,
    borderRadius: 16,
    padding: 20,
    marginBottom: 15,
  },
  cardElevated: {
    backgroundColor: DarkTheme.surface,
    borderRadius: 16,
    padding: 20,
    marginBottom: 15,
    shadowColor: Colors.primaryBlack,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 5,
  },
  
  // Buttons
  primaryButton: {
    backgroundColor: DarkTheme.primary,
    paddingHorizontal: 24,
    paddingVertical: 16,
    borderRadius: 30,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primaryButtonText: {
    color: Colors.primaryBlack,
    ...Typography.button,
  },
  secondaryButton: {
    backgroundColor: 'transparent',
    borderWidth: 2,
    borderColor: DarkTheme.primary,
    paddingHorizontal: 24,
    paddingVertical: 14,
    borderRadius: 30,
    alignItems: 'center',
    justifyContent: 'center',
  },
  secondaryButtonText: {
    color: DarkTheme.primary,
    ...Typography.button,
  },
  
  // Text
  title: {
    color: DarkTheme.text,
    ...Typography.h1,
  },
  subtitle: {
    color: DarkTheme.textSecondary,
    ...Typography.h3,
  },
  body: {
    color: DarkTheme.text,
    ...Typography.body,
  },
  label: {
    color: DarkTheme.textSecondary,
    ...Typography.label,
  },
  
  // Inputs
  input: {
    backgroundColor: DarkTheme.surface,
    borderWidth: 1,
    borderColor: DarkTheme.border,
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    color: DarkTheme.text,
    fontSize: FontSize.medium,
  },
  inputFocused: {
    borderColor: DarkTheme.primary,
  },
  
  // Dividers
  divider: {
    height: 1,
    backgroundColor: DarkTheme.border,
    marginVertical: 16,
  },
  
  // Shadows
  shadow: {
    shadowColor: Colors.primaryBlack,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  shadowMedium: {
    shadowColor: Colors.primaryBlack,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 5,
  },
  shadowLarge: {
    shadowColor: Colors.primaryBlack,
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.2,
    shadowRadius: 20,
    elevation: 10,
  },
  
  // Special
  voltGlow: {
    shadowColor: Colors.accentVolt,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.5,
    shadowRadius: 20,
    elevation: 10,
  },
});

// Spacing scale
export const Spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
};

// Border radius scale
export const BorderRadius = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  full: 9999,
};
/**
 * Consistent spacing values throughout the app
 * Based on 4px grid system
 */
export const Spacing = {
  // Base unit
  unit: 4,
  
  // Specific values
  xxs: 2,
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
  
  // Layout spacing
  screenPadding: 16,
  cardPadding: 16,
  sectionGap: 24,
  
  // Component spacing
  buttonPadding: {
    vertical: 12,
    horizontal: 20,
  },
  inputPadding: {
    vertical: 12,
    horizontal: 16,
  },
  
  // Border radius
  radius: {
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    round: 9999,
  },
  
  // Icon sizes
  icon: {
    xs: 16,
    sm: 20,
    md: 24,
    lg: 32,
    xl: 48,
  },
} as const;
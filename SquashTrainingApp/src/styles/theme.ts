import { Colors, DarkTheme, LightTheme } from './Colors';
import { Typography } from './Typography';
import { Spacing } from '../constants/spacing';

export interface Theme {
  colors: typeof DarkTheme;
  typography: typeof Typography;
  spacing: typeof Spacing;
  shadows: {
    small: {
      shadowColor: string;
      shadowOffset: { width: number; height: number };
      shadowOpacity: number;
      shadowRadius: number;
      elevation: number;
    };
    medium: {
      shadowColor: string;
      shadowOffset: { width: number; height: number };
      shadowOpacity: number;
      shadowRadius: number;
      elevation: number;
    };
    large: {
      shadowColor: string;
      shadowOffset: { width: number; height: number };
      shadowOpacity: number;
      shadowRadius: number;
      elevation: number;
    };
  };
  animations: {
    fast: number;
    normal: number;
    slow: number;
  };
}

export const createTheme = (isDark: boolean = true): Theme => {
  const colors = isDark ? DarkTheme : LightTheme;
  
  return {
    colors,
    typography: Typography,
    spacing: Spacing,
    shadows: {
      small: {
        shadowColor: isDark ? Colors.primaryWhite : Colors.primaryBlack,
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: isDark ? 0.1 : 0.08,
        shadowRadius: 4,
        elevation: 2,
      },
      medium: {
        shadowColor: isDark ? Colors.primaryWhite : Colors.primaryBlack,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: isDark ? 0.15 : 0.12,
        shadowRadius: 8,
        elevation: 4,
      },
      large: {
        shadowColor: isDark ? Colors.primaryWhite : Colors.primaryBlack,
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: isDark ? 0.2 : 0.16,
        shadowRadius: 16,
        elevation: 8,
      },
    },
    animations: {
      fast: 200,
      normal: 300,
      slow: 500,
    },
  };
};

// Default theme
export const defaultTheme = createTheme(true);

// Re-export common values for backward compatibility
export { Colors, DarkTheme, LightTheme, Typography, Spacing };
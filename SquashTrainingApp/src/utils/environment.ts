import { DEV_MODE_ENABLED } from '@env';

// Environment detection utilities
export const isDevelopment = () => {
  // Check multiple conditions for development mode
  return (
    __DEV__ || // React Native's built-in development flag
    DEV_MODE_ENABLED === 'true' ||
    process.env.NODE_ENV === 'development'
  );
};

export const isProduction = () => !isDevelopment();

// Feature flags based on environment
export const features = {
  // Enable mock data only in development when no API keys are present
  enableMockData: () => isDevelopment(),
  
  // Enable console logging only in development
  enableLogging: () => isDevelopment(),
  
  // Enable detailed error messages in development
  enableDetailedErrors: () => isDevelopment(),
  
  // Enable development tools (like dev login)
  enableDevTools: () => DEV_MODE_ENABLED === 'true',
};

// Conditional logging utility
export const devLog = (...args: any[]) => {
  if (features.enableLogging()) {
    console.log(...args);
  }
};

export const devWarn = (...args: any[]) => {
  if (features.enableLogging()) {
    console.warn(...args);
  }
};

export const devError = (...args: any[]) => {
  if (features.enableLogging()) {
    console.error(...args);
  }
};
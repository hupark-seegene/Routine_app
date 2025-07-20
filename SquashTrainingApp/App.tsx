import React, { useEffect } from 'react';
import { StatusBar } from 'react-native';
import AppNavigator from './src/navigation/AppNavigator';
import { AuthProvider } from './src/screens/auth/AuthContext';
import { ThemeProvider } from './src/contexts/ThemeContext';
import { initializeDatabase } from './src/database/database';
import NotificationService from './src/services/NotificationService';
import storageManager from './src/utils/storageManager';
import { devLog, devError } from './src/utils/environment';
import { ErrorBoundary } from './src/components/common';

function App(): React.JSX.Element {
  useEffect(() => {
    // 데이터베이스 초기화
    initializeDatabase()
      .then(() => {
        devLog('Database initialized successfully');
        // Storage migration after database is ready
        return storageManager.initializeStorage();
      })
      .then(() => {
        devLog('Storage system initialized successfully');
        // Initialize notification service after database is ready
        return NotificationService.init();
      })
      .then(() => {
        devLog('Notification system initialized successfully');
        // Request permissions for notifications (now using Alert API, so always returns true)
        return NotificationService.requestPermissions();
      })
      .then((granted) => {
        devLog('Notification permissions:', granted ? 'granted' : 'denied');
      })
      .catch((error) => {
        devError('Failed to initialize systems:', error);
      });

    return () => {
      // Cleanup if needed
    };
  }, []);

  return (
    <ErrorBoundary>
      <ThemeProvider>
        <AuthProvider>
          <StatusBar
            barStyle="light-content"
            backgroundColor="transparent"
            translucent
          />
          <AppNavigator />
        </AuthProvider>
      </ThemeProvider>
    </ErrorBoundary>
  );
}

export default App;

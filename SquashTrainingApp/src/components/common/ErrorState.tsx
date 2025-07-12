import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ViewStyle,
  Image,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../styles/Colors';
import { Typography } from '../../styles/Typography';
import { Button } from './Button';

interface ErrorStateProps {
  title?: string;
  message?: string;
  onRetry?: () => void;
  retryText?: string;
  fullScreen?: boolean;
  style?: ViewStyle;
  icon?: string;
  showIcon?: boolean;
}

export const ErrorState: React.FC<ErrorStateProps> = ({
  title = 'Something went wrong',
  message = 'An unexpected error occurred. Please try again.',
  onRetry,
  retryText = 'Try Again',
  fullScreen = false,
  style,
  icon = 'error-outline',
  showIcon = true,
}) => {
  return (
    <View
      style={[
        styles.container,
        fullScreen && styles.fullScreen,
        style,
      ]}
    >
      {showIcon && (
        <View style={styles.iconContainer}>
          <Icon name={icon} size={64} color={Colors.error} />
        </View>
      )}
      
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.message}>{message}</Text>
      
      {onRetry && (
        <Button
          title={retryText}
          onPress={onRetry}
          variant="primary"
          style={styles.retryButton}
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  fullScreen: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: Colors.background,
    zIndex: 999,
  },
  iconContainer: {
    marginBottom: 24,
    opacity: 0.8,
  },
  title: {
    ...Typography.h3,
    color: Colors.text,
    marginBottom: 8,
    textAlign: 'center',
  },
  message: {
    ...Typography.body1,
    color: Colors.textSecondary,
    textAlign: 'center',
    marginBottom: 24,
    maxWidth: 300,
  },
  retryButton: {
    minWidth: 120,
  },
});
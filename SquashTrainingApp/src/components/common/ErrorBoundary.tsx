import React, { Component, ReactNode } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  SafeAreaView,
  Alert,
} from 'react-native';
import { Colors, Typography, Spacing } from '../../styles';
import { features, devError } from '../../utils/environment';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: any) => void;
}

interface State {
  hasError: boolean;
  error: Error | null;
  errorInfo: any;
}

class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
    };
  }

  static getDerivedStateFromError(error: Error): State {
    return {
      hasError: true,
      error,
      errorInfo: null,
    };
  }

  componentDidCatch(error: Error, errorInfo: any) {
    // Log error in development
    devError('ErrorBoundary caught error:', error);
    devError('Error info:', errorInfo);

    // Call custom error handler if provided
    if (this.props.onError) {
      this.props.onError(error, errorInfo);
    }

    // Update state with error info
    this.setState({
      errorInfo,
    });
  }

  handleReset = () => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
    });
  };

  handleReport = () => {
    const { error, errorInfo } = this.state;
    const errorMessage = `Error: ${error?.toString() || 'Unknown error'}\n\nComponent Stack: ${
      errorInfo?.componentStack || 'Not available'
    }`;

    Alert.alert(
      'Report Error',
      'Would you like to report this error to help us improve the app?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Report',
          onPress: () => {
            // In production, this would send error to tracking service
            devError('Error reported:', errorMessage);
            Alert.alert('Thank You', 'The error has been reported.');
          },
        },
      ]
    );
  };

  render() {
    if (this.state.hasError) {
      // Custom fallback provided
      if (this.props.fallback) {
        return <>{this.props.fallback}</>;
      }

      // Default error UI
      return (
        <SafeAreaView style={styles.container}>
          <ScrollView contentContainerStyle={styles.content}>
            <View style={styles.errorContainer}>
              <Text style={styles.errorIcon}>⚠️</Text>
              <Text style={styles.title}>Oops! Something went wrong</Text>
              <Text style={styles.message}>
                We apologize for the inconvenience. The app encountered an unexpected error.
              </Text>

              {features.enableDetailedErrors() && this.state.error && (
                <View style={styles.errorDetails}>
                  <Text style={styles.errorDetailsTitle}>Error Details:</Text>
                  <Text style={styles.errorDetailsText}>
                    {this.state.error.toString()}
                  </Text>
                </View>
              )}

              <View style={styles.buttonContainer}>
                <TouchableOpacity
                  style={[styles.button, styles.primaryButton]}
                  onPress={this.handleReset}
                >
                  <Text style={styles.primaryButtonText}>Try Again</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={[styles.button, styles.secondaryButton]}
                  onPress={this.handleReport}
                >
                  <Text style={styles.secondaryButtonText}>Report Error</Text>
                </TouchableOpacity>
              </View>
            </View>
          </ScrollView>
        </SafeAreaView>
      );
    }

    return this.props.children;
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background.primary,
  },
  content: {
    flexGrow: 1,
    justifyContent: 'center',
    padding: Spacing.large,
  },
  errorContainer: {
    alignItems: 'center',
    maxWidth: 400,
    alignSelf: 'center',
  },
  errorIcon: {
    fontSize: 64,
    marginBottom: Spacing.medium,
  },
  title: {
    ...Typography.heading2,
    color: Colors.text.primary,
    textAlign: 'center',
    marginBottom: Spacing.small,
  },
  message: {
    ...Typography.body,
    color: Colors.text.secondary,
    textAlign: 'center',
    marginBottom: Spacing.large,
    lineHeight: 24,
  },
  errorDetails: {
    backgroundColor: Colors.background.secondary,
    padding: Spacing.medium,
    borderRadius: 8,
    marginBottom: Spacing.large,
    width: '100%',
  },
  errorDetailsTitle: {
    ...Typography.bodyBold,
    color: Colors.semantic.error,
    marginBottom: Spacing.small,
  },
  errorDetailsText: {
    ...Typography.caption,
    color: Colors.text.tertiary,
    fontFamily: 'monospace',
  },
  buttonContainer: {
    width: '100%',
    gap: Spacing.small,
  },
  button: {
    paddingVertical: Spacing.medium,
    paddingHorizontal: Spacing.large,
    borderRadius: 8,
    alignItems: 'center',
  },
  primaryButton: {
    backgroundColor: Colors.accent.primary,
  },
  primaryButtonText: {
    ...Typography.button,
    color: Colors.background.primary,
  },
  secondaryButton: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: Colors.text.tertiary,
  },
  secondaryButtonText: {
    ...Typography.button,
    color: Colors.text.primary,
  },
});

export default ErrorBoundary;
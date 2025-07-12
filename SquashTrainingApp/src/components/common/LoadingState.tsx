import React from 'react';
import {
  View,
  ActivityIndicator,
  Text,
  StyleSheet,
  ViewStyle,
} from 'react-native';
import { Colors } from '../../styles/Colors';
import { Typography } from '../../styles/Typography';

interface LoadingStateProps {
  message?: string;
  size?: 'small' | 'large';
  fullScreen?: boolean;
  style?: ViewStyle;
  color?: string;
}

export const LoadingState: React.FC<LoadingStateProps> = ({
  message,
  size = 'large',
  fullScreen = false,
  style,
  color = Colors.primary,
}) => {
  return (
    <View
      style={[
        styles.container,
        fullScreen && styles.fullScreen,
        style,
      ]}
    >
      <ActivityIndicator size={size} color={color} />
      {message && (
        <Text style={styles.message}>{message}</Text>
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
  message: {
    ...Typography.body1,
    color: Colors.textSecondary,
    marginTop: 16,
    textAlign: 'center',
  },
});
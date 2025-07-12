import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ViewStyle,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../styles/Colors';
import { Typography } from '../../styles/Typography';
import { Button } from './Button';

interface EmptyStateProps {
  title?: string;
  message?: string;
  icon?: string;
  actionText?: string;
  onAction?: () => void;
  style?: ViewStyle;
  showIcon?: boolean;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  title = 'No data found',
  message = 'There\'s nothing to show here yet.',
  icon = 'inbox',
  actionText,
  onAction,
  style,
  showIcon = true,
}) => {
  return (
    <View style={[styles.container, style]}>
      {showIcon && (
        <View style={styles.iconContainer}>
          <Icon name={icon} size={64} color={Colors.textSecondary} />
        </View>
      )}
      
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.message}>{message}</Text>
      
      {onAction && actionText && (
        <Button
          title={actionText}
          onPress={onAction}
          variant="primary"
          style={styles.actionButton}
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
    padding: 40,
  },
  iconContainer: {
    marginBottom: 24,
    opacity: 0.5,
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
  actionButton: {
    minWidth: 120,
  },
});
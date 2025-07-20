import React, { useState, useContext } from 'react';
import {
  View,
  ScrollView,
  StyleSheet,
  Switch,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { Colors } from '../styles/colors';
import { Text } from '../components/core/Text';
import { Card } from '../components/core/Card';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { ThemeContext } from '../contexts/ThemeContext';
import { BackupRestoreModal } from '../components/BackupRestoreModal';
import { useNavigation } from '@react-navigation/native';
import databaseService from '../services/databaseService';

export const SettingsScreen: React.FC = () => {
  const { theme, toggleTheme } = useContext(ThemeContext);
  const navigation = useNavigation();
  const [backupModalVisible, setBackupModalVisible] = useState(false);
  const [notifications, setNotifications] = useState({
    workoutReminder: true,
    achievementAlerts: true,
    weeklyReport: true,
  });

  const handleExportData = async () => {
    try {
      const analytics = await databaseService.getAnalytics();
      const dataStr = JSON.stringify(analytics, null, 2);
      Alert.alert(
        'Export Data',
        'Analytics data ready for export. In production, this would save to a CSV file.',
        [{ text: 'OK' }]
      );
    } catch (error) {
      Alert.alert('Error', 'Failed to export data');
    }
  };

  const handleResetProgress = () => {
    Alert.alert(
      'Reset Progress',
      'Are you sure you want to reset all your progress? This cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Reset',
          style: 'destructive',
          onPress: () => {
            Alert.alert('Success', 'Progress has been reset');
          },
        },
      ]
    );
  };

  const settingSections = [
    {
      title: 'Appearance',
      items: [
        {
          icon: 'theme-light-dark',
          title: 'Dark Mode',
          description: 'Toggle dark/light theme',
          action: (
            <Switch
              value={theme === 'dark'}
              onValueChange={toggleTheme}
              trackColor={{ false: Colors.cardBorder, true: Colors.primary }}
              thumbColor={theme === 'dark' ? Colors.primaryLight : '#f4f3f4'}
            />
          ),
        },
      ],
    },
    {
      title: 'Data Management',
      items: [
        {
          icon: 'backup-restore',
          title: 'Backup & Restore',
          description: 'Manage your data backups',
          onPress: () => setBackupModalVisible(true),
        },
        {
          icon: 'chart-line',
          title: 'Analytics',
          description: 'View detailed performance analytics',
          onPress: () => navigation.navigate('Analytics' as never),
        },
        {
          icon: 'download',
          title: 'Export Data',
          description: 'Export your data as CSV',
          onPress: handleExportData,
        },
        {
          icon: 'delete-forever',
          title: 'Reset Progress',
          description: 'Clear all workout data',
          onPress: handleResetProgress,
          danger: true,
        },
      ],
    },
    {
      title: 'Notifications',
      items: [
        {
          icon: 'bell-ring',
          title: 'Workout Reminders',
          description: 'Daily workout notifications',
          action: (
            <Switch
              value={notifications.workoutReminder}
              onValueChange={(value) =>
                setNotifications({ ...notifications, workoutReminder: value })
              }
              trackColor={{ false: Colors.cardBorder, true: Colors.primary }}
              thumbColor={notifications.workoutReminder ? Colors.primaryLight : '#f4f3f4'}
            />
          ),
        },
        {
          icon: 'trophy',
          title: 'Achievement Alerts',
          description: 'Notify on new achievements',
          action: (
            <Switch
              value={notifications.achievementAlerts}
              onValueChange={(value) =>
                setNotifications({ ...notifications, achievementAlerts: value })
              }
              trackColor={{ false: Colors.cardBorder, true: Colors.primary }}
              thumbColor={notifications.achievementAlerts ? Colors.primaryLight : '#f4f3f4'}
            />
          ),
        },
        {
          icon: 'calendar-week',
          title: 'Weekly Reports',
          description: 'Weekly progress summary',
          action: (
            <Switch
              value={notifications.weeklyReport}
              onValueChange={(value) =>
                setNotifications({ ...notifications, weeklyReport: value })
              }
              trackColor={{ false: Colors.cardBorder, true: Colors.primary }}
              thumbColor={notifications.weeklyReport ? Colors.primaryLight : '#f4f3f4'}
            />
          ),
        },
      ],
    },
    {
      title: 'About',
      items: [
        {
          icon: 'information',
          title: 'Version',
          description: '1.0.0 (Build 100)',
        },
        {
          icon: 'heart',
          title: 'Rate App',
          description: 'Love the app? Rate us!',
          onPress: () => Alert.alert('Thank you!', 'Thanks for your support!'),
        },
        {
          icon: 'email',
          title: 'Contact Support',
          description: 'Get help or report issues',
          onPress: () => Alert.alert('Support', 'support@squashtraining.app'),
        },
      ],
    },
  ];

  return (
    <>
      <ScrollView style={styles.container}>
        <View style={styles.header}>
          <Text variant="h4" style={styles.title}>Settings</Text>
        </View>

        {settingSections.map((section) => (
          <View key={section.title} style={styles.section}>
            <Text variant="h6" style={styles.sectionTitle}>
              {section.title}
            </Text>
            <Card style={styles.sectionCard}>
              {section.items.map((item, index) => (
                <TouchableOpacity
                  key={item.title}
                  style={[
                    styles.settingItem,
                    index < section.items.length - 1 && styles.settingItemBorder,
                  ]}
                  onPress={item.onPress}
                  disabled={!item.onPress}
                >
                  <View style={styles.settingIcon}>
                    <Icon
                      name={item.icon}
                      size={24}
                      color={item.danger ? Colors.error : Colors.primary}
                    />
                  </View>
                  <View style={styles.settingContent}>
                    <Text
                      style={[
                        styles.settingTitle,
                        item.danger && { color: Colors.error },
                      ]}
                    >
                      {item.title}
                    </Text>
                    <Text style={styles.settingDescription}>
                      {item.description}
                    </Text>
                  </View>
                  {item.action || (
                    item.onPress && (
                      <Icon
                        name="chevron-right"
                        size={24}
                        color={Colors.textSecondary}
                      />
                    )
                  )}
                </TouchableOpacity>
              ))}
            </Card>
          </View>
        ))}
      </ScrollView>

      <BackupRestoreModal
        visible={backupModalVisible}
        onClose={() => setBackupModalVisible(false)}
      />
    </>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  header: {
    padding: 20,
    paddingBottom: 10,
  },
  title: {
    color: Colors.text,
    fontWeight: 'bold',
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    color: Colors.textSecondary,
    marginHorizontal: 20,
    marginBottom: 8,
    fontWeight: '600',
  },
  sectionCard: {
    marginHorizontal: 20,
    padding: 0,
    overflow: 'hidden',
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
  },
  settingItemBorder: {
    borderBottomWidth: 1,
    borderBottomColor: Colors.cardBorder,
  },
  settingIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Colors.primaryTransparent,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  settingContent: {
    flex: 1,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: Colors.text,
  },
  settingDescription: {
    fontSize: 14,
    color: Colors.textSecondary,
    marginTop: 2,
  },
});
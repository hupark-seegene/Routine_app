import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TouchableOpacity,
  ScrollView,
  Alert,
  ActivityIndicator,
  Platform,
} from 'react-native';
import { Colors } from '../styles/colors';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import databaseService from '../services/databaseService';
import RNFS from 'react-native-fs';

interface BackupInfo {
  name: string;
  path: string;
  size: string;
  date: string;
}

interface BackupRestoreModalProps {
  visible: boolean;
  onClose: () => void;
}

export const BackupRestoreModal: React.FC<BackupRestoreModalProps> = ({
  visible,
  onClose,
}) => {
  const [loading, setLoading] = useState(false);
  const [backups, setBackups] = useState<BackupInfo[]>([]);
  const [selectedBackup, setSelectedBackup] = useState<string | null>(null);

  useEffect(() => {
    if (visible) {
      loadBackups();
    }
  }, [visible]);

  const loadBackups = async () => {
    try {
      setLoading(true);
      const backupDir = Platform.OS === 'ios' 
        ? `${RNFS.DocumentDirectoryPath}/backups`
        : `${RNFS.ExternalDirectoryPath}/backups`;
      
      const exists = await RNFS.exists(backupDir);
      if (!exists) {
        setBackups([]);
        return;
      }

      const files = await RNFS.readdir(backupDir);
      const backupFiles = files.filter(f => f.endsWith('.json'));
      
      const backupInfos = await Promise.all(
        backupFiles.map(async (file) => {
          const path = `${backupDir}/${file}`;
          const stat = await RNFS.stat(path);
          return {
            name: file.replace('.json', ''),
            path,
            size: formatBytes(stat.size),
            date: new Date(stat.mtime).toLocaleString(),
          };
        })
      );
      
      setBackups(backupInfos.sort((a, b) => 
        new Date(b.date).getTime() - new Date(a.date).getTime()
      ));
    } catch (error) {
      console.error('Error loading backups:', error);
      Alert.alert('Error', 'Failed to load backups');
    } finally {
      setLoading(false);
    }
  };

  const formatBytes = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const handleCreateBackup = async () => {
    try {
      setLoading(true);
      const backupPath = await databaseService.createBackup();
      Alert.alert(
        'Success',
        'Backup created successfully',
        [{ text: 'OK', onPress: loadBackups }]
      );
    } catch (error) {
      console.error('Backup error:', error);
      Alert.alert('Error', 'Failed to create backup');
    } finally {
      setLoading(false);
    }
  };

  const handleRestoreBackup = async () => {
    if (!selectedBackup) {
      Alert.alert('Error', 'Please select a backup to restore');
      return;
    }

    Alert.alert(
      'Confirm Restore',
      'This will replace all current data. Are you sure?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Restore',
          style: 'destructive',
          onPress: async () => {
            try {
              setLoading(true);
              await databaseService.restoreBackup(selectedBackup);
              Alert.alert(
                'Success',
                'Backup restored successfully',
                [{ text: 'OK', onPress: onClose }]
              );
            } catch (error) {
              console.error('Restore error:', error);
              Alert.alert('Error', 'Failed to restore backup');
            } finally {
              setLoading(false);
            }
          },
        },
      ]
    );
  };

  const handleDeleteBackup = async (path: string) => {
    Alert.alert(
      'Delete Backup',
      'Are you sure you want to delete this backup?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await RNFS.unlink(path);
              loadBackups();
            } catch (error) {
              console.error('Delete error:', error);
              Alert.alert('Error', 'Failed to delete backup');
            }
          },
        },
      ]
    );
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent={true}
      onRequestClose={onClose}
    >
      <View style={styles.container}>
        <View style={styles.content}>
          <View style={styles.header}>
            <Text style={styles.title}>Backup & Restore</Text>
            <TouchableOpacity onPress={onClose}>
              <Icon name="close" size={24} color={Colors.text} />
            </TouchableOpacity>
          </View>

          {loading ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color={Colors.primary} />
            </View>
          ) : (
            <>
              <TouchableOpacity
                style={styles.createButton}
                onPress={handleCreateBackup}
              >
                <Icon name="backup-restore" size={24} color={Colors.background} />
                <Text style={styles.createButtonText}>Create New Backup</Text>
              </TouchableOpacity>

              <ScrollView style={styles.backupList}>
                {backups.length === 0 ? (
                  <Text style={styles.emptyText}>No backups found</Text>
                ) : (
                  backups.map((backup) => (
                    <TouchableOpacity
                      key={backup.path}
                      style={[
                        styles.backupItem,
                        selectedBackup === backup.path && styles.selectedBackup,
                      ]}
                      onPress={() => setSelectedBackup(backup.path)}
                    >
                      <View style={styles.backupInfo}>
                        <Text style={styles.backupName}>{backup.name}</Text>
                        <Text style={styles.backupDetails}>
                          {backup.date} • {backup.size}
                        </Text>
                      </View>
                      <TouchableOpacity
                        onPress={() => handleDeleteBackup(backup.path)}
                        style={styles.deleteButton}
                      >
                        <Icon name="delete" size={20} color={Colors.error} />
                      </TouchableOpacity>
                    </TouchableOpacity>
                  ))
                )}
              </ScrollView>

              {selectedBackup && (
                <TouchableOpacity
                  style={styles.restoreButton}
                  onPress={handleRestoreBackup}
                >
                  <Icon name="restore" size={24} color={Colors.background} />
                  <Text style={styles.restoreButtonText}>Restore Selected Backup</Text>
                </TouchableOpacity>
              )}
            </>
          )}
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  content: {
    backgroundColor: Colors.background,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingTop: 20,
    paddingHorizontal: 20,
    paddingBottom: 40,
    maxHeight: '80%',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: Colors.text,
  },
  loadingContainer: {
    height: 200,
    justifyContent: 'center',
    alignItems: 'center',
  },
  createButton: {
    backgroundColor: Colors.primary,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    borderRadius: 12,
    marginBottom: 20,
  },
  createButtonText: {
    color: Colors.background,
    fontSize: 16,
    fontWeight: '600',
    marginLeft: 8,
  },
  backupList: {
    maxHeight: 300,
  },
  emptyText: {
    textAlign: 'center',
    color: Colors.textSecondary,
    fontSize: 16,
    marginTop: 20,
  },
  backupItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: Colors.card,
    padding: 16,
    borderRadius: 12,
    marginBottom: 8,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  selectedBackup: {
    borderColor: Colors.primary,
  },
  backupInfo: {
    flex: 1,
  },
  backupName: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.text,
  },
  backupDetails: {
    fontSize: 14,
    color: Colors.textSecondary,
    marginTop: 4,
  },
  deleteButton: {
    padding: 8,
  },
  restoreButton: {
    backgroundColor: Colors.accent,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    borderRadius: 12,
    marginTop: 20,
  },
  restoreButtonText: {
    color: Colors.background,
    fontSize: 16,
    fontWeight: '600',
    marginLeft: 8,
  },
});
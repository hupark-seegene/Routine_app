import DummyAsyncStorage from './DummyAsyncStorage';
import SQLiteAsyncStorage from './SQLiteAsyncStorage';

class StorageManager {
  private migrationKey = 'STORAGE_MIGRATED_TO_SQLITE';
  private hasMigrated = false;

  async migrateFromDummyToSQLite(): Promise<void> {
    try {
      // Check if migration has already been done
      const migrationStatus = await SQLiteAsyncStorage.getItem(this.migrationKey);
      if (migrationStatus === 'true') {
        this.hasMigrated = true;
        return;
      }

      console.log('Starting storage migration from DummyAsyncStorage to SQLiteAsyncStorage...');

      // Import all data from DummyAsyncStorage
      if (typeof DummyAsyncStorage.getStats === 'function') {
        const stats = DummyAsyncStorage.getStats();
        if (stats.keys && stats.keys.length > 0) {
          console.log(`Found ${stats.keys.length} items to migrate`);
          
          const migrationPairs: Array<[string, string]> = [];
          
          for (const key of stats.keys) {
            const value = await DummyAsyncStorage.getItem(key);
            if (value !== null) {
              migrationPairs.push([key, value]);
            }
          }
          
          if (migrationPairs.length > 0) {
            await SQLiteAsyncStorage.multiSet(migrationPairs);
            console.log(`Successfully migrated ${migrationPairs.length} items to SQLite storage`);
          }
        } else {
          console.log('No data found in DummyAsyncStorage to migrate');
        }
      }

      // Mark migration as complete
      await SQLiteAsyncStorage.setItem(this.migrationKey, 'true');
      this.hasMigrated = true;
      console.log('Storage migration completed successfully');
    } catch (error) {
      console.error('Storage migration failed:', error);
      // Don't throw error to prevent app crash
      // App will continue using SQLiteAsyncStorage even if migration fails
    }
  }

  async initializeStorage(): Promise<void> {
    // Always run migration check on app start
    await this.migrateFromDummyToSQLite();
  }

  isMigrationComplete(): boolean {
    return this.hasMigrated;
  }

  // Utility method to clear all storage (for testing)
  async clearAllStorage(): Promise<void> {
    await SQLiteAsyncStorage.clear();
    console.log('All storage data cleared');
  }

  // Utility method to get storage statistics
  async getStorageStats(): Promise<{ itemCount: number; keys: string[] }> {
    const keys = await SQLiteAsyncStorage.getAllKeys();
    return {
      itemCount: keys.length,
      keys,
    };
  }
}

export default new StorageManager();
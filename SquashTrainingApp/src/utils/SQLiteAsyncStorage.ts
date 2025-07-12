import SQLite from 'react-native-sqlite-storage';
import { getDBConnection } from '../database/database';

interface AsyncStorageStatic {
  getItem(key: string): Promise<string | null>;
  setItem(key: string, value: string): Promise<void>;
  removeItem(key: string): Promise<void>;
  clear(): Promise<void>;
  getAllKeys(): Promise<string[]>;
  multiGet(keys: string[]): Promise<Array<[string, string | null]>>;
  multiSet(keyValuePairs: Array<[string, string]>): Promise<void>;
  multiRemove(keys: string[]): Promise<void>;
}

class SQLiteAsyncStorage implements AsyncStorageStatic {
  private dbPromise: Promise<SQLite.SQLiteDatabase> | null = null;
  private isInitialized = false;

  constructor() {
    this.initDatabase();
  }

  private async initDatabase() {
    if (this.dbPromise) return this.dbPromise;
    
    this.dbPromise = (async () => {
      const db = await getDBConnection();
      
      // Create async storage table if not exists
      await db.executeSql(`
        CREATE TABLE IF NOT EXISTS async_storage (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
      `);
      
      // Create index for better performance
      await db.executeSql(`
        CREATE INDEX IF NOT EXISTS idx_async_storage_key ON async_storage(key);
      `);
      
      this.isInitialized = true;
      return db;
    })();
    
    return this.dbPromise;
  }

  private async getDb(): Promise<SQLite.SQLiteDatabase> {
    if (!this.dbPromise) {
      await this.initDatabase();
    }
    return this.dbPromise!;
  }

  async getItem(key: string): Promise<string | null> {
    try {
      const db = await this.getDb();
      const [result] = await db.executeSql(
        'SELECT value FROM async_storage WHERE key = ?',
        [key]
      );
      
      if (result.rows.length > 0) {
        return result.rows.item(0).value;
      }
      return null;
    } catch (error) {
      console.error('SQLiteAsyncStorage.getItem error:', error);
      return null;
    }
  }

  async setItem(key: string, value: string): Promise<void> {
    try {
      const db = await this.getDb();
      await db.executeSql(
        `INSERT OR REPLACE INTO async_storage (key, value, updated_at) 
         VALUES (?, ?, datetime('now'))`,
        [key, value]
      );
    } catch (error) {
      console.error('SQLiteAsyncStorage.setItem error:', error);
      throw error;
    }
  }

  async removeItem(key: string): Promise<void> {
    try {
      const db = await this.getDb();
      await db.executeSql(
        'DELETE FROM async_storage WHERE key = ?',
        [key]
      );
    } catch (error) {
      console.error('SQLiteAsyncStorage.removeItem error:', error);
      throw error;
    }
  }

  async clear(): Promise<void> {
    try {
      const db = await this.getDb();
      await db.executeSql('DELETE FROM async_storage');
    } catch (error) {
      console.error('SQLiteAsyncStorage.clear error:', error);
      throw error;
    }
  }

  async getAllKeys(): Promise<string[]> {
    try {
      const db = await this.getDb();
      const [result] = await db.executeSql(
        'SELECT key FROM async_storage ORDER BY key'
      );
      
      const keys: string[] = [];
      for (let i = 0; i < result.rows.length; i++) {
        keys.push(result.rows.item(i).key);
      }
      return keys;
    } catch (error) {
      console.error('SQLiteAsyncStorage.getAllKeys error:', error);
      return [];
    }
  }

  async multiGet(keys: string[]): Promise<Array<[string, string | null]>> {
    try {
      const db = await this.getDb();
      const placeholders = keys.map(() => '?').join(',');
      const [result] = await db.executeSql(
        `SELECT key, value FROM async_storage WHERE key IN (${placeholders})`,
        keys
      );
      
      const resultMap = new Map<string, string>();
      for (let i = 0; i < result.rows.length; i++) {
        const row = result.rows.item(i);
        resultMap.set(row.key, row.value);
      }
      
      return keys.map(key => [key, resultMap.get(key) || null]);
    } catch (error) {
      console.error('SQLiteAsyncStorage.multiGet error:', error);
      return keys.map(key => [key, null]);
    }
  }

  async multiSet(keyValuePairs: Array<[string, string]>): Promise<void> {
    try {
      const db = await this.getDb();
      
      // Use transaction for better performance
      await db.transaction(async (tx) => {
        for (const [key, value] of keyValuePairs) {
          tx.executeSql(
            `INSERT OR REPLACE INTO async_storage (key, value, updated_at) 
             VALUES (?, ?, datetime('now'))`,
            [key, value]
          );
        }
      });
    } catch (error) {
      console.error('SQLiteAsyncStorage.multiSet error:', error);
      throw error;
    }
  }

  async multiRemove(keys: string[]): Promise<void> {
    try {
      const db = await this.getDb();
      const placeholders = keys.map(() => '?').join(',');
      await db.executeSql(
        `DELETE FROM async_storage WHERE key IN (${placeholders})`,
        keys
      );
    } catch (error) {
      console.error('SQLiteAsyncStorage.multiRemove error:', error);
      throw error;
    }
  }

  // Migration helper to import data from old storage
  async importFromMemory(memoryStorage: any): Promise<void> {
    if (memoryStorage && typeof memoryStorage.getStats === 'function') {
      const stats = memoryStorage.getStats();
      if (stats.keys && stats.keys.length > 0) {
        console.log(`Migrating ${stats.keys.length} items from memory storage to SQLite...`);
        const pairs: Array<[string, string]> = [];
        
        for (const key of stats.keys) {
          const value = await memoryStorage.getItem(key);
          if (value !== null) {
            pairs.push([key, value]);
          }
        }
        
        if (pairs.length > 0) {
          await this.multiSet(pairs);
          console.log(`Successfully migrated ${pairs.length} items to SQLite storage`);
        }
      }
    }
  }
}

// Export single instance
const AsyncStorage = new SQLiteAsyncStorage();
export default AsyncStorage;

// Named export for compatibility
export { AsyncStorage };

// Type export for TypeScript
export type { AsyncStorageStatic };
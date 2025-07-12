// Dummy AsyncStorage implementation for compatibility issues
// React Native 0.80.1과 @react-native-async-storage/async-storage 호환성 문제 해결용

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

class DummyAsyncStorage implements AsyncStorageStatic {
  private storage: Map<string, string> = new Map();

  constructor() {
    console.log('DummyAsyncStorage: Initialized in-memory storage');
  }

  async getItem(key: string): Promise<string | null> {
    try {
      const value = this.storage.get(key) || null;
      console.log(`DummyAsyncStorage.getItem(${key}):`, value ? 'found' : 'not found');
      return value;
    } catch (error) {
      console.error('DummyAsyncStorage.getItem error:', error);
      return null;
    }
  }

  async setItem(key: string, value: string): Promise<void> {
    try {
      this.storage.set(key, value);
      console.log(`DummyAsyncStorage.setItem(${key}): stored`);
    } catch (error) {
      console.error('DummyAsyncStorage.setItem error:', error);
      throw error;
    }
  }

  async removeItem(key: string): Promise<void> {
    try {
      const existed = this.storage.has(key);
      this.storage.delete(key);
      console.log(`DummyAsyncStorage.removeItem(${key}):`, existed ? 'removed' : 'not found');
    } catch (error) {
      console.error('DummyAsyncStorage.removeItem error:', error);
      throw error;
    }
  }

  async clear(): Promise<void> {
    try {
      const count = this.storage.size;
      this.storage.clear();
      console.log(`DummyAsyncStorage.clear(): removed ${count} items`);
    } catch (error) {
      console.error('DummyAsyncStorage.clear error:', error);
      throw error;
    }
  }

  async getAllKeys(): Promise<string[]> {
    try {
      const keys = Array.from(this.storage.keys());
      console.log(`DummyAsyncStorage.getAllKeys(): found ${keys.length} keys`);
      return keys;
    } catch (error) {
      console.error('DummyAsyncStorage.getAllKeys error:', error);
      return [];
    }
  }

  async multiGet(keys: string[]): Promise<Array<[string, string | null]>> {
    try {
      const result: Array<[string, string | null]> = keys.map(key => [
        key,
        this.storage.get(key) || null
      ]);
      console.log(`DummyAsyncStorage.multiGet(${keys.length} keys): retrieved`);
      return result;
    } catch (error) {
      console.error('DummyAsyncStorage.multiGet error:', error);
      return keys.map(key => [key, null]);
    }
  }

  async multiSet(keyValuePairs: Array<[string, string]>): Promise<void> {
    try {
      keyValuePairs.forEach(([key, value]) => {
        this.storage.set(key, value);
      });
      console.log(`DummyAsyncStorage.multiSet(${keyValuePairs.length} pairs): stored`);
    } catch (error) {
      console.error('DummyAsyncStorage.multiSet error:', error);
      throw error;
    }
  }

  async multiRemove(keys: string[]): Promise<void> {
    try {
      let removedCount = 0;
      keys.forEach(key => {
        if (this.storage.has(key)) {
          this.storage.delete(key);
          removedCount++;
        }
      });
      console.log(`DummyAsyncStorage.multiRemove(${keys.length} keys): removed ${removedCount}`);
    } catch (error) {
      console.error('DummyAsyncStorage.multiRemove error:', error);
      throw error;
    }
  }

  // Helper method to get storage stats
  getStats() {
    return {
      size: this.storage.size,
      keys: Array.from(this.storage.keys()),
    };
  }
}

// Export single instance
const AsyncStorage = new DummyAsyncStorage();
export default AsyncStorage;

// Named export for compatibility
export { AsyncStorage };

// Type export for TypeScript
export type { AsyncStorageStatic };
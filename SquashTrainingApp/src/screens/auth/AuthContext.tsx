import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '../../utils/SQLiteAsyncStorage';
import { DEV_MODE_ENABLED } from '@env';
import { encrypt, decrypt } from '../../utils/crypto';
import { devError } from '../../utils/environment';

interface AuthContextType {
  isDeveloper: boolean;
  developerApiKey: string | null;
  login: (username: string, password: string, apiKey: string) => Promise<boolean>;
  logout: () => Promise<void>;
  isDevModeEnabled: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const AUTH_STORAGE_KEY = 'dev_auth';
const API_KEY_STORAGE_KEY = 'dev_api_key';

// Developer credentials (in production, these should be on a secure server)
const DEV_CREDENTIALS = {
  username: 'hupark',
  passwordHash: '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', // rhksflwk1!
};

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [isDeveloper, setIsDeveloper] = useState(false);
  const [developerApiKey, setDeveloperApiKey] = useState<string | null>(null);
  const isDevModeEnabled = DEV_MODE_ENABLED === 'true';

  useEffect(() => {
    checkAuthStatus();
  }, []);

  const checkAuthStatus = async () => {
    try {
      const authData = await AsyncStorage.getItem(AUTH_STORAGE_KEY);
      const encryptedApiKey = await AsyncStorage.getItem(API_KEY_STORAGE_KEY);
      
      if (authData === 'true' && encryptedApiKey) {
        setIsDeveloper(true);
        const decryptedKey = decrypt(encryptedApiKey);
        setDeveloperApiKey(decryptedKey);
      }
    } catch (error) {
      devError('Error checking auth status:', error);
    }
  };

  const login = async (username: string, password: string, apiKey: string): Promise<boolean> => {
    try {
      // Simple hash comparison (in production, use bcrypt or similar)
      const crypto = require('crypto-js');
      const inputPasswordHash = crypto.SHA256(password).toString();
      
      if (username === DEV_CREDENTIALS.username && inputPasswordHash === DEV_CREDENTIALS.passwordHash) {
        // Save auth status
        await AsyncStorage.setItem(AUTH_STORAGE_KEY, 'true');
        
        // Encrypt and save API key
        const encryptedApiKey = encrypt(apiKey);
        await AsyncStorage.setItem(API_KEY_STORAGE_KEY, encryptedApiKey);
        
        setIsDeveloper(true);
        setDeveloperApiKey(apiKey);
        return true;
      }
      
      return false;
    } catch (error) {
      devError('Login error:', error);
      return false;
    }
  };

  const logout = async () => {
    try {
      await AsyncStorage.removeItem(AUTH_STORAGE_KEY);
      await AsyncStorage.removeItem(API_KEY_STORAGE_KEY);
      setIsDeveloper(false);
      setDeveloperApiKey(null);
    } catch (error) {
      devError('Logout error:', error);
    }
  };

  return (
    <AuthContext.Provider value={{
      isDeveloper,
      developerApiKey,
      login,
      logout,
      isDevModeEnabled,
    }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
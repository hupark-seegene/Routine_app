import CryptoJS from 'crypto-js';

// Simple encryption for local storage
// Note: For production, use proper key management
const SECRET_KEY = 'squash-master-2024-secret-key';

export const encrypt = (text: string): string => {
  return CryptoJS.AES.encrypt(text, SECRET_KEY).toString();
};

export const decrypt = (ciphertext: string): string => {
  const bytes = CryptoJS.AES.decrypt(ciphertext, SECRET_KEY);
  return bytes.toString(CryptoJS.enc.Utf8);
};

// Hash password for comparison
export const hashPassword = (password: string): string => {
  return CryptoJS.SHA256(password).toString();
};

// Verify password
export const verifyPassword = (inputPassword: string, hashedPassword: string): boolean => {
  return hashPassword(inputPassword) === hashedPassword;
};
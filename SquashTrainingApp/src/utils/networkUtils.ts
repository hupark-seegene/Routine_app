import { devLog, devError, features } from './environment';

interface RetryOptions {
  maxAttempts?: number;
  delayMs?: number;
  backoffMultiplier?: number;
  maxDelayMs?: number;
  onRetry?: (attempt: number, error: any) => void;
}

interface FetchWithRetryOptions extends RetryOptions {
  timeout?: number;
}

// Custom error classes
export class NetworkError extends Error {
  constructor(message: string, public statusCode?: number) {
    super(message);
    this.name = 'NetworkError';
  }
}

export class TimeoutError extends Error {
  constructor(message: string = 'Request timed out') {
    super(message);
    this.name = 'TimeoutError';
  }
}

// Default retry configuration
const DEFAULT_RETRY_OPTIONS: Required<RetryOptions> = {
  maxAttempts: 3,
  delayMs: 1000,
  backoffMultiplier: 2,
  maxDelayMs: 10000,
  onRetry: () => {},
};

// Calculate delay with exponential backoff
const calculateDelay = (
  attempt: number,
  baseDelay: number,
  multiplier: number,
  maxDelay: number
): number => {
  const delay = baseDelay * Math.pow(multiplier, attempt - 1);
  return Math.min(delay, maxDelay);
};

// Check if error is retryable
const isRetryableError = (error: any): boolean => {
  // Network errors are retryable
  if (error instanceof NetworkError) {
    // Don't retry client errors (4xx) except for 429 (rate limit)
    if (error.statusCode && error.statusCode >= 400 && error.statusCode < 500) {
      return error.statusCode === 429;
    }
    return true;
  }
  
  // Timeout errors are retryable
  if (error instanceof TimeoutError) {
    return true;
  }
  
  // Generic network errors
  if (error.message && (
    error.message.includes('Network request failed') ||
    error.message.includes('Failed to fetch') ||
    error.message.includes('ECONNREFUSED') ||
    error.message.includes('ETIMEDOUT')
  )) {
    return true;
  }
  
  return false;
};

// Fetch with timeout support
const fetchWithTimeout = async (
  url: string,
  options: RequestInit,
  timeoutMs: number
): Promise<Response> => {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal,
    });
    clearTimeout(timeoutId);
    return response;
  } catch (error: any) {
    clearTimeout(timeoutId);
    if (error.name === 'AbortError') {
      throw new TimeoutError(`Request to ${url} timed out after ${timeoutMs}ms`);
    }
    throw error;
  }
};

// Main fetch with retry function
export const fetchWithRetry = async (
  url: string,
  options: RequestInit = {},
  retryOptions: FetchWithRetryOptions = {}
): Promise<Response> => {
  const config = { ...DEFAULT_RETRY_OPTIONS, ...retryOptions };
  const timeout = retryOptions.timeout || 30000; // 30 seconds default
  
  let lastError: any;
  
  for (let attempt = 1; attempt <= config.maxAttempts; attempt++) {
    try {
      devLog(`Attempt ${attempt}/${config.maxAttempts} for ${url}`);
      
      const response = await fetchWithTimeout(url, options, timeout);
      
      // Check if response is successful
      if (!response.ok) {
        throw new NetworkError(
          `HTTP ${response.status}: ${response.statusText}`,
          response.status
        );
      }
      
      return response;
    } catch (error: any) {
      lastError = error;
      
      // Log error details in development
      if (features.enableDetailedErrors()) {
        devError(`Request failed (attempt ${attempt}):`, error);
      }
      
      // Check if we should retry
      if (attempt < config.maxAttempts && isRetryableError(error)) {
        const delay = calculateDelay(
          attempt,
          config.delayMs,
          config.backoffMultiplier,
          config.maxDelayMs
        );
        
        devLog(`Retrying in ${delay}ms...`);
        config.onRetry(attempt, error);
        
        await new Promise(resolve => setTimeout(resolve, delay));
      } else {
        // No more retries
        break;
      }
    }
  }
  
  // All attempts failed
  throw lastError;
};

// Utility function for JSON API calls with retry
export const fetchJsonWithRetry = async <T>(
  url: string,
  options: RequestInit = {},
  retryOptions: FetchWithRetryOptions = {}
): Promise<T> => {
  const response = await fetchWithRetry(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
  }, retryOptions);
  
  try {
    return await response.json();
  } catch (error) {
    throw new Error('Invalid JSON response');
  }
};

// Error handler with user-friendly messages
export const handleApiError = (error: any): string => {
  if (error instanceof NetworkError) {
    if (error.statusCode === 429) {
      return 'Too many requests. Please try again later.';
    }
    if (error.statusCode === 401) {
      return 'Authentication failed. Please check your API key.';
    }
    if (error.statusCode === 403) {
      return 'Access denied. Please check your permissions.';
    }
    if (error.statusCode && error.statusCode >= 500) {
      return 'Server error. Please try again later.';
    }
  }
  
  if (error instanceof TimeoutError) {
    return 'Request timed out. Please check your connection and try again.';
  }
  
  if (error.message && error.message.includes('Network request failed')) {
    return 'No internet connection. Please check your network and try again.';
  }
  
  // Generic error message for production
  if (!features.enableDetailedErrors()) {
    return 'Something went wrong. Please try again later.';
  }
  
  // Detailed error in development
  return error.message || 'An unknown error occurred';
};
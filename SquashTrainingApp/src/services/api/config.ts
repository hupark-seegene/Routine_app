import { ANTHROPIC_API_KEY, OPENAI_API_KEY, YOUTUBE_API_KEY } from '@env';

// Function to get API configuration (can be overridden by developer mode)
export const getAPIConfig = (developerApiKey?: string | null) => ({
  // AI API Configuration
  AI: {
    // Using Claude Haiku for low-cost, fast responses
    ANTHROPIC_API_KEY: ANTHROPIC_API_KEY || '',
    ANTHROPIC_MODEL: 'claude-3-haiku-20240307',
    ANTHROPIC_BASE_URL: 'https://api.anthropic.com/v1',
    
    // Alternative: OpenAI GPT-3.5-turbo
    OPENAI_API_KEY: developerApiKey || OPENAI_API_KEY || '',
    OPENAI_MODEL: 'gpt-3.5-turbo',
    OPENAI_BASE_URL: 'https://api.openai.com/v1',
    
    // Default AI provider - use OpenAI if developer key is provided
    DEFAULT_PROVIDER: developerApiKey ? 'openai' : 'anthropic',
  },
  
  // YouTube API Configuration
  YOUTUBE: {
    API_KEY: YOUTUBE_API_KEY || '',
    BASE_URL: 'https://www.googleapis.com/youtube/v3',
    MAX_RESULTS: 10,
  },
  
  // Request Configuration
  REQUEST: {
    TIMEOUT: 30000, // 30 seconds
    RETRY_ATTEMPTS: 3,
    CACHE_DURATION: 3600000, // 1 hour in milliseconds
  },
});

// Default configuration (backward compatibility)
export const API_CONFIG = getAPIConfig();

// API Endpoints
export const API_ENDPOINTS = {
  // Anthropic
  ANTHROPIC_MESSAGES: '/messages',
  
  // OpenAI
  OPENAI_COMPLETIONS: '/chat/completions',
  
  // YouTube
  YOUTUBE_SEARCH: '/search',
  YOUTUBE_VIDEOS: '/videos',
};

// Error Messages
export const API_ERRORS = {
  NO_API_KEY: 'API key is not configured',
  NETWORK_ERROR: 'Network request failed',
  TIMEOUT: 'Request timed out',
  INVALID_RESPONSE: 'Invalid response from server',
  RATE_LIMIT: 'API rate limit exceeded',
};
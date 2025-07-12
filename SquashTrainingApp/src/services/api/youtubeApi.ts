import { getAPIConfig, API_ENDPOINTS, API_ERRORS } from './config';
import AsyncStorage from '../../utils/SQLiteAsyncStorage';
import { features, devLog, devError } from '../../utils/environment';
import { fetchJsonWithRetry, handleApiError } from '../../utils/networkUtils';

interface YouTubeVideo {
  id: string;
  title: string;
  description: string;
  thumbnailUrl: string;
  channelTitle: string;
  duration: string;
  viewCount: number;
}

interface SearchParams {
  skillLevel: string;
  topic: string;
  maxResults?: number;
}

class YouTubeApiService {
  private cacheKey = 'YOUTUBE_CACHE';

  // Search for squash training videos
  async searchVideos(params: SearchParams): Promise<YouTubeVideo[]> {
    try {
      // Check cache first
      const cached = await this.getCachedVideos(params);
      if (cached) {
        return cached;
      }

      const apiKey = getAPIConfig().YOUTUBE.API_KEY;
      if (!apiKey) {
        if (features.enableMockData()) {
          devLog('YouTube API: No API key, returning mock data');
          return this.getMockVideos(params);
        } else {
          throw new Error('YouTube API key not configured. Please contact support.');
        }
      }

      // Build search query
      const query = this.buildSearchQuery(params);
      
      // Search videos
      const searchUrl = `${getAPIConfig().YOUTUBE.BASE_URL}${API_ENDPOINTS.YOUTUBE_SEARCH}`;
      const searchParams = new URLSearchParams({
        key: apiKey,
        q: query,
        part: 'snippet',
        type: 'video',
        maxResults: String(params.maxResults || getAPIConfig().YOUTUBE.MAX_RESULTS),
        videoDuration: 'medium', // 4-20 minutes
        relevanceLanguage: 'en',
        safeSearch: 'strict',
      });

      // Search videos with retry logic
      const searchData = await fetchJsonWithRetry<any>(
        `${searchUrl}?${searchParams}`,
        {
          method: 'GET',
        },
        {
          timeout: getAPIConfig().REQUEST.TIMEOUT,
          maxAttempts: getAPIConfig().REQUEST.RETRY_ATTEMPTS,
          onRetry: (attempt, error) => {
            devLog(`Retrying YouTube search request (attempt ${attempt})`);
          },
        }
      );
      
      const videoIds = searchData.items.map((item: any) => item.id.videoId).join(',');

      // Get video details with retry logic
      const detailsUrl = `${getAPIConfig().YOUTUBE.BASE_URL}${API_ENDPOINTS.YOUTUBE_VIDEOS}`;
      const detailsParams = new URLSearchParams({
        key: apiKey,
        id: videoIds,
        part: 'snippet,contentDetails,statistics',
      });

      const detailsData = await fetchJsonWithRetry<any>(
        `${detailsUrl}?${detailsParams}`,
        {
          method: 'GET',
        },
        {
          timeout: getAPIConfig().REQUEST.TIMEOUT,
          maxAttempts: getAPIConfig().REQUEST.RETRY_ATTEMPTS,
          onRetry: (attempt, error) => {
            devLog(`Retrying YouTube details request (attempt ${attempt})`);
          },
        }
      );
      const videos = this.formatVideos(detailsData.items);

      // Cache results
      await this.cacheVideos(params, videos);

      return videos;
    } catch (error: any) {
      devError('YouTube API Error:', error);
      if (features.enableMockData()) {
        devLog('YouTube API: Falling back to mock data due to error');
        return this.getMockVideos(params);
      } else {
        const userMessage = handleApiError(error);
        throw new Error(userMessage);
      }
    }
  }

  // Build search query based on parameters
  private buildSearchQuery(params: SearchParams): string {
    const baseQuery = 'squash training';
    const levelPrefix = {
      beginner: 'beginner squash basics',
      intermediate: 'intermediate squash techniques',
      advanced: 'advanced squash tactics',
    };

    const level = levelPrefix[params.skillLevel as keyof typeof levelPrefix] || baseQuery;
    return `${level} ${params.topic}`;
  }

  // Format video data
  private formatVideos(items: any[]): YouTubeVideo[] {
    return items.map((item) => ({
      id: item.id,
      title: item.snippet.title,
      description: item.snippet.description.substring(0, 200) + '...',
      thumbnailUrl: item.snippet.thumbnails.high.url,
      channelTitle: item.snippet.channelTitle,
      duration: this.formatDuration(item.contentDetails.duration),
      viewCount: parseInt(item.statistics.viewCount, 10),
    }));
  }

  // Convert ISO 8601 duration to readable format
  private formatDuration(duration: string): string {
    const match = duration.match(/PT(\d+H)?(\d+M)?(\d+S)?/);
    if (!match) return '';

    const hours = match[1] ? parseInt(match[1], 10) : 0;
    const minutes = match[2] ? parseInt(match[2], 10) : 0;
    const seconds = match[3] ? parseInt(match[3], 10) : 0;

    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }

  // Cache management
  private async getCachedVideos(params: SearchParams): Promise<YouTubeVideo[] | null> {
    try {
      const cached = await AsyncStorage.getItem(this.cacheKey);
      if (!cached) return null;

      const cachedData = JSON.parse(cached);
      const cacheAge = Date.now() - cachedData.timestamp;

      if (cacheAge < getAPIConfig().REQUEST.CACHE_DURATION) {
        const cacheKey = JSON.stringify(params);
        if (cachedData[cacheKey]) {
          return cachedData[cacheKey];
        }
      }
    } catch (error) {
      devError('Cache read error:', error);
    }
    return null;
  }

  private async cacheVideos(params: SearchParams, videos: YouTubeVideo[]): Promise<void> {
    try {
      const cached = await AsyncStorage.getItem(this.cacheKey);
      const cachedData = cached ? JSON.parse(cached) : { timestamp: Date.now() };
      
      const cacheKey = JSON.stringify(params);
      cachedData[cacheKey] = videos;
      cachedData.timestamp = Date.now();

      await AsyncStorage.setItem(this.cacheKey, JSON.stringify(cachedData));
    } catch (error) {
      devError('Cache write error:', error);
    }
  }

  // Mock data for development/testing
  private getMockVideos(params: SearchParams): YouTubeVideo[] {
    const mockVideos = {
      beginner: [
        {
          id: 'mock1',
          title: 'Squash Basics: Grip and Stance for Beginners',
          description: 'Learn the fundamental grip techniques and proper stance for squash...',
          thumbnailUrl: 'https://via.placeholder.com/480x360?text=Squash+Basics',
          channelTitle: 'Squash Coach Pro',
          duration: '8:45',
          viewCount: 125000,
        },
        {
          id: 'mock2',
          title: 'Basic Squash Shots Every Beginner Should Know',
          description: 'Master the essential shots in squash including forehand, backhand...',
          thumbnailUrl: 'https://via.placeholder.com/480x360?text=Basic+Shots',
          channelTitle: 'Squash Academy',
          duration: '12:30',
          viewCount: 89000,
        },
      ],
      intermediate: [
        {
          id: 'mock3',
          title: 'Intermediate Squash Tactics: Court Movement',
          description: 'Improve your court movement and positioning with these drills...',
          thumbnailUrl: 'https://via.placeholder.com/480x360?text=Court+Movement',
          channelTitle: 'Pro Squash Training',
          duration: '15:20',
          viewCount: 67000,
        },
        {
          id: 'mock4',
          title: 'Developing Your Drop Shot - Intermediate Guide',
          description: 'Perfect your drop shot technique with step-by-step instructions...',
          thumbnailUrl: 'https://via.placeholder.com/480x360?text=Drop+Shot',
          channelTitle: 'Squash Masters',
          duration: '10:15',
          viewCount: 45000,
        },
      ],
      advanced: [
        {
          id: 'mock5',
          title: 'Advanced Deception Techniques in Squash',
          description: 'Learn how to deceive your opponent with advanced shot disguise...',
          thumbnailUrl: 'https://via.placeholder.com/480x360?text=Deception',
          channelTitle: 'Elite Squash',
          duration: '18:40',
          viewCount: 34000,
        },
        {
          id: 'mock6',
          title: 'Mental Game: Advanced Squash Psychology',
          description: 'Master the mental aspects of competitive squash...',
          thumbnailUrl: 'https://via.placeholder.com/480x360?text=Mental+Game',
          channelTitle: 'Squash Mind Coach',
          duration: '22:00',
          viewCount: 28000,
        },
      ],
    };

    return mockVideos[params.skillLevel as keyof typeof mockVideos] || mockVideos.beginner;
  }

  // Get recommended videos based on user performance
  async getRecommendedVideos(
    skillLevel: string,
    weakAreas: string[]
  ): Promise<YouTubeVideo[]> {
    const recommendations: YouTubeVideo[] = [];

    // Get videos for each weak area
    for (const area of weakAreas.slice(0, 3)) {
      // Limit to 3 areas
      const videos = await this.searchVideos({
        skillLevel,
        topic: area,
        maxResults: 3,
      });
      recommendations.push(...videos);
    }

    // Remove duplicates and limit results
    const uniqueVideos = Array.from(
      new Map(recommendations.map((v) => [v.id, v])).values()
    );
    return uniqueVideos.slice(0, 6);
  }
}

export default new YouTubeApiService();
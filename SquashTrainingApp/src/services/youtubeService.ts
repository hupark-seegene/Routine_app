// YouTube service for fetching squash training videos
// Note: In production, you'll need to add your YouTube API key

import { Alert } from 'react-native';

const YOUTUBE_API_KEY = 'YOUR_YOUTUBE_API_KEY'; // Replace with actual API key
const BASE_URL = 'https://www.googleapis.com/youtube/v3';

export interface YouTubeVideo {
  id: string;
  title: string;
  description: string;
  thumbnail: string;
  channelTitle: string;
  duration: string;
  viewCount: string;
  publishedAt: string;
}

export interface YouTubePlaylist {
  id: string;
  title: string;
  description: string;
  thumbnail: string;
  itemCount: number;
}

class YouTubeService {
  private apiKey: string;

  constructor() {
    this.apiKey = YOUTUBE_API_KEY;
  }

  // Search for squash training videos
  async searchVideos(query: string, maxResults: number = 10): Promise<YouTubeVideo[]> {
    try {
      if (this.apiKey === 'YOUR_YOUTUBE_API_KEY') {
        // Return mock data when API key is not set
        return this.getMockVideos(query);
      }

      const searchQuery = `squash training ${query}`;
      const url = `${BASE_URL}/search?part=snippet&q=${encodeURIComponent(searchQuery)}&maxResults=${maxResults}&type=video&videoCategoryId=17&key=${this.apiKey}`;
      
      const response = await fetch(url);
      const data = await response.json();

      if (data.error) {
        throw new Error(data.error.message);
      }

      // Get video details for duration
      const videoIds = data.items.map((item: any) => item.id.videoId).join(',');
      const detailsUrl = `${BASE_URL}/videos?part=contentDetails,statistics&id=${videoIds}&key=${this.apiKey}`;
      const detailsResponse = await fetch(detailsUrl);
      const detailsData = await detailsResponse.json();

      return data.items.map((item: any, index: number) => {
        const details = detailsData.items[index];
        return {
          id: item.id.videoId,
          title: item.snippet.title,
          description: item.snippet.description,
          thumbnail: item.snippet.thumbnails.high.url,
          channelTitle: item.snippet.channelTitle,
          duration: this.formatDuration(details?.contentDetails?.duration || 'PT0M'),
          viewCount: details?.statistics?.viewCount || '0',
          publishedAt: item.snippet.publishedAt,
        };
      });
    } catch (error) {
      console.error('YouTube search error:', error);
      return this.getMockVideos(query);
    }
  }

  // Get curated playlists for different skill levels
  async getCuratedPlaylists(): Promise<YouTubePlaylist[]> {
    try {
      if (this.apiKey === 'YOUR_YOUTUBE_API_KEY') {
        return this.getMockPlaylists();
      }

      // These would be real playlist IDs in production
      const playlistIds = [
        'PLxxxxxx1', // Beginner
        'PLxxxxxx2', // Intermediate  
        'PLxxxxxx3', // Advanced
      ];

      const promises = playlistIds.map(id => this.getPlaylistDetails(id));
      const playlists = await Promise.all(promises);
      return playlists.filter(p => p !== null) as YouTubePlaylist[];
    } catch (error) {
      console.error('YouTube playlist error:', error);
      return this.getMockPlaylists();
    }
  }

  // Get videos by category
  async getVideosByCategory(category: string): Promise<YouTubeVideo[]> {
    const categoryQueries: Record<string, string> = {
      technique: 'squash technique drills footwork',
      fitness: 'squash fitness training conditioning',
      tactics: 'squash tactics strategy game plan',
      mental: 'squash mental training psychology',
      matches: 'squash match analysis professional',
    };

    const query = categoryQueries[category] || category;
    return this.searchVideos(query, 15);
  }

  // Get playlist details
  private async getPlaylistDetails(playlistId: string): Promise<YouTubePlaylist | null> {
    try {
      const url = `${BASE_URL}/playlists?part=snippet,contentDetails&id=${playlistId}&key=${this.apiKey}`;
      const response = await fetch(url);
      const data = await response.json();

      if (data.items && data.items.length > 0) {
        const item = data.items[0];
        return {
          id: item.id,
          title: item.snippet.title,
          description: item.snippet.description,
          thumbnail: item.snippet.thumbnails.high.url,
          itemCount: item.contentDetails.itemCount,
        };
      }
      return null;
    } catch (error) {
      console.error('Playlist details error:', error);
      return null;
    }
  }

  // Format ISO 8601 duration to readable format
  private formatDuration(duration: string): string {
    const match = duration.match(/PT(\d+H)?(\d+M)?(\d+S)?/);
    if (!match) return '0:00';

    const hours = (match[1] || '').replace('H', '');
    const minutes = (match[2] || '0').replace('M', '');
    const seconds = (match[3] || '0').replace('S', '');

    let formatted = '';
    if (hours) {
      formatted += `${hours}:`;
    }
    formatted += `${minutes.padStart(hours ? 2 : 1, '0')}:`;
    formatted += seconds.padStart(2, '0');

    return formatted;
  }

  // Mock data for development
  private getMockVideos(query: string): YouTubeVideo[] {
    const categories = {
      beginner: [
        {
          id: 'mock1',
          title: 'Squash Basics: Grip and Stance for Beginners',
          description: 'Learn the fundamental grip and stance techniques for squash beginners.',
          thumbnail: 'https://via.placeholder.com/480x360/4CAF50/FFFFFF?text=Grip+%26+Stance',
          channelTitle: 'Squash Academy',
          duration: '8:45',
          viewCount: '125,430',
          publishedAt: '2024-01-15T10:00:00Z',
        },
        {
          id: 'mock2',
          title: 'Basic Squash Footwork Drills',
          description: 'Essential footwork patterns every squash player should master.',
          thumbnail: 'https://via.placeholder.com/480x360/2196F3/FFFFFF?text=Footwork+Drills',
          channelTitle: 'Pro Squash Training',
          duration: '12:30',
          viewCount: '89,200',
          publishedAt: '2024-02-20T14:30:00Z',
        },
      ],
      intermediate: [
        {
          id: 'mock3',
          title: 'Advanced Shot Selection in Squash',
          description: 'Improve your game with strategic shot selection techniques.',
          thumbnail: 'https://via.placeholder.com/480x360/FF9800/FFFFFF?text=Shot+Selection',
          channelTitle: 'Squash Masters',
          duration: '15:20',
          viewCount: '67,890',
          publishedAt: '2024-03-10T09:15:00Z',
        },
        {
          id: 'mock4',
          title: 'Squash Fitness: HIIT Workout for Players',
          description: 'High-intensity interval training designed specifically for squash players.',
          thumbnail: 'https://via.placeholder.com/480x360/E91E63/FFFFFF?text=HIIT+Workout',
          channelTitle: 'Fit for Squash',
          duration: '20:00',
          viewCount: '156,000',
          publishedAt: '2024-03-25T16:00:00Z',
        },
      ],
      advanced: [
        {
          id: 'mock5',
          title: 'Pro-Level Deception Techniques',
          description: 'Master the art of deception with these advanced techniques.',
          thumbnail: 'https://via.placeholder.com/480x360/9C27B0/FFFFFF?text=Deception',
          channelTitle: 'Elite Squash',
          duration: '18:15',
          viewCount: '45,230',
          publishedAt: '2024-04-05T11:30:00Z',
        },
      ],
    };

    // Return appropriate videos based on query
    const lowerQuery = query.toLowerCase();
    if (lowerQuery.includes('beginner') || lowerQuery.includes('basic')) {
      return categories.beginner;
    } else if (lowerQuery.includes('advanced') || lowerQuery.includes('pro')) {
      return categories.advanced;
    }
    return categories.intermediate;
  }

  private getMockPlaylists(): YouTubePlaylist[] {
    return [
      {
        id: 'pl_beginner',
        title: 'Complete Beginner Squash Course',
        description: 'Everything you need to start playing squash from zero.',
        thumbnail: 'https://via.placeholder.com/480x360/4CAF50/FFFFFF?text=Beginner+Course',
        itemCount: 25,
      },
      {
        id: 'pl_intermediate',
        title: 'Intermediate Squash Training Program',
        description: 'Take your squash game to the next level with structured training.',
        thumbnail: 'https://via.placeholder.com/480x360/2196F3/FFFFFF?text=Intermediate+Program',
        itemCount: 40,
      },
      {
        id: 'pl_advanced',
        title: 'Advanced Squash Mastery',
        description: 'Professional-level techniques and strategies for serious players.',
        thumbnail: 'https://via.placeholder.com/480x360/FF5722/FFFFFF?text=Advanced+Mastery',
        itemCount: 35,
      },
      {
        id: 'pl_fitness',
        title: 'Squash-Specific Fitness Training',
        description: 'Build strength, speed, and endurance for squash.',
        thumbnail: 'https://via.placeholder.com/480x360/FF9800/FFFFFF?text=Fitness+Training',
        itemCount: 30,
      },
    ];
  }

  // Open video in YouTube app or browser
  openVideo(videoId: string) {
    const youtubeUrl = `https://www.youtube.com/watch?v=${videoId}`;
    // In a real app, you would use Linking API
    Alert.alert(
      'Open Video',
      `Would open: ${youtubeUrl}`,
      [{ text: 'OK' }]
    );
  }
}

export default new YouTubeService();
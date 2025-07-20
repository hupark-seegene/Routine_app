import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Image,
  Dimensions,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { Colors } from '../styles/colors';
import { YouTubeVideo } from '../services/youtubeService';

interface VideoCardProps {
  video: YouTubeVideo;
  onPress: () => void;
  style?: any;
}

const { width } = Dimensions.get('window');

export const VideoCard: React.FC<VideoCardProps> = ({ video, onPress, style }) => {
  const formatViewCount = (count: string): string => {
    const num = parseInt(count.replace(/,/g, ''));
    if (num >= 1000000) {
      return `${(num / 1000000).toFixed(1)}M views`;
    } else if (num >= 1000) {
      return `${(num / 1000).toFixed(0)}K views`;
    }
    return `${num} views`;
  };

  const formatPublishedDate = (dateStr: string): string => {
    const date = new Date(dateStr);
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - date.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays < 7) {
      return `${diffDays} days ago`;
    } else if (diffDays < 30) {
      return `${Math.floor(diffDays / 7)} weeks ago`;
    } else if (diffDays < 365) {
      return `${Math.floor(diffDays / 30)} months ago`;
    }
    return `${Math.floor(diffDays / 365)} years ago`;
  };

  return (
    <TouchableOpacity style={[styles.container, style]} onPress={onPress}>
      <View style={styles.thumbnailContainer}>
        <Image source={{ uri: video.thumbnail }} style={styles.thumbnail} />
        <View style={styles.durationBadge}>
          <Text style={styles.durationText}>{video.duration}</Text>
        </View>
        <View style={styles.playOverlay}>
          <Icon name="play-circle" size={50} color="rgba(255,255,255,0.9)" />
        </View>
      </View>
      
      <View style={styles.infoContainer}>
        <Text style={styles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.channelName}>{video.channelTitle}</Text>
        <View style={styles.metaContainer}>
          <Text style={styles.metaText}>
            {formatViewCount(video.viewCount)}
          </Text>
          <Text style={styles.metaSeparator}>•</Text>
          <Text style={styles.metaText}>
            {formatPublishedDate(video.publishedAt)}
          </Text>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: Colors.card,
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: 16,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  thumbnailContainer: {
    width: '100%',
    aspectRatio: 16 / 9,
    position: 'relative',
  },
  thumbnail: {
    width: '100%',
    height: '100%',
    backgroundColor: Colors.cardBorder,
  },
  durationBadge: {
    position: 'absolute',
    bottom: 8,
    right: 8,
    backgroundColor: 'rgba(0,0,0,0.8)',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 4,
  },
  durationText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '600',
  },
  playOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0.1)',
  },
  infoContainer: {
    padding: 12,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.text,
    marginBottom: 4,
    lineHeight: 20,
  },
  channelName: {
    fontSize: 14,
    color: Colors.primary,
    marginBottom: 4,
  },
  metaContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  metaText: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  metaSeparator: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginHorizontal: 6,
  },
});

// Compact video card for lists
export const CompactVideoCard: React.FC<VideoCardProps> = ({ video, onPress }) => {
  return (
    <TouchableOpacity style={compactStyles.container} onPress={onPress}>
      <Image source={{ uri: video.thumbnail }} style={compactStyles.thumbnail} />
      <View style={compactStyles.infoContainer}>
        <Text style={compactStyles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={compactStyles.channelName}>{video.channelTitle}</Text>
        <Text style={compactStyles.duration}>{video.duration}</Text>
      </View>
      <Icon name="play-circle-outline" size={32} color={Colors.primary} />
    </TouchableOpacity>
  );
};

const compactStyles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    backgroundColor: Colors.card,
    borderRadius: 8,
    padding: 12,
    marginBottom: 8,
    alignItems: 'center',
  },
  thumbnail: {
    width: 80,
    height: 45,
    borderRadius: 6,
    backgroundColor: Colors.cardBorder,
  },
  infoContainer: {
    flex: 1,
    marginLeft: 12,
    marginRight: 8,
  },
  title: {
    fontSize: 14,
    fontWeight: '500',
    color: Colors.text,
    marginBottom: 2,
  },
  channelName: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginBottom: 2,
  },
  duration: {
    fontSize: 12,
    color: Colors.primary,
    fontWeight: '600',
  },
});
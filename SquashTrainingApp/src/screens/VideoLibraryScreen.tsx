import React, { useState, useEffect } from 'react';
import {
  View,
  ScrollView,
  StyleSheet,
  ActivityIndicator,
  RefreshControl,
  Linking,
  Alert,
} from 'react-native';
import { Text } from '../components/core/Text';
import { Card } from '../components/core/Card';
import { Button } from '../components/core/Button';
import { VideoCard, CompactVideoCard } from '../components/VideoCard';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { Colors } from '../styles/colors';
import youtubeService, { YouTubeVideo, YouTubePlaylist } from '../services/youtubeService';

export const VideoLibraryScreen: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [videos, setVideos] = useState<YouTubeVideo[]>([]);
  const [playlists, setPlaylists] = useState<YouTubePlaylist[]>([]);
  const [searchQuery, setSearchQuery] = useState('');

  const categories = [
    { id: 'all', name: 'All Videos', icon: 'video' },
    { id: 'technique', name: 'Technique', icon: 'tennis' },
    { id: 'fitness', name: 'Fitness', icon: 'dumbbell' },
    { id: 'tactics', name: 'Tactics', icon: 'strategy' },
    { id: 'mental', name: 'Mental', icon: 'brain' },
    { id: 'matches', name: 'Matches', icon: 'tournament' },
  ];

  useEffect(() => {
    loadContent();
  }, [selectedCategory]);

  const loadContent = async () => {
    try {
      setLoading(true);
      
      if (selectedCategory === 'all') {
        const [videosData, playlistsData] = await Promise.all([
          youtubeService.searchVideos('squash training', 10),
          youtubeService.getCuratedPlaylists(),
        ]);
        setVideos(videosData);
        setPlaylists(playlistsData);
      } else {
        const videosData = await youtubeService.getVideosByCategory(selectedCategory);
        setVideos(videosData);
        setPlaylists([]);
      }
    } catch (error) {
      console.error('Error loading content:', error);
      Alert.alert('Error', 'Failed to load videos. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setRefreshing(true);
    loadContent();
  };

  const handleVideoPress = async (video: YouTubeVideo) => {
    const url = `https://www.youtube.com/watch?v=${video.id}`;
    const supported = await Linking.canOpenURL(url);
    
    if (supported) {
      await Linking.openURL(url);
    } else {
      Alert.alert('Error', 'Cannot open YouTube video');
    }
  };

  const handlePlaylistPress = async (playlist: YouTubePlaylist) => {
    const url = `https://www.youtube.com/playlist?list=${playlist.id}`;
    const supported = await Linking.canOpenURL(url);
    
    if (supported) {
      await Linking.openURL(url);
    } else {
      Alert.alert('Error', 'Cannot open YouTube playlist');
    }
  };

  const handleSearch = async () => {
    if (!searchQuery.trim()) return;
    
    setLoading(true);
    try {
      const results = await youtubeService.searchVideos(searchQuery);
      setVideos(results);
      setPlaylists([]);
    } catch (error) {
      Alert.alert('Error', 'Search failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      <View style={styles.header}>
        <Text variant="h4" style={styles.title}>Video Library</Text>
        <Text style={styles.subtitle}>Learn from the best squash tutorials</Text>
      </View>

      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <View style={styles.searchBar}>
          <Icon name="magnify" size={24} color={Colors.textSecondary} />
          <TextInput
            style={styles.searchInput}
            placeholder="Search videos..."
            placeholderTextColor={Colors.textSecondary}
            value={searchQuery}
            onChangeText={setSearchQuery}
            onSubmitEditing={handleSearch}
            returnKeyType="search"
          />
          {searchQuery.length > 0 && (
            <TouchableOpacity onPress={() => setSearchQuery('')}>
              <Icon name="close-circle" size={20} color={Colors.textSecondary} />
            </TouchableOpacity>
          )}
        </View>
      </View>

      {/* Category Tabs */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        style={styles.categoryContainer}
        contentContainerStyle={styles.categoryContent}
      >
        {categories.map((category) => (
          <TouchableOpacity
            key={category.id}
            style={[
              styles.categoryTab,
              selectedCategory === category.id && styles.categoryTabActive,
            ]}
            onPress={() => setSelectedCategory(category.id)}
          >
            <Icon
              name={category.icon}
              size={20}
              color={
                selectedCategory === category.id
                  ? Colors.background
                  : Colors.textSecondary
              }
            />
            <Text
              style={[
                styles.categoryText,
                selectedCategory === category.id && styles.categoryTextActive,
              ]}
            >
              {category.name}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {loading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={Colors.primary} />
        </View>
      ) : (
        <>
          {/* Playlists Section */}
          {playlists.length > 0 && (
            <View style={styles.section}>
              <Text variant="h6" style={styles.sectionTitle}>
                Recommended Playlists
              </Text>
              <ScrollView
                horizontal
                showsHorizontalScrollIndicator={false}
                contentContainerStyle={styles.playlistScroll}
              >
                {playlists.map((playlist) => (
                  <TouchableOpacity
                    key={playlist.id}
                    style={styles.playlistCard}
                    onPress={() => handlePlaylistPress(playlist)}
                  >
                    <Image
                      source={{ uri: playlist.thumbnail }}
                      style={styles.playlistThumbnail}
                    />
                    <View style={styles.playlistOverlay}>
                      <Icon name="playlist-play" size={24} color="#fff" />
                      <Text style={styles.playlistCount}>
                        {playlist.itemCount} videos
                      </Text>
                    </View>
                    <Text style={styles.playlistTitle} numberOfLines={2}>
                      {playlist.title}
                    </Text>
                  </TouchableOpacity>
                ))}
              </ScrollView>
            </View>
          )}

          {/* Videos Section */}
          <View style={styles.section}>
            <Text variant="h6" style={styles.sectionTitle}>
              {selectedCategory === 'all' ? 'Popular Videos' : `${selectedCategory} Videos`}
            </Text>
            {videos.length > 0 ? (
              videos.map((video) => (
                <VideoCard
                  key={video.id}
                  video={video}
                  onPress={() => handleVideoPress(video)}
                />
              ))
            ) : (
              <Card style={styles.emptyCard}>
                <Icon name="video-off" size={48} color={Colors.textSecondary} />
                <Text style={styles.emptyText}>No videos found</Text>
              </Card>
            )}
          </View>
        </>
      )}
    </ScrollView>
  );
};

import { TextInput, TouchableOpacity, Image } from 'react-native';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  header: {
    padding: 20,
    paddingBottom: 10,
  },
  title: {
    color: Colors.text,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  subtitle: {
    color: Colors.textSecondary,
    fontSize: 16,
  },
  searchContainer: {
    paddingHorizontal: 20,
    marginBottom: 16,
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.card,
    borderRadius: 12,
    paddingHorizontal: 16,
    height: 48,
  },
  searchInput: {
    flex: 1,
    marginLeft: 8,
    fontSize: 16,
    color: Colors.text,
  },
  categoryContainer: {
    marginBottom: 20,
  },
  categoryContent: {
    paddingHorizontal: 20,
    gap: 8,
  },
  categoryTab: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: Colors.card,
    marginRight: 8,
  },
  categoryTabActive: {
    backgroundColor: Colors.primary,
  },
  categoryText: {
    marginLeft: 6,
    fontSize: 14,
    fontWeight: '600',
    color: Colors.textSecondary,
  },
  categoryTextActive: {
    color: Colors.background,
  },
  loadingContainer: {
    height: 300,
    justifyContent: 'center',
    alignItems: 'center',
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    marginHorizontal: 20,
    marginBottom: 12,
    color: Colors.text,
    fontWeight: '600',
  },
  playlistScroll: {
    paddingHorizontal: 20,
  },
  playlistCard: {
    width: 200,
    marginRight: 12,
  },
  playlistThumbnail: {
    width: 200,
    height: 112,
    borderRadius: 8,
    backgroundColor: Colors.cardBorder,
  },
  playlistOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 112,
    backgroundColor: 'rgba(0,0,0,0.4)',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  playlistCount: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
    marginTop: 4,
  },
  playlistTitle: {
    marginTop: 8,
    fontSize: 14,
    fontWeight: '600',
    color: Colors.text,
  },
  emptyCard: {
    marginHorizontal: 20,
    padding: 40,
    alignItems: 'center',
  },
  emptyText: {
    marginTop: 16,
    fontSize: 16,
    color: Colors.textSecondary,
  },
});
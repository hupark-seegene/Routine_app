import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Achievement } from '../database/ProfileQueries';

interface AchievementCardProps {
  achievement: Achievement;
  onPress?: () => void;
}

const AchievementCard: React.FC<AchievementCardProps> = ({ achievement, onPress }) => {
  const isUnlocked = achievement.unlockedAt !== null;
  const progressPercentage = Math.min((achievement.progress / achievement.requirement) * 100, 100);
  
  const animatedScale = new Animated.Value(1);
  
  const handlePressIn = () => {
    Animated.spring(animatedScale, {
      toValue: 0.95,
      useNativeDriver: true,
    }).start();
  };
  
  const handlePressOut = () => {
    Animated.spring(animatedScale, {
      toValue: 1,
      friction: 3,
      tension: 40,
      useNativeDriver: true,
    }).start();
  };
  
  return (
    <TouchableOpacity
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      activeOpacity={0.8}
    >
      <Animated.View 
        style={[
          styles.container,
          !isUnlocked && styles.lockedContainer,
          { transform: [{ scale: animatedScale }] }
        ]}
      >
        <View style={[styles.iconContainer, { backgroundColor: isUnlocked ? achievement.color : '#ddd' }]}>
          <Icon 
            name={isUnlocked ? achievement.icon : 'lock'} 
            size={30} 
            color="#fff" 
          />
        </View>
        
        <View style={styles.contentContainer}>
          <Text style={[styles.title, !isUnlocked && styles.lockedText]}>
            {achievement.name}
          </Text>
          <Text style={[styles.description, !isUnlocked && styles.lockedText]}>
            {achievement.description}
          </Text>
          
          {!isUnlocked && (
            <View style={styles.progressContainer}>
              <View style={styles.progressBar}>
                <View 
                  style={[
                    styles.progressFill,
                    { width: `${progressPercentage}%` }
                  ]} 
                />
              </View>
              <Text style={styles.progressText}>
                {achievement.progress}/{achievement.requirement}
              </Text>
            </View>
          )}
          
          {isUnlocked && achievement.unlockedAt && (
            <Text style={styles.unlockedDate}>
              달성일: {new Date(achievement.unlockedAt).toLocaleDateString()}
            </Text>
          )}
        </View>
        
        {isUnlocked && (
          <View style={styles.badgeContainer}>
            <Icon name="verified" size={24} color={achievement.color} />
          </View>
        )}
      </Animated.View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  lockedContainer: {
    opacity: 0.7,
  },
  iconContainer: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  contentContainer: {
    flex: 1,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },
  description: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },
  lockedText: {
    color: '#999',
  },
  progressContainer: {
    marginTop: 8,
  },
  progressBar: {
    height: 6,
    backgroundColor: '#e0e0e0',
    borderRadius: 3,
    overflow: 'hidden',
    marginBottom: 4,
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#4CAF50',
    borderRadius: 3,
  },
  progressText: {
    fontSize: 12,
    color: '#999',
  },
  unlockedDate: {
    fontSize: 12,
    color: '#4CAF50',
    fontStyle: 'italic',
  },
  badgeContainer: {
    position: 'absolute',
    top: 10,
    right: 10,
  },
});

export default AchievementCard;
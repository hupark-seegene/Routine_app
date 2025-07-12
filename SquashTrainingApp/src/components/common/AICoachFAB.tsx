import React, { useRef, useEffect } from 'react';
import {
  TouchableOpacity,
  StyleSheet,
  Animated,
  View,
} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {
  Colors,
  AnimationDuration,
  createScaleAnimation,
  pulseAnimation,
} from '../../styles';

interface AICoachFABProps {
  onPress: () => void;
  visible?: boolean;
}

const AICoachFAB: React.FC<AICoachFABProps> = ({ onPress, visible = true }) => {
  const scaleAnim = useRef(new Animated.Value(0)).current;
  const pulseAnim = useRef(new Animated.Value(1)).current;
  const rotateAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (visible) {
      // Entry animation
      createScaleAnimation(scaleAnim, 1, AnimationDuration.normal).start();
      // Continuous pulse
      pulseAnimation(pulseAnim).start();
    } else {
      Animated.timing(scaleAnim, {
        toValue: 0,
        duration: AnimationDuration.normal,
        useNativeDriver: true,
      }).start();
    }
  }, [visible]);

  const handlePress = () => {
    // Rotate animation on press
    Animated.sequence([
      Animated.timing(rotateAnim, {
        toValue: 1,
        duration: AnimationDuration.fast,
        useNativeDriver: true,
      }),
      Animated.timing(rotateAnim, {
        toValue: 0,
        duration: AnimationDuration.fast,
        useNativeDriver: true,
      }),
    ]).start();
    
    onPress();
  };

  const rotate = rotateAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  return (
    <Animated.View
      style={[
        styles.container,
        {
          transform: [
            { scale: scaleAnim },
            { rotate },
          ],
        },
      ]}
    >
      <TouchableOpacity
        onPress={handlePress}
        activeOpacity={0.8}
        style={styles.touchable}
      >
        <LinearGradient
          colors={Colors.gradients.voltToGreen}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.gradient}
        >
          <Animated.View
            style={[
              styles.iconContainer,
              { transform: [{ scale: pulseAnim }] },
            ]}
          >
            <Icon name="robot" size={28} color={Colors.primaryBlack} />
          </Animated.View>
        </LinearGradient>
        
        {/* Glow effect */}
        <Animated.View
          style={[
            styles.glow,
            {
              opacity: pulseAnim.interpolate({
                inputRange: [1, 1.1],
                outputRange: [0.6, 0.3],
              }),
              transform: [{ scale: pulseAnim }],
            },
          ]}
        />
      </TouchableOpacity>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 100,
    right: 20,
    zIndex: 999,
  },
  touchable: {
    width: 60,
    height: 60,
    borderRadius: 30,
    elevation: 10,
    shadowColor: Colors.accentVolt,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 20,
  },
  gradient: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
  },
  iconContainer: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  glow: {
    position: 'absolute',
    top: -10,
    left: -10,
    right: -10,
    bottom: -10,
    backgroundColor: Colors.accentVolt,
    borderRadius: 40,
    zIndex: -1,
  },
});

export default AICoachFAB;
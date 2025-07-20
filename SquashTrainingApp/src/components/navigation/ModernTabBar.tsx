import React, { useEffect, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Dimensions,
  Platform,
} from 'react-native';
import { BottomTabBarProps } from '@react-navigation/bottom-tabs';
import LinearGradient from 'react-native-linear-gradient';
import MaterialCommunityIcons from 'react-native-vector-icons/MaterialCommunityIcons';
import {
  Colors,
  ModernTypography,
  ModernSpacing,
  BorderRadius,
  Shadows,
  Glass,
  Animations,
} from '../../styles';

const { width: SCREEN_WIDTH } = Dimensions.get('window');
const TAB_WIDTH = SCREEN_WIDTH / 5;

const ModernTabBar: React.FC<BottomTabBarProps> = ({
  state,
  descriptors,
  navigation,
}) => {
  const animatedValues = useRef(
    state.routes.map(() => new Animated.Value(0))
  ).current;
  const indicatorPosition = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const toValue = state.index * TAB_WIDTH;
    Animated.spring(indicatorPosition, {
      toValue,
      ...Animations.spring,
    }).start();

    animatedValues.forEach((anim, index) => {
      Animated.timing(anim, {
        toValue: state.index === index ? 1 : 0,
        duration: 200,
        useNativeDriver: true,
      }).start();
    });
  }, [state.index]);

  const getIconName = (routeName: string): string => {
    const icons: { [key: string]: string } = {
      Home: 'home-variant',
      Checklist: 'clipboard-check',
      Record: 'record-circle',
      Coach: 'robot',
      Profile: 'account-circle',
    };
    return icons[routeName] || 'help-circle';
  };

  return (
    <View style={styles.container}>
      {/* Glass background */}
      <View style={styles.glassBackground}>
        <LinearGradient
          colors={['rgba(26, 26, 37, 0.9)', 'rgba(10, 10, 15, 0.95)']}
          start={{ x: 0, y: 0 }}
          end={{ x: 0, y: 1 }}
          style={styles.gradientBackground}
        />
      </View>

      {/* Active indicator */}
      <Animated.View
        style={[
          styles.activeIndicator,
          {
            transform: [{ translateX: indicatorPosition }],
          },
        ]}
      >
        <LinearGradient
          colors={[Colors.primary, Colors.primaryDark]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
          style={styles.indicatorGradient}
        />
      </Animated.View>

      {/* Tabs */}
      {state.routes.map((route, index) => {
        const { options } = descriptors[route.key];
        const label =
          options.tabBarLabel !== undefined
            ? options.tabBarLabel
            : options.title !== undefined
            ? options.title
            : route.name;

        const isFocused = state.index === index;

        const onPress = () => {
          const event = navigation.emit({
            type: 'tabPress',
            target: route.key,
            canPreventDefault: true,
          });

          if (!isFocused && !event.defaultPrevented) {
            navigation.navigate(route.name);
          }
        };

        const animatedScale = animatedValues[index].interpolate({
          inputRange: [0, 1],
          outputRange: [1, 1.2],
        });

        const animatedTranslateY = animatedValues[index].interpolate({
          inputRange: [0, 1],
          outputRange: [0, -5],
        });

        return (
          <TouchableOpacity
            key={index}
            accessibilityRole="button"
            accessibilityState={isFocused ? { selected: true } : {}}
            accessibilityLabel={options.tabBarAccessibilityLabel}
            testID={options.tabBarTestID}
            onPress={onPress}
            style={styles.tab}
            activeOpacity={0.7}
          >
            <Animated.View
              style={[
                styles.tabContent,
                {
                  transform: [
                    { scale: animatedScale },
                    { translateY: animatedTranslateY },
                  ],
                },
              ]}
            >
              <MaterialCommunityIcons
                name={getIconName(route.name)}
                size={24}
                color={isFocused ? Colors.primary : Colors.textMuted}
                style={[
                  styles.icon,
                  isFocused && styles.iconActive,
                ]}
              />
              {isFocused && (
                <Animated.Text
                  style={[
                    styles.label,
                    {
                      opacity: animatedValues[index],
                    },
                  ]}
                >
                  {label as string}
                </Animated.Text>
              )}
            </Animated.View>

            {/* Dot indicator for inactive tabs */}
            {!isFocused && (
              <View style={styles.inactiveDot} />
            )}
          </TouchableOpacity>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: Platform.OS === 'ios' ? 85 : 65,
    backgroundColor: 'transparent',
  },
  glassBackground: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderTopLeftRadius: BorderRadius.xl,
    borderTopRightRadius: BorderRadius.xl,
    overflow: 'hidden',
    ...Shadows.large,
  },
  gradientBackground: {
    flex: 1,
    borderTopLeftRadius: BorderRadius.xl,
    borderTopRightRadius: BorderRadius.xl,
    borderTopWidth: 1,
    borderLeftWidth: 0.5,
    borderRightWidth: 0.5,
    borderColor: 'rgba(255, 255, 255, 0.1)',
  },
  activeIndicator: {
    position: 'absolute',
    top: 0,
    width: TAB_WIDTH,
    height: 3,
    zIndex: 1,
  },
  indicatorGradient: {
    flex: 1,
    shadowColor: Colors.primary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.8,
    shadowRadius: 8,
  },
  tab: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: Platform.OS === 'ios' ? 15 : 10,
    paddingBottom: Platform.OS === 'ios' ? 25 : 15,
  },
  tabContent: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  icon: {
    marginBottom: 4,
  },
  iconActive: {
    shadowColor: Colors.primary,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.5,
    shadowRadius: 10,
    elevation: 5,
  },
  label: {
    ...ModernTypography.caption,
    color: Colors.primary,
    fontWeight: '600',
    marginTop: 2,
  },
  inactiveDot: {
    position: 'absolute',
    bottom: Platform.OS === 'ios' ? 20 : 10,
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: Colors.textMuted,
    opacity: 0.3,
  },
});

export default ModernTabBar;
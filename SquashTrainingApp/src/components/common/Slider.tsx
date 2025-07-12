import React, { useRef, useState } from 'react';
import {
  View,
  PanResponder,
  StyleSheet,
  Animated,
  LayoutChangeEvent,
  ViewStyle,
} from 'react-native';

interface SliderProps {
  style?: ViewStyle;
  minimumValue?: number;
  maximumValue?: number;
  value?: number;
  onValueChange?: (value: number) => void;
  minimumTrackTintColor?: string;
  maximumTrackTintColor?: string;
  thumbTintColor?: string;
  step?: number;
}

const Slider: React.FC<SliderProps> = ({
  style,
  minimumValue = 0,
  maximumValue = 1,
  value = 0,
  onValueChange,
  minimumTrackTintColor = '#C9FF00',
  maximumTrackTintColor = '#333',
  thumbTintColor = '#FFF',
  step = 0,
}) => {
  const [sliderWidth, setSliderWidth] = useState(0);
  const animatedValue = useRef(new Animated.Value(value)).current;

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: () => {},
      onPanResponderMove: (_, gestureState) => {
        const percentage = Math.max(0, Math.min(1, gestureState.moveX / sliderWidth));
        let newValue = minimumValue + percentage * (maximumValue - minimumValue);
        
        if (step > 0) {
          newValue = Math.round(newValue / step) * step;
        }
        
        animatedValue.setValue(newValue);
        onValueChange?.(newValue);
      },
      onPanResponderRelease: () => {},
    })
  ).current;

  const handleLayout = (event: LayoutChangeEvent) => {
    setSliderWidth(event.nativeEvent.layout.width);
  };

  const percentage = sliderWidth > 0 
    ? ((value - minimumValue) / (maximumValue - minimumValue)) * sliderWidth
    : 0;

  return (
    <View
      style={[styles.container, style]}
      onLayout={handleLayout}
      {...panResponder.panHandlers}
    >
      <View style={[styles.track, { backgroundColor: maximumTrackTintColor }]} />
      <View
        style={[
          styles.minimumTrack,
          {
            backgroundColor: minimumTrackTintColor,
            width: percentage,
          },
        ]}
      />
      <View
        style={[
          styles.thumb,
          {
            backgroundColor: thumbTintColor,
            left: percentage - 10,
          },
        ]}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    height: 40,
    justifyContent: 'center',
  },
  track: {
    height: 4,
    borderRadius: 2,
    position: 'absolute',
    left: 0,
    right: 0,
  },
  minimumTrack: {
    height: 4,
    borderRadius: 2,
    position: 'absolute',
    left: 0,
  },
  thumb: {
    width: 20,
    height: 20,
    borderRadius: 10,
    position: 'absolute',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
});

export default Slider;
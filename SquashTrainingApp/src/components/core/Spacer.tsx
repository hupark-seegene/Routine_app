import React from 'react';
import { View } from 'react-native';
import { Spacing } from '../../styles/designSystem';

interface SpacerProps {
  size?: keyof typeof Spacing;
  horizontal?: boolean;
}

const Spacer: React.FC<SpacerProps> = ({ size = 4, horizontal = false }) => {
  const dimension = Spacing[size];
  
  return (
    <View
      style={
        horizontal
          ? { width: dimension, height: 1 }
          : { height: dimension, width: 1 }
      }
    />
  );
};

export default Spacer;
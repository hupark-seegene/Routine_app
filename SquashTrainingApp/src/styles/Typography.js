/**
 * Typography styles
 */

import { StyleSheet } from 'react-native';
import Colors from './Colors';

export const Typography = StyleSheet.create({
  h1: {
    fontSize: 32,
    fontWeight: 'bold',
    color: Colors.text,
    marginBottom: 16,
  },
  h2: {
    fontSize: 24,
    fontWeight: 'bold',
    color: Colors.text,
    marginBottom: 12,
  },
  h3: {
    fontSize: 20,
    fontWeight: '600',
    color: Colors.text,
    marginBottom: 8,
  },
  body: {
    fontSize: 16,
    color: Colors.text,
    lineHeight: 24,
  },
  caption: {
    fontSize: 14,
    color: Colors.textSecondary,
  },
  button: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.primary,
    textTransform: 'uppercase',
  },
});

export default Typography;

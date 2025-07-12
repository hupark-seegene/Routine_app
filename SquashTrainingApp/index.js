/**
 * Squash Training App Entry Point
 * Cycle 10 - Bridge Fix
 * @format
 */

import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';

console.log('Index.js loaded - Squash Training App v1.0.10');
AppRegistry.registerComponent(appName, () => App);

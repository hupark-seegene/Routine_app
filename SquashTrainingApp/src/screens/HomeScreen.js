/**
 * HomeScreen - Main dashboard for Squash Training App
 * Created in Cycle 8
 */

import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  StatusBar,
} from 'react-native';
import Colors from '../styles/Colors';
import Typography from '../styles/Typography';

const HomeScreen = () => {
  const trainingOptions = [
    { id: 1, title: 'Daily Workout', subtitle: 'Complete today\'s training' },
    { id: 2, title: 'Practice Drills', subtitle: 'Improve your technique' },
    { id: 3, title: 'Training History', subtitle: 'View your progress' },
    { id: 4, title: 'AI Coach', subtitle: 'Get personalized advice' },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor={Colors.background} />
      
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <Text style={Typography.h1}>Squash Training</Text>
          <Text style={styles.version}>v1.0.8 - Cycle 8</Text>
        </View>
        
        <View style={styles.welcomeCard}>
          <Text style={Typography.h3}>Welcome Back!</Text>
          <Text style={Typography.caption}>Ready to improve your game?</Text>
        </View>
        
        <View style={styles.menuContainer}>
          {trainingOptions.map((option) => (
            <TouchableOpacity
              key={option.id}
              style={styles.menuItem}
              activeOpacity={0.8}
            >
              <Text style={styles.menuTitle}>{option.title}</Text>
              <Text style={styles.menuSubtitle}>{option.subtitle}</Text>
            </TouchableOpacity>
          ))}
        </View>
        
        <View style={styles.footer}>
          <Text style={Typography.caption}>Powered by React Native</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  scrollContent: {
    flexGrow: 1,
    padding: 20,
  },
  header: {
    alignItems: 'center',
    marginBottom: 30,
  },
  version: {
    color: Colors.primary,
    fontSize: 12,
    marginTop: 5,
  },
  welcomeCard: {
    backgroundColor: Colors.surface,
    padding: 20,
    borderRadius: 12,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: Colors.primary,
  },
  menuContainer: {
    flex: 1,
  },
  menuItem: {
    backgroundColor: Colors.card,
    padding: 20,
    borderRadius: 8,
    marginBottom: 12,
    borderLeftWidth: 3,
    borderLeftColor: Colors.primary,
  },
  menuTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.text,
    marginBottom: 4,
  },
  menuSubtitle: {
    fontSize: 14,
    color: Colors.textSecondary,
  },
  footer: {
    alignItems: 'center',
    marginTop: 30,
    paddingTop: 20,
    borderTopWidth: 1,
    borderTopColor: Colors.divider,
  },
});

export default HomeScreen;

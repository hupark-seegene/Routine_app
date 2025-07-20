import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import { View, StyleSheet } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors, DarkTheme } from '../styles';
import ModernTabBar from '../components/navigation/ModernTabBar';

// Screen imports (to be created)
import ModernHomeScreen from '../screens/ModernHomeScreen';
import ChecklistScreen from '../screens/ChecklistScreen';
import RecordScreen from '../screens/RecordScreen';
import ProfileScreen from '../screens/ProfileScreen';
import CoachScreen from '../screens/CoachScreen';
import ProgramDetailScreen from '../screens/ProgramDetailScreen';
import ExerciseDetailScreen from '../screens/ExerciseDetailScreen';
import DevLoginScreen from '../screens/auth/DevLoginScreen';

export type RootStackParamList = {
  MainTabs: undefined;
  ProgramDetail: { programId: number; programName: string };
  ExerciseDetail: { exerciseId: number; exerciseName: string };
  DevLogin: undefined;
};

export type MainTabParamList = {
  Home: undefined;
  Checklist: undefined;
  Record: undefined;
  Coach: undefined;
  Profile: undefined;
};

const Stack = createStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<MainTabParamList>();

function MainTabs() {
  return (
    <Tab.Navigator
      tabBar={(props) => <ModernTabBar {...props} />}
      screenOptions={{
        headerShown: false,
      }}
    >
      <Tab.Screen 
        name="Home" 
        component={ModernHomeScreen} 
        options={{ title: '홈' }}
      />
      <Tab.Screen 
        name="Checklist" 
        component={ChecklistScreen} 
        options={{ title: '체크리스트' }}
      />
      <Tab.Screen 
        name="Record" 
        component={RecordScreen} 
        options={{ title: '기록' }}
      />
      <Tab.Screen 
        name="Coach" 
        component={CoachScreen} 
        options={{ title: 'AI 코치' }}
      />
      <Tab.Screen 
        name="Profile" 
        component={ProfileScreen} 
        options={{ title: '프로필' }}
      />
    </Tab.Navigator>
  );
}

export default function AppNavigator() {
  return (
    <NavigationContainer
      theme={{
        dark: true,
        colors: {
          primary: Colors.accentVolt,
          background: DarkTheme.background,
          card: DarkTheme.surface,
          text: DarkTheme.text,
          border: DarkTheme.border,
          notification: Colors.accentVolt,
        },
      }}
    >
      <Stack.Navigator
        screenOptions={{
          headerStyle: {
            backgroundColor: DarkTheme.background,
            elevation: 0,
            shadowOpacity: 0,
            borderBottomWidth: 1,
            borderBottomColor: DarkTheme.border,
          },
          headerTintColor: Colors.accentVolt,
          headerTitleStyle: {
            fontWeight: 'bold',
            color: DarkTheme.text,
          },
        }}
      >
        <Stack.Screen 
          name="MainTabs" 
          component={MainTabs} 
          options={{ headerShown: false }}
        />
        <Stack.Screen 
          name="ProgramDetail" 
          component={ProgramDetailScreen}
          options={({ route }) => ({ title: route.params.programName })}
        />
        <Stack.Screen 
          name="ExerciseDetail" 
          component={ExerciseDetailScreen}
          options={({ route }) => ({ title: route.params.exerciseName })}
        />
        <Stack.Screen 
          name="DevLogin" 
          component={DevLoginScreen}
          options={{ 
            title: 'Developer Login',
            headerStyle: {
              backgroundColor: DarkTheme.background,
            },
            headerTintColor: Colors.accentVolt,
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: Colors.blackAlpha(0.95),
    borderTopWidth: 1,
    borderTopColor: DarkTheme.border,
    height: 70,
    paddingBottom: 10,
    paddingTop: 10,
  },
  tabBarLabel: {
    fontSize: 11,
    fontWeight: '600',
    marginTop: 4,
  },
  iconContainer: {
    position: 'relative',
    paddingTop: 8,
  },
  iconContainerActive: {
    borderTopWidth: 3,
    borderTopColor: Colors.accentVolt,
    marginTop: -8,
    paddingTop: 5,
  },
});
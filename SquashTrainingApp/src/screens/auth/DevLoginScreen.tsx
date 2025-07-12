import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  Animated,
  Alert,
  ActivityIndicator,
  ScrollView,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useAuth } from './AuthContext';
import { useNavigation } from '@react-navigation/native';
import {
  Colors,
  DarkTheme,
  Typography,
  GlobalStyles,
  Spacing,
  BorderRadius,
  AnimationDuration,
  createFadeInAnimation,
  createScaleAnimation,
  pulseAnimation,
} from '../../styles';

const DevLoginScreen: React.FC = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [apiKey, setApiKey] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showApiKey, setShowApiKey] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const { login } = useAuth();
  const navigation = useNavigation();

  // Animations
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.8)).current;
  const pulseAnim = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    // Start animations
    Animated.parallel([
      createFadeInAnimation(fadeAnim, AnimationDuration.slow),
      createScaleAnimation(scaleAnim, 1, AnimationDuration.slow),
    ]).start();

    // Start pulse animation for the dev badge
    pulseAnimation(pulseAnim).start();
  }, []);

  const handleLogin = async () => {
    if (!username || !password || !apiKey) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setIsLoading(true);
    
    try {
      const success = await login(username, password, apiKey);
      
      if (success) {
        Alert.alert('Success', 'Developer mode activated!', [
          { text: 'OK', onPress: () => navigation.goBack() },
        ]);
      } else {
        Alert.alert('Error', 'Invalid credentials');
      }
    } catch (error) {
      Alert.alert('Error', 'Login failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
      >
        <Animated.View
          style={[
            styles.content,
            {
              opacity: fadeAnim,
              transform: [{ scale: scaleAnim }],
            },
          ]}
        >
          {/* Header */}
          <View style={styles.header}>
            <Animated.View
              style={[
                styles.devBadge,
                {
                  transform: [{ scale: pulseAnim }],
                },
              ]}
            >
              <Icon name="code" size={32} color={Colors.primaryBlack} />
            </Animated.View>
            <Text style={styles.title}>Developer Mode</Text>
            <Text style={styles.subtitle}>
              Access advanced features and API controls
            </Text>
          </View>

          {/* Login Form */}
          <View style={styles.form}>
            {/* Username Input */}
            <View style={styles.inputContainer}>
              <Icon
                name="person"
                size={20}
                color={DarkTheme.textSecondary}
                style={styles.inputIcon}
              />
              <TextInput
                style={styles.input}
                placeholder="Username"
                placeholderTextColor={DarkTheme.textTertiary}
                value={username}
                onChangeText={setUsername}
                autoCapitalize="none"
                autoCorrect={false}
              />
            </View>

            {/* Password Input */}
            <View style={styles.inputContainer}>
              <Icon
                name="lock"
                size={20}
                color={DarkTheme.textSecondary}
                style={styles.inputIcon}
              />
              <TextInput
                style={styles.input}
                placeholder="Password"
                placeholderTextColor={DarkTheme.textTertiary}
                value={password}
                onChangeText={setPassword}
                secureTextEntry={!showPassword}
                autoCapitalize="none"
              />
              <TouchableOpacity
                onPress={() => setShowPassword(!showPassword)}
                style={styles.inputAction}
              >
                <Icon
                  name={showPassword ? 'visibility-off' : 'visibility'}
                  size={20}
                  color={DarkTheme.textSecondary}
                />
              </TouchableOpacity>
            </View>

            {/* API Key Input */}
            <View style={styles.inputContainer}>
              <Icon
                name="vpn-key"
                size={20}
                color={DarkTheme.textSecondary}
                style={styles.inputIcon}
              />
              <TextInput
                style={[styles.input, styles.apiKeyInput]}
                placeholder="OpenAI API Key"
                placeholderTextColor={DarkTheme.textTertiary}
                value={apiKey}
                onChangeText={setApiKey}
                secureTextEntry={!showApiKey}
                autoCapitalize="none"
                autoCorrect={false}
                multiline
              />
              <TouchableOpacity
                onPress={() => setShowApiKey(!showApiKey)}
                style={styles.inputAction}
              >
                <Icon
                  name={showApiKey ? 'visibility-off' : 'visibility'}
                  size={20}
                  color={DarkTheme.textSecondary}
                />
              </TouchableOpacity>
            </View>

            {/* Info Box */}
            <View style={styles.infoBox}>
              <Icon name="info" size={16} color={Colors.accentVolt} />
              <Text style={styles.infoText}>
                Your API key will be encrypted and stored locally. It will only
                be used for AI coaching features in developer mode.
              </Text>
            </View>

            {/* Login Button */}
            <TouchableOpacity
              style={[
                styles.loginButton,
                isLoading && styles.loginButtonDisabled,
              ]}
              onPress={handleLogin}
              disabled={isLoading}
              activeOpacity={0.8}
            >
              {isLoading ? (
                <ActivityIndicator color={Colors.primaryBlack} />
              ) : (
                <>
                  <Text style={styles.loginButtonText}>ACTIVATE</Text>
                  <Icon name="arrow-forward" size={20} color={Colors.primaryBlack} />
                </>
              )}
            </TouchableOpacity>

            {/* Cancel Button */}
            <TouchableOpacity
              style={styles.cancelButton}
              onPress={() => navigation.goBack()}
            >
              <Text style={styles.cancelButtonText}>Cancel</Text>
            </TouchableOpacity>
          </View>

          {/* Footer */}
          <View style={styles.footer}>
            <Icon name="security" size={16} color={DarkTheme.textTertiary} />
            <Text style={styles.footerText}>
              Secure developer access only
            </Text>
          </View>
        </Animated.View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: DarkTheme.background,
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
  },
  content: {
    flex: 1,
    padding: Spacing.lg,
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
    marginBottom: Spacing.xxl,
  },
  devBadge: {
    width: 80,
    height: 80,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.accentVolt,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: Spacing.lg,
    ...GlobalStyles.voltGlow,
  },
  title: {
    ...Typography.h2,
    color: DarkTheme.text,
    marginBottom: Spacing.sm,
  },
  subtitle: {
    ...Typography.body,
    color: DarkTheme.textSecondary,
    textAlign: 'center',
  },
  form: {
    marginBottom: Spacing.xl,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: DarkTheme.surface,
    borderRadius: BorderRadius.md,
    borderWidth: 1,
    borderColor: DarkTheme.border,
    marginBottom: Spacing.md,
    paddingHorizontal: Spacing.md,
  },
  inputIcon: {
    marginRight: Spacing.sm,
  },
  input: {
    flex: 1,
    paddingVertical: Spacing.md,
    ...Typography.body,
    color: DarkTheme.text,
  },
  apiKeyInput: {
    minHeight: 60,
    paddingTop: Spacing.md,
  },
  inputAction: {
    padding: Spacing.sm,
  },
  infoBox: {
    flexDirection: 'row',
    backgroundColor: Colors.voltAlpha(0.1),
    borderRadius: BorderRadius.md,
    padding: Spacing.md,
    marginBottom: Spacing.lg,
  },
  infoText: {
    flex: 1,
    marginLeft: Spacing.sm,
    ...Typography.bodySmall,
    color: DarkTheme.text,
    lineHeight: 18,
  },
  loginButton: {
    backgroundColor: Colors.accentVolt,
    borderRadius: BorderRadius.full,
    paddingVertical: Spacing.md,
    paddingHorizontal: Spacing.xl,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: Spacing.md,
    ...GlobalStyles.voltGlow,
  },
  loginButtonDisabled: {
    opacity: 0.6,
  },
  loginButtonText: {
    ...Typography.button,
    color: Colors.primaryBlack,
    marginRight: Spacing.sm,
  },
  cancelButton: {
    paddingVertical: Spacing.md,
    alignItems: 'center',
  },
  cancelButtonText: {
    ...Typography.body,
    color: DarkTheme.textSecondary,
  },
  footer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  footerText: {
    ...Typography.bodySmall,
    color: DarkTheme.textTertiary,
    marginLeft: Spacing.xs,
  },
});

export default DevLoginScreen;
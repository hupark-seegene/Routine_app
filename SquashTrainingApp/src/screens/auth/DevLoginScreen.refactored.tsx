import React, { useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  Animated,
  Alert,
  ScrollView,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useAuth } from './AuthContext';
import { useNavigation } from '@react-navigation/native';
import {
  Button,
  Input,
  Card,
  LoadingState,
} from '../../components/common';
import {
  useForm,
  validators,
  useLoading,
} from '../../hooks';
import {
  Colors,
  DarkTheme,
  Typography,
  GlobalStyles,
  AnimationDuration,
  createFadeInAnimation,
  createScaleAnimation,
  pulseAnimation,
} from '../../styles';
import { Spacing } from '../../constants/spacing';

interface LoginFormValues {
  username: string;
  password: string;
  apiKey: string;
}

const DevLoginScreen: React.FC = () => {
  const { login } = useAuth();
  const navigation = useNavigation();
  const { isLoading, withLoading } = useLoading();

  // Form management with validation
  const form = useForm<LoginFormValues>({
    initialValues: {
      username: '',
      password: '',
      apiKey: '',
    },
    validationRules: {
      username: validators.required('Username is required'),
      password: validators.required('Password is required'),
      apiKey: validators.required('API Key is required'),
    },
    onSubmit: async (values) => {
      await withLoading(handleLogin(values));
    },
  });

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

  const handleLogin = async (values: LoginFormValues) => {
    try {
      const success = await login(values.username, values.password, values.apiKey);
      
      if (success) {
        Alert.alert('Success', 'Developer mode activated!', [
          { text: 'OK', onPress: () => navigation.goBack() },
        ]);
      } else {
        form.setFieldError('password', 'Invalid credentials');
      }
    } catch (error) {
      Alert.alert('Error', 'Login failed. Please try again.');
    }
  };

  if (isLoading) {
    return <LoadingState message="Activating developer mode..." fullScreen />;
  }

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
            <Input
              label="Username"
              placeholder="Enter your username"
              value={form.values.username}
              onChangeText={form.handleChange('username')}
              onBlur={form.handleBlur('username')}
              error={form.touched.username ? form.errors.username : undefined}
              leftIcon="person"
              autoCapitalize="none"
              autoCorrect={false}
            />

            <Input
              label="Password"
              placeholder="Enter your password"
              value={form.values.password}
              onChangeText={form.handleChange('password')}
              onBlur={form.handleBlur('password')}
              error={form.touched.password ? form.errors.password : undefined}
              leftIcon="lock"
              secureTextEntry
              autoCapitalize="none"
            />

            <Input
              label="OpenAI API Key"
              placeholder="Enter your API key"
              value={form.values.apiKey}
              onChangeText={form.handleChange('apiKey')}
              onBlur={form.handleBlur('apiKey')}
              error={form.touched.apiKey ? form.errors.apiKey : undefined}
              leftIcon="vpn-key"
              secureTextEntry
              autoCapitalize="none"
              autoCorrect={false}
              multiline
              numberOfLines={2}
              helperText="Your API key will be encrypted and stored locally"
            />

            {/* Info Box */}
            <Card variant="filled" style={styles.infoCard}>
              <View style={styles.infoContent}>
                <Icon name="info" size={16} color={Colors.accentVolt} />
                <Text style={styles.infoText}>
                  Your API key will only be used for AI coaching features in developer mode.
                </Text>
              </View>
            </Card>

            {/* Action Buttons */}
            <Button
              title="ACTIVATE"
              onPress={form.handleSubmit}
              loading={form.isSubmitting}
              disabled={!form.isValid}
              fullWidth
              style={styles.loginButton}
            />

            <Button
              title="Cancel"
              onPress={() => navigation.goBack()}
              variant="ghost"
              fullWidth
            />
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
    padding: Spacing.screenPadding,
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
    marginBottom: Spacing.sectionGap,
  },
  devBadge: {
    width: 80,
    height: 80,
    borderRadius: Spacing.radius.round,
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
  infoCard: {
    backgroundColor: Colors.voltAlpha(0.1),
    marginBottom: Spacing.lg,
  },
  infoContent: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  infoText: {
    flex: 1,
    marginLeft: Spacing.sm,
    ...Typography.bodySmall,
    color: DarkTheme.text,
    lineHeight: 18,
  },
  loginButton: {
    marginBottom: Spacing.md,
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
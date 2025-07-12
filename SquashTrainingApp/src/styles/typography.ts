import { Platform } from 'react-native';

export const FontFamily = {
  regular: Platform.select({
    ios: 'System',
    android: 'Roboto',
    default: 'System',
  }),
  medium: Platform.select({
    ios: 'System',
    android: 'Roboto-Medium',
    default: 'System',
  }),
  bold: Platform.select({
    ios: 'System',
    android: 'Roboto-Bold',
    default: 'System',
  }),
  black: Platform.select({
    ios: 'System',
    android: 'Roboto-Black',
    default: 'System',
  }),
};

export const FontSize = {
  // Headings
  h1: 32,
  h2: 28,
  h3: 24,
  h4: 20,
  h5: 18,
  h6: 16,
  
  // Body
  large: 18,
  medium: 16,
  regular: 14,
  small: 12,
  tiny: 11,
  
  // Special
  hero: 36,
  display: 48,
};

export const FontWeight = {
  regular: '400' as const,
  medium: '500' as const,
  semiBold: '600' as const,
  bold: '700' as const,
  extraBold: '800' as const,
  black: '900' as const,
};

export const LineHeight = {
  tight: 1.1,
  normal: 1.5,
  relaxed: 1.75,
};

export const LetterSpacing = {
  tighter: -1,
  tight: -0.5,
  normal: 0,
  wide: 0.5,
  wider: 1,
  widest: 2,
};

export const Typography = {
  // Display
  display: {
    fontSize: FontSize.display,
    fontWeight: FontWeight.black,
    lineHeight: FontSize.display * LineHeight.tight,
    letterSpacing: LetterSpacing.tighter,
  },
  
  // Hero
  hero: {
    fontSize: FontSize.hero,
    fontWeight: FontWeight.extraBold,
    lineHeight: FontSize.hero * LineHeight.tight,
    letterSpacing: LetterSpacing.tight,
  },
  
  // Headings
  h1: {
    fontSize: FontSize.h1,
    fontWeight: FontWeight.extraBold,
    lineHeight: FontSize.h1 * LineHeight.tight,
    letterSpacing: LetterSpacing.tight,
  },
  h2: {
    fontSize: FontSize.h2,
    fontWeight: FontWeight.bold,
    lineHeight: FontSize.h2 * LineHeight.tight,
    letterSpacing: LetterSpacing.tight,
  },
  h3: {
    fontSize: FontSize.h3,
    fontWeight: FontWeight.bold,
    lineHeight: FontSize.h3 * LineHeight.normal,
    letterSpacing: LetterSpacing.tight,
  },
  h4: {
    fontSize: FontSize.h4,
    fontWeight: FontWeight.semiBold,
    lineHeight: FontSize.h4 * LineHeight.normal,
    letterSpacing: LetterSpacing.normal,
  },
  h5: {
    fontSize: FontSize.h5,
    fontWeight: FontWeight.semiBold,
    lineHeight: FontSize.h5 * LineHeight.normal,
    letterSpacing: LetterSpacing.normal,
  },
  h6: {
    fontSize: FontSize.h6,
    fontWeight: FontWeight.semiBold,
    lineHeight: FontSize.h6 * LineHeight.normal,
    letterSpacing: LetterSpacing.normal,
  },
  
  // Body
  bodyLarge: {
    fontSize: FontSize.large,
    fontWeight: FontWeight.regular,
    lineHeight: FontSize.large * LineHeight.normal,
  },
  body: {
    fontSize: FontSize.regular,
    fontWeight: FontWeight.regular,
    lineHeight: FontSize.regular * LineHeight.normal,
  },
  bodySmall: {
    fontSize: FontSize.small,
    fontWeight: FontWeight.regular,
    lineHeight: FontSize.small * LineHeight.normal,
  },
  
  // Labels
  label: {
    fontSize: FontSize.small,
    fontWeight: FontWeight.semiBold,
    lineHeight: FontSize.small * LineHeight.normal,
    letterSpacing: LetterSpacing.wide,
    textTransform: 'uppercase' as const,
  },
  labelTiny: {
    fontSize: FontSize.tiny,
    fontWeight: FontWeight.semiBold,
    lineHeight: FontSize.tiny * LineHeight.normal,
    letterSpacing: LetterSpacing.wide,
    textTransform: 'uppercase' as const,
  },
  
  // Buttons
  button: {
    fontSize: FontSize.medium,
    fontWeight: FontWeight.bold,
    lineHeight: FontSize.medium * LineHeight.normal,
    letterSpacing: LetterSpacing.wider,
    textTransform: 'uppercase' as const,
  },
  buttonSmall: {
    fontSize: FontSize.regular,
    fontWeight: FontWeight.semiBold,
    lineHeight: FontSize.regular * LineHeight.normal,
    letterSpacing: LetterSpacing.wide,
  },
};
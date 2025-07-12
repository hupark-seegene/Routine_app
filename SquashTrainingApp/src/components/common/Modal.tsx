import React from 'react';
import {
  Modal as RNModal,
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  TouchableWithoutFeedback,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../styles/Colors';
import { Typography } from '../../styles/Typography';
import { Button } from './Button';

interface ModalProps {
  visible: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
  footer?: React.ReactNode;
  closeOnBackdrop?: boolean;
  showCloseButton?: boolean;
  fullScreen?: boolean;
  scrollable?: boolean;
  actions?: Array<{
    title: string;
    onPress: () => void;
    variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  }>;
}

export const Modal: React.FC<ModalProps> = ({
  visible,
  onClose,
  title,
  children,
  footer,
  closeOnBackdrop = true,
  showCloseButton = true,
  fullScreen = false,
  scrollable = false,
  actions,
}) => {
  const handleBackdropPress = () => {
    if (closeOnBackdrop) {
      onClose();
    }
  };

  const content = (
    <View style={styles.content}>
      {title && (
        <View style={styles.header}>
          <Text style={styles.title}>{title}</Text>
          {showCloseButton && (
            <TouchableOpacity
              style={styles.closeButton}
              onPress={onClose}
              hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
            >
              <Icon name="close" size={24} color={Colors.textSecondary} />
            </TouchableOpacity>
          )}
        </View>
      )}
      
      {scrollable ? (
        <ScrollView
          style={styles.body}
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          {children}
        </ScrollView>
      ) : (
        <View style={styles.body}>{children}</View>
      )}
      
      {(footer || actions) && (
        <View style={styles.footer}>
          {footer || (
            <View style={styles.actions}>
              {actions?.map((action, index) => (
                <Button
                  key={index}
                  title={action.title}
                  onPress={action.onPress}
                  variant={action.variant || (index === 0 ? 'secondary' : 'primary')}
                  style={[
                    styles.actionButton,
                    index > 0 && styles.actionButtonSpacing,
                  ]}
                />
              ))}
            </View>
          )}
        </View>
      )}
    </View>
  );

  return (
    <RNModal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={onClose}
      statusBarTranslucent
    >
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.container}
      >
        <TouchableWithoutFeedback onPress={handleBackdropPress}>
          <View style={styles.backdrop} />
        </TouchableWithoutFeedback>
        
        <View
          style={[
            styles.modalContainer,
            fullScreen && styles.fullScreenModal,
          ]}
        >
          {content}
        </View>
      </KeyboardAvoidingView>
    </RNModal>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  modalContainer: {
    backgroundColor: Colors.card,
    borderRadius: 16,
    maxWidth: '90%',
    maxHeight: '80%',
    width: 400,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 8,
    elevation: 5,
  },
  fullScreenModal: {
    maxWidth: '100%',
    maxHeight: '100%',
    width: '100%',
    height: '100%',
    borderRadius: 0,
  },
  content: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingTop: 20,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  title: {
    ...Typography.h3,
    color: Colors.text,
    flex: 1,
  },
  closeButton: {
    marginLeft: 16,
  },
  body: {
    flex: 1,
    paddingHorizontal: 20,
    paddingVertical: 16,
  },
  scrollContent: {
    flexGrow: 1,
  },
  footer: {
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 20,
    borderTopWidth: 1,
    borderTopColor: Colors.border,
  },
  actions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  actionButton: {
    minWidth: 80,
  },
  actionButtonSpacing: {
    marginLeft: 12,
  },
});
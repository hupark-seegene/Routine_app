import { useState, useCallback, ChangeEvent } from 'react';

type FormErrors<T> = Partial<Record<keyof T, string>>;
type FormTouched<T> = Partial<Record<keyof T, boolean>>;
type ValidationRules<T> = Partial<Record<keyof T, (value: any) => string | undefined>>;

interface UseFormConfig<T> {
  initialValues: T;
  validationRules?: ValidationRules<T>;
  onSubmit: (values: T) => void | Promise<void>;
}

interface UseFormReturn<T> {
  values: T;
  errors: FormErrors<T>;
  touched: FormTouched<T>;
  isSubmitting: boolean;
  isValid: boolean;
  handleChange: (field: keyof T) => (value: any) => void;
  handleBlur: (field: keyof T) => () => void;
  handleSubmit: () => void;
  setFieldValue: (field: keyof T, value: any) => void;
  setFieldError: (field: keyof T, error: string) => void;
  setFieldTouched: (field: keyof T, touched?: boolean) => void;
  resetForm: () => void;
  validateField: (field: keyof T) => void;
  validateForm: () => boolean;
}

/**
 * Custom hook for form state management with validation
 * @param config - Form configuration
 * @returns Object with form state and control functions
 */
export function useForm<T extends Record<string, any>>({
  initialValues,
  validationRules,
  onSubmit,
}: UseFormConfig<T>): UseFormReturn<T> {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<FormErrors<T>>({});
  const [touched, setTouched] = useState<FormTouched<T>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validateField = useCallback(
    (field: keyof T) => {
      if (!validationRules || !validationRules[field]) {
        return;
      }

      const validator = validationRules[field];
      const error = validator!(values[field]);

      setErrors((prev) => ({
        ...prev,
        [field]: error,
      }));
    },
    [values, validationRules]
  );

  const validateForm = useCallback((): boolean => {
    if (!validationRules) return true;

    const newErrors: FormErrors<T> = {};
    let isValid = true;

    Object.keys(validationRules).forEach((field) => {
      const validator = validationRules[field as keyof T];
      if (validator) {
        const error = validator(values[field as keyof T]);
        if (error) {
          newErrors[field as keyof T] = error;
          isValid = false;
        }
      }
    });

    setErrors(newErrors);
    return isValid;
  }, [values, validationRules]);

  const handleChange = useCallback(
    (field: keyof T) => (value: any) => {
      setValues((prev) => ({
        ...prev,
        [field]: value,
      }));

      // Clear error when user starts typing
      if (errors[field]) {
        setErrors((prev) => ({
          ...prev,
          [field]: undefined,
        }));
      }
    },
    [errors]
  );

  const handleBlur = useCallback(
    (field: keyof T) => () => {
      setTouched((prev) => ({
        ...prev,
        [field]: true,
      }));

      validateField(field);
    },
    [validateField]
  );

  const handleSubmit = useCallback(async () => {
    // Touch all fields
    const allTouched: FormTouched<T> = {};
    Object.keys(values).forEach((key) => {
      allTouched[key as keyof T] = true;
    });
    setTouched(allTouched);

    // Validate form
    const isValid = validateForm();
    if (!isValid) return;

    // Submit
    setIsSubmitting(true);
    try {
      await onSubmit(values);
    } finally {
      setIsSubmitting(false);
    }
  }, [values, validateForm, onSubmit]);

  const setFieldValue = useCallback((field: keyof T, value: any) => {
    setValues((prev) => ({
      ...prev,
      [field]: value,
    }));
  }, []);

  const setFieldError = useCallback((field: keyof T, error: string) => {
    setErrors((prev) => ({
      ...prev,
      [field]: error,
    }));
  }, []);

  const setFieldTouched = useCallback(
    (field: keyof T, touchedValue: boolean = true) => {
      setTouched((prev) => ({
        ...prev,
        [field]: touchedValue,
      }));
    },
    []
  );

  const resetForm = useCallback(() => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
    setIsSubmitting(false);
  }, [initialValues]);

  const isValid = Object.keys(errors).length === 0;

  return {
    values,
    errors,
    touched,
    isSubmitting,
    isValid,
    handleChange,
    handleBlur,
    handleSubmit,
    setFieldValue,
    setFieldError,
    setFieldTouched,
    resetForm,
    validateField,
    validateForm,
  };
}

// Common validation rules
export const validators = {
  required: (message = 'This field is required') => (value: any) => {
    if (value === null || value === undefined || value === '') {
      return message;
    }
    return undefined;
  },

  minLength: (min: number, message?: string) => (value: string) => {
    if (value && value.length < min) {
      return message || `Must be at least ${min} characters`;
    }
    return undefined;
  },

  maxLength: (max: number, message?: string) => (value: string) => {
    if (value && value.length > max) {
      return message || `Must be at most ${max} characters`;
    }
    return undefined;
  },

  email: (message = 'Invalid email address') => (value: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (value && !emailRegex.test(value)) {
      return message;
    }
    return undefined;
  },

  pattern: (regex: RegExp, message = 'Invalid format') => (value: string) => {
    if (value && !regex.test(value)) {
      return message;
    }
    return undefined;
  },

  numeric: (message = 'Must be a number') => (value: any) => {
    if (value && isNaN(Number(value))) {
      return message;
    }
    return undefined;
  },

  min: (min: number, message?: string) => (value: number) => {
    if (value !== undefined && value < min) {
      return message || `Must be at least ${min}`;
    }
    return undefined;
  },

  max: (max: number, message?: string) => (value: number) => {
    if (value !== undefined && value > max) {
      return message || `Must be at most ${max}`;
    }
    return undefined;
  },
};
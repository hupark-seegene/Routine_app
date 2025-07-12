import { useState, useCallback } from 'react';

interface UseErrorReturn {
  error: Error | null;
  errorMessage: string | null;
  hasError: boolean;
  setError: (error: Error | string | null) => void;
  clearError: () => void;
  withErrorHandling: <T>(
    promise: Promise<T>,
    errorHandler?: (error: Error) => void
  ) => Promise<T | null>;
}

/**
 * Custom hook for managing error states
 * @returns Object with error state and control functions
 */
export const useError = (): UseErrorReturn => {
  const [error, setErrorState] = useState<Error | null>(null);

  const setError = useCallback((error: Error | string | null) => {
    if (error === null) {
      setErrorState(null);
    } else if (typeof error === 'string') {
      setErrorState(new Error(error));
    } else {
      setErrorState(error);
    }
  }, []);

  const clearError = useCallback(() => {
    setErrorState(null);
  }, []);

  const withErrorHandling = useCallback(
    async <T,>(
      promise: Promise<T>,
      errorHandler?: (error: Error) => void
    ): Promise<T | null> => {
      try {
        clearError();
        const result = await promise;
        return result;
      } catch (err) {
        const error = err instanceof Error ? err : new Error(String(err));
        setError(error);
        
        if (errorHandler) {
          errorHandler(error);
        }
        
        return null;
      }
    },
    [clearError, setError]
  );

  return {
    error,
    errorMessage: error?.message || null,
    hasError: error !== null,
    setError,
    clearError,
    withErrorHandling,
  };
};
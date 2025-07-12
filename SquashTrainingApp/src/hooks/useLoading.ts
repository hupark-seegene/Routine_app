import { useState, useCallback } from 'react';

interface UseLoadingReturn {
  isLoading: boolean;
  startLoading: () => void;
  stopLoading: () => void;
  setLoading: (value: boolean) => void;
  withLoading: <T>(promise: Promise<T>) => Promise<T>;
}

/**
 * Custom hook for managing loading states
 * @param initialState - Initial loading state (default: false)
 * @returns Object with loading state and control functions
 */
export const useLoading = (initialState: boolean = false): UseLoadingReturn => {
  const [isLoading, setIsLoading] = useState(initialState);

  const startLoading = useCallback(() => {
    setIsLoading(true);
  }, []);

  const stopLoading = useCallback(() => {
    setIsLoading(false);
  }, []);

  const setLoading = useCallback((value: boolean) => {
    setIsLoading(value);
  }, []);

  const withLoading = useCallback(async <T,>(promise: Promise<T>): Promise<T> => {
    try {
      startLoading();
      const result = await promise;
      return result;
    } finally {
      stopLoading();
    }
  }, [startLoading, stopLoading]);

  return {
    isLoading,
    startLoading,
    stopLoading,
    setLoading,
    withLoading,
  };
};
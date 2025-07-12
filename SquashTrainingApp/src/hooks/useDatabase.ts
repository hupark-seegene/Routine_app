import { useCallback, useEffect, useState } from 'react';
import { database } from '../database';
import { useLoading } from './useLoading';
import { useError } from './useError';

interface UseDatabaseReturn<T> {
  data: T | null;
  isLoading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
  execute: <R>(query: () => Promise<R>) => Promise<R | null>;
}

/**
 * Custom hook for database operations with loading and error handling
 * @param query - Async function that performs database operation
 * @param dependencies - Dependencies array for re-fetching
 * @returns Object with data, loading state, error, and control functions
 */
export function useDatabase<T>(
  query?: () => Promise<T>,
  dependencies: any[] = []
): UseDatabaseReturn<T> {
  const [data, setData] = useState<T | null>(null);
  const { isLoading, withLoading } = useLoading();
  const { error, withErrorHandling, clearError } = useError();

  const fetchData = useCallback(async () => {
    if (!query) return;
    
    const result = await withLoading(
      withErrorHandling(query())
    );
    
    if (result !== null) {
      setData(result);
    }
  }, [query, withLoading, withErrorHandling]);

  const execute = useCallback(
    async <R,>(operation: () => Promise<R>): Promise<R | null> => {
      clearError();
      return withLoading(
        withErrorHandling(operation())
      );
    },
    [withLoading, withErrorHandling, clearError]
  );

  useEffect(() => {
    fetchData();
  }, dependencies);

  return {
    data,
    isLoading,
    error,
    refetch: fetchData,
    execute,
  };
}

/**
 * Hook for database initialization
 */
export const useDatabaseInit = () => {
  const { isLoading, withLoading } = useLoading(true);
  const { error, withErrorHandling } = useError();

  useEffect(() => {
    const initDatabase = async () => {
      await withLoading(
        withErrorHandling(database.initialize())
      );
    };

    initDatabase();
  }, []);

  return { isInitialized: !isLoading && !error, error };
};
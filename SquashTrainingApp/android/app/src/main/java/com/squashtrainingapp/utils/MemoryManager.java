package com.squashtrainingapp.utils;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.ComponentCallbacks2;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.util.Log;
import android.util.LruCache;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Memory management utility to prevent memory leaks and optimize memory usage
 */
public class MemoryManager implements ComponentCallbacks2 {
    private static final String TAG = "MemoryManager";
    private static MemoryManager instance;
    
    private final Context applicationContext;
    private final List<WeakReference<Activity>> activityReferences;
    private final BitmapCache bitmapCache;
    
    // Memory thresholds
    private static final int LOW_MEMORY_THRESHOLD_MB = 50;
    private static final int CRITICAL_MEMORY_THRESHOLD_MB = 25;
    
    private MemoryManager(Context context) {
        this.applicationContext = context.getApplicationContext();
        this.activityReferences = new ArrayList<>();
        
        // Initialize bitmap cache with 1/8 of available memory
        final int maxMemory = (int) (Runtime.getRuntime().maxMemory() / 1024);
        final int cacheSize = maxMemory / 8;
        this.bitmapCache = new BitmapCache(cacheSize);
        
        // Register for memory callbacks
        context.registerComponentCallbacks(this);
    }
    
    public static synchronized MemoryManager getInstance(Context context) {
        if (instance == null) {
            instance = new MemoryManager(context);
        }
        return instance;
    }
    
    /**
     * Register an activity for memory management
     */
    public void registerActivity(Activity activity) {
        cleanupDeadReferences();
        activityReferences.add(new WeakReference<>(activity));
        Log.d(TAG, "Activity registered: " + activity.getClass().getSimpleName());
    }
    
    /**
     * Unregister an activity
     */
    public void unregisterActivity(Activity activity) {
        Iterator<WeakReference<Activity>> iterator = activityReferences.iterator();
        while (iterator.hasNext()) {
            WeakReference<Activity> ref = iterator.next();
            Activity act = ref.get();
            if (act == null || act == activity) {
                iterator.remove();
            }
        }
        Log.d(TAG, "Activity unregistered: " + activity.getClass().getSimpleName());
    }
    
    /**
     * Clean up dead activity references
     */
    private void cleanupDeadReferences() {
        Iterator<WeakReference<Activity>> iterator = activityReferences.iterator();
        while (iterator.hasNext()) {
            if (iterator.next().get() == null) {
                iterator.remove();
            }
        }
    }
    
    /**
     * Get current memory usage information
     */
    public MemoryInfo getMemoryInfo() {
        ActivityManager activityManager = (ActivityManager) applicationContext
                .getSystemService(Context.ACTIVITY_SERVICE);
        
        ActivityManager.MemoryInfo memInfo = new ActivityManager.MemoryInfo();
        activityManager.getMemoryInfo(memInfo);
        
        long totalMemory = Runtime.getRuntime().totalMemory();
        long freeMemory = Runtime.getRuntime().freeMemory();
        long maxMemory = Runtime.getRuntime().maxMemory();
        long usedMemory = totalMemory - freeMemory;
        
        return new MemoryInfo(
            usedMemory / (1024 * 1024),
            totalMemory / (1024 * 1024),
            maxMemory / (1024 * 1024),
            memInfo.availMem / (1024 * 1024),
            memInfo.totalMem / (1024 * 1024),
            memInfo.lowMemory
        );
    }
    
    /**
     * Check if memory is low
     */
    public boolean isMemoryLow() {
        MemoryInfo info = getMemoryInfo();
        long availableMemoryMB = info.availableSystemMemoryMB;
        return availableMemoryMB < LOW_MEMORY_THRESHOLD_MB;
    }
    
    /**
     * Check if memory is critically low
     */
    public boolean isMemoryCritical() {
        MemoryInfo info = getMemoryInfo();
        long availableMemoryMB = info.availableSystemMemoryMB;
        return availableMemoryMB < CRITICAL_MEMORY_THRESHOLD_MB;
    }
    
    /**
     * Perform memory cleanup
     */
    public void performMemoryCleanup() {
        Log.d(TAG, "Performing memory cleanup...");
        
        // Clear bitmap cache
        bitmapCache.evictAll();
        
        // Request garbage collection
        System.gc();
        
        // Notify activities to reduce memory usage
        for (WeakReference<Activity> ref : activityReferences) {
            Activity activity = ref.get();
            if (activity != null) {
                activity.onTrimMemory(TRIM_MEMORY_MODERATE);
            }
        }
        
        Log.d(TAG, "Memory cleanup completed");
    }
    
    /**
     * Get bitmap cache for image caching
     */
    public BitmapCache getBitmapCache() {
        return bitmapCache;
    }
    
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        // Handle configuration changes if needed
    }
    
    @Override
    public void onLowMemory() {
        Log.w(TAG, "System low memory warning received");
        performMemoryCleanup();
    }
    
    @Override
    public void onTrimMemory(int level) {
        Log.d(TAG, "onTrimMemory called with level: " + level);
        
        switch (level) {
            case TRIM_MEMORY_UI_HIDDEN:
                // App UI is hidden, reduce memory usage
                bitmapCache.trimToSize(bitmapCache.maxSize() / 2);
                break;
                
            case TRIM_MEMORY_RUNNING_MODERATE:
            case TRIM_MEMORY_RUNNING_LOW:
                // Running low on memory
                bitmapCache.trimToSize(bitmapCache.maxSize() / 4);
                break;
                
            case TRIM_MEMORY_RUNNING_CRITICAL:
                // Critical memory situation
                performMemoryCleanup();
                break;
                
            case TRIM_MEMORY_BACKGROUND:
            case TRIM_MEMORY_MODERATE:
            case TRIM_MEMORY_COMPLETE:
                // App in background, clear caches
                bitmapCache.evictAll();
                break;
        }
    }
    
    /**
     * Memory information class
     */
    public static class MemoryInfo {
        public final long usedMemoryMB;
        public final long totalMemoryMB;
        public final long maxMemoryMB;
        public final long availableSystemMemoryMB;
        public final long totalSystemMemoryMB;
        public final boolean isLowMemory;
        
        MemoryInfo(long usedMemoryMB, long totalMemoryMB, long maxMemoryMB,
                   long availableSystemMemoryMB, long totalSystemMemoryMB, boolean isLowMemory) {
            this.usedMemoryMB = usedMemoryMB;
            this.totalMemoryMB = totalMemoryMB;
            this.maxMemoryMB = maxMemoryMB;
            this.availableSystemMemoryMB = availableSystemMemoryMB;
            this.totalSystemMemoryMB = totalSystemMemoryMB;
            this.isLowMemory = isLowMemory;
        }
        
        @Override
        public String toString() {
            return String.format("Memory Info: App=%d/%dMB (max=%dMB), System=%d/%dMB, LowMemory=%b",
                usedMemoryMB, totalMemoryMB, maxMemoryMB,
                availableSystemMemoryMB, totalSystemMemoryMB, isLowMemory);
        }
    }
    
    /**
     * Simple bitmap cache using LruCache
     */
    public static class BitmapCache extends LruCache<String, Bitmap> {
        public BitmapCache(int maxSizeKB) {
            super(maxSizeKB);
        }
        
        @Override
        protected int sizeOf(String key, Bitmap bitmap) {
            // Return size in KB
            return bitmap.getByteCount() / 1024;
        }
        
        @Override
        protected void entryRemoved(boolean evicted, String key, Bitmap oldValue, Bitmap newValue) {
            if (evicted && oldValue != null && !oldValue.isRecycled()) {
                Log.d(TAG, "Bitmap evicted from cache: " + key);
            }
        }
        
        public void addBitmap(String key, Bitmap bitmap) {
            if (get(key) == null && bitmap != null) {
                put(key, bitmap);
            }
        }
        
        public Bitmap getBitmap(String key) {
            return get(key);
        }
    }
}
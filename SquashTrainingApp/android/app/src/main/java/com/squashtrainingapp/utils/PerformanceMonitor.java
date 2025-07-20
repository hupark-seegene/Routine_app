package com.squashtrainingapp.utils;

import android.app.ActivityManager;
import android.content.Context;
import android.os.Debug;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Choreographer;

import java.lang.ref.WeakReference;
import java.util.concurrent.TimeUnit;

/**
 * Performance monitoring utility for tracking FPS, memory usage, and performance metrics
 */
public class PerformanceMonitor {
    private static final String TAG = "PerformanceMonitor";
    private static PerformanceMonitor instance;
    
    private final WeakReference<Context> contextRef;
    private final Handler mainHandler;
    private boolean isMonitoring = false;
    
    // FPS tracking
    private Choreographer.FrameCallback frameCallback;
    private long lastFrameTimeNanos = 0;
    private int frameCount = 0;
    private long startTimeNanos = 0;
    
    // Memory tracking
    private long lastMemoryCheck = 0;
    private static final long MEMORY_CHECK_INTERVAL = 5000; // 5 seconds
    
    // Performance thresholds
    private static final int TARGET_FPS = 60;
    private static final int WARNING_FPS = 45;
    private static final int CRITICAL_FPS = 30;
    private static final long MAX_MEMORY_MB = 256; // Max memory usage in MB
    
    // Listener for performance updates
    public interface PerformanceListener {
        void onFPSUpdate(int fps);
        void onMemoryUpdate(long usedMemoryMB, long maxMemoryMB);
        void onPerformanceWarning(String warning);
    }
    
    private PerformanceListener listener;
    
    private PerformanceMonitor(Context context) {
        this.contextRef = new WeakReference<>(context.getApplicationContext());
        this.mainHandler = new Handler(Looper.getMainLooper());
        initializeFrameCallback();
    }
    
    public static synchronized PerformanceMonitor getInstance(Context context) {
        if (instance == null) {
            instance = new PerformanceMonitor(context);
        }
        return instance;
    }
    
    private void initializeFrameCallback() {
        frameCallback = new Choreographer.FrameCallback() {
            @Override
            public void doFrame(long frameTimeNanos) {
                if (!isMonitoring) return;
                
                // Calculate FPS
                if (lastFrameTimeNanos != 0) {
                    frameCount++;
                    
                    // Update FPS every second
                    long elapsedNanos = frameTimeNanos - startTimeNanos;
                    if (elapsedNanos >= TimeUnit.SECONDS.toNanos(1)) {
                        int fps = (int) (frameCount * TimeUnit.SECONDS.toNanos(1) / elapsedNanos);
                        notifyFPSUpdate(fps);
                        
                        // Reset counters
                        frameCount = 0;
                        startTimeNanos = frameTimeNanos;
                        
                        // Check for performance issues
                        checkPerformance(fps);
                    }
                } else {
                    startTimeNanos = frameTimeNanos;
                }
                
                lastFrameTimeNanos = frameTimeNanos;
                
                // Check memory periodically
                checkMemoryUsage();
                
                // Schedule next frame
                if (isMonitoring) {
                    Choreographer.getInstance().postFrameCallback(this);
                }
            }
        };
    }
    
    public void startMonitoring() {
        if (!isMonitoring) {
            isMonitoring = true;
            lastFrameTimeNanos = 0;
            frameCount = 0;
            Choreographer.getInstance().postFrameCallback(frameCallback);
            Log.d(TAG, "Performance monitoring started");
        }
    }
    
    public void stopMonitoring() {
        isMonitoring = false;
        Choreographer.getInstance().removeFrameCallback(frameCallback);
        Log.d(TAG, "Performance monitoring stopped");
    }
    
    public void setPerformanceListener(PerformanceListener listener) {
        this.listener = listener;
    }
    
    private void notifyFPSUpdate(int fps) {
        if (listener != null) {
            mainHandler.post(() -> listener.onFPSUpdate(fps));
        }
    }
    
    private void checkPerformance(int fps) {
        if (fps < CRITICAL_FPS) {
            notifyPerformanceWarning("Critical: FPS dropped to " + fps + " (target: " + TARGET_FPS + ")");
        } else if (fps < WARNING_FPS) {
            notifyPerformanceWarning("Warning: FPS is " + fps + " (target: " + TARGET_FPS + ")");
        }
    }
    
    private void checkMemoryUsage() {
        long currentTime = System.currentTimeMillis();
        if (currentTime - lastMemoryCheck < MEMORY_CHECK_INTERVAL) {
            return;
        }
        lastMemoryCheck = currentTime;
        
        Context context = contextRef.get();
        if (context == null) return;
        
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        if (activityManager == null) return;
        
        // Get memory info
        ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
        activityManager.getMemoryInfo(memoryInfo);
        
        // Get app memory usage
        Debug.MemoryInfo debugMemoryInfo = new Debug.MemoryInfo();
        Debug.getMemoryInfo(debugMemoryInfo);
        
        // Calculate memory usage in MB
        long totalPss = debugMemoryInfo.getTotalPss() / 1024; // Convert KB to MB
        long maxHeap = Runtime.getRuntime().maxMemory() / (1024 * 1024); // Convert bytes to MB
        
        if (listener != null) {
            mainHandler.post(() -> listener.onMemoryUpdate(totalPss, maxHeap));
        }
        
        // Check for memory warnings
        if (totalPss > MAX_MEMORY_MB) {
            notifyPerformanceWarning("High memory usage: " + totalPss + "MB (recommended max: " + MAX_MEMORY_MB + "MB)");
        }
        
        // Check if system is low on memory
        if (memoryInfo.lowMemory) {
            notifyPerformanceWarning("System low on memory - consider reducing memory usage");
        }
    }
    
    private void notifyPerformanceWarning(String warning) {
        Log.w(TAG, warning);
        if (listener != null) {
            mainHandler.post(() -> listener.onPerformanceWarning(warning));
        }
    }
    
    /**
     * Force garbage collection (use sparingly)
     */
    public void requestGarbageCollection() {
        System.gc();
        Log.d(TAG, "Garbage collection requested");
    }
    
    /**
     * Get current memory stats
     */
    public MemoryStats getMemoryStats() {
        Debug.MemoryInfo debugMemoryInfo = new Debug.MemoryInfo();
        Debug.getMemoryInfo(debugMemoryInfo);
        
        return new MemoryStats(
            debugMemoryInfo.getTotalPss() / 1024, // KB to MB
            Runtime.getRuntime().maxMemory() / (1024 * 1024), // Bytes to MB
            Runtime.getRuntime().totalMemory() / (1024 * 1024),
            Runtime.getRuntime().freeMemory() / (1024 * 1024)
        );
    }
    
    public static class MemoryStats {
        public final long totalPssMB;
        public final long maxHeapMB;
        public final long totalHeapMB;
        public final long freeHeapMB;
        
        MemoryStats(long totalPssMB, long maxHeapMB, long totalHeapMB, long freeHeapMB) {
            this.totalPssMB = totalPssMB;
            this.maxHeapMB = maxHeapMB;
            this.totalHeapMB = totalHeapMB;
            this.freeHeapMB = freeHeapMB;
        }
        
        @Override
        public String toString() {
            return String.format("Memory: PSS=%dMB, Heap=%d/%dMB (Free=%dMB)",
                totalPssMB, totalHeapMB, maxHeapMB, freeHeapMB);
        }
    }
}
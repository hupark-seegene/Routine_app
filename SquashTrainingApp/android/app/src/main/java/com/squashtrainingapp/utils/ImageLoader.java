package com.squashtrainingapp.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.ImageView;

import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Optimized image loader with caching and memory management
 */
public class ImageLoader {
    private static final String TAG = "ImageLoader";
    private static ImageLoader instance;
    
    private final MemoryManager.BitmapCache memoryCache;
    private final ExecutorService executorService;
    private final Context context;
    
    // Image loading options
    public static class Options {
        public int targetWidth = 0;
        public int targetHeight = 0;
        public boolean centerCrop = false;
        public int placeholderResId = 0;
        public int errorResId = 0;
        public boolean fadeIn = true;
        public int fadeInDuration = 200;
        
        public Options targetSize(int width, int height) {
            this.targetWidth = width;
            this.targetHeight = height;
            return this;
        }
        
        public Options placeholder(int resId) {
            this.placeholderResId = resId;
            return this;
        }
        
        public Options error(int resId) {
            this.errorResId = resId;
            return this;
        }
        
        public Options noFade() {
            this.fadeIn = false;
            return this;
        }
    }
    
    private ImageLoader(Context context) {
        this.context = context.getApplicationContext();
        this.memoryCache = MemoryManager.getInstance(context).getBitmapCache();
        this.executorService = Executors.newFixedThreadPool(3);
    }
    
    public static synchronized ImageLoader getInstance(Context context) {
        if (instance == null) {
            instance = new ImageLoader(context);
        }
        return instance;
    }
    
    /**
     * Load image from resource
     */
    public void loadResource(int resId, ImageView imageView) {
        loadResource(resId, imageView, new Options());
    }
    
    public void loadResource(int resId, ImageView imageView, Options options) {
        String key = "res_" + resId;
        
        // Check memory cache first
        Bitmap cached = memoryCache.getBitmap(key);
        if (cached != null && !cached.isRecycled()) {
            imageView.setImageBitmap(cached);
            return;
        }
        
        // Set placeholder if provided
        if (options.placeholderResId != 0) {
            imageView.setImageResource(options.placeholderResId);
        }
        
        // Load in background
        new LoadResourceTask(imageView, resId, key, options).executeOnExecutor(executorService);
    }
    
    /**
     * Load image from URL
     */
    public void loadUrl(String url, ImageView imageView) {
        loadUrl(url, imageView, new Options());
    }
    
    public void loadUrl(String url, ImageView imageView, Options options) {
        if (url == null || url.isEmpty()) {
            if (options.errorResId != 0) {
                imageView.setImageResource(options.errorResId);
            }
            return;
        }
        
        // Check memory cache first
        Bitmap cached = memoryCache.getBitmap(url);
        if (cached != null && !cached.isRecycled()) {
            imageView.setImageBitmap(cached);
            return;
        }
        
        // Set placeholder if provided
        if (options.placeholderResId != 0) {
            imageView.setImageResource(options.placeholderResId);
        }
        
        // Load in background
        new LoadUrlTask(imageView, url, options).executeOnExecutor(executorService);
    }
    
    /**
     * Clear memory cache
     */
    public void clearCache() {
        memoryCache.evictAll();
    }
    
    /**
     * Calculate optimal sample size for bitmap loading
     */
    private static int calculateInSampleSize(BitmapFactory.Options options, 
                                           int reqWidth, int reqHeight) {
        if (reqWidth == 0 || reqHeight == 0) {
            return 1;
        }
        
        final int height = options.outHeight;
        final int width = options.outWidth;
        int inSampleSize = 1;
        
        if (height > reqHeight || width > reqWidth) {
            final int halfHeight = height / 2;
            final int halfWidth = width / 2;
            
            while ((halfHeight / inSampleSize) >= reqHeight
                    && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2;
            }
        }
        
        return inSampleSize;
    }
    
    /**
     * Decode bitmap from resource with optimal size
     */
    private Bitmap decodeSampledBitmapFromResource(int resId, int reqWidth, int reqHeight) {
        final BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeResource(context.getResources(), resId, options);
        
        options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);
        options.inJustDecodeBounds = false;
        options.inPreferredConfig = Bitmap.Config.RGB_565; // Use RGB_565 for better memory usage
        
        try {
            return BitmapFactory.decodeResource(context.getResources(), resId, options);
        } catch (OutOfMemoryError e) {
            Log.e(TAG, "Out of memory loading resource: " + resId, e);
            // Try again with higher sample size
            options.inSampleSize *= 2;
            return BitmapFactory.decodeResource(context.getResources(), resId, options);
        }
    }
    
    /**
     * Decode bitmap from URL with optimal size
     */
    private Bitmap decodeSampledBitmapFromUrl(String urlString, int reqWidth, int reqHeight) {
        try {
            URL url = new URL(urlString);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            
            InputStream input = connection.getInputStream();
            
            // First decode with inJustDecodeBounds=true to check dimensions
            final BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeStream(input, null, options);
            input.close();
            
            // Calculate inSampleSize
            options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);
            
            // Decode bitmap with inSampleSize set
            options.inJustDecodeBounds = false;
            options.inPreferredConfig = Bitmap.Config.RGB_565;
            
            connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            input = connection.getInputStream();
            
            Bitmap bitmap = BitmapFactory.decodeStream(input, null, options);
            input.close();
            
            return bitmap;
        } catch (IOException e) {
            Log.e(TAG, "Error loading image from URL: " + urlString, e);
            return null;
        } catch (OutOfMemoryError e) {
            Log.e(TAG, "Out of memory loading URL: " + urlString, e);
            return null;
        }
    }
    
    /**
     * AsyncTask for loading resource images
     */
    private class LoadResourceTask extends AsyncTask<Void, Void, Bitmap> {
        private final WeakReference<ImageView> imageViewReference;
        private final int resId;
        private final String cacheKey;
        private final Options options;
        
        LoadResourceTask(ImageView imageView, int resId, String cacheKey, Options options) {
            this.imageViewReference = new WeakReference<>(imageView);
            this.resId = resId;
            this.cacheKey = cacheKey;
            this.options = options;
        }
        
        @Override
        protected Bitmap doInBackground(Void... params) {
            if (isCancelled()) return null;
            
            Bitmap bitmap = decodeSampledBitmapFromResource(
                resId,
                options.targetWidth,
                options.targetHeight
            );
            
            if (bitmap != null) {
                memoryCache.addBitmap(cacheKey, bitmap);
            }
            
            return bitmap;
        }
        
        @Override
        protected void onPostExecute(Bitmap bitmap) {
            if (isCancelled()) {
                bitmap = null;
            }
            
            ImageView imageView = imageViewReference.get();
            if (imageView != null && bitmap != null) {
                if (options.fadeIn) {
                    imageView.setAlpha(0f);
                    imageView.setImageBitmap(bitmap);
                    imageView.animate()
                        .alpha(1f)
                        .setDuration(options.fadeInDuration)
                        .start();
                } else {
                    imageView.setImageBitmap(bitmap);
                }
            } else if (imageView != null && options.errorResId != 0) {
                imageView.setImageResource(options.errorResId);
            }
        }
    }
    
    /**
     * AsyncTask for loading URL images
     */
    private class LoadUrlTask extends AsyncTask<Void, Void, Bitmap> {
        private final WeakReference<ImageView> imageViewReference;
        private final String url;
        private final Options options;
        
        LoadUrlTask(ImageView imageView, String url, Options options) {
            this.imageViewReference = new WeakReference<>(imageView);
            this.url = url;
            this.options = options;
        }
        
        @Override
        protected Bitmap doInBackground(Void... params) {
            if (isCancelled()) return null;
            
            Bitmap bitmap = decodeSampledBitmapFromUrl(
                url,
                options.targetWidth,
                options.targetHeight
            );
            
            if (bitmap != null) {
                memoryCache.addBitmap(url, bitmap);
            }
            
            return bitmap;
        }
        
        @Override
        protected void onPostExecute(Bitmap bitmap) {
            if (isCancelled()) {
                bitmap = null;
            }
            
            ImageView imageView = imageViewReference.get();
            if (imageView != null && bitmap != null) {
                if (options.fadeIn) {
                    imageView.setAlpha(0f);
                    imageView.setImageBitmap(bitmap);
                    imageView.animate()
                        .alpha(1f)
                        .setDuration(options.fadeInDuration)
                        .start();
                } else {
                    imageView.setImageBitmap(bitmap);
                }
            } else if (imageView != null && options.errorResId != 0) {
                imageView.setImageResource(options.errorResId);
            }
        }
    }
    
    /**
     * Shutdown the image loader
     */
    public void shutdown() {
        executorService.shutdown();
        clearCache();
    }
}
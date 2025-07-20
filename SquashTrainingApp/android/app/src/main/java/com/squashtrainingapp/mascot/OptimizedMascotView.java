package com.squashtrainingapp.mascot;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.util.AttributeSet;
import android.view.Choreographer;
import android.view.HapticFeedbackConstants;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import com.squashtrainingapp.R;

import java.lang.ref.WeakReference;
import java.util.LinkedList;

/**
 * Optimized MascotView with improved performance:
 * - Hardware acceleration
 * - Bitmap caching
 * - Choreographer-based animations for consistent 60fps
 * - Efficient memory management
 * - Reduced overdraw
 */
public class OptimizedMascotView extends View {
    private static final String TAG = "OptimizedMascotView";
    
    // Performance constants
    private static final int TARGET_FPS = 60;
    private static final long FRAME_TIME_NANOS = 1000000000L / TARGET_FPS;
    private static final int MAX_TRAIL_POINTS = 15; // Reduced for performance
    private static final int TRAIL_FADE_DURATION = 300; // ms
    
    // Cached resources
    private Bitmap mascotBitmap;
    private Bitmap shadowBitmap;
    private final Paint mascotPaint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);
    private final Paint trailPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint shadowPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    
    // Position and dimensions
    private float mascotX, mascotY;
    private float mascotWidth = 300;
    private float mascotHeight = 375;
    private float originalX, originalY;
    
    // Interaction states
    private boolean isDragging = false;
    private float lastTouchX, lastTouchY;
    private long touchStartTime;
    
    // Animation states
    private float animationPhase = 0f;
    private float breathingOffset = 0f;
    private float currentScale = 1.0f;
    private float targetScale = 1.0f;
    private boolean isAnimating = false;
    
    // Trail optimization
    private final LinkedList<TrailPoint> dragTrail = new LinkedList<>();
    private final Path trailPath = new Path(); // Reusable path
    
    // Zone effects
    private boolean inZone = false;
    private float zoneGlowIntensity = 0f;
    
    // Haptic feedback
    private Vibrator vibrator;
    
    // Animation handler using Choreographer
    private final Choreographer choreographer = Choreographer.getInstance();
    private final Choreographer.FrameCallback animationCallback = new Choreographer.FrameCallback() {
        @Override
        public void doFrame(long frameTimeNanos) {
            updateAnimations();
            if (isAnimating) {
                choreographer.postFrameCallback(this);
            }
        }
    };
    
    // Background thread for heavy operations
    private HandlerThread backgroundThread;
    private Handler backgroundHandler;
    
    // Listener
    private OnMascotInteractionListener interactionListener;
    
    // Optimized trail point with pooling
    private static class TrailPoint {
        float x, y;
        long timestamp;
        int alpha = 255;
        
        void set(float x, float y) {
            this.x = x;
            this.y = y;
            this.timestamp = System.currentTimeMillis();
            this.alpha = 255;
        }
    }
    
    public OptimizedMascotView(Context context) {
        super(context);
        init();
    }
    
    public OptimizedMascotView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }
    
    public OptimizedMascotView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }
    
    private void init() {
        // Enable hardware acceleration
        setLayerType(LAYER_TYPE_HARDWARE, null);
        
        // Initialize background thread for heavy operations
        backgroundThread = new HandlerThread("MascotBackground");
        backgroundThread.start();
        backgroundHandler = new Handler(backgroundThread.getLooper());
        
        // Load and cache mascot bitmap
        backgroundHandler.post(this::loadMascotBitmap);
        
        // Initialize paints
        trailPaint.setColor(0xFFC9FF00);
        trailPaint.setStyle(Paint.Style.STROKE);
        trailPaint.setStrokeWidth(6); // Slightly thinner for performance
        trailPaint.setStrokeCap(Paint.Cap.ROUND);
        trailPaint.setStrokeJoin(Paint.Join.ROUND);
        
        shadowPaint.setColor(0xFFC9FF00);
        shadowPaint.setStyle(Paint.Style.FILL);
        shadowPaint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.MULTIPLY));
        
        // Initialize vibrator
        vibrator = (Vibrator) getContext().getSystemService(Context.VIBRATOR_SERVICE);
        
        // Start animation loop
        startAnimationLoop();
    }
    
    private void loadMascotBitmap() {
        try {
            Drawable drawable = ContextCompat.getDrawable(getContext(), R.drawable.mascot_squash_player);
            if (drawable instanceof BitmapDrawable) {
                mascotBitmap = ((BitmapDrawable) drawable).getBitmap();
            } else if (drawable != null) {
                // Convert to bitmap if needed
                mascotBitmap = Bitmap.createBitmap(
                    (int) mascotWidth,
                    (int) mascotHeight,
                    Bitmap.Config.ARGB_8888
                );
                Canvas canvas = new Canvas(mascotBitmap);
                drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
                drawable.draw(canvas);
            }
            
            // Create shadow bitmap (smaller for performance)
            if (mascotBitmap != null) {
                createShadowBitmap();
            }
            
            // Update UI on main thread
            post(this::invalidate);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void createShadowBitmap() {
        int shadowSize = (int) (Math.min(mascotWidth, mascotHeight) * 0.3f);
        shadowBitmap = Bitmap.createBitmap(shadowSize, shadowSize, Bitmap.Config.ALPHA_8);
        Canvas shadowCanvas = new Canvas(shadowBitmap);
        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(0xFF000000);
        float radius = shadowSize / 2f;
        shadowCanvas.drawCircle(radius, radius, radius, paint);
    }
    
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        
        // Center the mascot
        mascotX = (w - mascotWidth) / 2;
        mascotY = (h - mascotHeight) / 2;
        originalX = mascotX;
        originalY = mascotY;
    }
    
    @Override
    protected void onDraw(Canvas canvas) {
        // Skip if resources not loaded
        if (mascotBitmap == null) return;
        
        // Draw trail first (behind mascot)
        if (isDragging && !dragTrail.isEmpty()) {
            drawOptimizedTrail(canvas);
        }
        
        // Calculate center for transformations
        float centerX = mascotX + mascotWidth / 2;
        float centerY = mascotY + mascotHeight / 2 + breathingOffset;
        
        // Draw zone glow if active
        if (inZone && zoneGlowIntensity > 0) {
            drawZoneGlow(canvas, centerX, centerY);
        }
        
        // Draw mascot with transformations
        canvas.save();
        canvas.scale(currentScale, currentScale, centerX, centerY);
        
        // Set alpha for drag effect
        mascotPaint.setAlpha(isDragging ? 220 : 255);
        
        // Draw mascot bitmap
        canvas.drawBitmap(
            mascotBitmap,
            mascotX,
            mascotY + breathingOffset,
            mascotPaint
        );
        
        canvas.restore();
    }
    
    private void drawOptimizedTrail(Canvas canvas) {
        if (dragTrail.size() < 2) return;
        
        // Clear and rebuild path
        trailPath.reset();
        
        // Build path from trail points
        boolean first = true;
        for (TrailPoint point : dragTrail) {
            if (first) {
                trailPath.moveTo(point.x, point.y);
                first = false;
            } else {
                trailPath.lineTo(point.x, point.y);
            }
            
            // Update alpha for fade effect
            long age = System.currentTimeMillis() - point.timestamp;
            point.alpha = Math.max(0, 255 - (int) (255 * age / TRAIL_FADE_DURATION));
        }
        
        // Draw with fading alpha
        trailPaint.setAlpha(dragTrail.getLast().alpha / 2);
        canvas.drawPath(trailPath, trailPaint);
    }
    
    private void drawZoneGlow(Canvas canvas, float centerX, float centerY) {
        if (shadowBitmap == null) return;
        
        float glowSize = shadowBitmap.getWidth() * (1 + zoneGlowIntensity * 0.5f);
        shadowPaint.setAlpha((int) (60 * zoneGlowIntensity));
        
        canvas.save();
        canvas.translate(centerX - glowSize / 2, centerY - glowSize / 2);
        canvas.scale(glowSize / shadowBitmap.getWidth(), glowSize / shadowBitmap.getHeight());
        canvas.drawBitmap(shadowBitmap, 0, 0, shadowPaint);
        canvas.restore();
    }
    
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        float x = event.getX();
        float y = event.getY();
        
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                return handleTouchDown(x, y);
                
            case MotionEvent.ACTION_MOVE:
                return handleTouchMove(x, y);
                
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                return handleTouchUp(x, y);
        }
        
        return super.onTouchEvent(event);
    }
    
    private boolean handleTouchDown(float x, float y) {
        if (isTouchOnMascot(x, y)) {
            isDragging = true;
            lastTouchX = x;
            lastTouchY = y;
            touchStartTime = System.currentTimeMillis();
            
            // Clear trail
            dragTrail.clear();
            addTrailPoint(x, y);
            
            // Animate scale
            animateScale(0.95f);
            
            // Haptic feedback
            performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY);
            
            return true;
        }
        return false;
    }
    
    private boolean handleTouchMove(float x, float y) {
        if (isDragging) {
            // Update position
            float dx = x - lastTouchX;
            float dy = y - lastTouchY;
            
            mascotX += dx;
            mascotY += dy;
            
            lastTouchX = x;
            lastTouchY = y;
            
            // Add trail point (throttled)
            if (dragTrail.isEmpty() || 
                System.currentTimeMillis() - dragTrail.getLast().timestamp > 16) {
                addTrailPoint(x, y);
            }
            
            // Notify listener
            if (interactionListener != null) {
                interactionListener.onMascotDragged(
                    mascotX + mascotWidth / 2,
                    mascotY + mascotHeight / 2
                );
            }
            
            invalidate();
            return true;
        }
        return false;
    }
    
    private boolean handleTouchUp(float x, float y) {
        if (isDragging) {
            isDragging = false;
            
            // Restore scale with bounce
            animateScaleBounce();
            
            // Check if it was a tap
            long touchDuration = System.currentTimeMillis() - touchStartTime;
            boolean hasMoved = Math.abs(mascotX - originalX) > 10 || 
                              Math.abs(mascotY - originalY) > 10;
            
            if (touchDuration < 200 && !hasMoved) {
                // Tap
                if (interactionListener != null) {
                    interactionListener.onMascotTapped();
                }
            } else {
                // Drag release
                if (interactionListener != null) {
                    interactionListener.onMascotReleased(
                        mascotX + mascotWidth / 2,
                        mascotY + mascotHeight / 2
                    );
                }
                
                // Haptic feedback
                if (inZone) {
                    performHapticFeedback(HapticFeedbackConstants.CONFIRM);
                }
            }
            
            // Animate back to original position
            animateToOriginalPosition();
            
            return true;
        }
        return false;
    }
    
    private boolean isTouchOnMascot(float x, float y) {
        return x >= mascotX && x <= mascotX + mascotWidth &&
               y >= mascotY && y <= mascotY + mascotHeight;
    }
    
    private void addTrailPoint(float x, float y) {
        TrailPoint point = new TrailPoint();
        point.set(x, y);
        dragTrail.add(point);
        
        // Remove old points
        while (dragTrail.size() > MAX_TRAIL_POINTS) {
            dragTrail.removeFirst();
        }
        
        // Remove faded points
        long currentTime = System.currentTimeMillis();
        while (!dragTrail.isEmpty() && 
               currentTime - dragTrail.getFirst().timestamp > TRAIL_FADE_DURATION) {
            dragTrail.removeFirst();
        }
    }
    
    private void startAnimationLoop() {
        isAnimating = true;
        choreographer.postFrameCallback(animationCallback);
    }
    
    private void stopAnimationLoop() {
        isAnimating = false;
        choreographer.removeFrameCallback(animationCallback);
    }
    
    private void updateAnimations() {
        // Update animation phase
        animationPhase += 0.05f;
        
        // Breathing animation
        if (!isDragging) {
            breathingOffset = (float) (Math.sin(animationPhase * 0.8) * 3);
        }
        
        // Scale animation
        if (Math.abs(currentScale - targetScale) > 0.001f) {
            currentScale += (targetScale - currentScale) * 0.15f;
        }
        
        // Zone glow animation
        if (inZone) {
            zoneGlowIntensity = 0.5f + 0.5f * (float) Math.sin(animationPhase * 3);
        } else if (zoneGlowIntensity > 0) {
            zoneGlowIntensity = Math.max(0, zoneGlowIntensity - 0.05f);
        }
        
        // Remove expired trail points
        if (!dragTrail.isEmpty()) {
            long currentTime = System.currentTimeMillis();
            while (!dragTrail.isEmpty() && 
                   currentTime - dragTrail.getFirst().timestamp > TRAIL_FADE_DURATION) {
                dragTrail.removeFirst();
            }
        }
        
        invalidate();
    }
    
    private void animateScale(float target) {
        targetScale = target;
    }
    
    private void animateScaleBounce() {
        // Use value animator for smooth bounce effect
        animateScale(1.1f);
        postDelayed(() -> animateScale(1.0f), 100);
    }
    
    private void animateToOriginalPosition() {
        TranslateAnimation animation = new TranslateAnimation(
            0, originalX - mascotX,
            0, originalY - mascotY
        );
        animation.setDuration(300);
        animation.setInterpolator(new AccelerateDecelerateInterpolator());
        animation.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {}
            
            @Override
            public void onAnimationEnd(Animation animation) {
                mascotX = originalX;
                mascotY = originalY;
                breathingOffset = 0;
                invalidate();
            }
            
            @Override
            public void onAnimationRepeat(Animation animation) {}
        });
        
        startAnimation(animation);
    }
    
    public void setOnMascotInteractionListener(OnMascotInteractionListener listener) {
        this.interactionListener = listener;
    }
    
    public void setInZone(boolean inZone) {
        this.inZone = inZone;
    }
    
    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        
        // Stop animations
        stopAnimationLoop();
        
        // Clean up background thread
        if (backgroundThread != null) {
            backgroundThread.quitSafely();
            backgroundThread = null;
            backgroundHandler = null;
        }
        
        // Release bitmaps
        if (mascotBitmap != null && !mascotBitmap.isRecycled()) {
            mascotBitmap.recycle();
            mascotBitmap = null;
        }
        if (shadowBitmap != null && !shadowBitmap.isRecycled()) {
            shadowBitmap.recycle();
            shadowBitmap = null;
        }
    }
    
    public interface OnMascotInteractionListener {
        void onMascotDragged(float x, float y);
        void onMascotReleased(float x, float y);
        void onMascotLongPress();
        void onMascotTapped();
    }
}
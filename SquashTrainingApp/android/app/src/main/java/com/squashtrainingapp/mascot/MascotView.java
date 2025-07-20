package com.squashtrainingapp.mascot;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.drawable.Drawable;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.util.AttributeSet;
import android.view.HapticFeedbackConstants;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.TranslateAnimation;
import android.os.Handler;
import androidx.core.content.ContextCompat;
import com.squashtrainingapp.R;
import java.util.ArrayList;
import java.util.List;

public class MascotView extends View {
    private static final String TAG = "MascotView";
    
    private Drawable mascotDrawable;
    private float mascotX, mascotY;
    private float mascotWidth = 300;
    private float mascotHeight = 375;
    private boolean isDragging = false;
    private float lastTouchX, lastTouchY;
    private float originalX, originalY;
    
    // Animation states
    private boolean isIdle = true;
    private boolean isActive = false;
    private Handler animationHandler;
    private Runnable idleAnimation;
    private Runnable breathingAnimation;
    private float animationTime = 0f;
    private float breathingOffset = 0f;
    private float scaleAnimation = 1.0f;
    
    // Drag trail visualization
    private List<TrailPoint> dragTrail;
    private Paint trailPaint;
    private boolean showTrail = false;
    
    // Haptic feedback
    private Vibrator vibrator;
    
    // Enhanced visual feedback
    private Paint shadowPaint;
    private boolean inZone = false;
    private float zoneGlowIntensity = 0f;
    
    private static class TrailPoint {
        float x, y;
        long timestamp;
        
        TrailPoint(float x, float y) {
            this.x = x;
            this.y = y;
            this.timestamp = System.currentTimeMillis();
        }
    }
    
    // Long press detection
    private long touchStartTime;
    private boolean isLongPressing = false;
    private static final long LONG_PRESS_DURATION = 2000; // 2 seconds
    private Handler longPressHandler;
    private Runnable longPressRunnable;
    
    // Listener interfaces
    private OnMascotInteractionListener interactionListener;
    
    public interface OnMascotInteractionListener {
        void onMascotDragged(float x, float y);
        void onMascotReleased(float x, float y);
        void onMascotLongPress();
        void onMascotTapped();
    }
    
    public MascotView(Context context) {
        super(context);
        init();
    }
    
    public MascotView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }
    
    public MascotView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }
    
    private void init() {
        mascotDrawable = ContextCompat.getDrawable(getContext(), R.drawable.mascot_squash_player);
        animationHandler = new Handler();
        longPressHandler = new Handler();
        
        // Initialize drag trail
        dragTrail = new ArrayList<>();
        
        // Initialize trail paint
        trailPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        trailPaint.setColor(0xFFC9FF00);
        trailPaint.setStyle(Paint.Style.STROKE);
        trailPaint.setStrokeWidth(8);
        trailPaint.setStrokeCap(Paint.Cap.ROUND);
        
        // Initialize shadow paint
        shadowPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        shadowPaint.setColor(0xFFC9FF00);
        shadowPaint.setStyle(Paint.Style.FILL);
        
        // Initialize vibrator
        vibrator = (Vibrator) getContext().getSystemService(Context.VIBRATOR_SERVICE);
        
        // Start idle animation
        startIdleAnimation();
    }
    
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        
        // Center the mascot initially
        mascotX = (w - mascotWidth) / 2;
        mascotY = (h - mascotHeight) / 2;
        originalX = mascotX;
        originalY = mascotY;
    }
    
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        // Draw drag trail first (behind mascot)
        if (showTrail && isDragging) {
            drawDragTrail(canvas);
        }
        
        if (mascotDrawable != null) {
            canvas.save();
            
            // Apply breathing animation and scaling
            float centerX = mascotX + mascotWidth / 2;
            float centerY = mascotY + mascotHeight / 2;
            
            // Draw enhanced shadow when in zone
            if (inZone) {
                drawZoneGlow(canvas, centerX, centerY);
            }
            
            // Scale animation for interaction feedback
            canvas.scale(scaleAnimation, scaleAnimation, centerX, centerY);
            
            // Apply breathing offset
            float currentY = mascotY + breathingOffset;
            
            // Set bounds with animation effects
            mascotDrawable.setBounds(
                (int) mascotX,
                (int) currentY,
                (int) (mascotX + mascotWidth),
                (int) (currentY + mascotHeight)
            );
            
            // Add slight transparency effect when being dragged
            if (isDragging) {
                mascotDrawable.setAlpha(220);
            } else {
                mascotDrawable.setAlpha(255);
            }
            
            mascotDrawable.draw(canvas);
            canvas.restore();
        }
    }
    
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        float x = event.getX();
        float y = event.getY();
        
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                if (isTouchOnMascot(x, y)) {
                    isDragging = true;
                    lastTouchX = x;
                    lastTouchY = y;
                    touchStartTime = System.currentTimeMillis();
                    
                    // Stop idle animation
                    stopIdleAnimation();
                    isActive = true;
                    
                    // Scale down animation for press feedback
                    animateScale(0.95f);
                    
                    // Clear drag trail and start fresh
                    dragTrail.clear();
                    showTrail = true;
                    addTrailPoint(x, y);
                    
                    // Haptic feedback for touch start
                    performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY);
                    
                    // Start long press detection
                    startLongPressDetection();
                    
                    return true;
                }
                break;
                
            case MotionEvent.ACTION_MOVE:
                if (isDragging) {
                    float dx = x - lastTouchX;
                    float dy = y - lastTouchY;
                    
                    mascotX += dx;
                    mascotY += dy;
                    
                    lastTouchX = x;
                    lastTouchY = y;
                    
                    // Add point to drag trail
                    addTrailPoint(x, y);
                    
                    // Cancel long press if moved
                    cancelLongPressDetection();
                    
                    if (interactionListener != null) {
                        interactionListener.onMascotDragged(mascotX + mascotWidth/2, mascotY + mascotHeight/2);
                    }
                    
                    invalidate();
                    return true;
                }
                break;
                
            case MotionEvent.ACTION_UP:
                if (isDragging) {
                    isDragging = false;
                    cancelLongPressDetection();
                    
                    // Hide drag trail
                    showTrail = false;
                    
                    // Restore scale with bounce effect
                    animateScaleBounce();
                    
                    long touchDuration = System.currentTimeMillis() - touchStartTime;
                    
                    if (touchDuration < 200 && !hasMoved()) {
                        // It's a tap
                        if (interactionListener != null) {
                            interactionListener.onMascotTapped();
                        }
                    } else {
                        // It's a drag release
                        if (interactionListener != null) {
                            interactionListener.onMascotReleased(mascotX + mascotWidth/2, mascotY + mascotHeight/2);
                        }
                        
                        // Provide haptic feedback on release
                        if (inZone) {
                            // Stronger feedback when released in zone
                            performHapticFeedback(HapticFeedbackConstants.CONFIRM);
                        } else {
                            // Light feedback for normal release
                            performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY);
                        }
                    }
                    
                    // Animate back to original position if needed
                    animateToOriginalPosition();
                    
                    return true;
                }
                break;
        }
        
        return super.onTouchEvent(event);
    }
    
    private boolean isTouchOnMascot(float x, float y) {
        return x >= mascotX && x <= mascotX + mascotWidth &&
               y >= mascotY && y <= mascotY + mascotHeight;
    }
    
    private boolean hasMoved() {
        float threshold = 10;
        return Math.abs(mascotX - originalX) > threshold || 
               Math.abs(mascotY - originalY) > threshold;
    }
    
    private void startLongPressDetection() {
        longPressRunnable = new Runnable() {
            @Override
            public void run() {
                if (isDragging && !hasMoved()) {
                    isLongPressing = true;
                    if (interactionListener != null) {
                        interactionListener.onMascotLongPress();
                    }
                }
            }
        };
        longPressHandler.postDelayed(longPressRunnable, LONG_PRESS_DURATION);
    }
    
    private void cancelLongPressDetection() {
        if (longPressRunnable != null) {
            longPressHandler.removeCallbacks(longPressRunnable);
            longPressRunnable = null;
        }
        isLongPressing = false;
    }
    
    private void animateToOriginalPosition() {
        TranslateAnimation animation = new TranslateAnimation(
            0, originalX - mascotX,
            0, originalY - mascotY
        );
        animation.setDuration(300);
        animation.setFillAfter(false);
        animation.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {}
            
            @Override
            public void onAnimationEnd(Animation animation) {
                mascotX = originalX;
                mascotY = originalY;
                invalidate();
                
                // Resume idle animation
                isActive = false;
                isIdle = true;
                startIdleAnimation();
            }
            
            @Override
            public void onAnimationRepeat(Animation animation) {}
        });
        
        startAnimation(animation);
    }
    
    private void startIdleAnimation() {
        if (idleAnimation == null) {
            idleAnimation = new Runnable() {
                @Override
                public void run() {
                    if (isIdle && !isActive) {
                        animationTime += 0.05f;
                        
                        // Breathing animation - smooth up and down
                        breathingOffset = (float) (Math.sin(animationTime * 0.8) * 3);
                        
                        // Subtle scale breathing effect
                        scaleAnimation = 1.0f + (float) (Math.sin(animationTime * 0.6) * 0.02);
                        
                        invalidate();
                    }
                    animationHandler.postDelayed(this, 50);
                }
            };
        }
        animationHandler.post(idleAnimation);
    }
    
    private void stopIdleAnimation() {
        if (idleAnimation != null) {
            animationHandler.removeCallbacks(idleAnimation);
        }
    }
    
    private void animateScale(float targetScale) {
        // Simple scale animation
        scaleAnimation = targetScale;
        invalidate();
    }
    
    private void animateScaleBounce() {
        // Create a bounce effect when released
        animationHandler.removeCallbacks(breathingAnimation);
        
        breathingAnimation = new Runnable() {
            float bouncePhase = 0f;
            
            @Override
            public void run() {
                if (bouncePhase < 1.0f) {
                    bouncePhase += 0.1f;
                    
                    // Bounce effect: scale up then settle to normal
                    float bounce = (float) (Math.sin(bouncePhase * Math.PI) * 0.1);
                    scaleAnimation = 1.0f + bounce;
                    
                    invalidate();
                    animationHandler.postDelayed(this, 16);
                } else {
                    // Settle to normal scale
                    scaleAnimation = 1.0f;
                    invalidate();
                }
            }
        };
        
        animationHandler.post(breathingAnimation);
    }
    
    public void setOnMascotInteractionListener(OnMascotInteractionListener listener) {
        this.interactionListener = listener;
    }
    
    // Method to set zone state for visual feedback
    public void setInZone(boolean inZone) {
        if (this.inZone != inZone) {
            this.inZone = inZone;
            
            // Start/stop zone glow animation
            if (inZone) {
                startZoneGlowAnimation();
            } else {
                stopZoneGlowAnimation();
            }
            
            invalidate();
        }
    }
    
    private void addTrailPoint(float x, float y) {
        dragTrail.add(new TrailPoint(x, y));
        
        // Remove old trail points (keep only last 20 points)
        long currentTime = System.currentTimeMillis();
        while (dragTrail.size() > 20 || 
               (!dragTrail.isEmpty() && currentTime - dragTrail.get(0).timestamp > 500)) {
            dragTrail.remove(0);
        }
    }
    
    private void drawDragTrail(Canvas canvas) {
        if (dragTrail.size() < 2) return;
        
        Path trailPath = new Path();
        TrailPoint firstPoint = dragTrail.get(0);
        trailPath.moveTo(firstPoint.x, firstPoint.y);
        
        for (int i = 1; i < dragTrail.size(); i++) {
            TrailPoint point = dragTrail.get(i);
            trailPath.lineTo(point.x, point.y);
        }
        
        // Draw trail with fading effect
        Paint fadingTrailPaint = new Paint(trailPaint);
        fadingTrailPaint.setAlpha(120);
        canvas.drawPath(trailPath, fadingTrailPaint);
    }
    
    private void drawZoneGlow(Canvas canvas, float centerX, float centerY) {
        // Draw animated glow effect around mascot when in zone
        float glowRadius = (mascotWidth + mascotHeight) / 3 * (1 + zoneGlowIntensity * 0.3f);
        
        shadowPaint.setAlpha((int) (60 * zoneGlowIntensity));
        canvas.drawCircle(centerX, centerY, glowRadius, shadowPaint);
    }
    
    private void startZoneGlowAnimation() {
        animationHandler.removeCallbacks(zoneGlowAnimation);
        animationHandler.post(zoneGlowAnimation);
    }
    
    private void stopZoneGlowAnimation() {
        animationHandler.removeCallbacks(zoneGlowAnimation);
        zoneGlowIntensity = 0f;
    }
    
    private Runnable zoneGlowAnimation = new Runnable() {
        @Override
        public void run() {
            if (inZone) {
                zoneGlowIntensity = 0.5f + 0.5f * (float) Math.sin(animationTime * 3);
                invalidate();
                animationHandler.postDelayed(this, 32);
            }
        }
    };
    
    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stopIdleAnimation();
        cancelLongPressDetection();
        stopZoneGlowAnimation();
        
        // Clean up breathing animation
        if (breathingAnimation != null) {
            animationHandler.removeCallbacks(breathingAnimation);
        }
        
        // Clean up animation handler
        if (animationHandler != null) {
            animationHandler.removeCallbacksAndMessages(null);
        }
    }
}
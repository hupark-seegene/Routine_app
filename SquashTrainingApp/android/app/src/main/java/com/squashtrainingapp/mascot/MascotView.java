package com.squashtrainingapp.mascot;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.TranslateAnimation;
import android.os.Handler;
import androidx.core.content.ContextCompat;
import com.squashtrainingapp.R;

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
        
        if (mascotDrawable != null) {
            mascotDrawable.setBounds(
                (int) mascotX,
                (int) mascotY,
                (int) (mascotX + mascotWidth),
                (int) (mascotY + mascotHeight)
            );
            mascotDrawable.draw(canvas);
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
                        // Simple bounce animation
                        float bounce = (float) (Math.sin(System.currentTimeMillis() * 0.001) * 5);
                        mascotY = originalY + bounce;
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
    
    public void setOnMascotInteractionListener(OnMascotInteractionListener listener) {
        this.interactionListener = listener;
    }
    
    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stopIdleAnimation();
        cancelLongPressDetection();
    }
}
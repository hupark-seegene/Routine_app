package com.squashtrainingapp.ui.views;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RadialGradient;
import android.graphics.Shader;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.DecelerateInterpolator;

import com.squashtrainingapp.R;

public class CircularPulseButton extends View {
    
    private Paint buttonPaint;
    private Paint pulsePaint;
    private Paint glowPaint;
    
    private int buttonColor = 0xFF10A37F; // Default green
    private int pulseColor = 0x3310A37F; // Semi-transparent green
    private int glowColor = 0x5513D4A3; // Glow color
    
    private float pulseRadius = 0f;
    private float glowRadius = 0f;
    private float rotation = 0f;
    
    private AnimatorSet pulseAnimatorSet;
    private ObjectAnimator rotationAnimator;
    
    private boolean isPulsing = false;
    private boolean isRotating = false;
    
    public CircularPulseButton(Context context) {
        super(context);
        init(context, null);
    }
    
    public CircularPulseButton(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }
    
    public CircularPulseButton(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }
    
    private void init(Context context, AttributeSet attrs) {
        if (attrs != null) {
            TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.CircularPulseButton);
            buttonColor = a.getColor(R.styleable.CircularPulseButton_buttonColor, buttonColor);
            pulseColor = a.getColor(R.styleable.CircularPulseButton_pulseColor, pulseColor);
            glowColor = a.getColor(R.styleable.CircularPulseButton_glowColor, glowColor);
            a.recycle();
        }
        
        // Main button paint
        buttonPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        buttonPaint.setColor(buttonColor);
        buttonPaint.setStyle(Paint.Style.FILL);
        
        // Pulse paint
        pulsePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        pulsePaint.setColor(pulseColor);
        pulsePaint.setStyle(Paint.Style.FILL);
        
        // Glow paint
        glowPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        glowPaint.setStyle(Paint.Style.FILL);
        
        setClickable(true);
    }
    
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        int width = getWidth();
        int height = getHeight();
        int centerX = width / 2;
        int centerY = height / 2;
        int radius = Math.min(width, height) / 2 - 20;
        
        // Save canvas state for rotation
        canvas.save();
        canvas.rotate(rotation, centerX, centerY);
        
        // Draw glow effect
        if (glowRadius > 0) {
            glowPaint.setShader(new RadialGradient(
                centerX, centerY, glowRadius,
                glowColor, 0x00000000, Shader.TileMode.CLAMP
            ));
            canvas.drawCircle(centerX, centerY, glowRadius, glowPaint);
        }
        
        // Draw pulse effect
        if (pulseRadius > 0) {
            pulsePaint.setAlpha((int) (100 * (1 - pulseRadius / (radius * 2))));
            canvas.drawCircle(centerX, centerY, radius + pulseRadius, pulsePaint);
        }
        
        // Restore canvas
        canvas.restore();
        
        // Draw main button
        canvas.drawCircle(centerX, centerY, radius, buttonPaint);
        
        // Draw microphone icon
        Paint iconPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        iconPaint.setColor(0xFFFFFFFF);
        iconPaint.setStyle(Paint.Style.STROKE);
        iconPaint.setStrokeWidth(6);
        iconPaint.setStrokeCap(Paint.Cap.ROUND);
        
        // Microphone body
        float micWidth = radius * 0.3f;
        float micHeight = radius * 0.5f;
        float micTop = centerY - micHeight / 2;
        float micBottom = centerY + micHeight / 2;
        
        canvas.drawLine(centerX - micWidth/2, micTop, centerX - micWidth/2, micBottom - micWidth/2, iconPaint);
        canvas.drawLine(centerX + micWidth/2, micTop, centerX + micWidth/2, micBottom - micWidth/2, iconPaint);
        canvas.drawArc(centerX - micWidth/2, micBottom - micWidth, centerX + micWidth/2, micBottom,
                0, 180, false, iconPaint);
        
        // Microphone stand
        canvas.drawLine(centerX, micBottom, centerX, micBottom + micHeight * 0.3f, iconPaint);
        canvas.drawLine(centerX - micWidth * 0.6f, micBottom + micHeight * 0.3f,
                centerX + micWidth * 0.6f, micBottom + micHeight * 0.3f, iconPaint);
    }
    
    public void startPulseAnimation() {
        if (isPulsing) return;
        isPulsing = true;
        
        // Create pulse animation
        ValueAnimator pulseAnimator = ValueAnimator.ofFloat(0, 1);
        pulseAnimator.setDuration(1500);
        pulseAnimator.setRepeatCount(ValueAnimator.INFINITE);
        pulseAnimator.setRepeatMode(ValueAnimator.RESTART);
        pulseAnimator.setInterpolator(new DecelerateInterpolator());
        pulseAnimator.addUpdateListener(animation -> {
            float value = (float) animation.getAnimatedValue();
            pulseRadius = value * getWidth() / 4;
            invalidate();
        });
        
        // Create glow animation
        ValueAnimator glowAnimator = ValueAnimator.ofFloat(0, 1, 0);
        glowAnimator.setDuration(2000);
        glowAnimator.setRepeatCount(ValueAnimator.INFINITE);
        glowAnimator.setRepeatMode(ValueAnimator.RESTART);
        glowAnimator.addUpdateListener(animation -> {
            float value = (float) animation.getAnimatedValue();
            glowRadius = (getWidth() / 2) + (value * getWidth() / 6);
            invalidate();
        });
        
        pulseAnimatorSet = new AnimatorSet();
        pulseAnimatorSet.playTogether(pulseAnimator, glowAnimator);
        pulseAnimatorSet.start();
    }
    
    public void stopPulseAnimation() {
        isPulsing = false;
        if (pulseAnimatorSet != null) {
            pulseAnimatorSet.cancel();
            pulseRadius = 0;
            glowRadius = 0;
            invalidate();
        }
    }
    
    public void startRotationAnimation() {
        if (isRotating) return;
        isRotating = true;
        
        rotationAnimator = ObjectAnimator.ofFloat(this, "rotation", 0f, 360f);
        rotationAnimator.setDuration(1000);
        rotationAnimator.setRepeatCount(ValueAnimator.INFINITE);
        rotationAnimator.setInterpolator(new DecelerateInterpolator());
        rotationAnimator.addUpdateListener(animation -> invalidate());
        rotationAnimator.start();
    }
    
    public void stopRotationAnimation() {
        isRotating = false;
        if (rotationAnimator != null) {
            rotationAnimator.cancel();
            rotation = 0f;
            invalidate();
        }
    }
    
    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stopPulseAnimation();
        stopRotationAnimation();
    }
}
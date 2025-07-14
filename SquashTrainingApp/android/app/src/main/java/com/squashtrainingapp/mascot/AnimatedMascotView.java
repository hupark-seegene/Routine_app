package com.squashtrainingapp.mascot;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Shader;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.BounceInterpolator;
import com.squashtrainingapp.R;

public class AnimatedMascotView extends View {
    
    private Paint bodyPaint;
    private Paint facePaint;
    private Paint eyePaint;
    private Paint pupilPaint;
    private Paint mouthPaint;
    private Paint racketPaint;
    private Paint shadowPaint;
    private Paint accentPaint;
    
    private float bounceOffset = 0f;
    private float blinkProgress = 0f;
    private float armRotation = 0f;
    private float breathScale = 1f;
    private boolean isListening = false;
    private float voiceWaveRadius = 0f;
    
    private AnimatorSet idleAnimationSet;
    private AnimatorSet listeningAnimationSet;
    
    // Character proportions
    private float headRadius;
    private float bodyWidth;
    private float bodyHeight;
    
    public AnimatedMascotView(Context context) {
        super(context);
        init();
    }
    
    public AnimatedMascotView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }
    
    private void init() {
        // Body paint with gradient
        bodyPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        
        // Face paint
        facePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        facePaint.setColor(Color.parseColor("#FFE0BD"));
        
        // Eye paint
        eyePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        eyePaint.setColor(Color.WHITE);
        
        // Pupil paint
        pupilPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        pupilPaint.setColor(Color.parseColor("#2C3E50"));
        
        // Mouth paint
        mouthPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mouthPaint.setColor(Color.parseColor("#E74C3C"));
        mouthPaint.setStyle(Paint.Style.STROKE);
        mouthPaint.setStrokeWidth(4f);
        mouthPaint.setStrokeCap(Paint.Cap.ROUND);
        
        // Racket paint
        racketPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        racketPaint.setColor(Color.parseColor("#34495E"));
        
        // Shadow paint
        shadowPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        shadowPaint.setColor(Color.parseColor("#20000000"));
        
        // Accent paint for details
        accentPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        accentPaint.setColor(getContext().getColor(R.color.accent));
        
        startIdleAnimation();
    }
    
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        
        // Calculate character dimensions
        headRadius = Math.min(w, h) * 0.15f;
        bodyWidth = Math.min(w, h) * 0.35f;
        bodyHeight = Math.min(w, h) * 0.4f;
        
        // Update gradient for body
        LinearGradient bodyGradient = new LinearGradient(
            w/2 - bodyWidth/2, h/2,
            w/2 + bodyWidth/2, h/2 + bodyHeight,
            getContext().getColor(R.color.primary),
            getContext().getColor(R.color.primary_dark),
            Shader.TileMode.CLAMP
        );
        bodyPaint.setShader(bodyGradient);
    }
    
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        float centerX = getWidth() / 2f;
        float centerY = getHeight() / 2f + bounceOffset;
        
        // Draw shadow
        float shadowY = getHeight() * 0.85f;
        float shadowScale = 1f - (bounceOffset / 100f);
        canvas.drawOval(
            centerX - bodyWidth/2 * shadowScale,
            shadowY - 10,
            centerX + bodyWidth/2 * shadowScale,
            shadowY + 10,
            shadowPaint
        );
        
        // Draw body with breathing effect
        canvas.save();
        canvas.scale(breathScale, breathScale, centerX, centerY);
        RectF bodyRect = new RectF(
            centerX - bodyWidth/2,
            centerY - bodyHeight/4,
            centerX + bodyWidth/2,
            centerY + bodyHeight/2
        );
        canvas.drawRoundRect(bodyRect, bodyWidth/4, bodyWidth/4, bodyPaint);
        canvas.restore();
        
        // Draw arms
        drawArms(canvas, centerX, centerY);
        
        // Draw racket
        drawRacket(canvas, centerX + bodyWidth/2, centerY);
        
        // Draw head
        float headY = centerY - bodyHeight/4 - headRadius;
        canvas.drawCircle(centerX, headY, headRadius, facePaint);
        
        // Draw face
        drawFace(canvas, centerX, headY);
        
        // Draw voice waves when listening
        if (isListening && voiceWaveRadius > 0) {
            drawVoiceWaves(canvas, centerX, headY);
        }
    }
    
    private void drawArms(Canvas canvas, float centerX, float centerY) {
        Paint armPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        armPaint.setColor(facePaint.getColor());
        armPaint.setStrokeWidth(20f);
        armPaint.setStrokeCap(Paint.Cap.ROUND);
        
        // Left arm
        canvas.drawLine(
            centerX - bodyWidth/3, centerY,
            centerX - bodyWidth/2 - 20, centerY + 40,
            armPaint
        );
        
        // Right arm (holding racket)
        canvas.save();
        canvas.rotate(armRotation, centerX + bodyWidth/3, centerY);
        canvas.drawLine(
            centerX + bodyWidth/3, centerY,
            centerX + bodyWidth/2 + 20, centerY - 20,
            armPaint
        );
        canvas.restore();
    }
    
    private void drawRacket(Canvas canvas, float x, float y) {
        canvas.save();
        canvas.rotate(armRotation, x, y);
        
        // Racket handle
        Paint handlePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        handlePaint.setColor(Color.parseColor("#8B4513"));
        handlePaint.setStrokeWidth(12f);
        canvas.drawLine(x + 20, y - 20, x + 60, y - 60, handlePaint);
        
        // Racket head
        RectF racketHead = new RectF(x + 50, y - 90, x + 90, y - 50);
        canvas.drawOval(racketHead, racketPaint);
        
        // Racket strings
        Paint stringPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        stringPaint.setColor(Color.WHITE);
        stringPaint.setStrokeWidth(2f);
        for (int i = 0; i < 4; i++) {
            float offset = i * 10;
            canvas.drawLine(x + 55 + offset, y - 85, x + 55 + offset, y - 55, stringPaint);
            canvas.drawLine(x + 55, y - 85 + offset, x + 85, y - 85 + offset, stringPaint);
        }
        
        canvas.restore();
    }
    
    private void drawFace(Canvas canvas, float centerX, float centerY) {
        float eyeY = centerY - headRadius * 0.2f;
        float eyeSpacing = headRadius * 0.6f;
        float eyeRadius = headRadius * 0.15f;
        
        // Draw eyes with blink animation
        if (blinkProgress < 0.5f) {
            // Eyes open
            canvas.drawCircle(centerX - eyeSpacing/2, eyeY, eyeRadius, eyePaint);
            canvas.drawCircle(centerX + eyeSpacing/2, eyeY, eyeRadius, eyePaint);
            
            // Pupils that follow cursor/touch
            float pupilRadius = eyeRadius * 0.5f;
            canvas.drawCircle(centerX - eyeSpacing/2, eyeY, pupilRadius, pupilPaint);
            canvas.drawCircle(centerX + eyeSpacing/2, eyeY, pupilRadius, pupilPaint);
        } else {
            // Eyes closed (blinking)
            mouthPaint.setStrokeWidth(3f);
            canvas.drawLine(
                centerX - eyeSpacing/2 - eyeRadius, eyeY,
                centerX - eyeSpacing/2 + eyeRadius, eyeY,
                mouthPaint
            );
            canvas.drawLine(
                centerX + eyeSpacing/2 - eyeRadius, eyeY,
                centerX + eyeSpacing/2 + eyeRadius, eyeY,
                mouthPaint
            );
            mouthPaint.setStrokeWidth(4f);
        }
        
        // Draw mouth (smile)
        Path mouthPath = new Path();
        float mouthY = centerY + headRadius * 0.3f;
        float mouthWidth = headRadius * 0.6f;
        
        if (isListening) {
            // Open mouth when listening
            RectF mouthRect = new RectF(
                centerX - mouthWidth/2,
                mouthY - 10,
                centerX + mouthWidth/2,
                mouthY + 10
            );
            mouthPaint.setStyle(Paint.Style.FILL);
            canvas.drawOval(mouthRect, mouthPaint);
            mouthPaint.setStyle(Paint.Style.STROKE);
        } else {
            // Smile
            mouthPath.moveTo(centerX - mouthWidth/2, mouthY);
            mouthPath.quadTo(centerX, mouthY + 15, centerX + mouthWidth/2, mouthY);
            canvas.drawPath(mouthPath, mouthPaint);
        }
        
        // Draw cheeks (blush effect when happy)
        Paint blushPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        blushPaint.setColor(Color.parseColor("#30FF6B6B"));
        canvas.drawCircle(centerX - headRadius * 0.7f, centerY, headRadius * 0.2f, blushPaint);
        canvas.drawCircle(centerX + headRadius * 0.7f, centerY, headRadius * 0.2f, blushPaint);
    }
    
    private void drawVoiceWaves(Canvas canvas, float centerX, float centerY) {
        Paint wavePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        wavePaint.setStyle(Paint.Style.STROKE);
        wavePaint.setStrokeWidth(3f);
        
        for (int i = 0; i < 3; i++) {
            float radius = voiceWaveRadius + i * 30;
            int alpha = (int) (255 * (1 - radius / 200f));
            wavePaint.setColor(Color.argb(alpha, 0x1E, 0x88, 0xE5));
            canvas.drawCircle(centerX, centerY, radius, wavePaint);
        }
    }
    
    private void startIdleAnimation() {
        // Bounce animation
        ObjectAnimator bounceAnim = ObjectAnimator.ofFloat(this, "bounceOffset", 0f, -20f, 0f);
        bounceAnim.setDuration(2000);
        bounceAnim.setInterpolator(new BounceInterpolator());
        bounceAnim.setRepeatCount(ValueAnimator.INFINITE);
        
        // Blink animation
        ObjectAnimator blinkAnim = ObjectAnimator.ofFloat(this, "blinkProgress", 0f, 1f, 0f);
        blinkAnim.setDuration(200);
        blinkAnim.setStartDelay(3000);
        blinkAnim.setRepeatCount(ValueAnimator.INFINITE);
        blinkAnim.setRepeatMode(ValueAnimator.RESTART);
        
        // Arm swing animation
        ObjectAnimator armAnim = ObjectAnimator.ofFloat(this, "armRotation", -10f, 10f, -10f);
        armAnim.setDuration(3000);
        armAnim.setInterpolator(new AccelerateDecelerateInterpolator());
        armAnim.setRepeatCount(ValueAnimator.INFINITE);
        
        // Breathing animation
        ObjectAnimator breathAnim = ObjectAnimator.ofFloat(this, "breathScale", 1f, 1.05f, 1f);
        breathAnim.setDuration(4000);
        breathAnim.setInterpolator(new AccelerateDecelerateInterpolator());
        breathAnim.setRepeatCount(ValueAnimator.INFINITE);
        
        idleAnimationSet = new AnimatorSet();
        idleAnimationSet.playTogether(bounceAnim, blinkAnim, armAnim, breathAnim);
        idleAnimationSet.start();
    }
    
    public void startListeningAnimation() {
        isListening = true;
        
        if (idleAnimationSet != null) {
            idleAnimationSet.cancel();
        }
        
        // Voice wave animation
        ObjectAnimator waveAnim = ObjectAnimator.ofFloat(this, "voiceWaveRadius", 0f, 200f);
        waveAnim.setDuration(1500);
        waveAnim.setRepeatCount(ValueAnimator.INFINITE);
        waveAnim.setRepeatMode(ValueAnimator.RESTART);
        
        // Excited bounce
        ObjectAnimator excitedBounce = ObjectAnimator.ofFloat(this, "bounceOffset", 0f, -30f, 0f);
        excitedBounce.setDuration(500);
        excitedBounce.setInterpolator(new BounceInterpolator());
        excitedBounce.setRepeatCount(ValueAnimator.INFINITE);
        
        listeningAnimationSet = new AnimatorSet();
        listeningAnimationSet.playTogether(waveAnim, excitedBounce);
        listeningAnimationSet.start();
    }
    
    public void stopListeningAnimation() {
        isListening = false;
        voiceWaveRadius = 0f;
        
        if (listeningAnimationSet != null) {
            listeningAnimationSet.cancel();
        }
        
        startIdleAnimation();
    }
    
    // Property setters for animations
    public void setBounceOffset(float offset) {
        this.bounceOffset = offset;
        invalidate();
    }
    
    public void setBlinkProgress(float progress) {
        this.blinkProgress = progress;
        invalidate();
    }
    
    public void setArmRotation(float rotation) {
        this.armRotation = rotation;
        invalidate();
    }
    
    public void setBreathScale(float scale) {
        this.breathScale = scale;
        invalidate();
    }
    
    public void setVoiceWaveRadius(float radius) {
        this.voiceWaveRadius = radius;
        invalidate();
    }
    
    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (idleAnimationSet != null) {
            idleAnimationSet.cancel();
        }
        if (listeningAnimationSet != null) {
            listeningAnimationSet.cancel();
        }
    }
}
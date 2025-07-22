package com.squashtrainingapp.ui.views;

import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.LinearInterpolator;

import java.util.Random;

public class WaveformView extends View {
    
    private Paint wavePaint;
    private Path wavePath;
    
    private float[] amplitudes;
    private float[] targetAmplitudes;
    private float animationProgress = 0f;
    
    private ValueAnimator waveAnimator;
    private Random random = new Random();
    
    private int waveColor = 0x4010A37F; // Semi-transparent green
    private int barCount = 40;
    private float barWidth = 4f;
    private float barSpacing = 2f;
    private float maxAmplitude = 0.8f; // 80% of view height
    
    private boolean isAnimating = false;
    
    public WaveformView(Context context) {
        super(context);
        init();
    }
    
    public WaveformView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }
    
    public WaveformView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }
    
    private void init() {
        wavePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        wavePaint.setColor(waveColor);
        wavePaint.setStyle(Paint.Style.FILL);
        wavePaint.setStrokeCap(Paint.Cap.ROUND);
        
        wavePath = new Path();
        
        amplitudes = new float[barCount];
        targetAmplitudes = new float[barCount];
        
        // Initialize with small random values
        for (int i = 0; i < barCount; i++) {
            amplitudes[i] = 0.1f + random.nextFloat() * 0.1f;
            targetAmplitudes[i] = amplitudes[i];
        }
    }
    
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        int width = getWidth();
        int height = getHeight();
        int centerY = height / 2;
        
        // Calculate total bar width
        float totalBarWidth = (barWidth + barSpacing) * barCount - barSpacing;
        float startX = (width - totalBarWidth) / 2;
        
        // Draw waveform bars
        for (int i = 0; i < barCount; i++) {
            float x = startX + i * (barWidth + barSpacing);
            
            // Interpolate between current and target amplitude
            float amplitude = amplitudes[i] + (targetAmplitudes[i] - amplitudes[i]) * animationProgress;
            float barHeight = amplitude * height * maxAmplitude;
            
            // Create smooth wave effect - bars near center are taller
            float centerFactor = 1f - Math.abs(i - barCount / 2f) / (barCount / 2f);
            centerFactor = (float) Math.pow(centerFactor, 0.5); // Smooth curve
            barHeight *= (0.3f + 0.7f * centerFactor);
            
            // Draw bar
            float top = centerY - barHeight / 2;
            float bottom = centerY + barHeight / 2;
            
            // Add rounded corners
            wavePath.reset();
            wavePath.moveTo(x, top + barWidth / 2);
            wavePath.lineTo(x, bottom - barWidth / 2);
            wavePath.arcTo(x, bottom - barWidth, x + barWidth, bottom,
                    90, 180, false);
            wavePath.lineTo(x + barWidth, top + barWidth / 2);
            wavePath.arcTo(x, top, x + barWidth, top + barWidth,
                    270, 180, false);
            wavePath.close();
            
            // Set alpha based on amplitude
            int alpha = (int) (100 + amplitude * 155);
            wavePaint.setAlpha(alpha);
            
            canvas.drawPath(wavePath, wavePaint);
        }
    }
    
    public void startAnimation() {
        if (isAnimating) return;
        isAnimating = true;
        
        // Create continuous animation
        waveAnimator = ValueAnimator.ofFloat(0f, 1f);
        waveAnimator.setDuration(150);
        waveAnimator.setRepeatCount(ValueAnimator.INFINITE);
        waveAnimator.setInterpolator(new LinearInterpolator());
        
        waveAnimator.addUpdateListener(animation -> {
            animationProgress = (float) animation.getAnimatedValue();
            
            // When animation completes, generate new target amplitudes
            if (animationProgress >= 0.95f) {
                generateNewAmplitudes();
            }
            
            invalidate();
        });
        
        waveAnimator.start();
        
        // Start generating random amplitudes
        generateNewAmplitudes();
    }
    
    public void stopAnimation() {
        isAnimating = false;
        if (waveAnimator != null) {
            waveAnimator.cancel();
            waveAnimator = null;
        }
        
        // Animate to flat line
        for (int i = 0; i < barCount; i++) {
            targetAmplitudes[i] = 0.1f;
        }
        
        // One final animation to flatten
        ValueAnimator flattenAnimator = ValueAnimator.ofFloat(0f, 1f);
        flattenAnimator.setDuration(300);
        flattenAnimator.addUpdateListener(animation -> {
            float progress = (float) animation.getAnimatedValue();
            for (int i = 0; i < barCount; i++) {
                amplitudes[i] = amplitudes[i] + (targetAmplitudes[i] - amplitudes[i]) * progress;
            }
            invalidate();
        });
        flattenAnimator.start();
    }
    
    private void generateNewAmplitudes() {
        // Copy current targets to current
        System.arraycopy(targetAmplitudes, 0, amplitudes, 0, barCount);
        
        // Generate new targets with voice-like patterns
        float baseAmplitude = 0.3f + random.nextFloat() * 0.5f;
        
        for (int i = 0; i < barCount; i++) {
            // Create groups of similar amplitudes (voice formants)
            int groupSize = 3 + random.nextInt(5);
            int groupIndex = i / groupSize;
            
            float groupAmplitude = baseAmplitude * (0.5f + random.nextFloat() * 0.5f);
            float variation = 0.1f + random.nextFloat() * 0.2f;
            
            targetAmplitudes[i] = Math.max(0.1f, Math.min(1f, 
                groupAmplitude + (random.nextFloat() - 0.5f) * variation));
            
            // Add occasional spikes (consonants)
            if (random.nextFloat() < 0.1f) {
                targetAmplitudes[i] = Math.min(1f, targetAmplitudes[i] * 1.5f);
            }
        }
        
        // Reset animation progress
        animationProgress = 0f;
    }
    
    public void setWaveColor(int color) {
        this.waveColor = color;
        wavePaint.setColor(color);
        invalidate();
    }
    
    public void setBarCount(int count) {
        this.barCount = count;
        amplitudes = new float[barCount];
        targetAmplitudes = new float[barCount];
        
        for (int i = 0; i < barCount; i++) {
            amplitudes[i] = 0.1f;
            targetAmplitudes[i] = 0.1f;
        }
        
        invalidate();
    }
    
    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stopAnimation();
    }
}
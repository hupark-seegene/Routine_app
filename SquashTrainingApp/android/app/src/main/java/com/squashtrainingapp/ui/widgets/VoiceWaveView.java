package com.squashtrainingapp.ui.widgets;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.util.AttributeSet;
import android.view.View;
import com.squashtrainingapp.R;

public class VoiceWaveView extends View {
    private static final int WAVE_COUNT = 5;
    private static final float MAX_AMPLITUDE = 100f;
    
    private Paint wavePaint;
    private Paint glowPaint;
    private float[] amplitudes;
    private float[] targetAmplitudes;
    private float animationSpeed = 0.15f;
    private boolean isAnimating = false;
    
    public VoiceWaveView(Context context) {
        super(context);
        init();
    }
    
    public VoiceWaveView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }
    
    public VoiceWaveView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }
    
    private void init() {
        amplitudes = new float[WAVE_COUNT];
        targetAmplitudes = new float[WAVE_COUNT];
        
        wavePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        wavePaint.setColor(getContext().getColor(R.color.volt_green));
        wavePaint.setStrokeWidth(8f);
        wavePaint.setStrokeCap(Paint.Cap.ROUND);
        
        glowPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        glowPaint.setColor(getContext().getColor(R.color.volt_green));
        glowPaint.setStrokeWidth(12f);
        glowPaint.setStrokeCap(Paint.Cap.ROUND);
        glowPaint.setAlpha(80);
    }
    
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        float centerX = getWidth() / 2f;
        float centerY = getHeight() / 2f;
        float spacing = getWidth() / (float)(WAVE_COUNT + 1);
        
        for (int i = 0; i < WAVE_COUNT; i++) {
            float x = spacing * (i + 1);
            float amplitude = amplitudes[i];
            
            // Draw glow
            glowPaint.setAlpha((int)(80 * (amplitude / MAX_AMPLITUDE)));
            canvas.drawLine(x, centerY - amplitude * 1.2f, x, centerY + amplitude * 1.2f, glowPaint);
            
            // Draw wave line
            canvas.drawLine(x, centerY - amplitude, x, centerY + amplitude, wavePaint);
        }
        
        if (isAnimating) {
            updateAmplitudes();
            postInvalidateDelayed(50);
        }
    }
    
    private void updateAmplitudes() {
        for (int i = 0; i < WAVE_COUNT; i++) {
            // Smooth animation towards target
            amplitudes[i] += (targetAmplitudes[i] - amplitudes[i]) * animationSpeed;
            
            // Generate new random target when close
            if (Math.abs(amplitudes[i] - targetAmplitudes[i]) < 5f) {
                targetAmplitudes[i] = (float)(Math.random() * MAX_AMPLITUDE * 0.8f + MAX_AMPLITUDE * 0.2f);
            }
        }
    }
    
    public void startAnimation() {
        isAnimating = true;
        for (int i = 0; i < WAVE_COUNT; i++) {
            targetAmplitudes[i] = (float)(Math.random() * MAX_AMPLITUDE * 0.8f + MAX_AMPLITUDE * 0.2f);
        }
        invalidate();
    }
    
    public void stopAnimation() {
        isAnimating = false;
        for (int i = 0; i < WAVE_COUNT; i++) {
            targetAmplitudes[i] = 0;
        }
        invalidate();
    }
    
    public void setAmplitude(float amplitude) {
        // Set amplitude based on voice input level
        float normalizedAmplitude = Math.min(amplitude * MAX_AMPLITUDE, MAX_AMPLITUDE);
        for (int i = 0; i < WAVE_COUNT; i++) {
            float variation = (float)(Math.random() * 0.4f + 0.8f);
            targetAmplitudes[i] = normalizedAmplitude * variation;
        }
    }
}
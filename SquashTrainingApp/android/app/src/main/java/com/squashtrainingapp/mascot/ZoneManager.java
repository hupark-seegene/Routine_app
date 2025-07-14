package com.squashtrainingapp.mascot;

import android.content.Context;
import android.graphics.BlurMaskFilter;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RadialGradient;
import android.graphics.RectF;
import android.graphics.Shader;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.View;
import androidx.core.content.ContextCompat;
import com.squashtrainingapp.R;
import java.util.HashMap;
import java.util.Map;

public class ZoneManager extends View {
    private static final String TAG = "ZoneManager";
    
    private DragHandler dragHandler;
    private Map<String, ZoneInfo> zoneInfoMap;
    private Paint zonePaint;
    private Paint activeZonePaint;
    private Paint iconPaint;
    private Paint textPaint;
    private String highlightedZone = null;
    
    private static class ZoneInfo {
        String label;
        int iconResId;
        int color;
        
        ZoneInfo(String label, int iconResId, int color) {
            this.label = label;
            this.iconResId = iconResId;
            this.color = color;
        }
    }
    
    public ZoneManager(Context context) {
        super(context);
        init();
    }
    
    public ZoneManager(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }
    
    public ZoneManager(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }
    
    private void init() {
        dragHandler = new DragHandler();
        zoneInfoMap = new HashMap<>();
        
        // Initialize zone information
        zoneInfoMap.put("profile", new ZoneInfo("Profile", 0, 0xFF4CAF50));
        zoneInfoMap.put("checklist", new ZoneInfo("Checklist", 0, 0xFF2196F3));
        zoneInfoMap.put("coach", new ZoneInfo("AI Coach", 0, 0xFFFF9800));
        zoneInfoMap.put("record", new ZoneInfo("Record", 0, 0xFFF44336));
        zoneInfoMap.put("history", new ZoneInfo("History", 0, 0xFF9C27B0));
        zoneInfoMap.put("settings", new ZoneInfo("Settings", 0, 0xFF607D8B));
        
        // Enable hardware acceleration for blur effects
        setLayerType(LAYER_TYPE_SOFTWARE, null);
        
        // Initialize paints
        zonePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        zonePaint.setStyle(Paint.Style.FILL);
        zonePaint.setAlpha(30);
        
        activeZonePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        activeZonePaint.setStyle(Paint.Style.STROKE);
        activeZonePaint.setStrokeWidth(3);
        activeZonePaint.setColor(0xFFC9FF00); // Volt green
        activeZonePaint.setShadowLayer(20, 0, 0, 0xFFC9FF00);
        
        iconPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        
        textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        textPaint.setTextSize(28);
        textPaint.setColor(0xFFFFFFFF);
        textPaint.setTextAlign(Paint.Align.CENTER);
        textPaint.setShadowLayer(8, 0, 0, 0xFFC9FF00);
        textPaint.setLetterSpacing(0.05f);
    }
    
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        dragHandler.initializeZones(w, h);
    }
    
    // Update mascot position for highlighting
    public void updateMascotPosition(float x, float y) {
        if (dragHandler != null) {
            dragHandler.updatePosition(x, y);
            invalidate(); // Redraw to update highlight
        }
    }
    
    // Check which zone is at the given position
    public String checkZoneAtPosition(float x, float y) {
        if (dragHandler != null) {
            return dragHandler.getZoneAt(x, y);
        }
        return null;
    }
    
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        Map<String, RectF> zones = dragHandler.getFeatureZones();
        
        for (Map.Entry<String, RectF> entry : zones.entrySet()) {
            String zoneName = entry.getKey();
            RectF zone = entry.getValue();
            ZoneInfo info = zoneInfoMap.get(zoneName);
            
            if (info != null) {
                float centerX = zone.centerX();
                float centerY = zone.centerY();
                float radius = zone.width() / 2;
                
                // Create glassmorphism effect
                Paint glassPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
                
                // Gradient for depth
                RadialGradient gradient = new RadialGradient(
                    centerX, centerY, radius,
                    new int[]{
                        (info.color & 0x00FFFFFF) | 0x40000000,  // Semi-transparent center
                        (info.color & 0x00FFFFFF) | 0x20000000,  // More transparent edge
                        (info.color & 0x00FFFFFF) | 0x00000000   // Fully transparent
                    },
                    new float[]{0f, 0.7f, 1f},
                    Shader.TileMode.CLAMP
                );
                glassPaint.setShader(gradient);
                
                // Draw glassmorphism background
                canvas.drawCircle(centerX, centerY, radius, glassPaint);
                
                // Draw glass border
                Paint borderPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
                borderPaint.setStyle(Paint.Style.STROKE);
                borderPaint.setStrokeWidth(2);
                borderPaint.setColor((info.color & 0x00FFFFFF) | 0x60000000);
                canvas.drawCircle(centerX, centerY, radius, borderPaint);
                
                // Draw active zone neon glow
                if (zoneName.equals(highlightedZone)) {
                    // Multiple glow layers for neon effect
                    for (int i = 3; i > 0; i--) {
                        Paint glowPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
                        glowPaint.setStyle(Paint.Style.STROKE);
                        glowPaint.setStrokeWidth(i * 4);
                        glowPaint.setColor(0xFFC9FF00);
                        glowPaint.setAlpha(255 / (i * 2));
                        glowPaint.setMaskFilter(new BlurMaskFilter(i * 8, BlurMaskFilter.Blur.NORMAL));
                        canvas.drawCircle(centerX, centerY, radius, glowPaint);
                    }
                    
                    // Inner bright ring
                    canvas.drawCircle(centerX, centerY, radius, activeZonePaint);
                }
                
                // Draw zone label with glow
                canvas.drawText(
                    info.label.toUpperCase(),
                    centerX,
                    centerY + 10,
                    textPaint
                );
            }
        }
    }
    
    public void highlightZone(String zoneName) {
        if (!zoneName.equals(highlightedZone)) {
            highlightedZone = zoneName;
            invalidate();
        }
    }
    
    public void clearHighlight() {
        if (highlightedZone != null) {
            highlightedZone = null;
            invalidate();
        }
    }
    
    public DragHandler getDragHandler() {
        return dragHandler;
    }
}
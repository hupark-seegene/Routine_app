package com.squashtrainingapp.mascot;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
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
        
        // Initialize paints
        zonePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        zonePaint.setStyle(Paint.Style.FILL);
        zonePaint.setAlpha(50);
        
        activeZonePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        activeZonePaint.setStyle(Paint.Style.STROKE);
        activeZonePaint.setStrokeWidth(4);
        activeZonePaint.setColor(0xFFC9FF00); // Volt green
        
        iconPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        
        textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        textPaint.setTextSize(32);
        textPaint.setColor(0xFFFFFFFF);
        textPaint.setTextAlign(Paint.Align.CENTER);
        textPaint.setShadowLayer(4, 0, 2, 0xFF000000);
    }
    
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        dragHandler.initializeZones(w, h);
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
                // Draw zone background
                zonePaint.setColor(info.color);
                canvas.drawCircle(
                    zone.centerX(),
                    zone.centerY(),
                    zone.width() / 2,
                    zonePaint
                );
                
                // Draw active zone highlight
                if (zoneName.equals(highlightedZone)) {
                    canvas.drawCircle(
                        zone.centerX(),
                        zone.centerY(),
                        zone.width() / 2,
                        activeZonePaint
                    );
                }
                
                // Draw zone label
                canvas.drawText(
                    info.label,
                    zone.centerX(),
                    zone.centerY() + 10,
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
package com.squashtrainingapp.mascot;

import android.graphics.RectF;
import java.util.HashMap;
import java.util.Map;

public class DragHandler {
    private static final String TAG = "DragHandler";
    
    // Feature zones definitions
    private Map<String, RectF> featureZones;
    private String activeZone = null;
    private OnZoneChangeListener zoneChangeListener;
    
    public interface OnZoneChangeListener {
        void onZoneEntered(String zoneName);
        void onZoneExited(String zoneName);
        void onZoneActivated(String zoneName);
    }
    
    public DragHandler() {
        featureZones = new HashMap<>();
    }
    
    // Initialize zones based on screen dimensions
    public void initializeZones(int screenWidth, int screenHeight) {
        float centerX = screenWidth / 2f;
        float centerY = screenHeight / 2f;
        float zoneRadius = Math.min(screenWidth, screenHeight) * 0.15f;
        
        // Profile Zone (top)
        featureZones.put("profile", new RectF(
            centerX - zoneRadius,
            centerY - screenHeight * 0.35f - zoneRadius,
            centerX + zoneRadius,
            centerY - screenHeight * 0.35f + zoneRadius
        ));
        
        // Checklist Zone (top-left)
        featureZones.put("checklist", new RectF(
            centerX - screenWidth * 0.3f - zoneRadius,
            centerY - screenHeight * 0.2f - zoneRadius,
            centerX - screenWidth * 0.3f + zoneRadius,
            centerY - screenHeight * 0.2f + zoneRadius
        ));
        
        // Coach Zone (top-right)
        featureZones.put("coach", new RectF(
            centerX + screenWidth * 0.3f - zoneRadius,
            centerY - screenHeight * 0.2f - zoneRadius,
            centerX + screenWidth * 0.3f + zoneRadius,
            centerY - screenHeight * 0.2f + zoneRadius
        ));
        
        // Record Zone (bottom-left)
        featureZones.put("record", new RectF(
            centerX - screenWidth * 0.3f - zoneRadius,
            centerY + screenHeight * 0.2f - zoneRadius,
            centerX - screenWidth * 0.3f + zoneRadius,
            centerY + screenHeight * 0.2f + zoneRadius
        ));
        
        // History Zone (bottom-right)
        featureZones.put("history", new RectF(
            centerX + screenWidth * 0.3f - zoneRadius,
            centerY + screenHeight * 0.2f - zoneRadius,
            centerX + screenWidth * 0.3f + zoneRadius,
            centerY + screenHeight * 0.2f + zoneRadius
        ));
        
        // Settings Zone (bottom)
        featureZones.put("settings", new RectF(
            centerX - zoneRadius,
            centerY + screenHeight * 0.35f - zoneRadius,
            centerX + zoneRadius,
            centerY + screenHeight * 0.35f + zoneRadius
        ));
    }
    
    // Check which zone the mascot is currently in
    public void updatePosition(float x, float y) {
        String currentZone = null;
        
        for (Map.Entry<String, RectF> entry : featureZones.entrySet()) {
            if (entry.getValue().contains(x, y)) {
                currentZone = entry.getKey();
                break;
            }
        }
        
        // Handle zone changes
        if (currentZone != activeZone) {
            if (activeZone != null && zoneChangeListener != null) {
                zoneChangeListener.onZoneExited(activeZone);
            }
            
            activeZone = currentZone;
            
            if (activeZone != null && zoneChangeListener != null) {
                zoneChangeListener.onZoneEntered(activeZone);
            }
        }
    }
    
    // Called when mascot is released
    public void handleRelease(float x, float y) {
        for (Map.Entry<String, RectF> entry : featureZones.entrySet()) {
            if (entry.getValue().contains(x, y)) {
                if (zoneChangeListener != null) {
                    zoneChangeListener.onZoneActivated(entry.getKey());
                }
                break;
            }
        }
        
        activeZone = null;
    }
    
    public void setOnZoneChangeListener(OnZoneChangeListener listener) {
        this.zoneChangeListener = listener;
    }
    
    public Map<String, RectF> getFeatureZones() {
        return featureZones;
    }
    
    public String getActiveZone() {
        return activeZone;
    }
    
    // Get zone bounds for drawing
    public RectF getZoneBounds(String zoneName) {
        return featureZones.get(zoneName);
    }
}
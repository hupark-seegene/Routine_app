package com.squashtrainingapp.mascot;

import android.graphics.RectF;
import android.util.Log;
import java.util.HashMap;
import java.util.Map;

public class DragHandler {
    private static final String TAG = "DragHandler";
    
    // Feature zones definitions
    private Map<String, RectF> featureZones;
    private Map<String, Float> zoneDistances;
    private String activeZone = null;
    private String nearestZone = null;
    private OnZoneChangeListener zoneChangeListener;
    private float zoneRadius;
    private int screenWidth, screenHeight;
    
    public interface OnZoneChangeListener {
        void onZoneEntered(String zoneName);
        void onZoneExited(String zoneName);
        void onZoneActivated(String zoneName);
    }
    
    public DragHandler() {
        featureZones = new HashMap<>();
        zoneDistances = new HashMap<>();
    }
    
    // Initialize zones based on screen dimensions
    public void initializeZones(int screenWidth, int screenHeight) {
        this.screenWidth = screenWidth;
        this.screenHeight = screenHeight;
        
        float centerX = screenWidth / 2f;
        float centerY = screenHeight / 2f;
        
        // Adaptive zone radius based on screen size
        this.zoneRadius = Math.min(screenWidth, screenHeight) * 0.16f;
        
        // Improved zone positioning with better spacing
        float horizontalOffset = screenWidth * 0.28f;
        float verticalOffset = screenHeight * 0.32f;
        
        Log.d(TAG, "Initializing zones - Screen: " + screenWidth + "x" + screenHeight + 
                   ", ZoneRadius: " + zoneRadius);
        
        // Profile Zone (top)
        float profileY = centerY - verticalOffset;
        featureZones.put("profile", new RectF(
            centerX - zoneRadius,
            profileY - zoneRadius,
            centerX + zoneRadius,
            profileY + zoneRadius
        ));
        
        // Checklist Zone (top-left)
        float checklistX = centerX - horizontalOffset;
        float checklistY = centerY - verticalOffset * 0.6f;
        featureZones.put("checklist", new RectF(
            checklistX - zoneRadius,
            checklistY - zoneRadius,
            checklistX + zoneRadius,
            checklistY + zoneRadius
        ));
        
        // Coach Zone (top-right)
        float coachX = centerX + horizontalOffset;
        float coachY = centerY - verticalOffset * 0.6f;
        featureZones.put("coach", new RectF(
            coachX - zoneRadius,
            coachY - zoneRadius,
            coachX + zoneRadius,
            coachY + zoneRadius
        ));
        
        // Record Zone (bottom-left)
        float recordX = centerX - horizontalOffset;
        float recordY = centerY + verticalOffset * 0.6f;
        featureZones.put("record", new RectF(
            recordX - zoneRadius,
            recordY - zoneRadius,
            recordX + zoneRadius,
            recordY + zoneRadius
        ));
        
        // History Zone (bottom-right)
        float historyX = centerX + horizontalOffset;
        float historyY = centerY + verticalOffset * 0.6f;
        featureZones.put("history", new RectF(
            historyX - zoneRadius,
            historyY - zoneRadius,
            historyX + zoneRadius,
            historyY + zoneRadius
        ));
        
        // Settings Zone (bottom)
        float settingsY = centerY + verticalOffset;
        featureZones.put("settings", new RectF(
            centerX - zoneRadius,
            settingsY - zoneRadius,
            centerX + zoneRadius,
            settingsY + zoneRadius
        ));
        
        // Log zone positions for debugging
        for (Map.Entry<String, RectF> entry : featureZones.entrySet()) {
            RectF zone = entry.getValue();
            Log.d(TAG, "Zone " + entry.getKey() + ": center(" + zone.centerX() + ", " + 
                      zone.centerY() + ") size(" + zone.width() + "x" + zone.height() + ")");
        }
    }
    
    // Check which zone the mascot is currently in with improved detection
    public void updatePosition(float x, float y) {
        String currentZone = null;
        float minDistance = Float.MAX_VALUE;
        
        // Clear previous distances
        zoneDistances.clear();
        
        // Calculate distances to all zones
        for (Map.Entry<String, RectF> entry : featureZones.entrySet()) {
            RectF zone = entry.getValue();
            float distance = calculateDistanceToZone(x, y, zone);
            zoneDistances.put(entry.getKey(), distance);
            
            // Check if point is within zone
            if (zone.contains(x, y)) {
                currentZone = entry.getKey();
            }
            
            // Track nearest zone
            if (distance < minDistance) {
                minDistance = distance;
                nearestZone = entry.getKey();
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
    
    public float getZoneRadius() {
        return zoneRadius;
    }
    
    // Get zone bounds for drawing
    public RectF getZoneBounds(String zoneName) {
        return featureZones.get(zoneName);
    }
    
    // Get the zone at a specific position with improved accuracy
    public String getZoneAt(float x, float y) {
        // First check for exact zone containment
        for (Map.Entry<String, RectF> entry : featureZones.entrySet()) {
            if (entry.getValue().contains(x, y)) {
                return entry.getKey();
            }
        }
        
        // If not in any zone, check if close to zone edge (within 20% of radius)
        float threshold = zoneRadius * 0.2f;
        for (Map.Entry<String, RectF> entry : featureZones.entrySet()) {
            RectF zone = entry.getValue();
            float distance = calculateDistanceToZone(x, y, zone);
            if (distance <= threshold) {
                return entry.getKey();
            }
        }
        
        return null;
    }
    
    // Calculate distance from point to zone center
    private float calculateDistanceToZone(float x, float y, RectF zone) {
        float centerX = zone.centerX();
        float centerY = zone.centerY();
        
        float dx = x - centerX;
        float dy = y - centerY;
        
        return (float) Math.sqrt(dx * dx + dy * dy);
    }
    
    // Get the nearest zone to current position
    public String getNearestZone() {
        return nearestZone;
    }
    
    // Get distance to a specific zone
    public float getDistanceToZone(String zoneName) {
        return zoneDistances.containsKey(zoneName) ? zoneDistances.get(zoneName) : Float.MAX_VALUE;
    }
    
    // Get all zone distances for debugging
    public Map<String, Float> getAllZoneDistances() {
        return new HashMap<>(zoneDistances);
    }
    
    // Check if position is near any zone (within 30% of radius)
    public boolean isNearAnyZone(float x, float y) {
        float threshold = zoneRadius * 0.3f;
        for (RectF zone : featureZones.values()) {
            if (calculateDistanceToZone(x, y, zone) <= threshold) {
                return true;
            }
        }
        return false;
    }
}
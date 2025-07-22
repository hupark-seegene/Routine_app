package com.squashtrainingapp;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;

import java.util.Locale;

public class MainApplication extends Application {
    
    @Override
    public void onCreate() {
        super.onCreate();
        
        // Apply saved language preference
        applyLanguagePreference();
    }
    
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(updateBaseContextLocale(base));
    }
    
    private Context updateBaseContextLocale(Context context) {
        SharedPreferences prefs = context.getSharedPreferences("app_settings", Context.MODE_PRIVATE);
        String language = prefs.getString("language", "auto");
        
        Locale locale;
        if (language.equals("ko")) {
            locale = new Locale("ko");
        } else if (language.equals("en")) {
            locale = Locale.ENGLISH;
        } else {
            // Use system default
            return context;
        }
        
        Locale.setDefault(locale);
        
        Resources res = context.getResources();
        Configuration config = new Configuration(res.getConfiguration());
        config.setLocale(locale);
        
        return context.createConfigurationContext(config);
    }
    
    private void applyLanguagePreference() {
        SharedPreferences prefs = getSharedPreferences("app_settings", Context.MODE_PRIVATE);
        String language = prefs.getString("language", "auto");
        
        if (!language.equals("auto")) {
            Locale locale = language.equals("ko") ? new Locale("ko") : Locale.ENGLISH;
            Locale.setDefault(locale);
            
            Resources res = getResources();
            Configuration config = new Configuration(res.getConfiguration());
            config.setLocale(locale);
            
            getBaseContext().getResources().updateConfiguration(config, getBaseContext().getResources().getDisplayMetrics());
        }
    }
}
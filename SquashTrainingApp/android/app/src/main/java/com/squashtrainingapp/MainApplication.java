package com.squashtrainingapp;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;

public class MainApplication extends Application implements ReactApplication {
    
    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        protected List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
                new MainReactPackage()
                // Add other packages here if needed
            );
        }

        @Override
        protected String getJSMainModuleName() {
            return "index";
        }
    };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }
    
    @Override
    public void onCreate() {
        super.onCreate();
        
        // Initialize SoLoader for React Native
        SoLoader.init(this, /* native exopackage */ false);
        
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
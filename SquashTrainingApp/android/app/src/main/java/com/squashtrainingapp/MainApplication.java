package com.squashtrainingapp;

import android.app.Application;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.defaults.DefaultReactNativeHost;
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;
import com.facebook.react.PackageList;

// Native module imports
import com.oblador.vectoricons.VectorIconsPackage;
import org.pgsqlite.SQLitePluginPackage;
import com.horcrux.svg.SvgPackage;
import com.BV.LinearGradient.LinearGradientPackage;
import com.reactnativecommunity.slider.ReactSliderPackage;

import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;

public class MainApplication extends Application implements ReactApplication {

    private final ReactNativeHost mReactNativeHost = new DefaultReactNativeHost(this) {
        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        protected List<ReactPackage> getPackages() {
            @SuppressWarnings("UnnecessaryLocalVariable")
            List<ReactPackage> packages = new ArrayList<>();
            
            // Add default packages
            packages.add(new MainReactPackage());
            
            // Try to use autolinking first
            try {
                List<ReactPackage> autoLinkedPackages = new PackageList(this).getPackages();
                packages.addAll(autoLinkedPackages);
            } catch (Exception e) {
                // If autolinking fails, add packages manually
                packages.add(new VectorIconsPackage());
                packages.add(new SQLitePluginPackage());
                packages.add(new SvgPackage());
                packages.add(new LinearGradientPackage());
                packages.add(new ReactSliderPackage());
            }
            
            return packages;
        }

        @Override
        protected String getJSMainModuleName() {
            return "index";
        }

        @Override
        protected boolean isNewArchEnabled() {
            return BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
        }

        @Override
        protected Boolean isHermesEnabled() {
            return BuildConfig.IS_HERMES_ENABLED;
        }
    };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        SoLoader.init(this, /* native exopackage */ false);
        if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
            // If you opted-in for the New Architecture, we load the native entry point for this app.
            DefaultNewArchitectureEntryPoint.load();
        }
    }
}
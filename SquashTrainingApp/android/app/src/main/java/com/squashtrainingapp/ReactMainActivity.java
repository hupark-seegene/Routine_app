package com.squashtrainingapp;

import com.facebook.react.ReactActivity;
import com.facebook.react.ReactActivityDelegate;
import com.facebook.react.ReactRootView;

public class ReactMainActivity extends ReactActivity {

    /**
     * Returns the name of the main component registered from JavaScript.
     * This is used to schedule rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
        return "SquashTrainingApp";
    }

    /**
     * Returns the instance of the [ReactActivityDelegate]. We use [DefaultReactActivityDelegate]
     * which allows you to enable New Architecture with a single boolean flags [fabricEnabled]
     */
    @Override
    protected ReactActivityDelegate createReactActivityDelegate() {
        return new ReactActivityDelegate(this, getMainComponentName()) {
            @Override
            protected ReactRootView createRootView() {
                ReactRootView reactRootView = new ReactRootView(getContext());
                // If you opted-in for the New Architecture, we enable the Fabric Renderer.
                reactRootView.setIsFabric(BuildConfig.IS_NEW_ARCHITECTURE_ENABLED);
                return reactRootView;
            }
        };
    }
}
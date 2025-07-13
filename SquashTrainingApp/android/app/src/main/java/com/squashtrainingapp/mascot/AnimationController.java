package com.squashtrainingapp.mascot;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.BounceInterpolator;
import android.view.animation.OvershootInterpolator;

public class AnimationController {
    private static final String TAG = "AnimationController";
    
    // Animation durations
    private static final long IDLE_BOUNCE_DURATION = 2000;
    private static final long DRAG_SCALE_DURATION = 200;
    private static final long RELEASE_DURATION = 300;
    private static final long ZONE_ENTER_DURATION = 150;
    
    private View targetView;
    private AnimatorSet currentAnimation;
    
    public AnimationController(View view) {
        this.targetView = view;
    }
    
    // Idle bounce animation
    public void startIdleBounce() {
        stopCurrentAnimation();
        
        ObjectAnimator bounceY = ObjectAnimator.ofFloat(targetView, "translationY", 0f, -20f, 0f);
        bounceY.setDuration(IDLE_BOUNCE_DURATION);
        bounceY.setRepeatCount(ValueAnimator.INFINITE);
        bounceY.setInterpolator(new AccelerateDecelerateInterpolator());
        
        ObjectAnimator scaleX = ObjectAnimator.ofFloat(targetView, "scaleX", 1f, 1.02f, 1f);
        scaleX.setDuration(IDLE_BOUNCE_DURATION);
        scaleX.setRepeatCount(ValueAnimator.INFINITE);
        
        ObjectAnimator scaleY = ObjectAnimator.ofFloat(targetView, "scaleY", 1f, 0.98f, 1f);
        scaleY.setDuration(IDLE_BOUNCE_DURATION);
        scaleY.setRepeatCount(ValueAnimator.INFINITE);
        
        currentAnimation = new AnimatorSet();
        currentAnimation.playTogether(bounceY, scaleX, scaleY);
        currentAnimation.start();
    }
    
    // Scale up when dragging starts
    public void startDragAnimation() {
        stopCurrentAnimation();
        
        ObjectAnimator scaleUpX = ObjectAnimator.ofFloat(targetView, "scaleX", targetView.getScaleX(), 1.1f);
        ObjectAnimator scaleUpY = ObjectAnimator.ofFloat(targetView, "scaleY", targetView.getScaleY(), 1.1f);
        
        scaleUpX.setDuration(DRAG_SCALE_DURATION);
        scaleUpY.setDuration(DRAG_SCALE_DURATION);
        scaleUpX.setInterpolator(new OvershootInterpolator());
        scaleUpY.setInterpolator(new OvershootInterpolator());
        
        currentAnimation = new AnimatorSet();
        currentAnimation.playTogether(scaleUpX, scaleUpY);
        currentAnimation.start();
    }
    
    // Bounce back when released
    public void startReleaseAnimation() {
        stopCurrentAnimation();
        
        ObjectAnimator scaleDownX = ObjectAnimator.ofFloat(targetView, "scaleX", targetView.getScaleX(), 1f);
        ObjectAnimator scaleDownY = ObjectAnimator.ofFloat(targetView, "scaleY", targetView.getScaleY(), 1f);
        
        scaleDownX.setDuration(RELEASE_DURATION);
        scaleDownY.setDuration(RELEASE_DURATION);
        scaleDownX.setInterpolator(new BounceInterpolator());
        scaleDownY.setInterpolator(new BounceInterpolator());
        
        currentAnimation = new AnimatorSet();
        currentAnimation.playTogether(scaleDownX, scaleDownY);
        currentAnimation.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {}
            
            @Override
            public void onAnimationEnd(Animator animation) {
                startIdleBounce();
            }
            
            @Override
            public void onAnimationCancel(Animator animation) {}
            
            @Override
            public void onAnimationRepeat(Animator animation) {}
        });
        currentAnimation.start();
    }
    
    // Pulse animation when entering a zone
    public void startZoneEnterAnimation() {
        ObjectAnimator pulseX = ObjectAnimator.ofFloat(targetView, "scaleX", 1.1f, 1.2f, 1.1f);
        ObjectAnimator pulseY = ObjectAnimator.ofFloat(targetView, "scaleY", 1.1f, 1.2f, 1.1f);
        
        pulseX.setDuration(ZONE_ENTER_DURATION);
        pulseY.setDuration(ZONE_ENTER_DURATION);
        
        AnimatorSet pulseSet = new AnimatorSet();
        pulseSet.playTogether(pulseX, pulseY);
        pulseSet.start();
    }
    
    // Wiggle animation for attention
    public void startWiggleAnimation() {
        stopCurrentAnimation();
        
        ObjectAnimator rotateLeft = ObjectAnimator.ofFloat(targetView, "rotation", 0f, -10f);
        ObjectAnimator rotateRight = ObjectAnimator.ofFloat(targetView, "rotation", -10f, 10f);
        ObjectAnimator rotateCenter = ObjectAnimator.ofFloat(targetView, "rotation", 10f, 0f);
        
        rotateLeft.setDuration(100);
        rotateRight.setDuration(200);
        rotateCenter.setDuration(100);
        
        currentAnimation = new AnimatorSet();
        currentAnimation.playSequentially(rotateLeft, rotateRight, rotateCenter);
        currentAnimation.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {}
            
            @Override
            public void onAnimationEnd(Animator animation) {
                startIdleBounce();
            }
            
            @Override
            public void onAnimationCancel(Animator animation) {}
            
            @Override
            public void onAnimationRepeat(Animator animation) {}
        });
        currentAnimation.start();
    }
    
    // Stop any current animation
    public void stopCurrentAnimation() {
        if (currentAnimation != null && currentAnimation.isRunning()) {
            currentAnimation.cancel();
        }
    }
    
    // Snap back to position animation
    public void animateToPosition(float x, float y) {
        stopCurrentAnimation();
        
        ObjectAnimator moveX = ObjectAnimator.ofFloat(targetView, "x", x);
        ObjectAnimator moveY = ObjectAnimator.ofFloat(targetView, "y", y);
        
        moveX.setDuration(300);
        moveY.setDuration(300);
        moveX.setInterpolator(new OvershootInterpolator());
        moveY.setInterpolator(new OvershootInterpolator());
        
        currentAnimation = new AnimatorSet();
        currentAnimation.playTogether(moveX, moveY);
        currentAnimation.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {}
            
            @Override
            public void onAnimationEnd(Animator animation) {
                startIdleBounce();
            }
            
            @Override
            public void onAnimationCancel(Animator animation) {}
            
            @Override
            public void onAnimationRepeat(Animator animation) {}
        });
        currentAnimation.start();
    }
}
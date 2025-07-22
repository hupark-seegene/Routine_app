package com.squashtrainingapp.ui.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.airbnb.lottie.LottieAnimationView;
import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.squashtrainingapp.R;
import com.squashtrainingapp.onboarding.PremiumOnboardingManager;
import com.squashtrainingapp.ui.activities.OnboardingActivity;

import java.util.List;

public class OnboardingAdapter extends RecyclerView.Adapter<OnboardingAdapter.OnboardingViewHolder> {
    
    private List<OnboardingActivity.OnboardingItem> items;
    private Context context;
    private PremiumOnboardingManager onboardingManager;
    
    public OnboardingAdapter(List<OnboardingActivity.OnboardingItem> items, Context context) {
        this.items = items;
        this.context = context;
        this.onboardingManager = PremiumOnboardingManager.getInstance(context);
    }
    
    @NonNull
    @Override
    public OnboardingViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_onboarding, parent, false);
        return new OnboardingViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull OnboardingViewHolder holder, int position) {
        OnboardingActivity.OnboardingItem item = items.get(position);
        holder.bind(item);
    }
    
    @Override
    public int getItemCount() {
        return items.size();
    }
    
    public OnboardingActivity.OnboardingItem getItem(int position) {
        return items.get(position);
    }
    
    class OnboardingViewHolder extends RecyclerView.ViewHolder {
        private TextView titleText;
        private TextView descriptionText;
        private ImageView imageView;
        private LottieAnimationView animationView;
        private ViewGroup personalizationContainer;
        private ChipGroup levelChipGroup;
        private ChipGroup goalChipGroup;
        private RadioGroup frequencyRadioGroup;
        private Spinner timeSpinner;
        
        public OnboardingViewHolder(@NonNull View itemView) {
            super(itemView);
            
            titleText = itemView.findViewById(R.id.onboarding_title);
            descriptionText = itemView.findViewById(R.id.onboarding_description);
            imageView = itemView.findViewById(R.id.onboarding_image);
            animationView = itemView.findViewById(R.id.onboarding_animation);
            personalizationContainer = itemView.findViewById(R.id.personalization_container);
            levelChipGroup = itemView.findViewById(R.id.level_chip_group);
            goalChipGroup = itemView.findViewById(R.id.goal_chip_group);
            frequencyRadioGroup = itemView.findViewById(R.id.frequency_radio_group);
            timeSpinner = itemView.findViewById(R.id.time_spinner);
        }
        
        public void bind(OnboardingActivity.OnboardingItem item) {
            titleText.setText(item.getTitle());
            descriptionText.setText(item.getDescription());
            
            // Handle animation or image
            if (item.getAnimationResId() != 0 && animationView != null) {
                animationView.setVisibility(View.VISIBLE);
                imageView.setVisibility(View.GONE);
                animationView.setAnimation(item.getAnimationResId());
                animationView.playAnimation();
            } else if (item.getImageResId() != 0) {
                imageView.setVisibility(View.VISIBLE);
                if (animationView != null) {
                    animationView.setVisibility(View.GONE);
                }
                imageView.setImageResource(item.getImageResId());
            }
            
            // Handle personalization page
            if (item.getType() == OnboardingActivity.OnboardingItem.Type.PERSONALIZATION 
                    && personalizationContainer != null) {
                personalizationContainer.setVisibility(View.VISIBLE);
                setupPersonalization();
            } else if (personalizationContainer != null) {
                personalizationContainer.setVisibility(View.GONE);
            }
            
            // Special styling for premium offer
            if (item.getType() == OnboardingActivity.OnboardingItem.Type.PREMIUM_OFFER) {
                itemView.setBackgroundResource(R.drawable.premium_gradient_background);
            } else {
                itemView.setBackgroundColor(context.getColor(android.R.color.transparent));
            }
        }
        
        private void setupPersonalization() {
            // Setup level selection
            if (levelChipGroup != null) {
                String[] levels = {"초급", "중급", "상급", "프로"};
                PremiumOnboardingManager.UserLevel[] levelEnums = {
                    PremiumOnboardingManager.UserLevel.BEGINNER,
                    PremiumOnboardingManager.UserLevel.INTERMEDIATE,
                    PremiumOnboardingManager.UserLevel.ADVANCED,
                    PremiumOnboardingManager.UserLevel.PROFESSIONAL
                };
                
                for (int i = 0; i < levels.length; i++) {
                    Chip chip = new Chip(context);
                    chip.setText(levels[i]);
                    chip.setCheckable(true);
                    chip.setChecked(i == 0); // Default to beginner
                    
                    final int index = i;
                    chip.setOnCheckedChangeListener((buttonView, isChecked) -> {
                        if (isChecked) {
                            onboardingManager.setUserLevel(levelEnums[index]);
                        }
                    });
                    
                    levelChipGroup.addView(chip);
                }
            }
            
            // Setup goal selection
            if (goalChipGroup != null) {
                String[] goals = {"체력 향상", "대회 준비", "기술 개선", "체중 감량", "친목 도모"};
                PremiumOnboardingManager.UserGoal[] goalEnums = {
                    PremiumOnboardingManager.UserGoal.FITNESS,
                    PremiumOnboardingManager.UserGoal.COMPETITION,
                    PremiumOnboardingManager.UserGoal.TECHNIQUE,
                    PremiumOnboardingManager.UserGoal.WEIGHT_LOSS,
                    PremiumOnboardingManager.UserGoal.SOCIAL
                };
                
                for (int i = 0; i < goals.length; i++) {
                    Chip chip = new Chip(context);
                    chip.setText(goals[i]);
                    chip.setCheckable(true);
                    chip.setChecked(i == 0); // Default to fitness
                    
                    final int index = i;
                    chip.setOnCheckedChangeListener((buttonView, isChecked) -> {
                        if (isChecked) {
                            onboardingManager.setUserGoal(goalEnums[index]);
                        }
                    });
                    
                    goalChipGroup.addView(chip);
                }
            }
            
            // Setup frequency selection
            if (frequencyRadioGroup != null) {
                frequencyRadioGroup.setOnCheckedChangeListener((group, checkedId) -> {
                    int frequency = 3; // Default
                    if (checkedId == R.id.frequency_1_2) {
                        frequency = 2;
                    } else if (checkedId == R.id.frequency_3_4) {
                        frequency = 3;
                    } else if (checkedId == R.id.frequency_5_plus) {
                        frequency = 5;
                    }
                    onboardingManager.setWorkoutFrequency(frequency);
                });
            }
            
            // Setup time preference
            if (timeSpinner != null) {
                String[] times = {"아침 (6-9시)", "오전 (9-12시)", "점심 (12-14시)", 
                                 "오후 (14-18시)", "저녁 (18-21시)", "밤 (21시 이후)"};
                ArrayAdapter<String> adapter = new ArrayAdapter<>(context, 
                        android.R.layout.simple_spinner_item, times);
                adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                timeSpinner.setAdapter(adapter);
                timeSpinner.setSelection(4); // Default to evening
            }
        }
    }
}
package com.squashtrainingapp.ui.dialogs;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import androidx.annotation.NonNull;

import com.google.android.material.button.MaterialButton;
import com.squashtrainingapp.R;

public class ContentFilterDialog extends Dialog {
    
    private RadioGroup sortRadioGroup;
    private MaterialButton applyButton;
    
    private OnSortSelectedListener listener;
    
    public interface OnSortSelectedListener {
        void onSortSelected(String sortBy);
    }
    
    public ContentFilterDialog(@NonNull Context context) {
        super(context);
    }
    
    public void setOnSortSelectedListener(OnSortSelectedListener listener) {
        this.listener = listener;
    }
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.dialog_content_filter);
        
        initializeViews();
        setupListeners();
    }
    
    private void initializeViews() {
        sortRadioGroup = findViewById(R.id.sort_radio_group);
        applyButton = findViewById(R.id.apply_button);
        
        // Set default selection
        ((RadioButton) findViewById(R.id.radio_popular)).setChecked(true);
    }
    
    private void setupListeners() {
        applyButton.setOnClickListener(v -> {
            String sortBy = "popular"; // default
            
            int checkedId = sortRadioGroup.getCheckedRadioButtonId();
            if (checkedId == R.id.radio_popular) {
                sortBy = "popular";
            } else if (checkedId == R.id.radio_newest) {
                sortBy = "newest";
            } else if (checkedId == R.id.radio_rating) {
                sortBy = "rating";
            } else if (checkedId == R.id.radio_price_low) {
                sortBy = "price_low";
            } else if (checkedId == R.id.radio_price_high) {
                sortBy = "price_high";
            }
            
            if (listener != null) {
                listener.onSortSelected(sortBy);
            }
            dismiss();
        });
    }
}
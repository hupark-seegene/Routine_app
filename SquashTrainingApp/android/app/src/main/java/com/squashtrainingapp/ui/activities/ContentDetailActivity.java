package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.button.MaterialButton;
import com.squashtrainingapp.R;
import com.squashtrainingapp.marketplace.MarketplaceService;

public class ContentDetailActivity extends AppCompatActivity {
    
    private TextView titleText;
    private TextView creatorText;
    private TextView descriptionText;
    private TextView priceText;
    private RatingBar ratingBar;
    private TextView ratingText;
    private TextView purchaseCountText;
    private MaterialButton purchaseButton;
    private ProgressBar progressBar;
    
    private MarketplaceService marketplaceService;
    private String contentId;
    private boolean isPurchased;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_content_detail);
        
        contentId = getIntent().getStringExtra("content_id");
        isPurchased = getIntent().getBooleanExtra("is_purchased", false);
        
        initializeViews();
        loadContentDetails();
    }
    
    private void initializeViews() {
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        titleText = findViewById(R.id.title_text);
        creatorText = findViewById(R.id.creator_text);
        descriptionText = findViewById(R.id.description_text);
        priceText = findViewById(R.id.price_text);
        ratingBar = findViewById(R.id.rating_bar);
        ratingText = findViewById(R.id.rating_text);
        purchaseCountText = findViewById(R.id.purchase_count_text);
        purchaseButton = findViewById(R.id.purchase_button);
        progressBar = findViewById(R.id.progress_bar);
        
        marketplaceService = new MarketplaceService(this);
        
        if (isPurchased) {
            purchaseButton.setText("이미 구매함");
            purchaseButton.setEnabled(false);
        }
    }
    
    private void loadContentDetails() {
        // In a real app, you would load content details from Firebase
        // For now, show placeholder content
        titleText.setText("고급 스쿼시 트레이닝 프로그램");
        creatorText.setText("프로 코치 김철수");
        descriptionText.setText("이 프로그램은 중급자를 위한 8주 집중 트레이닝 과정입니다.");
        priceText.setText("$19.99");
        ratingBar.setRating(4.5f);
        ratingText.setText("4.5 (120 리뷰)");
        purchaseCountText.setText("500+ 구매");
    }
}
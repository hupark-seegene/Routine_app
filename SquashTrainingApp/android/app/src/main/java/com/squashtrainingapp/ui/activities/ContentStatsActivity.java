package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.squashtrainingapp.R;
import com.squashtrainingapp.marketplace.MarketplaceService;

public class ContentStatsActivity extends AppCompatActivity {
    
    private TextView viewCountText;
    private TextView purchaseCountText;
    private TextView revenueText;
    private TextView ratingText;
    
    private MarketplaceService marketplaceService;
    private String contentId;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_content_stats);
        
        contentId = getIntent().getStringExtra("content_id");
        
        initializeViews();
        loadStats();
    }
    
    private void initializeViews() {
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        viewCountText = findViewById(R.id.view_count_text);
        purchaseCountText = findViewById(R.id.purchase_count_text);
        revenueText = findViewById(R.id.revenue_text);
        ratingText = findViewById(R.id.rating_text);
        
        marketplaceService = new MarketplaceService(this);
    }
    
    private void loadStats() {
        // Placeholder stats
        viewCountText.setText("1,234");
        purchaseCountText.setText("56");
        revenueText.setText("$559.44");
        ratingText.setText("4.7 / 5.0");
        
        Toast.makeText(this, "콘텐츠 통계 기능 준비 중", Toast.LENGTH_SHORT).show();
    }
}
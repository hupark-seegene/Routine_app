package com.squashtrainingapp.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.SearchView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.squashtrainingapp.R;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.marketplace.MarketplaceService;
import com.squashtrainingapp.ui.adapters.MarketplaceContentAdapter;
import com.squashtrainingapp.ui.adapters.MarketplacePagerAdapter;
import com.squashtrainingapp.ui.dialogs.ContentFilterDialog;
import com.squashtrainingapp.ui.dialogs.PremiumFeatureDialog;

import java.util.ArrayList;
import java.util.List;

public class MarketplaceActivity extends AppCompatActivity implements MarketplaceContentAdapter.OnContentClickListener {
    
    // UI Components
    private TabLayout tabLayout;
    private ViewPager2 viewPager;
    private SearchView searchView;
    private ChipGroup filterChipGroup;
    private RecyclerView contentRecyclerView;
    private ProgressBar progressBar;
    private FloatingActionButton createContentFab;
    
    // Adapters
    private MarketplacePagerAdapter pagerAdapter;
    private MarketplaceContentAdapter contentAdapter;
    
    // Services
    private MarketplaceService marketplaceService;
    private FirebaseAuthManager authManager;
    
    // Current filters
    private MarketplaceService.ContentType currentType = null;
    private String currentSort = "popular";
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_marketplace);
        
        // Check premium status
        authManager = FirebaseAuthManager.getInstance(this);
        if (!authManager.isPremiumUser()) {
            PremiumFeatureDialog dialog = new PremiumFeatureDialog(this);
            dialog.showForMarketplace();
            finish();
            return;
        }
        
        initializeServices();
        initializeViews();
        setupTabs();
        setupFilters();
        loadContent();
    }
    
    private void initializeServices() {
        marketplaceService = new MarketplaceService(this);
    }
    
    private void initializeViews() {
        // Back button
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        // Views
        tabLayout = findViewById(R.id.tab_layout);
        viewPager = findViewById(R.id.view_pager);
        searchView = findViewById(R.id.search_view);
        filterChipGroup = findViewById(R.id.filter_chip_group);
        contentRecyclerView = findViewById(R.id.content_recycler_view);
        progressBar = findViewById(R.id.progress_bar);
        createContentFab = findViewById(R.id.create_content_fab);
        
        // Setup RecyclerView
        contentAdapter = new MarketplaceContentAdapter(new ArrayList<>(), this);
        contentRecyclerView.setLayoutManager(new GridLayoutManager(this, 2));
        contentRecyclerView.setAdapter(contentAdapter);
        
        // Setup search
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                searchContent(query);
                return true;
            }
            
            @Override
            public boolean onQueryTextChange(String newText) {
                if (newText.isEmpty()) {
                    loadContent();
                }
                return true;
            }
        });
        
        // FAB for content creators
        createContentFab.setOnClickListener(v -> {
            Intent intent = new Intent(this, CreateContentActivity.class);
            startActivity(intent);
        });
    }
    
    private void setupTabs() {
        pagerAdapter = new MarketplacePagerAdapter(this);
        viewPager.setAdapter(pagerAdapter);
        
        new TabLayoutMediator(tabLayout, viewPager, (tab, position) -> {
            switch (position) {
                case 0:
                    tab.setText("탐색");
                    break;
                case 1:
                    tab.setText("내 라이브러리");
                    break;
                case 2:
                    tab.setText("내 콘텐츠");
                    break;
            }
        }).attach();
        
        // Show/hide main content based on tab
        viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                if (position == 0) {
                    filterChipGroup.setVisibility(View.VISIBLE);
                    contentRecyclerView.setVisibility(View.VISIBLE);
                    createContentFab.setVisibility(View.GONE);
                } else if (position == 2) {
                    filterChipGroup.setVisibility(View.GONE);
                    contentRecyclerView.setVisibility(View.GONE);
                    createContentFab.setVisibility(View.VISIBLE);
                } else {
                    filterChipGroup.setVisibility(View.GONE);
                    contentRecyclerView.setVisibility(View.GONE);
                    createContentFab.setVisibility(View.GONE);
                }
            }
        });
    }
    
    private void setupFilters() {
        // Add filter chips
        String[] filters = {"전체", "트레이닝 프로그램", "드릴 모음", "비디오 튜토리얼", 
                           "기술 가이드", "영양 계획", "무료"};
        
        for (int i = 0; i < filters.length; i++) {
            Chip chip = new Chip(this);
            chip.setText(filters[i]);
            chip.setCheckable(true);
            chip.setChecked(i == 0); // First chip selected by default
            
            final int index = i;
            chip.setOnCheckedChangeListener((buttonView, isChecked) -> {
                if (isChecked) {
                    switch (index) {
                        case 0:
                            currentType = null;
                            break;
                        case 1:
                            currentType = MarketplaceService.ContentType.TRAINING_PROGRAM;
                            break;
                        case 2:
                            currentType = MarketplaceService.ContentType.DRILL_COLLECTION;
                            break;
                        case 3:
                            currentType = MarketplaceService.ContentType.VIDEO_TUTORIAL;
                            break;
                        case 4:
                            currentType = MarketplaceService.ContentType.TECHNIQUE_GUIDE;
                            break;
                        case 5:
                            currentType = MarketplaceService.ContentType.NUTRITION_PLAN;
                            break;
                        case 6:
                            currentType = null; // Will filter by price
                            break;
                    }
                    loadContent();
                }
            });
            
            filterChipGroup.addView(chip);
        }
        
        // Add sort chip at the end
        Chip sortChip = new Chip(this);
        sortChip.setText("정렬: 인기순");
        sortChip.setClickable(true);
        sortChip.setOnClickListener(v -> showSortDialog());
        filterChipGroup.addView(sortChip);
    }
    
    private void loadContent() {
        progressBar.setVisibility(View.VISIBLE);
        
        marketplaceService.browseContent(currentType, currentSort, 20, 
                new MarketplaceService.ContentCallback() {
            @Override
            public void onSuccess(List<MarketplaceService.MarketplaceContent> contents) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    contentAdapter.updateData(contents);
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(MarketplaceActivity.this, 
                            "콘텐츠 로드 실패: " + error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    private void searchContent(String query) {
        progressBar.setVisibility(View.VISIBLE);
        
        marketplaceService.searchContent(query, new MarketplaceService.ContentCallback() {
            @Override
            public void onSuccess(List<MarketplaceService.MarketplaceContent> contents) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    contentAdapter.updateData(contents);
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(MarketplaceActivity.this, 
                            "검색 실패: " + error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    private void showSortDialog() {
        ContentFilterDialog dialog = new ContentFilterDialog(this);
        dialog.setOnSortSelectedListener(sortBy -> {
            currentSort = sortBy;
            loadContent();
            
            // Update sort chip text
            Chip sortChip = (Chip) filterChipGroup.getChildAt(filterChipGroup.getChildCount() - 1);
            String sortText = "정렬: ";
            switch (sortBy) {
                case "popular":
                    sortText += "인기순";
                    break;
                case "newest":
                    sortText += "최신순";
                    break;
                case "rating":
                    sortText += "평점순";
                    break;
                case "price_low":
                    sortText += "가격 낮은순";
                    break;
                case "price_high":
                    sortText += "가격 높은순";
                    break;
            }
            sortChip.setText(sortText);
        });
        dialog.show();
    }
    
    @Override
    public void onContentClick(MarketplaceService.MarketplaceContent content) {
        Intent intent = new Intent(this, ContentDetailActivity.class);
        intent.putExtra("content_id", content.id);
        startActivity(intent);
    }
    
    @Override
    public void onPurchaseClick(MarketplaceService.MarketplaceContent content) {
        progressBar.setVisibility(View.VISIBLE);
        
        marketplaceService.purchaseContent(content.id, new MarketplaceService.PurchaseCallback() {
            @Override
            public void onSuccess(String message) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(MarketplaceActivity.this, message, Toast.LENGTH_SHORT).show();
                    loadContent(); // Refresh to update purchase status
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(MarketplaceActivity.this, error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        loadContent(); // Refresh content when returning from create activity
    }
}
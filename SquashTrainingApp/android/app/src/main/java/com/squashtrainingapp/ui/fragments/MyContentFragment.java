package com.squashtrainingapp.ui.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.squashtrainingapp.R;
import com.squashtrainingapp.marketplace.MarketplaceService;
import com.squashtrainingapp.ui.activities.CreateContentActivity;
import com.squashtrainingapp.ui.adapters.CreatorContentAdapter;

import java.util.ArrayList;
import java.util.List;

public class MyContentFragment extends Fragment {
    
    private RecyclerView recyclerView;
    private ProgressBar progressBar;
    private TextView emptyText;
    private CreatorContentAdapter adapter;
    private MarketplaceService marketplaceService;
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_my_content, container, false);
        
        initializeViews(view);
        loadCreatedContent();
        
        return view;
    }
    
    private void initializeViews(View view) {
        recyclerView = view.findViewById(R.id.recycler_view);
        progressBar = view.findViewById(R.id.progress_bar);
        emptyText = view.findViewById(R.id.empty_text);
        
        marketplaceService = new MarketplaceService(getContext());
        
        adapter = new CreatorContentAdapter(new ArrayList<>());
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerView.setAdapter(adapter);
    }
    
    private void loadCreatedContent() {
        progressBar.setVisibility(View.VISIBLE);
        emptyText.setVisibility(View.GONE);
        
        marketplaceService.getCreatedContent(new MarketplaceService.ContentCallback() {
            @Override
            public void onSuccess(List<MarketplaceService.MarketplaceContent> contents) {
                getActivity().runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    
                    if (contents.isEmpty()) {
                        emptyText.setText("아직 생성한 콘텐츠가 없습니다.\n새로운 콘텐츠를 만들어보세요!");
                        emptyText.setVisibility(View.VISIBLE);
                    } else {
                        adapter.updateData(contents);
                    }
                });
            }
            
            @Override
            public void onError(String error) {
                getActivity().runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    emptyText.setText("콘텐츠를 불러올 수 없습니다.");
                    emptyText.setVisibility(View.VISIBLE);
                });
            }
        });
    }
}
package com.squashtrainingapp.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageButton;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.squashtrainingapp.R;
import com.squashtrainingapp.models.User;
import com.squashtrainingapp.models.VideoTutorial;
import com.squashtrainingapp.ui.adapters.VideoTutorialAdapter;
import com.squashtrainingapp.video.YouTubeVideoManager;
import com.squashtrainingapp.database.DatabaseHelper;

import java.util.ArrayList;
import java.util.List;

public class VideoTutorialsActivity extends AppCompatActivity implements 
    VideoTutorialAdapter.VideoClickListener {
    
    private RecyclerView recyclerView;
    private VideoTutorialAdapter adapter;
    private YouTubeVideoManager videoManager;
    private Spinner categorySpinner;
    private Spinner levelSpinner;
    private ImageButton backButton;
    private TextView titleText;
    private TextView emptyText;
    
    private DatabaseHelper dbHelper;
    private User currentUser;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video_tutorials);
        
        initializeViews();
        setupSpinners();
        loadVideos();
    }
    
    private void initializeViews() {
        backButton = findViewById(R.id.back_button);
        titleText = findViewById(R.id.title_text);
        recyclerView = findViewById(R.id.videos_recycler_view);
        categorySpinner = findViewById(R.id.category_spinner);
        levelSpinner = findViewById(R.id.level_spinner);
        emptyText = findViewById(R.id.empty_text);
        
        // Initialize managers
        videoManager = new YouTubeVideoManager(this);
        dbHelper = DatabaseHelper.getInstance(this);
        currentUser = dbHelper.getUserDao().getUser();
        
        // Setup RecyclerView
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        adapter = new VideoTutorialAdapter(this);
        recyclerView.setAdapter(adapter);
        
        // Back button
        backButton.setOnClickListener(v -> finish());
        
        titleText.setText("비디오 튜토리얼");
    }
    
    private void setupSpinners() {
        // Category spinner
        String[] categories = {"모든 카테고리", "기술", "체력", "전술", "정신력", "드릴"};
        ArrayAdapter<String> categoryAdapter = new ArrayAdapter<>(
            this, android.R.layout.simple_spinner_item, categories);
        categoryAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        categorySpinner.setAdapter(categoryAdapter);
        
        // Level spinner
        String[] levels = {"추천", "초급", "중급", "고급", "모든 레벨"};
        ArrayAdapter<String> levelAdapter = new ArrayAdapter<>(
            this, android.R.layout.simple_spinner_item, levels);
        levelAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        levelSpinner.setAdapter(levelAdapter);
        
        // Listeners
        categorySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                filterVideos();
            }
            
            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });
        
        levelSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                filterVideos();
            }
            
            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });
    }
    
    private void loadVideos() {
        // Default: show recommended videos
        List<VideoTutorial> videos = videoManager.getRecommendedVideos(currentUser.getLevel());
        updateVideoList(videos);
    }
    
    private void filterVideos() {
        List<VideoTutorial> videos = new ArrayList<>();
        
        int categoryPosition = categorySpinner.getSelectedItemPosition();
        int levelPosition = levelSpinner.getSelectedItemPosition();
        
        // Level filter
        if (levelPosition == 0) {
            // Recommended
            videos = videoManager.getRecommendedVideos(currentUser.getLevel());
        } else if (levelPosition == 1) {
            videos = videoManager.getVideosForLevel(VideoTutorial.Level.BEGINNER);
        } else if (levelPosition == 2) {
            videos = videoManager.getVideosForLevel(VideoTutorial.Level.INTERMEDIATE);
        } else if (levelPosition == 3) {
            videos = videoManager.getVideosForLevel(VideoTutorial.Level.ADVANCED);
        } else {
            // All levels - get all videos
            videos.addAll(videoManager.getVideosForLevel(VideoTutorial.Level.BEGINNER));
            videos.addAll(videoManager.getVideosForLevel(VideoTutorial.Level.INTERMEDIATE));
            videos.addAll(videoManager.getVideosForLevel(VideoTutorial.Level.ADVANCED));
        }
        
        // Category filter
        if (categoryPosition > 0) {
            VideoTutorial.Category category = null;
            switch (categoryPosition) {
                case 1: category = VideoTutorial.Category.TECHNIQUE; break;
                case 2: category = VideoTutorial.Category.FITNESS; break;
                case 3: category = VideoTutorial.Category.TACTICS; break;
                case 4: category = VideoTutorial.Category.MENTAL; break;
                case 5: category = VideoTutorial.Category.DRILLS; break;
            }
            
            if (category != null) {
                List<VideoTutorial> filtered = new ArrayList<>();
                for (VideoTutorial video : videos) {
                    if (video.getCategory() == category) {
                        filtered.add(video);
                    }
                }
                videos = filtered;
            }
        }
        
        updateVideoList(videos);
    }
    
    private void updateVideoList(List<VideoTutorial> videos) {
        adapter.setVideos(videos);
        
        if (videos.isEmpty()) {
            recyclerView.setVisibility(View.GONE);
            emptyText.setVisibility(View.VISIBLE);
        } else {
            recyclerView.setVisibility(View.VISIBLE);
            emptyText.setVisibility(View.GONE);
        }
    }
    
    @Override
    public void onVideoClick(VideoTutorial video) {
        // Play video
        videoManager.playVideo(video);
        
        // Update view count
        video.incrementViewCount();
        
        // Show toast
        Toast.makeText(this, "비디오 재생: " + video.getTitle(), Toast.LENGTH_SHORT).show();
    }
    
    @Override
    public void onFavoriteClick(VideoTutorial video) {
        video.setFavorite(!video.isFavorite());
        adapter.notifyDataSetChanged();
        
        String message = video.isFavorite() ? "즐겨찾기에 추가됨" : "즐겨찾기에서 제거됨";
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }
}
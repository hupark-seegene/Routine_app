package com.squashtrainingapp.ui.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.squashtrainingapp.R;
import com.squashtrainingapp.models.VideoTutorial;

import java.util.ArrayList;
import java.util.List;

public class VideoTutorialAdapter extends RecyclerView.Adapter<VideoTutorialAdapter.VideoViewHolder> {
    
    private List<VideoTutorial> videos = new ArrayList<>();
    private VideoClickListener listener;
    
    public interface VideoClickListener {
        void onVideoClick(VideoTutorial video);
        void onFavoriteClick(VideoTutorial video);
    }
    
    public VideoTutorialAdapter(VideoClickListener listener) {
        this.listener = listener;
    }
    
    public void setVideos(List<VideoTutorial> videos) {
        this.videos = videos;
        notifyDataSetChanged();
    }
    
    @NonNull
    @Override
    public VideoViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.item_video_tutorial, parent, false);
        return new VideoViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull VideoViewHolder holder, int position) {
        VideoTutorial video = videos.get(position);
        holder.bind(video);
    }
    
    @Override
    public int getItemCount() {
        return videos.size();
    }
    
    class VideoViewHolder extends RecyclerView.ViewHolder {
        private ImageView thumbnailImage;
        private TextView titleText;
        private TextView descriptionText;
        private TextView durationText;
        private TextView levelText;
        private TextView categoryText;
        private ImageButton favoriteButton;
        private ImageButton playButton;
        
        VideoViewHolder(@NonNull View itemView) {
            super(itemView);
            
            thumbnailImage = itemView.findViewById(R.id.thumbnail_image);
            titleText = itemView.findViewById(R.id.title_text);
            descriptionText = itemView.findViewById(R.id.description_text);
            durationText = itemView.findViewById(R.id.duration_text);
            levelText = itemView.findViewById(R.id.level_text);
            categoryText = itemView.findViewById(R.id.category_text);
            favoriteButton = itemView.findViewById(R.id.favorite_button);
            playButton = itemView.findViewById(R.id.play_button);
        }
        
        void bind(VideoTutorial video) {
            titleText.setText(video.getTitle());
            descriptionText.setText(video.getDescription());
            durationText.setText(video.getDuration());
            
            // Level and category with icons
            levelText.setText(video.getLevelIcon() + " " + video.getLevel().getKorean());
            categoryText.setText(video.getCategoryIcon() + " " + video.getCategory().getKorean());
            
            // Favorite button
            favoriteButton.setImageResource(
                video.isFavorite() ? R.drawable.ic_favorite_filled : R.drawable.ic_favorite_outline
            );
            
            // Click listeners
            itemView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onVideoClick(video);
                }
            });
            
            playButton.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onVideoClick(video);
                }
            });
            
            favoriteButton.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onFavoriteClick(video);
                }
            });
            
            // Set thumbnail placeholder
            thumbnailImage.setImageResource(R.drawable.video_placeholder);
        }
    }
}
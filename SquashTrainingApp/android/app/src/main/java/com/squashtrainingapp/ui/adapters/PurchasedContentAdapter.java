package com.squashtrainingapp.ui.adapters;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;
import com.squashtrainingapp.R;
import com.squashtrainingapp.marketplace.MarketplaceService;
import com.squashtrainingapp.ui.activities.ContentDetailActivity;

import java.util.List;

public class PurchasedContentAdapter extends RecyclerView.Adapter<PurchasedContentAdapter.ViewHolder> {
    
    private List<MarketplaceService.MarketplaceContent> contents;
    
    public PurchasedContentAdapter(List<MarketplaceService.MarketplaceContent> contents) {
        this.contents = contents;
    }
    
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_purchased_content, parent, false);
        return new ViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.bind(contents.get(position));
    }
    
    @Override
    public int getItemCount() {
        return contents.size();
    }
    
    public void updateData(List<MarketplaceService.MarketplaceContent> newContents) {
        this.contents = newContents;
        notifyDataSetChanged();
    }
    
    class ViewHolder extends RecyclerView.ViewHolder {
        private CardView cardView;
        private ImageView thumbnailImage;
        private TextView titleText;
        private TextView typeText;
        private TextView descriptionText;
        private MaterialButton viewButton;
        private MaterialButton downloadButton;
        
        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            
            cardView = itemView.findViewById(R.id.card_view);
            thumbnailImage = itemView.findViewById(R.id.thumbnail_image);
            titleText = itemView.findViewById(R.id.title_text);
            typeText = itemView.findViewById(R.id.type_text);
            descriptionText = itemView.findViewById(R.id.description_text);
            viewButton = itemView.findViewById(R.id.view_button);
            downloadButton = itemView.findViewById(R.id.download_button);
        }
        
        public void bind(MarketplaceService.MarketplaceContent content) {
            titleText.setText(content.title);
            typeText.setText(getTypeText(content.type));
            descriptionText.setText(content.description);
            
            // Set thumbnail placeholder
            setThumbnailPlaceholder(content.type);
            
            // View button
            viewButton.setOnClickListener(v -> {
                Intent intent = new Intent(itemView.getContext(), ContentDetailActivity.class);
                intent.putExtra("content_id", content.id);
                intent.putExtra("is_purchased", true);
                itemView.getContext().startActivity(intent);
            });
            
            // Download button (for offline access)
            downloadButton.setOnClickListener(v -> {
                // In a real app, this would download the content for offline access
            });
        }
        
        private String getTypeText(MarketplaceService.ContentType type) {
            switch (type) {
                case TRAINING_PROGRAM:
                    return "트레이닝 프로그램";
                case DRILL_COLLECTION:
                    return "드릴 모음";
                case VIDEO_TUTORIAL:
                    return "비디오 튜토리얼";
                case TECHNIQUE_GUIDE:
                    return "기술 가이드";
                case NUTRITION_PLAN:
                    return "영양 계획";
                case FITNESS_ROUTINE:
                    return "체력 루틴";
                case MATCH_ANALYSIS:
                    return "경기 분석";
                case AUDIO_COACHING:
                    return "오디오 코칭";
                default:
                    return "기타";
            }
        }
        
        private void setThumbnailPlaceholder(MarketplaceService.ContentType type) {
            int drawableId;
            switch (type) {
                case VIDEO_TUTORIAL:
                    drawableId = R.drawable.ic_video_placeholder;
                    break;
                case AUDIO_COACHING:
                    drawableId = R.drawable.ic_audio_placeholder;
                    break;
                case NUTRITION_PLAN:
                    drawableId = R.drawable.ic_nutrition_placeholder;
                    break;
                default:
                    drawableId = R.drawable.ic_content_placeholder;
                    break;
            }
            thumbnailImage.setImageResource(drawableId);
        }
    }
}
package com.squashtrainingapp.ui.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;
import com.squashtrainingapp.R;
import com.squashtrainingapp.marketplace.MarketplaceService;

import java.util.List;

public class MarketplaceContentAdapter extends RecyclerView.Adapter<MarketplaceContentAdapter.ContentViewHolder> {
    
    private List<MarketplaceService.MarketplaceContent> contents;
    private OnContentClickListener listener;
    
    public interface OnContentClickListener {
        void onContentClick(MarketplaceService.MarketplaceContent content);
        void onPurchaseClick(MarketplaceService.MarketplaceContent content);
    }
    
    public MarketplaceContentAdapter(List<MarketplaceService.MarketplaceContent> contents, 
                                   OnContentClickListener listener) {
        this.contents = contents;
        this.listener = listener;
    }
    
    @NonNull
    @Override
    public ContentViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_marketplace_content, parent, false);
        return new ContentViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ContentViewHolder holder, int position) {
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
    
    class ContentViewHolder extends RecyclerView.ViewHolder {
        private CardView cardView;
        private ImageView thumbnailImage;
        private TextView titleText;
        private TextView creatorText;
        private TextView priceText;
        private RatingBar ratingBar;
        private TextView ratingText;
        private TextView purchaseCountText;
        private MaterialButton purchaseButton;
        private TextView typeChip;
        
        public ContentViewHolder(@NonNull View itemView) {
            super(itemView);
            
            cardView = itemView.findViewById(R.id.card_view);
            thumbnailImage = itemView.findViewById(R.id.thumbnail_image);
            titleText = itemView.findViewById(R.id.title_text);
            creatorText = itemView.findViewById(R.id.creator_text);
            priceText = itemView.findViewById(R.id.price_text);
            ratingBar = itemView.findViewById(R.id.rating_bar);
            ratingText = itemView.findViewById(R.id.rating_text);
            purchaseCountText = itemView.findViewById(R.id.purchase_count_text);
            purchaseButton = itemView.findViewById(R.id.purchase_button);
            typeChip = itemView.findViewById(R.id.type_chip);
        }
        
        public void bind(MarketplaceService.MarketplaceContent content) {
            titleText.setText(content.title);
            creatorText.setText(content.creatorName != null ? content.creatorName : "Creator");
            priceText.setText(content.getFormattedPrice());
            
            ratingBar.setRating(content.averageRating);
            ratingText.setText(String.format("%.1f", content.averageRating));
            purchaseCountText.setText(content.purchaseCount + " 구매");
            
            // Set type chip
            String typeText = getTypeText(content.type);
            typeChip.setText(typeText);
            
            // Set thumbnail placeholder based on type
            setThumbnailPlaceholder(content.type);
            
            // Purchase button
            if (content.priceInCents == 0) {
                purchaseButton.setText("무료 다운로드");
            } else {
                purchaseButton.setText(content.getFormattedPrice());
            }
            
            // Click listeners
            cardView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onContentClick(content);
                }
            });
            
            purchaseButton.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onPurchaseClick(content);
                }
            });
        }
        
        private String getTypeText(MarketplaceService.ContentType type) {
            switch (type) {
                case TRAINING_PROGRAM:
                    return "프로그램";
                case DRILL_COLLECTION:
                    return "드릴";
                case VIDEO_TUTORIAL:
                    return "비디오";
                case TECHNIQUE_GUIDE:
                    return "가이드";
                case NUTRITION_PLAN:
                    return "영양";
                case FITNESS_ROUTINE:
                    return "체력";
                case MATCH_ANALYSIS:
                    return "경기분석";
                case AUDIO_COACHING:
                    return "오디오";
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
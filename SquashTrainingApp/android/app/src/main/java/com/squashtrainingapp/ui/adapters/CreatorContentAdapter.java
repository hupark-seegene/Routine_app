package com.squashtrainingapp.ui.adapters;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.chip.Chip;
import com.squashtrainingapp.R;
import com.squashtrainingapp.marketplace.MarketplaceService;
import com.squashtrainingapp.ui.activities.ContentStatsActivity;
import com.squashtrainingapp.ui.activities.EditContentActivity;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class CreatorContentAdapter extends RecyclerView.Adapter<CreatorContentAdapter.ViewHolder> {
    
    private List<MarketplaceService.MarketplaceContent> contents;
    private SimpleDateFormat dateFormat;
    
    public CreatorContentAdapter(List<MarketplaceService.MarketplaceContent> contents) {
        this.contents = contents;
        this.dateFormat = new SimpleDateFormat("yyyy.MM.dd", Locale.getDefault());
    }
    
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_creator_content, parent, false);
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
        private TextView titleText;
        private Chip statusChip;
        private TextView priceText;
        private TextView purchaseCountText;
        private TextView ratingText;
        private TextView createdDateText;
        private MaterialButton editButton;
        private MaterialButton statsButton;
        
        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            
            cardView = itemView.findViewById(R.id.card_view);
            titleText = itemView.findViewById(R.id.title_text);
            statusChip = itemView.findViewById(R.id.status_chip);
            priceText = itemView.findViewById(R.id.price_text);
            purchaseCountText = itemView.findViewById(R.id.purchase_count_text);
            ratingText = itemView.findViewById(R.id.rating_text);
            createdDateText = itemView.findViewById(R.id.created_date_text);
            editButton = itemView.findViewById(R.id.edit_button);
            statsButton = itemView.findViewById(R.id.stats_button);
        }
        
        public void bind(MarketplaceService.MarketplaceContent content) {
            titleText.setText(content.title);
            priceText.setText(content.getFormattedPrice());
            purchaseCountText.setText(content.purchaseCount + " 판매");
            ratingText.setText(String.format("⭐ %.1f", content.averageRating));
            createdDateText.setText("생성: " + dateFormat.format(new Date(content.createdAt)));
            
            // Set status chip
            setStatusChip(content.status);
            
            // Edit button
            editButton.setOnClickListener(v -> {
                Intent intent = new Intent(itemView.getContext(), EditContentActivity.class);
                intent.putExtra("content_id", content.id);
                itemView.getContext().startActivity(intent);
            });
            
            // Stats button
            statsButton.setOnClickListener(v -> {
                Intent intent = new Intent(itemView.getContext(), ContentStatsActivity.class);
                intent.putExtra("content_id", content.id);
                itemView.getContext().startActivity(intent);
            });
        }
        
        private void setStatusChip(MarketplaceService.ContentStatus status) {
            switch (status) {
                case DRAFT:
                    statusChip.setText("초안");
                    statusChip.setChipBackgroundColorResource(R.color.chip_draft);
                    break;
                case PENDING_REVIEW:
                    statusChip.setText("검토 중");
                    statusChip.setChipBackgroundColorResource(R.color.chip_pending);
                    break;
                case APPROVED:
                    statusChip.setText("승인됨");
                    statusChip.setChipBackgroundColorResource(R.color.chip_approved);
                    break;
                case REJECTED:
                    statusChip.setText("거절됨");
                    statusChip.setChipBackgroundColorResource(R.color.chip_rejected);
                    break;
                case ARCHIVED:
                    statusChip.setText("보관됨");
                    statusChip.setChipBackgroundColorResource(R.color.chip_archived);
                    break;
            }
        }
    }
}
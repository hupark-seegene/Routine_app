package com.squashtrainingapp.ui.adapters;

import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;

import com.squashtrainingapp.R;
import com.squashtrainingapp.social.LeaderboardService;

import java.util.ArrayList;
import java.util.List;

public class LeaderboardAdapter extends RecyclerView.Adapter<LeaderboardAdapter.LeaderboardViewHolder> {
    
    private List<LeaderboardService.LeaderboardEntry> entries = new ArrayList<>();
    
    public void setEntries(List<LeaderboardService.LeaderboardEntry> entries) {
        this.entries = entries;
        notifyDataSetChanged();
    }
    
    @NonNull
    @Override
    public LeaderboardViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_leaderboard_entry, parent, false);
        return new LeaderboardViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull LeaderboardViewHolder holder, int position) {
        LeaderboardService.LeaderboardEntry entry = entries.get(position);
        
        // Rank
        holder.rankText.setText(String.valueOf(entry.rank));
        
        // Special styling for top 3
        if (entry.rank <= 3) {
            holder.rankText.setTextSize(24);
            holder.rankText.setTypeface(null, Typeface.BOLD);
            
            // Medal colors
            switch (entry.rank) {
                case 1:
                    holder.rankText.setTextColor(holder.itemView.getContext().getColor(R.color.gold));
                    holder.medalIcon.setVisibility(View.VISIBLE);
                    holder.medalIcon.setImageResource(R.drawable.ic_medal_gold);
                    break;
                case 2:
                    holder.rankText.setTextColor(holder.itemView.getContext().getColor(R.color.silver));
                    holder.medalIcon.setVisibility(View.VISIBLE);
                    holder.medalIcon.setImageResource(R.drawable.ic_medal_silver);
                    break;
                case 3:
                    holder.rankText.setTextColor(holder.itemView.getContext().getColor(R.color.bronze));
                    holder.medalIcon.setVisibility(View.VISIBLE);
                    holder.medalIcon.setImageResource(R.drawable.ic_medal_bronze);
                    break;
            }
        } else {
            holder.rankText.setTextSize(18);
            holder.rankText.setTypeface(null, Typeface.NORMAL);
            holder.rankText.setTextColor(holder.itemView.getContext().getColor(R.color.text_secondary));
            holder.medalIcon.setVisibility(View.GONE);
        }
        
        // User info
        holder.nameText.setText(entry.displayName);
        holder.levelText.setText("Lv. " + getLevelNumber(entry.level));
        
        // Value
        holder.valueText.setText(formatValue(entry.value));
        
        // Highlight current user
        if (entry.isCurrentUser) {
            holder.cardView.setCardBackgroundColor(
                holder.itemView.getContext().getColor(R.color.accent_light)
            );
        } else {
            holder.cardView.setCardBackgroundColor(
                holder.itemView.getContext().getColor(R.color.bg_secondary)
            );
        }
        
        // Profile picture (placeholder for now)
        holder.profileImage.setImageResource(R.drawable.ic_profile_placeholder);
    }
    
    @Override
    public int getItemCount() {
        return entries.size();
    }
    
    private String formatValue(int value) {
        if (value >= 1000000) {
            return String.format("%.1fM", value / 1000000.0);
        } else if (value >= 1000) {
            return String.format("%.1fK", value / 1000.0);
        }
        return String.valueOf(value);
    }
    
    private int getLevelNumber(String level) {
        switch (level.toLowerCase()) {
            case "beginner":
                return 1;
            case "intermediate":
                return 2;
            case "advanced":
                return 3;
            case "expert":
                return 4;
            case "master":
                return 5;
            default:
                return 1;
        }
    }
    
    static class LeaderboardViewHolder extends RecyclerView.ViewHolder {
        CardView cardView;
        TextView rankText;
        ImageView medalIcon;
        ImageView profileImage;
        TextView nameText;
        TextView levelText;
        TextView valueText;
        
        LeaderboardViewHolder(@NonNull View itemView) {
            super(itemView);
            cardView = itemView.findViewById(R.id.card_view);
            rankText = itemView.findViewById(R.id.rank_text);
            medalIcon = itemView.findViewById(R.id.medal_icon);
            profileImage = itemView.findViewById(R.id.profile_image);
            nameText = itemView.findViewById(R.id.name_text);
            levelText = itemView.findViewById(R.id.level_text);
            valueText = itemView.findViewById(R.id.value_text);
        }
    }
}
package com.squashtrainingapp.ui.adapters;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;

import com.squashtrainingapp.R;
import com.squashtrainingapp.models.Achievement;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class AchievementAdapter extends RecyclerView.Adapter<AchievementAdapter.AchievementViewHolder> {
    
    private List<Achievement> achievements = new ArrayList<>();
    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy.MM.dd", Locale.getDefault());
    
    public void setAchievements(List<Achievement> achievements) {
        this.achievements = achievements;
        notifyDataSetChanged();
    }
    
    @NonNull
    @Override
    public AchievementViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.item_achievement, parent, false);
        return new AchievementViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull AchievementViewHolder holder, int position) {
        Achievement achievement = achievements.get(position);
        holder.bind(achievement);
    }
    
    @Override
    public int getItemCount() {
        return achievements.size();
    }
    
    class AchievementViewHolder extends RecyclerView.ViewHolder {
        private CardView cardView;
        private TextView iconText;
        private TextView rankIcon;
        private TextView nameText;
        private TextView descriptionText;
        private TextView progressText;
        private ProgressBar progressBar;
        private TextView pointsText;
        private TextView dateText;
        private View lockedOverlay;
        
        AchievementViewHolder(@NonNull View itemView) {
            super(itemView);
            
            cardView = (CardView) itemView;
            iconText = itemView.findViewById(R.id.achievement_icon);
            rankIcon = itemView.findViewById(R.id.rank_icon);
            nameText = itemView.findViewById(R.id.achievement_name);
            descriptionText = itemView.findViewById(R.id.achievement_description);
            progressText = itemView.findViewById(R.id.progress_text);
            progressBar = itemView.findViewById(R.id.progress_bar);
            pointsText = itemView.findViewById(R.id.points_text);
            dateText = itemView.findViewById(R.id.date_text);
            lockedOverlay = itemView.findViewById(R.id.locked_overlay);
        }
        
        void bind(Achievement achievement) {
            // Icons
            iconText.setText(achievement.getIconEmoji());
            rankIcon.setText(achievement.getRankIcon());
            
            // Text
            nameText.setText(achievement.getName());
            descriptionText.setText(achievement.getDescription());
            pointsText.setText("+" + achievement.getPoints() + "P");
            
            // Progress
            if (achievement.isUnlocked()) {
                progressText.setText("완료!");
                progressBar.setProgress(100);
                dateText.setVisibility(View.VISIBLE);
                dateText.setText(dateFormat.format(new Date(achievement.getUnlockedDate())));
                lockedOverlay.setVisibility(View.GONE);
                
                // Rank color for card background
                String colorStr = achievement.getRank().getColor();
                int color = Color.parseColor(colorStr);
                cardView.setCardBackgroundColor(adjustColorAlpha(color, 30));
            } else {
                progressText.setText(achievement.getProgressText());
                progressBar.setProgress((int) achievement.getProgressPercentage());
                dateText.setVisibility(View.GONE);
                lockedOverlay.setVisibility(View.VISIBLE);
                cardView.setCardBackgroundColor(itemView.getContext().getColor(R.color.dark_surface));
            }
        }
        
        private int adjustColorAlpha(int color, int alpha) {
            return Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color));
        }
    }
}
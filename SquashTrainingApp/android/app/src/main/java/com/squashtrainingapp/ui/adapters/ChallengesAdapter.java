package com.squashtrainingapp.ui.adapters;

import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.chip.Chip;
import com.squashtrainingapp.R;
import com.squashtrainingapp.social.ChallengeService;

import java.util.ArrayList;
import java.util.List;

public class ChallengesAdapter extends RecyclerView.Adapter<ChallengesAdapter.ChallengeViewHolder> {
    
    private List<ChallengeService.Challenge> challenges = new ArrayList<>();
    private ChallengeClickListener listener;
    
    public interface ChallengeClickListener {
        void onChallengeClick(ChallengeService.Challenge challenge);
        void onJoinChallenge(ChallengeService.Challenge challenge);
    }
    
    public ChallengesAdapter(ChallengeClickListener listener) {
        this.listener = listener;
    }
    
    public void setChallenges(List<ChallengeService.Challenge> challenges) {
        this.challenges = challenges;
        notifyDataSetChanged();
    }
    
    @NonNull
    @Override
    public ChallengeViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_challenge, parent, false);
        return new ChallengeViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ChallengeViewHolder holder, int position) {
        ChallengeService.Challenge challenge = challenges.get(position);
        
        // Title and description
        holder.titleText.setText(challenge.title);
        holder.descriptionText.setText(challenge.description);
        
        // Type chip
        holder.typeChip.setText(getTypeText(challenge.type));
        
        // Time remaining
        long timeRemaining = challenge.endTime - System.currentTimeMillis();
        if (timeRemaining > 0) {
            holder.timeRemainingText.setText("남은 시간: " + 
                DateUtils.getRelativeTimeSpanString(challenge.endTime));
        } else {
            holder.timeRemainingText.setText("종료됨");
        }
        
        // Reward
        holder.rewardText.setText(challenge.rewardPoints + " 포인트");
        
        // Participants
        holder.participantsText.setText(challenge.participantCount + "명 참여중");
        
        // Progress (if user is participating)
        // This would be fetched from user's challenge data
        holder.progressBar.setVisibility(View.GONE);
        holder.progressText.setVisibility(View.GONE);
        
        // Join button
        holder.joinButton.setOnClickListener(v -> {
            if (listener != null) {
                listener.onJoinChallenge(challenge);
            }
        });
        
        // Card click
        holder.cardView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onChallengeClick(challenge);
            }
        });
        
        // Team badge
        if (challenge.isTeamChallenge) {
            holder.teamBadge.setVisibility(View.VISIBLE);
        } else {
            holder.teamBadge.setVisibility(View.GONE);
        }
    }
    
    @Override
    public int getItemCount() {
        return challenges.size();
    }
    
    private String getTypeText(ChallengeService.ChallengeType type) {
        switch (type) {
            case DAILY_WORKOUT:
                return "일일 운동";
            case WEEKLY_STREAK:
                return "주간 연속";
            case CALORIE_BURN:
                return "칼로리 소모";
            case SESSION_DURATION:
                return "운동 시간";
            case SKILL_CHALLENGE:
                return "기술 도전";
            case TEAM_CHALLENGE:
                return "팀 대결";
            case TOURNAMENT:
                return "토너먼트";
            default:
                return "챌린지";
        }
    }
    
    static class ChallengeViewHolder extends RecyclerView.ViewHolder {
        CardView cardView;
        TextView titleText;
        TextView descriptionText;
        Chip typeChip;
        TextView timeRemainingText;
        TextView rewardText;
        TextView participantsText;
        ProgressBar progressBar;
        TextView progressText;
        MaterialButton joinButton;
        TextView teamBadge;
        
        ChallengeViewHolder(@NonNull View itemView) {
            super(itemView);
            cardView = itemView.findViewById(R.id.card_view);
            titleText = itemView.findViewById(R.id.title_text);
            descriptionText = itemView.findViewById(R.id.description_text);
            typeChip = itemView.findViewById(R.id.type_chip);
            timeRemainingText = itemView.findViewById(R.id.time_remaining_text);
            rewardText = itemView.findViewById(R.id.reward_text);
            participantsText = itemView.findViewById(R.id.participants_text);
            progressBar = itemView.findViewById(R.id.progress_bar);
            progressText = itemView.findViewById(R.id.progress_text);
            joinButton = itemView.findViewById(R.id.join_button);
            teamBadge = itemView.findViewById(R.id.team_badge);
        }
    }
}
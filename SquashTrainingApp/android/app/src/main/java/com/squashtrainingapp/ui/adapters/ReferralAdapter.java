package com.squashtrainingapp.ui.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.chip.Chip;
import com.squashtrainingapp.R;
import com.squashtrainingapp.marketing.ReferralService;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class ReferralAdapter extends RecyclerView.Adapter<ReferralAdapter.ReferralViewHolder> {
    
    private List<ReferralService.Referral> referrals;
    private SimpleDateFormat dateFormat;
    
    public ReferralAdapter(List<ReferralService.Referral> referrals) {
        this.referrals = referrals;
        this.dateFormat = new SimpleDateFormat("yyyy.MM.dd", Locale.getDefault());
    }
    
    @NonNull
    @Override
    public ReferralViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_referral, parent, false);
        return new ReferralViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ReferralViewHolder holder, int position) {
        holder.bind(referrals.get(position));
    }
    
    @Override
    public int getItemCount() {
        return referrals.size();
    }
    
    public void updateData(List<ReferralService.Referral> newReferrals) {
        this.referrals = newReferrals;
        notifyDataSetChanged();
    }
    
    class ReferralViewHolder extends RecyclerView.ViewHolder {
        private ImageView profileImage;
        private TextView nameText;
        private TextView emailText;
        private TextView dateText;
        private Chip statusChip;
        private ImageView rewardIcon;
        
        public ReferralViewHolder(@NonNull View itemView) {
            super(itemView);
            
            profileImage = itemView.findViewById(R.id.profile_image);
            nameText = itemView.findViewById(R.id.name_text);
            emailText = itemView.findViewById(R.id.email_text);
            dateText = itemView.findViewById(R.id.date_text);
            statusChip = itemView.findViewById(R.id.status_chip);
            rewardIcon = itemView.findViewById(R.id.reward_icon);
        }
        
        public void bind(ReferralService.Referral referral) {
            // Set name and email
            nameText.setText(referral.refereeName != null ? referral.refereeName : "신규 사용자");
            
            if (referral.refereeEmail != null) {
                emailText.setText(maskEmail(referral.refereeEmail));
                emailText.setVisibility(View.VISIBLE);
            } else {
                emailText.setVisibility(View.GONE);
            }
            
            // Set date
            dateText.setText("가입일: " + dateFormat.format(new Date(referral.createdAt)));
            
            // Set status
            updateStatusChip(referral.status);
            
            // Show reward icon if rewarded
            rewardIcon.setVisibility(referral.referrerRewarded ? View.VISIBLE : View.GONE);
            
            // Set profile placeholder
            profileImage.setImageResource(R.drawable.ic_profile_placeholder);
        }
        
        private void updateStatusChip(ReferralService.ReferralStatus status) {
            switch (status) {
                case PENDING:
                    statusChip.setText("대기중");
                    statusChip.setChipBackgroundColorResource(R.color.chip_pending);
                    break;
                case COMPLETED:
                    statusChip.setText("가입완료");
                    statusChip.setChipBackgroundColorResource(R.color.chip_approved);
                    break;
                case REWARDED:
                    statusChip.setText("보상지급");
                    statusChip.setChipBackgroundColorResource(R.color.gold);
                    break;
            }
        }
        
        private String maskEmail(String email) {
            if (email == null || !email.contains("@")) return email;
            
            String[] parts = email.split("@");
            if (parts[0].length() <= 3) {
                return "***@" + parts[1];
            }
            
            String username = parts[0];
            String masked = username.substring(0, 3) + "***";
            return masked + "@" + parts[1];
        }
    }
}
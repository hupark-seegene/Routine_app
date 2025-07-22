package com.squashtrainingapp.ui.adapters;

import android.text.format.DateUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;

import com.squashtrainingapp.R;
import com.squashtrainingapp.ui.activities.PremiumCoachActivity;

import java.util.List;

public class ChatMessageAdapter extends RecyclerView.Adapter<ChatMessageAdapter.MessageViewHolder> {
    
    private List<PremiumCoachActivity.ChatMessage> messages;
    
    public ChatMessageAdapter(List<PremiumCoachActivity.ChatMessage> messages) {
        this.messages = messages;
    }
    
    @NonNull
    @Override
    public MessageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_chat_message, parent, false);
        return new MessageViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull MessageViewHolder holder, int position) {
        PremiumCoachActivity.ChatMessage message = messages.get(position);
        
        holder.messageText.setText(message.message);
        
        // Format timestamp
        String timeString = DateUtils.formatDateTime(
            holder.itemView.getContext(),
            message.timestamp,
            DateUtils.FORMAT_SHOW_TIME
        );
        holder.timeText.setText(timeString);
        
        // Adjust layout based on sender
        LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) holder.messageCard.getLayoutParams();
        
        if (message.isUser) {
            // User message - align right
            params.gravity = Gravity.END;
            params.setMargins(100, 8, 16, 8);
            holder.messageCard.setCardBackgroundColor(
                holder.itemView.getContext().getColor(R.color.accent)
            );
            holder.messageText.setTextColor(
                holder.itemView.getContext().getColor(android.R.color.white)
            );
            holder.timeText.setTextColor(
                holder.itemView.getContext().getColor(android.R.color.white)
            );
        } else {
            // AI message - align left
            params.gravity = Gravity.START;
            params.setMargins(16, 8, 100, 8);
            holder.messageCard.setCardBackgroundColor(
                holder.itemView.getContext().getColor(R.color.bg_secondary)
            );
            holder.messageText.setTextColor(
                holder.itemView.getContext().getColor(R.color.text_primary)
            );
            holder.timeText.setTextColor(
                holder.itemView.getContext().getColor(R.color.text_secondary)
            );
        }
        
        holder.messageCard.setLayoutParams(params);
    }
    
    @Override
    public int getItemCount() {
        return messages.size();
    }
    
    static class MessageViewHolder extends RecyclerView.ViewHolder {
        CardView messageCard;
        TextView messageText;
        TextView timeText;
        
        MessageViewHolder(@NonNull View itemView) {
            super(itemView);
            messageCard = itemView.findViewById(R.id.message_card);
            messageText = itemView.findViewById(R.id.message_text);
            timeText = itemView.findViewById(R.id.time_text);
        }
    }
}
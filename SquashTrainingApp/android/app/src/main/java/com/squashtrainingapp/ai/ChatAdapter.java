package com.squashtrainingapp.ai;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.squashtrainingapp.R;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class ChatAdapter extends RecyclerView.Adapter<ChatAdapter.MessageViewHolder> {
    private List<ChatMessage> messages;
    private SimpleDateFormat timeFormat;
    
    public ChatAdapter() {
        this.messages = new ArrayList<>();
        this.timeFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
    }
    
    @NonNull
    @Override
    public MessageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view;
        if (viewType == ChatMessage.MessageType.USER.ordinal()) {
            view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_chat_user, parent, false);
        } else {
            view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_chat_ai, parent, false);
        }
        return new MessageViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull MessageViewHolder holder, int position) {
        ChatMessage message = messages.get(position);
        holder.messageText.setText(message.getMessage());
        holder.timeText.setText(timeFormat.format(new Date(message.getTimestamp())));
    }
    
    @Override
    public int getItemCount() {
        return messages.size();
    }
    
    @Override
    public int getItemViewType(int position) {
        return messages.get(position).getType().ordinal();
    }
    
    public void addMessage(ChatMessage message) {
        messages.add(message);
        notifyItemInserted(messages.size() - 1);
    }
    
    public void clearMessages() {
        messages.clear();
        notifyDataSetChanged();
    }
    
    static class MessageViewHolder extends RecyclerView.ViewHolder {
        TextView messageText;
        TextView timeText;
        
        MessageViewHolder(View itemView) {
            super(itemView);
            messageText = itemView.findViewById(R.id.message_text);
            timeText = itemView.findViewById(R.id.time_text);
        }
    }
}
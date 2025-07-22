package com.squashtrainingapp.ui.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.squashtrainingapp.R;
import com.squashtrainingapp.models.ChatMessage;

import java.util.ArrayList;
import java.util.List;

public class ChatAdapter extends RecyclerView.Adapter<ChatAdapter.ChatViewHolder> {
    
    private List<ChatMessage> messages = new ArrayList<>();
    
    public void addMessage(ChatMessage message) {
        messages.add(message);
        notifyItemInserted(messages.size() - 1);
    }
    
    public void clearMessages() {
        messages.clear();
        notifyDataSetChanged();
    }
    
    @NonNull
    @Override
    public ChatViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_chat_message, parent, false);
        return new ChatViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ChatViewHolder holder, int position) {
        ChatMessage message = messages.get(position);
        holder.bind(message);
    }
    
    @Override
    public int getItemCount() {
        return messages.size();
    }
    
    static class ChatViewHolder extends RecyclerView.ViewHolder {
        private final LinearLayout userContainer;
        private final LinearLayout aiContainer;
        private final TextView userMessageText;
        private final TextView aiMessageText;
        
        public ChatViewHolder(@NonNull View itemView) {
            super(itemView);
            userContainer = itemView.findViewById(R.id.user_message_container);
            aiContainer = itemView.findViewById(R.id.ai_message_container);
            userMessageText = itemView.findViewById(R.id.user_message_text);
            aiMessageText = itemView.findViewById(R.id.ai_message_text);
        }
        
        public void bind(ChatMessage message) {
            if (message.isUser()) {
                userContainer.setVisibility(View.VISIBLE);
                aiContainer.setVisibility(View.GONE);
                userMessageText.setText(message.getMessage());
            } else {
                userContainer.setVisibility(View.GONE);
                aiContainer.setVisibility(View.VISIBLE);
                aiMessageText.setText(message.getMessage());
            }
        }
    }
}
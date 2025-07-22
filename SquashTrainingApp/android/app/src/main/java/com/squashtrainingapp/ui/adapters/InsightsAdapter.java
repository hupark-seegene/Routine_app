package com.squashtrainingapp.ui.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.squashtrainingapp.R;

import java.util.List;

public class InsightsAdapter extends RecyclerView.Adapter<InsightsAdapter.InsightViewHolder> {
    
    private List<String> insights;
    
    public InsightsAdapter(List<String> insights) {
        this.insights = insights;
    }
    
    @NonNull
    @Override
    public InsightViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_insight, parent, false);
        return new InsightViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull InsightViewHolder holder, int position) {
        holder.bind(insights.get(position));
    }
    
    @Override
    public int getItemCount() {
        return insights.size();
    }
    
    public void updateData(List<String> newInsights) {
        this.insights = newInsights;
        notifyDataSetChanged();
    }
    
    static class InsightViewHolder extends RecyclerView.ViewHolder {
        private TextView insightText;
        
        public InsightViewHolder(@NonNull View itemView) {
            super(itemView);
            insightText = itemView.findViewById(R.id.insight_text);
        }
        
        public void bind(String insight) {
            insightText.setText(insight);
        }
    }
}
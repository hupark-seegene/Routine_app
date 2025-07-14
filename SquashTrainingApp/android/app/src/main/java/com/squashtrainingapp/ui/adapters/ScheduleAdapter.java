package com.squashtrainingapp.ui.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.squashtrainingapp.R;
import com.squashtrainingapp.models.WorkoutSession;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

public class ScheduleAdapter extends RecyclerView.Adapter<ScheduleAdapter.ViewHolder> {
    
    private List<WorkoutSession> sessions;
    private Context context;
    private SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd", Locale.getDefault());
    private SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
    
    public ScheduleAdapter(List<WorkoutSession> sessions, Context context) {
        this.sessions = sessions;
        this.context = context;
    }
    
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_schedule, parent, false);
        return new ViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        WorkoutSession session = sessions.get(position);
        
        holder.sessionName.setText(session.getSessionName());
        holder.dateText.setText(dateFormat.format(session.getScheduledDate()));
        holder.timeText.setText(timeFormat.format(session.getScheduledDate()));
        holder.durationText.setText(session.getDurationMinutes() + " MIN");
        
        // Set status color
        switch (session.getStatus()) {
            case "completed":
                holder.statusIndicator.setBackgroundResource(R.color.success);
                break;
            case "cancelled":
                holder.statusIndicator.setBackgroundResource(R.color.error);
                break;
            default:
                holder.statusIndicator.setBackgroundResource(R.color.volt_green);
                break;
        }
    }
    
    @Override
    public int getItemCount() {
        return sessions.size();
    }
    
    public void updateSessions(List<WorkoutSession> newSessions) {
        this.sessions = newSessions;
        notifyDataSetChanged();
    }
    
    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView sessionName;
        TextView dateText;
        TextView timeText;
        TextView durationText;
        View statusIndicator;
        
        ViewHolder(View view) {
            super(view);
            sessionName = view.findViewById(R.id.session_name);
            dateText = view.findViewById(R.id.date_text);
            timeText = view.findViewById(R.id.time_text);
            durationText = view.findViewById(R.id.duration_text);
            statusIndicator = view.findViewById(R.id.status_indicator);
        }
    }
}
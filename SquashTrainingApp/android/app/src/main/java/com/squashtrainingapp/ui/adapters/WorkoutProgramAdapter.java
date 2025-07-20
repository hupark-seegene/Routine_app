package com.squashtrainingapp.ui.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.squashtrainingapp.R;
import com.squashtrainingapp.models.WorkoutProgram;

import java.util.ArrayList;
import java.util.List;

public class WorkoutProgramAdapter extends RecyclerView.Adapter<WorkoutProgramAdapter.ProgramViewHolder> {
    
    private List<WorkoutProgram> programs = new ArrayList<>();
    private ProgramClickListener listener;
    
    public interface ProgramClickListener {
        void onProgramClick(WorkoutProgram program);
        void onProgramStart(WorkoutProgram program);
        void onProgramStop(WorkoutProgram program);
        void onProgramDelete(WorkoutProgram program);
    }
    
    public WorkoutProgramAdapter(ProgramClickListener listener) {
        this.listener = listener;
    }
    
    public void setPrograms(List<WorkoutProgram> programs) {
        this.programs = programs;
        notifyDataSetChanged();
    }
    
    @NonNull
    @Override
    public ProgramViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.item_workout_program, parent, false);
        return new ProgramViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ProgramViewHolder holder, int position) {
        WorkoutProgram program = programs.get(position);
        holder.bind(program);
    }
    
    @Override
    public int getItemCount() {
        return programs.size();
    }
    
    class ProgramViewHolder extends RecyclerView.ViewHolder {
        private TextView nameText;
        private TextView descriptionText;
        private TextView typeText;
        private TextView durationText;
        private TextView progressText;
        private ProgressBar progressBar;
        private Button actionButton;
        private ImageButton deleteButton;
        private View userCreatedIndicator;
        private View activeIndicator;
        
        ProgramViewHolder(@NonNull View itemView) {
            super(itemView);
            
            nameText = itemView.findViewById(R.id.program_name);
            descriptionText = itemView.findViewById(R.id.program_description);
            typeText = itemView.findViewById(R.id.program_type);
            durationText = itemView.findViewById(R.id.program_duration);
            progressText = itemView.findViewById(R.id.progress_text);
            progressBar = itemView.findViewById(R.id.progress_bar);
            actionButton = itemView.findViewById(R.id.action_button);
            deleteButton = itemView.findViewById(R.id.delete_button);
            userCreatedIndicator = itemView.findViewById(R.id.user_created_indicator);
            activeIndicator = itemView.findViewById(R.id.active_indicator);
        }
        
        void bind(WorkoutProgram program) {
            nameText.setText(program.getName());
            descriptionText.setText(program.getDescription());
            typeText.setText(program.getTypeIcon() + " " + program.getType().getKorean());
            durationText.setText(program.getDuration().getKorean() + " · 주 " + program.getDaysPerWeek() + "회");
            
            // Progress
            int progress = (int) program.getProgressPercentage();
            progressBar.setProgress(progress);
            progressText.setText(progress + "% 완료 (" + program.getCompletedDays() + "/" + program.getProgramDays().size() + "일)");
            
            // Indicators
            userCreatedIndicator.setVisibility(program.isUserCreated() ? View.VISIBLE : View.GONE);
            activeIndicator.setVisibility(program.isActive() ? View.VISIBLE : View.GONE);
            
            // Delete button (only for user-created)
            deleteButton.setVisibility(program.isUserCreated() ? View.VISIBLE : View.GONE);
            
            // Action button
            if (program.isActive()) {
                actionButton.setText("중단");
                actionButton.setBackgroundResource(R.drawable.button_background_secondary);
                actionButton.setOnClickListener(v -> {
                    if (listener != null) {
                        listener.onProgramStop(program);
                    }
                });
            } else {
                actionButton.setText("시작");
                actionButton.setBackgroundResource(R.drawable.button_background);
                actionButton.setOnClickListener(v -> {
                    if (listener != null) {
                        listener.onProgramStart(program);
                    }
                });
            }
            
            // Click listeners
            itemView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onProgramClick(program);
                }
            });
            
            deleteButton.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onProgramDelete(program);
                }
            });
        }
    }
}
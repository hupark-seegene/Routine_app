package com.squashtrainingapp.ui.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.squashtrainingapp.R;
import com.squashtrainingapp.models.TrainingProgram;
import java.util.List;

public class ProgramAdapter extends RecyclerView.Adapter<ProgramAdapter.ProgramViewHolder> {
    
    private List<TrainingProgram> programs;
    private OnProgramClickListener listener;
    
    public interface OnProgramClickListener {
        void onProgramClick(TrainingProgram program);
    }
    
    public ProgramAdapter(List<TrainingProgram> programs, OnProgramClickListener listener) {
        this.programs = programs;
        this.listener = listener;
    }
    
    @NonNull
    @Override
    public ProgramViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_program, parent, false);
        return new ProgramViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ProgramViewHolder holder, int position) {
        TrainingProgram program = programs.get(position);
        holder.bind(program);
    }
    
    @Override
    public int getItemCount() {
        return programs.size();
    }
    
    public void updatePrograms(List<TrainingProgram> newPrograms) {
        this.programs = newPrograms;
        notifyDataSetChanged();
    }
    
    class ProgramViewHolder extends RecyclerView.ViewHolder {
        private TextView nameText;
        private TextView descriptionText;
        private TextView durationText;
        private TextView difficultyText;
        private View difficultyIndicator;
        
        ProgramViewHolder(@NonNull View itemView) {
            super(itemView);
            nameText = itemView.findViewById(R.id.program_name);
            descriptionText = itemView.findViewById(R.id.program_description);
            durationText = itemView.findViewById(R.id.program_duration);
            difficultyText = itemView.findViewById(R.id.program_difficulty);
            difficultyIndicator = itemView.findViewById(R.id.difficulty_indicator);
            
            itemView.setOnClickListener(v -> {
                int position = getAdapterPosition();
                if (position != RecyclerView.NO_POSITION && listener != null) {
                    listener.onProgramClick(programs.get(position));
                }
            });
        }
        
        void bind(TrainingProgram program) {
            nameText.setText(program.getName());
            descriptionText.setText(program.getDescription());
            durationText.setText(program.getDurationWeeks() + " WEEKS");
            difficultyText.setText(program.getDifficulty().toUpperCase());
            
            // Set difficulty indicator color
            int indicatorColor;
            switch (program.getDifficulty().toLowerCase()) {
                case "beginner":
                    indicatorColor = itemView.getContext().getColor(R.color.success);
                    break;
                case "intermediate":
                    indicatorColor = itemView.getContext().getColor(R.color.warning);
                    break;
                case "advanced":
                    indicatorColor = itemView.getContext().getColor(R.color.error);
                    break;
                default:
                    indicatorColor = itemView.getContext().getColor(R.color.text_secondary);
                    break;
            }
            difficultyIndicator.setBackgroundColor(indicatorColor);
        }
    }
}
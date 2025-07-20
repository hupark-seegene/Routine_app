package com.squashtrainingapp.ui.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.squashtrainingapp.R;
import com.squashtrainingapp.models.CustomExercise;

import java.util.ArrayList;
import java.util.List;

public class CustomExerciseAdapter extends RecyclerView.Adapter<CustomExerciseAdapter.ExerciseViewHolder> {
    
    private List<CustomExercise> exercises = new ArrayList<>();
    private ExerciseClickListener listener;
    
    public interface ExerciseClickListener {
        void onExerciseClick(CustomExercise exercise);
        void onExerciseEdit(CustomExercise exercise);
        void onExerciseDelete(CustomExercise exercise);
    }
    
    public CustomExerciseAdapter(ExerciseClickListener listener) {
        this.listener = listener;
    }
    
    public void setExercises(List<CustomExercise> exercises) {
        this.exercises = exercises;
        notifyDataSetChanged();
    }
    
    @NonNull
    @Override
    public ExerciseViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.item_custom_exercise, parent, false);
        return new ExerciseViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ExerciseViewHolder holder, int position) {
        CustomExercise exercise = exercises.get(position);
        holder.bind(exercise);
    }
    
    @Override
    public int getItemCount() {
        return exercises.size();
    }
    
    class ExerciseViewHolder extends RecyclerView.ViewHolder {
        private TextView nameText;
        private TextView descriptionText;
        private TextView categoryText;
        private TextView difficultyText;
        private TextView durationText;
        private TextView usageText;
        private ImageButton editButton;
        private ImageButton deleteButton;
        private View userCreatedIndicator;
        
        ExerciseViewHolder(@NonNull View itemView) {
            super(itemView);
            
            nameText = itemView.findViewById(R.id.exercise_name);
            descriptionText = itemView.findViewById(R.id.exercise_description);
            categoryText = itemView.findViewById(R.id.exercise_category);
            difficultyText = itemView.findViewById(R.id.exercise_difficulty);
            durationText = itemView.findViewById(R.id.exercise_duration);
            usageText = itemView.findViewById(R.id.exercise_usage);
            editButton = itemView.findViewById(R.id.button_edit);
            deleteButton = itemView.findViewById(R.id.button_delete);
            userCreatedIndicator = itemView.findViewById(R.id.user_created_indicator);
        }
        
        void bind(CustomExercise exercise) {
            nameText.setText(exercise.getName());
            descriptionText.setText(exercise.getDescription());
            categoryText.setText(exercise.getCategoryIcon() + " " + exercise.getCategory().getKorean());
            difficultyText.setText(exercise.getDifficultyIcon() + " " + exercise.getDifficulty().getKorean());
            durationText.setText(exercise.getFormattedDuration());
            
            if (exercise.getTimesUsed() > 0) {
                usageText.setVisibility(View.VISIBLE);
                usageText.setText("사용: " + exercise.getTimesUsed() + "회");
            } else {
                usageText.setVisibility(View.GONE);
            }
            
            // Show indicator for user-created exercises
            userCreatedIndicator.setVisibility(exercise.isUserCreated() ? View.VISIBLE : View.GONE);
            
            // Show edit/delete buttons only for user-created exercises
            boolean showEditButtons = exercise.isUserCreated();
            editButton.setVisibility(showEditButtons ? View.VISIBLE : View.GONE);
            deleteButton.setVisibility(showEditButtons ? View.VISIBLE : View.GONE);
            
            // Click listeners
            itemView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onExerciseClick(exercise);
                }
            });
            
            editButton.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onExerciseEdit(exercise);
                }
            });
            
            deleteButton.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onExerciseDelete(exercise);
                }
            });
        }
    }
}
package com.squashtrainingapp.ui.adapters;

import com.squashtrainingapp.R;
import com.squashtrainingapp.models.Exercise;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class ExerciseAdapter extends RecyclerView.Adapter<ExerciseAdapter.ExerciseViewHolder> {
    
    private List<Exercise> exerciseList;
    private OnExerciseCheckListener checkListener;
    
    public interface OnExerciseCheckListener {
        void onExerciseChecked(int position, boolean isChecked);
    }
    
    public ExerciseAdapter(List<Exercise> exerciseList, OnExerciseCheckListener listener) {
        this.exerciseList = exerciseList;
        this.checkListener = listener;
    }
    
    @NonNull
    @Override
    public ExerciseViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_exercise, parent, false);
        return new ExerciseViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ExerciseViewHolder holder, int position) {
        Exercise exercise = exerciseList.get(position);
        holder.bind(exercise, position);
    }
    
    @Override
    public int getItemCount() {
        return exerciseList.size();
    }
    
    class ExerciseViewHolder extends RecyclerView.ViewHolder {
        private TextView nameText;
        private TextView categoryText;
        private TextView detailsText;
        private CheckBox checkBox;
        
        public ExerciseViewHolder(@NonNull View itemView) {
            super(itemView);
            nameText = itemView.findViewById(R.id.exercise_name);
            categoryText = itemView.findViewById(R.id.exercise_category);
            detailsText = itemView.findViewById(R.id.exercise_details);
            checkBox = itemView.findViewById(R.id.exercise_checkbox);
        }
        
        public void bind(Exercise exercise, int position) {
            nameText.setText(exercise.getName());
            categoryText.setText(exercise.getCategory());
            detailsText.setText(exercise.getDisplayText());
            checkBox.setChecked(exercise.isCompleted());
            
            // Set category color
            int categoryColor = getCategoryColor(exercise.getCategory());
            categoryText.setTextColor(categoryColor);
            
            checkBox.setOnCheckedChangeListener((buttonView, isChecked) -> {
                if (checkListener != null) {
                    checkListener.onExerciseChecked(position, isChecked);
                }
            });
        }
        
        private int getCategoryColor(String category) {
            switch (category) {
                case "Skill":
                    return itemView.getContext().getColor(R.color.volt_green);
                case "Cardio":
                    return itemView.getContext().getColor(R.color.error);
                case "Fitness":
                    return itemView.getContext().getColor(R.color.warning);
                case "Strength":
                    return itemView.getContext().getColor(R.color.success);
                default:
                    return itemView.getContext().getColor(R.color.text_secondary);
            }
        }
    }
}

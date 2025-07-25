package com.squashtrainingapp.ui.activities;

import com.squashtrainingapp.R;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.Record;
import com.squashtrainingapp.models.Exercise;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class HistoryActivity extends AppCompatActivity {
    
    private RecyclerView recyclerView;
    private RecordAdapter adapter;
    private DatabaseHelper databaseHelper;
    private List<Record> records;
    private TextView emptyText;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_history);
        
        databaseHelper = DatabaseHelper.getInstance(this);
        
        recyclerView = findViewById(R.id.history_recycler);
        emptyText = findViewById(R.id.empty_text);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        loadRecords();
    }
    
    private void loadRecords() {
        records = databaseHelper.getRecordDao().getAllRecords();
        
        if (records.isEmpty()) {
            recyclerView.setVisibility(View.GONE);
            emptyText.setVisibility(View.VISIBLE);
        } else {
            recyclerView.setVisibility(View.VISIBLE);
            emptyText.setVisibility(View.GONE);
            adapter = new RecordAdapter();
            recyclerView.setAdapter(adapter);
        }
    }
    
    private class RecordAdapter extends RecyclerView.Adapter<RecordAdapter.ViewHolder> {
        
        private SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.getDefault());
        
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_record, parent, false);
            return new ViewHolder(view);
        }
        
        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            Record record = records.get(position);
            
            holder.exerciseName.setText(record.getExerciseName());
            
            // Format date
            try {
                String formattedDate = record.getDate();
                if (record.getDate() != null) {
                    formattedDate = record.getDate().substring(0, Math.min(record.getDate().length(), 19));
                }
                holder.dateText.setText(formattedDate);
            } catch (Exception e) {
                holder.dateText.setText(record.getDate());
            }
            
            // Build stats string
            StringBuilder stats = new StringBuilder();
            if (record.getSets() > 0) stats.append("Sets: ").append(record.getSets()).append(" ");
            if (record.getReps() > 0) stats.append("Reps: ").append(record.getReps()).append(" ");
            if (record.getDuration() > 0) stats.append("Duration: ").append(record.getDuration()).append("min");
            holder.statsText.setText(stats.toString());
            
            // Ratings
            String ratings = String.format("Intensity: %d/10 | Condition: %d/10 | Fatigue: %d/10",
                                         record.getIntensity(), record.getCondition(), record.getFatigue());
            holder.ratingsText.setText(ratings);
            
            // Memo
            if (record.getMemo() != null && !record.getMemo().isEmpty()) {
                holder.memoText.setVisibility(View.VISIBLE);
                holder.memoText.setText("Memo: " + record.getMemo());
            } else {
                holder.memoText.setVisibility(View.GONE);
            }
            
            // Delete button
            holder.deleteButton.setOnClickListener(v -> {
                showDeleteConfirmation(record, position);
            });
        }
        
        @Override
        public int getItemCount() {
            return records.size();
        }
        
        class ViewHolder extends RecyclerView.ViewHolder {
            TextView exerciseName;
            TextView dateText;
            TextView statsText;
            TextView ratingsText;
            TextView memoText;
            Button deleteButton;
            
            ViewHolder(View itemView) {
                super(itemView);
                exerciseName = itemView.findViewById(R.id.exercise_name);
                dateText = itemView.findViewById(R.id.date_text);
                statsText = itemView.findViewById(R.id.stats_text);
                ratingsText = itemView.findViewById(R.id.ratings_text);
                memoText = itemView.findViewById(R.id.memo_text);
                deleteButton = itemView.findViewById(R.id.delete_button);
            }
        }
    }
    
    private void showDeleteConfirmation(Record record, int position) {
        new AlertDialog.Builder(this)
            .setTitle("Delete Workout")
            .setMessage("Are you sure you want to delete this workout record?")
            .setPositiveButton("Delete", (dialog, which) -> {
                databaseHelper.getRecordDao().delete(record.getId());
                records.remove(position);
                adapter.notifyItemRemoved(position);
                Toast.makeText(this, "Workout deleted", Toast.LENGTH_SHORT).show();
                
                if (records.isEmpty()) {
                    recyclerView.setVisibility(View.GONE);
                    emptyText.setVisibility(View.VISIBLE);
                }
            })
            .setNegativeButton("Cancel", null)
            .show();
    }
}
package com.squashtrainingapp.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.tabs.TabLayout;
import com.squashtrainingapp.R;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.database.dao.TrainingProgramDao;
import com.squashtrainingapp.models.TrainingProgram;
import com.squashtrainingapp.ui.adapters.ProgramAdapter;
import java.util.ArrayList;
import java.util.List;

public class ProgramsActivity extends AppCompatActivity implements ProgramAdapter.OnProgramClickListener {
    
    private TabLayout tabLayout;
    private RecyclerView programsRecyclerView;
    private TextView emptyStateText;
    private ProgramAdapter programAdapter;
    private TrainingProgramDao programDao;
    private DatabaseHelper dbHelper;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_programs);
        
        initializeViews();
        setupDatabase();
        setupTabs();
        loadPrograms("Focus");
    }
    
    private void initializeViews() {
        // Back button
        ImageView backButton = findViewById(R.id.back_button);
        backButton.setOnClickListener(v -> finish());
        
        // Schedule button
        ImageView scheduleButton = findViewById(R.id.schedule_button);
        scheduleButton.setOnClickListener(v -> {
            Intent intent = new Intent(ProgramsActivity.this, ScheduleActivity.class);
            startActivity(intent);
        });
        
        // Title
        TextView titleText = findViewById(R.id.title_text);
        titleText.setText("TRAINING PROGRAMS");
        
        // Tabs
        tabLayout = findViewById(R.id.tab_layout);
        
        // RecyclerView
        programsRecyclerView = findViewById(R.id.programs_recycler_view);
        programsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        // Empty state
        emptyStateText = findViewById(R.id.empty_state_text);
        
        // Adapter
        programAdapter = new ProgramAdapter(new ArrayList<>(), this);
        programsRecyclerView.setAdapter(programAdapter);
    }
    
    private void setupDatabase() {
        dbHelper = DatabaseHelper.getInstance(this);
        programDao = new TrainingProgramDao(dbHelper);
        
        // Insert default programs if database is empty
        List<TrainingProgram> existingPrograms = programDao.getAllPrograms();
        if (existingPrograms.isEmpty()) {
            programDao.insertDefaultPrograms();
        }
    }
    
    private void setupTabs() {
        // Add tabs
        tabLayout.addTab(tabLayout.newTab().setText("4-WEEK FOCUS"));
        tabLayout.addTab(tabLayout.newTab().setText("12-WEEK MASTER"));
        tabLayout.addTab(tabLayout.newTab().setText("SEASON PLANS"));
        
        // Tab selection listener
        tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                String type = "Focus"; // Default
                switch (tab.getPosition()) {
                    case 0:
                        type = "Focus";
                        break;
                    case 1:
                        type = "Master";
                        break;
                    case 2:
                        type = "Season";
                        break;
                }
                loadPrograms(type);
            }
            
            @Override
            public void onTabUnselected(TabLayout.Tab tab) {}
            
            @Override
            public void onTabReselected(TabLayout.Tab tab) {}
        });
    }
    
    private void loadPrograms(String type) {
        List<TrainingProgram> programs = programDao.getProgramsByType(type);
        
        if (programs.isEmpty()) {
            programsRecyclerView.setVisibility(View.GONE);
            emptyStateText.setVisibility(View.VISIBLE);
            emptyStateText.setText("No " + type.toLowerCase() + " programs available");
        } else {
            programsRecyclerView.setVisibility(View.VISIBLE);
            emptyStateText.setVisibility(View.GONE);
            programAdapter.updatePrograms(programs);
        }
    }
    
    @Override
    public void onProgramClick(TrainingProgram program) {
        // Navigate to program detail activity
        Intent intent = new Intent(this, ProgramDetailActivity.class);
        intent.putExtra("program_id", program.getId());
        intent.putExtra("program_name", program.getName());
        startActivity(intent);
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (dbHelper != null) {
            dbHelper.close();
        }
    }
}
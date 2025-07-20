package com.squashtrainingapp.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.tabs.TabLayout;
import com.squashtrainingapp.R;
import com.squashtrainingapp.managers.WorkoutProgramManager;
import com.squashtrainingapp.models.WorkoutProgram;
import com.squashtrainingapp.ui.adapters.WorkoutProgramAdapter;

import java.util.ArrayList;
import java.util.List;

public class WorkoutProgramActivity extends AppCompatActivity implements 
    WorkoutProgramAdapter.ProgramClickListener {
    
    private RecyclerView recyclerView;
    private WorkoutProgramAdapter adapter;
    private WorkoutProgramManager programManager;
    private TabLayout tabLayout;
    private FloatingActionButton fabAdd;
    private ImageButton backButton;
    private TextView titleText;
    private TextView emptyText;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_workout_program);
        
        initializeViews();
        setupTabs();
        loadPrograms(0);
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        // Refresh when returning from program details
        loadPrograms(tabLayout.getSelectedTabPosition());
    }
    
    private void initializeViews() {
        backButton = findViewById(R.id.back_button);
        titleText = findViewById(R.id.title_text);
        recyclerView = findViewById(R.id.programs_recycler_view);
        tabLayout = findViewById(R.id.tab_layout);
        fabAdd = findViewById(R.id.fab_add_program);
        emptyText = findViewById(R.id.empty_text);
        
        // Initialize manager
        programManager = new WorkoutProgramManager(this);
        
        // Setup RecyclerView
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        adapter = new WorkoutProgramAdapter(this);
        recyclerView.setAdapter(adapter);
        
        // Back button
        backButton.setOnClickListener(v -> finish());
        
        // FAB
        fabAdd.setOnClickListener(v -> createNewProgram());
        
        titleText.setText("운동 프로그램");
    }
    
    private void setupTabs() {
        tabLayout.addTab(tabLayout.newTab().setText("진행 중"));
        tabLayout.addTab(tabLayout.newTab().setText("내 프로그램"));
        tabLayout.addTab(tabLayout.newTab().setText("추천"));
        tabLayout.addTab(tabLayout.newTab().setText("완료"));
        
        tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                loadPrograms(tab.getPosition());
            }
            
            @Override
            public void onTabUnselected(TabLayout.Tab tab) {}
            
            @Override
            public void onTabReselected(TabLayout.Tab tab) {}
        });
    }
    
    private void loadPrograms(int tabPosition) {
        List<WorkoutProgram> programs;
        
        switch (tabPosition) {
            case 0: // Active
                programs = programManager.getActivePrograms();
                emptyText.setText("진행 중인 프로그램이 없습니다");
                break;
            case 1: // My Programs
                programs = programManager.getUserCreatedPrograms();
                emptyText.setText("내가 만든 프로그램이 없습니다\n+ 버튼을 눌러 새 프로그램을 만들어보세요");
                break;
            case 2: // Recommended
                // Get user level from shared prefs or database
                int userLevel = 5; // Default intermediate
                programs = programManager.getRecommendedPrograms(userLevel);
                emptyText.setText("추천 프로그램이 없습니다");
                break;
            case 3: // Completed
                programs = new ArrayList<>();
                for (WorkoutProgram program : programManager.getAllPrograms()) {
                    if (program.isCompleted()) {
                        programs.add(program);
                    }
                }
                emptyText.setText("완료한 프로그램이 없습니다");
                break;
            default:
                programs = programManager.getAllPrograms();
        }
        
        updateProgramList(programs);
    }
    
    private void updateProgramList(List<WorkoutProgram> programs) {
        adapter.setPrograms(programs);
        
        if (programs.isEmpty()) {
            recyclerView.setVisibility(View.GONE);
            emptyText.setVisibility(View.VISIBLE);
        } else {
            recyclerView.setVisibility(View.VISIBLE);
            emptyText.setVisibility(View.GONE);
        }
    }
    
    private void createNewProgram() {
        Intent intent = new Intent(this, CreateProgramActivity.class);
        startActivity(intent);
    }
    
    @Override
    public void onProgramClick(WorkoutProgram program) {
        Intent intent = new Intent(this, ProgramDetailActivity.class);
        intent.putExtra("program_id", program.getId());
        startActivity(intent);
    }
    
    @Override
    public void onProgramStart(WorkoutProgram program) {
        if (programManager.getActiveProgram() != null) {
            new AlertDialog.Builder(this)
                .setTitle("프로그램 변경")
                .setMessage("현재 진행 중인 프로그램이 있습니다. " + program.getName() + "을(를) 시작하시겠습니까?")
                .setPositiveButton("시작", (dialog, which) -> {
                    programManager.setActiveProgram(program.getId());
                    loadPrograms(tabLayout.getSelectedTabPosition());
                    Toast.makeText(this, program.getName() + " 프로그램을 시작했습니다", Toast.LENGTH_SHORT).show();
                })
                .setNegativeButton("취소", null)
                .show();
        } else {
            programManager.setActiveProgram(program.getId());
            loadPrograms(tabLayout.getSelectedTabPosition());
            Toast.makeText(this, program.getName() + " 프로그램을 시작했습니다", Toast.LENGTH_SHORT).show();
        }
    }
    
    @Override
    public void onProgramStop(WorkoutProgram program) {
        new AlertDialog.Builder(this)
            .setTitle("프로그램 중단")
            .setMessage(program.getName() + " 프로그램을 중단하시겠습니까?")
            .setPositiveButton("중단", (dialog, which) -> {
                programManager.deactivateProgram();
                loadPrograms(tabLayout.getSelectedTabPosition());
                Toast.makeText(this, "프로그램을 중단했습니다", Toast.LENGTH_SHORT).show();
            })
            .setNegativeButton("취소", null)
            .show();
    }
    
    @Override
    public void onProgramDelete(WorkoutProgram program) {
        new AlertDialog.Builder(this)
            .setTitle("프로그램 삭제")
            .setMessage(program.getName() + "을(를) 삭제하시겠습니까?\n이 작업은 취소할 수 없습니다.")
            .setPositiveButton("삭제", (dialog, which) -> {
                programManager.deleteProgram(program.getId());
                loadPrograms(tabLayout.getSelectedTabPosition());
                Toast.makeText(this, "프로그램이 삭제되었습니다", Toast.LENGTH_SHORT).show();
            })
            .setNegativeButton("취소", null)
            .show();
    }
}
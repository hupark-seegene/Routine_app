package com.squashtrainingapp.ui.activities;

import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.os.Bundle;
import android.view.View;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.squashtrainingapp.R;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.database.dao.TrainingProgramDao;
import com.squashtrainingapp.database.dao.WorkoutSessionDao;
import com.squashtrainingapp.models.TrainingProgram;
import com.squashtrainingapp.models.WorkoutSession;
import com.squashtrainingapp.ui.adapters.ScheduleAdapter;
import java.text.SimpleDateFormat;
import java.util.*;

public class ScheduleActivity extends AppCompatActivity {
    
    private TextView dateText;
    private TextView timeText;
    private EditText sessionNameInput;
    private EditText durationInput;
    private Spinner programSpinner;
    private Button scheduleButton;
    private RecyclerView upcomingRecyclerView;
    
    private WorkoutSessionDao sessionDao;
    private TrainingProgramDao programDao;
    private ScheduleAdapter scheduleAdapter;
    
    private Calendar selectedDateTime = Calendar.getInstance();
    private SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy", Locale.getDefault());
    private SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
    
    private List<TrainingProgram> programs;
    private TrainingProgram selectedProgram;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_schedule);
        
        initializeViews();
        initializeDatabase();
        loadPrograms();
        loadUpcomingSessions();
        setupListeners();
    }
    
    private void initializeViews() {
        // Header
        ImageView backButton = findViewById(R.id.back_button);
        backButton.setOnClickListener(v -> finish());
        
        // Schedule form
        dateText = findViewById(R.id.date_text);
        timeText = findViewById(R.id.time_text);
        sessionNameInput = findViewById(R.id.session_name_input);
        durationInput = findViewById(R.id.duration_input);
        programSpinner = findViewById(R.id.program_spinner);
        scheduleButton = findViewById(R.id.schedule_button);
        
        // Upcoming sessions
        upcomingRecyclerView = findViewById(R.id.upcoming_recycler_view);
        upcomingRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        // Set default date/time
        updateDateTimeDisplay();
    }
    
    private void initializeDatabase() {
        DatabaseHelper dbHelper = DatabaseHelper.getInstance(this);
        sessionDao = new WorkoutSessionDao(dbHelper);
        programDao = new TrainingProgramDao(dbHelper);
    }
    
    private void loadPrograms() {
        programs = programDao.getAllPrograms();
        
        // Add "No Program" option
        TrainingProgram noProgram = new TrainingProgram();
        noProgram.setName("No Program");
        noProgram.setId(0);
        programs.add(0, noProgram);
        
        // Create adapter for spinner
        ArrayAdapter<String> adapter = new ArrayAdapter<>(
            this,
            android.R.layout.simple_spinner_item,
            getProgramNames()
        );
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        programSpinner.setAdapter(adapter);
        
        programSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectedProgram = programs.get(position);
            }
            
            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selectedProgram = programs.get(0);
            }
        });
    }
    
    private List<String> getProgramNames() {
        List<String> names = new ArrayList<>();
        for (TrainingProgram program : programs) {
            names.add(program.getName());
        }
        return names;
    }
    
    private void loadUpcomingSessions() {
        List<WorkoutSession> upcomingSessions = sessionDao.getUpcomingSessions();
        scheduleAdapter = new ScheduleAdapter(upcomingSessions, this);
        upcomingRecyclerView.setAdapter(scheduleAdapter);
    }
    
    private void setupListeners() {
        // Date picker
        dateText.setOnClickListener(v -> showDatePicker());
        
        // Time picker
        timeText.setOnClickListener(v -> showTimePicker());
        
        // Schedule button
        scheduleButton.setOnClickListener(v -> scheduleWorkout());
    }
    
    private void showDatePicker() {
        DatePickerDialog picker = new DatePickerDialog(
            this,
            (view, year, month, dayOfMonth) -> {
                selectedDateTime.set(year, month, dayOfMonth);
                updateDateTimeDisplay();
            },
            selectedDateTime.get(Calendar.YEAR),
            selectedDateTime.get(Calendar.MONTH),
            selectedDateTime.get(Calendar.DAY_OF_MONTH)
        );
        picker.getDatePicker().setMinDate(System.currentTimeMillis());
        picker.show();
    }
    
    private void showTimePicker() {
        TimePickerDialog picker = new TimePickerDialog(
            this,
            (view, hourOfDay, minute) -> {
                selectedDateTime.set(Calendar.HOUR_OF_DAY, hourOfDay);
                selectedDateTime.set(Calendar.MINUTE, minute);
                updateDateTimeDisplay();
            },
            selectedDateTime.get(Calendar.HOUR_OF_DAY),
            selectedDateTime.get(Calendar.MINUTE),
            true
        );
        picker.show();
    }
    
    private void updateDateTimeDisplay() {
        dateText.setText(dateFormat.format(selectedDateTime.getTime()));
        timeText.setText(timeFormat.format(selectedDateTime.getTime()));
    }
    
    private void scheduleWorkout() {
        String sessionName = sessionNameInput.getText().toString().trim();
        String durationStr = durationInput.getText().toString().trim();
        
        if (sessionName.isEmpty()) {
            Toast.makeText(this, "Please enter a session name", Toast.LENGTH_SHORT).show();
            return;
        }
        
        int duration = 60; // default
        if (!durationStr.isEmpty()) {
            try {
                duration = Integer.parseInt(durationStr);
            } catch (NumberFormatException e) {
                Toast.makeText(this, "Invalid duration", Toast.LENGTH_SHORT).show();
                return;
            }
        }
        
        // Create workout session
        WorkoutSession session = new WorkoutSession(
            selectedProgram.getId(),
            sessionName,
            selectedDateTime.getTime(),
            duration
        );
        
        // Save to database
        long sessionId = sessionDao.insertSession(session);
        
        if (sessionId > 0) {
            Toast.makeText(this, "Workout scheduled!", Toast.LENGTH_SHORT).show();
            
            // Clear form
            sessionNameInput.setText("");
            durationInput.setText("");
            selectedDateTime = Calendar.getInstance();
            updateDateTimeDisplay();
            
            // Reload upcoming sessions
            loadUpcomingSessions();
        } else {
            Toast.makeText(this, "Failed to schedule workout", Toast.LENGTH_SHORT).show();
        }
    }
}
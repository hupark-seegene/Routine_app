package com.squashtrainingapp.managers;

import android.content.Context;
import android.content.SharedPreferences;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.squashtrainingapp.models.CustomExercise;
import com.squashtrainingapp.models.WorkoutProgram;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class WorkoutProgramManager {
    
    private static final String PREFS_NAME = "workout_programs";
    private static final String KEY_PROGRAMS = "programs";
    private static final String KEY_ACTIVE_PROGRAM = "active_program_id";
    
    private Context context;
    private SharedPreferences prefs;
    private Gson gson;
    private List<WorkoutProgram> programs;
    private String activeProgramId;
    
    public WorkoutProgramManager(Context context) {
        this.context = context;
        this.prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        this.gson = new Gson();
        loadPrograms();
        initializeDefaultPrograms();
    }
    
    private void loadPrograms() {
        String json = prefs.getString(KEY_PROGRAMS, null);
        if (json != null) {
            Type type = new TypeToken<List<WorkoutProgram>>() {}.getType();
            programs = gson.fromJson(json, type);
        } else {
            programs = new ArrayList<>();
        }
        activeProgramId = prefs.getString(KEY_ACTIVE_PROGRAM, null);
    }
    
    private void savePrograms() {
        String json = gson.toJson(programs);
        prefs.edit()
            .putString(KEY_PROGRAMS, json)
            .putString(KEY_ACTIVE_PROGRAM, activeProgramId)
            .apply();
    }
    
    private void initializeDefaultPrograms() {
        if (programs.isEmpty()) {
            // Beginner Program
            WorkoutProgram beginnerProgram = new WorkoutProgram(
                "초급자 시작 프로그램",
                "스쿼시를 처음 시작하는 분들을 위한 4주 프로그램",
                WorkoutProgram.ProgramType.BEGINNER,
                WorkoutProgram.Duration.WEEK_4
            );
            beginnerProgram.setDaysPerWeek(3);
            beginnerProgram.setUserCreated(false);
            
            // Week 1
            for (int i = 1; i <= 3; i++) {
                WorkoutProgram.ProgramDay day = new WorkoutProgram.ProgramDay(
                    i, "1주차 " + i + "일차"
                );
                day.getExerciseIds().add("basic_forehand");
                day.getExerciseIds().add("basic_backhand");
                day.getExerciseIds().add("basic_serve");
                beginnerProgram.addProgramDay(day);
            }
            
            // Week 2-4 (similar structure)
            for (int week = 2; week <= 4; week++) {
                for (int day = 1; day <= 3; day++) {
                    int dayNumber = (week - 1) * 3 + day;
                    WorkoutProgram.ProgramDay programDay = new WorkoutProgram.ProgramDay(
                        dayNumber, week + "주차 " + day + "일차"
                    );
                    // Add progressive exercises
                    beginnerProgram.addProgramDay(programDay);
                }
            }
            
            programs.add(beginnerProgram);
            
            // Intermediate Program
            WorkoutProgram intermediateProgram = new WorkoutProgram(
                "중급자 실력 향상 프로그램",
                "기본기를 마스터한 분들을 위한 8주 심화 프로그램",
                WorkoutProgram.ProgramType.INTERMEDIATE,
                WorkoutProgram.Duration.WEEK_8
            );
            intermediateProgram.setDaysPerWeek(4);
            intermediateProgram.setUserCreated(false);
            programs.add(intermediateProgram);
            
            // Tournament Prep Program
            WorkoutProgram tournamentProgram = new WorkoutProgram(
                "대회 준비 프로그램",
                "대회를 준비하는 선수들을 위한 4주 집중 프로그램",
                WorkoutProgram.ProgramType.TOURNAMENT,
                WorkoutProgram.Duration.WEEK_4
            );
            tournamentProgram.setDaysPerWeek(5);
            tournamentProgram.setUserCreated(false);
            programs.add(tournamentProgram);
            
            savePrograms();
        }
    }
    
    // CRUD operations
    public void addProgram(WorkoutProgram program) {
        programs.add(program);
        savePrograms();
    }
    
    public void updateProgram(WorkoutProgram program) {
        for (int i = 0; i < programs.size(); i++) {
            if (programs.get(i).getId().equals(program.getId())) {
                programs.set(i, program);
                savePrograms();
                break;
            }
        }
    }
    
    public void deleteProgram(String programId) {
        programs.removeIf(p -> p.getId().equals(programId));
        if (programId.equals(activeProgramId)) {
            activeProgramId = null;
        }
        savePrograms();
    }
    
    public WorkoutProgram getProgramById(String id) {
        for (WorkoutProgram program : programs) {
            if (program.getId().equals(id)) {
                return program;
            }
        }
        return null;
    }
    
    // Query methods
    public List<WorkoutProgram> getAllPrograms() {
        return new ArrayList<>(programs);
    }
    
    public List<WorkoutProgram> getActivePrograms() {
        return programs.stream()
            .filter(WorkoutProgram::isActive)
            .collect(Collectors.toList());
    }
    
    public List<WorkoutProgram> getProgramsByType(WorkoutProgram.ProgramType type) {
        return programs.stream()
            .filter(p -> p.getType() == type)
            .collect(Collectors.toList());
    }
    
    public List<WorkoutProgram> getUserCreatedPrograms() {
        return programs.stream()
            .filter(WorkoutProgram::isUserCreated)
            .collect(Collectors.toList());
    }
    
    public WorkoutProgram getActiveProgram() {
        if (activeProgramId != null) {
            return getProgramById(activeProgramId);
        }
        return null;
    }
    
    // Program management
    public void setActiveProgram(String programId) {
        // Deactivate current active program
        if (activeProgramId != null) {
            WorkoutProgram currentActive = getProgramById(activeProgramId);
            if (currentActive != null) {
                currentActive.setActive(false);
            }
        }
        
        // Activate new program
        WorkoutProgram newActive = getProgramById(programId);
        if (newActive != null) {
            newActive.setActive(true);
            newActive.setStartDate(System.currentTimeMillis());
            activeProgramId = programId;
            savePrograms();
        }
    }
    
    public void deactivateProgram() {
        if (activeProgramId != null) {
            WorkoutProgram activeProgram = getProgramById(activeProgramId);
            if (activeProgram != null) {
                activeProgram.setActive(false);
            }
            activeProgramId = null;
            savePrograms();
        }
    }
    
    public void markDayCompleted(String programId, int dayNumber) {
        WorkoutProgram program = getProgramById(programId);
        if (program != null) {
            program.markDayCompleted(dayNumber);
            savePrograms();
        }
    }
    
    // Statistics
    public int getTotalProgramsCompleted() {
        return (int) programs.stream()
            .filter(WorkoutProgram::isCompleted)
            .count();
    }
    
    public int getTotalActiveDays() {
        return programs.stream()
            .mapToInt(WorkoutProgram::getCompletedDays)
            .sum();
    }
    
    public List<WorkoutProgram> getRecommendedPrograms(int userLevel) {
        List<WorkoutProgram> recommended = new ArrayList<>();
        
        if (userLevel <= 3) {
            recommended.addAll(getProgramsByType(WorkoutProgram.ProgramType.BEGINNER));
        } else if (userLevel <= 6) {
            recommended.addAll(getProgramsByType(WorkoutProgram.ProgramType.INTERMEDIATE));
        } else {
            recommended.addAll(getProgramsByType(WorkoutProgram.ProgramType.ADVANCED));
            recommended.addAll(getProgramsByType(WorkoutProgram.ProgramType.TOURNAMENT));
        }
        
        return recommended;
    }
}
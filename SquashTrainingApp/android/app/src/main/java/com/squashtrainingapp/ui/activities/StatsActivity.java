package com.squashtrainingapp.ui.activities;

import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

import com.github.mikephil.charting.charts.BarChart;
import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.charts.PieChart;
import com.github.mikephil.charting.components.Legend;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.components.YAxis;
import com.github.mikephil.charting.data.BarData;
import com.github.mikephil.charting.data.BarDataSet;
import com.github.mikephil.charting.data.BarEntry;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import com.github.mikephil.charting.data.PieEntry;
import com.github.mikephil.charting.formatter.IndexAxisValueFormatter;
import com.github.mikephil.charting.formatter.PercentFormatter;
import com.github.mikephil.charting.utils.ColorTemplate;

import com.squashtrainingapp.R;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.Record;
import com.squashtrainingapp.models.User;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class StatsActivity extends AppCompatActivity {
    
    // UI Components
    private Spinner timeRangeSpinner;
    private TextView totalWorkoutsText;
    private TextView totalHoursText;
    private TextView avgDurationText;
    private TextView bestStreakText;
    
    // Charts
    private LineChart progressChart;
    private BarChart weeklyChart;
    private PieChart categoryChart;
    
    // Data
    private DatabaseHelper databaseHelper;
    private List<Record> records;
    private User currentUser;
    
    // Time ranges
    private static final int RANGE_WEEK = 0;
    private static final int RANGE_MONTH = 1;
    private static final int RANGE_YEAR = 2;
    private static final int RANGE_ALL = 3;
    
    private int currentTimeRange = RANGE_MONTH;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_stats);
        
        // Initialize database
        databaseHelper = DatabaseHelper.getInstance(this);
        currentUser = databaseHelper.getUserDao().getUser();
        
        // Initialize views
        initializeViews();
        setupTimeRangeSpinner();
        
        // Load and display data
        loadDataForTimeRange(currentTimeRange);
    }
    
    private void initializeViews() {
        // Stats cards
        totalWorkoutsText = findViewById(R.id.total_workouts_text);
        totalHoursText = findViewById(R.id.total_hours_text);
        avgDurationText = findViewById(R.id.avg_duration_text);
        bestStreakText = findViewById(R.id.best_streak_text);
        
        // Charts
        progressChart = findViewById(R.id.progress_chart);
        weeklyChart = findViewById(R.id.weekly_chart);
        categoryChart = findViewById(R.id.category_chart);
        
        // Spinner
        timeRangeSpinner = findViewById(R.id.time_range_spinner);
        
        // Setup charts
        setupProgressChart();
        setupWeeklyChart();
        setupCategoryChart();
        
        // Back button
        findViewById(R.id.back_button).setOnClickListener(v -> onBackPressed());
        
        // Export button
        View exportButton = findViewById(R.id.export_button);
        if (exportButton != null) {
            exportButton.setOnClickListener(v -> exportDataToCSV());
        }
    }
    
    private void setupTimeRangeSpinner() {
        String[] timeRanges = {
            getString(R.string.this_week),
            getString(R.string.this_month),
            getString(R.string.this_year),
            getString(R.string.all_time)
        };
        
        ArrayAdapter<String> adapter = new ArrayAdapter<>(
            this, android.R.layout.simple_spinner_item, timeRanges);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        timeRangeSpinner.setAdapter(adapter);
        timeRangeSpinner.setSelection(RANGE_MONTH);
        
        timeRangeSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                currentTimeRange = position;
                loadDataForTimeRange(currentTimeRange);
            }
            
            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });
    }
    
    private void loadDataForTimeRange(int range) {
        Calendar calendar = Calendar.getInstance();
        Date endDate = new Date();
        Date startDate;
        
        switch (range) {
            case RANGE_WEEK:
                calendar.add(Calendar.DAY_OF_YEAR, -7);
                startDate = calendar.getTime();
                break;
            case RANGE_MONTH:
                calendar.add(Calendar.MONTH, -1);
                startDate = calendar.getTime();
                break;
            case RANGE_YEAR:
                calendar.add(Calendar.YEAR, -1);
                startDate = calendar.getTime();
                break;
            default: // RANGE_ALL
                calendar.add(Calendar.YEAR, -10); // 10 years back
                startDate = calendar.getTime();
                break;
        }
        
        // Load records from database
        records = databaseHelper.getRecordDao().getRecordsBetweenDates(
            startDate.getTime(), endDate.getTime());
        
        // Update UI
        updateStatsCards();
        updateProgressChart();
        updateWeeklyChart();
        updateCategoryChart();
    }
    
    private void updateStatsCards() {
        if (records == null || records.isEmpty()) {
            totalWorkoutsText.setText("0");
            totalHoursText.setText("0");
            avgDurationText.setText("0 min");
            bestStreakText.setText("0 days");
            return;
        }
        
        // Calculate stats
        int totalWorkouts = records.size();
        int totalMinutes = 0;
        for (Record record : records) {
            totalMinutes += record.getDuration();
        }
        
        float totalHours = totalMinutes / 60f;
        int avgMinutes = totalWorkouts > 0 ? totalMinutes / totalWorkouts : 0;
        
        // Update UI
        totalWorkoutsText.setText(String.valueOf(totalWorkouts));
        totalHoursText.setText(String.format(Locale.getDefault(), "%.1f", totalHours));
        avgDurationText.setText(avgMinutes + " min");
        
        // Calculate streak (simplified)
        int currentStreak = calculateCurrentStreak();
        bestStreakText.setText(currentStreak + " days");
    }
    
    private int calculateCurrentStreak() {
        if (records.isEmpty()) return 0;
        
        // Sort records by date
        records.sort((r1, r2) -> Long.compare(r2.getDate(), r1.getDate()));
        
        int streak = 0;
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        
        for (Record record : records) {
            Calendar recordCal = Calendar.getInstance();
            recordCal.setTimeInMillis(record.getDateAsTimestamp());
            recordCal.set(Calendar.HOUR_OF_DAY, 0);
            recordCal.set(Calendar.MINUTE, 0);
            recordCal.set(Calendar.SECOND, 0);
            recordCal.set(Calendar.MILLISECOND, 0);
            
            if (cal.getTimeInMillis() == recordCal.getTimeInMillis()) {
                streak++;
                cal.add(Calendar.DAY_OF_YEAR, -1);
            } else {
                break;
            }
        }
        
        return streak;
    }
    
    private void setupProgressChart() {
        progressChart.getDescription().setEnabled(false);
        progressChart.setDrawGridBackground(false);
        progressChart.setTouchEnabled(true);
        progressChart.setDragEnabled(true);
        progressChart.setScaleEnabled(false);
        progressChart.setPinchZoom(false);
        
        // X axis
        XAxis xAxis = progressChart.getXAxis();
        xAxis.setPosition(XAxis.XAxisPosition.BOTTOM);
        xAxis.setTextColor(Color.WHITE);
        xAxis.setDrawGridLines(false);
        
        // Y axis
        YAxis leftAxis = progressChart.getAxisLeft();
        leftAxis.setTextColor(Color.WHITE);
        leftAxis.setDrawGridLines(true);
        leftAxis.setGridColor(Color.GRAY);
        leftAxis.setAxisMinimum(0f);
        
        progressChart.getAxisRight().setEnabled(false);
        
        // Legend
        Legend legend = progressChart.getLegend();
        legend.setTextColor(Color.WHITE);
    }
    
    private void updateProgressChart() {
        if (records.isEmpty()) {
            progressChart.clear();
            progressChart.invalidate();
            return;
        }
        
        // Group records by date
        Map<String, Integer> dailyMinutes = new HashMap<>();
        SimpleDateFormat sdf = new SimpleDateFormat("MM/dd", Locale.getDefault());
        
        for (Record record : records) {
            String date = sdf.format(new Date(record.getDateAsTimestamp()));
            dailyMinutes.put(date, dailyMinutes.getOrDefault(date, 0) + record.getDuration());
        }
        
        // Create entries
        List<Entry> entries = new ArrayList<>();
        List<String> labels = new ArrayList<>(dailyMinutes.keySet());
        labels.sort(String::compareTo);
        
        for (int i = 0; i < labels.size(); i++) {
            String date = labels.get(i);
            entries.add(new Entry(i, dailyMinutes.get(date)));
        }
        
        // Create dataset
        LineDataSet dataSet = new LineDataSet(entries, getString(R.string.workout_minutes));
        dataSet.setColor(getResources().getColor(R.color.volt_green));
        dataSet.setCircleColor(getResources().getColor(R.color.volt_green));
        dataSet.setLineWidth(2f);
        dataSet.setCircleRadius(4f);
        dataSet.setDrawCircleHole(false);
        dataSet.setValueTextSize(10f);
        dataSet.setValueTextColor(Color.WHITE);
        dataSet.setDrawFilled(true);
        dataSet.setFillColor(getResources().getColor(R.color.volt_green));
        dataSet.setFillAlpha(50);
        
        // Set data
        LineData lineData = new LineData(dataSet);
        progressChart.setData(lineData);
        
        // Set x-axis labels
        progressChart.getXAxis().setValueFormatter(new IndexAxisValueFormatter(labels));
        progressChart.getXAxis().setLabelCount(Math.min(labels.size(), 7));
        
        progressChart.invalidate();
    }
    
    private void setupWeeklyChart() {
        weeklyChart.getDescription().setEnabled(false);
        weeklyChart.setDrawGridBackground(false);
        weeklyChart.setTouchEnabled(true);
        weeklyChart.setDragEnabled(false);
        weeklyChart.setScaleEnabled(false);
        weeklyChart.setPinchZoom(false);
        
        // X axis
        XAxis xAxis = weeklyChart.getXAxis();
        xAxis.setPosition(XAxis.XAxisPosition.BOTTOM);
        xAxis.setTextColor(Color.WHITE);
        xAxis.setDrawGridLines(false);
        
        // Y axis
        YAxis leftAxis = weeklyChart.getAxisLeft();
        leftAxis.setTextColor(Color.WHITE);
        leftAxis.setDrawGridLines(true);
        leftAxis.setGridColor(Color.GRAY);
        leftAxis.setAxisMinimum(0f);
        
        weeklyChart.getAxisRight().setEnabled(false);
        weeklyChart.getLegend().setEnabled(false);
    }
    
    private void updateWeeklyChart() {
        String[] daysOfWeek = {
            getString(R.string.sun), getString(R.string.mon), 
            getString(R.string.tue), getString(R.string.wed),
            getString(R.string.thu), getString(R.string.fri), 
            getString(R.string.sat)
        };
        
        // Initialize weekly data
        int[] weeklyMinutes = new int[7];
        Calendar cal = Calendar.getInstance();
        
        for (Record record : records) {
            cal.setTimeInMillis(record.getDateAsTimestamp());
            int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK) - 1; // 0-6
            weeklyMinutes[dayOfWeek] += record.getDuration();
        }
        
        // Create entries
        List<BarEntry> entries = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            entries.add(new BarEntry(i, weeklyMinutes[i]));
        }
        
        // Create dataset
        BarDataSet dataSet = new BarDataSet(entries, getString(R.string.weekly_activity));
        dataSet.setColor(getResources().getColor(R.color.volt_green));
        dataSet.setValueTextColor(Color.WHITE);
        dataSet.setValueTextSize(10f);
        
        // Set data
        BarData barData = new BarData(dataSet);
        barData.setBarWidth(0.7f);
        weeklyChart.setData(barData);
        
        // Set x-axis labels
        weeklyChart.getXAxis().setValueFormatter(new IndexAxisValueFormatter(daysOfWeek));
        weeklyChart.getXAxis().setLabelCount(7);
        
        weeklyChart.invalidate();
    }
    
    private void setupCategoryChart() {
        categoryChart.getDescription().setEnabled(false);
        categoryChart.setDrawHoleEnabled(true);
        categoryChart.setHoleColor(getResources().getColor(R.color.dark_surface));
        categoryChart.setTransparentCircleColor(Color.WHITE);
        categoryChart.setTransparentCircleAlpha(110);
        categoryChart.setHoleRadius(58f);
        categoryChart.setTransparentCircleRadius(61f);
        categoryChart.setDrawCenterText(true);
        categoryChart.setCenterText(getString(R.string.exercise_types));
        categoryChart.setCenterTextColor(Color.WHITE);
        categoryChart.setRotationEnabled(true);
        categoryChart.setHighlightPerTapEnabled(true);
        
        Legend legend = categoryChart.getLegend();
        legend.setVerticalAlignment(Legend.LegendVerticalAlignment.TOP);
        legend.setHorizontalAlignment(Legend.LegendHorizontalAlignment.RIGHT);
        legend.setOrientation(Legend.LegendOrientation.VERTICAL);
        legend.setDrawInside(false);
        legend.setTextColor(Color.WHITE);
    }
    
    private void updateCategoryChart() {
        if (records.isEmpty()) {
            categoryChart.clear();
            categoryChart.invalidate();
            return;
        }
        
        // Count exercises by category
        Map<String, Integer> categoryCount = new HashMap<>();
        for (Record record : records) {
            String category = record.getExerciseType();
            if (category == null || category.isEmpty()) {
                category = getString(R.string.other);
            }
            categoryCount.put(category, categoryCount.getOrDefault(category, 0) + 1);
        }
        
        // Create entries
        List<PieEntry> entries = new ArrayList<>();
        for (Map.Entry<String, Integer> entry : categoryCount.entrySet()) {
            entries.add(new PieEntry(entry.getValue(), entry.getKey()));
        }
        
        // Create dataset
        PieDataSet dataSet = new PieDataSet(entries, getString(R.string.categories));
        dataSet.setSliceSpace(3f);
        dataSet.setSelectionShift(5f);
        
        // Set colors
        ArrayList<Integer> colors = new ArrayList<>();
        colors.add(getResources().getColor(R.color.volt_green));
        colors.add(getResources().getColor(R.color.volt_yellow));
        colors.add(getResources().getColor(R.color.neon_blue));
        colors.add(getResources().getColor(R.color.electric_purple));
        colors.add(getResources().getColor(R.color.cyber_pink));
        dataSet.setColors(colors);
        
        // Set data
        PieData pieData = new PieData(dataSet);
        pieData.setValueFormatter(new PercentFormatter(categoryChart));
        pieData.setValueTextSize(11f);
        pieData.setValueTextColor(Color.WHITE);
        
        categoryChart.setData(pieData);
        categoryChart.setUsePercentValues(true);
        categoryChart.invalidate();
    }
    
    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
    }
    
    private void exportDataToCSV() {
        if (records == null || records.isEmpty()) {
            Toast.makeText(this, getString(R.string.no_data_to_export), Toast.LENGTH_SHORT).show();
            return;
        }
        
        try {
            // Create export directory
            File exportDir = new File(getExternalFilesDir(null), "exports");
            if (!exportDir.exists()) {
                exportDir.mkdirs();
            }
            
            // Create CSV file with timestamp
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault());
            String fileName = "workout_data_" + dateFormat.format(new Date()) + ".csv";
            File csvFile = new File(exportDir, fileName);
            
            // Write CSV data
            FileWriter writer = new FileWriter(csvFile);
            
            // Write header
            writer.append("Date,Exercise,Duration (min),Sets,Reps,Intensity,Condition,Fatigue,Category,Calories\n");
            
            // Write records
            SimpleDateFormat recordDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault());
            for (Record record : records) {
                writer.append(recordDateFormat.format(new Date(record.getDateAsTimestamp()))).append(",");
                writer.append(escapeCSV(record.getExerciseName())).append(",");
                writer.append(String.valueOf(record.getDuration())).append(",");
                writer.append(String.valueOf(record.getSets())).append(",");
                writer.append(String.valueOf(record.getReps())).append(",");
                writer.append(String.valueOf(record.getIntensity())).append(",");
                writer.append(String.valueOf(record.getCondition())).append(",");
                writer.append(String.valueOf(record.getFatigue())).append(",");
                writer.append(escapeCSV(record.getExerciseType())).append(",");
                writer.append(String.valueOf(record.getEstimatedCalories())).append("\n");
            }
            
            // Write summary
            writer.append("\n\nSummary\n");
            writer.append("Total Workouts,").append(String.valueOf(records.size())).append("\n");
            writer.append("Total Duration,").append(String.valueOf(getTotalDuration())).append(" min\n");
            writer.append("Average Duration,").append(String.valueOf(getAverageDuration())).append(" min\n");
            writer.append("Date Range,").append(getDateRangeString()).append("\n");
            
            writer.flush();
            writer.close();
            
            // Show success message with file path
            String message = getString(R.string.data_exported_to) + "\n" + csvFile.getAbsolutePath();
            Toast.makeText(this, message, Toast.LENGTH_LONG).show();
            
        } catch (IOException e) {
            Toast.makeText(this, getString(R.string.export_failed) + ": " + e.getMessage(), 
                Toast.LENGTH_LONG).show();
        }
    }
    
    private String escapeCSV(String value) {
        if (value == null) return "";
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
    
    private int getTotalDuration() {
        int total = 0;
        for (Record record : records) {
            total += record.getDuration();
        }
        return total;
    }
    
    private int getAverageDuration() {
        if (records.isEmpty()) return 0;
        return getTotalDuration() / records.size();
    }
    
    private String getDateRangeString() {
        if (records.isEmpty()) return "No data";
        
        long minDate = Long.MAX_VALUE;
        long maxDate = Long.MIN_VALUE;
        
        for (Record record : records) {
            long timestamp = record.getDateAsTimestamp();
            if (timestamp < minDate) minDate = timestamp;
            if (timestamp > maxDate) maxDate = timestamp;
        }
        
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy", Locale.getDefault());
        return sdf.format(new Date(minDate)) + " - " + sdf.format(new Date(maxDate));
    }
}
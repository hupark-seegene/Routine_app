package com.squashtrainingapp.ui.activities;

import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ProgressBar;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.charts.PieChart;
import com.github.mikephil.charting.charts.RadarChart;
import com.github.mikephil.charting.components.Legend;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import com.github.mikephil.charting.data.PieEntry;
import com.github.mikephil.charting.data.RadarData;
import com.github.mikephil.charting.data.RadarDataSet;
import com.github.mikephil.charting.data.RadarEntry;
import com.github.mikephil.charting.formatter.IndexAxisValueFormatter;
import com.github.mikephil.charting.formatter.PercentFormatter;
import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.squashtrainingapp.R;
import com.squashtrainingapp.analytics.AnalyticsService;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.ui.adapters.InsightsAdapter;
import com.squashtrainingapp.ui.dialogs.PremiumFeatureDialog;

import java.util.ArrayList;
import java.util.List;

public class AnalyticsDashboardActivity extends AppCompatActivity {
    
    // UI Components
    private Spinner timePeriodSpinner;
    private ChipGroup analyticsTypeChipGroup;
    private ProgressBar progressBar;
    
    // Cards
    private CardView performanceCard;
    private CardView fitnessCard;
    private CardView progressionCard;
    private CardView goalsCard;
    private CardView injuryPreventionCard;
    
    // Charts
    private LineChart performanceChart;
    private PieChart fitnessChart;
    private RadarChart skillRadarChart;
    
    // Text views
    private TextView performanceTrendText;
    private TextView totalWorkoutsText;
    private TextView totalCaloriesText;
    private TextView currentStreakText;
    private TextView goalCompletionText;
    private TextView techniqueScoreText;
    private TextView consistencyScoreText;
    
    // RecyclerViews
    private RecyclerView insightsRecyclerView;
    private RecyclerView recommendationsRecyclerView;
    
    // Services
    private AnalyticsService analyticsService;
    private FirebaseAuthManager authManager;
    
    // Data
    private AnalyticsService.TimePeriod currentPeriod = AnalyticsService.TimePeriod.MONTH;
    private AnalyticsService.AnalyticsType currentType = AnalyticsService.AnalyticsType.PERFORMANCE_METRICS;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_analytics_dashboard);
        
        // Check premium status
        authManager = FirebaseAuthManager.getInstance(this);
        if (!authManager.isPremiumUser()) {
            PremiumFeatureDialog dialog = new PremiumFeatureDialog(this);
            dialog.showForAnalytics();
            finish();
            return;
        }
        
        initializeServices();
        initializeViews();
        setupSpinner();
        setupChipGroup();
        loadAnalyticsData();
    }
    
    private void initializeServices() {
        analyticsService = new AnalyticsService(this);
    }
    
    private void initializeViews() {
        // Back button
        findViewById(R.id.back_button).setOnClickListener(v -> finish());
        
        // Progress bar
        progressBar = findViewById(R.id.progress_bar);
        
        // Time period spinner
        timePeriodSpinner = findViewById(R.id.time_period_spinner);
        
        // Chip group
        analyticsTypeChipGroup = findViewById(R.id.analytics_type_chip_group);
        
        // Cards
        performanceCard = findViewById(R.id.performance_card);
        fitnessCard = findViewById(R.id.fitness_card);
        progressionCard = findViewById(R.id.progression_card);
        goalsCard = findViewById(R.id.goals_card);
        injuryPreventionCard = findViewById(R.id.injury_prevention_card);
        
        // Charts
        performanceChart = findViewById(R.id.performance_chart);
        fitnessChart = findViewById(R.id.fitness_chart);
        skillRadarChart = findViewById(R.id.skill_radar_chart);
        
        // Text views
        performanceTrendText = findViewById(R.id.performance_trend_text);
        totalWorkoutsText = findViewById(R.id.total_workouts_text);
        totalCaloriesText = findViewById(R.id.total_calories_text);
        currentStreakText = findViewById(R.id.current_streak_text);
        goalCompletionText = findViewById(R.id.goal_completion_text);
        techniqueScoreText = findViewById(R.id.technique_score_text);
        consistencyScoreText = findViewById(R.id.consistency_score_text);
        
        // RecyclerViews
        insightsRecyclerView = findViewById(R.id.insights_recycler_view);
        recommendationsRecyclerView = findViewById(R.id.recommendations_recycler_view);
        
        // Setup RecyclerViews
        insightsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        recommendationsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        // Setup charts
        setupCharts();
    }
    
    private void setupSpinner() {
        String[] periods = {"주간", "월간", "3개월", "6개월", "연간", "전체"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, 
                android.R.layout.simple_spinner_item, periods);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        timePeriodSpinner.setAdapter(adapter);
        
        timePeriodSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                switch (position) {
                    case 0:
                        currentPeriod = AnalyticsService.TimePeriod.WEEK;
                        break;
                    case 1:
                        currentPeriod = AnalyticsService.TimePeriod.MONTH;
                        break;
                    case 2:
                        currentPeriod = AnalyticsService.TimePeriod.THREE_MONTHS;
                        break;
                    case 3:
                        currentPeriod = AnalyticsService.TimePeriod.SIX_MONTHS;
                        break;
                    case 4:
                        currentPeriod = AnalyticsService.TimePeriod.YEAR;
                        break;
                    case 5:
                        currentPeriod = AnalyticsService.TimePeriod.ALL_TIME;
                        break;
                }
                loadAnalyticsData();
            }
            
            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });
        
        // Set default selection
        timePeriodSpinner.setSelection(1); // Month
    }
    
    private void setupChipGroup() {
        String[] types = {"성능 지표", "체력 추적", "기술 향상", "목표 달성", "부상 예방"};
        
        for (int i = 0; i < types.length; i++) {
            Chip chip = new Chip(this);
            chip.setText(types[i]);
            chip.setCheckable(true);
            chip.setChecked(i == 0); // First chip selected by default
            
            final int index = i;
            chip.setOnCheckedChangeListener((buttonView, isChecked) -> {
                if (isChecked) {
                    switch (index) {
                        case 0:
                            currentType = AnalyticsService.AnalyticsType.PERFORMANCE_METRICS;
                            showPerformanceView();
                            break;
                        case 1:
                            currentType = AnalyticsService.AnalyticsType.FITNESS_TRACKING;
                            showFitnessView();
                            break;
                        case 2:
                            currentType = AnalyticsService.AnalyticsType.SKILL_PROGRESSION;
                            showProgressionView();
                            break;
                        case 3:
                            currentType = AnalyticsService.AnalyticsType.GOAL_ACHIEVEMENT;
                            showGoalsView();
                            break;
                        case 4:
                            currentType = AnalyticsService.AnalyticsType.INJURY_PREVENTION;
                            showInjuryPreventionView();
                            break;
                    }
                }
            });
            
            analyticsTypeChipGroup.addView(chip);
        }
    }
    
    private void setupCharts() {
        // Performance Line Chart
        performanceChart.getDescription().setEnabled(false);
        performanceChart.setTouchEnabled(true);
        performanceChart.setDragEnabled(true);
        performanceChart.setScaleEnabled(true);
        performanceChart.setPinchZoom(true);
        performanceChart.setDrawGridBackground(false);
        
        XAxis xAxis = performanceChart.getXAxis();
        xAxis.setPosition(XAxis.XAxisPosition.BOTTOM);
        xAxis.setDrawGridLines(false);
        
        // Fitness Pie Chart
        fitnessChart.getDescription().setEnabled(false);
        fitnessChart.setUsePercentValues(true);
        fitnessChart.setExtraOffsets(5, 10, 5, 5);
        fitnessChart.setDragDecelerationFrictionCoef(0.95f);
        fitnessChart.setDrawHoleEnabled(true);
        fitnessChart.setHoleColor(Color.WHITE);
        fitnessChart.setTransparentCircleRadius(61f);
        
        // Skill Radar Chart
        skillRadarChart.getDescription().setEnabled(false);
        skillRadarChart.setWebLineWidth(1f);
        skillRadarChart.setWebColor(Color.LTGRAY);
        skillRadarChart.setWebLineWidthInner(1f);
        skillRadarChart.setWebColorInner(Color.LTGRAY);
        skillRadarChart.setWebAlpha(100);
    }
    
    private void loadAnalyticsData() {
        progressBar.setVisibility(View.VISIBLE);
        
        analyticsService.getAnalyticsDashboard(currentPeriod, new AnalyticsService.AnalyticsCallback() {
            @Override
            public void onSuccess(AnalyticsService.AnalyticsData data) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    updateUI(data);
                });
            }
            
            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(AnalyticsDashboardActivity.this, 
                            "데이터 로드 실패: " + error, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
    
    private void updateUI(AnalyticsService.AnalyticsData data) {
        // Update performance data
        if (data.performanceMetrics != null) {
            updatePerformanceChart(data.performanceMetrics);
            performanceTrendText.setText(String.format("%.1f%%", data.performanceTrend));
            
            if (data.performanceTrend > 0) {
                performanceTrendText.setTextColor(Color.GREEN);
                performanceTrendText.setText("↑ " + performanceTrendText.getText());
            } else if (data.performanceTrend < 0) {
                performanceTrendText.setTextColor(Color.RED);
                performanceTrendText.setText("↓ " + performanceTrendText.getText());
            }
        }
        
        // Update fitness data
        if (data.fitnessStats != null) {
            updateFitnessChart(data.fitnessStats);
            totalCaloriesText.setText(String.valueOf(data.fitnessStats.totalCaloriesBurned));
        }
        
        // Update workout stats
        if (data.workoutStats != null) {
            totalWorkoutsText.setText(String.valueOf(data.workoutStats.totalSessions));
            currentStreakText.setText(data.workoutStats.currentStreak + "일");
        }
        
        // Update skill progression
        if (data.skillProgression != null) {
            updateSkillRadarChart(data.skillProgression);
            techniqueScoreText.setText(data.skillProgression.techniqueScore + "/100");
            consistencyScoreText.setText(data.skillProgression.consistencyScore + "/100");
        }
        
        // Update goals
        if (data.goalStats != null) {
            goalCompletionText.setText(String.format("%.0f%%", data.goalStats.completionRate));
        }
        
        // Update injury prevention
        if (data.injuryPrevention != null && data.injuryPrevention.recommendations != null) {
            updateRecommendations(data.injuryPrevention.recommendations);
        }
        
        // Generate insights
        generateInsights(data);
    }
    
    private void updatePerformanceChart(AnalyticsService.PerformanceMetrics metrics) {
        List<Entry> entries = new ArrayList<>();
        
        // Mock data for demonstration
        entries.add(new Entry(1, metrics.averageShotAccuracy));
        entries.add(new Entry(2, metrics.averagePowerRating));
        entries.add(new Entry(3, metrics.averageSpeedRating));
        entries.add(new Entry(4, metrics.averageRallyLength));
        entries.add(new Entry(5, metrics.courtCoveragePercent));
        
        LineDataSet dataSet = new LineDataSet(entries, "성능 지표");
        dataSet.setColor(Color.BLUE);
        dataSet.setValueTextColor(Color.BLACK);
        dataSet.setLineWidth(2f);
        dataSet.setCircleRadius(4f);
        dataSet.setDrawFilled(true);
        dataSet.setFillColor(Color.BLUE);
        dataSet.setFillAlpha(50);
        
        LineData lineData = new LineData(dataSet);
        performanceChart.setData(lineData);
        performanceChart.invalidate();
    }
    
    private void updateFitnessChart(AnalyticsService.FitnessStats stats) {
        List<PieEntry> entries = new ArrayList<>();
        
        // Mock exercise distribution
        entries.add(new PieEntry(40f, "드릴"));
        entries.add(new PieEntry(30f, "경기"));
        entries.add(new PieEntry(20f, "체력"));
        entries.add(new PieEntry(10f, "기술"));
        
        PieDataSet dataSet = new PieDataSet(entries, "운동 분포");
        
        // Set colors
        ArrayList<Integer> colors = new ArrayList<>();
        colors.add(Color.parseColor("#FF6384"));
        colors.add(Color.parseColor("#36A2EB"));
        colors.add(Color.parseColor("#FFCE56"));
        colors.add(Color.parseColor("#4BC0C0"));
        dataSet.setColors(colors);
        
        dataSet.setValueLinePart1OffsetPercentage(80.f);
        dataSet.setValueLinePart1Length(0.2f);
        dataSet.setValueLinePart2Length(0.4f);
        dataSet.setYValuePosition(PieDataSet.ValuePosition.OUTSIDE_SLICE);
        
        PieData data = new PieData(dataSet);
        data.setValueFormatter(new PercentFormatter());
        data.setValueTextSize(11f);
        data.setValueTextColor(Color.BLACK);
        
        fitnessChart.setData(data);
        fitnessChart.invalidate();
    }
    
    private void updateSkillRadarChart(AnalyticsService.SkillProgression progression) {
        List<RadarEntry> entries = new ArrayList<>();
        
        entries.add(new RadarEntry(progression.techniqueScore));
        entries.add(new RadarEntry(progression.consistencyScore));
        entries.add(new RadarEntry(progression.accuracyScore));
        entries.add(new RadarEntry(85)); // Mock power score
        entries.add(new RadarEntry(78)); // Mock speed score
        
        RadarDataSet dataSet = new RadarDataSet(entries, "기술 레벨");
        dataSet.setColor(Color.BLUE);
        dataSet.setFillColor(Color.BLUE);
        dataSet.setDrawFilled(true);
        dataSet.setFillAlpha(180);
        dataSet.setLineWidth(2f);
        dataSet.setDrawHighlightCircleEnabled(true);
        dataSet.setDrawHighlightIndicators(false);
        
        RadarData data = new RadarData(dataSet);
        data.setValueTextSize(8f);
        data.setDrawValues(true);
        data.setValueTextColor(Color.BLACK);
        
        // Set labels
        String[] labels = {"기술", "일관성", "정확도", "파워", "속도"};
        skillRadarChart.getXAxis().setValueFormatter(new IndexAxisValueFormatter(labels));
        
        skillRadarChart.setData(data);
        skillRadarChart.invalidate();
    }
    
    private void generateInsights(AnalyticsService.AnalyticsData data) {
        List<String> insights = new ArrayList<>();
        
        if (data.performanceTrend > 10) {
            insights.add("🎯 지난 기간 대비 성능이 크게 향상되었습니다!");
        } else if (data.performanceTrend < -10) {
            insights.add("📉 성능이 하락 추세입니다. 훈련 강도를 점검해보세요.");
        }
        
        if (data.workoutStats != null && data.workoutStats.currentStreak > 7) {
            insights.add("🔥 " + data.workoutStats.currentStreak + "일 연속 운동! 훌륭합니다!");
        }
        
        if (data.fitnessStats != null && data.fitnessStats.totalCaloriesBurned > 5000) {
            insights.add("💪 이번 기간 " + data.fitnessStats.totalCaloriesBurned + " 칼로리 소모!");
        }
        
        InsightsAdapter adapter = new InsightsAdapter(insights);
        insightsRecyclerView.setAdapter(adapter);
    }
    
    private void updateRecommendations(List<String> recommendations) {
        InsightsAdapter adapter = new InsightsAdapter(recommendations);
        recommendationsRecyclerView.setAdapter(adapter);
    }
    
    private void showPerformanceView() {
        performanceCard.setVisibility(View.VISIBLE);
        fitnessCard.setVisibility(View.GONE);
        progressionCard.setVisibility(View.GONE);
        goalsCard.setVisibility(View.GONE);
        injuryPreventionCard.setVisibility(View.GONE);
    }
    
    private void showFitnessView() {
        performanceCard.setVisibility(View.GONE);
        fitnessCard.setVisibility(View.VISIBLE);
        progressionCard.setVisibility(View.GONE);
        goalsCard.setVisibility(View.GONE);
        injuryPreventionCard.setVisibility(View.GONE);
    }
    
    private void showProgressionView() {
        performanceCard.setVisibility(View.GONE);
        fitnessCard.setVisibility(View.GONE);
        progressionCard.setVisibility(View.VISIBLE);
        goalsCard.setVisibility(View.GONE);
        injuryPreventionCard.setVisibility(View.GONE);
    }
    
    private void showGoalsView() {
        performanceCard.setVisibility(View.GONE);
        fitnessCard.setVisibility(View.GONE);
        progressionCard.setVisibility(View.GONE);
        goalsCard.setVisibility(View.VISIBLE);
        injuryPreventionCard.setVisibility(View.GONE);
    }
    
    private void showInjuryPreventionView() {
        performanceCard.setVisibility(View.GONE);
        fitnessCard.setVisibility(View.GONE);
        progressionCard.setVisibility(View.GONE);
        goalsCard.setVisibility(View.GONE);
        injuryPreventionCard.setVisibility(View.VISIBLE);
    }
}
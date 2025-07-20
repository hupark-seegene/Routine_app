import React from 'react';
import { View, StyleSheet, Dimensions } from 'react-native';
import Svg, { Path, Line, Text as SvgText, Circle, G } from 'react-native-svg';
import { Colors } from '../../styles/colors';

interface ProgressChartProps {
  data: Array<{
    week: string;
    workouts: number;
    completionRate: number;
  }>;
  height?: number;
  color?: string;
}

export const ProgressChart: React.FC<ProgressChartProps> = ({
  data,
  height = 200,
  color = Colors.primary,
}) => {
  const width = Dimensions.get('window').width - 80;
  const padding = { top: 20, right: 20, bottom: 40, left: 40 };
  const chartWidth = width - padding.left - padding.right;
  const chartHeight = height - padding.top - padding.bottom;

  if (!data || data.length === 0) {
    return (
      <View style={[styles.container, { height }]}>
        <Text style={styles.emptyText}>No data available</Text>
      </View>
    );
  }

  // Calculate scales
  const maxWorkouts = Math.max(...data.map(d => d.workouts));
  const xScale = (index: number) => (index / (data.length - 1)) * chartWidth;
  const yScale = (value: number) => chartHeight - (value / maxWorkouts) * chartHeight;

  // Create path for workouts line
  const workoutsPath = data
    .map((d, i) => {
      const x = xScale(i) + padding.left;
      const y = yScale(d.workouts) + padding.top;
      return `${i === 0 ? 'M' : 'L'} ${x} ${y}`;
    })
    .join(' ');

  // Create path for completion rate line
  const completionPath = data
    .map((d, i) => {
      const x = xScale(i) + padding.left;
      const y = chartHeight - (d.completionRate / 100) * chartHeight + padding.top;
      return `${i === 0 ? 'M' : 'L'} ${x} ${y}`;
    })
    .join(' ');

  return (
    <View style={[styles.container, { height }]}>
      <Svg width={width} height={height}>
        {/* Grid lines */}
        {[0, 0.25, 0.5, 0.75, 1].map((ratio) => (
          <Line
            key={ratio}
            x1={padding.left}
            y1={padding.top + chartHeight * (1 - ratio)}
            x2={padding.left + chartWidth}
            y2={padding.top + chartHeight * (1 - ratio)}
            stroke={Colors.cardBorder}
            strokeWidth="1"
            strokeDasharray="5,5"
          />
        ))}

        {/* Y-axis labels */}
        {[0, 0.25, 0.5, 0.75, 1].map((ratio) => (
          <SvgText
            key={ratio}
            x={padding.left - 10}
            y={padding.top + chartHeight * (1 - ratio) + 5}
            fontSize="12"
            fill={Colors.textSecondary}
            textAnchor="end"
          >
            {Math.round(maxWorkouts * ratio)}
          </SvgText>
        ))}

        {/* Workouts line */}
        <Path
          d={workoutsPath}
          stroke={color}
          strokeWidth="3"
          fill="none"
          strokeLinecap="round"
          strokeLinejoin="round"
        />

        {/* Completion rate line */}
        <Path
          d={completionPath}
          stroke={Colors.success}
          strokeWidth="2"
          fill="none"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeDasharray="5,5"
        />

        {/* Data points */}
        {data.map((d, i) => (
          <G key={i}>
            <Circle
              cx={xScale(i) + padding.left}
              cy={yScale(d.workouts) + padding.top}
              r="5"
              fill={color}
            />
            <Circle
              cx={xScale(i) + padding.left}
              cy={chartHeight - (d.completionRate / 100) * chartHeight + padding.top}
              r="4"
              fill={Colors.success}
            />
          </G>
        ))}

        {/* X-axis labels */}
        {data.map((d, i) => {
          if (i % Math.ceil(data.length / 4) === 0 || i === data.length - 1) {
            return (
              <SvgText
                key={i}
                x={xScale(i) + padding.left}
                y={height - 10}
                fontSize="10"
                fill={Colors.textSecondary}
                textAnchor="middle"
              >
                W{d.week.split('-')[1]}
              </SvgText>
            );
          }
          return null;
        })}
      </Svg>

      <View style={styles.legend}>
        <View style={styles.legendItem}>
          <View style={[styles.legendDot, { backgroundColor: color }]} />
          <Text style={styles.legendText}>Workouts</Text>
        </View>
        <View style={styles.legendItem}>
          <View style={[styles.legendDot, { backgroundColor: Colors.success }]} />
          <Text style={styles.legendText}>Completion %</Text>
        </View>
      </View>
    </View>
  );
};

import { Text } from 'react-native';

const styles = StyleSheet.create({
  container: {
    backgroundColor: Colors.background,
  },
  emptyText: {
    textAlign: 'center',
    color: Colors.textSecondary,
    marginTop: 80,
  },
  legend: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 20,
    marginTop: 10,
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  legendDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  legendText: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
});
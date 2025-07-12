import { WorkoutLog, UserMemo } from '../database/models/types';

interface TrendData {
  date: string;
  value: number;
}

interface PerformanceMetrics {
  skillLevel: number;
  physicalCondition: number;
  mentalState: number;
  injuryRisk: number;
  progressRate: number;
}

export class AdvancedAnalytics {
  // 장기 트렌드 분석
  analyzeLongTermTrends(workoutLogs: WorkoutLog[]): {
    performanceTrend: 'improving' | 'stable' | 'declining';
    plateauDetected: boolean;
    recommendedAction: string;
    projectedProgress: number;
  } {
    if (workoutLogs.length < 10) {
      return {
        performanceTrend: 'stable',
        plateauDetected: false,
        recommendedAction: '더 많은 데이터가 필요합니다.',
        projectedProgress: 0
      };
    }

    // 최근 4주간 데이터 분석
    const recentLogs = workoutLogs.slice(-28);
    const weeklyAverages = this.calculateWeeklyAverages(recentLogs);
    
    // 성과 추세 계산
    const trend = this.calculateTrend(weeklyAverages);
    const plateauDetected = this.detectPlateau(weeklyAverages);
    
    let recommendedAction = '';
    if (plateauDetected) {
      recommendedAction = '정체기가 감지되었습니다. 운동 강도를 15% 높이거나 새로운 훈련 방법을 도입해보세요.';
    } else if (trend === 'improving') {
      recommendedAction = '훌륭한 진전을 보이고 있습니다! 현재 프로그램을 유지하세요.';
    } else if (trend === 'declining') {
      recommendedAction = '성과가 하락 중입니다. 충분한 휴식과 영양 섭취를 확인하세요.';
    }

    const projectedProgress = this.projectFutureProgress(weeklyAverages);

    return {
      performanceTrend: trend,
      plateauDetected,
      recommendedAction,
      projectedProgress
    };
  }

  // 부상 위험 예측
  predictInjuryRisk(workoutLogs: WorkoutLog[]): {
    riskLevel: 'low' | 'medium' | 'high';
    riskFactors: string[];
    preventiveMeasures: string[];
    recoveryDays: number;
  } {
    const recentLogs = workoutLogs.slice(-14); // 최근 2주
    
    let riskScore = 0;
    const riskFactors: string[] = [];
    const preventiveMeasures: string[] = [];

    // 피로도 누적 분석
    const avgFatigue = this.calculateAverage(recentLogs.map(log => log.fatigue_level || 0));
    if (avgFatigue > 7) {
      riskScore += 3;
      riskFactors.push('높은 피로도 누적');
      preventiveMeasures.push('적극적인 회복 운동과 마사지');
    }

    // 급격한 운동량 증가 검사
    const volumeIncrease = this.checkVolumeIncrease(recentLogs);
    if (volumeIncrease > 50) {
      riskScore += 2;
      riskFactors.push('급격한 운동량 증가');
      preventiveMeasures.push('점진적인 운동량 조절');
    }

    // 근육통 지속성 검사
    const persistentSoreness = recentLogs.filter(log => (log.muscle_soreness || 0) > 6).length;
    if (persistentSoreness > 5) {
      riskScore += 2;
      riskFactors.push('지속적인 근육통');
      preventiveMeasures.push('단백질 섭취 증가와 충분한 수면');
    }

    // 수면 품질 검사
    const poorSleep = recentLogs.filter(log => (log.sleep_quality || 0) < 5).length;
    if (poorSleep > 7) {
      riskScore += 1;
      riskFactors.push('불충분한 수면');
      preventiveMeasures.push('수면 환경 개선과 스트레스 관리');
    }

    // 위험 수준 결정
    let riskLevel: 'low' | 'medium' | 'high';
    let recoveryDays = 0;
    
    if (riskScore >= 6) {
      riskLevel = 'high';
      recoveryDays = 3;
      preventiveMeasures.unshift('즉시 2-3일간 완전 휴식 필요');
    } else if (riskScore >= 3) {
      riskLevel = 'medium';
      recoveryDays = 1;
      preventiveMeasures.unshift('운동 강도를 50% 감소');
    } else {
      riskLevel = 'low';
      recoveryDays = 0;
    }

    return {
      riskLevel,
      riskFactors,
      preventiveMeasures,
      recoveryDays
    };
  }

  // 개인화된 운동 추천
  generatePersonalizedWorkout(
    workoutLogs: WorkoutLog[],
    currentPhase: string,
    weaknesses: string[]
  ): {
    recommendedExercises: Array<{
      name: string;
      sets: number;
      reps: number;
      intensity: string;
      focus: string;
    }>;
    optimalTime: string;
    duration: number;
  } {
    // 최적 운동 시간 분석
    const optimalTime = this.findOptimalWorkoutTime(workoutLogs);
    
    // 현재 능력 수준 평가
    const currentCapacity = this.assessCurrentCapacity(workoutLogs);
    
    const recommendedExercises = [];

    // 약점 보완 운동
    if (weaknesses.includes('backhand')) {
      recommendedExercises.push({
        name: '백핸드 월 드릴',
        sets: 4,
        reps: 25,
        intensity: 'medium',
        focus: '정확도와 일관성'
      });
    }

    if (weaknesses.includes('endurance')) {
      recommendedExercises.push({
        name: '고강도 인터벌 러닝',
        sets: 6,
        reps: 1,
        intensity: 'high',
        focus: '심폐지구력'
      });
    }

    if (weaknesses.includes('power')) {
      recommendedExercises.push({
        name: '플라이오메트릭 점프',
        sets: 3,
        reps: 10,
        intensity: 'high',
        focus: '폭발적 파워'
      });
    }

    // 단계별 맞춤 운동
    if (currentPhase === 'peak') {
      recommendedExercises.push({
        name: '경기 시뮬레이션',
        sets: 2,
        reps: 1,
        intensity: 'high',
        focus: '실전 감각'
      });
    }

    // 운동 시간 조정
    const duration = currentCapacity > 80 ? 90 : currentCapacity > 60 ? 75 : 60;

    return {
      recommendedExercises,
      optimalTime,
      duration
    };
  }

  // 스쿼시 기술 분석
  analyzeSquashTechnique(
    memos: UserMemo[],
    workoutLogs: WorkoutLog[]
  ): {
    technicalStrengths: string[];
    areasForImprovement: string[];
    drillRecommendations: Array<{
      skill: string;
      drill: string;
      frequency: string;
    }>;
    tacticalAdvice: string[];
  } {
    const technicalStrengths: string[] = [];
    const areasForImprovement: string[] = [];
    const drillRecommendations: Array<{ skill: string; drill: string; frequency: string }> = [];
    const tacticalAdvice: string[] = [];

    // 메모 분석으로 기술 평가
    const techniqueKeywords = this.extractTechniqueKeywords(memos);
    
    // 강점 식별
    if (techniqueKeywords.forehand > techniqueKeywords.backhand) {
      technicalStrengths.push('포핸드 드라이브');
    } else if (techniqueKeywords.backhand > techniqueKeywords.forehand) {
      technicalStrengths.push('백핸드 컨트롤');
    }

    // 개선 영역 식별
    if (techniqueKeywords.drop < 2) {
      areasForImprovement.push('드롭샷 정확도');
      drillRecommendations.push({
        skill: '드롭샷',
        drill: '전방 코너 드롭샷 반복',
        frequency: '매일 15분'
      });
    }

    if (techniqueKeywords.volley < 3) {
      areasForImprovement.push('발리 반응속도');
      drillRecommendations.push({
        skill: '발리',
        drill: '빠른 발리 교환 연습',
        frequency: '주 3회'
      });
    }

    // 전술 조언
    const avgIntensity = this.calculateAverage(
      workoutLogs.slice(-10).map(log => log.intensity_rating || 0)
    );

    if (avgIntensity > 7) {
      tacticalAdvice.push('높은 강도를 유지하고 있습니다. 경기 중 페이스 조절 연습을 추가하세요.');
    }

    tacticalAdvice.push('상대의 백핸드를 공략하는 크로스코트 샷을 연습하세요.');
    tacticalAdvice.push('T 포지션 복귀를 더 빠르게 하여 코트 커버리지를 개선하세요.');

    return {
      technicalStrengths,
      areasForImprovement,
      drillRecommendations,
      tacticalAdvice
    };
  }

  // 통합 건강 분석
  analyzeHolisticHealth(
    workoutLogs: WorkoutLog[],
    memos: UserMemo[]
  ): {
    healthScore: number;
    sleepQualityTrend: 'improving' | 'stable' | 'declining';
    nutritionRecommendations: string[];
    stressLevel: 'low' | 'medium' | 'high';
    recoveryProtocol: string[];
  } {
    const recentLogs = workoutLogs.slice(-14);
    
    // 건강 점수 계산 (0-100)
    let healthScore = 100;
    
    // 수면 품질 분석
    const avgSleep = this.calculateAverage(recentLogs.map(log => log.sleep_quality || 0));
    const sleepTrend = this.analyzeSleepTrend(recentLogs);
    healthScore -= (10 - avgSleep) * 3;

    // 스트레스 수준 평가
    const stressIndicators = this.detectStressFromMemos(memos);
    let stressLevel: 'low' | 'medium' | 'high' = 'low';
    if (stressIndicators > 5) {
      stressLevel = 'high';
      healthScore -= 20;
    } else if (stressIndicators > 2) {
      stressLevel = 'medium';
      healthScore -= 10;
    }

    // 영양 권장사항
    const nutritionRecommendations: string[] = [];
    if (avgSleep < 6) {
      nutritionRecommendations.push('취침 2시간 전 마그네슘이 풍부한 음식 섭취');
    }
    
    const highIntensityDays = recentLogs.filter(log => (log.intensity_rating || 0) > 7).length;
    if (highIntensityDays > 7) {
      nutritionRecommendations.push('운동 후 30분 이내 탄수화물:단백질 3:1 비율로 섭취');
      nutritionRecommendations.push('하루 체중 1kg당 1.6-2.2g 단백질 섭취');
    }

    // 회복 프로토콜
    const recoveryProtocol: string[] = [];
    if (healthScore < 70) {
      recoveryProtocol.push('매일 10분 명상 또는 호흡 운동');
      recoveryProtocol.push('주 2회 마사지 또는 폼롤러 사용');
      recoveryProtocol.push('취침 1시간 전 전자기기 사용 금지');
    }

    if (stressLevel === 'high') {
      recoveryProtocol.push('요가 또는 필라테스 주 2회 추가');
      recoveryProtocol.push('자연에서 30분 이상 산책');
    }

    return {
      healthScore: Math.max(0, Math.min(100, healthScore)),
      sleepQualityTrend: sleepTrend,
      nutritionRecommendations,
      stressLevel,
      recoveryProtocol
    };
  }

  // 성과 예측 모델
  predictPerformance(
    workoutLogs: WorkoutLog[],
    targetDate: Date
  ): {
    predictedLevel: number;
    confidenceInterval: { lower: number; upper: number };
    keyMilestones: Array<{ date: string; achievement: string }>;
    recommendedIntensity: number;
  } {
    const currentPerformance = this.calculateCurrentPerformance(workoutLogs);
    const improvementRate = this.calculateImprovementRate(workoutLogs);
    
    const daysUntilTarget = Math.ceil(
      (targetDate.getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24)
    );
    
    // 선형 회귀를 사용한 예측
    const predictedLevel = currentPerformance + (improvementRate * daysUntilTarget);
    
    // 신뢰 구간 계산
    const standardError = this.calculateStandardError(workoutLogs);
    const confidenceInterval = {
      lower: predictedLevel - (1.96 * standardError),
      upper: predictedLevel + (1.96 * standardError)
    };

    // 주요 마일스톤 생성
    const keyMilestones = this.generateMilestones(
      currentPerformance,
      predictedLevel,
      daysUntilTarget
    );

    // 권장 운동 강도
    const recommendedIntensity = this.calculateOptimalIntensity(
      currentPerformance,
      improvementRate
    );

    return {
      predictedLevel,
      confidenceInterval,
      keyMilestones,
      recommendedIntensity
    };
  }

  // Helper 함수들
  private calculateWeeklyAverages(logs: WorkoutLog[]): TrendData[] {
    const weeklyData: { [key: string]: number[] } = {};
    
    logs.forEach(log => {
      const weekStart = this.getWeekStart(new Date(log.date));
      const weekKey = weekStart.toISOString().split('T')[0];
      
      if (!weeklyData[weekKey]) {
        weeklyData[weekKey] = [];
      }
      
      const performance = ((log.intensity_rating || 0) + (log.condition_rating || 0)) / 2;
      weeklyData[weekKey].push(performance);
    });

    return Object.entries(weeklyData).map(([date, values]) => ({
      date,
      value: this.calculateAverage(values)
    }));
  }

  private calculateTrend(data: TrendData[]): 'improving' | 'stable' | 'declining' {
    if (data.length < 2) return 'stable';
    
    const firstHalf = data.slice(0, Math.floor(data.length / 2));
    const secondHalf = data.slice(Math.floor(data.length / 2));
    
    const firstAvg = this.calculateAverage(firstHalf.map(d => d.value));
    const secondAvg = this.calculateAverage(secondHalf.map(d => d.value));
    
    const difference = secondAvg - firstAvg;
    
    if (difference > 0.5) return 'improving';
    if (difference < -0.5) return 'declining';
    return 'stable';
  }

  private detectPlateau(data: TrendData[]): boolean {
    if (data.length < 4) return false;
    
    const recentData = data.slice(-4);
    const variance = this.calculateVariance(recentData.map(d => d.value));
    
    return variance < 0.25;
  }

  private calculateAverage(values: number[]): number {
    if (values.length === 0) return 0;
    return values.reduce((a, b) => a + b, 0) / values.length;
  }

  private calculateVariance(values: number[]): number {
    const avg = this.calculateAverage(values);
    const squaredDiffs = values.map(v => Math.pow(v - avg, 2));
    return this.calculateAverage(squaredDiffs);
  }

  private getWeekStart(date: Date): Date {
    const d = new Date(date);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1);
    return new Date(d.setDate(diff));
  }

  private checkVolumeIncrease(logs: WorkoutLog[]): number {
    if (logs.length < 7) return 0;
    
    const firstWeek = logs.slice(0, 7);
    const secondWeek = logs.slice(7, 14);
    
    const firstWeekVolume = firstWeek.filter(log => log.completed).length;
    const secondWeekVolume = secondWeek.filter(log => log.completed).length;
    
    if (firstWeekVolume === 0) return 0;
    
    return ((secondWeekVolume - firstWeekVolume) / firstWeekVolume) * 100;
  }

  private findOptimalWorkoutTime(logs: WorkoutLog[]): string {
    const timePerformance: { [key: string]: number[] } = {};
    
    logs.forEach(log => {
      const hour = new Date(log.created_at || log.date).getHours();
      const timeSlot = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';
      
      if (!timePerformance[timeSlot]) {
        timePerformance[timeSlot] = [];
      }
      
      const performance = (log.condition_rating || 0) + (log.intensity_rating || 0);
      timePerformance[timeSlot].push(performance);
    });

    let bestTime = 'morning';
    let bestScore = 0;
    
    Object.entries(timePerformance).forEach(([time, scores]) => {
      const avgScore = this.calculateAverage(scores);
      if (avgScore > bestScore) {
        bestScore = avgScore;
        bestTime = time;
      }
    });

    const timeMap: { [key: string]: string } = {
      morning: '오전 7-9시',
      afternoon: '오후 2-5시',
      evening: '저녁 6-8시'
    };

    return timeMap[bestTime];
  }

  private assessCurrentCapacity(logs: WorkoutLog[]): number {
    const recentLogs = logs.slice(-7);
    
    const avgIntensity = this.calculateAverage(
      recentLogs.map(log => log.intensity_rating || 0)
    );
    const avgCondition = this.calculateAverage(
      recentLogs.map(log => log.condition_rating || 0)
    );
    const avgFatigue = this.calculateAverage(
      recentLogs.map(log => log.fatigue_level || 0)
    );

    const capacity = ((avgIntensity + avgCondition) * 10) - (avgFatigue * 5);
    return Math.max(0, Math.min(100, capacity));
  }

  private extractTechniqueKeywords(memos: UserMemo[]): {
    [key: string]: number;
  } {
    const keywords = {
      forehand: 0,
      backhand: 0,
      serve: 0,
      volley: 0,
      drop: 0,
      drive: 0,
      boast: 0,
      lob: 0
    };

    memos.forEach(memo => {
      const content = memo.memo.toLowerCase();
      Object.keys(keywords).forEach(keyword => {
        if (content.includes(keyword)) {
          keywords[keyword]++;
        }
      });
    });

    return keywords;
  }

  private analyzeSleepTrend(logs: WorkoutLog[]): 'improving' | 'stable' | 'declining' {
    const sleepData = logs.map(log => log.sleep_quality || 0);
    return this.calculateTrend(
      sleepData.map((value, index) => ({
        date: logs[index].date,
        value
      }))
    );
  }

  private detectStressFromMemos(memos: UserMemo[]): number {
    const stressKeywords = ['스트레스', '압박', '부담', '걱정', '불안', '피곤', '지침'];
    let stressCount = 0;

    memos.forEach(memo => {
      const content = memo.memo.toLowerCase();
      stressKeywords.forEach(keyword => {
        if (content.includes(keyword)) {
          stressCount++;
        }
      });
    });

    return stressCount;
  }

  private calculateCurrentPerformance(logs: WorkoutLog[]): number {
    const recentLogs = logs.slice(-14);
    const performanceScores = recentLogs.map(log => {
      const intensity = log.intensity_rating || 0;
      const condition = log.condition_rating || 0;
      const completion = log.completed ? 10 : 0;
      return (intensity + condition + completion) / 3;
    });

    return this.calculateAverage(performanceScores) * 10;
  }

  private calculateImprovementRate(logs: WorkoutLog[]): number {
    if (logs.length < 30) return 0.1;

    const monthlyPerformance = [];
    for (let i = 0; i < logs.length; i += 30) {
      const monthLogs = logs.slice(i, i + 30);
      monthlyPerformance.push(this.calculateCurrentPerformance(monthLogs));
    }

    if (monthlyPerformance.length < 2) return 0.1;

    const totalImprovement = monthlyPerformance[monthlyPerformance.length - 1] - monthlyPerformance[0];
    const monthsElapsed = monthlyPerformance.length - 1;

    return totalImprovement / (monthsElapsed * 30);
  }

  private calculateStandardError(logs: WorkoutLog[]): number {
    const performances = logs.map(log => 
      ((log.intensity_rating || 0) + (log.condition_rating || 0)) / 2
    );

    const variance = this.calculateVariance(performances);
    return Math.sqrt(variance / performances.length);
  }

  private generateMilestones(
    current: number,
    target: number,
    days: number
  ): Array<{ date: string; achievement: string }> {
    const milestones = [];
    const increment = (target - current) / 4;

    for (let i = 1; i <= 4; i++) {
      const milestoneDate = new Date();
      milestoneDate.setDate(milestoneDate.getDate() + (days * i / 4));
      
      const level = current + (increment * i);
      let achievement = '';
      
      if (level > 80) {
        achievement = '상급 수준 도달';
      } else if (level > 60) {
        achievement = '중상급 수준 도달';
      } else if (level > 40) {
        achievement = '중급 마스터';
      } else {
        achievement = '기초 완성';
      }

      milestones.push({
        date: milestoneDate.toISOString().split('T')[0],
        achievement
      });
    }

    return milestones;
  }

  private calculateOptimalIntensity(performance: number, improvementRate: number): number {
    let baseIntensity = 7;
    
    if (performance > 70) {
      baseIntensity = 8;
    } else if (performance < 40) {
      baseIntensity = 6;
    }

    if (improvementRate > 0.5) {
      baseIntensity += 0.5;
    } else if (improvementRate < 0.1) {
      baseIntensity += 1;
    }

    return Math.min(10, Math.max(5, baseIntensity));
  }

  private projectFutureProgress(weeklyAverages: TrendData[]): number {
    if (weeklyAverages.length < 3) return 0;

    const recentAverages = weeklyAverages.slice(-3);
    const growthRates = [];

    for (let i = 1; i < recentAverages.length; i++) {
      const growth = ((recentAverages[i].value - recentAverages[i-1].value) / recentAverages[i-1].value) * 100;
      growthRates.push(growth);
    }

    const avgGrowthRate = this.calculateAverage(growthRates);
    const fourWeekProjection = recentAverages[recentAverages.length - 1].value * Math.pow(1 + avgGrowthRate/100, 4);

    return Math.round(fourWeekProjection * 10);
  }
}

export const advancedAnalytics = new AdvancedAnalytics();
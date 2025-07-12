import { WorkoutLog, UserMemo, AIAdvice } from '../database/models/types';
import { advancedAnalytics } from './AdvancedAnalytics';

interface AnalysisData {
  recentWorkouts: WorkoutLog[];
  recentMemos: UserMemo[];
  averageIntensity: number;
  averageCondition: number;
  averageFatigue: number;
  completionRate: number;
  currentStreak: number;
  allWorkouts?: WorkoutLog[];
  allMemos?: UserMemo[];
}

export class AIAdvisor {
  // 운동 데이터 분석 (고도화)
  analyzeWorkoutData(data: AnalysisData): AIAdvice[] {
    const advice: AIAdvice[] = [];
    const today = new Date().toISOString().split('T')[0];

    // 기본 분석
    // 1. 피로도 분석
    if (data.averageFatigue > 7) {
      advice.push({
        user_id: 1, // Will be set by caller
        date: today,
        advice_type: 'recovery',
        content: '최근 피로도가 높은 편입니다. 오늘은 가벼운 스트레칭과 회복 운동 위주로 진행하시는 것을 추천합니다. 충분한 수면과 영양 섭취도 중요합니다.'
      } as AIAdvice);
    }

    // 2. 강도 조절 분석
    if (data.averageIntensity > 8 && data.averageCondition < 5) {
      advice.push({
        user_id: 1,
        date: today,
        advice_type: 'program_adjustment',
        content: '운동 강도에 비해 컨디션이 따라가지 못하고 있습니다. 일시적으로 운동 강도를 70-80% 수준으로 낮추고, 점진적으로 올리는 것을 권장합니다.'
      } as AIAdvice);
    }

    // 3. 연속 운동 일수 분석
    if (data.currentStreak > 6) {
      advice.push({
        user_id: 1,
        date: today,
        advice_type: 'recovery',
        content: '일주일 연속 운동하셨네요! 훌륭합니다. 하지만 적절한 휴식도 중요합니다. 이번 주말에는 완전한 휴식일을 가지시는 것을 추천합니다.'
      } as AIAdvice);
    }

    // 4. 완료율 기반 동기부여
    if (data.completionRate < 70) {
      advice.push({
        user_id: 1,
        date: today,
        advice_type: 'motivation',
        content: '최근 운동 완료율이 조금 낮아진 것 같습니다. 작은 목표부터 시작해보세요. 오늘은 30분만이라도 운동해보는 것은 어떨까요?'
      } as AIAdvice);
    } else if (data.completionRate > 90) {
      advice.push({
        user_id: 1,
        date: today,
        advice_type: 'motivation',
        content: '훌륭한 완료율입니다! 꾸준함이 실력 향상의 핵심입니다. 이 페이스를 유지하시면 곧 상급 수준에 도달하실 수 있을 거예요.'
      } as AIAdvice);
    }

    // 고급 분석 추가
    if (data.allWorkouts && data.allWorkouts.length > 10) {
      // 장기 트렌드 분석
      const trendAnalysis = advancedAnalytics.analyzeLongTermTrends(data.allWorkouts);
      if (trendAnalysis.plateauDetected) {
        advice.push({
          user_id: 1,
          date: today,
          advice_type: 'program_adjustment',
          content: trendAnalysis.recommendedAction
        } as AIAdvice);
      }

      // 부상 위험 예측
      const injuryRisk = advancedAnalytics.predictInjuryRisk(data.allWorkouts);
      if (injuryRisk.riskLevel !== 'low') {
        advice.push({
          user_id: 1,
          date: today,
          advice_type: 'recovery',
          content: `부상 위험도: ${injuryRisk.riskLevel === 'high' ? '높음' : '중간'}\n위험 요인: ${injuryRisk.riskFactors.join(', ')}\n예방 조치: ${injuryRisk.preventiveMeasures[0]}`
        } as AIAdvice);
      }

      // 통합 건강 분석
      if (data.allMemos) {
        const healthAnalysis = advancedAnalytics.analyzeHolisticHealth(data.allWorkouts, data.allMemos);
        if (healthAnalysis.healthScore < 70) {
          advice.push({
            user_id: 1,
            date: today,
            advice_type: 'recovery',
            content: `건강 점수가 ${healthAnalysis.healthScore}점으로 낮습니다. ${healthAnalysis.recoveryProtocol[0]}`
          } as AIAdvice);
        }
      }
    }

    return advice;
  }

  // 메모 내용 기반 조언 (고도화)
  analyzeMemoContent(memo: string, allMemos?: UserMemo[], allWorkouts?: WorkoutLog[]): string {
    const lowerMemo = memo.toLowerCase();
    
    // 기본 키워드 분석
    if (lowerMemo.includes('피곤') || lowerMemo.includes('지침') || lowerMemo.includes('힘듦')) {
      return '피로가 누적된 것 같습니다. 운동 강도를 조절하고 충분한 휴식을 취하세요.';
    }
    
    if (lowerMemo.includes('백핸드') || lowerMemo.includes('포핸드')) {
      return '기술 연습에 집중하고 계시네요. 벽치기 연습과 함께 동영상으로 자세를 체크해보세요.';
    }
    
    if (lowerMemo.includes('개선') || lowerMemo.includes('발전') || lowerMemo.includes('좋아')) {
      return '실력이 향상되고 있습니다! 이 긍정적인 에너지를 유지하며 계속 노력하세요.';
    }
    
    if (lowerMemo.includes('부상') || lowerMemo.includes('아프') || lowerMemo.includes('통증')) {
      return '부상 예방이 중요합니다. 충분한 웜업과 쿨다운을 하고, 필요시 전문가의 도움을 받으세요.';
    }

    // 고급 분석 추가
    if (allMemos && allWorkouts && allMemos.length > 5 && allWorkouts.length > 10) {
      const techniqueAnalysis = advancedAnalytics.analyzeSquashTechnique(allMemos, allWorkouts);
      
      // 기술 관련 메모인 경우
      if (lowerMemo.includes('샷') || lowerMemo.includes('스윙') || lowerMemo.includes('자세')) {
        if (techniqueAnalysis.drillRecommendations.length > 0) {
          const recommendation = techniqueAnalysis.drillRecommendations[0];
          return `${recommendation.skill} 향상을 위해 ${recommendation.drill}을 ${recommendation.frequency} 연습하세요.`;
        }
      }
    }
    
    return '꾸준히 기록을 남기는 것이 발전의 지름길입니다. 계속 화이팅!';
  }

  // 주차별 프로그램 조정 제안
  suggestProgramAdjustment(
    weekNumber: number,
    phase: string,
    performance: { intensity: number; condition: number; fatigue: number }
  ): string {
    const { intensity, condition, fatigue } = performance;
    
    // 준비 단계
    if (phase === 'preparation') {
      if (fatigue > 6) {
        return '준비 단계에서 피로도가 높습니다. 운동량을 10-20% 줄이고 회복에 집중하세요.';
      }
      if (condition > 7 && intensity < 6) {
        return '컨디션이 좋으니 운동 강도를 조금 더 높여보세요.';
      }
    }
    
    // 강도 증가 단계
    if (phase === 'intensity') {
      if (fatigue > 7 && condition < 5) {
        return '강도 증가 단계이지만 몸 상태가 따라가지 못하고 있습니다. 2-3일 정도 회복기를 가지세요.';
      }
      if (condition > 8 && fatigue < 4) {
        return '훌륭한 컨디션입니다! 계획된 운동을 100% 수행하세요.';
      }
    }
    
    // 피크 단계
    if (phase === 'peak') {
      if (fatigue > 8) {
        return '피크 단계에서 과도한 피로는 부상 위험을 높입니다. 강도를 유지하되 볼륨을 줄이세요.';
      }
      if (weekNumber > 8) {
        return '장기간 고강도 훈련을 하셨습니다. 다음 주부터는 회복 단계로 전환하세요.';
      }
    }
    
    // 회복 단계
    if (phase === 'recovery') {
      if (condition > 8 && fatigue < 3) {
        return '회복이 잘 되었습니다. 다음 사이클을 준비하세요.';
      }
      return '회복 단계입니다. 가벼운 운동과 충분한 휴식을 취하세요.';
    }
    
    return '현재 상태를 유지하며 계획대로 진행하세요.';
  }

  // 영양 조언
  getNutritionAdvice(workoutType: string, intensity: number): string {
    if (workoutType === 'squash' && intensity > 7) {
      return '고강도 스쿼시 훈련 후에는 탄수화물과 단백질을 30분 이내에 섭취하세요. 바나나와 프로틴 쉐이크가 좋습니다.';
    }
    
    if (workoutType === 'fitness' && intensity > 6) {
      return '근력 운동 후에는 단백질 섭취가 중요합니다. 닭가슴살, 계란, 두부 등을 충분히 섭취하세요.';
    }
    
    return '운동 전후로 충분한 수분 섭취를 하고, 균형 잡힌 식사를 유지하세요.';
  }

  // 부상 예방 조언
  getInjuryPreventionTips(exerciseType: string): string[] {
    const tips: string[] = [];
    
    if (exerciseType === 'squash') {
      tips.push('운동 전 10-15분간 충분한 워밍업을 하세요');
      tips.push('발목과 무릎 보호대 착용을 고려하세요');
      tips.push('급격한 방향 전환 시 무릎이 발끝을 넘지 않도록 주의하세요');
    }
    
    if (exerciseType === 'fitness') {
      tips.push('정확한 자세를 유지하며 운동하세요');
      tips.push('무게를 점진적으로 증가시키세요');
      tips.push('호흡을 규칙적으로 유지하세요');
    }
    
    tips.push('운동 후 5-10분간 쿨다운과 스트레칭을 하세요');
    tips.push('충분한 수면과 영양 섭취로 회복을 도우세요');
    
    return tips;
  }
  // 새로운 고급 기능 추가
  generateComprehensiveReport(
    workoutLogs: WorkoutLog[],
    memos: UserMemo[],
    currentPhase: string
  ): {
    summary: string;
    recommendations: string[];
    nextSteps: string[];
    warnings: string[];
  } {
    const trendAnalysis = advancedAnalytics.analyzeLongTermTrends(workoutLogs);
    const injuryRisk = advancedAnalytics.predictInjuryRisk(workoutLogs);
    const healthAnalysis = advancedAnalytics.analyzeHolisticHealth(workoutLogs, memos);
    const techniqueAnalysis = advancedAnalytics.analyzeSquashTechnique(memos, workoutLogs);
    
    const summary = `현재 성과 추세: ${trendAnalysis.performanceTrend === 'improving' ? '상승' : trendAnalysis.performanceTrend === 'declining' ? '하락' : '정체'}. ` +
                   `건강 점수: ${healthAnalysis.healthScore}/100. ` +
                   `부상 위험도: ${injuryRisk.riskLevel === 'low' ? '낮음' : injuryRisk.riskLevel === 'medium' ? '중간' : '높음'}.`;
    
    const recommendations = [
      ...healthAnalysis.nutritionRecommendations,
      ...injuryRisk.preventiveMeasures.slice(0, 2),
      trendAnalysis.recommendedAction
    ];
    
    const nextSteps = techniqueAnalysis.drillRecommendations.map(
      drill => `${drill.skill}: ${drill.drill} (${drill.frequency})`
    );
    
    const warnings = [];
    if (injuryRisk.riskLevel === 'high') {
      warnings.push('부상 위험이 높습니다. 즉시 휴식을 취하세요.');
    }
    if (healthAnalysis.stressLevel === 'high') {
      warnings.push('스트레스 수준이 높습니다. 정신 건강 관리가 필요합니다.');
    }
    if (trendAnalysis.plateauDetected) {
      warnings.push('성과 정체기입니다. 훈련 방법을 변경해보세요.');
    }
    
    return {
      summary,
      recommendations,
      nextSteps,
      warnings
    };
  }

  // 개인 맞춤형 운동 계획 생성
  generatePersonalizedPlan(
    workoutLogs: WorkoutLog[],
    currentPhase: string,
    targetDate: Date
  ): {
    dailyPlan: Array<{
      day: string;
      exercises: Array<{ name: string; sets: number; reps: number; intensity: string }>;
      duration: number;
    }>;
    weeklyGoals: string[];
    adjustmentTriggers: string[];
  } {
    // 약점 분석
    const weaknesses = this.identifyWeaknesses(workoutLogs);
    
    // 개인화된 운동 생성
    const personalizedWorkout = advancedAnalytics.generatePersonalizedWorkout(
      workoutLogs,
      currentPhase,
      weaknesses
    );
    
    // 성과 예측
    const performancePrediction = advancedAnalytics.predictPerformance(
      workoutLogs,
      targetDate
    );
    
    // 일주일 계획 생성
    const dailyPlan = [];
    const daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];
    
    for (let i = 0; i < 7; i++) {
      if (i === 3 || i === 6) {
        // 휴식일
        dailyPlan.push({
          day: daysOfWeek[i],
          exercises: [],
          duration: 0
        });
      } else {
        dailyPlan.push({
          day: daysOfWeek[i],
          exercises: personalizedWorkout.recommendedExercises,
          duration: personalizedWorkout.duration
        });
      }
    }
    
    const weeklyGoals = [
      `목표 운동 강도: ${performancePrediction.recommendedIntensity}/10`,
      `최적 운동 시간: ${personalizedWorkout.optimalTime}`,
      '주 5회 이상 운동 완료',
      '매일 운동 후 스트레칭 10분'
    ];
    
    const adjustmentTriggers = [
      '피로도가 8 이상일 때: 운동 강도 30% 감소',
      '컨디션이 3 이하일 때: 휴식일로 전환',
      '3일 연속 미수행 시: 운동량 50% 감소 후 재시작'
    ];
    
    return {
      dailyPlan,
      weeklyGoals,
      adjustmentTriggers
    };
  }

  // 약점 식별 헬퍼 함수
  private identifyWeaknesses(workoutLogs: WorkoutLog[]): string[] {
    const weaknesses = [];
    
    const avgIntensity = workoutLogs.reduce((sum, log) => sum + (log.intensity_rating || 0), 0) / workoutLogs.length;
    const avgCondition = workoutLogs.reduce((sum, log) => sum + (log.condition_rating || 0), 0) / workoutLogs.length;
    
    if (avgCondition < 6) {
      weaknesses.push('endurance');
    }
    if (avgIntensity < 6) {
      weaknesses.push('power');
    }
    
    // 메모에서 자주 언급되는 약점 추가
    // 실제 구현에서는 더 정교한 분석 필요
    weaknesses.push('backhand');
    
    return weaknesses;
  }
}

export const aiAdvisor = new AIAdvisor();
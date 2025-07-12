import { TrainingProgram, WeeklyPlan, DailyWorkout, Exercise } from '../database/models/types';

// 4주 프로그램 - 기초 체력 향상 중심
export const fourWeekProgram: TrainingProgram = {
  name: '4주 집중 체력 향상 프로그램',
  duration_type: '4weeks',
  description: '중급에서 상급으로 가기 위한 기초 체력과 스쿼시 기본기 강화'
};

export const fourWeekPlans: WeeklyPlan[] = [
  // Week 1 - Preparation Phase
  { program_id: 1, week_number: 1, phase: 'preparation', focus: '기초 체력 및 적응' },
  // Week 2 - Intensity Building
  { program_id: 1, week_number: 2, phase: 'intensity', focus: '강도 증가 및 기술 연습' },
  // Week 3 - Peak Intensity
  { program_id: 1, week_number: 3, phase: 'peak', focus: '최고 강도 훈련' },
  // Week 4 - Recovery & Test
  { program_id: 1, week_number: 4, phase: 'recovery', focus: '회복 및 성과 측정' }
];

// 12주 프로그램 - 균형잡힌 발전
export const twelveWeekProgram: TrainingProgram = {
  name: '12주 종합 스쿼시 마스터 프로그램',
  duration_type: '12weeks',
  description: '체력, 기술, 전술을 균형있게 발전시키는 중장기 프로그램'
};

export const twelveWeekPlans: WeeklyPlan[] = [
  // Phase 1: Foundation (Weeks 1-3)
  { program_id: 2, week_number: 1, phase: 'preparation', focus: '기초 체력 구축' },
  { program_id: 2, week_number: 2, phase: 'preparation', focus: '기본 기술 정립' },
  { program_id: 2, week_number: 3, phase: 'preparation', focus: '움직임 패턴 개선' },
  
  // Phase 2: Build (Weeks 4-6)
  { program_id: 2, week_number: 4, phase: 'intensity', focus: '근력 및 파워 향상' },
  { program_id: 2, week_number: 5, phase: 'intensity', focus: '스피드 및 민첩성' },
  { program_id: 2, week_number: 6, phase: 'intensity', focus: '지구력 강화' },
  
  // Phase 3: Peak (Weeks 7-9)
  { program_id: 2, week_number: 7, phase: 'peak', focus: '고강도 게임 시뮬레이션' },
  { program_id: 2, week_number: 8, phase: 'peak', focus: '전술 및 전략 훈련' },
  { program_id: 2, week_number: 9, phase: 'peak', focus: '멘탈 및 집중력 강화' },
  
  // Phase 4: Taper & Test (Weeks 10-12)
  { program_id: 2, week_number: 10, phase: 'recovery', focus: '강도 조절 및 기술 정교화' },
  { program_id: 2, week_number: 11, phase: 'recovery', focus: '경기 준비 및 전략 점검' },
  { program_id: 2, week_number: 12, phase: 'recovery', focus: '성과 평가 및 다음 계획' }
];

// 1년 프로그램 - 시합 주기 고려
export const oneYearProgram: TrainingProgram = {
  name: '1년 시즌 마스터플랜',
  duration_type: '1year',
  description: '시합 일정을 고려한 체계적인 연간 트레이닝 계획'
};

// 샘플 운동 템플릿
export const squashSkillExercises: Partial<Exercise>[] = [
  {
    name: '포핸드 드라이브 드릴',
    category: 'skill',
    sets: 3,
    reps: 20,
    intensity: 'medium',
    instructions: '정확한 타점과 스윙 궤적에 집중하며 반복 연습'
  },
  {
    name: '백핸드 크로스코트',
    category: 'skill',
    sets: 3,
    reps: 20,
    intensity: 'medium',
    instructions: '어깨 회전과 체중 이동을 의식하며 연습'
  },
  {
    name: '부스터 샷 연습',
    category: 'skill',
    sets: 5,
    reps: 10,
    intensity: 'high',
    instructions: '빠른 라켓 헤드 스피드와 정확한 컨택 포인트 유지'
  },
  {
    name: '드롭샷 정확도 훈련',
    category: 'skill',
    duration: 15,
    intensity: 'low',
    instructions: '부드러운 터치와 스핀 컨트롤에 집중'
  },
  {
    name: '볼리 반응 훈련',
    category: 'skill',
    duration: 10,
    intensity: 'high',
    instructions: '빠른 반사신경과 정확한 라켓 컨트롤 연습'
  }
];

export const fitnessExercises: Partial<Exercise>[] = [
  // 근력 운동
  {
    name: '스쿼트',
    category: 'strength',
    sets: 4,
    reps: 12,
    intensity: 'medium',
    instructions: '무릎이 발끝을 넘지 않도록 주의, 코어 긴장 유지'
  },
  {
    name: '런지',
    category: 'strength',
    sets: 3,
    reps: 15,
    intensity: 'medium',
    instructions: '균형을 유지하며 앞다리 90도 굽힘'
  },
  {
    name: '플랭크',
    category: 'strength',
    sets: 3,
    duration: 1,
    intensity: 'medium',
    instructions: '엉덩이가 처지거나 올라가지 않도록 일직선 유지'
  },
  {
    name: '메디신볼 로테이션',
    category: 'strength',
    sets: 3,
    reps: 20,
    intensity: 'medium',
    instructions: '코어 회전력 강화, 스쿼시 스윙 동작과 연결'
  },
  
  // 유산소 운동
  {
    name: '인터벌 러닝',
    category: 'cardio',
    duration: 20,
    intensity: 'high',
    instructions: '30초 전력질주, 90초 조깅 반복'
  },
  {
    name: '스텝 운동',
    category: 'cardio',
    duration: 15,
    intensity: 'medium',
    instructions: '스쿼시 풋워크 패턴 적용'
  },
  {
    name: '버피',
    category: 'cardio',
    sets: 4,
    reps: 10,
    intensity: 'high',
    instructions: '전신 협응력과 심폐지구력 향상'
  },
  
  // 민첩성 운동
  {
    name: '래더 드릴',
    category: 'fitness',
    duration: 15,
    intensity: 'medium',
    instructions: '다양한 발놀림 패턴으로 민첩성 향상'
  },
  {
    name: '콘 드릴',
    category: 'fitness',
    duration: 10,
    intensity: 'high',
    instructions: '빠른 방향 전환과 가속력 훈련'
  },
  {
    name: '박스 점프',
    category: 'fitness',
    sets: 3,
    reps: 10,
    intensity: 'high',
    instructions: '폭발적인 파워와 점프력 향상'
  }
];

// 주차별 운동 배정 함수
export function generateDailyWorkouts(weeklyPlanId: number, phase: string): DailyWorkout[] {
  const workouts: DailyWorkout[] = [];
  
  switch (phase) {
    case 'preparation':
      // 준비 단계: 적당한 강도로 시작
      workouts.push(
        { weekly_plan_id: weeklyPlanId, day_of_week: 1, workout_type: 'fitness' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 2, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 3, workout_type: 'fitness' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 4, workout_type: 'rest' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 5, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 6, workout_type: 'fitness' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 7, workout_type: 'rest' }
      );
      break;
      
    case 'intensity':
      // 강도 증가 단계
      workouts.push(
        { weekly_plan_id: weeklyPlanId, day_of_week: 1, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 2, workout_type: 'fitness' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 3, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 4, workout_type: 'fitness' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 5, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 6, workout_type: 'fitness' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 7, workout_type: 'rest' }
      );
      break;
      
    case 'peak':
      // 최고 강도 단계
      workouts.push(
        { weekly_plan_id: weeklyPlanId, day_of_week: 1, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 2, workout_type: 'fitness' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 3, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 4, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 5, workout_type: 'fitness' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 6, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 7, workout_type: 'rest' }
      );
      break;
      
    case 'recovery':
      // 회복 단계
      workouts.push(
        { weekly_plan_id: weeklyPlanId, day_of_week: 1, workout_type: 'fitness' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 2, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 3, workout_type: 'rest' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 4, workout_type: 'squash' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 5, workout_type: 'fitness' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 6, workout_type: 'rest' },
        { weekly_plan_id: weeklyPlanId, day_of_week: 7, workout_type: 'rest' }
      );
      break;
  }
  
  return workouts;
}

// 운동 난이도와 볼륨 조정 함수
export function adjustExerciseIntensity(
  exercise: Exercise,
  phase: string,
  week: number
): Exercise {
  const adjustedExercise = { ...exercise };
  
  switch (phase) {
    case 'preparation':
      // 준비 단계: 기본 강도
      if (adjustedExercise.sets) adjustedExercise.sets = Math.floor(adjustedExercise.sets * 0.8);
      if (adjustedExercise.reps) adjustedExercise.reps = Math.floor(adjustedExercise.reps * 0.8);
      if (adjustedExercise.intensity === 'high') adjustedExercise.intensity = 'medium';
      break;
      
    case 'intensity':
      // 강도 증가 단계: 점진적 증가
      if (adjustedExercise.sets) adjustedExercise.sets = Math.floor(adjustedExercise.sets * 1.1);
      break;
      
    case 'peak':
      // 최고 강도 단계: 최대 볼륨
      if (adjustedExercise.sets) adjustedExercise.sets = Math.floor(adjustedExercise.sets * 1.2);
      if (adjustedExercise.intensity === 'medium') adjustedExercise.intensity = 'high';
      break;
      
    case 'recovery':
      // 회복 단계: 강도 감소
      if (adjustedExercise.sets) adjustedExercise.sets = Math.floor(adjustedExercise.sets * 0.7);
      if (adjustedExercise.reps) adjustedExercise.reps = Math.floor(adjustedExercise.reps * 0.7);
      if (adjustedExercise.intensity === 'high') adjustedExercise.intensity = 'medium';
      if (adjustedExercise.intensity === 'medium') adjustedExercise.intensity = 'low';
      break;
  }
  
  return adjustedExercise;
}
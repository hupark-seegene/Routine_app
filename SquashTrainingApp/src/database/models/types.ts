export interface UserProfile {
  id?: number;
  level: 'beginner' | 'intermediate' | 'advanced';
  created_at?: string;
  updated_at?: string;
}

export interface TrainingProgram {
  id?: number;
  name: string;
  duration_type: '4weeks' | '12weeks' | '1year';
  description?: string;
  created_at?: string;
}

export interface WeeklyPlan {
  id?: number;
  program_id: number;
  week_number: number;
  phase: 'preparation' | 'intensity' | 'recovery' | 'peak';
  focus: string;
}

export interface DailyWorkout {
  id?: number;
  weekly_plan_id: number;
  day_of_week: number; // 1-7
  workout_type: 'squash' | 'fitness' | 'rest';
  exercises?: Exercise[];
}

export interface Exercise {
  id?: number;
  daily_workout_id: number;
  name: string;
  category: 'skill' | 'fitness' | 'cardio' | 'strength';
  sets?: number;
  reps?: number;
  duration_minutes?: number;
  intensity?: 'low' | 'medium' | 'high';
  instructions?: string;
}

export interface WorkoutLog {
  id?: number;
  user_id: number;
  program_id: number;
  workout_id: number;
  date: string;
  duration_minutes: number;
  intensity_level: number; // 1-10
  fatigue_level: number; // 1-10
  condition_score: number; // 1-10
  exercises_completed: number[];
  notes?: string;
  logged_at?: string;
}

export interface UserMemo {
  id?: number;
  user_id: number;
  workout_log_id?: number | null;
  date: string;
  type: string;
  content: string;
  tags?: string;
  created_at?: string;
}

export interface AIAdvice {
  id?: number;
  user_id: number;
  date: string;
  advice_type: string;
  content: string;
  context_data?: any;
  applied?: boolean;
  created_at?: string;
}

export interface NotificationSettings {
  id?: number;
  user_id: number;
  daily_reminder_enabled: boolean;
  daily_reminder_time: string;
  weekly_report_enabled: boolean;
  weekly_report_day: number;
  achievement_alerts: boolean;
  ai_suggestions: boolean;
  push_enabled: boolean;
  email_enabled: boolean;
  updated_at?: string;
}
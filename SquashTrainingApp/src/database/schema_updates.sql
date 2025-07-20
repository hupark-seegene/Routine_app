-- Schema updates for custom exercises and workouts

-- Add custom exercise fields to exercises table
ALTER TABLE exercises ADD COLUMN is_custom INTEGER DEFAULT 0;
ALTER TABLE exercises ADD COLUMN created_by INTEGER;
ALTER TABLE exercises ADD COLUMN created_at TEXT;

-- Create workout_exercises table to link exercises to workouts
CREATE TABLE IF NOT EXISTS workout_exercises (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_id INTEGER NOT NULL,
    exercise_id INTEGER NOT NULL,
    sets TEXT,
    reps TEXT,
    duration TEXT,
    intensity TEXT,
    order_index INTEGER DEFAULT 0,
    FOREIGN KEY (workout_id) REFERENCES daily_workouts(id),
    FOREIGN KEY (exercise_id) REFERENCES exercises(id)
);

-- Add custom workout fields to daily_workouts table
ALTER TABLE daily_workouts ADD COLUMN is_custom INTEGER DEFAULT 0;
ALTER TABLE daily_workouts ADD COLUMN created_by INTEGER;
ALTER TABLE daily_workouts ADD COLUMN created_at TEXT;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_exercises_custom ON exercises(is_custom, created_by);
CREATE INDEX IF NOT EXISTS idx_daily_workouts_custom ON daily_workouts(is_custom, created_by);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_workout ON workout_exercises(workout_id);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_exercise ON workout_exercises(exercise_id);
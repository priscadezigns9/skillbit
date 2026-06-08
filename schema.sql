-- Skillbit Supabase Schema

-- Users table (handled by Supabase Auth)
-- Profiles/Progress table
CREATE TABLE IF NOT EXISTS user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT,
    track TEXT DEFAULT 'Web Dev',
    lessons_completed INTEGER DEFAULT 0,
    xp_total INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    tier TEXT DEFAULT 'free', -- 'free' or 'pro'
    UNIQUE(user_id)
);

-- Completed Lessons table
CREATE TABLE IF NOT EXISTS completed_lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id TEXT NOT NULL,
    score INTEGER NOT NULL, -- Number of correct answers (0-3)
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Leaderboard View
CREATE OR REPLACE VIEW leaderboard AS
SELECT 
    user_id,
    username,
    xp_total as weekly_xp -- Simplified for this implementation, could be filtered by date
FROM 
    user_progress
ORDER BY 
    xp_total DESC
LIMIT 10;

-- RLS (Row Level Security) - Basic setup
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE completed_lessons ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own progress" ON user_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own progress" ON user_progress FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own progress" ON user_progress FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own completed lessons" ON completed_lessons FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own completed lessons" ON completed_lessons FOR INSERT WITH CHECK (auth.uid() = user_id);

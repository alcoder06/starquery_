-- Querynaut — Supabase schema
-- Run this in: Supabase Dashboard → SQL Editor → New query → Run
-- Or apply via: supabase db push (if using the Supabase CLI)

-- ============================================================
-- PROFILES  (one row per auth user, stores the public callsign)
-- ============================================================
CREATE TABLE public.profiles (
  id          UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username    TEXT        UNIQUE NOT NULL
              CONSTRAINT username_length CHECK (char_length(username) BETWEEN 3 AND 20)
              CONSTRAINT username_chars  CHECK (username ~ '^[a-zA-Z0-9_]+$'),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- anyone can read callsigns (needed for leaderboard display)
CREATE POLICY "profiles_read_all"   ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE  USING (auth.uid() = id);

-- ============================================================
-- PROGRESS  (one row per user × exercise, immutable after first solve)
-- ============================================================
CREATE TABLE public.progress (
  user_id     UUID    NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id INTEGER NOT NULL,
  xp_earned   INTEGER NOT NULL CHECK (xp_earned > 0),
  solved_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, exercise_id)
);

ALTER TABLE public.progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "progress_read_own"   ON public.progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "progress_insert_own" ON public.progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "progress_update_own" ON public.progress FOR UPDATE  USING (auth.uid() = user_id);

-- ============================================================
-- LEADERBOARD FUNCTION
-- SECURITY DEFINER so it can aggregate across all users,
-- bypassing RLS on progress (needed for anonymous callers).
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_leaderboard()
RETURNS TABLE (
  username     TEXT,
  total_xp     INTEGER,
  solved_count INTEGER,
  last_active  TIMESTAMPTZ
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    p.username,
    COALESCE(SUM(pr.xp_earned), 0)::INTEGER  AS total_xp,
    COUNT(pr.exercise_id)::INTEGER            AS solved_count,
    MAX(pr.solved_at)                         AS last_active
  FROM profiles p
  LEFT JOIN progress pr ON pr.user_id = p.id
  GROUP BY p.id, p.username
  ORDER BY total_xp DESC, solved_count DESC
  LIMIT 100;
$$;

-- Allow unauthenticated (anon) users to call the leaderboard
GRANT EXECUTE ON FUNCTION public.get_leaderboard TO anon, authenticated;

-- ============================================================
-- TRIGGER — auto-create profile on user signup
-- Reads username from raw_user_meta_data set during signUp().
-- Falls back to a generated callsign if missing.
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _username TEXT;
BEGIN
  _username := NEW.raw_user_meta_data->>'username';
  IF _username IS NULL OR _username = '' THEN
    _username := 'cosmonaut_' || LEFT(REPLACE(NEW.id::TEXT, '-', ''), 8);
  END IF;
  BEGIN
    INSERT INTO profiles (id, username) VALUES (NEW.id, _username);
  EXCEPTION WHEN unique_violation THEN
    -- append short suffix on collision
    INSERT INTO profiles (id, username)
    VALUES (NEW.id, _username || '_' || LEFT(REPLACE(NEW.id::TEXT, '-', ''), 4));
  END;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

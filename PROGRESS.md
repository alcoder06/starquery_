# StarQuery — Project Progress Report
**Date:** June 16, 2026  
**Project:** StarQuery (formerly Querynaut) — SQL Learning Platform  
**Status:** Deployed to production with auth & database backend live

---

## ✅ Completed

### 1. Project Rename & Branding
- Renamed from "Querynaut" to **"StarQuery"**
- Updated all three HTML files (`index.html`, `index.ru.html`, `index.uz.html`)
- Updated title tags, logo text (Q → S), and localStorage keys across all versions

### 2. GitHub Repository Setup
- Created GitHub repository: `https://github.com/alcoder06/starquery_`
- Pushed all project files to `main` and `master` branches
- Fixed git author email to match GitHub account (`alcoder1206@gmail.com`)

### 3. Vercel Deployment
- Deployed to Vercel with auto-redeployment on git push
- Live URL: `https://starquery.vercel.app/`
- Static site hosting with `vercel.json` configuration (`cleanUrls: true`, `trailingSlash: false`)

### 4. Supabase Backend Integration
- **Created Supabase project** with free tier
- **Database schema applied** — SQL migration file (`supabase/migrations/001_initial.sql`) executed:
  - `profiles` table — stores user callsigns (usernames), RLS enabled
  - `progress` table — tracks solved exercises & XP earned per user
  - `get_leaderboard()` function — public leaderboard query, SECURITY DEFINER for anon access
  - Auto-trigger on signup — creates profile with username from auth metadata
  - RLS policies — users can only see/edit their own progress
  
- **Supabase credentials wired into all 3 HTML files:**
  - `SUPABASE_URL: https://zyhnzdsuhejvmffsnsht.supabase.co`
  - `SUPABASE_ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (anon public key)

### 5. Authentication System
- Email/password signup & signin implemented
- User profiles auto-created on signup with username
- Leaderboard queries connected
- `emailRedirectTo: 'https://starquery.vercel.app/'` added to `signUp` call in all 3 HTML files
- Friendly error messages mapped (wrong password, unverified email, rate limit, expired link)
- Verify email banner + Resend button already present in all 3 files
- **Remaining:** Whitelist redirect URL in Supabase Dashboard (see Remaining Manual Step)

### 6. Visual & UX Polish
- Planet icons: upgraded to 3-stop radial-gradient with highlight, midtone, and dark atmospheric limb
- Planet inset depth shadow added to all planets
- Planet hover: glow + scale(1.08) effect using per-module `--glow` color
- Saturn ring (module 7): thicker, 3D gradient border with glow
- Planet sidebar slots: slide-right on hover (`translateX(3px)`)
- `planet-pulse` keyframe: more dramatic 52px outer glow at peak
- Shooting stars: longer trail (170px), brighter center, blur filter, longer travel (340px)
- Leaderboard loading: animated amber spinner next to loading text

---

## 🟡 Remaining Manual Step

### Auth Redirect URL — Supabase Dashboard Config
The `emailRedirectTo` is now wired in code. One manual step remains:

1. Go to Supabase Dashboard → **Authentication** → **URL Configuration**
2. Add to **Redirect URLs**:
   - `https://starquery.vercel.app/`
   - `http://localhost:3000/`
3. Save → email confirmation links will work on production

---

## 📋 Future Work

- Enhanced responsive design for smaller screens
- Mobile app considerations
- Analytics/telemetry
- Orbit animation for moon dots around active planet (requires DOM restructure)
- More exercises / additional modules

---

## 📁 Project Structure

```
starquery_/
├── index.html                          # Main app (English)
├── index.ru.html                       # Russian version
├── index.uz.html                       # Uzbek version
├── vercel.json                         # Vercel deployment config
├── supabase/
│   └── migrations/
│       └── 001_initial.sql             # Database schema
└── PROGRESS.md                         # This file
```

---

## 🔑 Key Credentials & Links

### Repository
- GitHub: `https://github.com/alcoder06/starquery_`
- Main Branch: `main` (deployed to Vercel)

### Deployment
- Vercel URL: `https://starquery.vercel.app/`
- Vercel Dashboard: `https://vercel.com/dashboard`

### Supabase
- Project URL: `https://zyhnzdsuhejvmffsnsht.supabase.co`
- Dashboard: `https://app.supabase.com/`
- Project Name: `StarQuery` (FREE tier)
- Region: Asia-Pacific

### Supabase Configuration Checklist
- [x] Project created
- [x] Database schema applied
- [x] Supabase keys in HTML files
- [ ] **Auth Redirect URLs configured** (BLOCKING)
- [ ] Email confirmations tested
- [ ] Login flow verified

---

## 💡 Technical Details

### Authentication Flow
1. User signs up with email, password, and username
2. Supabase creates auth user
3. Trigger fires: `handle_new_user()` creates profile row with username
4. Confirmation email sent with magic link
5. User clicks link (needs redirect URL configured in Supabase)
6. User can now sign in with email/password
7. Progress & profile data syncs on login

### Database
- `profiles.id` → FK to `auth.users.id` (cascade delete)
- `progress.user_id` → FK to `auth.users.id` (cascade delete)
- RLS policies restrict access to user's own data
- Leaderboard function bypasses RLS via SECURITY DEFINER

### Storage
- User progress saved to Supabase `progress` table
- Fallback localStorage (`starquery_progress_v1`) for offline mode
- Syncs when user logs in

---

## 🚀 Next Steps (Immediate)

1. **Manual step required:**
   - [ ] Add `https://starquery.vercel.app/` and `http://localhost:3000/` to Supabase Auth → URL Configuration → Redirect URLs
   - [ ] Push to git → Vercel auto-redeploys
   - [ ] Test signup → verify email → login on production

---

## 📝 Notes

- App works offline (SQL.js + localStorage fallback)
- Cloud features (auth, leaderboard) require Supabase config + internet
- All three language versions (EN, RU, UZ) share the same backend
- Production URL is live but auth is currently broken due to Redirect URL config

---

**Last Updated:** 2026-06-16  
**Last Editor:** Claude Sonnet 4.6  
**Next Review:** After Supabase redirect URL configured & production tested

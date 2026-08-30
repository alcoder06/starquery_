# StarQuery

A gamified SQL trainer that runs in the browser. Nine modules, 67 exercises, from
`SELECT` to window functions, with every query executed against a real SQLite database
inside the page.

**[Open it](https://starquery.vercel.app/)** — no install, no sign-up needed to start.
Available in [English](https://starquery.vercel.app/),
[Russian](https://starquery.vercel.app/index.ru.html) and
[Uzbek](https://starquery.vercel.app/index.uz.html).

---

## Why it runs entirely in the browser

Most SQL learning sites send your query to a server, run it there, and send back a
result table. That is one round trip per attempt, and learning SQL means making
hundreds of attempts — most of them wrong.

StarQuery loads SQLite compiled to WebAssembly (sql.js 1.8.0) and executes queries
locally. After the initial load, an attempt costs nothing: no request, no waiting, no
failure when the connection drops mid-lesson. That matters for the students this was
built for, on mid-range Android phones and university wifi, where a server round trip
per query is the difference between practising and giving up.

It also means the error messages are SQLite's own. A learner who mistypes `GROUP BY`
sees what a real database says, not a sanitised approximation of it.

## The path through it

| Module | Topic |
|---|---|
| Launch Pad | `SELECT` essentials |
| Navigation | Filtering with `WHERE` |
| Flight Control | Sorting and limits |
| Telemetry | Aggregation and `GROUP BY` |
| Docking | Joins |
| Deep Space | Subqueries and CTEs |
| Warp Drive | Window functions |
| Nebula Challenges | Expert missions |
| Free Flight | Open sandbox against the full schema |

Progress earns XP across seven ranks, Cadet through Fleet Admiral. The ordering is the
argument: joins come before subqueries because a learner who cannot yet join two tables
has no use for a correlated subquery, and window functions come last because they only
make sense once grouping is second nature.

## What the backend does, and what it deliberately does not

Queries never touch a server. Supabase handles only the things that genuinely need
persistence:

- **Accounts** — email and password sign-in
- **`profiles`** — display name, readable by everyone so the leaderboard can show names
- **`progress`** — which exercises a user has solved, readable and writable only by that user
- **Leaderboard** — a `SECURITY DEFINER` function, so ranking never requires exposing
  one user's progress rows to another

Row Level Security is enabled on both tables, with `auth.uid()`-scoped policies. The
Supabase URL and anon key sit in the client source because that is what an anon key is
for; it is the RLS policies, not the secrecy of that key, that protect the data.

Sign-in is optional. Without an account the app keeps progress in `localStorage`, so a
learner who does not want to register still gets the full course.

## Running it locally

There is no build step. Serve the folder:

```bash
python -m http.server 8000
```

Then open `http://localhost:8000`. To point it at your own Supabase project, apply
`supabase/migrations/001_initial.sql` and replace `SUPABASE_URL` and `SUPABASE_ANON_KEY`
near the bottom of each `index*.html`.

## Layout

```
index.html            English
index.ru.html         Russian
index.uz.html         Uzbek
supabase/migrations/  schema, RLS policies, leaderboard function
vercel.json           static hosting config
```

Each language is a self-contained file rather than a shared bundle with a string table.
For a three-language static site with no build step, one file per language is the
simplest thing that works, at the cost of editing three files when a lesson changes.

## Licence

MIT.

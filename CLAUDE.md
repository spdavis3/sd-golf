# sd-golf

Monorepo for the SD Golf app suite. This is a refactor of two existing projects:
- `~/Desktop/golf-tracker` — mobile PWA (vanilla JS) + Python backend (`server.py`)
- `~/Desktop/golf-analysis` — Next.js analysis dashboard

## Structure

```
sd-golf/
├── sd-golf-scorecard/   # Mobile PWA for on-course data entry (vanilla JS)
├── sd-golf-analysis/    # Web analysis dashboard (Next.js)
└── sd-golf-backend/     # Python backend serving both frontends
```

## Apps

### sd-golf-scorecard
Mobile-first PWA for on-course data capture. Installed on phone via manifest/service worker. Refactored from the frontend in `~/Desktop/golf-tracker/static/`.

### sd-golf-analysis
Desktop web app for post-round analysis — handicap tracking, VD match stats, driving/approach/putting breakdowns, trends. Refactored from `~/Desktop/golf-analysis/` (Next.js + Tailwind).

### sd-golf-backend
Python HTTP backend. Currently embedded in `~/Desktop/golf-tracker/server.py`. Will be extracted into its own directory and serve both sd-golf-scorecard and sd-golf-analysis via a shared API.

## Data
- SQLite DB (`golf.db`) — primary store for rounds, holes, and shot data
- JSON files (`rounds.json`, `vd.json`, `v_rounds.json`) — used by golf-analysis, may be consolidated into SQLite in the refactor

## Deployment
- Backend + scorecard currently deployed on Render (`render.yaml`) at http://164.90.139.80
- Analysis app runs locally only (localhost:3007)

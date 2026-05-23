# Tech Stack

## Backend — `sd-golf-backend/`

**FastAPI + SQLite**, deployed on Digital Ocean.

- FastAPI replaces the legacy `BaseHTTPServer` (`server.py`, ~615 lines)
- Same SQLite DB, expanded schema (see `context/schema.md` when written)
- Pydantic models for request/response validation
- `StreamingResponse` for the `/api/feedback` Claude coaching endpoint
- CORS enabled for `localhost:3007` (analysis app)
- Single source of truth for all data — no JSON file stores

## Mobile — `sd-golf-scorecard/`

**SwiftUI**, sideloaded to iPhone via Xcode (free Apple ID, no developer account needed).

- Offline-first: in-progress round stored as `Codable` structs written to `Documents/active_round.json`
- On every shot save: update in-memory state → write to file → background sync to backend
- On app launch: reload file, retry any unsynced rounds
- Server is source of truth; phone is entry device + local cache
- Runs on Mac for development via "Designed for iPhone" destination (no extra code)

## Analysis — `sd-golf-analysis/`

**React + Vite**, runs locally on port 3007.

- All data reads/writes go directly to the FastAPI backend — no intermediate API layer
- React Router for sidebar navigation
- No server-side code — pure client app
- Claude coaching feedback calls FastAPI's `/api/feedback` endpoint (keeps API key server-side)

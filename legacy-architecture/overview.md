# System Overview

Two separate apps that share data, glued together by HTTP.

## Components

```mermaid
graph TB
    subgraph Mobile["Mobile Device (phone or browser)"]
        PWA["Scorecard PWA<br/>(static/index.html, vanilla JS)<br/>IndexedDB cache"]
    end

    subgraph Render["Render — http://164.90.139.80"]
        Backend["Python BaseHTTPServer<br/>server.py (615 lines)"]
        SQLite[("SQLite<br/>rounds.db")]
        VDJsonRemote[["vd.json<br/>(written by backend)"]]
        BubbleCache[["hp_bubble_cache.json"]]
        Backend --> SQLite
        Backend -. writes .-> VDJsonRemote
        Backend --> BubbleCache
    end

    subgraph Localhost["Localhost (Mac)"]
        Next["Next.js Analysis App<br/>(localhost:3007)"]
        NextAPI["Next.js API routes<br/>(/api/hcp/*, /api/rounds/*, /api/feedback)"]
        Next --> NextAPI
        JsonFiles[["~/Desktop/golf-handicap/<br/>rounds.json<br/>vd.json<br/>v_rounds.json"]]
        NextAPI --> JsonFiles
        Claude["Anthropic SDK<br/>(claude-opus-4-6)"]
        NextAPI --> Claude
    end

    PWA -- "fetch /api/rounds<br/>POST /api/sync<br/>POST /api/rounds<br/>POST /api/courses" --> Backend
    PWA -- "fetch /api/hcp/bubble<br/>(direct cross-origin to 3007)" --> NextAPI
    NextAPI -- "GET /api/rounds, /api/rounds/:id<br/>(proxied to backend)" --> Backend
```

## Data flow (round of golf)

```mermaid
sequenceDiagram
    participant U as User (phone)
    participant P as Scorecard PWA
    participant I as IndexedDB
    participant B as Backend (server.py)
    participant DB as SQLite
    participant V as vd.json
    participant A as Analysis App
    participant H as ~/Desktop/golf-handicap/rounds.json

    U->>P: Start round (course, nines, VD on/off)
    P->>I: idbPut(round)
    P->>B: POST /api/sync {rounds:[...]}
    B->>DB: INSERT/UPDATE rounds + holes
    loop Each hole
        U->>P: Tap shot → modal → save
        P->>I: idbPut(round) [updated]
        P->>B: POST /api/sync {rounds:[...]}
        B->>DB: REPLACE holes (per round_id)
    end
    U->>P: Complete round
    P->>B: POST /api/sync (completed=true, vdEndStanding=X)
    B->>DB: UPDATE rounds
    B->>V: append/update entry for date
    U->>A: open localhost:3007/hcp
    A->>B: GET /api/rounds (via proxy)
    A->>H: read rounds.json (handicap source-of-truth)
    A-->>U: render analytics
```

## Three data stores (the real picture)

The system has **three independent data stores**, not one:

| Store | Owner | Used by | Contains |
|-------|-------|---------|----------|
| `rounds.db` (SQLite) | golf-tracker backend | Scorecard PWA, golf-analysis (read-only proxy) | Detailed shot-by-shot round data — primary source for in-app analytics |
| `~/Desktop/golf-handicap/rounds.json` | golf-analysis (Next.js API routes) | HCP page, VD Match, Trends, Bubble | Summary rounds (date, score, rating, slope, differential) — **separate manual entries** going back to 2021 |
| `~/Desktop/golf-handicap/vd.json` | both — backend writes; analysis reads/writes | VD Match page | VD standings history (per date) |

`v_rounds.json` (also in golf-handicap) holds V's rounds and is a similar summary-only file.

There is **partial duplication** between the SQLite `rounds` table and `rounds.json` — they overlap for recent rounds but not for older ones. The refactor will need to decide which is the source-of-truth.

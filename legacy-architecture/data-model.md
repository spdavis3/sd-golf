# Data Model

The system has **three independent data stores** with overlapping but distinct schemas.

```mermaid
erDiagram
    rounds_db_rounds ||--o{ rounds_db_holes : "has many"
    rounds_db_holes }o--|| rounds_db_courses : "joined by course/nines"
    rounds_db_holes ||--o{ shots_json : "embeds JSON array"

    rounds_json {
        int id PK
        string date
        string course
        float rating
        int slope
        int pcc
        int score
        int adj_score
        float differential
        int ghin
        float anti_hcp
        float ave_diff_20
        string notes
    }
    v_rounds_json {
        string id PK
        string date
        string course
        float course_rating
        int course_slope
        int score
        int adj_score
        float differential
        int ghin
        string notes
    }
    vd_json {
        int id PK
        string date
        int vd
        string h
    }

    rounds_db_rounds {
        TEXT id PK
        TEXT date
        TEXT course
        TEXT nines
        TEXT tee
        TEXT conditions
        INT score
        INT completed
        TEXT created_at
        TEXT updated_at
        INT vd
        TEXT vd_honors
        INT vd_ended
        TEXT vd_end_honors
        INT vd_end_standing
        INT vd_start_standing
        TEXT vd_start_strokes
        TEXT vd_strokes_for_next_nine
    }
    rounds_db_holes {
        TEXT id PK
        TEXT round_id FK
        INT hole_number
        INT course_hole_number
        INT par
        INT score
        TEXT shots_json
        INT vd_score
        INT vd_strokes
        REAL vd_net_delta
        REAL vd_standing
        TEXT vd_honors
        INT hdcp
        INT yardage
    }
    rounds_db_courses {
        TEXT id PK
        TEXT name UK
        TEXT nines
        TEXT hole_pars
        TEXT nine_starts
        TEXT hole_hdcp
        TEXT hole_yardages
        TEXT nine_ratings
    }
```

## Store 1: `rounds.db` (SQLite — on Render server)

Three tables, all detailed above in [backend.md](./backend.md#sqlite-schema).

- `rounds` — one row per round, 18 columns including all VD match state
- `holes` — one row per played hole, 14 columns, shots embedded as JSON
- `courses` — one row per course, 8 columns, nearly all data JSON-encoded

## Store 2: `~/Desktop/golf-handicap/rounds.json`

386+ entries going back to 2021. Summary-only — no hole or shot data.

```json
{
  "id": 1,
  "date": "2021-08-22",
  "course": "Foothills to Mountain",
  "rating": 69.6,
  "slope": 128,
  "pcc": 0,
  "score": 111,
  "adj_score": 111,
  "differential": 36.5,
  "ghin": null,
  "anti_hcp": null,
  "ave_diff_20": null,
  "notes": ""
}
```

Used for: WHS handicap calculation (analysis app's `/hcp` page), bubble target, trend lines on `/trends`.

## Store 3: `~/Desktop/golf-handicap/vd.json`

97 entries. VD match running standings.

```json
{
  "id": 1,
  "date": null,
  "vd": 18,         // net standing (D − V); positive = D leads
  "h": null         // honors holder: "d" | "v" | null
}
```

Written by **both** the backend (`_update_vd_json` on completed VD round) **and** the analysis app's `/api/hcp/vd` POST endpoint.

## Store 4: `~/Desktop/golf-handicap/v_rounds.json`

V's summary rounds, schema parallel to `rounds.json`.

```json
{
  "id": "v001",
  "date": "2025-10-05",
  "course": "Foothills to Mountain",
  "course_rating": 69.3,
  "course_slope": 131,
  "score": 85,
  "adj_score": 85,
  "differential": 13.5,
  "ghin": null,
  "notes": ""
}
```

## Shot data model (embedded JSON in `holes.shots_json`)

All shot types share `{ type: string }` discriminator. Full taxonomy:

```mermaid
classDiagram
    class Shot {
      <<abstract>>
      +type: drive|approach|position|short_game|recovery|putt|penalty_marker
    }
    class Drive {
      +driveGrade: + | F | B
      +driveDistance: number
      +drive3w: bool
      +driveLat: L | R
      +driveLatGrade: 1 | 2 | 3
      +driveSD: bool (legacy)
    }
    class Approach {
      +approachType: LA | MA | SA | AW
      +approachClub: 58 | 54 | AW | PW | 9i | 8i | 7i | 6i | 5h | 4h | 5w | 3w
      +approachDifficult: bool
      +approachLat / approachLatGrade
      +approachDepth: S | Lg
      +approachDepthGrade: 1 | 2 | 3
      +approachPenalty: OB | W | L
    }
    class Position {
      +positionType: string
      +positionGrade: + | F | B
      +positionClub: string
      +positionDistance: number | string
      +positionDifficult: bool
      +positionLat / positionLatGrade
      +positionDepth / positionDepthGrade
      +positionPenalty: string
    }
    class ShortGame {
      +shortGameType: C | P | SS | SM | SL | SLP | MS | LSG | LSP | SLG
      +shortGameDifficult: bool
      +lspGrade: + | F | B
      +shortGameLat / shortGameLatGrade
      +shortGameDepth / shortGameDepthGrade
      +shortGamePenalty: string
    }
    class Recovery {
      +recoveryGrade: + | F | B
      +recoveryDifficult: bool
      +recoveryPenalty: bool
    }
    class Putt {
      +puttDistances: number[]
    }
    class PenaltyMarker {
      +penaltyType: string
      +shotCategory: string
      +originalLabel: string
    }
    Shot <|-- Drive
    Shot <|-- Approach
    Shot <|-- Position
    Shot <|-- ShortGame
    Shot <|-- Recovery
    Shot <|-- Putt
    Shot <|-- PenaltyMarker
```

### Approach club categories (used by `/api/directional/approach/*`)

```js
APPROACH_CLUBS = {
  wedge:  ['58', '54', 'AW'],
  short:  ['PW', '9i', '8i'],
  medium: ['7i', '6i'],
  long:   ['5h', '4h', '5w', '3w'],
}
```

### Short-game type abbreviations

| Code | Meaning |
|------|---------|
| `C` | Chip |
| `P` | Pitch |
| `SS` | Sand Short |
| `SM` | Sand Medium |
| `SL` | Sand Long |
| `SLP` | Long Sand Putt-style |
| `MS` | (legacy) Medium Short |
| `LSG`, `LSP`, `SLG` | (legacy) various long-sand variants |

## Overlap & duplication

```mermaid
graph LR
    subgraph "Recent rounds (2026+)"
        DB[rounds.db<br/>full shot data]
        JSON[rounds.json<br/>summary only]
        DB -. same date/score, different IDs .- JSON
    end
    subgraph "Historic rounds (2021–2025)"
        OLDJSON[rounds.json only<br/>no shot data]
    end
```

The `rounds.json` file is **manually maintained** (via `/hcp` page POST/DELETE) and predates the backend SQLite store. New rounds get entered into **both** systems — they're not auto-synced. This is the biggest refactor target: a single source-of-truth.

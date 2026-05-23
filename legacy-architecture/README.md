# Legacy Architecture

Comprehensive snapshot of the **two existing apps** that this monorepo is refactoring:

1. **`golf-tracker`** — Python `server.py` backend + vanilla-JS PWA frontend (the mobile scorecard, deployed at http://164.90.139.80)
2. **`golf-analysis`** — Next.js app (localhost:3007), reads from the tracker backend and from local JSON files in `~/Desktop/golf-handicap/`

| Doc | Contents |
|-----|----------|
| [`overview.md`](./overview.md) | High-level system diagram and data-flow |
| [`backend.md`](./backend.md) | Every endpoint, SQLite schema, all migrations |
| [`scorecard.md`](./scorecard.md) | Mobile PWA — views, IndexedDB cache, shot data model, sync logic |
| [`analysis.md`](./analysis.md) | Next.js app — pages, API routes, JSON file schemas, analytics functions |
| [`data-model.md`](./data-model.md) | Combined data model — DB tables, JSON files, shot type taxonomy |

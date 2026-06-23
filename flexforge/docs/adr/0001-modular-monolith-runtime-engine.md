# ADR 0001 — Modular monolith runtime engine, not microservices

**Status:** Accepted · **Date:** 2026-06

## Context

FlexForge must let one engine serve many apps, expose multiple protocols (REST, GraphQL,
more later), and stay maintainable by a very small team. A natural temptation is to split
the engine into microservices (auth service, data service, GraphQL service, …).

## Decision

The engine is a **modular monolith**: one deployable process, internally divided into
clear modules (`config`, `schema`, `data`, `api.rest`, `api.graphql`, `api.meta`, `auth`,
`bootstrap`) with well-defined seams. One engine **process per deployed app** (the Mendix
model), not a fleet of services per app.

## Why

- **Runtime-engine model fits a monolith.** The whole premise is one interpreter reading
  one in-memory model. Splitting that across network boundaries adds latency, failure
  modes and ops cost for no functional gain.
- **Industry has swung back toward modular monoliths** for exactly this kind of system.
  Even Amazon Prime Video consolidated a microservice pipeline back into a monolith; ~42%
  of microservice adopters have merged some services back, citing debugging complexity and
  operational overhead. A modular monolith typically needs 1–2 ops engineers vs. 2–4+ for
  an equivalent microservice setup — decisive for a solo founder.
- **The seams are already modules.** If a piece ever needs to scale independently (e.g. a
  heavy reporting/query service), the module boundary is the extraction point. Start
  monolith, extract only on evidence.

## UI consequence

The Design/Admin UI is **metadata-driven**: the frontend reads `/__meta` and renders the
entity browser, forms and search from the schema — no app-specific UI code. This is the
same pattern Salesforce Lightning and other low-code platforms use, and it keeps the UI in
lockstep with config automatically.

## Revisit if

- A single engine process must host thousands of tiny apps cheaply → revisit multi-tenant
  routing inside one process, or a control-plane/data-plane split.
- A specific capability (search, analytics) becomes a measured bottleneck → extract that
  one module behind its module seam.

## Sources

- [Microservices vs Modular Monoliths in 2025/2026 — Java Code Geeks](https://www.javacodegeeks.com/2025/12/microservices-vs-modular-monoliths-in-2025-when-each-approach-wins.html)
- [Monolith vs Microservices in 2025 — Foojay](https://foojay.io/today/monolith-vs-microservices-2025/)
- [Breaking the Monolith in 2025: Microservices vs Modular Monolith](https://musesofareticenttechie.blog/2025/08/25/breaking-the-monolith-in-2025-microservices-vs-modular-monolith/)
- [Designing Scalable Metadata-Driven UIs for Dynamic Data Systems — Medium](https://medium.com/@kharshith53/designing-scalable-metadata-driven-uis-for-dynamic-data-systems-c0b3fb7271ce)
- [Metadata-Driven Application Development — ClaySys](https://www.claysys.com/blog/metadata-driven-application-development/)

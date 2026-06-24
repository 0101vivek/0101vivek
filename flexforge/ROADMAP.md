# FlexForge Roadmap

Staged so each version has a clear, demonstrable threshold before moving on.

## ✅ v0 — Engine spike (DONE in this commit)
Runtime engine interpreting a minimal config (entities + fields + CRUD) on H2/Postgres/MySQL,
exposed over **both REST and GraphQL** from the same metadata. Config is loaded, JSON-Schema
validated, and the schema is auto-synced (additive) on boot.
**Threshold met:** an app fully defined by config, no per-app code; integration test drives
REST + GraphQL CRUD end-to-end on H2. ✔

## ✅ v0.5 — Config-driven auth (DONE)
JWT (HS256) auth declared entirely in the `security` config block: `/auth/login`, an
in-config user store (plaintext or BCrypt), and per-entity `read`/`write` role rules
enforced identically across REST and GraphQL via one `AccessGuard`. Disabled by default.
**Threshold met:** login issues a token; role rules gate read vs. write; same rules apply
on both protocols — proven by `SecurityIntegrationTest`. ✔
*(Still to come here: OAuth2/OIDC, API keys, row-level rules — see v3.)*

## ✅ v0.7 — App-builder essentials + admin UI (DONE)
- Declarative **validation** (required/min/max/length/pattern/email)
- **Operator search** (`_like`/`_gt`/`_gte`/`_lt`/`_lte`/`_ne`/`_in`)
- **Relations** via `REFERENCE` fields with app-level integrity
- **Auto timestamps** (`createdAt`/`updatedAt`)
- **/__meta** + **OpenAPI** introspection
- **Metadata-driven admin UI** (entity browser, generated forms, search, login)
- **CORS**; architecture decision recorded (ADR 0001: modular monolith)
**Threshold met:** a non-trivial app (Customer/Product/Order with a relation, validation,
auth) is fully usable from the generated UI and APIs with no app code. ✔

## ✅ v0.8 — Crypto + files + API keys (DONE)
- **Field-level encryption** (AES-256-GCM) via `encrypted: true`, transparent on read
- **FILE** field type: upload / inline download / base64 over `/api/{entity}/{id}/file/{field}`
- **API-key** auth (X-API-Key) alongside JWT, sharing the same AccessGuard
- Reusable `EncryptionService` (AES-GCM, SHA-256, base64)
**Threshold met:** sensitive fields are encrypted at rest; images/documents store and
serve through the API; both verified by tests (17 total passing). ✔

## ✅ v0.9 — P1 platform primitives + AI-ready (DONE, partial)
- **Real-time protocols**: SSE + WebSocket over a CRUD change-event stream
- **Audit log** (`/__audit`) — every CRUD recorded with user/op/entity/id
- **Idempotency** — `Idempotency-Key` header prevents duplicate creates (money-safe)
- **AI flow step** (`ai`) — provider-abstracted (stub offline; OpenAI-compatible with a key);
  the seam where the user's AI modules (RAG/classify/extract/agent) plug in
- **Notification step** (`notify`) + `/__notifications`
**Threshold met:** AI + notify usable inside flows with no external setup; audit and
idempotency verified by tests (29 total passing). ✔
*Still in P1: double-entry ledger, approval/maker-checker step, rules engine, scheduler
trigger, payment connector, MCP protocol.*

## v1 — Production data layer + artifact packaging
- Replace the hand-rolled dialect SQL with **Hibernate 6** (CRUD) + **jOOQ** (complex/dynamic
  queries); keep the `SqlDialect` seam.
- Add **Oracle** and **SQL Server** drivers; rely on Hibernate 6 dialect auto-detection.
- Package per-app artifacts with **Jib** (engine base + config layer); ship platform-hosted
  and `docker run` self-host.
- Conformance test suite running the same config's CRUD against all four engines
  (Testcontainers).
- **Threshold:** the same config runs unmodified on all four engines; an artifact boots
  against a user-supplied DB via env vars.

## v2 — Clean regenerate loop
- Immutable, content-hashed **config versioning** with full history.
- **Liquibase** programmatic diff (desired-from-config vs. live DB) → changeset.
- **Additive vs. destructive classification**; destructive changes require explicit
  preview + approval; pre-apply backup.
- **Expand/contract** migrations + **blue-green** redeploy + rollback.
- **Threshold:** a data-model change deploys with zero downtime behind a clear
  destructive-change gate; rollback works for additive changes.

## v3 — More protocols, richer logic, hot-reload, AI
- **Config hot-reload** for non-schema changes (UI/rules/new endpoint) with zero rebuild.
- More API surfaces over the same core: **gRPC**, **WebSocket subscriptions**, **OData**,
  bulk/batch endpoints, filtering/search DSL.
- **Auth modules** as config: JWT, OAuth2/OIDC, API keys, RBAC/row-level rules.
- **Rules & workflows** engine; relations (1-N, N-N) and computed fields.
- **Third-party integrations** declared in config (webhooks, email/SMS, payment) — wired,
  not hand-coded.
- **AI augmentation** in the design plane: natural language → validated config (never
  source), which keeps everything inside the safe, no-source envelope.
- **Threshold:** turning a protocol or an auth module on/off is a config edit, not code.

## v4 — Scale-out & options
- In-cluster builds (Kaniko), BYO-cloud export (artifact + Helm chart).
- Evaluate a pinned-DB **GraalVM-native** variant for latency-sensitive apps.
- NoSQL field types / external connectors where demand justifies it.
- Multi-tenant routing inside one engine if hosting many tiny apps cheaply.

---

### Guardrails that don't change
- Engine model over code-gen (until a measured bottleneck justifies hot-path compilation).
- Single DB abstraction over per-DB adapters.
- Liquibase migrations; expand/contract + preview/approve + backup, always.
- The config schema is the product — validate every version before it deploys.

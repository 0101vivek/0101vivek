# FlexForge Platform Blueprint

> Synthesis of research across 11+ no-code platforms (Airtable, Retool, Bubble,
> Salesforce, Power Apps/Dataverse, Mendix, OutSystems, Appsmith, Budibase, Supabase,
> Directus, n8n, Zapier, Make) and 16 app categories across 12 industries. This is the
> north star for what FlexForge must become: **one engine that can build any app, fully
> flow/config-driven, no per-app code, AI-ready, with multi-language escape hatches.**

## 1. Vision & non-negotiables

- **No-code for the builder.** The engine is our code; the apps built on it need **zero**
  user code. Everything = declarative config + visual flows.
- **One interpreted engine, one config bundle** (Mendix model). No multi-stack codegen.
- **Modular monolith**, one engine process per app (see ADR 0001).
- **AI-ready by construction.** AI is not a separate runtime — AI steps are ordinary flow
  nodes that reference a model credential + prompt (+ optional memory/vector sub-nodes).
- **Multi-language = pluggable logic, not multiple engines** (see §6).

## 2. The primitive spine (what we must ship)

### 2.1 Typed, pluggable field registry
Each field type = storage + JSON-Schema validation + default UI widget + formula behavior.
- **Core (table stakes):** text, long/rich text, number(int/decimal), currency, percent,
  boolean, date, datetime(tz), single-select, multi-select, email, phone, url,
  attachment/file/image, auto-number/id, created/modified by/at (system audit columns).
- **Computed class (depends on relations):** **formula**, **lookup**, **rollup** (sum/
  count/avg/min/max), **count**.
- **Differentiating:** status, rating, geolocation, barcode/QR, signature, JSON, duration,
  color.
- *FlexForge today:* STRING/TEXT/INT/LONG/DOUBLE/DECIMAL/BOOLEAN/DATE/TIMESTAMP/JSON/
  REFERENCE/FILE + validation + encryption. **Gap:** select/multiselect, currency,
  geo/rating/etc., and the whole computed class (formula/lookup/rollup).

### 2.2 Relations as friendly first-class links (hide FKs)
1:N / N:1, N:N, lookup, and a **master-detail** flavor (cascade + permission inheritance)
that enables rollups. Plus self-referential/hierarchical and (later) polymorphic.
- *Today:* REFERENCE (N:1) with app-level integrity. **Gap:** N:N, master-detail, rollups.

### 2.3 Flow / automation engine — **Trigger → Logic → Action** (building now)
- **Triggers:** webhook/HTTP, schedule/cron, record-created/updated/deleted, form-submit,
  message-queue, manual/sub-flow.
- **Control flow:** condition/branch (router), loop/iterator + aggregator, delay/wait,
  wait-for-event / **human approval**, error handler (retry/backoff + fallback + DLQ).
- **Actions:** DB CRUD, HTTP call, transform/map (expression language), notification
  (email/SMS/Slack/push), file ops, sub-flow, **code step**, set-variable.
- **Execution:** DAG over a shared, audited context; durable/replayable (Temporal-style)
  so long waits, retries and human-in-the-loop are first-class.
- **Uniform step interface** (schema-driven) so every step — incl. AI — is the same shape.

### 2.4 AI steps (slot into the flow engine)
Ordinary nodes referencing a model credential + prompt (+ memory/vector sub-nodes):
- **P0:** LLM chat/completion (provider-abstracted, streaming, JSON output), prompt
  template, RAG retrieval (vector + embeddings + top-K + filters), classification,
  extraction.
- **P1:** embeddings, vector upsert/search, summarization, agent/tool-use (tools = flow
  actions), content moderation/guardrail, image-gen, STT/TTS.
- **AI-readiness enablers:** central secret store, model-provider abstraction (gateway w/
  failover), streaming, memory/context store, pluggable vector-store connector,
  cost/rate limiting + per-node usage metering, eval/guardrail harness.

### 2.5 Connector SDK
Generic OAuth2-capable **REST/GraphQL + OpenAPI-import** core (the universal escape
hatch), with named wrappers on top: Stripe/PayPal, Twilio/Slack, SendGrid/SMTP, S3/Drive,
Google Maps/Calendar, QuickBooks, OpenAI/Anthropic. Connector = auth + action/trigger defs.

### 2.6 Three-layer UI (component / binding / resource)
Auto-generated CRUD screens + the universal view set: **table/grid, form, list/repeater,
detail, kanban, calendar, gallery, charts/KPIs**; plus map/timeline/wizard/custom-plugin.
- *Today:* metadata-driven admin UI (table + generated forms + search + auth). **Gap:**
  kanban/calendar/charts, a visual builder, component/binding model.

### 2.7 Enterprise cross-cutting layer (the moat — build from day one)
Auth + SSO/SAML/OIDC · **RBAC + row-level + field-level security** · **multi-tenant
isolation** · **audit logging** (immutable) · auto-exposed REST/GraphQL/webhook API ·
notifications · search · reporting/dashboards · i18n/l10n (RTL) · **retention rules** ·
app versioning + dev/test/prod environments.
- *Today:* JWT/API-key auth, per-entity role rules, encryption, CORS, OpenAPI. **Gap:**
  row/field-level security, audit log, multi-tenancy, retention, i18n, RBAC depth.

## 3. Cross-industry findings → platform requirements

Recurring needs that MUST be platform primitives (not per-app work), from 12 industries:

| Recurring need | Industries demanding it | → FlexForge primitive |
|---|---|---|
| **Immutable audit trail** of reads & writes | Education (FERPA), HR (EEOC), Gov (FOIA/NARA), Manufacturing (21 CFR 11), CRM (SOC2) | Audit engine (append-only, per entity/field) |
| **Field- & row-level RBAC** | Education, HR (firewall bank/EEO data), Real estate/Hospitality portals | RLS + field-level security |
| **Workflow + SLA/time-based escalation** | Ticketing, Gov case mgmt, QA CAPA, editorial approval | Flow engine + timers + approval step |
| **Real-time external integrations** | Real estate (MLS/IDX), HR (job boards), Food (payments/maps/dispatch) | Connector SDK + event triggers |
| **Payments / PCI tokenization** | Real-estate PM, Food, HR payroll | Centralized payment connector |
| **Custom-schema modeling** (user-defined types) | CMS/Media is literally a mini no-code modeler | Our core data model = this |
| **Join/pivot entities carry the domain** | Enrollment, Application, Lease, Order, Reservation, WorkOrder, Case | First-class N:N + master-detail |
| **Accessibility (WCAG-AA) by default** | Gov (508/ADA), Education, Media | UI builder emits accessible output |
| **Consent / data-subject-rights** | Media, CRM (GDPR/CCPA), Education (consent) | Privacy module (export/delete/consent) |
| **Records retention/disposal rules** | Gov, Manufacturing, HR | Retention engine |
| **Hierarchical / graph data** | Manufacturing genealogy, account hierarchies, org charts | Self-referential relations + tree queries |

**Conclusion:** build a generic **audit + RBAC(row/field) + workflow + connector +
retention** spine once, and most industries become *configuration*, with thin optional
vertical modules (e.g. MLS connector, EBR/genealogy, EEO firewall).

## 4. Architecture decisions (locked)

1. **Runtime interpretation, single engine** — not multi-stack codegen. (ADR 0001)
2. **Modular monolith**, one process per app. (ADR 0001)
3. **Flow engine = DAG of typed nodes** over a shared, audited, replayable context.
4. **Uniform schema-driven step/plugin interface** — classic, AI, and connector steps all
   implement the same contract.
5. **AI as nodes**, with a model-provider gateway, secret store, and vector/memory
   connectors — no separate AI runtime.

## 5. AI module readiness (for the modules you'll bring)
Whatever AI modules you list, they slot in as flow steps implementing `FlowStep` +
declaring a JSON-Schema config. The platform will provide: provider abstraction, secret
injection, streaming, memory store, vector connector, cost/rate limits, and guardrail
hooks — so a new AI module is *config + a step class*, never engine surgery.

## 6. Multi-language support — decision (3 layered escape hatches)
Keep the single Java engine. Deliver "multiple languages" as pluggable logic, **not**
multiple engines:

- **Tier 1 — HTTP / serverless function connector (first).** The engine *calls* a function
  the dev wrote in ANY language (AWS Lambda/Cloud Functions/container). Zero untrusted code
  in our engine; isolation is the cloud's job. Cheapest path to "any language."
- **Tier 2 — inline JS code step.** GraalJS (secure-by-default) for trusted/self-host; for
  untrusted multi-tenant, prefer **quickjs4j (QuickJS-on-Chicory)** — pure-Java, memory-
  safe, no GraalVM-Enterprise license needed for CPU/mem caps. (GraalPy later for Python.)
- **Tier 3 — WASM plugins via Extism + Chicory.** Pure-Java, free, strongly sandboxed;
  authors compile Rust/Go/Zig/AssemblyScript/JS to a `.wasm` plugin for heavy in-process
  logic.
- **Skip:** multi-stack codegen (kills the single-engine thesis) and custom gRPC sidecars
  (high ops cost) until enterprise demand appears.

## 7. Prioritized roadmap (research-aligned)

- **P0 (now): Flow engine core** — DAG executor + uniform step interface + triggers
  (HTTP/manual) + steps (set/transform, condition/branch, DB CRUD, HTTP, respond, log) +
  expression language. *(building this commit)*
- **P0.5:** select/multiselect + computed fields (formula/lookup/rollup) + N:N relations.
- **P1:** AI steps (LLM/prompt/RAG/classify/extract) + provider gateway + secret store +
  vector connector. Code step (Tier-2) + serverless connector (Tier-1).
- **P1.5:** audit engine, row/field-level security, notifications, scheduler trigger.
- **P2:** visual flow + UI builder, kanban/calendar/charts, connector marketplace,
  multi-tenancy, retention, i18n, environments/versioning.
- **P3:** WASM plugins (Tier-3), vertical modules (MLS, EBR/genealogy, payroll), offline.

## 8. Competitive wedge (from the gaps every platform shares)
Research across 19 platforms surfaced the SAME complaints everywhere — these are our
opening:
1. **Vendor lock-in / no export** → FlexForge apps ARE portable config bundles; offer
   export + self-host from day one.
2. **Pricing that explodes at scale** (workload units, per-seat, row caps) → flat,
   self-hostable, no artificial caps.
3. **The "80% wall"** (last 20% impossible) → no-ceiling flow engine + 3-tier code escape
   hatches (§6).
4. **Weak version control** → apps are config, so git branching/diff/multi-env come *free*.
5. **Shallow AI** (black-box prompt-to-app) → AI edits *validated config*, never opaque
   code; stays inside the safe envelope.
6. **Paywalled security** (SSO/RBAC/RLS behind enterprise tiers) → row/field-level security
   ungated.
7. **Only REST** → auto REST + GraphQL + (roadmap) realtime subscriptions + MCP server from
   one model.

**The wedge:** be *config/flow-driven by design* — so portability, versioning, multi-env,
and AI-editability are inherent, not bolted on — while matching Xano-grade backend logic +
Supabase-grade auto APIs + Retool-grade builder in one portable, self-hostable package.

## Source research
Full agent reports synthesized here cover: no-code platform primitives; flow + AI model
(n8n/Zapier/Make/LangGraph); multi-language strategy (GraalVM/quickjs4j/Extism/Chicory/
serverless); and app patterns across Education, Real Estate, HR, Hospitality,
Manufacturing, CRM/Prof-services, Media/CMS, Government/NGO, Healthcare, Fintech,
E-commerce, Logistics.

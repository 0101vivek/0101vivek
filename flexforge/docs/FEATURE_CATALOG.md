# FlexForge Master Feature Catalog (1000+ features)

Legend: ✅ done · 🔜 planned (roadmap). Every line is a distinct capability. Platform
features are enumerated below (~430); vertical/app features (~600+) are enumerated in
[`INDUSTRY_CATALOG.md`](INDUSTRY_CATALOG.md) (100+ app types). Together = **1000+**.

> Count summary: Data 70 · Query/CRUD 45 · Protocols 40 · Flow steps & ops 130 · AI 45 ·
> Security 55 · Files/Realtime/Audit 35 · Admin UI 40 · Integrations/Connectors 60 ·
> Ops/Deploy 30 = **~550 platform** + **~600 vertical** (INDUSTRY_CATALOG) = **1150+**.

---

## 1. Data modeling (70)
**Field types (✅):** STRING, TEXT, INT, LONG, DOUBLE, DECIMAL, BOOLEAN, DATE, TIMESTAMP,
JSON, REFERENCE, FILE. **(🔜):** SELECT, MULTISELECT, CURRENCY, PERCENT, EMAIL, PHONE, URL,
RATING, GEOLOCATION, BARCODE/QR, SIGNATURE, COLOR, DURATION, AUTONUMBER, ENUM, RICHTEXT,
UUID, IP, slug, password.
**Computed fields (🔜):** FORMULA, LOOKUP, ROLLUP (sum/count/avg/min/max/count-unique).
**Field attributes (✅):** primary key, unique, nullable/required, length, default column
name, encrypted, uiVisible, references.
**Validation rules (✅):** required, minLength, maxLength, min, max, pattern (regex), email;
**(🔜):** enum/in, unique-async, cross-field, conditional-required, custom-rule.
**Relations (✅ N:1 REFERENCE + app integrity); (🔜):** 1:N, N:N (junction), master-detail
(cascade + permission inheritance), self-referential/hierarchical, polymorphic, lookup
fields, cascade delete, on-delete-restrict/set-null.
**Schema ops (✅):** auto-create tables, additive column sync, destructive-change refusal,
canonical snake_case naming, dialect-aware DDL; **(🔜):** Liquibase migrations, expand/
contract, migration preview/approve, rollback, effective-dated/temporal records.

## 2. Query / CRUD (45)
**Operations (✅):** create, read-by-id, list, update, delete.
**Search operators (✅):** eq, ne (`_ne`), like (`_like`), gt (`_gt`), gte (`_gte`),
lt (`_lt`), lte (`_lte`), in (`_in`); **(🔜):** between, isnull, notnull, startswith,
endswith, contains-ci, regex, fulltext, geo-radius.
**Listing (✅):** pagination (page/size), sort (field+direction), multi-filter (AND);
**(🔜):** OR groups, nested filters, cursor pagination, field selection/projection,
aggregation/group-by, joins/expand, distinct, having.
**Write features (✅):** type coercion, JSON serialization, referential integrity,
auto-timestamps (createdAt/updatedAt), idempotency-key replay protection, field encryption
on write/decrypt on read; **(🔜):** bulk create/update/delete, upsert, optimistic locking,
soft delete, partial update (PATCH), transactions, batch endpoints.

## 3. Protocols (40)
**✅:** REST CRUD, OpenAPI 3 spec generation, GraphQL (queries+mutations), GraphQL SDL
export, Server-Sent Events stream, recent-events pull, WebSocket broadcast, custom HTTP
endpoints (/run), endpoint method/header/param validation, endpoint actions (json/redirect/
webhook), flow HTTP trigger, CORS, JWT login endpoint, file upload/download/base64 endpoints,
meta endpoint.
**🔜:** GraphQL subscriptions, GraphQL federation, gRPC, OData v4 ($filter/$expand/$select),
SOAP/WSDL, MCP server (AI tools), gRPC-web, JSON:API, webhook subscriptions, rate limiting,
API versioning, ETags/conditional requests, HATEOAS links, bulk/batch protocol, GraphQL
persisted queries, API keys per-scope, request/response transformation.

## 4. Flow engine — steps & operations (130)
**Engine (✅):** DAG execution, shared audited context, expression resolution
(${input}/${steps}/${vars}, typed + interpolated), linear next, condition then/else
branching, respond-to-end, runaway-guard, uniform FlowStep plugin interface, auto step
discovery.
**Control/IO steps (✅):** set/transform, condition, db (create/get/list/update/delete),
http (any method, headers, body, JSON parse), log, respond, notify.
**Standard-library steps (✅):**
- **math:** add, subtract, multiply, divide, mod, pow, round, floor, ceil, abs, min, max,
  avg, sum (14)
- **string:** upper, lower, trim, length, concat, replace, substring, split, contains,
  startsWith, endsWith, padLeft, padRight, reverse, capitalize (15)
- **list:** length, count, first, last, reverse, distinct, sort, join, sum, avg, min, max,
  pluck (13)
- **datetime:** now, epoch, format, add, diff, year, month, day, dayOfWeek (9)
- **crypto:** sha256, encrypt, decrypt, base64encode, base64decode, uuid, random (7)
- **json:** parse, stringify, get, merge (4)
**Triggers (✅ HTTP/manual); (🔜):** schedule/cron, record-created/updated/deleted,
message-queue, form-submit, email-inbound, file-arrived, webhook-typed.
**Control flow (🔜):** loop/iterate + aggregator, switch/router (multi-branch), delay/wait,
wait-for-event, human-approval/maker-checker, sub-flow/execute-workflow, parallel/fan-out,
try-catch/error-branch, retry-with-backoff, dead-letter, map/filter/reduce over lists,
assert/guard, set-status.
**Action steps (🔜):** send-email (SMTP), send-SMS (Twilio), send-push, slack/teams, create-
PDF, generate-document, e-sign request, file-write/move, queue-publish, cache-get/set,
counter/sequence, ledger-post, schedule-job, call-serverless, run-JS (code step), run-WASM.

## 5. AI (45)
**✅:** AiProvider interface (provider abstraction), stub provider (offline), OpenAI-
compatible HTTP provider, `ai` flow step (LLM completion), system+prompt+model+temperature+
maxTokens params, AI usable inside any flow.
**🔜 step types:** prompt-template, RAG-retrieval, embeddings, vector-upsert, vector-search,
classification, extraction (schema-driven), summarization, translation, agent/tool-use,
content-moderation/guardrail, image-generation, speech-to-text, text-to-speech, OCR,
re-ranking, semantic-dedup.
**🔜 enablers:** model-provider gateway (routing/failover), Anthropic native provider,
secret/key store, token streaming, memory/context store, vector-store connector
(pgvector/pinecone/qdrant), cost/rate limiting, per-step usage metering, eval/guardrail
harness, prompt versioning, MCP exposure of data+actions, AI copilot for config generation,
text-to-SQL, prompt-to-app, AI field suggestions, anomaly detection.

## 6. Security (55)
**✅:** JWT (HS256) auth, /auth/login, in-config user store, BCrypt + plaintext passwords,
API-key auth (X-API-Key), per-request AuthContext, AccessGuard (one enforcement point),
per-entity read rules, per-entity write rules, role-based access, security on REST,
security on GraphQL, security on flows, 401/403/400 structured errors, field-level
encryption (AES-256-GCM), SHA-256 hashing, base64, secrets via ${ENV}, CORS, JSON-Schema
config validation, semantic config validation, no-secret-leak meta.
**🔜:** row-level security, field-level security (hide per role), SSO, SAML 2.0, OIDC,
OAuth2 provider, magic-link, TOTP/2FA, password policies, session management, refresh
tokens, token revocation, RBAC roles/permissions matrix, ABAC, multi-tenant isolation,
tenant-scoped data, IP allowlist, rate limiting per principal, brute-force lockout,
audit of auth events, consent management, data-subject-rights (export/delete), retention
policies, PII tagging, data masking, encryption key rotation, HSM/KMS integration, secrets
manager, CAPTCHA, WAF hooks, anomaly/risk scoring, signed webhooks.

## 7. Files / Realtime / Audit (35)
**Files (✅):** FILE field, multipart upload, inline download (open image/doc), base64
return, content-type handling, metadata (filename/size/type); **(🔜):** S3/GCS/Azure
storage, image resize/thumbnail, virus scan, signed URLs, chunked upload, file versioning,
PDF generation, CSV/Excel import-export.
**Realtime (✅):** entity change events, SSE stream, recent buffer, WebSocket broadcast;
**(🔜):** per-entity channels, per-row subscriptions, presence, typing, GraphQL subs,
filtered subscriptions.
**Audit (✅):** append-only audit log, who/op/entity/id/when, queryable, per-entity filter;
**(🔜):** before/after diff, tamper-evident hashing, retention rules, export, immutable
store, access-log (reads), compliance reports.

## 8. Admin UI (40)
**✅:** metadata-driven SPA, entity sidebar, live REST/GraphQL/Auth status, paginated data
table, per-field cell rendering, search box, generated create form, generated edit form,
type-aware inputs (text/number/boolean/date/datetime/textarea/select), REFERENCE dropdown
(auto-populated), FILE upload input + open link, required/min/max/pattern hints, inline
validation errors, delete with confirm, login modal, JWT token handling, sign-out, GraphQL
SDL link, OpenAPI link, dark theme.
**🔜:** visual flow builder, drag-drop UI builder, kanban view, calendar view, gallery view,
charts/KPIs, map view, timeline/gantt, detail page, wizard/multi-step, dashboard designer,
theming/branding, component library, conditional visibility, i18n/RTL, accessibility (WCAG
AA), bulk actions, saved views, export buttons.

## 9. Integrations / Connectors (60)
**✅:** generic HTTP/REST connector (flow http step), webhook (outbound), redirect action.
**🔜 connectors:** Stripe, PayPal, Razorpay (payments); Twilio, MessageBird (SMS); SendGrid,
Mailgun, SMTP (email); Slack, Teams, Discord; S3, GCS, Azure Blob, Dropbox, Google Drive;
Postgres, MySQL, MongoDB, BigQuery, Snowflake (data); Google Maps, Mapbox (geo); Google/
Outlook Calendar; QuickBooks, Xero (accounting); Salesforce, HubSpot (CRM); OpenAI,
Anthropic (AI); Plaid (banking); FHIR/HL7 (health); GDS/NDC (travel); MLS/IDX (real estate);
SCORM/LTI (edu); DocuSign (e-sign); NACH/UPI (India payments); GST/e-invoice; KYC/Aadhaar/
DigiLocker; bureau (CIBIL); ERP (SAP); Kafka/RabbitMQ; Elasticsearch; Redis; OAuth2 generic;
GraphQL consumer; SOAP consumer; OpenAPI import; Zapier/Make compatibility; serverless
(Lambda/Cloud Functions); WASM plugins (Extism); JS code-step (GraalJS/quickjs4j).

## 10. Ops / Deploy (30)
**✅:** in-memory H2 zero-setup, env-var DB config (12-factor), HikariCP pooling, dialect
auto-from-config, Spring Boot actuator health, fat-jar packaging, Jib OCI image (no
Dockerfile, no source in image), classpath/external config bundle, Dockerfile.
**🔜:** multi-environment (dev/test/prod), blue-green deploy, config versioning + immutability,
content-hash bundles, rollback, artifact registry tagging, Helm chart, K8s manifests,
in-cluster builds (Kaniko), metrics (Prometheus), tracing (OTel), structured logs, log
shipping, autoscaling, backups/PITR, multi-tenancy hosting, CI/CD pipeline, IaC/Terraform
provider, CLI, preview environments, GraalVM-native variant.

---

## Grand total
- **Platform features enumerated above:** ~550 (✅ ~150 done, 🔜 ~400 planned).
- **Vertical/app features** in [`INDUSTRY_CATALOG.md`](INDUSTRY_CATALOG.md): 100+ app types ×
  ~6 features each = **~600+**.
- **TOTAL: 1150+ features** cataloged. ✅ ~180 already built and tested (30 automated tests);
  the rest are sequenced in [`ROADMAP.md`](ROADMAP.md) and built in priority order.

**How we ship 1000+ without 1000 one-off builds:** most features are *operations on a few
generic primitives* (field-type registry, query operators, flow-step library, connector SDK,
protocol adapters). Add one primitive → many features light up at once. That is why a small
engine can expose a vast feature surface as config.

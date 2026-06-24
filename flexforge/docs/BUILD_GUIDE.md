# How to Build Your Application on FlexForge

> You build an app by **writing a config bundle (YAML), not code**. The engine reads it and
> becomes your backend — data model, database schema, REST + GraphQL + realtime APIs, auth,
> and business logic — instantly. This guide builds a real **NBFC lending app** step by step.
> The finished bundle is [`examples/lending-app.yaml`](../examples/lending-app.yaml).

## The mental model
```
your app  =  one YAML config bundle   ──▶  FlexForge engine  ──▶  a running backend
            (entities, fields, auth,                            (APIs + UI + DB, no code)
             flows, endpoints)
```
There is **no per-app source code**. To change the app, you change the config and restart
(or hot-reload, roadmap). To run a different app, point the same engine at a different bundle.

## Run any bundle
```bash
FLEXFORGE_CONFIG_PATH=examples/lending-app.yaml mvn spring-boot:run
# open http://localhost:8080/   (the Console renders YOUR app from the bundle)
```

---

## Step 1 — Define your data model (entities + fields)
Each entity becomes a table + REST/GraphQL endpoints automatically.
```yaml
appId: nbfc-lending
entities:
  - name: Borrower
    fields:
      - { name: id,       type: LONG,   pk: true }
      - { name: fullName, type: STRING, length: 200, nullable: false }
      - { name: email,    type: STRING, email: true }
```
**Field types:** STRING, TEXT, INT, LONG, DOUBLE, DECIMAL, BOOLEAN, DATE, TIMESTAMP, JSON,
REFERENCE (relation), FILE (upload). Every field can set: `pk`, `unique`, `nullable`,
`length`, plus validation (below).

## Step 2 — Connect entities (relations)
Use a `REFERENCE` field pointing at another entity. The engine enforces that the referenced
record exists.
```yaml
  - name: LoanApplication
    fields:
      - { name: id,         type: LONG,      pk: true }
      - { name: borrowerId, type: REFERENCE, references: Borrower, nullable: false }
      - { name: amount,     type: DECIMAL,   min: 1000, nullable: false }
```

## Step 3 — Add validation (no code)
```yaml
      - { name: fullName, type: STRING, nullable: false, minLength: 2 }   # required + min length
      - { name: email,    type: STRING, email: true }                     # must be an email
      - { name: phone,    type: STRING, pattern: "^[0-9]{10,15}$" }        # regex
      - { name: amount,   type: DECIMAL, min: 1000, max: 5000000 }        # numeric range
```
Invalid writes return HTTP 400 with a clear `errors[]` list.

## Step 4 — Protect sensitive data (encryption + files)
```yaml
      - { name: pan,    type: STRING, encrypted: true }   # AES-256-GCM at rest, plaintext on read
      - { name: kycDoc, type: FILE }                       # upload/download via /api/Borrower/{id}/file/kycDoc
```

## Step 5 — Turn on auth + role rules (config-driven)
```yaml
security:
  enabled: true
  jwtSecret: ${JWT_SECRET}
  users:
    - { username: officer, password: officer123, roles: [OFFICER] }
    - { username: manager, password: manager123, roles: [MANAGER] }
  rules:
    LoanApplication: { read: [OFFICER, MANAGER], write: [OFFICER] }
    Disbursement:    { write: [MANAGER] }
```
Same rules apply across REST, GraphQL, and flows. Log in at `POST /auth/login` → use the
JWT, or use an `X-API-Key`.

## Step 6 — Business logic as no-code flows
A flow = trigger + steps. Steps read prior data via `${input.x}`, `${steps.id.field}`.
Here is real loan auto-decisioning:
```yaml
flows:
  - name: applyLoan
    steps:
      - id: create                       # 1. create the application
        type: db
        params: { op: create, entity: LoanApplication,
                  data: { borrowerId: "${input.borrowerId}", productId: "${input.productId}",
                          amount: "${input.amount}", status: "SUBMITTED" } }
        next: decide
      - id: decide                        # 2. branch on amount
        type: condition
        params: { left: "${input.amount}", op: "<=", right: 200000 }
        then: approve
        else: review
      - id: approve                       # 3a. auto-approve small loans
        type: db
        params: { op: update, entity: LoanApplication, id: "${steps.create.id}",
                  data: { status: "APPROVED", score: 750 } }
        next: notifyOk
      - id: notifyOk
        type: notify
        params: { channel: log, subject: "Approved", message: "App ${steps.create.id} approved" }
        next: doneOk
      - id: doneOk
        type: respond
        params: { body: { applicationId: "${steps.create.id}", status: "APPROVED" } }
      - id: review                        # 3b. larger loans go to manual review
        type: respond
        params: { body: { applicationId: "${steps.create.id}", status: "MANUAL_REVIEW" } }
```
Run it: `POST /flows/applyLoan/run {"borrowerId":1,"productId":1,"amount":150000}`
→ `{"applicationId":1,"status":"APPROVED"}`. (Amount 300000 → `MANUAL_REVIEW`.)

**Step types available:** `db`, `http`, `condition`, `set`, `respond`, `log`, `notify`,
`ai`, `math`, `string`, `list`, `datetime`, `crypto`, `json` (60+ operations). AI steps
(RAG/classify/extract/agent) plug in the same way.

## Step 7 — Custom endpoints (optional)
```yaml
endpoints:
  - name: health
    method: GET
    action: { type: json, body: { app: "nbfc-lending", ok: true } }   # also: redirect, webhook
```

## Step 8 — Run & use it
```bash
FLEXFORGE_CONFIG_PATH=examples/lending-app.yaml mvn spring-boot:run
```
You instantly get, with no code:
- **Admin Console** at `/` (dashboard, data browser, generated forms, flow runner).
- **REST**: `/api/Borrower`, `/api/LoanApplication`, … (CRUD + search + pagination).
- **GraphQL**: `/graphql` (queries + mutations) and SDL at `/graphql/schema`.
- **OpenAPI**: `/__meta/openapi.json`. **Realtime**: `/realtime/stream`, `/ws/events`.
- **Audit log**: `/__audit`. **Flows**: `/flows/{name}/run`.

## What you did NOT have to do
Write controllers, repositories, DTOs, SQL, migrations, auth filters, validation code,
serializers, an API spec, or a UI. All of that is derived from the bundle by the engine.

## Build YOUR app
Copy `examples/lending-app.yaml`, change `appId`, replace the entities/flows with your
domain, and run. The same pattern builds a clinic, a CRM, a marketplace, an LMS — see
[`INDUSTRY_CATALOG.md`](INDUSTRY_CATALOG.md) for the entities/features each vertical needs,
and [`FEATURE_CATALOG.md`](FEATURE_CATALOG.md) for the full capability list.

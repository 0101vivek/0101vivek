# FlexForge Runtime Engine

> One hardened image. It reads an **immutable config bundle** at startup and *becomes* a
> full backend application — data model, database schema, and **REST + GraphQL** APIs —
> with **no per-app source code** generated anywhere.

This is the architecture Mendix and Retool use in production: a runtime **interpreter**
(not a per-app code generator) plus a versioned config bundle. The config is the single
source of truth; "regenerate" means produce a new bundle and redeploy — there is no
round-trip/merge problem because there is no hand-written source to overwrite.

## Why this design

| Requirement | How FlexForge satisfies it |
|---|---|
| **Multi-database** | One DB-agnostic layer (`SqlDialect`, dialect chosen at boot). v0 ships H2/Postgres/MySQL; production delegates to Hibernate 6 + jOOQ. |
| **No source exposure** | There is no per-app source. Only declarative config exists, so there is nothing to leak. |
| **Clean regenerate loop** | Config is versioned + immutable; schema changes are additive-first with a destructive-change gate (full Liquibase expand/contract in v2). |
| **One model, many protocols** | The **same metadata** is projected onto REST *and* GraphQL, both backed by the same generic CRUD service. gRPC / WebSocket / OData are roadmap surfaces that plug into the same core. |

### What's implemented now

- **Config-defined entities/fields** → tables auto-created on boot (additive sync)
- **REST + GraphQL** from one model, plus an auto-generated **OpenAPI** spec
- **Config-driven JWT auth** + **API-key** (X-API-Key) auth + per-entity read/write **role rules** (one `AccessGuard` for every protocol)
- **Field-level encryption** (`encrypted: true` → AES-256-GCM at rest, transparent on read)
- **File/image/document fields** (`FILE`): upload, inline download, base64 — `/api/{entity}/{id}/file/{field}`
- **Declarative validation** (required, min/max, minLength/maxLength, pattern, email)
- **Operator search**: `?field_like=`, `_gt`, `_gte`, `_lt`, `_lte`, `_ne`, `_in`
- **Relations** (`REFERENCE` fields) with app-level integrity — entities **connect**
- **Auto timestamps** (`createdAt`/`updatedAt`) by convention
- **Metadata-driven admin UI** at `/` — entity browser, generated CRUD forms, search, login
- **Multi-DB** dialect layer (H2 / Postgres / MySQL), chosen at boot · **CORS** enabled

Open **http://localhost:8080/** after starting for the admin UI.

## Run it (zero setup)

```bash
cd flexforge
mvn spring-boot:run
```

The bundled config (`src/main/resources/config/app.yaml`) defines a small CRM
(`Customer`, `Product`) and runs on in-memory H2. The engine creates the tables on boot.

### Point the same image at a real database

Connection details come from the environment (12-factor) — the image never changes:

```bash
export DB_ENGINE=postgres
export DB_URL='jdbc:postgresql://localhost:5432/crm'
export DB_USERNAME=crm
export DB_PASSWORD=secret
mvn spring-boot:run
```

### Run a different app with the same engine

```bash
export FLEXFORGE_CONFIG_PATH=/path/to/your/app.yaml
mvn spring-boot:run
```

## Try the APIs

**REST**

```bash
# create
curl -s -X POST localhost:8080/api/Customer \
  -H 'Content-Type: application/json' \
  -d '{"email":"ada@example.com","fullName":"Ada Lovelace","tier":"gold","active":true}'

# list (paginated + filterable: ?page=0&size=20&sort=email&tier=gold)
curl -s localhost:8080/api/Customer

# read / update / delete
curl -s localhost:8080/api/Customer/1
curl -s -X PUT localhost:8080/api/Customer/1 -H 'Content-Type: application/json' -d '{"tier":"platinum"}'
curl -s -X DELETE localhost:8080/api/Customer/1
```

**GraphQL** (same data, same service)

```bash
curl -s -X POST localhost:8080/graphql -H 'Content-Type: application/json' -d '{
  "query": "mutation { createProduct(input:{sku:\"SKU-1\",name:\"Widget\",inStock:true}){ id sku name } }"
}'

curl -s -X POST localhost:8080/graphql -H 'Content-Type: application/json' \
  -d '{"query":"{ productList { id sku name price } }"}'

# generated SDL:
curl -s localhost:8080/graphql/schema
```

## Auth — configured, not coded

Authentication is a config block, not hand-written code. Turn it on, declare users/roles
and per-entity rules; the engine enforces them across **both** REST and GraphQL (they share
one `AccessGuard`). Disabled by default, so open apps are unaffected.

```yaml
security:
  enabled: true
  jwtSecret: ${JWT_SECRET}        # HS256; use a strong env value in prod
  tokenTtlMinutes: 60
  users:
    - { username: admin,  password: admin123,  roles: [ADMIN] }   # plaintext or $2a$ bcrypt
    - { username: viewer, password: viewer123, roles: [VIEWER] }
  rules:
    Customer:
      read:  [ADMIN, VIEWER]      # empty/omitted = any authenticated user
      write: [ADMIN]
```

```bash
# log in → JWT
TOKEN=$(curl -s -X POST localhost:8080/auth/login -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123"}' | jq -r .token)

# call protected endpoints (REST and GraphQL both honor the same rules)
curl -s localhost:8080/api/Customer -H "Authorization: Bearer $TOKEN"
```

OAuth2/OIDC and external identity providers plug into the same `AuthContext`/`AccessGuard`
seam (see ROADMAP).

## How a request flows

```
HTTP (REST or GraphQL)
        │
        ▼
  Protocol surface  ─────────────┐   (DynamicRestController / GraphQLController)
        │                        │
        ▼                        ▼
  DynamicCrudService  ◄── MetadataRegistry (the in-memory config model)
        │                        ▲
        ▼                        │
  SqlDialect ──► parameterized SQL ──► HikariCP ──► your database
```

On startup: load bundle → **validate** (JSON Schema + semantic rules) → choose dialect →
build datasource → **sync schema** (additive) → expose enabled protocols.

## Build & test

```bash
mvn test        # boots on H2, exercises REST + GraphQL CRUD end-to-end
mvn package     # fat jar
mvn compile jib:build -Dimage=ghcr.io/you/flexforge-engine:0.1.0   # OCI image, no Dockerfile, no source in image
```

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the full design and decisions, and
[`ROADMAP.md`](ROADMAP.md) for the staged plan (v0 → v4).

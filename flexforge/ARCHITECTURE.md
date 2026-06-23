# FlexForge Architecture

## The one-line thesis

Ship a **packaged runtime-interpretation engine** plus a versioned config bundle — **not**
a per-app code generator. A deployed app = (the same engine image) + (an immutable, signed
config bundle). This is the Mendix/Retool model and it solves all the hard requirements
with the least code.

## Two planes

1. **FlexForge Design Platform** *(future)* — where apps are authored: visual/config
   editor, version store, migration previewer, artifact builder, AI config generation. It
   **produces** config bundles.
2. **FlexForge Runtime Engine** *(this repo)* — the shipped interpreter. It **runs**
   bundles. Stateless, one process per deployed app.

> The **config schema is the real product.** Everything downstream — the engine,
> migrations, the protocol surfaces, future AI — keys off it. It is validated by JSON
> Schema (`src/main/resources/schema/flexforge-config.schema.json`) before anything can
> deploy.

## Engine internals (v0, implemented)

```
config/                         config bundle (YAML/JSON) — the single source of truth
config.ConfigLoader             parse bundle → AppConfig (POJOs, field-access Jackson)
config.ConfigValidator          JSON Schema (structure) + semantic rules (1 PK, no dup names)
config.MetadataRegistry         the parsed model, held in memory; every layer reads it

schema.SqlDialect (+ H2/PG/MySQL)  per-DB type mapping, identifier quoting, identity, pagination
schema.Naming                   one canonical convention (snake_case, quoted) for all engines
schema.SchemaManager            create tables + additive column sync; refuses destructive changes

data.DynamicCrudService         ONE generic CRUD engine — builds parameterized SQL from metadata
data.QueryOptions / Page        pagination, sorting, equality filters

api.rest.DynamicRestController  /api/{entity} CRUD — every entity, one controller
api.graphql.GraphQLSchemaBuilder  builds a GraphQL schema at runtime from the same metadata
api.graphql.GraphQLController   /graphql endpoint + /graphql/schema SDL

bootstrap.EngineConfiguration   composition root: load→validate→datasource→dialect→beans
bootstrap.EngineBootstrap       runs schema sync on startup (before traffic)
```

The decisive property: **REST and GraphQL are both thin projections over the one
`DynamicCrudService`.** Adding a protocol (gRPC, OData, WebSocket subscriptions) means
adding a surface that calls the same service — the data model and business logic are never
re-implemented per protocol. That is what "one platform that can do everything" means in
practice.

## Multi-database strategy

A single database-agnostic layer, **not** per-DB adapters (per-DB adapters = N× the code,
bugs, and test matrix for one team).

- **v0 (this repo):** a small hand-rolled `SqlDialect` abstraction over H2/Postgres/MySQL,
  proving the seam: one config, parameterized SQL, dialect chosen at boot.
- **Production target:** Hibernate 6 (CRUD; its `Dialect` hierarchy already encapsulates
  pagination, identity/sequence, type mapping, and auto-detects from JDBC metadata) + jOOQ
  (the ~30% of complex/dynamic SQL) + **Liquibase** for cross-DB DDL.
- Reserve thin per-engine handling only for non-abstractable edges (JSON operators,
  `CREATE INDEX CONCURRENTLY`, identity edge cases) behind capability flags.
- Constrain the portable feature set to the **four-engine intersection**; opt-in
  extensions per engine. JSON maps to the native type per dialect (Postgres `JSONB`,
  MySQL `JSON`), with portable query semantics only.

## Decisions (carried from the design brief)

| Decision | Choice | Not |
|---|---|---|
| Architecture | Packaged runtime engine + config bundle | per-app code-gen |
| DB layer (prod) | Hibernate 6 + jOOQ + Liquibase | hand-built per-DB adapters |
| Image builder | Google **Jib** (JVM mode) — no Dockerfile, **no source in image** | GraalVM native (defer), Buildpacks (heavier) |
| Migrations | **Liquibase** (db-agnostic changelog + programmatic diff) | Flyway (4× SQL scripts) |
| ID strategy | **SEQUENCE**-style where supported (keeps Hibernate JDBC batching) | IDENTITY everywhere |
| Migration safety | expand/contract + preview/approve + pre-apply backup, **always** | silent destructive DDL |
| Config delivery | immutable, versioned bundle as an image layer; secrets via env | baking secrets into images |

## Deployment model (target)

A per-app artifact = prebuilt engine base image + the config bundle as a thin top layer
(Jib keeps the heavy engine/deps layers shared and cached). Tag by `{appId}:{configVersion}`
for traceability and rollback. Offer: (1) platform-hosted, (2) one-command `docker run`
self-host, (3) BYO-cloud export later.

## Known edges & risks

- **Schema migration across regenerations is the #1 risk** — mitigated by
  expand/contract, mandatory destructive-change approval, pre-apply backup, batched
  backfills. (v0 only does additive auto-sync; the full gate is v2.)
- **Liquibase abstraction leaks** for engine-specific DDL → drop to raw-SQL changesets
  behind per-engine flags.
- **Single-engine blast radius** — pin each app to a tested engine version; canary engine
  upgrades; never force-upgrade without re-running conformance tests.
- **Interpretation overhead** — negligible for typical CRUD; cache compiled config
  representations (as Mendix holds the model in memory) before ever considering code-gen.

## What v0 deliberately is *not* yet

No Hibernate/jOOQ/Liquibase yet (direct dialect SQL instead), no Oracle/SQL Server, no
auth, no migration approval gate, no design platform, no AI. Those are sequenced in
[`ROADMAP.md`](ROADMAP.md). v0's job was to prove the spine end-to-end: **an app defined
entirely by config, served over multiple protocols, on a real database** — which it does.

# FlexForge Protocol Layer

A FlexForge app is a data model + logic. **Protocols are projections** of that one model —
the app author turns transports on/off in config; the data and business logic are never
re-implemented per protocol. This is the platform's core "one model, many protocols" idea.

## Status matrix

| Protocol | Status | Surface | Notes |
|---|---|---|---|
| **REST** | ✅ done | `/api/{entity}` CRUD + filters/paging | Auto-generated; OpenAPI at `/__meta/openapi.json` |
| **GraphQL** | ✅ done | `/graphql` (+ SDL `/graphql/schema`) | Schema built at runtime from metadata |
| **Webhooks (outbound)** | ✅ done | flow `http` step / endpoint `webhook` action | Call any third party |
| **Custom HTTP endpoints** | ✅ done | `/run/{name}` | Method + header/param checks + actions |
| **Server-Sent Events** | ✅ done | `/realtime/stream`, `/realtime/recent` | Live change feed |
| **WebSocket** | ✅ done | `/ws/events` | Broadcasts change events |
| **Flow triggers (HTTP)** | ✅ done | `/flows/{name}/run` | Run a no-code flow |
| **GraphQL subscriptions** | 🔜 P1 | `/graphql` (ws) | Reuse the EntityEvent stream |
| **MCP (Model Context Protocol)** | 🔜 P1 | `/mcp` | Expose data+actions to AI tools under RBAC (Directus-style) — high priority for the AI roadmap |
| **gRPC** | 🔜 P2 | `:9090` | Generate proto from metadata; map to the same CRUD service |
| **OData v4** | 🔜 P2 | `/odata` | `$filter/$expand/$select` over entities (enterprise/Excel/PowerBI) |
| **SOAP / WSDL** | 🔜 P3 | `/soap` | Legacy enterprise integration; WSDL from metadata |
| **GraphQL Federation** | 🔜 P3 | — | Compose multiple apps into one graph |

## Design principle (how a new protocol is added)

Every transport is a thin adapter over two shared cores:
1. **`DynamicCrudService`** — all data operations.
2. **`EntityEvent` stream** — all change notifications (for real-time protocols).

So adding gRPC/OData/MCP = write an adapter that (a) translates the protocol's requests
into `DynamicCrudService` calls and (b) for streaming protocols, subscribes to
`EntityEvent`. No new data logic, no per-entity code.

```
                         ┌───────── REST ───────────┐
                         ├───────── GraphQL ─────────┤
   one config bundle ──▶ ├───────── gRPC (P2) ───────┤ ──▶ DynamicCrudService ──▶ DB
   (entities + logic)    ├───────── OData (P2) ──────┤        ▲
                         ├───────── MCP (P1) ────────┤        │ EntityEvent stream
                         └─ SSE / WebSocket / subs ──┘────────┘
```

## Why MCP is prioritized (P1)
Given the AI direction, an MCP server lets AI agents/tools read data and invoke actions
**under the app's existing RBAC** — turning every FlexForge app into a first-class tool for
LLM agents without bespoke integration. It reuses the same CRUD service + AccessGuard.

## Multi-language note
Protocols are about *transport*; custom *logic* in other languages is handled separately by
the three escape hatches (serverless connector, JS code-step, WASM plugins) — see
`PLATFORM_BLUEPRINT.md` §6.

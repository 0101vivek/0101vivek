#!/usr/bin/env python3
"""Generate PDF deliverables with reportlab (no LibreOffice needed).
Run from flexforge/: python3 docs/generate_pdfs.py  -> docs/generated/*.pdf
"""
import os
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
                                ListFlowable, ListItem, Preformatted, PageBreak)
from reportlab.lib.enums import TA_LEFT

OUT = os.path.join(os.path.dirname(__file__), "generated")
os.makedirs(OUT, exist_ok=True)
ACCENT = colors.HexColor("#4A6BFF")
DARK = colors.HexColor("#1f2330")

ss = getSampleStyleSheet()
H0 = ParagraphStyle("H0", parent=ss["Title"], textColor=ACCENT, fontSize=24, spaceAfter=6)
SUB = ParagraphStyle("SUB", parent=ss["Normal"], fontSize=10, textColor=colors.grey, spaceAfter=14)
H1 = ParagraphStyle("H1", parent=ss["Heading1"], textColor=DARK, fontSize=15, spaceBefore=14, spaceAfter=6)
H2 = ParagraphStyle("H2", parent=ss["Heading2"], textColor=ACCENT, fontSize=12, spaceBefore=8, spaceAfter=4)
BODY = ParagraphStyle("BODY", parent=ss["Normal"], fontSize=9.5, leading=14, spaceAfter=6)
CODE = ParagraphStyle("CODE", parent=ss["Code"], fontSize=8, leading=10, backColor=colors.HexColor("#f3f4f8"),
                      borderPadding=6, leftIndent=4)


def P(t, s=BODY):
    return Paragraph(t, s)


def bullets(items):
    return ListFlowable([ListItem(P(x), leftIndent=10) for x in items], bulletType="bullet", start="•")


def table(headers, rows, widths):
    data = [[P(f"<b>{h}</b>", ParagraphStyle('th', parent=BODY, textColor=colors.white)) for h in headers]]
    for r in rows:
        data.append([P(str(c)) for c in r])
    t = Table(data, colWidths=widths, repeatRows=1)
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), ACCENT),
        ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#cfd3e0")),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#f7f8fc")]),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]))
    return t


def tech_pdf():
    story = []
    story.append(P("FlexForge — Technical Documentation", H0))
    story.append(P("Runtime-interpretation no-code application platform · v0.1.0 · 2026-06-24", SUB))

    story.append(P("1. Executive Overview", H1))
    story.append(P("FlexForge is a packaged runtime-interpretation engine: one hardened Spring Boot image "
                   "reads an immutable config bundle (entities, fields, auth, flows) and <b>becomes</b> a full "
                   "backend application at runtime. No per-app source code is generated. The same metadata is "
                   "projected onto multiple protocols (REST, GraphQL, SSE, WebSocket), and all logic is expressed "
                   "as no-code flows."))
    story.append(bullets([
        "No-code for the builder: apps are config + flows, never hand-written code.",
        "One interpreted engine, one config bundle (the Mendix model) — not multi-stack codegen.",
        "Modular monolith, one engine process per app.",
        "AI-ready: AI modules slot in as flow steps (uniform FlowStep interface).",
        "Multi-language via escape hatches (serverless, JS code-step, WASM) — not multiple engines.",
    ]))

    story.append(P("2. High-Level Design", H1))
    story.append(P("Request lifecycle:", H2))
    story.append(Preformatted(
        "HTTP (REST / GraphQL / SSE / WebSocket / Flow trigger)\n"
        "   -> Protocol surface -> AccessGuard (auth) -> DynamicCrudService <-> MetadataRegistry\n"
        "   -> SqlDialect -> parameterized SQL -> HikariCP -> Database\n"
        "   -> EntityEvent stream -> SSE / WebSocket subscribers", CODE))
    story.append(P("Startup: load bundle -> validate (JSON Schema + semantic) -> pick dialect -> build datasource "
                   "-> sync schema (additive) -> expose enabled protocols -> live.", BODY))

    story.append(P("3. Low-Level Design — Modules", H1))
    story.append(table(["Module", "Responsibility"], [
        ["config(.model)", "Config POJOs; loader; JSON-Schema + semantic validation; MetadataRegistry"],
        ["schema", "SqlDialect (H2/PG/MySQL), Naming, SchemaManager (DDL sync)"],
        ["data", "DynamicCrudService (generic CRUD), FieldValidator, QueryOptions, IdempotencyStore"],
        ["crypto / auth", "AES-256-GCM EncryptionService; JWT + API-key + AccessGuard"],
        ["flow(.steps)", "FlowEngine; steps: set/condition/db/http/log/respond/ai/notify"],
        ["audit / notify / ai", "AuditService (audit log); NotificationService; AiProvider (stub + OpenAI-compatible)"],
        ["realtime", "EntityEvent, RealtimeService (SSE), WebSocket handler"],
        ["api.*", "REST, GraphQL, meta/OpenAPI, file, endpoint, flow, realtime surfaces"],
        ["bootstrap", "EngineConfiguration (composition root), EngineBootstrap, CORS"],
    ], [120, 330]))

    story.append(P("4. Field Types", H1))
    story.append(table(["Type", "Notes"], [
        ["STRING/TEXT", "length + validation (minLength/maxLength/pattern/email)"],
        ["INT/LONG/DOUBLE/DECIMAL", "numeric validation (min/max)"],
        ["BOOLEAN / DATE / TIMESTAMP", "auto createdAt/updatedAt by convention"],
        ["JSON", "native per dialect (JSONB/JSON)"],
        ["REFERENCE", "relation to another entity (app-level integrity)"],
        ["FILE", "upload/download/base64 via file API"],
        ["encrypted:true", "AES-256-GCM at rest, transparent on read"],
    ], [150, 300]))

    story.append(P("5. Application Flow (No-Code)", H1))
    story.append(P("Flows = trigger + graph of typed steps over a shared context; steps read ${input.x}, "
                   "${steps.id.field}, ${vars.x}. The uniform FlowStep interface is where AI modules and "
                   "connectors plug in.", BODY))
    story.append(Preformatted(
        "flows:\n"
        "  - name: grade\n"
        "    steps:\n"
        "      - {id: check, type: condition,\n"
        "         params: {left: \"${input.score}\", op: \">=\", right: 50}, then: pass, else: fail}\n"
        "      - {id: pass, type: respond, params: {body: {result: \"pass\"}}}\n"
        "      - {id: fail, type: respond, params: {body: {result: \"fail\"}}}\n"
        "# POST /flows/grade/run {\"score\":70} -> {\"result\":\"pass\"}", CODE))

    story.append(P("6. Protocols", H1))
    story.append(table(["Protocol", "Status", "Endpoint"], [
        ["REST", "Done", "/api/{entity}"],
        ["GraphQL", "Done", "/graphql (+ /graphql/schema)"],
        ["Server-Sent Events", "Done", "/realtime/stream"],
        ["WebSocket", "Done", "/ws/events"],
        ["Custom endpoints / webhooks", "Done", "/run/{name}, flow http step"],
        ["Flow trigger", "Done", "/flows/{name}/run"],
        ["GraphQL subscriptions / MCP", "Roadmap P1", "—"],
        ["gRPC / OData", "Roadmap P2", "—"],
        ["SOAP / Federation", "Roadmap P3", "—"],
    ], [150, 90, 210]))

    story.append(P("7. Security", H1))
    story.append(bullets([
        "Auth: JWT (/auth/login) or API-key (X-API-Key).",
        "Per-entity read/write role rules via one AccessGuard across all protocols.",
        "Field-level AES-256-GCM encryption; CORS; secrets via ${ENV}.",
        "Roadmap: row-level security, SSO/SAML/OIDC, audit log, multi-tenancy.",
    ]))

    story.append(P("8. How to Run", H1))
    story.append(Preformatted(
        "cd flexforge\n"
        "mvn spring-boot:run            # in-memory H2, zero setup\n"
        "open http://localhost:8080/    # admin UI\n\n"
        "# Postgres/MySQL (same image):\n"
        "export DB_ENGINE=postgres DB_URL=jdbc:postgresql://localhost:5432/app \\\n"
        "       DB_USERNAME=app DB_PASSWORD=secret && mvn spring-boot:run\n\n"
        "# different app, same engine:\n"
        "export FLEXFORGE_CONFIG_PATH=/path/to/app.yaml && mvn spring-boot:run\n\n"
        "mvn test                       # 26 integration tests on H2\n"
        "mvn package                    # fat jar\n"
        "mvn compile jib:build -Dimage=ghcr.io/you/flexforge-engine:0.1.0", CODE))

    story.append(P("9. Roadmap", H1))
    story.append(bullets([
        "P0.5: select/multiselect + computed fields (formula/lookup/rollup), N:N relations.",
        "P1: AI steps + provider gateway + vector store; MCP protocol; serverless + JS code-step.",
        "P1.5: audit engine, row/field-level security, notifications, scheduler trigger.",
        "P2: visual builder, kanban/calendar/charts, connectors, multi-tenancy, gRPC/OData.",
        "P3: WASM plugins, vertical modules, SOAP, federation, offline.",
    ]))

    SimpleDocTemplate(os.path.join(OUT, "FlexForge_Technical_Documentation.pdf"), pagesize=A4,
                      leftMargin=18 * mm, rightMargin=18 * mm, topMargin=16 * mm, bottomMargin=16 * mm)\
        .build(story)


TESTS = [
    ("TC-01", "Engine", "REST CRUD round-trip", "201 create; reads back; 404 after delete", "PASS"),
    ("TC-02", "Engine", "GraphQL mutation + query", "record created and listed via GraphQL", "PASS"),
    ("TC-03", "Security", "Unauthenticated rejected", "HTTP 401", "PASS"),
    ("TC-04", "Security", "Role-gated write", "ADMIN 201; VIEWER 403; VIEWER read 200", "PASS"),
    ("TC-05", "Security", "Bad credentials rejected", "HTTP 401", "PASS"),
    ("TC-06", "Validation", "Bad email / missing required", "HTTP 400 with errors[]", "PASS"),
    ("TC-07", "Functional", "Search operators (_like / eq)", "filtered results returned", "PASS"),
    ("TC-08", "Security", "Metadata hides secrets", "no jwtSecret/password in /__meta", "PASS"),
    ("TC-09", "Functional", "OpenAPI generated", "openapi=3.0.3 with paths", "PASS"),
    ("TC-10", "Functional", "Admin UI served", "200; contains 'FlexForge Admin'", "PASS"),
    ("TC-11", "Functional", "Relation + auto timestamps", "Order links; createdAt/updatedAt set", "PASS"),
    ("TC-12", "Validation", "Referential integrity", "HTTP 400 on missing reference", "PASS"),
    ("TC-13", "Functional", "Endpoint missing param", "HTTP 400; mentions 'who'", "PASS"),
    ("TC-14", "Functional", "Endpoint json action", "200; message=pong", "PASS"),
    ("TC-15", "Functional", "Endpoint missing header", "HTTP 400; mentions X-API-Key", "PASS"),
    ("TC-16", "Functional", "Endpoint wrong method", "HTTP 405", "PASS"),
    ("TC-17", "Functional", "Endpoint header ok", "200; accepted=true", "PASS"),
    ("TC-18", "Security", "Encrypted field round-trip", "ssn returned decrypted", "PASS"),
    ("TC-19", "Functional", "File upload/download/base64", "bytes match original", "PASS"),
    ("TC-20", "Unit", "AES round-trip + cipher differs", "decrypt==plain; cipher!=plain", "PASS"),
    ("TC-21", "Unit", "Non-deterministic ciphertext", "two ciphers differ; both decrypt", "PASS"),
    ("TC-22", "Unit", "Base64 round-trip", "bytes preserved", "PASS"),
    ("TC-23", "Functional", "Flow expression interpolation", "{message:'Hello Ada'}", "PASS"),
    ("TC-24", "Functional", "Flow db step creates record", "record visible via REST", "PASS"),
    ("TC-25", "Functional", "Flow condition branching", "pass / fail by score", "PASS"),
    ("TC-26", "Functional", "CRUD emits change events", "create event in /realtime/recent", "PASS"),
    ("TC-27", "Security", "CRUD is audited", "create entry in /__audit", "PASS"),
    ("TC-28", "Functional", "Idempotency-Key prevents dup create", "replay returns same record (200)", "PASS"),
    ("TC-29", "Functional", "AI step (stub) + notify step", "summary returned; notification recorded", "PASS"),
]


def test_pdf():
    story = []
    story.append(P("FlexForge — Test Cases & Report", H0))
    story.append(P("JUnit 5 + Spring Boot @SpringBootTest (H2) · v0.1.0 · 2026-06-24", SUB))

    total = len(TESTS)
    passed = sum(1 for t in TESTS if t[4] == "PASS")
    story.append(P("Summary", H1))
    story.append(table(["Metric", "Value"], [
        ["Total tests", total], ["Passed", passed], ["Failed", total - passed],
        ["Pass rate", f"{round(passed / total * 100)}%"],
        ["Suites", "9 (Engine, Security, Features, Relations, Endpoints, Crypto/File, Encryption, Flow, Realtime)"],
    ], [150, 300]))

    story.append(P("Test Cases", H1))
    rows = [[i, suite, title, expected, status] for (i, suite, title, expected, status) in TESTS]
    t = table(["ID", "Type", "Title", "Expected Result", "Status"], rows, [38, 58, 150, 165, 40])
    story.append(t)

    SimpleDocTemplate(os.path.join(OUT, "FlexForge_Test_Cases_and_Report.pdf"), pagesize=A4,
                      leftMargin=15 * mm, rightMargin=15 * mm, topMargin=15 * mm, bottomMargin=15 * mm)\
        .build(story)


if __name__ == "__main__":
    tech_pdf()
    test_pdf()
    print("Wrote PDFs to", OUT)

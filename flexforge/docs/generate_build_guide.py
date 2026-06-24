#!/usr/bin/env python3
"""Generate FlexForge_Build_Your_App.pdf (how to build an app, with the lending example)."""
import os
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Preformatted, ListFlowable, ListItem

OUT = os.path.join(os.path.dirname(__file__), "generated")
os.makedirs(OUT, exist_ok=True)
ACCENT = colors.HexColor("#4A6BFF")
DARK = colors.HexColor("#1f2330")

ss = getSampleStyleSheet()
H0 = ParagraphStyle("H0", parent=ss["Title"], textColor=ACCENT, fontSize=22, spaceAfter=6)
SUB = ParagraphStyle("SUB", parent=ss["Normal"], fontSize=10, textColor=colors.grey, spaceAfter=12)
H1 = ParagraphStyle("H1", parent=ss["Heading1"], textColor=DARK, fontSize=13.5, spaceBefore=12, spaceAfter=5)
BODY = ParagraphStyle("BODY", parent=ss["Normal"], fontSize=9.5, leading=14, spaceAfter=6)
CODE = ParagraphStyle("CODE", parent=ss["Code"], fontSize=7.8, leading=10.2,
                      backColor=colors.HexColor("#f3f4f8"), borderPadding=6, leftIndent=4)


def P(t, s=BODY):
    return Paragraph(t, s)


def bullets(items):
    return ListFlowable([ListItem(P(x)) for x in items], bulletType="bullet", start="•", leftIndent=12)


s = []
s.append(P("FlexForge — Build Your Application", H0))
s.append(P("You build an app by writing a config bundle (YAML), not code. Worked example: a real NBFC lending app.", SUB))

s.append(P("The mental model", H1))
s.append(Preformatted(
    "your app  =  one YAML config bundle  -->  FlexForge engine  -->  a running backend\n"
    "            (entities, fields, auth,                          (APIs + UI + DB, no code)\n"
    "             flows, endpoints)", CODE))
s.append(P("No per-app source code. Change the config and restart. Run a different app by pointing the "
           "same engine at a different bundle:", BODY))
s.append(Preformatted("FLEXFORGE_CONFIG_PATH=examples/lending-app.yaml mvn spring-boot:run\n"
                      "# open http://localhost:8080/  (Console renders YOUR app)", CODE))

s.append(P("Step 1 — Data model (entities + fields)", H1))
s.append(Preformatted(
    "appId: nbfc-lending\n"
    "entities:\n"
    "  - name: Borrower\n"
    "    fields:\n"
    "      - { name: id,       type: LONG,   pk: true }\n"
    "      - { name: fullName, type: STRING, length: 200, nullable: false }\n"
    "      - { name: email,    type: STRING, email: true }", CODE))
s.append(P("<b>Field types:</b> STRING, TEXT, INT, LONG, DOUBLE, DECIMAL, BOOLEAN, DATE, TIMESTAMP, JSON, "
           "REFERENCE (relation), FILE (upload).", BODY))

s.append(P("Step 2 — Relations (connect entities)", H1))
s.append(Preformatted(
    "  - name: LoanApplication\n"
    "    fields:\n"
    "      - { name: id,         type: LONG,      pk: true }\n"
    "      - { name: borrowerId, type: REFERENCE, references: Borrower, nullable: false }\n"
    "      - { name: amount,     type: DECIMAL,   min: 1000, nullable: false }", CODE))

s.append(P("Step 3 — Validation (no code)", H1))
s.append(Preformatted(
    "- { name: fullName, type: STRING,  nullable: false, minLength: 2 }   # required + min length\n"
    "- { name: email,    type: STRING,  email: true }                     # must be email\n"
    "- { name: phone,    type: STRING,  pattern: \"^[0-9]{10,15}$\" }        # regex\n"
    "- { name: amount,   type: DECIMAL, min: 1000, max: 5000000 }         # numeric range", CODE))
s.append(P("Invalid writes return HTTP 400 with a clear errors[] list.", BODY))

s.append(P("Step 4 — Encryption + files", H1))
s.append(Preformatted(
    "- { name: pan,    type: STRING, encrypted: true }   # AES-256-GCM at rest, plaintext on read\n"
    "- { name: kycDoc, type: FILE }                       # /api/Borrower/{id}/file/kycDoc", CODE))

s.append(P("Step 5 — Auth + role rules (config-driven)", H1))
s.append(Preformatted(
    "security:\n"
    "  enabled: true\n"
    "  users:\n"
    "    - { username: officer, password: officer123, roles: [OFFICER] }\n"
    "    - { username: manager, password: manager123, roles: [MANAGER] }\n"
    "  rules:\n"
    "    LoanApplication: { read: [OFFICER, MANAGER], write: [OFFICER] }\n"
    "    Disbursement:    { write: [MANAGER] }", CODE))
s.append(P("Same rules apply across REST, GraphQL and flows. Login: POST /auth/login, or use X-API-Key.", BODY))

s.append(P("Step 6 — Business logic as no-code flows", H1))
s.append(P("Real loan auto-decisioning (create -> branch on amount -> approve/review):", BODY))
s.append(Preformatted(
    "flows:\n"
    "  - name: applyLoan\n"
    "    steps:\n"
    "      - id: create\n"
    "        type: db\n"
    "        params: { op: create, entity: LoanApplication,\n"
    "                  data: { borrowerId: \"${input.borrowerId}\", amount: \"${input.amount}\",\n"
    "                          status: \"SUBMITTED\" } }\n"
    "        next: decide\n"
    "      - id: decide\n"
    "        type: condition\n"
    "        params: { left: \"${input.amount}\", op: \"<=\", right: 200000 }\n"
    "        then: approve\n"
    "        else: review\n"
    "      - id: approve\n"
    "        type: db\n"
    "        params: { op: update, entity: LoanApplication, id: \"${steps.create.id}\",\n"
    "                  data: { status: \"APPROVED\", score: 750 } }\n"
    "        next: done\n"
    "      - id: done\n"
    "        type: respond\n"
    "        params: { body: { applicationId: \"${steps.create.id}\", status: \"APPROVED\" } }\n"
    "      - id: review\n"
    "        type: respond\n"
    "        params: { body: { status: \"MANUAL_REVIEW\" } }", CODE))
s.append(P("Run: POST /flows/applyLoan/run {\"borrowerId\":1,\"amount\":150000} -> "
           "{\"applicationId\":1,\"status\":\"APPROVED\"}  (300000 -> MANUAL_REVIEW).", BODY))
s.append(P("<b>Step types:</b> db, http, condition, set, respond, log, notify, ai, math, string, "
           "list, datetime, crypto, json (60+ ops). AI steps plug in the same way.", BODY))

s.append(P("Step 7 — Run & use it (what you get free)", H1))
s.append(bullets([
    "Admin Console at / (dashboard, data browser, generated forms, flow runner)",
    "REST CRUD + search + pagination for every entity; OpenAPI at /__meta/openapi.json",
    "GraphQL at /graphql (+ SDL); Realtime at /realtime/stream and /ws/events",
    "Audit log at /__audit; flows at /flows/{name}/run",
]))

s.append(P("What you did NOT write", H1))
s.append(P("No controllers, repositories, DTOs, SQL, migrations, auth filters, validation code, "
           "serializers, API spec, or UI. All derived from the bundle by the engine.", BODY))

s.append(P("Build YOUR app", H1))
s.append(P("Copy examples/lending-app.yaml, change appId, replace entities/flows with your domain, run. "
           "The same pattern builds a clinic, CRM, marketplace, LMS — see INDUSTRY_CATALOG.md for the "
           "entities/features each vertical needs.", BODY))

SimpleDocTemplate(os.path.join(OUT, "FlexForge_Build_Your_App.pdf"), pagesize=A4,
                  leftMargin=18 * mm, rightMargin=18 * mm, topMargin=16 * mm, bottomMargin=14 * mm).build(s)
print("Wrote", os.path.join(OUT, "FlexForge_Build_Your_App.pdf"))

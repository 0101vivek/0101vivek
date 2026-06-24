#!/usr/bin/env python3
"""Generates two PDFs:
  - FlexForge_How_To_Run.pdf        (step-by-step run guide)
  - FlexForge_Code_Flow_Diagrams.pdf (visual box-and-arrow code/architecture flow)
Run from flexforge/: python3 docs/generate_run_and_flow.py
"""
import math
import os
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Preformatted,
                                ListFlowable, ListItem, Table, TableStyle)
from reportlab.graphics.shapes import Drawing, Rect, String, Line, Polygon

OUT = os.path.join(os.path.dirname(__file__), "generated")
os.makedirs(OUT, exist_ok=True)
ACCENT = colors.HexColor("#4A6BFF")
DARK = colors.HexColor("#1f2330")
GREEN = colors.HexColor("#1B8A4B")
GREY = colors.HexColor("#5b6270")

ss = getSampleStyleSheet()
H0 = ParagraphStyle("H0", parent=ss["Title"], textColor=ACCENT, fontSize=23, spaceAfter=6)
SUB = ParagraphStyle("SUB", parent=ss["Normal"], fontSize=10, textColor=colors.grey, spaceAfter=14)
H1 = ParagraphStyle("H1", parent=ss["Heading1"], textColor=DARK, fontSize=14, spaceBefore=12, spaceAfter=6)
H2 = ParagraphStyle("H2", parent=ss["Heading2"], textColor=ACCENT, fontSize=11, spaceBefore=8, spaceAfter=3)
BODY = ParagraphStyle("BODY", parent=ss["Normal"], fontSize=9.5, leading=14, spaceAfter=6)
CODE = ParagraphStyle("CODE", parent=ss["Code"], fontSize=8.2, leading=11,
                      backColor=colors.HexColor("#f3f4f8"), borderPadding=6, leftIndent=4)
NOTE = ParagraphStyle("NOTE", parent=BODY, textColor=GREEN, fontSize=9)


def P(t, s=BODY):
    return Paragraph(t, s)


def steps(items):
    return ListFlowable([ListItem(P(x)) for x in items], bulletType="1", leftIndent=14)


def bullets(items):
    return ListFlowable([ListItem(P(x)) for x in items], bulletType="bullet", start="•", leftIndent=12)


# ---------------------------------------------------------------------------
# RUN GUIDE
# ---------------------------------------------------------------------------

def run_guide():
    s = []
    s.append(P("FlexForge — How to Run", H0))
    s.append(P("Step-by-step guide for running the engine locally, on a real database, and as a container · v0.1.0", SUB))

    s.append(P("0. Prerequisites", H1))
    s.append(bullets([
        "<b>JDK 21</b> (check: <font face=Courier>java -version</font>)",
        "<b>Maven 3.9+</b> (check: <font face=Courier>mvn -version</font>)",
        "Optional: Docker (for container builds), Postgres/MySQL (for a real DB)",
        "No database needed to start — the engine defaults to in-memory H2.",
    ]))

    s.append(P("1. Get the code", H1))
    s.append(P("The project lives under <font face=Courier>flexforge/</font> on the branch "
               "<font face=Courier>claude/backend-architecture-plan-xcgh3m</font>.", BODY))
    s.append(Preformatted(
        "git clone https://github.com/0101vivek/0101vivek.git\n"
        "cd 0101vivek\n"
        "git checkout claude/backend-architecture-plan-xcgh3m\n"
        "cd flexforge", CODE))

    s.append(P("2. Run it (zero setup — in-memory H2)", H1))
    s.append(Preformatted("mvn spring-boot:run", CODE))
    s.append(P("You should see logs ending with:", BODY))
    s.append(Preformatted(
        "[engine] config 'crm-demo' v0.1.0 validated: 4 entities, REST=true, GraphQL=true\n"
        "[schema] creating table customer ...\n"
        "[engine] schema ready - app 'crm-demo' is live\n"
        "Tomcat started on port 8080", CODE))
    s.append(P("Then open the admin UI in a browser:", BODY))
    s.append(Preformatted("http://localhost:8080/", CODE))

    s.append(P("3. Try the APIs (in another terminal)", H1))
    s.append(P("REST:", H2))
    s.append(Preformatted(
        "curl -s -X POST localhost:8080/api/Customer -H 'Content-Type: application/json' \\\n"
        "  -d '{\"email\":\"ada@example.com\",\"fullName\":\"Ada Lovelace\",\"tier\":\"gold\"}'\n\n"
        "curl -s localhost:8080/api/Customer\n"
        "curl -s 'localhost:8080/api/Customer?tier_like=gol'", CODE))
    s.append(P("GraphQL:", H2))
    s.append(Preformatted(
        "curl -s -X POST localhost:8080/graphql -H 'Content-Type: application/json' \\\n"
        "  -d '{\"query\":\"{ customerList { id email tier } }\"}'", CODE))
    s.append(P("A no-code flow:", H2))
    s.append(Preformatted(
        "curl -s -X POST localhost:8080/flows/grade/run -H 'Content-Type: application/json' \\\n"
        "  -d '{\"score\":70}'        # -> {\"result\":\"pass\"}", CODE))
    s.append(P("Real-time + audit:", H2))
    s.append(Preformatted(
        "curl -s localhost:8080/realtime/recent     # change events\n"
        "curl -s localhost:8080/__audit             # audit log\n"
        "curl -s localhost:8080/__meta/openapi.json # OpenAPI spec", CODE))

    s.append(P("4. Point at a real database (same image, no code change)", H1))
    s.append(P("Connection details come from environment variables (12-factor):", BODY))
    s.append(Preformatted(
        "export DB_ENGINE=postgres\n"
        "export DB_URL='jdbc:postgresql://localhost:5432/crm'\n"
        "export DB_USERNAME=crm\n"
        "export DB_PASSWORD=secret\n"
        "mvn spring-boot:run\n\n"
        "# MySQL: DB_ENGINE=mysql, DB_URL=jdbc:mysql://localhost:3306/crm", CODE))

    s.append(P("5. Run a different app with the same engine", H1))
    s.append(Preformatted(
        "export FLEXFORGE_CONFIG_PATH=/path/to/your/app.yaml\n"
        "mvn spring-boot:run", CODE))

    s.append(P("6. Build artifacts", H1))
    s.append(Preformatted(
        "mvn test        # run the 30 integration tests on H2\n"
        "mvn package     # build the fat jar (target/flexforge-engine-0.1.0.jar)\n"
        "java -jar target/flexforge-engine-0.1.0.jar\n\n"
        "# OCI image with no Dockerfile and no source in the image:\n"
        "mvn compile jib:build -Dimage=ghcr.io/you/flexforge-engine:0.1.0", CODE))

    s.append(P("7. Enable security (optional)", H1))
    s.append(P("Set <font face=Courier>security.enabled: true</font> in the config with users + role rules, then:", BODY))
    s.append(Preformatted(
        "TOKEN=$(curl -s -X POST localhost:8080/auth/login -H 'Content-Type: application/json' \\\n"
        "  -d '{\"username\":\"admin\",\"password\":\"admin123\"}' | jq -r .token)\n"
        "curl -s localhost:8080/api/Customer -H \"Authorization: Bearer $TOKEN\"", CODE))

    s.append(P("8. Troubleshooting", H1))
    s.append(Table(
        [[P("<b>Symptom</b>"), P("<b>Fix</b>")],
         [P("Port 8080 in use"), P("Set server.port or stop the other process")],
         [P("'database.url is required'"), P("Set DB_URL/DB_ENGINE, or unset them to use H2")],
         [P("Config invalid on boot"), P("Read the printed JSON-Schema/semantic errors; fix app.yaml")],
         [P("401 on API calls"), P("Security is on — log in and send the Bearer token")],
         [P("Java version error"), P("Install/select JDK 21")]],
        colWidths=[150, 320],
        style=TableStyle([("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#cfd3e0")),
                          ("BACKGROUND", (0, 0), (-1, 0), ACCENT),
                          ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                          ("VALIGN", (0, 0), (-1, -1), "TOP"),
                          ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#f7f8fc")])])))

    SimpleDocTemplate(os.path.join(OUT, "FlexForge_How_To_Run.pdf"), pagesize=A4,
                      leftMargin=18 * mm, rightMargin=18 * mm, topMargin=16 * mm, bottomMargin=16 * mm).build(s)


# ---------------------------------------------------------------------------
# CODE-FLOW DIAGRAMS (vector)
# ---------------------------------------------------------------------------

def box(d, x, y, w, h, label, fill=ACCENT, fg=colors.white, fs=8.5):
    d.add(Rect(x, y, w, h, rx=5, ry=5, fillColor=fill, strokeColor=DARK, strokeWidth=0.8))
    lines = label.split("\n")
    ty = y + h / 2 + (len(lines) - 1) * 5.5 - 3
    for ln in lines:
        d.add(String(x + w / 2, ty, ln, fontName="Helvetica-Bold", fontSize=fs, fillColor=fg, textAnchor="middle"))
        ty -= 11


def arrow(d, x1, y1, x2, y2, color=GREY):
    d.add(Line(x1, y1, x2, y2, strokeColor=color, strokeWidth=1.2))
    ang = math.atan2(y2 - y1, x2 - x1)
    a = 5
    d.add(Polygon([x2, y2,
                   x2 - a * math.cos(ang - 0.5), y2 - a * math.sin(ang - 0.5),
                   x2 - a * math.cos(ang + 0.5), y2 - a * math.sin(ang + 0.5)],
                  fillColor=color, strokeColor=color))


def label(d, x, y, text, fs=7.5, color=GREY):
    d.add(String(x, y, text, fontName="Helvetica-Oblique", fontSize=fs, fillColor=color, textAnchor="middle"))


def diagram_request():
    d = Drawing(470, 360)
    cx = 235
    box(d, cx - 150, 320, 300, 30, "Client  (browser / mobile / curl / AI agent)", GREY)
    arrow(d, cx, 320, cx, 300)
    box(d, cx - 220, 268, 440, 30,
        "Protocol surfaces:  REST  /  GraphQL  /  SSE  /  WebSocket  /  /flows  /  /run", ACCENT)
    arrow(d, cx, 268, cx, 248)
    box(d, cx - 110, 216, 220, 30, "SecurityFilter -> AccessGuard\n(JWT / API-key, role rules)", DARK)
    arrow(d, cx, 216, cx, 196)
    box(d, cx - 130, 164, 260, 30, "DynamicCrudService\n(one generic CRUD engine)", ACCENT)
    # side: metadata registry
    box(d, cx + 150, 164, 130, 30, "MetadataRegistry\n(in-memory model)", GREEN, fs=7.5)
    arrow(d, cx + 150, 179, cx + 130, 179)
    arrow(d, cx, 164, cx, 144)
    box(d, cx - 120, 112, 240, 28, "SqlDialect -> parameterized SQL", DARK)
    arrow(d, cx, 112, cx, 92)
    box(d, cx - 90, 60, 180, 28, "HikariCP pool", GREY)
    arrow(d, cx, 60, cx, 40)
    box(d, cx - 70, 8, 140, 30, "Database\nH2 / PG / MySQL", GREEN)
    # event side-channel
    box(d, cx - 360 + 40, 164, 90, 30, "EntityEvent", colors.HexColor("#b9770e"), fs=7.5)
    arrow(d, cx - 130, 179, cx - 230, 179)
    box(d, 20, 112, 110, 28, "Realtime (SSE/WS)", colors.HexColor("#b9770e"), fs=7)
    box(d, 20, 72, 110, 28, "AuditService", colors.HexColor("#b9770e"), fs=7)
    arrow(d, 75, 164, 75, 140)
    arrow(d, 75, 112, 75, 100)
    return d


def diagram_startup():
    d = Drawing(470, 300)
    items = ["Load config bundle (YAML/JSON)",
             "Validate  (JSON Schema + semantic rules)",
             "Choose SQL dialect from config",
             "Build HikariCP datasource",
             "Sync schema  (create tables, additive columns)",
             "Register flow steps + expose enabled protocols",
             "Engine is LIVE"]
    y = 268
    for i, it in enumerate(items):
        fill = GREEN if i == len(items) - 1 else ACCENT
        box(d, 60, y, 350, 26, it, fill)
        if i < len(items) - 1:
            arrow(d, 235, y, 235, y - 12)
        y -= 38
    return d


def diagram_flow_engine():
    d = Drawing(470, 300)
    box(d, 150, 268, 170, 26, "POST /flows/{name}/run", GREY)
    arrow(d, 235, 268, 235, 250)
    box(d, 150, 222, 170, 26, "FlowEngine.run()", ACCENT)
    arrow(d, 235, 222, 235, 204)
    box(d, 120, 176, 230, 26, "for each step: StepRegistry.require(type)", DARK)
    arrow(d, 235, 176, 235, 158)
    # step library row
    box(d, 20, 120, 430, 30,
        "FlowStep:  set · condition · db · http · ai · notify · math ·\nstring · list · datetime · crypto · json · log · respond", ACCENT, fs=7.3)
    arrow(d, 235, 120, 235, 104)
    box(d, 150, 78, 170, 26, "FlowContext (shared, audited)", GREEN)
    label(d, 235, 64, "next  /  then-else  /  respond ends the run")
    arrow(d, 235, 78, 235, 46)
    box(d, 150, 18, 170, 26, "respond -> HTTP response", GREY)
    return d


def diagram_modules():
    d = Drawing(470, 250)
    groups = [
        ("config / config.model", GREEN), ("schema (dialects, DDL)", ACCENT),
        ("data (CRUD, validate, idempotency)", ACCENT), ("auth + crypto", DARK),
        ("flow + flow.steps", ACCENT), ("realtime (SSE/WS)", colors.HexColor("#b9770e")),
        ("audit / notify / ai", colors.HexColor("#b9770e")), ("api.* surfaces", GREY),
        ("bootstrap (composition root)", DARK),
    ]
    x, y = 25, 200
    w, h, gap = 200, 30, 12
    col = 0
    for name, fill in groups:
        box(d, x, y, w, h, name, fill, fs=8)
        col += 1
        if col % 2 == 0:
            x = 25
            y -= (h + gap)
        else:
            x = 245
    return d


def code_flow():
    s = []
    s.append(P("FlexForge — Code Flow Diagrams", H0))
    s.append(P("Visual walkthrough of how a request flows, how the engine boots, how a flow runs, and the module map · v0.1.0", SUB))

    s.append(P("1. Request flow (architecture)", H1))
    s.append(P("Every protocol is a thin surface over one CRUD engine; data changes fan out to "
               "real-time and audit via the EntityEvent stream.", BODY))
    s.append(diagram_request())

    s.append(P("2. Startup sequence", H1))
    s.append(P("What happens when the engine boots and interprets the config bundle.", BODY))
    s.append(diagram_startup())

    s.append(P("3. Flow engine execution", H1))
    s.append(P("How a no-code flow runs: the engine walks the step graph, each step is resolved "
               "from the registry and executed against the shared context.", BODY))
    s.append(diagram_flow_engine())

    s.append(P("4. Module map", H1))
    s.append(P("The modular-monolith package structure.", BODY))
    s.append(diagram_modules())

    SimpleDocTemplate(os.path.join(OUT, "FlexForge_Code_Flow_Diagrams.pdf"), pagesize=A4,
                      leftMargin=18 * mm, rightMargin=18 * mm, topMargin=16 * mm, bottomMargin=14 * mm).build(s)


if __name__ == "__main__":
    run_guide()
    code_flow()
    print("Wrote run guide + code-flow diagrams to", OUT)

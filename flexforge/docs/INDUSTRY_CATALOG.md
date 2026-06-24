# FlexForge Industry & App Feature Catalog

> Synthesized from research across **30+ industries and 100+ app types** (banking, NBFC,
> insurance, wealth, crypto, accounting, healthcare, e-commerce, logistics, education,
> real estate, HR, hospitality, manufacturing, CRM, media, government, travel, food,
> events, legal, telecom, energy, construction, automotive, agritech, and more).
>
> **The thesis:** ~70% of every app is a small set of **universal primitives**. Ship those
> as first-class config building blocks and each vertical reduces to *a data-model template
> + a few vertical engines + compliance config*. The vertical engines become premium modules.

## A. Universal platform primitives (build once — almost every app uses these)

| # | Primitive | Why universal | FlexForge status |
|---|---|---|---|
| 1 | **Typed data model + relations + computed fields** | Every app | ✅ core (computed/N:N = P0.5) |
| 2 | **CRUD over many protocols** (REST/GraphQL/realtime) | Every app | ✅ done |
| 3 | **Auth + RBAC + row/field-level security** | Every app | ✅ auth/RBAC; RLS = P1.5 |
| 4 | **Audit trail** (append-only, who/when/before-after) | Healthcare, finance, gov, HR, mfg — legally required | 🔜 P1.5 (event stream exists) |
| 5 | **Workflow / flow engine** (trigger→logic→action) | Every app | ✅ done |
| 6 | **Approval / maker-checker** (multi-level, SoD) | Lending, insurance, expense, gov, HR | 🔜 P1 (flow step) |
| 7 | **Double-entry ledger / GL** | Banking, NBFC, payments, crypto, accounting, billing | 🔜 P1 (premium primitive) |
| 8 | **Idempotency layer** (no double-charge under retry) | All money movement + webhooks | 🔜 P1 |
| 9 | **Reconciliation engine** (match two feeds + exceptions) | Payments, neobank, exchange, GST, commissions | 🔜 P2 |
| 10 | **Scheduled jobs / batch** (EOD, billing, NAV, dunning) | Finance, billing, ops | 🔜 P1.5 (scheduler trigger) |
| 11 | **Document / KYC capture** (OCR, ID/liveness, e-sign) | Onboarding, lending, insurance, legal, expense | 🔜 P2 (connector) |
| 12 | **Rules / decisioning engine** (versioned, explainable) | Credit, underwriting, fraud, eligibility, tax | 🔜 P1 (flow + rules) |
| 13 | **External-API orchestration** (retry/fallback/audit) | Everywhere (bureaus, RTAs, gov portals, PSPs) | ✅ http step; connectors P1 |
| 14 | **Notifications** (email/SMS/push + consent) | Every app | 🔜 P1 (flow step) |
| 15 | **Booking / availability + concurrency (TTL holds)** | Travel, food, healthcare, events, edtech | 🔜 P2 (premium primitive) |
| 16 | **Cart / checkout + tokenized payments** | E-com, travel, food, events, edtech | 🔜 P1 (payment connector) |
| 17 | **Reporting / statements / dashboards** | Every app | 🔜 P2 |
| 18 | **File / media handling** | Every app | ✅ done |
| 19 | **Encryption (field-level) + secrets** | Healthcare, finance, gov | ✅ done |
| 20 | **Multi-tenancy / multi-entity isolation** | SaaS, gov, partner portals | 🔜 P2 |
| 21 | **i18n / l10n + WCAG-AA accessibility (default)** | Gov, media, education (legally) | 🔜 P2 |
| 22 | **Effective-dated / point-in-time records** | Insurance, HR, banking, PMS | 🔜 P2 |

## B. Industry → apps → uniqueness → vertical module needed

| Industry | Representative apps | What's unique/hard | Vertical module(s) |
|---|---|---|---|
| **Banking** | Core banking, account opening/KYC, neobank/BaaS, payments | Double-entry GL real-time consistency; V-CIP KYC; idempotent settlement | Ledger, KYC, settlement, reconciliation |
| **NBFC / Lending** | LOS, LMS/servicing, collections, gold loan, microfinance | Interest accrual + amortization; NPA/DPD (IRAC); collections waterfall; offline JLG | Accrual engine, amortization scheduler, NPA classifier, collections, mandate (NACH) |
| **Insurance** | Policy admin, claims, underwriting, broker portal | Rating/premium engine (versioned); claims adjudication; effective-dated policy; multi-carrier commission recon | Rating engine, claims workflow, reconciliation |
| **WealthTech** | Robo-advisory, brokerage/OMS, mutual funds, PMS | Real-time RMS/margin; tax-lot harvesting; NAV cutoff recon; corporate actions | Order/matching + RMS, portfolio math, NAV recon |
| **Crypto/Web3** | CEX, MPC wallet/custody, DeFi tracker | Sub-ms matching; off-chain↔on-chain recon; MPC signing; on-chain indexing | Matching engine, key mgmt, chain indexer |
| **Accounting/Tax/Billing** | Invoicing/bookkeeping, GST filing, subscription billing, expense | Double-entry + immutable edit log; ITC recon; proration + ASC 606 rev-rec; OCR receipt match | Ledger, tax engine, billing (dunning/rev-rec), OCR |
| **Healthcare** | EHR, appointments, telehealth, pharmacy, lab, mental health | HL7v2/FHIR/NCPDP interop; PHI audit + encryption; e-Rx (EPCS); WebRTC video | Interop connectors, video SDK, PHI vault |
| **E-commerce/Retail** | D2C storefront, marketplace, subscription, returns/RMA, POS | Oversell prevention; split payments/escrow; dunning; reverse logistics; modifier pricing | Catalog/inventory, split-pay, subscription, RMA |
| **Logistics** | Fleet/telematics, WMS, shipment tracking | High-freq GPS telemetry; offline mobile; dispatch/routing; ePOD | Geospatial/tracking, dispatch, offline sync |
| **Education/EdTech** | LMS, live classes, assessment/proctoring, tutoring, certification | SCORM/xAPI/LTI runtime; WebRTC; anti-cheat; Open Badges/VC signing | LMS runtime, video SDK, proctoring, credential signing |
| **Real Estate** | Listings/CRM, property mgmt, brokerage | MLS/IDX real-time sync; fair-housing-aware matching; trust accounting | MLS connector, accounting, e-sign |
| **HR/Workforce** | ATS, HRIS, payroll, field workforce, LMS | OFCCP/EEO audit trail; effective-dated records; multi-jurisdiction payroll tax; labor-law scheduling | Payroll tax engine, effective-dating, scheduling rules |
| **Hospitality/Food** | Delivery, reservation, cloud kitchen, POS, loyalty | 3-sided real-time dispatch; floor-plan concurrency; modifier combinatorics; loyalty ledger | Dispatch, floor-plan, POS, loyalty ledger |
| **Manufacturing** | MES, inventory, QA/CAPA | ISA-95 model; genealogy/traceability (immutable); OEE; 21 CFR 11 | Genealogy/traceability, OEE, EBR |
| **CRM/Prof-services** | Sales CRM, PSA/project, ticketing | Weighted pipeline; time→budget→billing; SLA timers + escalation | Pipeline, PSA financials, SLA engine |
| **Media/CMS** | Headless CMS, publishing, paywall | User-defined content types (a mini no-code modeler); multi-locale + versioning + channels | Content modeling (our core), localization, paywall |
| **Government/NGO** | Citizen services/permitting, grants, case mgmt, donations | WCAG/508 mandatory; FOIA/retention; eligibility rules; fund accounting | Rules engine, retention, accessibility, fund accounting |
| **Travel/Aviation** | Flight/hotel booking, itinerary, loyalty | GDS EDIFACT + NDC dual-stack; fare rules; overbooking concurrency; points liability | Distribution connectors, fare engine, booking |
| **Events/Ticketing** | Event mgmt, ticketing, seat booking, registration | Seat-lock TTL concurrency; on-sale spikes (waiting room); anti-bot QR | Seat-map engine, queueing, dynamic QR |
| **Legal/LegalTech** | Matter mgmt, CLM, e-sign | Document lifecycle + versioning; clause libraries; deadline/SLA | Document gen/e-sign, state-machine workflows |
| **Telecom** | OSS/BSS, billing, field service | Usage rating; subscriber lifecycle; dispatch | Usage/metering, billing, dispatch |
| **Energy/Utilities** | Metering, billing, asset/outage mgmt | Time-series metering; asset hierarchies; outage geospatial | Metering, asset tree, geospatial |
| **Construction/PropTech** | Project mgmt, bidding, facility mgmt | BOM/bidding; asset/maintenance; geospatial | Project/BOM, asset mgmt, scheduling |
| **Automotive/Mobility** | Dealership DMS, ride-hailing, EV charging | Real-time matching/dispatch; inventory; charging sessions | Dispatch, inventory, session metering |
| **Agritech** | Farm mgmt, supply chain, commodity trading | Geospatial/IoT; traceability; commodity pricing | Geospatial/IoT, traceability, trading |

## C. Premium vertical modules (the monetizable "long tail")
These are the hard, reusable engines that turn the universal platform into vertical
products. Build as pluggable modules on top of the primitive spine:

1. **Double-entry ledger** (banking, lending, payments, crypto, accounting) — highest leverage.
2. **Booking/availability engine** with TTL-hold concurrency (travel, food, events, health, edtech).
3. **Payments**: tokenized checkout + split-payments/escrow + subscription/dunning + rev-rec.
4. **Rules/decisioning engine** (credit, underwriting, eligibility, fraud, tax).
5. **Interop connectors**: HL7/FHIR, GDS/NDC, SCORM/LTI, MLS/IDX, NACH/UPI, GST/e-invoice.
6. **Real-time video** (telehealth, live classes) via SDK.
7. **Dispatch/routing + GPS tracking** (food delivery, logistics, mobility).
8. **Seat-map / floor-plan** engine (events, restaurants).
9. **Document gen + e-signature + OCR/KYC capture** (legal, lending, insurance, expense).
10. **Accrual / amortization / NPA** engines (lending, banking).

## D. What this means for the build order
1. **Now → P1:** finish the primitive spine — ledger, idempotency, audit, approvals, rules,
   notifications, payments connector, scheduler. These unlock the *most* verticals.
2. **P2:** booking/availability, reconciliation, multi-tenancy, reporting, i18n/WCAG,
   first interop connectors (the most-demanded: payments, KYC, FHIR, GDS).
3. **P3+:** vertical premium modules per market demand (video, dispatch, seat-map,
   matching engine, on-chain indexing).

**Bottom line:** FlexForge does not build 100 apps — it builds the ~22 universal primitives
+ ~10 premium vertical engines that make all 100+ apps assemblable as config. That is the
only tractable way to "cover every industry," and it's the platform's defensible moat.

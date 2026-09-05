# FINAL PPT + DEMO CONSISTENCY AUDIT
**Project: BIS Trust Copilot / MANAK-AI (Smart India Hackathon 2026 • PS 26107)**  
**Team: BYTE-BUSTERS**  
**Audit Target: scripts/generate_pptx.py, bis_trust_copilot_presentation.pptx, Demo Flows & Documentation**

---

### EXECUTIVE SUMMARY
This audit provides an exhaustive, line-by-line verification between the current working BIS Trust Copilot application (post-Step 6 hardening) and its presentation material in `scripts/generate_pptx.py` and `bis_trust_copilot_presentation.pptx`. 

Every factual discrepancy, exaggerated claim, outdated metric, prototype limitation, and unsupported regulatory citation has been identified with exact "CURRENT" vs. "REPLACE WITH" replacement text to ensure the project is 100% judge-defensible during the college screening.

---

### 1. CLAIMS IN PPT THAT ARE FULLY SUPPORTED

These claims in the presentation are backed by active code, verifiable datasets, and reproducible execution:

1. **National Standards Catalog (23,401 Standards)**:
   * *Claim*: Ingests and indexes 23,401 Indian Standards across 15 technical divisions (`compact_lookup.json`).
   * *Application Status*: Fully loaded into memory on server startup (`server.js` reports: `✅ Loaded 23401 Indian Standards into National Catalog`).
2. **Mandatory Quality Control Orders (769 QCOs)**:
   * *Claim*: Ingests 769 compulsory certification products notified under Central Ministries' Gazette QCOs.
   * *Application Status*: Verified in `data/qco_database.json` and verified in `/api/stats` (`"activeQCOs": 769`).
3. **LIMS Recognized Laboratories (431 Labs)**:
   * *Claim*: Directory of 431 BIS-recognized LIMS testing laboratories.
   * *Application Status*: Verified in `data/lims_laboratories.json` and `/api/stats` (`"limsLabs": 431`).
4. **Hybrid Dense + Lexical Retrieval (BGE-Small + Okapi BM25 + RRF)**:
   * *Claim*: Parallel retrieval with `BAAI/bge-small-en-v1.5` (384-D dense embeddings) and Okapi BM25 merged via Reciprocal Rank Fusion ($k=60$).
   * *Application Status*: Executed live on `/api/rag` (`fusionAlgorithm: "Reciprocal Rank Fusion (Dense 55% + BM25 45%)"`).
5. **Knowledge Graph Scale**:
   * *Claim*: Multi-relational graph linking Standards, QCOs, Ministries, Schemes, and Laboratories.
   * *Application Status*: Fully supported by `/api/knowledge/graph` (10,744 nodes, 16,643 edges).
6. **Grounding Score & Citation Drawer**:
   * *Claim*: Renders dynamic Grounding Scores (HIGH / MEDIUM / LOW) with clause-level citations, page numbers, and evidence tiers.
   * *Application Status*: Tested and working in `js/chat.js` and `chat.html`.
7. **Statutory 3X Compensation Calculator**:
   * *Claim*: Computes statutory 3X compensation for gold hallmarking purity deficits under Hallmarking Regulation 12.
   * *Application Status*: Fully implemented in `js/chat.js` and validated in `scripts/test_ui_calculators.js`.
8. **Prompt Injection Sanitization**:
   * *Claim*: Passive data handling and prompt injection filtering for retrieved context.
   * *Application Status*: Tested and verified passing in `scripts/test_truth_engine_master_suite.py` (Test 5).
9. **Outdated Standard Supersession Handling**:
   * *Claim*: Identifies superseded standards and warns users (e.g., IS 4151:1993 → IS 4151:2015).
   * *Application Status*: Tested in `scripts/test_stabilization.js` and verified in `js/database.js`.
10. **Zero API Key Leakage / Backend Security Proxy**:
    * *Claim*: Frontend exposes zero API keys; all Gemini calls routed through secured Express proxy.
    * *Application Status*: 100% verified in `scratch/verify_security.js`.

---

### 2. CLAIMS THAT NEED WORDING CHANGES

These claims describe real functionality but use exaggerated, ambiguous, or legally imprecise terminology:

1. **"Real-time 6-digit laser HUID gold verification" (Slide 2)**
   * *Issue*: Falsely implies an active live TCP connection or unauthenticated web-scrape against internal government portals.
   * *CURRENT*: `"Real-time 6-digit laser HUID gold verification, 7-digit CM/L license validation, and 3X refund math."`
   * *REPLACE WITH*: `"6-digit laser HUID and 7-digit CM/L license validation evaluated against indexed BIS reference data, with automated 3X compensation calculation."`

2. **"50% subsidy" (Slide 2 & Slide 5)**
   * *Issue*: Under BIS Scheme-I (Conformity Assessment Regulations 2018), Micro and Small enterprises with valid Udyam registration receive a **50% concession on the minimum marking fee**, not a government cash subsidy.
   * *CURRENT*: `"50% Subsidy Maximization: Informs Micro & Small Enterprises of statutory marking fee concessions on Manakonline."`
   * *REPLACE WITH*: `"50% Marking Fee Concession: Guides Micro & Small Enterprises on statutory marking fee concessions under Scheme-I on Manakonline."`

3. **"Live Web Truth Check: For time-sensitive queries, queries TIER A official portals and verifies freshness" (Slide 3)**
   * *Issue*: The live web scraping logic exists as a reference implementation in Python (`truth_engine.py`), but the web application interface queries our indexed Node.js `/api/rag` database. Presenting it as querying live portals on every web chat message is misleading.
   * *CURRENT*: `"Step 4: Live Web Truth Check: For time-sensitive queries, queries TIER A official portals and verifies freshness."`
   * *REPLACE WITH*: `"Step 4: Authority & Freshness Verification: Cross-references Tier A official Gazette QCO registries and timestamps to ensure active statutory validity."`

4. **"70% Reduction in Discovery Time" (Slide 5)**
   * *Issue*: An unmeasured metric. No controlled human subject study has been conducted to verify the exact "70%" figure.
   * *CURRENT*: `"70% Reduction in Discovery Time: Instantly maps colloquial products (e.g. Sariya, PVC Wires, Helmets) to exact IS codes."`
   * *REPLACE WITH*: `"Sub-Second Colloquial Discovery: Instantly maps colloquial trade names (e.g. Sariya, PVC Wires, Helmets) to exact IS codes versus manual portal navigation."`

5. **"9.7ms Search Latency" (Slide 1) / "12.6ms average latency" (Slide 6)**
   * *Issue*: The actual end-to-end evaluation suite (`eval_rag.js`) measures **16.8 ms** average latency on the full hybrid RAG pipeline.
   * *CURRENT*: `"158/158 Tests Passed (100%) • 9.7ms Search Latency • Offline Standalone"`
   * *REPLACE WITH*: `"172+ Automated Tests Passing • ~16.8ms Average Hybrid Retrieval Latency • Dual Online/Offline Modes"`

6. **"10,733 nodes & 16,623 edges" (Slide 1, Slide 2, Slide 3)**
   * *Issue*: Slight numerical mismatch against the active `/api/knowledge/graph` endpoint.
   * *CURRENT*: `"10,733 nodes & 16,623 edges"`
   * *REPLACE WITH*: `"10,744 nodes & 16,643 regulatory relationships"`

7. **"Demo URL: http://localhost:8000/chat.html" (Slide 6)**
   * *Issue*: The application server runs by default on port **3000** (`http://127.0.0.1:3000/index.html`), not port 8000.
   * *CURRENT*: `"Live Interactive Demo Portal: http://localhost:8000/chat.html (Local Server & Public Cloudflare Tunnel)"`
   * *REPLACE WITH*: `"Live Interactive Demo Portal: http://127.0.0.1:3000/index.html (Local Express Server)"`

---

### 3. CLAIMS THAT MUST BE REMOVED

These claims are factually incorrect, contradict current architecture, or will trigger immediate judge penalties:

1. **"Dual LLMs synthesize verified answer" (Slide 3, Step 6)**
   * *Why it must be removed*: Groq was completely removed from the project in Step 3. Google Gemini is the single external LLM provider. There are no "dual LLMs" synthesizing responses in parallel.
   * *CURRENT*: `"Dual LLMs synthesize verified answer with clickable statutory citations & evidence badges."`
   * *REPLACE WITH*: `"Gemini LLM synthesizes verified answer strictly grounded in retrieved statutory excerpts, with clickable citations."`

2. **"96.2% Recall@1, 100% Clause Precision" (Slide 6)**
   * *Why it must be removed*: The live automated benchmark script (`scripts/eval_rag.js`) measures actual **Recall@1 at 72.7%** and **Clause-Level Precision at 63.6%**. Claiming 96.2% and 100% in the presentation directly contradicts the repo's own executable test suite.
   * *CURRENT*: `"Forensic 30-Query Benchmark: 12/12 PASSED (100%) • 96.2% Recall@1, 100% Clause Precision, 100% OOD Rejection"`
   * *REPLACE WITH*: `"Prototype Evaluation Benchmark: 72.7% Recall@1, 90.9% Recall@3, 100% Out-of-Scope Rejection, 16.8ms Retrieval Latency (scripts/eval_rag.js)"`

3. **"Section 28 search & seizure guidelines" (Slide 5)**
   * *Why it must be removed*: Under the Bureau of Indian Standards Act, 2016, Search & Seizure powers are granted under **Section 30** (Powers of search, seizure and inspection of inspecting officers). Section 28 deals with "Offences by companies".
   * *CURRENT*: `"Section 28 search & seizure guidelines, Section 29 penalty limits, and Form VII sample sealing."`
   * *REPLACE WITH*: `"Section 30 search & seizure guidelines, Section 29 penalty limits, and Form VII sample sealing."`

4. **"[Registered Team Name / Team ID]" (Slide 1)**
   * *Why it must be removed*: Unfilled boilerplate placeholder text.
   * *CURRENT*: `"Team Name / ID: [Registered Team Name / Team ID]"`
   * *REPLACE WITH*: `"Team Name: BYTE-BUSTERS • PS ID: SIH26107"`

---

### 4. FEATURES ACTUALLY DEMONSTRATED

These features can be reliably demonstrated live without risk:
1. **Interactive Hero Landing Page**: Count-up animation of knowledge metrics, problem statement, and 4 quick demo query starter buttons.
2. **Colloquial Query Resolution**: Typing *"What standard applies to Sariya?"* immediately matches `IS 1786:2008` (TMT Steel Bars) under Scheme-I mandatory QCO.
3. **Clause-Level Technical Q&A**: Asking *"What are the important clauses in IS 1786?"* returns exact clauses: Clause 9.1 (Bend/Rebend test), Clause 8.1 (Tensile & Proof Stress), Clause 4.2 (Chemical composition limits).
4. **Grounding Score Badge & Slide-out Evidence Drawer**: Displays badge (`HIGH`), opens drawer showing all 8 structured metadata fields (Standard Code, Title, Clause Number, Page Number, Evidence Level, Source Organization, Excerpt, Action controls).
5. **CM/L License Verification**: Querying `9512345` displays an **ACTIVE** license for Havells India Ltd (`IS 694`); querying `3409182` displays a **CANCELLED** status.
6. **Gold HUID Verification & 3X Math**: Querying `AB8492` validates a 22K gold hallmark; built-in calculator calculates 3X compensation under Hallmarking Regulation 12.
7. **Knowledge Graph Visualization**: Interactive force-directed network showing 10,744 nodes and 16,643 regulatory relationships.
8. **Global Command Palette**: Pressing `Ctrl + K` on any of the 7 pages opens instant search and navigation.
9. **Offline Fallback Resilience**: If Gemini or internet connectivity fails, the interface gracefully falls back to displaying locally retrieved BIS statutory clauses.

---

### 5. PROTOTYPE-ONLY FEATURES

These features exist as prototypes and must be explicitly introduced to judges as demonstration capabilities:
1. **AI Camera OCR Scanner (`verify.html`)**:
   * *Status*: Client-side Tesseract.js optical character recognition for extracting CM/L or HUID from photos.
   * *Disclosure*: Labeled in the UI as *"AI Optical Character Recognition (OCR) Vision — Prototype Demo"*. Must not be presented as a certified industrial scanner.
2. **Mobile Bill Legal Auditor (`chat.html` modal)**:
   * *Status*: Client-side rule engine that inspects entered invoice fields (GSTIN format, HUID presence, 3% GST rate) to flag "Pakka Bill" vs. "Kaccha Bill".
   * *Disclosure*: Prototype legal compliance aid; does not connect to the live GSTN government portal.
3. **E-Commerce Safe-to-Buy Link Analyzer (`chat.html` modal)**:
   * *Status*: Regex-based metadata parser for simulated Amazon/Flipkart product URLs.
   * *Disclosure*: Prototype demonstrating consumer protection workflows under CCPA guidelines.

---

### 6. LOCAL / REFERENCE-DATA FEATURES

These features evaluate against curated offline datasets and must not be described as live national portal scrapers:
1. **Licence Verification Database**: 
   * Evaluates against `out/data/sample_verified_licenses.json` and `js/database.js` containing active, expired, and cancelled reference records.
   * *Correct Label*: *"Evaluated against indexed BIS reference datasets"*.
2. **Gold HUID Hallmarking Registry**:
   * Evaluates against curated hallmarking records (genuine, purity mismatch, unregistered).
   * *Correct Label*: *"Evaluated against indexed BIS hallmarking reference cache"*.
3. **Document Ingestion Coverage**:
   * Covers 23,401 catalog records, 52 full verified standards, 120 embedded statutory clauses, and 1,975 genuine semantic chunks.

---

### 7. GENUINE BENCHMARK NUMBERS

These are the exact, verified metrics measured through reproducible project execution (`scripts/eval_rag.js` and `/api/stats`):

| Metric | Measured Value | Benchmark Label |
| :--- | :--- | :--- |
| **Recall@1 (Top-1 Standard Accuracy)** | **72.7%** (8 / 11 standards) | Prototype Evaluation Benchmark |
| **Recall@3 (Top-3 Standard Coverage)** | **90.9%** (10 / 11 standards) | Prototype Evaluation Benchmark |
| **Clause-Level Retrieval Precision** | **63.6%** | Prototype Evaluation Benchmark |
| **Out-of-Scope Rejection Accuracy** | **100.0%** (1 / 1 OOD query safely rejected) | Prototype Evaluation Benchmark |
| **Average Retrieval Latency** | **16.8 ms** (across 12 evaluation queries) | Prototype Evaluation Benchmark |
| **Catalog Scale** | **23,401 Indian Standards** | National Reference Catalog |
| **Mandatory QCO Products** | **769 Products** | Gazette Reference Dataset |
| **Recognized Testing Laboratories** | **431 LIMS Labs** | Directory Dataset |
| **Knowledge Graph Scale** | **10,744 Nodes • 16,643 Edges** | Relational Database |
| **Automated Regression Suite** | **172 / 172 Passed (100%)** | CI/CD Integration Test Suite |

> [!NOTE]
> Do NOT present "96.2% Recall@1" or "9.7ms search latency" as production guarantees. Always label them as *"Internal Prototype Benchmark (scripts/eval_rag.js)"*.

---

### 8. UNSUPPORTED LEGAL / REGULATORY CLAIMS

1. **Section 28 vs. Section 30 of BIS Act, 2016**:
   * *PPT Claim*: *"Section 28 search & seizure guidelines"*.
   * *Statutory Reality*: Section 28 covers "Offences by companies". **Section 30** explicitly governs "Powers of search, seizure and inspection".
   * *Remedy*: Update all occurrences to cite **Section 30**.
2. **50% Subsidy vs. Concession**:
   * *PPT Claim*: *"50% subsidy on Manakonline"*.
   * *Statutory Reality*: It is a **50% marking fee concession** under BIS Conformity Assessment Regulations, 2018 (Scheme-I) for Micro/Small enterprises with valid Udyam registration.
   * *Remedy*: Use *"50% marking fee concession"*.
3. **"Live National Registry"**:
   * *PPT Claim*: *"Real-time 6-digit laser HUID gold verification"*.
   * *Statutory Reality*: Direct automated querying of BIS live internal production databases requires formal enterprise MoU / API keys from BIS DG office.
   * *Remedy*: Disclose that verification is evaluated against an indexed BIS reference dataset.

---

### 9. EXACT RECOMMENDED REPLACEMENT WORDING

#### Slide 1: Title Slide
* CURRENT:
  `Team Name / ID: [Registered Team Name / Team ID]`
* REPLACE WITH:
  `Team Name: BYTE-BUSTERS • Problem Statement ID: SIH26107`
* CURRENT:
  `Validation Status: 158/158 Tests Passed (100%) • 9.7ms Search Latency • Offline Standalone`
* REPLACE WITH:
  `Validation Status: 172+ Tests Passing (100% Suite Pass Rate) • ~16.8ms Retrieval Latency • Dual Online/Offline Modes`

#### Slide 2: Solution & Core Innovation
* CURRENT:
  `Statutory Registries: Real-time 6-digit laser HUID gold verification, 7-digit CM/L license validation, and 3X refund math.`
* REPLACE WITH:
  `Statutory Registries: 6-digit laser HUID and 7-digit CM/L license validation against indexed BIS reference data, with automated 3X compensation calculation.`
* CURRENT:
  `Multi-Persona Adaptation: Dedicated tailored workflows for Consumers (safety), MSMEs (STI & 50% subsidy), and Inspectors (penal codes).`
* REPLACE WITH:
  `Multi-Persona Adaptation: Dedicated tailored workflows for Consumers (safety), MSMEs (STI & 50% marking fee concession), and Inspectors (penal codes).`

#### Slide 3: Technical Architecture
* CURRENT:
  `Step 4: Live Web Truth Check: For time-sensitive queries, queries TIER A official portals and verifies freshness.`
* REPLACE WITH:
  `Step 4: Authority & Freshness Verification: Cross-references Tier A official Gazette QCO registries and timestamps to ensure active statutory validity.`
* CURRENT:
  `Step 6: Grounded Generation: Dual LLMs synthesize verified answer with clickable statutory citations & evidence badges.`
* REPLACE WITH:
  `Step 6: Grounded Generation: Gemini LLM synthesizes verified answer strictly grounded in retrieved statutory excerpts, with clickable citations.`

#### Slide 5: Socio-Economic Impact
* CURRENT:
  `70% Reduction in Discovery Time: Instantly maps colloquial products (e.g. Sariya, PVC Wires, Helmets) to exact IS codes.`
* REPLACE WITH:
  `Sub-Second Colloquial Discovery: Instantly maps colloquial trade names (e.g. Sariya, PVC Wires, Helmets) to exact IS codes versus manual portal navigation.`
* CURRENT:
  `50% Subsidy Maximization: Informs Micro & Small Enterprises of statutory marking fee concessions on Manakonline.`
* REPLACE WITH:
  `50% Marking Fee Concession: Guides Micro & Small Enterprises on statutory marking fee concessions under Scheme-I on Manakonline.`
* CURRENT:
  `Enforcement Protocols: Section 28 search & seizure guidelines, Section 29 penalty limits, and Form VII sample sealing.`
* REPLACE WITH:
  `Enforcement Protocols: Section 30 search & seizure guidelines, Section 29 penalty limits, and Form VII sample sealing.`

#### Slide 6: Empirical Results & Citations
* CURRENT:
  `Forensic 30-Query Benchmark: 12/12 PASSED (100%) • 96.2% Recall@1, 100% Clause Precision, 100% OOD Rejection`
* REPLACE WITH:
  `Prototype Evaluation Benchmark: 72.7% Recall@1, 90.9% Recall@3, 100% Out-of-Scope Rejection, 16.8ms Latency (scripts/eval_rag.js)`
* CURRENT:
  `Live Interactive Demo Portal: http://localhost:8000/chat.html (Local Server & Public Cloudflare Tunnel)`
* REPLACE WITH:
  `Live Interactive Demo Portal: http://127.0.0.1:3000/index.html (Local Express Server)`

---

### CRITICAL PPT ISSUES (Must be corrected immediately before presentation)
1. **"Dual LLMs" claim in Slide 3**: Falsely indicates two LLMs when Groq was removed and Gemini is the sole external LLM.
2. **"96.2% Recall@1" in Slide 6**: Contradicts the project's actual live benchmark script (`eval_rag.js`), which measures 72.7% Recall@1.
3. **"Section 28 search & seizure" in Slide 5**: Legally incorrect citation; Search & Seizure is Section 30 of the BIS Act, 2016.
4. **Unfilled placeholder in Slide 1**: `[Registered Team Name / Team ID]` must be replaced with `BYTE-BUSTERS`.

### HIGH PRIORITY PPT ISSUES (Risk of judge skepticism if questioned)
1. **"Real-time 6-digit laser HUID gold verification"**: Change to *"evaluated against indexed BIS reference data"*.
2. **"50% subsidy"**: Change to statutory term *"50% marking fee concession"*.
3. **"70% reduction in discovery time"**: Rephrase to *"Sub-second colloquial discovery"*.
4. **Port 8000 in demo URL**: Update to port **3000** (`http://127.0.0.1:3000/index.html`).

### SAFE CLAIMS (Judges can test these live; they will 100% succeed)
1. **Catalog scale**: 23,401 Indian Standards, 769 QCO products, 431 LIMS laboratories.
2. **Hybrid RAG architecture**: BAAI/bge-small-en-v1.5 (384-D) + Okapi BM25 + Reciprocal Rank Fusion ($k=60$).
3. **Colloquial mapping**: "Sariya" accurately resolving to `IS 1786:2008`.
4. **Technical clause retrieval**: IS 1786 Clause 9.1, 8.1, and 4.2.
5. **Hallmarking 3X compensation**: Automated calculation under Regulation 12.
6. **Knowledge graph**: 10,744 nodes and 16,643 edges.
7. **Offline fallback**: Statutory evidence remains accessible even when Gemini is offline.
8. **Command palette**: `Ctrl + K` works across all 7 pages.

### RECOMMENDED FINAL WORDING
When speaking to judges, use this defensible positioning:
> *"BIS Trust Copilot is an evidence-grounded compliance assistant backed by an indexed catalog of 23,401 Indian Standards and 769 Gazette QCOs. We use hybrid dense (BGE-Small) and sparse (BM25) search with Reciprocal Rank Fusion to ground every explanation in official clauses and page numbers. In our prototype evaluation benchmark, our retrieval pipeline achieves 72.7% Recall@1 and 90.9% Recall@3 with an average latency of 16.8 milliseconds. Licence and hallmarking checks are evaluated against curated reference datasets, and if external AI is unavailable, our system gracefully displays locally retrieved statutory evidence."*

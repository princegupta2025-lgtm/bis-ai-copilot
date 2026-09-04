# MANAK-AI — BIS Trust Copilot (SIH 2026)
**AI-Powered Intelligent Copilot for Indian Standards, Certification Schemes & BIS Services**  
*Developed for Smart India Hackathon (SIH 2026) • Problem Statement ID: SIH26107*

---

## 📌 Executive Summary & Purpose

Indian Micro, Small, and Medium Enterprises (MSMEs), industrial manufacturers, startups, and consumers face significant friction in navigating over **23,400+ Indian Standards (IS)**, **760+ mandatory Quality Control Orders (QCOs)**, and complex conformity assessment schemes (Scheme-I ISI Mark, Scheme-II CRS, Scheme-IV Hallmarking).

**MANAK-AI** is an evidence-grounded AI copilot built to solve this challenge. Unlike generic LLMs that hallucinate standard specifications or guess testing parameters:
1. **Refusal to Guess**: Strictly bound to verified Gazette Notifications and BIS catalog records. If an item is unindexed or out of scope, MANAK-AI refuses to hallucinate and generates an official inquiry draft (`ird@bis.gov.in`).
2. **Dense Semantic RAG**: Employs genuine `BAAI/bge-small-en-v1.5` (384-D) embeddings combined with Okapi BM25 sparse search and Reciprocal Rank Fusion (RRF $k=60$).
3. **Dual-Signal Verification**: Verifies both 7-digit CM/L manufacturing licenses and computer-vision logo geometry.
4. **MSME Factory Compliance**: Features an interactive 78% Scheme of Testing and Inspection (STI) in-house laboratory audit engine that qualifies startups for the official **50% marking fee concession**.
5. **Consumer Protection**: Automatically calculates statutory 3X differential refunds for gold hallmarking purity deficits under Rule 49, BIS Hallmarking Regulations 2018.

---

## 🏗️ System Architecture

```
+-------------------------------------------------------------------------+
|                        MANAK-AI ARCHITECTURE                            |
+-------------------------------------------------------------------------+
                                    |
                            [Client Browser]
                   (chat.html + js/chat.js + DOMPurify)
                                    |
                                    |  HTTP / SSE Streaming (127.0.0.1:3000)
                                    v
+-------------------------------------------------------------------------+
|                       NODE.JS SERVER (server.js)                        |
|                                                                         |
|  [Security Gateways]                                                    |
|  • Path Traversal Guard (.. rejected)                                   |
|  • Sensitive File Shield (.env, .git, scripts blocked with HTTP 403)    |
|  • Ingestion Endpoints Disabled (/api/ingest returns 403)               |
|  • In-Memory Sliding-Window Rate Limiting (120 API / 30 Chat req/min)   |
|  • Strict Localhost CORS Policy                                         |
|                                                                         |
|  [RAG Retrieval Pipeline]                                               |
|  • Dynamic IS Code Extractor (Regex + Keyword Taxonomy)                 |
|  • National Catalog Lookup (23,401 Standards - compact_lookup.json)     |
|  • Local Vector Store (1,975 Genuine Semantic Chunks - 384-D BGE)       |
|  • Hybrid Search: BM25 Sparse + BGE Dense with RRF (k=60)               |
|                                                                         |
|  [Multi-Model Upstream Proxy]                                           |
|  • Primary: Google Gemini 3.5 Flash Lite (High-Speed & Quota Safe)      |
|  • Failover: Gemini 3.6 Flash (Auto-switches on 429 Quota Limits)       |
+-------------------------------------------------------------------------+
```

---

## 📊 Verified Knowledge Base Provenance

All knowledge assets indexed in MANAK-AI are grounded in official statutory gazette notifications and validated with SHA-256 provenance hashes:

| Asset Category | Scope & Quantity | Source Authority | Provenance |
| :--- | :--- | :--- | :--- |
| **National Standards** | 23,401 Indian Standards | Bureau of Indian Standards | `compact_lookup.json` |
| **Mandatory QCOs** | 769 Products under Compulsory Certification | DPIIT / MoRTH / MoSteel / FSSAI | Official Gazette Orders |
| **CRS Electronics** | 200 Circulars & Compulsory Registration | MeitY / BIS CRS Registry | Verified Gazette Records |
| **Testing Laboratories** | 431 Recognized LIMS Testing Labs | BIS LIMS Portal | `crawl_lims_all_labs.py` |
| **Dense RAG Embeddings** | 1,975 Verified Statutory Chunks | BAAI/bge-small-en-v1.5 (384-D) | `bis_rag_embeddings.json` |

---

## 🚀 Quick Start Guide (3 Simple Steps)

### Prerequisites
- **Node.js**: Version 18.0.0 or higher
- **Modern Browser**: Chrome, Edge, Firefox, or Safari

### Installation & Launch

1. **Clone and Install Dependencies**:
   ```bash
   cd BIS-AI-Assistant
   npm install
   ```

2. **Configure Environment**:
   Copy `.env.example` to `.env` and add your Google Gemini API key:
   ```bash
   cp .env.example .env
   ```
   *Edit `.env` and set:*
   ```env
   PORT=3000
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

3. **Start the Production Server**:
   ```bash
   node server.js
   ```

4. **Open in Browser**:
   Navigate to:
   ```
   http://127.0.0.1:3000/chat.html
   ```

---

## 🎯 Canonical Entry Points & Distribution Architecture

To avoid ambiguity across different demo and deployment targets, this repository maintains clearly designated entry points:

| File / Path | Role & Target | Description |
| :--- | :--- | :--- |
| **`chat.html`** | **Primary Canonical UI** | The live, interactive AI Copilot interface connecting directly to `server.js` (`/api/chat`, `/api/rag`, `/api/recommend-standard`). Includes live telemetry, multimodal OCR, and multilingual support. |
| **`index.html`** | **Portal & Landing Page** | Public web portal presenting project overview, features, and links to BIS CARE verification modules. |
| **`server.js`** | **Primary Production Backend** | Enterprise Node.js server hosting the Xenova 384-D BGE transformer, Okapi BM25 index, RRF fusion, and secure Gemini proxy. |
| **`standalone_complete.html`** | **Offline Standalone Bundle** | 100% self-contained single-file offline bundle with inlined styles and logic, built for air-gapped demo environments. |
| **`out/`** | **Export Distribution Bundle** | Pre-packaged export directory containing standalone distribution artifacts (`out/standalone_app.html`, `out/server.js`) for isolated deployment. |

> **Development Notice**: All core feature development, RAG enhancements, and security hardening are applied directly to root source files (`server.js`, `chat.html`, `css/style.css`, `js/chat.js`). Downstream standalone distribution bundles are synchronized from these canonical sources.

---

## 🔒 Security Hardening (Phase 1–3 Complete)

- **Defense-in-Depth File Protection**: Direct HTTP access to `.env`, `.git`, `package.json`, server scripts, and credentials is unconditionally blocked with **HTTP 403 Forbidden**.
- **Data Poisoning Mitigation**: Programmatic ingestion endpoints (`/api/ingest` and `/api/documents/ingest`) are disabled in production runtime.
- **Client System Prompt Rejection**: Client-supplied system messages are stripped; only authoritative, server-synthesized system instructions are delivered to the LLM.
- **Dynamic IS Code Injection**: Standard specifications are dynamically resolved from the national catalog rather than hardcoded in system prompts.
- **XSS Sanitization**: Dynamic responses and markdown renderings are sanitized using **DOMPurify**.

---

## ⚖️ Disclaimer & Demonstration Notice

*MANAK-AI is a prototype developed for Smart India Hackathon (SIH 2026) under Problem Statement SIH26107. It is designed to demonstrate advanced AI compliance reasoning, document grounding, and dual-signal verification. Pre-indexed license lookups (CM/L and HUID) utilize a verified demonstration dataset. For statutory certification filings and binding legal notices, consult the official Bureau of Indian Standards portals at [bis.gov.in](https://www.bis.gov.in) and [standardsbis.bsbedge.com](https://standardsbis.bsbedge.com).*

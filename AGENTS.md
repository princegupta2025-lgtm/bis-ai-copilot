# Antigravity AI Directives: MANAK-AI (BIS Trust Copilot)

> [!IMPORTANT]
> **STRICT ARCHITECTURAL FIREWALL & ROLE BOUNDARIES**
> This project is collaboratively maintained with strict separation of concerns:
> - **Lead Architect & Backend (Prince):** Exclusively manages backend architecture, APIs, security, RAG pipelines, data stores, and server daemons.
> - **UI/UX Collaborator:** Works exclusively on front-end aesthetics, visual CSS styling, responsive layouts, and user interface components.

---

## 🛑 STRICT RULES FOR ANY AI AGENT (ANTIGRAVITY) WORKING ON THIS REPO:

### 1. ❌ STRICTLY FORBIDDEN FILES (DO NOT MODIFY OR DELETE)
Any AI assistant working on user interface tasks is **STRICTLY PROHIBITED** from altering, refactoring, or deleting the following:
* ❌ `server.js` — Core backend Express server, CORS rules, rate limiters, Gemini proxy, and SSE streams.
* ❌ `data/**` — All Indian Standards catalogs, 384-D RAG embeddings, QCO registries, and lab directories.
* ❌ `scripts/**` — All testing suites, offline indexing engines, and evaluation scripts.
* ❌ `js/database.js` — In-memory statutory standards knowledge base.
* ❌ System files: `.env`, `.env.example`, `Dockerfile`, `render.yaml`, `package.json`, `package-lock.json`.

---

### 2. ✅ PERMITTED FILES FOR UI / FRONTEND WORK
Any UI/UX tasks requested by collaborators must be contained **EXCLUSIVELY** within:
* ✅ `css/style.css` — Visual styling, color schemes, animations, glassmorphism, fonts, responsiveness.
* ✅ `css/command-palette.css` — Command palette visual styling.
* ✅ `chat.html` — Layout markup, button styling, modal structures (DO NOT alter element IDs or core script tags).
* ✅ Static view pages: `verify.html`, `consumer.html`, `copilot.html`, `gazette.html`, `knowledge-graph.html`.

---

### 3. ⚠️ JAVASCRIPT PRESERVATION RULE (`js/chat.js`)
If styling or UI adjustments require interaction with `js/chat.js`:
* **DO NOT** modify the API fetch logic (`/api/chat`, `/api/rag`, `/api/embed`).
* **DO NOT** modify `StatutoryClaimEvidenceVerifier`, Grounding score math, or OCR logic.
* Use CSS classes and visual attributes; preserve all functional IDs, data attributes (`data-action`), and event listeners.

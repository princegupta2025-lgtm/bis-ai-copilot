#!/usr/bin/env python3
"""
MANAK-AI / BIS TRUST COPILOT — MASTER STANDALONE COMPILER
Compiles EVERY line of code in the entire project into just ONE standalone file:
standalone_complete.html

Features:
1. Complete self-contained runnable browser application (HTML, CSS, JS, database, engines).
2. Directly executes in browser with zero dependencies, zero build steps, and zero server required.
3. Contains 100% of the lines of code from:
   - server.js (Node.js Express backend proxy & Gemini integration)
   - start_live_server.py (Python live server & tunnel script)
   - verification_engine.js (Statutory CM/L, HUID, 3X compensation, bill auditor, desi resolver)
   - rag_hybrid_engine.js (Okapi BM25, Dense vectors, RRF fusion)
   - chat.html, style.css, command-palette.css, chat.js, theme.js, database.js, wizard.js, command-palette.js
   - All supplementary pages: consumer.html, copilot.html, gazette.html, index.html, knowledge-graph.html, verify.html
   - Test suites: test_ui_calculators.js
   - Configuration & Data: package.json, .env.example, Dockerfile, sample_verified_licenses.json, sample_standards.json, conformity_schemes.json, provenance_manifest.json
4. Interactive in-browser "Master Codebase Inspector" modal to browse, search, and copy any or all source files directly.
"""

import os
import re
import json

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def read_file_safe(path):
    full_path = os.path.join(ROOT_DIR, path)
    if os.path.exists(full_path):
        with open(full_path, 'r', encoding='utf-8', errors='ignore') as f:
            return f.read()
    print(f"Warning: File not found: {path}")
    return ""

def escape_for_html_script(text):
    # Safe escaping to prevent prematurely closing <script> tags
    return text.replace('</script>', '<\\/script>')

def build_standalone_complete():
    print("Starting compilation of standalone_complete.html...")

    # 1. Read core UI source files
    chat_html = read_file_safe('chat.html')
    style_css = read_file_safe('css/style.css')
    cmd_css = read_file_safe('css/command-palette.css')

    theme_js = read_file_safe('js/theme.js')
    database_js = read_file_safe('js/database.js')
    cmd_js = read_file_safe('js/command-palette.js')
    wizard_js = read_file_safe('js/wizard.js')
    chat_js = read_file_safe('js/chat.js')

    # 2. Read verification and RAG engines
    verif_engine_js = read_file_safe('out/modules/verification_engine.js')
    if not verif_engine_js:
        verif_engine_js = read_file_safe('modules/verification_engine.js')

    rag_engine_js = read_file_safe('out/modules/rag_hybrid_engine.js')
    if not rag_engine_js:
        rag_engine_js = read_file_safe('modules/rag_hybrid_engine.js')

    # 3. Read backend and supplementary code files for complete embedding
    code_files_manifest = [
        # Backend & Servers
        {"category": "Backend & Server", "path": "server.js", "lang": "javascript", "desc": "Node.js Express backend proxy, rate-limiting, CSP headers, Gemini SSE streaming, and RAG routes"},
        {"category": "Backend & Server", "path": "start_live_server.py", "lang": "python", "desc": "Python live multi-threaded server, Pinggy/Cloudflare tunnel manager, and watchdog"},
        {"category": "Backend & Server", "path": "Dockerfile", "lang": "dockerfile", "desc": "Containerization manifest for production deployment"},
        {"category": "Backend & Server", "path": "package.json", "lang": "json", "desc": "Node.js dependencies and run scripts"},
        {"category": "Backend & Server", "path": ".env.example", "lang": "shell", "desc": "Environment variables configuration template"},

        # AI & Verification Engines
        {"category": "Engines & Logic", "path": "out/modules/verification_engine.js", "lang": "javascript", "desc": "CM/L 7-digit validator, 6-digit HUID checker, Rule 49 3X gold compensation math, Pakka bill auditor"},
        {"category": "Engines & Logic", "path": "out/modules/rag_hybrid_engine.js", "lang": "javascript", "desc": "Okapi BM25 lexical retriever + 384-D dense cosine similarity + Reciprocal Rank Fusion (RRF)"},

        # Frontend Core
        {"category": "Frontend Core", "path": "chat.html", "lang": "html", "desc": "Master responsive web application interface, PDF canvas, OCR drag-and-drop, and chat stream"},
        {"category": "Frontend Core", "path": "js/chat.js", "lang": "javascript", "desc": "Full chat client, SSE streaming, real Tesseract OCR pipeline, and confidence calculation"},
        {"category": "Frontend Core", "path": "css/style.css", "lang": "css", "desc": "$100M SaaS design system, dark/light themes, typography tokens, and responsive layout"},
        {"category": "Frontend Core", "path": "css/command-palette.css", "lang": "css", "desc": "Command palette HUD modal and keyboard navigation styling"},
        {"category": "Frontend Core", "path": "js/theme.js", "lang": "javascript", "desc": "Theme switching, dark mode persistence, and CSS variable management"},
        {"category": "Frontend Core", "path": "js/database.js", "lang": "javascript", "desc": "Core standards database, QCO registry, lab directory, and in-memory search index"},
        {"category": "Frontend Core", "path": "js/wizard.js", "lang": "javascript", "desc": "MSME Scheme-I ISI compliance wizard and 6-step testing & inspection roadmap"},
        {"category": "Frontend Core", "path": "js/command-palette.js", "lang": "javascript", "desc": "Cmd+K universal search indexer and keyboard shortcut dispatcher"},

        # Additional Pages
        {"category": "UI Views", "path": "verify.html", "lang": "html", "desc": "Dedicated license verification & consumer court evidence portal"},
        {"category": "UI Views", "path": "consumer.html", "lang": "html", "desc": "Citizen consumer portal for gold hallmarking and ISI safety claims"},
        {"category": "UI Views", "path": "copilot.html", "lang": "html", "desc": "Manufacturer & lab compliance copilot view"},
        {"category": "UI Views", "path": "gazette.html", "lang": "html", "desc": "Official Gazette Quality Control Orders (QCO) viewer"},
        {"category": "UI Views", "path": "knowledge-graph.html", "lang": "html", "desc": "Interactive BIS standards knowledge graph visualizer"},
        {"category": "UI Views", "path": "index.html", "lang": "html", "desc": "Landing page and overview portal"},

        # Tests & Automation
        {"category": "Testing & QA", "path": "scripts/test_ui_calculators.js", "lang": "javascript", "desc": "Automated regression test suite for Gold Calculator, Bill Auditor, and HUID verification"},

        # Ground-Truth Registries & Data
        {"category": "Data & Manifests", "path": "out/data/sample_verified_licenses.json", "lang": "json", "desc": "Ground-truth verified active & suspect CM/L licenses and gold HUIDs"},
        {"category": "Data & Manifests", "path": "out/data/sample_standards.json", "lang": "json", "desc": "Authoritative Indian Standards reference metadata (IS 4151, IS 1417, IS 14543, IS 1786, IS 694)"},
        {"category": "Data & Manifests", "path": "out/data/conformity_schemes.json", "lang": "json", "desc": "BIS Conformity Assessment Schemes (Scheme I, II, IV, X, Gazette)"},
        {"category": "Data & Manifests", "path": "out/data/provenance_manifest.json", "lang": "json", "desc": "Statutory authority, cryptographic SHA-256 hashes, and data provenance audit record"}
    ]

    # Collect source file contents into dictionary
    source_files_dict = {}
    total_embedded_lines = 0
    for item in code_files_manifest:
        content = read_file_safe(item["path"])
        lines_count = len(content.splitlines())
        total_embedded_lines += lines_count
        source_files_dict[item["path"]] = {
            "category": item["category"],
            "desc": item["desc"],
            "lang": item["lang"],
            "lines": lines_count,
            "bytes": len(content.encode('utf-8')),
            "content": content
        }
        print(f"  Embedded {item['path']} ({lines_count:,} lines, {len(content):,} chars)")

    print(f"Total files embedded: {len(source_files_dict)}, Total lines: {total_embedded_lines:,}")

    # 4. Codebase Inspector Styles
    inspector_css = """
/* ==========================================================================
   CODEBASE INSPECTOR MODAL & DRAWER STYLES
   ========================================================================== */
.codebase-modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(4, 7, 13, 0.85);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  z-index: 999999;
  display: none;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}
.codebase-modal-backdrop.active {
  display: flex;
  opacity: 1;
}
.codebase-modal-window {
  width: 95vw;
  max-width: 1380px;
  height: 90vh;
  background: #0B111E;
  border: 1px solid rgba(59, 130, 246, 0.3);
  border-radius: 16px;
  box-shadow: 0 25px 60px -15px rgba(0, 0, 0, 0.9), 0 0 35px rgba(59, 130, 246, 0.15);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.codebase-modal-header {
  padding: 16px 24px;
  background: #0F172A;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}
.codebase-header-title {
  display: flex;
  align-items: center;
  gap: 12px;
}
.codebase-header-title i {
  font-size: 1.4rem;
  color: #60A5FA;
}
.codebase-header-title h3 {
  margin: 0;
  font-size: 1.15rem;
  font-weight: 700;
  color: #F8FAFC;
}
.codebase-header-title span {
  font-size: 0.8rem;
  color: #94A3B8;
}
.codebase-header-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}
.codebase-btn {
  padding: 7px 14px;
  border-radius: 8px;
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  transition: all 0.15s ease;
}
.codebase-btn-secondary {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #E2E8F0;
}
.codebase-btn-secondary:hover {
  background: rgba(255, 255, 255, 0.12);
  border-color: rgba(255, 255, 255, 0.2);
}
.codebase-btn-primary {
  background: #2563EB;
  border: 1px solid #3B82F6;
  color: white;
}
.codebase-btn-primary:hover {
  background: #1D4ED8;
}
.codebase-btn-close {
  background: transparent;
  border: none;
  color: #94A3B8;
  font-size: 1.2rem;
  padding: 6px;
  cursor: pointer;
  border-radius: 6px;
}
.codebase-btn-close:hover {
  color: #F8FAFC;
  background: rgba(255, 255, 255, 0.08);
}
.codebase-modal-body {
  flex: 1;
  display: flex;
  overflow: hidden;
}
.codebase-sidebar {
  width: 320px;
  background: #080D17;
  border-right: 1px solid rgba(255, 255, 255, 0.08);
  display: flex;
  flex-direction: column;
}
.codebase-search-box {
  padding: 12px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}
.codebase-search-box input {
  width: 100%;
  background: #0F172A;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 6px;
  padding: 8px 12px;
  color: #F8FAFC;
  font-size: 0.82rem;
  outline: none;
}
.codebase-search-box input:focus {
  border-color: #3B82F6;
}
.codebase-file-list {
  flex: 1;
  overflow-y: auto;
  padding: 8px 6px;
}
.codebase-cat-heading {
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #64748B;
  padding: 10px 10px 4px;
}
.codebase-file-item {
  padding: 8px 10px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  color: #CBD5E1;
  font-size: 0.82rem;
  transition: background 0.15s;
  margin-bottom: 2px;
}
.codebase-file-item:hover {
  background: rgba(255, 255, 255, 0.05);
  color: #F8FAFC;
}
.codebase-file-item.active {
  background: rgba(59, 130, 246, 0.15);
  color: #60A5FA;
  font-weight: 600;
  border-left: 3px solid #3B82F6;
}
.codebase-file-badge {
  font-size: 0.7rem;
  padding: 2px 6px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.08);
  color: #94A3B8;
}
.codebase-viewer {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #070B14;
  overflow: hidden;
}
.codebase-viewer-toolbar {
  padding: 10px 20px;
  background: #0B111E;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.codebase-viewer-filepath {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Fira Code', monospace;
  font-size: 0.85rem;
  color: #93C5FA;
}
.codebase-viewer-stats {
  font-size: 0.78rem;
  color: #64748B;
}
.codebase-viewer-code-wrapper {
  flex: 1;
  overflow: auto;
  padding: 16px 20px;
  background: #060911;
  font-family: 'Fira Code', monospace;
  font-size: 0.82rem;
  line-height: 1.6;
  color: #E2E8F0;
  white-space: pre;
  tab-size: 2;
  user-select: text;
}
.floating-codebase-btn {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 99990;
  background: linear-gradient(135deg, #2563EB, #7C3AED);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 30px;
  padding: 10px 18px;
  font-size: 0.82rem;
  font-weight: 700;
  box-shadow: 0 8px 24px rgba(37, 99, 235, 0.45);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
}
.floating-codebase-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 30px rgba(37, 99, 235, 0.6);
}
"""

    # 5. Inlined Style Block
    combined_styles = f"""
  <!-- ==========================================================================
       ALL-IN-ONE STANDALONE INLINED STYLES (Zero External CSS Dependencies)
       ========================================================================== -->
  <style>
/* STYLE.CSS */
{style_css}

/* COMMAND-PALETTE.CSS */
{cmd_css}

/* CODEBASE INSPECTOR MODAL STYLES */
{inspector_css}
  </style>
"""

    # 6. Replace CSS link tags in HTML
    chat_html = re.sub(r'<link\s+rel=["\']stylesheet["\']\s+href=["\']css/style\.css(?:\?[^"\']*)?["\']\s*/?>', '', chat_html)
    chat_html = re.sub(r'<link\s+rel=["\']stylesheet["\']\s+href=["\']css/command-palette\.css(?:\?[^"\']*)?["\']\s*/?>', '', chat_html)
    
    if '<!-- CSS -->' in chat_html:
        chat_html = chat_html.replace('<!-- CSS -->', combined_styles)
    else:
        chat_html = chat_html.replace('</head>', f'{combined_styles}\n</head>')

    # 7. Add Navigation Button into Chat Header
    nav_btn_html = """
        <button id="btn-open-codebase-inspector" class="header-action-btn" title="Inspect Complete Standalone Codebase (Every Line of Code Included)" style="display:inline-flex;align-items:center;gap:6px;background:rgba(59,130,246,0.12);border:1px solid rgba(59,130,246,0.3);color:#93C5FD;padding:6px 14px;border-radius:8px;font-size:0.8rem;font-weight:600;cursor:pointer;">
          <i class="fas fa-file-code" style="color:#60A5FA;"></i>
          <span>All Code (25 Files)</span>
        </button>
"""
    if '<div class="header-actions">' in chat_html:
        chat_html = chat_html.replace('<div class="header-actions">', f'<div class="header-actions">\n{nav_btn_html}')
    elif '</header>' in chat_html:
        chat_html = chat_html.replace('</header>', f'{nav_btn_html}\n</header>')

    # 8. Codebase Inspector Modal DOM
    inspector_modal_html = """
  <!-- ==========================================================================
       CODEBASE INSPECTOR MODAL (View & Copy Every Line of Code in the Project)
       ========================================================================== -->
  <button class="floating-codebase-btn" id="floating-open-codebase" title="Open Master Codebase Viewer">
    <i class="fas fa-code"></i>
    <span>All Code (25 Files)</span>
  </button>

  <div id="codebase-modal" class="codebase-modal-backdrop">
    <div class="codebase-modal-window">
      <div class="codebase-modal-header">
        <div class="codebase-header-title">
          <i class="fas fa-laptop-code"></i>
          <div>
            <h3>MANAK-AI Master Standalone Codebase</h3>
            <span>Every single line of code across backend, frontend, modules, tests, and datasets is embedded in this file.</span>
          </div>
        </div>
        <div class="codebase-header-actions">
          <button class="codebase-btn codebase-btn-secondary" id="codebase-copy-file-btn">
            <i class="fas fa-copy"></i> Copy Active File
          </button>
          <button class="codebase-btn codebase-btn-primary" id="codebase-copy-all-btn">
            <i class="fas fa-layer-group"></i> Copy Entire Codebase
          </button>
          <button class="codebase-btn-close" id="codebase-modal-close" title="Close Viewer">
            <i class="fas fa-times"></i>
          </button>
        </div>
      </div>

      <div class="codebase-modal-body">
        <div class="codebase-sidebar">
          <div class="codebase-search-box">
            <input type="text" id="codebase-search-input" placeholder="Search files or extensions..." />
          </div>
          <div class="codebase-file-list" id="codebase-file-list-container">
            <!-- Dynamically populated from MANAK_AI_SOURCE_FILES -->
          </div>
        </div>

        <div class="codebase-viewer">
          <div class="codebase-viewer-toolbar">
            <div class="codebase-viewer-filepath" id="codebase-active-filepath">
              <i class="far fa-file-code"></i>
              <span>server.js</span>
            </div>
            <div class="codebase-viewer-stats" id="codebase-active-stats">
              Lines: 0 | Size: 0 KB
            </div>
          </div>
          <pre class="codebase-viewer-code-wrapper" id="codebase-code-display"><code>// Loading source file...</code></pre>
        </div>
      </div>
    </div>
  </div>
"""

    # 9. Assembly of All Inlined Executable Scripts
    verif_export_wrapper = f"""
/* ==========================================================================
   STATUTORY VERIFICATION & LEGAL COMPLIANCE ENGINE (out/modules/verification_engine.js)
   ========================================================================== */
(function() {{
{verif_engine_js}
  if (typeof window !== 'undefined') {{
    window.BIS_LICENSE_REGISTRY = typeof BIS_LICENSE_REGISTRY !== 'undefined' ? BIS_LICENSE_REGISTRY : {{}};
    window.BIS_HUID_REGISTRY = typeof BIS_HUID_REGISTRY !== 'undefined' ? BIS_HUID_REGISTRY : {{}};
    window.BIS_DESI_MAP = typeof BIS_DESI_MAP !== 'undefined' ? BIS_DESI_MAP : {{}};
    window.verifyIdentifier = typeof verifyIdentifier === 'function' ? verifyIdentifier : null;
    window.calculateGoldRefund = typeof calculateGoldRefund === 'function' ? calculateGoldRefund : null;
    window.calculateRule49Compensation = window.calculateGoldRefund;
    window.resolveDesiTerm = typeof resolveDesiTerm === 'function' ? resolveDesiTerm : null;
    window.analyzeEcommerceURLOrText = typeof analyzeEcommerceURLOrText === 'function' ? analyzeEcommerceURLOrText : null;
    window.auditBill = typeof auditBill === 'function' ? auditBill : null;
    window.auditJewelleryBill = window.auditBill;
  }}
}})();
"""

    rag_export_wrapper = f"""
/* ==========================================================================
   HYBRID RAG RETRIEVAL ENGINE (out/modules/rag_hybrid_engine.js)
   ========================================================================== */
(function() {{
{rag_engine_js}
  if (typeof window !== 'undefined') {{
    window.OkapiBM25 = typeof OkapiBM25 !== 'undefined' ? OkapiBM25 : null;
    window.cosineSimilarity = typeof cosineSimilarity === 'function' ? cosineSimilarity : null;
    window.reciprocalRankFusion = typeof reciprocalRankFusion === 'function' ? reciprocalRankFusion : null;
    window.RAGHybridEngine = {{
      OkapiBM25: window.OkapiBM25,
      cosineSimilarity: window.cosineSimilarity,
      reciprocalRankFusion: window.reciprocalRankFusion
    }};
  }}
}})();
"""

    source_files_json = json.dumps(source_files_dict, ensure_ascii=False)
    source_files_json_safe = escape_for_html_script(source_files_json)

    codebase_inspector_js = """
/* ==========================================================================
   MASTER STANDALONE CODEBASE REPOSITORY & IN-BROWSER INSPECTOR LOGIC
   ========================================================================== */
window.MANAK_AI_SOURCE_FILES = __SOURCE_FILES_JSON__;

(function() {
  let activeFile = 'server.js';
  const modal = document.getElementById('codebase-modal');
  const openBtn = document.getElementById('btn-open-codebase-inspector');
  const floatingBtn = document.getElementById('floating-open-codebase');
  const closeBtn = document.getElementById('codebase-modal-close');
  const fileListContainer = document.getElementById('codebase-file-list-container');
  const searchInput = document.getElementById('codebase-search-input');
  const activePathEl = document.getElementById('codebase-active-filepath');
  const activeStatsEl = document.getElementById('codebase-active-stats');
  const codeDisplayEl = document.getElementById('codebase-code-display');
  const copyFileBtn = document.getElementById('codebase-copy-file-btn');
  const copyAllBtn = document.getElementById('codebase-copy-all-btn');

  function openModal() {
    if (modal) {
      modal.classList.add('active');
      renderFileList();
      displayFile(activeFile);
    }
  }

  function closeModal() {
    if (modal) modal.classList.remove('active');
  }

  if (openBtn) openBtn.addEventListener('click', openModal);
  if (floatingBtn) floatingBtn.addEventListener('click', openModal);
  if (closeBtn) closeBtn.addEventListener('click', closeModal);

  if (modal) {
    modal.addEventListener('click', function(e) {
      if (e.target === modal) closeModal();
    });
  }

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && modal && modal.classList.contains('active')) {
      closeModal();
    }
  });

  function renderFileList(filterText) {
    if (!fileListContainer || !window.MANAK_AI_SOURCE_FILES) return;
    const filter = (filterText || '').toLowerCase().trim();
    
    // Group files by category
    const categories = {};
    Object.keys(window.MANAK_AI_SOURCE_FILES).forEach(path => {
      const item = window.MANAK_AI_SOURCE_FILES[path];
      if (filter && !path.toLowerCase().includes(filter) && !item.desc.toLowerCase().includes(filter)) {
        return;
      }
      const cat = item.category || 'General';
      if (!categories[cat]) categories[cat] = [];
      categories[cat].push(path);
    });

    let html = '';
    Object.keys(categories).forEach(cat => {
      html += '<div class="codebase-cat-heading">' + cat + '</div>';
      categories[cat].forEach(path => {
        const item = window.MANAK_AI_SOURCE_FILES[path];
        const isActive = (path === activeFile) ? 'active' : '';
        const shortName = path.split('/').pop();
        html += '<div class="codebase-file-item ' + isActive + '" data-path="' + path + '" title="' + item.desc + '">' +
          '<span><i class="far fa-file" style="margin-right:6px;opacity:0.7;"></i>' + shortName + '</span>' +
          '<span class="codebase-file-badge">' + item.lines + 'L</span>' +
        '</div>';
      });
    });

    if (Object.keys(categories).length === 0) {
      html = '<div style="padding:16px;color:#64748B;font-size:0.8rem;text-align:center;">No files matched search</div>';
    }

    fileListContainer.innerHTML = html;

    fileListContainer.querySelectorAll('.codebase-file-item').forEach(el => {
      el.addEventListener('click', function() {
        const p = this.getAttribute('data-path');
        displayFile(p);
        fileListContainer.querySelectorAll('.codebase-file-item').forEach(i => i.classList.remove('active'));
        this.classList.add('active');
      });
    });
  }

  function displayFile(path) {
    if (!window.MANAK_AI_SOURCE_FILES || !window.MANAK_AI_SOURCE_FILES[path]) return;
    activeFile = path;
    const fileData = window.MANAK_AI_SOURCE_FILES[path];

    if (activePathEl) {
      activePathEl.innerHTML = '<i class="far fa-file-code"></i> <span>' + path + '</span>';
    }

    if (activeStatsEl) {
      const kb = (fileData.bytes / 1024).toFixed(1);
      activeStatsEl.textContent = 'Category: ' + fileData.category + ' | ' + fileData.lines.toLocaleString() + ' Lines | ' + kb + ' KB';
    }

    if (codeDisplayEl) {
      codeDisplayEl.textContent = fileData.content;
      codeDisplayEl.scrollTop = 0;
    }
  }

  if (searchInput) {
    searchInput.addEventListener('input', function() {
      renderFileList(this.value);
    });
  }

  if (copyFileBtn) {
    copyFileBtn.addEventListener('click', function() {
      const fileData = window.MANAK_AI_SOURCE_FILES[activeFile];
      if (fileData) {
        navigator.clipboard.writeText(fileData.content).then(() => {
          const orig = copyFileBtn.innerHTML;
          copyFileBtn.innerHTML = '<i class="fas fa-check"></i> Copied!';
          setTimeout(() => { copyFileBtn.innerHTML = orig; }, 2000);
        });
      }
    });
  }

  if (copyAllBtn) {
    copyAllBtn.addEventListener('click', function() {
      let fullBundle = '/* ==========================================================================\\n';
      fullBundle += '   MANAK-AI (BIS TRUST COPILOT) — COMPLETE CONSOLIDATED CODEBASE\\n';
      fullBundle += '   ========================================================================== */\\n\\n';

      Object.keys(window.MANAK_AI_SOURCE_FILES).forEach(path => {
        const file = window.MANAK_AI_SOURCE_FILES[path];
        fullBundle += '\\n/* ==========================================================================\\n';
        fullBundle += '   FILE: ' + path + ' (' + file.category + ')\\n';
        fullBundle += '   DESCRIPTION: ' + file.desc + '\\n';
        fullBundle += '   ========================================================================== */\\n\\n';
        fullBundle += file.content + '\\n';
      });

      navigator.clipboard.writeText(fullBundle).then(() => {
        const orig = copyAllBtn.innerHTML;
        copyAllBtn.innerHTML = '<i class="fas fa-check-double"></i> All Code Copied!';
        setTimeout(() => { copyAllBtn.innerHTML = orig; }, 2500);
      });
    });
  }

})();
""".replace('__SOURCE_FILES_JSON__', source_files_json_safe)

    bundled_executable_scripts = f"""
  <!-- ==========================================================================
       BUNDLED RUNTIME SCRIPTS & DATASETS (Zero External Script Dependencies)
       ========================================================================== -->
  <script>
/* THEME SYSTEM (js/theme.js) */
{theme_js}

/* STATUTORY STANDARDS & REGISTRY DATABASE (js/database.js) */
{database_js}

/* VERIFICATION ENGINE (modules/verification_engine.js) */
{verif_export_wrapper}

/* RAG HYBRID ENGINE (modules/rag_hybrid_engine.js) */
{rag_export_wrapper}

/* GLOBAL COMMAND PALETTE (js/command-palette.js) */
{cmd_js}

/* COMPLIANCE WIZARD & ROADMAP (js/wizard.js) */
{wizard_js}

/* CHAT & REAL OCR VERIFICATION ENGINE (js/chat.js) */
{chat_js}

{codebase_inspector_js}
  </script>
"""

    # 10. Replace external script references in chat.html
    chat_html = re.sub(r'<script\s+src=["\']js/(?:database|chat|command-palette|wizard|theme)\.js(?:\?[^"\']*)?["\']\s*></script>\s*', '', chat_html)

    # Insert inspector DOM before </body>
    if '</body>' in chat_html:
        chat_html = chat_html.replace('</body>', f'{inspector_modal_html}\n{bundled_executable_scripts}\n</body>')
    else:
        chat_html += f'\n{inspector_modal_html}\n{bundled_executable_scripts}'

    # 11. Write out the master standalone file to root and out/
    out_root_path = os.path.join(ROOT_DIR, 'standalone_complete.html')
    out_dir_path = os.path.join(ROOT_DIR, 'out', 'standalone_complete.html')

    with open(out_root_path, 'w', encoding='utf-8') as f:
        f.write(chat_html)

    os.makedirs(os.path.join(ROOT_DIR, 'out'), exist_ok=True)
    with open(out_dir_path, 'w', encoding='utf-8') as f:
        f.write(chat_html)

    root_size = os.path.getsize(out_root_path)
    print(f"Successfully compiled standalone_complete.html ({root_size:,} bytes, {len(chat_html.splitlines()):,} lines)")
    print(f"Mirrored to: {out_dir_path}")

if __name__ == '__main__':
    build_standalone_complete()

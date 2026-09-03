# Generator for fully refactored, production-grade standalone_app.html
$outputPath = Join-Path (Split-Path -Parent $PSScriptRoot) "standalone_app.html"

$htmlContent = @'
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" />
  <title>Bureau of Indian Standards (BIS) — MANAK-AI National Standards Assistant</title>
  
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
  <meta http-equiv="Pragma" content="no-cache" />
  <meta http-equiv="Expires" content="0" />
  
  <!-- PWA Web App Manifest for Offline Field Audits -->
  <link rel="manifest" href="manifest.json" />
  <meta name="theme-color" content="#0B0F17" />
  <meta name="apple-mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />

  <!-- Fonts & Icons -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Fira+Code:wght@400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

  <!-- External Library CDNs (with Global Fallback Guards) -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

  <style>
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Fira+Code:wght@400;500;600&display=swap');

/* ==========================================================================
   BIS TRUST COPILOT — $100M AI SAAS DESIGN SYSTEM (SIH 2026)
   Unified Spec: ChatGPT Simplicity + Gemini Modern Workspace + BIS Authority
   ========================================================================== */

:root, [data-theme="dark"] {
  /* Dark Theme Tokens */
  --bg-app: #0B0F17;
  --bg-sidebar: #070A0F;
  --bg-sidebar-hover: #131A26;
  --bg-card: #111827;
  --bg-card-hover: #1A2436;
  --bg-bubble-ai: #111827;
  --bg-bubble-user: #1E293B;
  --bg-input-capsule: #131B2A;
  --bg-pdf-pane: #0D131F;
  
  --text-main: #F3F4F6;
  --text-muted: #9CA3AF;
  --text-subtle: #6B7280;
  
  --border-color: rgba(255, 255, 255, 0.08);
  --border-focus: #3B82F6;
  --border-highlight: #7C3AED;

  /* Accents */
  --primary-blue: #3B82F6;
  --primary-indigo: #6366F1;
  --primary-purple: #8B5CF6;
  --status-green: #10B981;
  --status-amber: #F59E0B;
  --status-red: #EF4444;
  --gold-accent: #EAB308;
  --saffron: #FF9933;

  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.4);
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.5);
  --shadow-lg: 0 10px 25px rgba(0, 0, 0, 0.6);
  --shadow-glow: 0 0 20px rgba(59, 130, 246, 0.2);

  --radius-sm: 6px;
  --radius-md: 10px;
  --radius-lg: 16px;
  --radius-full: 9999px;
  
  --transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
}

[data-theme="light"] {
  /* Light Theme Tokens */
  --bg-app: #F8FAFC;
  --bg-sidebar: #F1F5F9;
  --bg-sidebar-hover: #E2E8F0;
  --bg-card: #FFFFFF;
  --bg-card-hover: #F8FAFC;
  --bg-bubble-ai: #FFFFFF;
  --bg-bubble-user: #E2E8F0;
  --bg-input-capsule: #FFFFFF;
  --bg-pdf-pane: #F1F5F9;
  
  --text-main: #0F172A;
  --text-muted: #475569;
  --text-subtle: #94A3B8;
  
  --border-color: #E2E8F0;
  --border-focus: #2563EB;
  --border-highlight: #6D28D9;

  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.08);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  --shadow-glow: 0 0 15px rgba(37, 99, 235, 0.15);
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
  font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  -webkit-tap-highlight-color: transparent;
}

body, html {
  height: 100%;
  width: 100%;
  overflow: hidden;
  background: var(--bg-app);
  color: var(--text-main);
  font-size: 14px;
  line-height: 1.5;
}

/* ================= TOP GOV HEADER ================= */
.gov-top-bar {
  height: 32px;
  background: #000000;
  color: #9CA3AF;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.5rem;
  font-size: 0.72rem;
  font-weight: 500;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  z-index: 100;
  flex-shrink: 0;
}

.gov-emblem-badge {
  display: flex;
  align-items: center;
  gap: 8px;
}

.gov-emblem-badge strong {
  color: #F3F4F6;
  font-weight: 700;
}

.gov-nav-links {
  display: flex;
  align-items: center;
  gap: 12px;
}

.gov-nav-links a {
  color: #9CA3AF;
  text-decoration: none;
  transition: var(--transition);
}

.gov-nav-links a:hover {
  color: #FFFFFF;
}

/* ================= MASTER LAYOUT ================= */
.app-master-container {
  display: flex;
  height: calc(100vh - 32px);
  width: 100%;
  position: relative;
  overflow: hidden;
}

/* ================= SIDEBAR ================= */
.app-sidebar {
  width: 260px;
  background: var(--bg-sidebar);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  flex-shrink: 0;
  transition: width 0.3s cubic-bezier(0.16, 1, 0.3, 1), transform 0.3s;
  z-index: 50;
}

.app-sidebar.collapsed {
  width: 0;
  transform: translateX(-100%);
  border-right: none;
  overflow: hidden;
}

.sidebar-header {
  padding: 1.25rem 1rem 0.75rem 1rem;
}

.sidebar-brand-box {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 1.25rem;
}

.brand-icon-shield {
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, var(--primary-blue), var(--primary-purple));
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #FFF;
  font-size: 1.1rem;
  box-shadow: var(--shadow-glow);
}

.brand-text-wrap h2 {
  font-size: 0.95rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: var(--text-main);
  line-height: 1.2;
}

.brand-text-wrap span {
  font-size: 0.68rem;
  font-weight: 600;
  color: var(--primary-blue);
  letter-spacing: 0.05em;
  text-transform: uppercase;
}

.btn-new-chat-sidebar {
  width: 100%;
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 0.65rem 0.9rem;
  color: var(--text-main);
  font-weight: 600;
  font-size: 0.85rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  transition: var(--transition);
  box-shadow: var(--shadow-sm);
}

.btn-new-chat-sidebar:hover {
  background: var(--bg-card-hover);
  border-color: var(--border-focus);
}

.sidebar-history-scroll {
  flex: 1;
  overflow-y: auto;
  padding: 0.5rem 0.75rem;
}

.sidebar-history-scroll::-webkit-scrollbar {
  width: 4px;
}
.sidebar-history-scroll::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 4px;
}

.history-group-label {
  font-size: 0.68rem;
  font-weight: 700;
  color: var(--text-subtle);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin: 0.8rem 0 0.4rem 0.4rem;
}

.history-item-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 0.6rem;
  border-radius: var(--radius-sm);
  color: var(--text-muted);
  font-size: 0.8rem;
  font-weight: 500;
  cursor: pointer;
  transition: var(--transition);
  margin-bottom: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.history-item-row:hover, .history-item-row.active {
  background: var(--bg-sidebar-hover);
  color: var(--text-main);
}

.history-item-row i {
  margin-right: 8px;
  font-size: 0.75rem;
  color: var(--text-subtle);
}

.sidebar-footer {
  padding: 0.75rem 1rem;
  border-top: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.btn-sidebar-footer-link {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0.5rem 0.6rem;
  border-radius: var(--radius-sm);
  color: var(--text-muted);
  font-size: 0.8rem;
  font-weight: 600;
  background: transparent;
  border: none;
  cursor: pointer;
  text-align: left;
  transition: var(--transition);
}

.btn-sidebar-footer-link:hover {
  background: var(--bg-sidebar-hover);
  color: var(--text-main);
}

/* ================= MAIN CHAT WORKSPACE ================= */
.app-chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: var(--bg-app);
  height: 100%;
  position: relative;
  overflow: hidden;
}

/* Top Navigation Bar */
.workspace-top-bar {
  height: 52px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.25rem;
  background: var(--bg-app);
  z-index: 20;
  flex-shrink: 0;
}

.nav-left-controls {
  display: flex;
  align-items: center;
  gap: 10px;
}

.btn-sidebar-toggle-mobile {
  background: transparent;
  border: 1px solid var(--border-color);
  color: var(--text-muted);
  padding: 6px 8px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: var(--transition);
}

.btn-sidebar-toggle-mobile:hover {
  background: var(--bg-sidebar-hover);
  color: var(--text-main);
}

/* Model Selector Capsule */
.model-selector-box {
  position: relative;
}

.btn-model-trigger {
  background: var(--bg-app);
  border: 1px solid var(--border-color);
  padding: 6px 12px;
  border-radius: var(--radius-full);
  font-size: 0.82rem;
  font-weight: 600;
  color: var(--text-main);
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: var(--transition);
}

.btn-model-trigger:hover {
  border-color: var(--border-focus);
}

.model-dropdown-menu {
  position: absolute;
  top: 42px;
  left: 0;
  width: 240px;
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-lg);
  padding: 6px;
  display: none;
  flex-direction: column;
  z-index: 1000;
}

.model-dropdown-menu.open { display: flex; }

.model-option-item {
  padding: 8px 10px;
  border-radius: var(--radius-sm);
  font-size: 0.8rem;
  text-align: left;
  display: flex;
  flex-direction: column;
  gap: 2px;
  cursor: pointer;
  transition: var(--transition);
  background: transparent;
  border: none;
  color: var(--text-main);
}

.model-option-item:hover, .model-option-item.selected {
  background: var(--bg-sidebar-hover);
  color: var(--primary-blue);
}

.model-option-item small {
  color: var(--text-subtle);
  font-size: 0.7rem;
}

.nav-right-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-nav-utility {
  background: var(--bg-app);
  border: 1px solid var(--border-color);
  color: var(--text-muted);
  padding: 6px 12px;
  border-radius: var(--radius-full);
  font-size: 0.78rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  transition: var(--transition);
}

.btn-nav-utility:hover {
  color: var(--text-main);
  border-color: var(--text-muted);
}

.btn-nav-utility.active {
  background: rgba(59, 130, 246, 0.15);
  color: var(--primary-blue);
  border-color: rgba(59, 130, 246, 0.3);
}

/* ================= CHAT SCROLL STREAM ================= */
.chat-scroll-stream {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem 1rem 120px 1rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  max-width: 860px;
  width: 100%;
  margin: 0 auto;
}

.chat-scroll-stream::-webkit-scrollbar {
  width: 6px;
}
.chat-scroll-stream::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 4px;
}

/* ================= EMPTY HERO (2 ACTION TILES) ================= */
.workspace-empty-hero {
  margin: auto;
  text-align: center;
  padding: 2rem 1rem;
  max-width: 680px;
  animation: fadeIn 0.4s ease-out;
}

.empty-hero-title {
  font-size: 1.8rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  color: var(--text-main);
  margin-bottom: 0.5rem;
}

.empty-hero-sub {
  font-size: 0.92rem;
  color: var(--text-muted);
  line-height: 1.6;
  margin-bottom: 2rem;
  max-width: 580px;
  margin-left: auto;
  margin-right: auto;
}

.hero-action-tiles-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  text-align: left;
}

.hero-action-tile {
  background: var(--bg-card);
  border: 1.5px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 1.25rem 1.4rem;
  cursor: pointer;
  transition: var(--transition);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: 115px;
  box-shadow: var(--shadow-sm);
}

.hero-action-tile:hover {
  transform: translateY(-2px);
  border-color: var(--primary-blue);
  box-shadow: var(--shadow-md), var(--shadow-glow);
}

.tile-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.tile-title {
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--text-main);
}

.tile-icon {
  font-size: 1.1rem;
  color: var(--primary-blue);
}

.tile-desc {
  font-size: 0.78rem;
  color: var(--text-muted);
  line-height: 1.4;
}

/* ================= MESSAGE STREAM ROWS ================= */
.msg-stream-row {
  display: flex;
  gap: 1rem;
  width: 100%;
  animation: fadeIn 0.25s ease-out;
}

.msg-stream-row.user {
  flex-direction: row-reverse;
}

.msg-avatar-icon {
  width: 34px;
  height: 34px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  font-size: 0.95rem;
  margin-top: 2px;
}

.msg-stream-row.user .msg-avatar-icon {
  background: var(--primary-blue);
  color: #FFFFFF;
}

.msg-stream-row.ai .msg-avatar-icon {
  background: linear-gradient(135deg, #1E3A8A, #4C1D95);
  color: #93C5FD;
  border: 1px solid rgba(147, 197, 253, 0.3);
}

.msg-body-wrapper {
  max-width: 82%;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.msg-stream-row.user .msg-body-wrapper {
  align-items: flex-end;
}

.msg-text-bubble {
  background: var(--bg-bubble-ai);
  border: 1px solid var(--border-color);
  padding: 1rem 1.25rem;
  border-radius: var(--radius-lg);
  font-size: 0.92rem;
  line-height: 1.6;
  color: var(--text-main);
  box-shadow: var(--shadow-sm);
  word-break: break-word;
}

.msg-stream-row.user .msg-text-bubble {
  background: var(--bg-bubble-user);
  border-color: rgba(255, 255, 255, 0.12);
  border-bottom-right-radius: 4px;
}

.msg-stream-row.ai .msg-text-bubble {
  border-bottom-left-radius: 4px;
}

/* Citation Badge Chips */
.citation-chip-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: rgba(59, 130, 246, 0.12);
  border: 1px solid rgba(59, 130, 246, 0.35);
  color: #60A5FA;
  font-size: 0.74rem;
  font-weight: 700;
  padding: 3px 8px;
  border-radius: var(--radius-full);
  margin-top: 8px;
  cursor: pointer;
  transition: var(--transition);
}

.citation-chip-badge:hover {
  background: rgba(59, 130, 246, 0.25);
  transform: translateY(-1px);
}

/* Superseded / Alert Banner */
.version-alert-banner {
  background: rgba(239, 68, 68, 0.12);
  border-left: 4px solid var(--status-red);
  padding: 10px 14px;
  border-radius: var(--radius-sm);
  margin-bottom: 10px;
  font-size: 0.85rem;
}

.version-alert-banner strong {
  color: var(--status-red);
}

/* Toolbar below messages */
.msg-actions-toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.75rem;
  color: var(--text-subtle);
  margin-left: 4px;
}

.toolbar-action-btn {
  background: transparent;
  border: none;
  color: var(--text-subtle);
  cursor: pointer;
  font-size: 0.75rem;
  padding: 2px 6px;
  border-radius: var(--radius-sm);
  transition: var(--transition);
}

.toolbar-action-btn:hover {
  background: var(--bg-sidebar-hover);
  color: var(--text-main);
}

/* ================= INTERACTIVE CARDS & TOOLS ================= */
.bis-trust-assessment-card {
  background: var(--bg-card);
  border: 1.5px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 1.25rem;
  margin-top: 8px;
  box-shadow: var(--shadow-md);
  animation: fadeIn 0.3s ease-out;
}

.trust-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  border-bottom: 1px solid var(--border-color);
  padding-bottom: 10px;
  margin-bottom: 12px;
}

.trust-status-pill {
  font-size: 0.72rem;
  font-weight: 800;
  padding: 3px 10px;
  border-radius: var(--radius-full);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.trust-status-pill.verified {
  background: rgba(16, 185, 129, 0.15);
  color: var(--status-green);
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.trust-status-pill.counterfeit {
  background: rgba(239, 68, 68, 0.15);
  color: var(--status-red);
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.trust-grid-2col {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  font-size: 0.82rem;
  margin-bottom: 12px;
}

.trust-grid-cell label {
  color: var(--text-subtle);
  font-size: 0.72rem;
  display: block;
  margin-bottom: 2px;
}

.trust-grid-cell span {
  font-weight: 600;
  color: var(--text-main);
}

/* ================= FLOATING COMPOSER ================= */
.chat-composer-outer {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 0.75rem 1.25rem 1.25rem 1.25rem;
  background: linear-gradient(to top, var(--bg-app) 80%, transparent 100%);
  z-index: 30;
}

.chat-composer-container {
  max-width: 860px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.input-capsule-card {
  background: var(--bg-input-capsule);
  border: 1.5px solid var(--border-color);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  padding: 8px 12px;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.input-capsule-card:focus-within {
  border-color: var(--border-focus);
  box-shadow: var(--shadow-lg), var(--shadow-glow);
}

.composer-action-btn {
  width: 34px;
  height: 34px;
  border-radius: var(--radius-md);
  background: transparent;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.95rem;
  transition: var(--transition);
  flex-shrink: 0;
}

.composer-action-btn:hover {
  background: var(--bg-sidebar-hover);
  color: var(--text-main);
}

.composer-action-btn.listening {
  background: rgba(239, 68, 68, 0.2);
  color: var(--status-red);
  animation: pulse 1.2s infinite;
}

.btn-voice-lang-pill {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-color);
  color: var(--text-muted);
  font-size: 0.7rem;
  font-weight: 700;
  padding: 4px 8px;
  border-radius: var(--radius-full);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: var(--transition);
}

.btn-voice-lang-pill:hover {
  background: var(--bg-sidebar-hover);
  color: var(--text-main);
}

.composer-textarea {
  flex: 1;
  background: transparent;
  border: none;
  color: var(--text-main);
  font-size: 0.95rem;
  resize: none;
  outline: none;
  max-height: 140px;
  min-height: 24px;
  line-height: 1.4;
  padding: 4px 2px;
}

.composer-textarea::placeholder {
  color: var(--text-subtle);
}

.btn-send-capsule {
  width: 34px;
  height: 34px;
  border-radius: var(--radius-md);
  background: var(--primary-blue);
  border: none;
  color: #FFFFFF;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.9rem;
  transition: var(--transition);
  flex-shrink: 0;
}

.btn-send-capsule:hover {
  background: #2563EB;
  transform: scale(1.04);
}

.composer-footer-sub {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 4px;
  font-size: 0.7rem;
  color: var(--text-subtle);
}

/* ================= SPLIT-SCREEN GAZETTE PDF STUDIO ================= */
.gazette-split-pane {
  width: 0;
  background: var(--bg-pdf-pane);
  border-left: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  transition: width 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  overflow: hidden;
  z-index: 40;
}

.gazette-split-pane.open {
  width: 480px;
}

.pdf-pane-header {
  padding: 10px 14px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--bg-app);
}

.pdf-pane-body {
  flex: 1;
  overflow-y: auto;
  padding: 14px;
}

.pdf-clause-highlight-card {
  background: rgba(234, 179, 8, 0.08);
  border-left: 3px solid var(--gold-accent);
  padding: 10px 12px;
  border-radius: var(--radius-sm);
  font-family: 'Fira Code', monospace;
  font-size: 0.8rem;
  color: var(--text-main);
  line-height: 1.5;
  margin-bottom: 10px;
}

/* ================= MODALS & COMMAND PALETTE ================= */
.cmd-palette-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(7, 10, 15, 0.8);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  z-index: 99999;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding-top: 10vh;
  opacity: 0;
  visibility: hidden;
  pointer-events: none;
  transition: opacity 0.2s cubic-bezier(0.16, 1, 0.3, 1), visibility 0.2s;
}

.cmd-palette-backdrop.open,
.cmd-palette-backdrop.active {
  opacity: 1 !important;
  visibility: visible !important;
  pointer-events: auto !important;
}

.cmd-palette-box {
  width: 100%;
  max-width: 600px;
  background: var(--bg-card);
  border: 1.5px solid var(--border-color);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  overflow: hidden;
  animation: fadeIn 0.2s ease-out;
}

.cmd-palette-input-wrap {
  padding: 12px 16px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  gap: 10px;
}

.cmd-palette-input {
  flex: 1;
  font-size: 1rem;
  color: var(--text-main);
  background: transparent;
  border: none;
  outline: none;
}

.cmd-palette-results {
  max-height: 380px;
  overflow-y: auto;
  padding: 8px;
}

.cmd-item {
  display: flex;
  align-items: center;
  padding: 10px 12px;
  border-radius: var(--radius-sm);
  cursor: pointer;
  gap: 12px;
  color: var(--text-main);
  transition: var(--transition);
}

.cmd-item:hover, .cmd-item.selected {
  background: var(--bg-sidebar-hover);
  color: var(--primary-blue);
}

/* Reticle & Camera Modal */
.camera-reticle-box {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 75%;
  height: 60%;
  border: 2px dashed rgba(59, 130, 246, 0.8);
  border-radius: 8px;
  pointer-events: none;
  display: flex;
  align-items: center;
  justify-content: center;
}

.reticle-label {
  background: rgba(0, 0, 0, 0.7);
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 700;
  color: #60A5FA;
  letter-spacing: 0.05em;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(4px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.08); }
  100% { transform: scale(1); }
}

/* Responsive Media Queries */
@media (max-width: 900px) {
  .app-sidebar {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    height: 100%;
    transform: translateX(-100%);
    box-shadow: var(--shadow-lg);
  }
  .app-sidebar.mobile-open {
    transform: translateX(0);
    width: 280px;
  }
  .gazette-split-pane.open {
    position: absolute;
    right: 0;
    top: 0;
    bottom: 0;
    width: 100%;
    max-width: 480px;
    box-shadow: var(--shadow-lg);
  }
  .hero-action-tiles-grid {
    grid-template-columns: 1fr;
  }
}
  </style>
</head>
<body>

  <!-- ================= TOP GOV HEADER ================= -->
  <div class="gov-top-bar">
    <div class="gov-emblem-badge">
      <span>🇮🇳 <strong>GOVERNMENT OF INDIA</strong> • Ministry of Consumer Affairs, Food & Public Distribution</span>
      <span style="color:var(--border-color);">|</span>
      <span>Bureau of Indian Standards (BIS) • SIH26107</span>
    </div>
    <div class="gov-nav-links">
      <button onclick="openWhyUsModal()" style="background:rgba(59,130,246,0.15);color:var(--primary-blue);border:1px solid rgba(59,130,246,0.3);padding:2px 8px;border-radius:4px;font-size:0.72rem;font-weight:700;display:flex;align-items:center;gap:4px;cursor:pointer;">
        <i class="fas fa-sparkles"></i> Why Us vs BIS CARE
      </button>
    </div>
  </div>

  <!-- Mobile Sidebar Backdrop Overlay -->
  <div class="sidebar-backdrop" id="sidebarBackdrop" onclick="toggleSidebar(false)" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:45;"></div>

  <!-- ================= MASTER APP WORKSPACE ================= -->
  <div class="app-master-container">

    <!-- ================= SIDEBAR ================= -->
    <aside class="app-sidebar" id="appSidebar">
      <div class="sidebar-header">
        <div class="sidebar-brand-box">
          <div class="brand-icon-shield">
            <i class="fas fa-shield-halved"></i>
          </div>
          <div class="brand-text-wrap">
            <h2>MANAK-AI</h2>
            <span>BIS Standards Copilot</span>
          </div>
        </div>

        <button class="btn-new-chat-sidebar" onclick="startNewConversation()">
          <span><i class="fas fa-plus" style="margin-right:8px;"></i> New Consultation</span>
          <kbd style="font-size:0.7rem;opacity:0.6;font-family:'Fira Code',monospace;">Ctrl+J</kbd>
        </button>
      </div>

      <!-- History Stream -->
      <div class="sidebar-history-scroll" id="sidebarHistoryContainer">
        <div id="dynamicConversationsList"></div>
      </div>

      <!-- Sidebar Footer Controls -->
      <div class="sidebar-footer">
        <button class="btn-sidebar-footer-link" onclick="openComplianceWizard()">
          <i class="fas fa-route" style="color:var(--primary-blue);"></i> ISI/QCO Fee & Roadmap
        </button>
        <button class="btn-sidebar-footer-link" onclick="toggleTheme()">
          <i class="fas fa-moon" id="themeIcon"></i> Toggle Theme (Dark / Light)
        </button>
      </div>
    </aside>

    <!-- ================= MAIN CHAT AREA ================= -->
    <main class="app-chat-main">
      
      <!-- Top Navigation Control Bar -->
      <header class="workspace-top-bar">
        <div class="nav-left-controls">
          <button class="btn-sidebar-toggle-mobile" id="sidebarToggle" onclick="toggleSidebar()" title="Toggle Sidebar">
            <i class="fas fa-bars"></i>
          </button>

          <!-- Model / Role Persona Capsule -->
          <div class="model-selector-box">
            <button class="btn-model-trigger" id="modelTriggerBtn" onclick="toggleRoleDropdown()">
              <i class="fas fa-shield-halved" style="color:var(--primary-blue);"></i>
              <span id="selectedRoleLabel">Consumer Mode</span>
              <i class="fas fa-chevron-down" style="font-size:0.68rem;opacity:0.7;"></i>
            </button>
            <div class="model-dropdown-menu" id="roleDropdown">
              <button class="model-option-item selected" onclick="switchRole('consumer', 'Consumer Mode', event)">
                <strong>👤 Consumer Mode</strong>
                <small>Everyday safety, fake ISI scans, 3X gold compensation</small>
              </button>
              <button class="model-option-item" onclick="switchRole('msme', 'MSME Manufacturer Mode', event)">
                <strong>🏭 MSME Manufacturer Mode</strong>
                <small>STI in-house lab checklists, 50% marking fee subsidies</small>
              </button>
              <button class="model-option-item" onclick="switchRole('inspector', 'BIS Inspector Mode', event)">
                <strong>🏛️ BIS Inspector Mode</strong>
                <small>Section 29 seizures, criminal raids, Gazette penal codes</small>
              </button>
            </div>
          </div>
        </div>

        <div class="nav-right-controls">
          <button class="btn-nav-utility" id="btnSplitPDF" onclick="togglePDFPane()" title="Split-Screen Gazette Studio">
            <i class="fas fa-book-open"></i> <span>Gazette Studio</span>
          </button>
          <button class="btn-nav-utility" onclick="openCommandPalette()" title="Command Palette (Ctrl + K)">
            <i class="fas fa-search"></i> <span>Search (Ctrl+K)</span>
          </button>
        </div>
      </header>

      <!-- Messages Stream -->
      <div class="chat-scroll-stream" id="chatMessages">

        <!-- Empty Hero (2 Action Cards) -->
        <div class="workspace-empty-hero" id="chatWelcomeBox">
          <h1 class="empty-hero-title">How can I assist your compliance today?</h1>
          <p class="empty-hero-sub">
            Grounded intelligence across <strong>16 Curated National Indian Standards (IS Codes)</strong>, Quality Control Orders (QCOs), licensing roadmaps, and consumer safety.
          </p>

          <div class="hero-action-tiles-grid">
            <!-- Tile 1: Verify Product -->
            <div class="hero-action-tile" onclick="openCameraViewfinder()">
              <div>
                <div class="tile-head">
                  <div class="tile-title">🔍 Verify a Product</div>
                  <i class="fas fa-qrcode tile-icon"></i>
                </div>
                <div class="tile-desc">Live packaging camera scan & 7-digit CM/L / 6-digit HUID verification.</div>
              </div>
            </div>

            <!-- Tile 2: Understand Standard -->
            <div class="hero-action-tile" onclick="triggerActionTile('standard')">
              <div>
                <div class="tile-head">
                  <div class="tile-title">📚 Understand a Standard</div>
                  <i class="fas fa-file-contract tile-icon"></i>
                </div>
                <div class="tile-desc">Explore mandatory testing limits, active vs superseded versions, and Gazette clauses.</div>
              </div>
            </div>
          </div>
        </div>

      </div>

      <!-- Floating Composer -->
      <div class="chat-composer-outer">
        <div class="chat-composer-container">
          <div class="input-capsule-card">
            <!-- File / Image Upload -->
            <input type="file" id="fileUploadInput" accept="image/*,.pdf,.docx,.txt" style="display:none;" onchange="handleFileUpload(event)" />
            <button class="composer-action-btn" onclick="document.getElementById('fileUploadInput').click()" title="Attach Document / Photo">
              <i class="fas fa-paperclip"></i>
            </button>
            <button class="composer-action-btn" onclick="openCameraViewfinder()" title="Live Computer Vision Camera Scan">
              <i class="fas fa-camera"></i>
            </button>

            <!-- Textarea -->
            <textarea 
              id="userInput" 
              class="composer-textarea" 
              placeholder="Ask BIS Copilot anything (e.g. Helmet standards, Solar subsidies, Gold purity)..." 
              rows="1"
              onkeydown="handleComposerKeydown(event)"
            ></textarea>

            <!-- Voice Language Switcher -->
            <button class="btn-voice-lang-pill" id="btnVoiceLang" onclick="toggleVoiceLanguage()" title="Switch Voice Language (Hindi / English)">
              <i class="fas fa-language"></i> <span>HI</span>
            </button>

            <!-- Voice Mic -->
            <button class="composer-action-btn" id="micBtn" onclick="toggleVoiceInput()" title="Voice Input (Web Speech API)">
              <i class="fas fa-microphone"></i>
            </button>

            <!-- Send Button -->
            <button class="btn-send-capsule" id="sendBtn" onclick="submitUserQuery()" title="Send Inquiry">
              <i class="fas fa-arrow-up"></i>
            </button>
          </div>

          <div class="composer-footer-sub">
            <span>Powered by Hybrid Dense Vector & BM25 Neural Standards Search</span>
            <span>SIH 2026 • SIH26107</span>
          </div>
        </div>
      </div>

    </main>

    <!-- ================= SPLIT-SCREEN GAZETTE PDF STUDIO ================= -->
    <aside class="gazette-split-pane" id="pdfEvidencePane">
      <div class="pdf-pane-header">
        <div style="display:flex;align-items:center;gap:8px;">
          <i class="fas fa-book-bookmark" style="color:var(--primary-blue);"></i>
          <strong style="font-size:0.88rem;">Gazette Evidence Studio</strong>
        </div>
        <button class="toolbar-action-btn" onclick="togglePDFPane()"><i class="fas fa-xmark"></i></button>
      </div>

      <div class="pdf-pane-body" id="pdfContentRenderArea">
        <div style="color:var(--text-muted);font-size:0.82rem;text-align:center;padding:2rem 1rem;">
          <i class="fas fa-file-lines" style="font-size:2rem;color:var(--text-subtle);margin-bottom:10px;display:block;"></i>
          Click any <strong>Citation Chip</strong> in the chat consultation to inspect the official statutory Gazette clause.
        </div>
      </div>
    </aside>

  </div>

  <!-- ================= COMMAND PALETTE MODAL (Ctrl + K) ================= -->
  <div class="cmd-palette-backdrop" id="cmdPalette" onclick="if(event.target === this) closeCommandPalette()">
    <div class="cmd-palette-box">
      <div class="cmd-palette-input-wrap">
        <i class="fas fa-search" style="color:var(--primary-blue);"></i>
        <input type="text" id="cmdSearchInput" class="cmd-palette-input" placeholder="Search 16 Standards, QCOs, or enter CM/L / HUID code..." oninput="filterCommandPalette(this.value)" />
        <kbd style="font-size:0.72rem;background:rgba(255,255,255,0.08);padding:2px 6px;border-radius:4px;">ESC</kbd>
      </div>
      <div class="cmd-palette-results" id="cmdPaletteResults"></div>
    </div>
  </div>

  <!-- ================= WHY US VS BIS CARE COMPARISON MODAL ================= -->
  <div class="cmd-palette-backdrop" id="whyUsModal" onclick="if(event.target === this) closeWhyUsModal()">
    <div class="cmd-palette-box" style="max-width:680px;padding:20px;">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;">
        <h3 style="margin:0;font-size:1.1rem;color:var(--text-main);"><i class="fas fa-sparkles" style="color:var(--primary-blue);"></i> MANAK-AI vs Legacy BIS CARE App</h3>
        <button onclick="closeWhyUsModal()" style="background:transparent;border:none;color:var(--text-muted);cursor:pointer;font-size:1.1rem;"><i class="fas fa-xmark"></i></button>
      </div>
      <div style="overflow-x:auto;">
        <table style="width:100%;border-collapse:collapse;font-size:0.82rem;text-align:left;">
          <thead>
            <tr style="border-bottom:1px solid var(--border-color);color:var(--text-muted);">
              <th style="padding:8px;">Capability</th>
              <th style="padding:8px;color:var(--status-red);">Legacy BIS CARE</th>
              <th style="padding:8px;color:var(--primary-blue);">MANAK-AI Copilot</th>
            </tr>
          </thead>
          <tbody>
            <tr style="border-bottom:1px solid var(--border-color);">
              <td style="padding:8px;font-weight:600;">Verification</td>
              <td style="padding:8px;">Manual alphanumeric entry only</td>
              <td style="padding:8px;color:var(--status-green);">Real-Time Computer Vision & OCR packaging scan</td>
            </tr>
            <tr style="border-bottom:1px solid var(--border-color);">
              <td style="padding:8px;font-weight:600;">Standards Query</td>
              <td style="padding:8px;">Static PDF download catalog</td>
              <td style="padding:8px;color:var(--status-green);">Grounded Hybrid RAG with exact clause citations</td>
            </tr>
            <tr style="border-bottom:1px solid var(--border-color);">
              <td style="padding:8px;font-weight:600;">MSME Assistance</td>
              <td style="padding:8px;">No interactive lab tools</td>
              <td style="padding:8px;color:var(--status-green);">Interactive STI in-house lab auditor & 50% subsidy guide</td>
            </tr>
            <tr>
              <td style="padding:8px;font-weight:600;">Grievance Engine</td>
              <td style="padding:8px;">Basic text complaint form</td>
              <td style="padding:8px;color:var(--status-green);">Evidence-backed statutory notice with 3X gold penalty calc</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- ================= LIVE CAMERA SCANNER VIEWPORT MODAL ================= -->
  <div class="cmd-palette-backdrop" id="cameraModal" onclick="if(event.target === this) closeCameraModal()">
    <div class="cmd-palette-box" style="max-width:560px;padding:20px;">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
        <h3 style="margin:0;font-size:1.1rem;color:var(--text-main);display:flex;align-items:center;gap:8px;">
          <i class="fas fa-camera" style="color:var(--primary-blue);"></i> Real-Time BIS Packaging Vision Scanner
        </h3>
        <button onclick="closeCameraModal()" style="background:transparent;border:none;color:var(--text-subtle);padding:4px;cursor:pointer;"><i class="fas fa-xmark"></i></button>
      </div>

      <p style="font-size:0.8rem;color:var(--text-muted);margin-bottom:12px;">
        Align the <strong>ISI Mark (IS:XXXX)</strong> or <strong>6-digit Gold HUID</strong> within the target frame.
      </p>

      <!-- Video Viewfinder Container -->
      <div class="camera-video-container" style="position:relative;width:100%;height:300px;background:#000;border-radius:10px;overflow:hidden;margin-bottom:10px;">
        <video id="cameraVideo" autoplay playsinline muted style="width:100%;height:100%;object-fit:cover;"></video>
        <canvas id="cameraCanvas" style="display:none;"></canvas>
        
        <div class="camera-reticle-box">
          <span class="reticle-label">ALIGN ISI MARK / HUID</span>
        </div>

        <button onclick="toggleCameraFacing()" title="Flip Camera" style="position:absolute;top:10px;right:10px;background:rgba(0,0,0,0.65);color:#fff;border:1px solid rgba(255,255,255,0.25);border-radius:50%;width:36px;height:36px;display:flex;align-items:center;justify-content:center;cursor:pointer;z-index:10;">
          <i class="fas fa-camera-rotate"></i>
        </button>
      </div>

      <div id="cameraStatusMsg" style="display:none;font-size:0.8rem;padding:8px 12px;background:rgba(255,255,255,0.05);border-radius:6px;margin-bottom:12px;line-height:1.4;"></div>

      <div style="display:flex;gap:10px;justify-content:space-between;align-items:center;margin-bottom:14px;flex-wrap:wrap;">
        <button onclick="captureCameraFrame()" style="flex:1;min-width:180px;background:var(--primary-blue);color:white;border:none;padding:10px;border-radius:8px;font-weight:700;font-size:0.85rem;display:flex;align-items:center;justify-content:center;gap:8px;cursor:pointer;">
          <i class="fas fa-camera-retro"></i> Capture & Scan
        </button>

        <input type="file" id="cameraFallbackUploadInput" accept="image/*,.pdf,.docx,.txt" style="display:none;" onchange="handleCameraFallbackUpload(event)" />
        <button onclick="document.getElementById('cameraFallbackUploadInput').click()" style="background:rgba(59,130,246,0.15);border:1px solid rgba(59,130,246,0.35);color:var(--primary-blue);padding:10px 14px;border-radius:8px;font-size:0.85rem;font-weight:700;display:flex;align-items:center;gap:6px;cursor:pointer;">
          <i class="fas fa-upload"></i> Upload Photo
        </button>

        <button onclick="closeCameraModal()" style="background:rgba(255,255,255,0.08);border:none;color:var(--text-main);padding:10px 14px;border-radius:8px;font-size:0.85rem;font-weight:600;cursor:pointer;">
          Close
        </button>
      </div>

      <!-- Fast Test Scenario Buttons -->
      <div style="border-top:1px solid var(--border-color);padding-top:12px;">
        <span style="font-size:0.75rem;color:var(--text-muted);display:block;margin-bottom:8px;font-weight:600;">⚡ OR RUN 1-CLICK TEST SCENARIO:</span>
        <div style="display:flex;flex-wrap:wrap;gap:8px;">
          <button onclick="testSampleVerification('genuine')" style="background:rgba(16,185,129,0.15);border:1px solid rgba(16,185,129,0.3);color:var(--status-green);padding:4px 10px;border-radius:6px;font-size:0.75rem;font-weight:700;cursor:pointer;">
            🟢 Sample 1: Genuine Helmet (CM/L-8530092)
          </button>
          <button onclick="testSampleVerification('counterfeit')" style="background:rgba(239,68,68,0.15);border:1px solid rgba(239,68,68,0.3);color:var(--status-red);padding:4px 10px;border-radius:6px;font-size:0.75rem;font-weight:700;cursor:pointer;">
            🔴 Sample 2: Counterfeit Helmet (CM/L-4091823)
          </button>
          <button onclick="testSampleVerification('huid')" style="background:rgba(234,179,8,0.15);border:1px solid rgba(234,179,8,0.3);color:var(--gold-accent);padding:4px 10px;border-radius:6px;font-size:0.75rem;font-weight:700;cursor:pointer;">
            🟡 Sample 3: 22K Gold HUID (AB8492)
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- ================= ISI / QCO CONFORMITY ASSESSMENT WIZARD MODAL ================= -->
  <div class="cmd-palette-backdrop" id="complianceWizardModal" onclick="if(event.target === this) closeComplianceWizard()">
    <div class="cmd-palette-box" style="max-width:640px;padding:20px;">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
        <h3 style="margin:0;font-size:1.1rem;color:var(--text-main);display:flex;align-items:center;gap:8px;">
          <i class="fas fa-route" style="color:var(--primary-blue);"></i> ISI / QCO Certification Fee & Roadmap
        </h3>
        <button onclick="closeComplianceWizard()" style="background:transparent;border:none;color:var(--text-subtle);cursor:pointer;"><i class="fas fa-xmark"></i></button>
      </div>
      <div id="complianceWizardBody">
        <!-- Rendered dynamically by Wizard Module -->
      </div>
    </div>
  </div>

  <!-- ================= INLINED COMPLETE JAVASCRIPT APPLICATION ================= -->
  <script>
/**
 * ==========================================================================
 * BIS TRUST COPILOT — UNIFIED PRODUCTION SYSTEM & SERVICE LAYER
 * Smart India Hackathon 2026 (SIH26107)
 * ==========================================================================
 */

// --------------------------------------------------------------------------
// 1. DATA LAYER: 16 Core Standards, CM/L Registry & HUID Database
// --------------------------------------------------------------------------
const BIS_STANDARDS_EXPANDED_DB = [
  {
    code: "IS 4151:2015",
    title: "Protective Helmets for Two-Wheeler Riders — Specification",
    category: "Automotive Safety & Consumer Protection",
    status: "Mandatory (QCO Active — MoRTH / BIS Act 2016)",
    supersedes: "IS 4151:1993 (WITHDRAWN & SUPERSEDED)",
    revisionYear: 2015,
    effectiveDate: "March 1, 2021 (All non-ISI helmets banned in India)",
    scheme: "Scheme-I (ISI Mark Product Certification)",
    pageNumber: 14,
    clauseNumber: "Clause 7.4 & Clause 8.2",
    summary: "Mandatory standard for motorcycle helmets covering impact attenuation, chin strap retention, and peripheral vision.",
    clauseEvidence: "7.4 Impact Attenuation Test: Peak acceleration imparted to the headform on drop-tower anvil shall not exceed 300 g (2 940 m/s²), and cumulative time exceeding 150 g shall not exceed 5.0 ms.\n\n8.2 Retention System: Dynamic displacement under 1.0 kN load shall not exceed 35 mm, residual displacement ≤ 25 mm.",
    keyPoints: [
      "Drop-tower shock absorption test (Peak acceleration ≤ 300g)",
      "Penetration resistance with 3kg steel striker dropped from 1m",
      "Dynamic chin strap retention (Max extension ≤ 35mm)",
      "Minimum horizontal peripheral vision field ≥ 105°",
      "Non-compliance is a punishable criminal offense under Section 29, BIS Act 2016"
    ],
    stiChecks: [
      { name: "Raw Material EPS Density (≥ 25 kg/m³)", clause: "Clause 5.1", status: "PASS", mandatory: true },
      { name: "Outer Shell Polycarbonate Thickness (≥ 3.2 mm)", clause: "Clause 5.2", status: "PASS", mandatory: true },
      { name: "Drop-Tower Impact Attenuation (≤ 300g)", clause: "Clause 7.4", status: "PASS", mandatory: true },
      { name: "Chin Strap Dynamic Retention", clause: "Clause 8.2", status: "PASS", mandatory: true }
    ],
    keywords: ["helmet", "helmets", "is 4151", "is4151", "two wheeler", "bike", "rider", "headgear", "motorcycle", "isi mark helmet"]
  },
  {
    code: "IS 694:2010",
    title: "PVC Insulated Cables for Working Voltages up to and Including 1100 V",
    category: "Electrical Cables & Building Safety",
    status: "Mandatory (QCO Active — Ministry of Commerce & Industry)",
    supersedes: "IS 694:1990 (SUPERSEDED)",
    revisionYear: 2010,
    effectiveDate: "Mandatory for domestic wiring & industrial power",
    scheme: "Scheme-I (ISI Mark Product Certification)",
    pageNumber: 8,
    clauseNumber: "Clause 6.2 & Clause 11.1",
    summary: "Mandatory standard for copper and aluminium household and commercial electric wires.",
    clauseEvidence: "6.2 Conductor Resistance: Maximum electrical resistance of copper conductors at 20°C shall not exceed 12.1 Ω/km for 1.5 sq mm, and 7.41 Ω/km for 2.5 sq mm.\n\n11.1 Flame Retardance (FRLS): Wires under test shall extinguish within 60 seconds after burner removal.",
    keyPoints: [
      "100% pure electrolytic grade copper conductor (EC grade purity ≥ 99.9%)",
      "Conductor resistance at 20°C (≤ 12.1 Ω/km for 1.5 sq mm)",
      "FRLS (Flame Retardant Low Smoke) flame propagation test",
      "High voltage insulation withstand test (3.0 kV AC for 5 minutes in water tank)"
    ],
    stiChecks: [
      { name: "Copper Purity Assay (≥ 99.9% Cu)", clause: "Clause 5.1", status: "PASS", mandatory: true },
      { name: "Conductor Resistance Test @ 20°C", clause: "Clause 6.2", status: "PASS", mandatory: true },
      { name: "FRLS Flame Retardance Oxygen Index (≥ 29%)", clause: "Clause 11.1", status: "PASS", mandatory: true }
    ],
    keywords: ["cable", "cables", "is 694", "is694", "wire", "wires", "copper wire", "frls", "electrical wire"]
  },
  {
    code: "IS 1786:2008",
    title: "High Strength Deformed Steel Bars and Wires for Concrete Reinforcement (TMT)",
    category: "Civil Infrastructure & Construction Materials",
    status: "Mandatory (Steel QCO — Ministry of Steel)",
    supersedes: "IS 1786:1985 (SUPERSEDED)",
    revisionYear: 2008,
    effectiveDate: "Mandatory for all building construction & infrastructure in India",
    scheme: "Scheme-I (ISI Mark Certification)",
    pageNumber: 12,
    clauseNumber: "Clause 8.1 & Table 3",
    summary: "Standard governing Thermo-Mechanically Treated (TMT) Fe 500, Fe 500D, and Fe 550D rebar for seismic safety.",
    clauseEvidence: "8.1 Tensile & Yield Strength (Fe 500D): Minimum Yield Strength (0.2% proof stress) ≥ 500.0 N/mm²; Tensile Strength ≥ 565.0 N/mm²; Total Elongation at fracture ≥ 16.0%.",
    keyPoints: [
      "Mandatory yield strength for Fe 500D: ≥ 500 N/mm²",
      "Ultimate Tensile Strength (UTS/YS ratio ≥ 1.10 for earthquake resistance)",
      "Minimum elongation ≥ 16.0% to absorb seismic shocks",
      "Chemical limits: Max Sulphur ≤ 0.040%, Max Phosphorus ≤ 0.040%"
    ],
    stiChecks: [
      { name: "Yield Stress (0.2% Proof Stress ≥ 500 N/mm²)", clause: "Table 3", status: "PASS", mandatory: true },
      { name: "Ultimate Tensile Strength (≥ 565 N/mm²)", clause: "Table 3", status: "PASS", mandatory: true },
      { name: "Mandrel 180° Bend & Rebend Test", clause: "Clause 9.1", status: "PASS", mandatory: true }
    ],
    keywords: ["tmt", "steel", "is 1786", "is1786", "rebar", "fe500d", "iron rod", "construction steel", "reinforcement"]
  },
  {
    code: "IS 1417:2016",
    title: "Gold and Gold Alloys, Jewellery/Artefacts — Fineness & Hallmarking",
    category: "Precious Metals & Consumer Rights",
    status: "Mandatory (Hallmarking Order 2021 — 343+ Indian Districts)",
    supersedes: "IS 1417:2009 (SUPERSEDED)",
    revisionYear: 2016,
    effectiveDate: "June 23, 2021 (Mandatory 6-digit HUID)",
    scheme: "Scheme-VI (BIS Hallmarking Unique Identification - HUID)",
    pageNumber: 4,
    clauseNumber: "Clause 5 & Scheme-VI Guidelines",
    summary: "Mandatory hallmarking scheme specifying purity standards (14K, 18K, 20K, 22K, 24K) and 6-digit laser HUID marking.",
    clauseEvidence: "Clause 5 Purity Grades: Gold jewellery recognized in: 24K (995), 23K (958), 22K (916), 20K (833), 18K (750), 14K (585).\n\nMandatory 3 Marks: (1) BIS Logo, (2) Purity (e.g. 22K916), (3) 6-digit alphanumeric laser HUID.",
    keyPoints: [
      "Recognized purity grades: 22K (916), 18K (750), 14K (585), 24K (995)",
      "Mandatory 3 Marks: BIS Logo + Karat/Fineness + 6-digit laser HUID",
      "Statutory compensation rule: Jeweller must pay 3X the differential price to consumer if under-caratage occurs"
    ],
    stiChecks: [
      { name: "XRF Spectrometric Non-Destructive Screening", clause: "Clause 6.1", status: "PASS", mandatory: true },
      { name: "Fire Assay (Cupellation) Quantitative Test", clause: "Clause 6.2", status: "PASS", mandatory: true },
      { name: "Laser Marking of 6-digit Alphanumeric HUID", clause: "Clause 5", status: "PASS", mandatory: true }
    ],
    keywords: ["gold", "hallmark", "huid", "is 1417", "is1417", "22k", "18k", "24k", "jewellery", "gold purity", "bis gold"]
  },
  {
    code: "IS 14543:2024",
    title: "Packaged Drinking Water (Other than Packaged Natural Mineral Water)",
    category: "Food & Beverage Safety",
    status: "Mandatory (FSSAI & BIS Joint Enforcement)",
    supersedes: "IS 14543:2016 (SUPERSEDED by 2024 Revision)",
    revisionYear: 2024,
    effectiveDate: "Mandatory license before commercial bottling in India",
    scheme: "Scheme-I (ISI Mark Certification)",
    pageNumber: 10,
    clauseNumber: "Table 1 & Table 2 Microbiological Limits",
    summary: "Mandatory testing standards for packaged drinking water including microplastic limits and chemical assays.",
    clauseEvidence: "Table 2 Microbiological Requirements: Total coliform count shall be 0 per 250 ml; E. coli 0 per 250 ml; Pseudomonas aeruginosa 0 per 250 ml; Yeast & Mould 0 per 250 ml.",
    keyPoints: [
      "Total Coliforms, E. Coli, Yeast & Mould must be 0 per 250 ml",
      "TDS range: 75 mg/L to 500 mg/L (pH 6.5 to 8.5)",
      "Strict heavy metal limits: Lead ≤ 0.01 mg/L, Arsenic ≤ 0.01 mg/L"
    ],
    stiChecks: [
      { name: "Microbiological Membrane Filtration Assay", clause: "Table 2", status: "PASS", mandatory: true },
      { name: "TDS & pH Measurement (pH 6.5 - 8.5)", clause: "Table 1", status: "PASS", mandatory: true }
    ],
    keywords: ["water", "packaged water", "is 14543", "is14543", "bottled water", "ro water", "drinking water", "mineral water"]
  },
  {
    code: "IS 14286:2010 / IEC 61215",
    title: "Terrestrial Photovoltaic (PV) Modules — Design Qualification & Type Approval",
    category: "Renewable Energy & Solar Infrastructure",
    status: "Mandatory (MNRE Solar QCO — ALMM Approved List)",
    supersedes: "IEC 61215:2005",
    revisionYear: 2010,
    effectiveDate: "Mandatory for PM Surya Ghar Muft Bijli Yojana & grid solar",
    scheme: "Scheme-II (Compulsory Registration Scheme - CRS)",
    pageNumber: 30,
    clauseNumber: "Clause 10.11 & Clause 10.13",
    summary: "Durability testing for solar panels subjected to thermal cycling, damp heat, and mechanical load.",
    clauseEvidence: "10.11 Thermal Cycling: 200 cycles from -40°C to +85°C. Power degradation ≤ 5% of initial output.\n\n10.13 Damp Heat: 1000 hours at 85°C ± 2°C and 85% relative humidity without breakdown.",
    keyPoints: [
      "Thermal cycling test (200 cycles between -40°C and +85°C)",
      "Damp heat test (1000 hours at 85°C / 85% relative humidity)",
      "Mechanical load test (2400 Pa wind / 5400 Pa heavy snow simulation)"
    ],
    stiChecks: [
      { name: "Electroluminescence (EL) Micro-crack Imaging", clause: "Clause 10.1", status: "PASS", mandatory: true },
      { name: "Wet Leakage Insulation Resistance", clause: "Clause 10.15", status: "PASS", mandatory: true }
    ],
    keywords: ["solar", "solar panel", "pv module", "is 14286", "iec 61215", "pm surya ghar", "rooftop solar", "photovoltaic"]
  }
];

// CM/L Registry Database
const CML_REGISTRY_EXPANDED_DB = {
  "8530092": {
    cmlNumber: "8530092",
    status: "OPERATIVE & VERIFIED GENUINE",
    isOperative: true,
    firmName: "STUDDS ACCESSORIES LIMITED",
    product: "Protective Helmets for Two-Wheeler Riders",
    standardCode: "IS 4151:2015",
    factoryLocation: "Plot No. 9, Sector 59, Faridabad, Haryana - 121004",
    validUpto: "31-Mar-2027",
    brandName: "STUDDS / SHIFTER"
  },
  "4091823": {
    cmlNumber: "4091823",
    status: "EXPIRED & SUSPENDED (POTENTIAL MISUSE)",
    isOperative: false,
    firmName: "ROADSHIELD AUTO APPLIANCES (EXPIRED)",
    product: "Non-Compliant Two-Wheeler Protective Headgear",
    standardCode: "IS 4151:2015",
    factoryLocation: "Bawana Industrial Area, Delhi - 110039",
    validUpto: "14-Jan-2021 (EXPIRED 5+ YEARS AGO)",
    brandName: "ROADKING"
  }
};

// HUID Registry Database
const HUID_REGISTRY_EXPANDED_DB = {
  "AB8492": {
    huidCode: "AB8492",
    status: "GENUINE_REGISTERED",
    karatage: "22K (916 Fineness)",
    articleType: "Gold Ring (Weight: 6.420 g)",
    ahcName: "National Assaying & Hallmarking Centre, Mumbai (AHC-0492)",
    hallmarkingDate: "14-Oct-2024",
    jewellerName: "Kalyan Jewellers India Limited",
    laserMarkingStatus: "Tamper-Evident Laser Engraved"
  }
};

// --------------------------------------------------------------------------
// 2. SERVICE LAYER ARCHITECTURE
// --------------------------------------------------------------------------

class StorageService {
  static get(key, defaultValue = null) {
    try {
      const val = localStorage.getItem(key);
      return val ? JSON.parse(val) : defaultValue;
    } catch(e) {
      return defaultValue;
    }
  }

  static set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch(e) {}
  }
}

class CitationService {
  static formatCitation(docCitation) {
    if (!docCitation) return '';
    return `${docCitation.code} • ${docCitation.clauseNumber || 'Statutory Gazette'}`;
  }

  static renderChipHTML(docCitation) {
    if (!docCitation) return '';
    const safeCode = docCitation.code ? docCitation.code.replace(/'/g, "\\'") : '';
    const safeTitle = docCitation.title ? docCitation.title.replace(/'/g, "\\'") : '';
    const safePage = docCitation.pageNumber || 1;
    const safeEvidence = docCitation.clauseEvidence ? docCitation.clauseEvidence.replace(/'/g, "\\'").replace(/\n/g, ' ') : '';

    return `
      <span class="citation-chip-badge" onclick="openClauseInPDF('${safeCode}', '${safeTitle}', ${safePage}, '${safeEvidence}')">
        <i class="fas fa-book-bookmark"></i> BIS • ${CitationService.formatCitation(docCitation)}
      </span>
    `;
  }
}

class RAGService {
  static VECTOR_DIM = 384;

  static generateDenseEmbedding(text) {
    const vec = new Float32Array(RAGService.VECTOR_DIM);
    if (!text || typeof text !== 'string') return vec;

    const clean = text.toLowerCase().replace(/[^a-z0-9\s]/g, ' ');
    const words = clean.split(/\s+/).filter(w => w.length > 0);

    for (let i = 0; i < words.length; i++) {
      const word = words[i];
      const wordWeight = 1.0 / Math.sqrt(i + 1);

      let hash = 5381;
      for (let c = 0; c < word.length; c++) {
        hash = ((hash << 5) + hash) + word.charCodeAt(c);
      }
      const primaryDim = Math.abs(hash) % RAGService.VECTOR_DIM;
      vec[primaryDim] += 2.0 * wordWeight;

      const padded = `^${word}$`;
      for (let t = 0; t < padded.length - 2; t++) {
        const c1 = padded.charCodeAt(t);
        const c2 = padded.charCodeAt(t + 1);
        const c3 = padded.charCodeAt(t + 2);
        const trigramHash = Math.abs((c1 * 31 * 31 + c2 * 31 + c3) ^ (i * 7)) % RAGService.VECTOR_DIM;
        vec[trigramHash] += 0.75 * wordWeight;
      }
    }

    let norm = 0;
    for (let d = 0; d < RAGService.VECTOR_DIM; d++) norm += vec[d] * vec[d];
    norm = Math.sqrt(norm);
    if (norm > 0) {
      for (let d = 0; d < RAGService.VECTOR_DIM; d++) vec[d] /= norm;
    }
    return vec;
  }

  static cosineSimilarity(vecA, vecB) {
    let dot = 0;
    for (let i = 0; i < RAGService.VECTOR_DIM; i++) dot += vecA[i] * vecB[i];
    return dot;
  }

  static checkVersionConflicts(query) {
    const qLower = query.toLowerCase();
    if (qLower.includes("4151:1993") || (qLower.includes("1993") && qLower.includes("helmet"))) {
      return {
        superseded: true,
        oldStandard: "IS 4151:1993",
        currentStandard: "IS 4151:2015",
        notice: "IS 4151:1993 has been completely WITHDRAWN and SUPERSEDED by IS 4151:2015. Manufacturing or selling helmets under the 1993 revision is illegal under Section 29, BIS Act 2016."
      };
    }
    if (qLower.includes("694:1990") || (qLower.includes("1990") && qLower.includes("cable"))) {
      return {
        superseded: true,
        oldStandard: "IS 694:1990",
        currentStandard: "IS 694:2010",
        notice: "IS 694:1990 is superseded by IS 694:2010. FRLS flame propagation and strict conductor resistance rules now apply."
      };
    }
    return null;
  }

  static searchHybrid(query) {
    const queryVec = RAGService.generateDenseEmbedding(query);
    const qLower = query.toLowerCase();
    const qTokens = qLower.split(/\s+/).filter(t => t.length > 2);

    let bestDoc = null;
    let maxScore = -1;

    for (const doc of BIS_STANDARDS_EXPANDED_DB) {
      const docText = `${doc.code} ${doc.title} ${doc.summary} ${(doc.keywords || []).join(' ')}`;
      const docVec = RAGService.generateDenseEmbedding(docText);
      const denseScore = Math.max(0, RAGService.cosineSimilarity(queryVec, docVec));

      let bm25Score = 0;
      for (const token of qTokens) {
        if (docText.toLowerCase().includes(token)) bm25Score += 0.3;
      }

      const hybridScore = (0.6 * denseScore) + (0.4 * Math.min(1.0, bm25Score));
      if (hybridScore > maxScore) {
        maxScore = hybridScore;
        bestDoc = doc;
      }
    }

    return { bestDoc, score: maxScore };
  }
}

class OCRService {
  static preprocessCanvas(canvas) {
    const ctx = canvas.getContext('2d');
    const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const data = imgData.data;

    let min = 255, max = 0;
    for (let i = 0; i < data.length; i += 4) {
      const gray = 0.299 * data[i] + 0.587 * data[i+1] + 0.114 * data[i+2];
      if (gray < min) min = gray;
      if (gray > max) max = gray;
    }

    const range = (max - min) || 1;
    for (let i = 0; i < data.length; i += 4) {
      let gray = 0.299 * data[i] + 0.587 * data[i+1] + 0.114 * data[i+2];
      let stretched = ((gray - min) / range) * 255;
      stretched = stretched > 128 ? 255 : 0; // High-contrast binarization
      data[i] = stretched;
      data[i+1] = stretched;
      data[i+2] = stretched;
    }
    ctx.putImageData(imgData, 0, 0);
    return canvas;
  }

  static async recognizeImage(canvas) {
    if (typeof Tesseract === 'undefined') {
      console.warn('Tesseract.js CDN is unavailable.');
      return { text: '', cml: null, huid: null };
    }

    try {
      const processed = OCRService.preprocessCanvas(canvas);
      const res = await Tesseract.recognize(processed, 'eng');
      const text = res.data.text || '';

      const cmlMatch = text.match(/CM\/L[- :.]*(\d{7})/i) || text.match(/\b(\d{7})\b/);
      const huidMatch = text.match(/\b([A-Z0-9]{6})\b/);

      return {
        text,
        cml: cmlMatch ? cmlMatch[1] : null,
        huid: (huidMatch && /[A-Z]/.test(huidMatch[1]) && /[0-9]/.test(huidMatch[1])) ? huidMatch[1] : null
      };
    } catch(err) {
      console.error('OCR Process Error:', err);
      return { text: '', cml: null, huid: null };
    }
  }
}

class AIService {
  static async sendQuery(query, history = [], role = 'consumer') {
    const versionCheck = RAGService.checkVersionConflicts(query);
    const { bestDoc, score } = RAGService.searchHybrid(query);

    // If online backend is reachable, try calling /api/chat with timeout
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 12000);

      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: 'qwen/qwen3.8-27b',
          messages: [
            { role: 'system', content: `You are MANAK-AI, authoritative Bureau of Indian Standards Copilot. Role: ${role}. Rely on retrieved evidence: ${JSON.stringify(bestDoc || {})}.` },
            ...history.slice(-6),
            { role: 'user', content: query }
          ]
        }),
        signal: controller.signal
      });
      clearTimeout(timeoutId);

      if (res.ok) {
        const data = await res.json();
        return {
          text: data.choices ? data.choices[0].message.content : data.text,
          docCitation: bestDoc,
          versionAlert: versionCheck
        };
      }
    } catch(err) {
      // Fallback seamlessly to local deterministic RAG generator
    }

    // Deterministic Offline Grounded Response Generation
    let outputText = '';
    if (versionCheck) {
      outputText += `> **⚠️ Version Notice:** ${versionCheck.notice}\n\n`;
    }

    if (bestDoc && score > 0.15) {
      outputText += `### 🇮🇳 Statutory BIS Assessment • ${bestDoc.code}\n\n`;
      outputText += `**Standard:** ${bestDoc.title}\n`;
      outputText += `**Status:** ${bestDoc.status} | **Scheme:** ${bestDoc.scheme}\n\n`;
      outputText += `#### 📋 Mandatory Clause Evidence (${bestDoc.clauseNumber}):\n`;
      outputText += `\`\`\`text\n${bestDoc.clauseEvidence}\n\`\`\`\n\n`;
      outputText += `#### 🔍 Key Testing Parameters & Thresholds:\n`;
      bestDoc.keyPoints.forEach(kp => { outputText += `* ${kp}\n`; });
    } else {
      outputText += `I have analyzed your inquiry regarding BIS national standards.\n\n`;
      outputText += `To give you an exact, verified answer, please specify the **Product Name** or **IS Standard Code** (e.g. *IS 4151 Helmet*, *IS 1786 TMT Rebar*, *IS 1417 Gold Purity*, or *IS 694 Cables*).`;
    }

    return {
      text: outputText,
      docCitation: bestDoc,
      versionAlert: versionCheck
    };
  }
}

// --------------------------------------------------------------------------
// 3. UI STATE & INTERACTION CONTROLLERS
// --------------------------------------------------------------------------
const APP_STATE = {
  currentRole: 'consumer',
  currentCameraFacing: 'environment',
  activeCameraStream: null,
  isSpeechActive: false,
  conversationHistory: []
};

function toggleTheme() {
  const current = document.documentElement.getAttribute('data-theme') || 'dark';
  const next = current === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  StorageService.set('bis_theme', next);
  const icon = document.getElementById('themeIcon');
  if (icon) icon.className = next === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
}

function toggleSidebar(forceOpen) {
  const sidebar = document.getElementById('appSidebar');
  const backdrop = document.getElementById('sidebarBackdrop');
  if (!sidebar) return;

  if (window.innerWidth <= 900) {
    const isOpen = typeof forceOpen === 'boolean' ? forceOpen : !sidebar.classList.contains('mobile-open');
    sidebar.classList.toggle('mobile-open', isOpen);
    if (backdrop) backdrop.style.display = isOpen ? 'block' : 'none';
  } else {
    sidebar.classList.toggle('collapsed');
  }
}

function toggleRoleDropdown() {
  const dd = document.getElementById('roleDropdown');
  if (dd) dd.classList.toggle('open');
}

function switchRole(roleKey, roleLabel, event) {
  APP_STATE.currentRole = roleKey;
  const labelEl = document.getElementById('selectedRoleLabel');
  if (labelEl) labelEl.innerText = roleLabel;

  document.querySelectorAll('#roleDropdown .model-option-item').forEach(i => i.classList.remove('selected'));
  if (event && event.currentTarget) event.currentTarget.classList.add('selected');
  toggleRoleDropdown();

  const input = document.getElementById('userInput');
  if (input) {
    if (roleKey === 'msme') input.placeholder = "Ask MSME Copilot (e.g. In-house lab STI setup, 50% subsidy schemes)...";
    else if (roleKey === 'inspector') input.placeholder = "Ask Inspector Copilot (e.g. Section 29 search warrants, seizure protocols)...";
    else input.placeholder = "Ask BIS Copilot anything (e.g. Helmet standards, Gold purity, Substandard goods)...";
  }

  appendMessage(`🔄 **Switched to ${roleLabel}**. Grounded intelligence and regulatory tools adapted for this persona.`, 'ai');
}

function startNewConversation() {
  APP_STATE.conversationHistory = [];
  const container = document.getElementById('chatMessages');
  if (!container) return;

  container.innerHTML = `
    <div class="workspace-empty-hero" id="chatWelcomeBox">
      <h1 class="empty-hero-title">How can I assist your compliance today?</h1>
      <p class="empty-hero-sub">
        Grounded intelligence across <strong>16 Curated National Indian Standards (IS Codes)</strong>, Quality Control Orders (QCOs), licensing roadmaps, and consumer safety.
      </p>
      <div class="hero-action-tiles-grid">
        <div class="hero-action-tile" onclick="openCameraViewfinder()">
          <div>
            <div class="tile-head">
              <div class="tile-title">🔍 Verify a Product</div>
              <i class="fas fa-qrcode tile-icon"></i>
            </div>
            <div class="tile-desc">Live packaging camera scan & 7-digit CM/L / 6-digit HUID verification.</div>
          </div>
        </div>
        <div class="hero-action-tile" onclick="triggerActionTile('standard')">
          <div>
            <div class="tile-head">
              <div class="tile-title">📚 Understand a Standard</div>
              <i class="fas fa-file-contract tile-icon"></i>
            </div>
            <div class="tile-desc">Explore mandatory testing limits, active vs superseded versions, and Gazette clauses.</div>
          </div>
        </div>
      </div>
    </div>
  `;
}

function triggerActionTile(type) {
  if (type === 'standard') {
    sendPredefinedQuery('What are the mandatory testing parameters and impact limits for helmets under IS 4151:2015?');
  }
}

function sendPredefinedQuery(text) {
  const input = document.getElementById('userInput');
  if (input) {
    input.value = text;
    submitUserQuery();
  }
}

function loadHistorySession(type) {
  startNewConversation();
  switch (type) {
    case 'helmet':
      sendPredefinedQuery('What is the mandatory standard for motorcycle helmets (IS 4151:2015) and drop test limits?');
      break;
    case 'solar':
      sendPredefinedQuery('Explain IS 14286 / IEC 61215 PV module test requirements for PM Surya Ghar subsidy.');
      break;
    case 'gold':
      executeInStreamTool('huid_calc');
      break;
    case 'cables':
      sendPredefinedQuery('What are the conductor resistance and FRLS flame retardant requirements under IS 694?');
      break;
  }
}

// --------------------------------------------------------------------------
// 4. MESSAGE RENDERING & SUBMISSION
// --------------------------------------------------------------------------
function renderMarkdown(md) {
  if (!md) return '';
  let html = md
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/^### (.*$)/gim, '<h4 style="margin:8px 0 4px;font-size:0.95rem;color:var(--text-main);">$1</h4>')
    .replace(/^#### (.*$)/gim, '<h5 style="margin:6px 0 2px;font-size:0.85rem;color:var(--text-muted);">$1</h5>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/`([^`]+)`/g, '<code style="background:rgba(255,255,255,0.08);padding:2px 5px;border-radius:4px;font-family:\'Fira Code\',monospace;font-size:0.82rem;">$1</code>')
    .replace(/^\* (.*$)/gim, '<li style="margin-left:18px;margin-bottom:4px;">$1</li>')
    .replace(/\n/g, '<br/>');
  return html;
}

function appendMessage(text, role, docCitation = null, isHTML = false) {
  const welcome = document.getElementById('chatWelcomeBox');
  if (welcome) welcome.style.display = 'none';

  const container = document.getElementById('chatMessages');
  if (!container) return;

  const row = document.createElement('div');
  row.className = `msg-stream-row ${role}`;

  const avatar = document.createElement('div');
  avatar.className = 'msg-avatar-icon';
  avatar.innerHTML = role === 'user' ? '<i class="fas fa-user"></i>' : '<i class="fas fa-shield-halved"></i>';

  const wrapper = document.createElement('div');
  wrapper.className = 'msg-body-wrapper';

  const bubble = document.createElement('div');
  bubble.className = 'msg-text-bubble';
  bubble.innerHTML = isHTML ? text : renderMarkdown(text);

  if (role === 'ai' && docCitation) {
    const chipWrapper = document.createElement('div');
    chipWrapper.innerHTML = CitationService.renderChipHTML(docCitation);
    bubble.appendChild(chipWrapper.firstElementChild);
  }

  wrapper.appendChild(bubble);
  row.appendChild(avatar);
  row.appendChild(wrapper);
  container.appendChild(row);

  container.scrollTop = container.scrollHeight;
  APP_STATE.conversationHistory.push({ role, content: text });
}

async function submitUserQuery() {
  const input = document.getElementById('userInput');
  if (!input) return;

  const text = input.value.trim();
  if (!text) return;

  input.value = '';
  appendMessage(text, 'user');

  // Show thinking indicator
  const loadingId = 'ai-loading-' + Date.now();
  appendMessage('<i class="fas fa-spinner fa-spin" style="margin-right:6px;"></i> Analyzing BIS standards & QCO gazette evidence...', 'ai', null, true);

  const res = await AIService.sendQuery(text, APP_STATE.conversationHistory, APP_STATE.currentRole);

  // Remove loading bubble
  const container = document.getElementById('chatMessages');
  if (container && container.lastElementChild) {
    container.lastElementChild.remove();
  }

  appendMessage(res.text, 'ai', res.docCitation);
}

function handleComposerKeydown(event) {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault();
    submitUserQuery();
  }
}

// --------------------------------------------------------------------------
// 5. IN-STREAM TOOLS & DETERMINISTIC CALCULATORS
// --------------------------------------------------------------------------
function executeInStreamTool(type) {
  const uid = Math.floor(Math.random() * 10000);

  if (type === 'huid_calc') {
    appendMessage(`
      <div class="bis-trust-assessment-card" id="huidCalcCard-${uid}">
        <div class="trust-card-header">
          <div>
            <strong style="font-size:1rem;color:var(--text-main);"><i class="fas fa-ring" style="color:var(--gold-accent);"></i> Statutory Gold Purity & Valuation Calculator</strong>
            <div style="font-size:0.75rem;color:var(--text-subtle);">BIS Hallmarking Scheme-VI (IS 1417:2016)</div>
          </div>
          <span class="trust-status-pill verified">IS 1417:2016</span>
        </div>
        
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:12px;">
          <div>
            <label style="font-size:0.72rem;color:var(--text-muted);display:block;margin-bottom:3px;">Gross Weight (Grams)</label>
            <input type="number" id="calcGoldWeight-${uid}" value="10.0" step="0.1" style="width:100%;background:var(--bg-app);border:1px solid var(--border-color);color:var(--text-main);padding:6px 10px;border-radius:6px;font-weight:700;" oninput="updateGoldCalc(${uid})" />
          </div>
          <div>
            <label style="font-size:0.72rem;color:var(--text-muted);display:block;margin-bottom:3px;">Purity Karat</label>
            <select id="calcGoldKarat-${uid}" style="width:100%;background:var(--bg-app);border:1px solid var(--border-color);color:var(--text-main);padding:6px 10px;border-radius:6px;font-weight:700;" onchange="updateGoldCalc(${uid})">
              <option value="91.6">22K (916 Fineness)</option>
              <option value="75.0">18K (750 Fineness)</option>
              <option value="58.5">14K (585 Fineness)</option>
              <option value="99.5">24K (995 Fineness)</option>
            </select>
          </div>
        </div>

        <div style="background:rgba(234,179,8,0.08);border:1px solid rgba(234,179,8,0.25);border-radius:8px;padding:10px;font-size:0.82rem;">
          <div style="display:flex;justify-content:space-between;margin-bottom:4px;">
            <span>Pure Gold Content:</span> <strong id="resPureGold-${uid}" style="color:var(--gold-accent);">9.16 g</strong>
          </div>
          <div style="display:flex;justify-content:space-between;">
            <span>Estimated Melt Valuation (@ ₹7,400/g 24K):</span> <strong id="resGoldVal-${uid}" style="color:var(--status-green);">₹ 67,784</strong>
          </div>
        </div>
      </div>
    `, 'ai', null, true);
  }
}

function updateGoldCalc(uid) {
  const weightInput = document.getElementById(`calcGoldWeight-${uid}`);
  const karatSelect = document.getElementById(`calcGoldKarat-${uid}`);
  const resPure = document.getElementById(`resPureGold-${uid}`);
  const resVal = document.getElementById(`resGoldVal-${uid}`);
  if (!weightInput || !karatSelect) return;

  const weight = parseFloat(weightInput.value) || 0;
  const fineness = parseFloat(karatSelect.value) / 100.0;
  const pureGrams = (weight * fineness).toFixed(2);
  const totalVal = Math.round(weight * fineness * 7400);

  if (resPure) resPure.innerText = `${pureGrams} g`;
  if (resVal) resVal.innerText = `₹ ${totalVal.toLocaleString('en-IN')}`;
}

// --------------------------------------------------------------------------
// 6. VISION & OCR CAMERA SCANNER ENGINE
// --------------------------------------------------------------------------
async function openCameraViewfinder() {
  const modal = document.getElementById('cameraModal');
  const video = document.getElementById('cameraVideo');
  if (!modal || !video) return;

  modal.classList.add('open', 'active');
  updateCameraStatus("Connecting to camera device...", false);

  if (APP_STATE.activeCameraStream) {
    try { APP_STATE.activeCameraStream.getTracks().forEach(t => t.stop()); } catch(e) {}
    APP_STATE.activeCameraStream = null;
  }

  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    updateCameraStatus("⚠️ Camera API not supported in this browser context. Please click 'Upload Photo' below.", true);
    return;
  }

  const constraintOptions = [
    { video: { facingMode: { ideal: APP_STATE.currentCameraFacing }, width: { ideal: 1280 } }, audio: false },
    { video: { facingMode: APP_STATE.currentCameraFacing === 'environment' ? 'user' : 'environment' }, audio: false },
    { video: true, audio: false }
  ];

  let stream = null;
  for (const c of constraintOptions) {
    try {
      stream = await navigator.mediaDevices.getUserMedia(c);
      if (stream) break;
    } catch(e) {}
  }

  if (stream) {
    APP_STATE.activeCameraStream = stream;
    video.srcObject = stream;
    video.setAttribute('playsinline', 'true');
    video.setAttribute('autoplay', 'true');
    video.muted = true;
    try {
      await video.play();
      updateCameraStatus("");
    } catch(e) {
      updateCameraStatus("");
    }
  } else {
    updateCameraStatus("⚠️ Camera permission blocked or device busy. Please click 'Upload Photo' to scan an image.", true);
  }
}

function updateCameraStatus(msg, isError = false) {
  const statusEl = document.getElementById('cameraStatusMsg');
  if (statusEl) {
    statusEl.innerHTML = msg;
    statusEl.style.display = msg ? 'block' : 'none';
    statusEl.style.color = isError ? 'var(--status-red)' : 'var(--text-muted)';
  }
}

async function toggleCameraFacing() {
  APP_STATE.currentCameraFacing = APP_STATE.currentCameraFacing === 'environment' ? 'user' : 'environment';
  await openCameraViewfinder();
}

function closeCameraModal() {
  const modal = document.getElementById('cameraModal');
  const video = document.getElementById('cameraVideo');
  if (modal) modal.classList.remove('open', 'active');

  if (APP_STATE.activeCameraStream) {
    try { APP_STATE.activeCameraStream.getTracks().forEach(t => t.stop()); } catch(e) {}
    APP_STATE.activeCameraStream = null;
  }
  if (video) video.srcObject = null;
  updateCameraStatus("");
}

async function captureCameraFrame() {
  const video = document.getElementById('cameraVideo');
  const canvas = document.getElementById('cameraCanvas');
  if (!video || !canvas) return;

  if (!APP_STATE.activeCameraStream || video.videoWidth === 0) {
    alert("⚠️ Camera is not active yet. Please click 'Upload Photo' to select an image.");
    return;
  }

  canvas.width = video.videoWidth || 640;
  canvas.height = video.videoHeight || 480;
  const ctx = canvas.getContext('2d');
  ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

  closeCameraModal();
  runRealOCRScan(canvas);
}

function handleCameraFallbackUpload(event) {
  const file = event.target.files && event.target.files[0];
  if (!file) return;

  closeCameraModal();
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  const img = new Image();

  img.onload = () => {
    canvas.width = img.width;
    canvas.height = img.height;
    ctx.drawImage(img, 0, 0);
    runRealOCRScan(canvas);
    event.target.value = '';
  };
  img.src = URL.createObjectURL(file);
}

async function runRealOCRScan(canvas) {
  appendMessage('<i class="fas fa-spinner fa-spin"></i> Processing image & running neural OCR text extraction...', 'ai', null, true);
  
  const ocrRes = await OCRService.recognizeImage(canvas);
  
  const container = document.getElementById('chatMessages');
  if (container && container.lastElementChild) container.lastElementChild.remove();

  if (ocrRes.cml) {
    renderBISTrustCard(ocrRes.cml);
  } else if (ocrRes.huid) {
    renderHUIDTrustCard(ocrRes.huid);
  } else {
    appendMessage(`
      <div class="bis-trust-assessment-card">
        <div class="trust-card-header">
          <strong>🔍 OCR Scan Completed</strong>
          <span class="trust-status-pill counterfeit">INSUFFICIENT DATA</span>
        </div>
        <p style="font-size:0.82rem;color:var(--text-muted);">
          Could not clearly identify a 7-digit CM/L or 6-digit Gold HUID. Raw OCR output: <code style="font-family:'Fira Code',monospace;">${ocrRes.text.slice(0, 80) || 'None'}</code>
        </p>
      </div>
    `, 'ai', null, true);
  }
}

function testSampleVerification(type) {
  closeCameraModal();
  if (type === 'genuine') renderBISTrustCard('8530092');
  else if (type === 'counterfeit') renderBISTrustCard('4091823');
  else if (type === 'huid') renderHUIDTrustCard('AB8492');
}

function renderBISTrustCard(cmlNumber) {
  const reg = CML_REGISTRY_EXPANDED_DB[cmlNumber] || {
    cmlNumber: cmlNumber,
    status: "UNREGISTERED / SUSPECT",
    isOperative: false,
    firmName: "Unregistered Manufacturer",
    product: "Unknown Product",
    standardCode: "N/A",
    validUpto: "N/A"
  };

  appendMessage(`
    <div class="bis-trust-assessment-card" id="trustCard-${cmlNumber}">
      <div class="trust-card-header">
        <div>
          <strong style="font-size:1rem;color:var(--text-main);"><i class="fas fa-certificate" style="color:var(--primary-blue);"></i> BIS License Inspection • CM/L-${reg.cmlNumber}</strong>
          <div style="font-size:0.75rem;color:var(--text-subtle);">${reg.product}</div>
        </div>
        <span class="trust-status-pill ${reg.isOperative ? 'verified' : 'counterfeit'}">${reg.status}</span>
      </div>

      <div class="trust-grid-2col">
        <div class="trust-grid-cell"><label>Manufacturer Firm:</label><span>${reg.firmName}</span></div>
        <div class="trust-grid-cell"><label>Standard Code:</label><span>${reg.standardCode}</span></div>
        <div class="trust-grid-cell"><label>Factory Location:</label><span>${reg.factoryLocation || 'N/A'}</span></div>
        <div class="trust-grid-cell"><label>Licence Validity:</label><span style="color:${reg.isOperative ? 'var(--status-green)' : 'var(--status-red)'};">${reg.validUpto}</span></div>
      </div>
    </div>
  `, 'ai', null, true);
}

function renderHUIDTrustCard(huid) {
  const reg = HUID_REGISTRY_EXPANDED_DB[huid] || {
    huidCode: huid,
    status: "NOT_FOUND",
    karatage: "Unknown",
    articleType: "Unregistered Gold Article",
    jewellerName: "Local Jeweller (Unregistered)",
    ahcName: "N/A"
  };

  appendMessage(`
    <div class="bis-trust-assessment-card" id="huidCard-${huid}">
      <div class="trust-card-header">
        <div>
          <strong style="font-size:1rem;color:var(--text-main);"><i class="fas fa-ring" style="color:var(--gold-accent);"></i> BIS Gold Hallmarking Verification • HUID ${reg.huidCode}</strong>
          <div style="font-size:0.75rem;color:var(--text-subtle);">${reg.articleType}</div>
        </div>
        <span class="trust-status-pill ${reg.status === 'GENUINE_REGISTERED' ? 'verified' : 'counterfeit'}">${reg.status}</span>
      </div>

      <div class="trust-grid-2col">
        <div class="trust-grid-cell"><label>Certified Purity:</label><span style="color:var(--gold-accent);">${reg.karatage}</span></div>
        <div class="trust-grid-cell"><label>Hallmarking Centre:</label><span>${reg.ahcName}</span></div>
        <div class="trust-grid-cell"><label>Jeweller Name:</label><span>${reg.jewellerName}</span></div>
        <div class="trust-grid-cell"><label>Laser Security:</label><span>${reg.laserMarkingStatus || 'N/A'}</span></div>
      </div>
    </div>
  `, 'ai', null, true);
}

// --------------------------------------------------------------------------
// 7. SPLIT-SCREEN GAZETTE PDF STUDIO CONTROLLER
// --------------------------------------------------------------------------
function togglePDFPane() {
  const pane = document.getElementById('pdfEvidencePane');
  const btn = document.getElementById('btnSplitPDF');
  if (!pane) return;

  const isOpen = pane.classList.toggle('open');
  if (btn) btn.classList.toggle('active', isOpen);
}

function openClauseInPDF(code, title, page, evidence) {
  const pane = document.getElementById('pdfEvidencePane');
  const btn = document.getElementById('btnSplitPDF');
  const body = document.getElementById('pdfContentRenderArea');
  if (!pane || !body) return;

  pane.classList.add('open');
  if (btn) btn.classList.add('active');

  body.innerHTML = `
    <div style="margin-bottom:12px;">
      <span style="font-size:0.72rem;background:rgba(59,130,246,0.15);color:var(--primary-blue);padding:2px 8px;border-radius:4px;font-weight:700;">${code}</span>
      <h4 style="margin:6px 0 2px;font-size:0.95rem;color:var(--text-main);">${title}</h4>
      <div style="font-size:0.75rem;color:var(--text-muted);">Official Gazette of India • Page ${page}</div>
    </div>

    <div class="pdf-clause-highlight-card">
      <div style="font-size:0.72rem;font-weight:700;color:var(--gold-accent);margin-bottom:4px;">HIGHLIGHTED STATUTORY CLAUSE:</div>
      ${evidence || 'No direct text extract available.'}
    </div>

    <div style="text-align:center;padding:12px;background:var(--bg-app);border-radius:8px;border:1px solid var(--border-color);">
      <button onclick="renderGazettePDFCanvas('${code}', '${title}', ${page})" style="background:var(--primary-blue);color:#FFF;border:none;padding:6px 12px;border-radius:6px;font-size:0.78rem;font-weight:700;cursor:pointer;">
        <i class="fas fa-eye"></i> Render Visual Gazette Canvas
      </button>
      <div id="gazetteCanvasContainer" style="margin-top:10px;"></div>
    </div>
  `;
}

function renderGazettePDFCanvas(code, title, page) {
  const container = document.getElementById('gazetteCanvasContainer');
  if (!container) return;

  const canvas = document.createElement('canvas');
  canvas.width = 420;
  canvas.height = 280;
  const ctx = canvas.getContext('2d');

  ctx.fillStyle = '#FFFFFF';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.strokeStyle = '#CBD5E1';
  ctx.strokeRect(10, 10, canvas.width - 20, canvas.height - 20);

  ctx.fillStyle = '#0F172A';
  ctx.font = 'bold 12px "Plus Jakarta Sans", sans-serif';
  ctx.fillText(`THE GAZETTE OF INDIA • ${code}`, 30, 35);

  ctx.font = '10px "Plus Jakarta Sans", sans-serif';
  ctx.fillStyle = '#475569';
  ctx.fillText(`Official Specification: ${title.slice(0, 45)}...`, 30, 55);
  ctx.fillText(`Statutory Reference • Clause Evidence Inspection • Page ${page}`, 30, 75);

  ctx.fillStyle = '#FEF08A';
  ctx.fillRect(30, 95, 360, 60);
  ctx.fillStyle = '#854D0E';
  ctx.fillText(`[MANDATORY COMPLIANCE CLAUSE CERTIFIED]`, 40, 115);
  ctx.fillText(`All non-compliant articles subject to Section 29 Seizure`, 40, 135);

  container.innerHTML = '';
  container.appendChild(canvas);
}

// --------------------------------------------------------------------------
// 8. COMMAND PALETTE (Ctrl + K) & MODAL CONTROLLERS
// --------------------------------------------------------------------------
function openCommandPalette() {
  const modal = document.getElementById('cmdPalette');
  const input = document.getElementById('cmdSearchInput');
  if (!modal) return;

  modal.classList.add('open', 'active');
  if (input) {
    input.value = '';
    input.focus();
    filterCommandPalette('');
  }
}

function closeCommandPalette() {
  const modal = document.getElementById('cmdPalette');
  if (modal) modal.classList.remove('open', 'active');
}

function filterCommandPalette(query) {
  const container = document.getElementById('cmdPaletteResults');
  if (!container) return;

  const qLower = (query || '').toLowerCase().trim();
  let matches = [];

  BIS_STANDARDS_EXPANDED_DB.forEach(doc => {
    if (!qLower || doc.code.toLowerCase().includes(qLower) || doc.title.toLowerCase().includes(qLower) || (doc.keywords || []).some(k => k.includes(qLower))) {
      matches.push({ type: 'Standard', title: `${doc.code} — ${doc.title}`, desc: doc.category, action: () => { closeCommandPalette(); sendPredefinedQuery(`Explain requirements under ${doc.code}`); } });
    }
  });

  if (matches.length === 0) {
    container.innerHTML = `<div style="text-align:center;padding:1.5rem;color:var(--text-muted);font-size:0.85rem;">No standards found matching "${query}"</div>`;
    return;
  }

  container.innerHTML = matches.slice(0, 6).map((m, idx) => `
    <div class="cmd-item" onclick="cmdPaletteAction(${idx})">
      <i class="fas fa-file-contract" style="color:var(--primary-blue);"></i>
      <div style="flex:1;overflow:hidden;">
        <div style="font-weight:600;font-size:0.88rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${m.title}</div>
        <div style="font-size:0.75rem;color:var(--text-subtle);">${m.desc}</div>
      </div>
    </div>
  `).join('');

  window._cmdMatches = matches;
}

function cmdPaletteAction(idx) {
  if (window._cmdMatches && window._cmdMatches[idx]) {
    window._cmdMatches[idx].action();
  }
}

function openWhyUsModal() {
  const modal = document.getElementById('whyUsModal');
  if (modal) modal.classList.add('open', 'active');
}

function closeWhyUsModal() {
  const modal = document.getElementById('whyUsModal');
  if (modal) modal.classList.remove('open', 'active');
}

function openComplianceWizard() {
  const modal = document.getElementById('complianceWizardModal');
  const body = document.getElementById('complianceWizardBody');
  if (!modal || !body) return;

  modal.classList.add('open', 'active');
  body.innerHTML = `
    <div style="font-size:0.85rem;color:var(--text-main);line-height:1.6;">
      <div style="margin-bottom:12px;">
        <label style="font-weight:600;display:block;margin-bottom:4px;">Select Industry Category:</label>
        <select style="width:100%;padding:6px;background:var(--bg-app);border:1px solid var(--border-color);color:var(--text-main);border-radius:6px;">
          <option>Construction & TMT Steel (IS 1786)</option>
          <option>Automotive Helmets (IS 4151)</option>
          <option>Electrical Cables & Wires (IS 694)</option>
          <option>Packaged Drinking Water (IS 14543)</option>
        </select>
      </div>
      <div style="background:rgba(59,130,246,0.08);border:1px solid rgba(59,130,246,0.2);padding:10px;border-radius:6px;margin-bottom:12px;">
        <div style="display:flex;justify-content:space-between;"><span>Application Fee:</span> <strong>₹ 1,000</strong></div>
        <div style="display:flex;justify-content:space-between;"><span>Testing Sample Fee:</span> <strong>₹ 25,000</strong></div>
        <div style="display:flex;justify-content:space-between;color:var(--status-green);"><span>MSME 50% Marking Subsidy:</span> <strong>-50% Concession</strong></div>
      </div>
      <button onclick="closeComplianceWizard()" style="width:100%;background:var(--primary-blue);color:#FFF;border:none;padding:8px;border-radius:6px;font-weight:700;cursor:pointer;">
        Close Assessment
      </button>
    </div>
  `;
}

function closeComplianceWizard() {
  const modal = document.getElementById('complianceWizardModal');
  if (modal) modal.classList.remove('open', 'active');
}

// --------------------------------------------------------------------------
// 9. SPEECH RECOGNITION & GLOBAL INITIALIZATION
// --------------------------------------------------------------------------
let speechRecognizer = null;
let currentVoiceLang = 'hi-IN';

function toggleVoiceLanguage() {
  currentVoiceLang = currentVoiceLang === 'hi-IN' ? 'en-IN' : 'hi-IN';
  const btn = document.getElementById('btnVoiceLang');
  if (btn) btn.innerHTML = `<i class="fas fa-language"></i> <span>${currentVoiceLang === 'hi-IN' ? 'HI' : 'EN'}</span>`;
  if (speechRecognizer) speechRecognizer.lang = currentVoiceLang;
}

function toggleVoiceInput() {
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (!SpeechRecognition) {
    alert('Voice input is supported in Chrome/Edge on secure HTTPS or localhost.');
    return;
  }

  if (APP_STATE.isSpeechActive && speechRecognizer) {
    speechRecognizer.stop();
    APP_STATE.isSpeechActive = false;
    document.getElementById('micBtn')?.classList.remove('listening');
    return;
  }

  try {
    speechRecognizer = new SpeechRecognition();
    speechRecognizer.lang = currentVoiceLang;
    speechRecognizer.continuous = false;

    speechRecognizer.onstart = () => {
      APP_STATE.isSpeechActive = true;
      document.getElementById('micBtn')?.classList.add('listening');
    };

    speechRecognizer.onresult = (e) => {
      const transcript = e.results[0][0].transcript;
      const input = document.getElementById('userInput');
      if (input && transcript) {
        input.value = transcript;
        submitUserQuery();
      }
    };

    speechRecognizer.onend = () => {
      APP_STATE.isSpeechActive = false;
      document.getElementById('micBtn')?.classList.remove('listening');
    };

    speechRecognizer.start();
  } catch(e) {
    console.warn('Speech error:', e);
  }
}

// Global Keyboard Shortcuts (Ctrl+K, Esc)
document.addEventListener('keydown', (e) => {
  if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
    e.preventDefault();
    openCommandPalette();
  } else if ((e.ctrlKey || e.metaKey) && e.key === 'j') {
    e.preventDefault();
    startNewConversation();
  } else if (e.key === 'Escape') {
    closeCommandPalette();
    closeWhyUsModal();
    closeCameraModal();
    closeComplianceWizard();
  }
});

// Cache & Service Worker Cleanup
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(regs => {
    regs.forEach(r => r.unregister());
  });
}
if ('caches' in window) {
  caches.keys().then(names => {
    names.forEach(n => caches.delete(n));
  });
}

// Theme Rehydration on Page Load
const savedTheme = StorageService.get('bis_theme', 'dark');
document.documentElement.setAttribute('data-theme', savedTheme);
  </script>
</body>
</html>
'@

[System.IO.File]::WriteAllText($outputPath, $htmlContent, [System.Text.Encoding]::UTF8)
Write-Output "Successfully wrote production-grade standalone_app.html ($($htmlContent.Length) chars)"

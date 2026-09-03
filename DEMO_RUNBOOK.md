# MANAK-AI (SIH 2026) — 90-Second Judge Presentation Runbook

**Problem Statement:** SIH26107 — AI-powered Intelligent Assistant for Indian Standards and BIS Services  
**Goal:** Deliver a flawless, authoritative, and confidence-inspiring demonstration to senior evaluators.

---

## 🎯 The Core Elevator Pitch (First 20 Seconds)

> *"Respected Judges, generic AI assistants like ChatGPT guess Indian Standards from memory—often hallucinating clause numbers, confusing voluntary guidelines with mandatory QCOs, or prescribing incorrect test limits.  
>  
> **MANAK-AI** is built on a fundamental principle: **We refuse to guess Indian Standards.**  
> Powered by an authoritative catalog of 23,401 standards, 769 mandatory QCOs, and genuine BGE semantic hybrid RAG, our system grounds every single answer in official Gazette clauses and provides split-screen statutory evidence."*

---

## 🧪 3-Step Live Demonstration Flow

### Flow 1: Mandatory QCO Compliance & Split-Screen Evidence (30s)
* **Prompt to Type / Click:**
  ```
  What are the mandatory testing requirements for IS 4151 helmets under MoRTH QCO?
  ```
* **What to Show the Judges:**
  1. **Dynamic Progress Bar**: Point out the 3-stage progress tracker (*Analyzing Intent → Searching Gazette RAG → Synthesizing Answer*).
  2. **Active IS Code Card**: Highlights `IS 4151:2015`, **MANDATORY QCO** status, and key parameters (drop height 3.0m, peak acceleration $\le$ 300g).
  3. **Split-Screen Studio**: Click **"Open in Gazette Studio"** to show the official gazette page with **Clause 7.4 (Impact Attenuation Test)** highlighted in real-time.
  4. **Grounding Badge**: Highlight the verified gazette badge showing 90%+ clause grounding.

---

### Flow 2: MSME Factory STI Audit & Concession (25s)
* **Action:**
  Click **Tools Hub** $\rightarrow$ Click **"78% STI In-House Audit"** (or type query).
* **What to Show the Judges:**
  1. Demonstrate the automated **Scheme of Testing & Inspection (STI)** readiness scorecard.
  2. Explain how this qualifies an Udyam-registered startup for the **official 50% marking fee concession** on Manakonline.
  3. Show the **1-Click PDF Legal / Audit Notice Generator** that auto-formats a compliance report.

---

### Flow 3: The "Refusal to Hallucinate" Demonstration (15s)
* **The Killer Test:**
  Ask about an unindexed, voluntary product that generic LLMs always hallucinate:
  ```
  What is the mandatory BIS standard for household plastic buckets?
  ```
* **What to Show the Judges:**
  1. The assistant **strictly refuses** to invent a standard or misapply unrelated plastics/plugs standards.
  2. It explains that no mandatory standalone QCO currently applies to household buckets.
  3. It automatically generates official contact guidance (`ird@bis.gov.in`) and a link to the official standards catalog (`standardsbis.bsbedge.com`).
  > *"Judges, while other AI models hallucinate an answer, MANAK-AI protects Indian manufacturers by refusing to provide ungrounded regulatory advice."*

---

## ⚡ Backup 1-Click Verification Scenarios (If Asked to Test Scanner)

If judges ask about the **Camera / Verification Scanner**, open the camera modal and click the fast test scenarios:
1. **🟢 Helmet — GENUINE (CM/L-8530092)**:
   - Matches 7-digit license in manufacturer registry + authentic ISI logo geometry (Dual-Signal).
2. **🔴 Helmet — COUNTERFEIT (CM/L-4091823)**:
   - Detects revoked license and geometric distortion, auto-drafting a Section 29 legal notice.
3. **🟡 22K Gold — VERIFIED HUID (AB8492)**:
   - Validates 6-digit laser HUID and calculates pure gold value.
4. **🔴 Gold Ring — HUID PURITY FRAUD (FA9999)**:
   - Triggers the **3X Differential Compensation Calculator** under Rule 49, BIS Hallmarking Regulations.

---

## 🛡️ Judge Defense Q&A

**Q: Is your system connected live to the official BIS database?**  
*A: "Our prototype is grounded in 23,401 official catalog standards and 1,975 pre-indexed statutory gazette chunks validated with SHA-256 provenance hashes. It is fully architected with secure API gateway adapters ready to plug directly into the National Informatics Centre (NIC) e-BIS production API once formal access is provisioned."*

**Q: How does this prevent prompt injection?**  
*A: "Our server strips all client-sent system prompts, enforces an immutable server-side compliance system instruction, blocks path traversal and .env inspection with HTTP 403, and strictly validates all retrieved IS codes against the national registry."*

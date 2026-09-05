# BIS Trust Copilot — 3-Minute College Screening Demo Script
**Smart India Hackathon 2026 | Problem Statement: SIH26107**  
**Role: Presenter (Student) | Target Duration: 3 Minutes (180 Seconds)**

---

### [0:00 – 0:20] The Problem
*(Screen on index.html landing page)*

> "Respected judges, India has over 23,000 national standards and more than 700 mandatory Quality Control Orders. Yet today, when an MSME wants to set up a factory or a consumer wants to check if an ISI mark or gold jewellery is genuine, they are trapped in fragmented portals and hundreds of pages of legal PDFs. General AI like ChatGPT cannot be trusted here—it hallucinates standard numbers, invents test limits, and confuses outdated revisions."

---

### [0:20 – 0:40] The Solution
*(Point to the hero title and Trust Indicators on index.html)*

> "That is why we built **BIS Trust Copilot**. It is an authoritative, evidence-grounded AI copilot designed for Indian Standards and compliance. It combines hybrid dense and sparse search over our national catalog of 23,401 standards with an enterprise-grade Grounding Score. Most importantly: AI does not make up facts here—it only explains verified statutory evidence."

---

### [0:40 – 1:30] Main BIS Query Demo
*(Click the demo starter pill: **"What standard applies to Sariya?"** or click Consult AI)*

> "Let me demonstrate with a real-world question: *'What standard applies to Sariya?'*
> Notice how immediately our hybrid retrieval engine maps the colloquial Hindi term 'Sariya' to **IS 1786:2008** for High Strength Deformed Steel Bars. 
> The system retrieves the exact DPIIT Quality Control Order, identifies the mandatory Scheme-I ISI Mark requirement, and streams a structured answer with technical parameters like Fe 500D yield strength and elongation limits."

---

### [1:30 – 2:00] Citation & Evidence Drawer
*(Click the **Grounding Score Badge (HIGH)** to expand the Evidence Drawer)*

> "Notice this **HIGH Grounding Score** badge. When I click it, our slide-out **Evidence Drawer** opens. 
> Here, judges can inspect the actual ground truth: Standard **IS 1786:2008**, Clause **9.1** for Bend and Rebend tests, Page Number **6**, statutory evidence tier, and the direct BIS document source. 
> There is zero black-box mystery. Every statement is directly anchored to an authentic government specification."

---

### [2:00 – 2:30] Licence & Gold HUID Verification
*(Navigate to **Verify** page via top nav or Ctrl+K)*

> "Now let us test authenticity verification. 
> First, I'll enter a 7-digit CM/L license number: **9512345**. Within milliseconds, the system validates it against indexed reference data, showing an **ACTIVE** licence for PVC insulated cables under IS 694. 
> Next, I enter a 6-digit laser HUID code: **AB8492**. It instantly confirms **VERIFIED** 22 Karat 916 gold hallmarking. 
> If a consumer suspects adulteration, our built-in calculator computes the statutory 3X compensation under Hallmarking Regulation 12."

---

### [2:30 – 2:50] Knowledge Graph & Command Palette
*(Click **Knowledge Graph** in nav, then press **Ctrl + K**)*

> "To see how regulations connect, we can open our interactive **Knowledge Graph** connecting over 10,700 nodes and 16,600 regulatory relationships—linking standards, QCO ministries, and testing laboratories. 
> And for power users and factory auditors, pressing **Ctrl + K** summons our instant Command Palette for quick search and keyboard navigation across all modules."

---

### [2:50 – 3:00] Why This is Different & Conclusion
*(Switch back to index.html)*

> "Even if the Gemini API or cloud connectivity drops, our system gracefully falls back to locally retrieved BIS statutory clauses. 
> BIS Trust Copilot replaces guesswork with verifiable evidence—protecting Indian consumers and empowering MSME manufacturing. Thank you!"

---

### Presenter Checklist Before Taking the Stage:
1. Ensure `node server.js` is running on `http://127.0.0.1:3000`.
2. Have `http://localhost:3000/index.html` open in Chrome.
3. Have sample numbers memorized or on a sticky note:
   - **CM/L Sample:** `9512345` (Active Havells IS 694)
   - **HUID Sample:** `AB8492` (22K Gold Hallmark)
   - **Demo Query:** *"What standard applies to Sariya?"*

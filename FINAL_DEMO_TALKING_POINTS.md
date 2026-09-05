# BIS Trust Copilot — Final Judge Demo Talking Points
**Smart India Hackathon 2026 • Problem Statement SIH26107 | Team BYTE-BUSTERS**  
*College Screening Speaking Guide (Each response < 20 seconds naturally)*

---

### 1. What problem are you solving?
> "India has over 23,000 standards and 760+ mandatory Quality Control Orders spread across multiple portals. MSMEs struggle to identify mandatory factory testing requirements, and consumers cannot easily verify ISI marks or gold hallmarking."

### 2. Why not simply use ChatGPT?
> "Generic LLMs frequently hallucinate standard numbers, confuse outdated revisions with active ones, and invent non-existent test parameters. Our copilot is strictly evidence-grounded: every answer is anchored to authentic clauses and page numbers with an explicit Grounding Score."

### 3. What is the core technology?
> "A local hybrid retrieval engine combining 384-dimensional dense semantic vectors (`BAAI/bge-small-en-v1.5`) and sparse lexical matching (`Okapi BM25`), fused with Reciprocal Rank Fusion ($k=60$), coupled with a multi-relational Knowledge Graph."

### 4. What makes it trustworthy?
> "AI does not generate facts here—it only explains retrieved statutory text. The system enforces an evidence boundary: if an inquiry cannot be substantiated from the indexed standards, the system explicitly reports it rather than guessing."

### 5. Where does the data come from?
> "Official public records of the Bureau of Indian Standards, including the National Standards Catalog of 23,401 standards, 769 Gazette Quality Control Orders, published Scheme of Testing & Inspection (STI) manuals, and 431 recognized testing laboratories."

### 6. How does RAG work here?
> "When a query arrives, it runs in parallel through dense vector search and BM25 lexical lookup. The candidate chunks are merged via Reciprocal Rank Fusion, and top-ranked statutory excerpts are injected into Gemini's system instruction to produce a grounded explanation."

### 7. Why BM25 + BGE?
> "Dense embeddings capture colloquial terms and semantic synonyms—like mapping 'Sariya' to reinforcement bars—while BM25 guarantees exact alphanumeric code matching for standard numbers like 'IS 1786:2008 Clause 9.1'."

### 8. What does Gemini do?
> "Gemini acts exclusively as the reasoning and natural language explanation layer. It translates complex legal specifications and technical tables into clear, structured guidance for manufacturers and citizens."

### 9. What happens if Gemini fails?
> "The system automatically tries our backup Gemini candidate cascade. If all cloud AI connectivity drops, the interface gracefully displays the locally retrieved BIS statutory clauses, tables, and citation drawer directly to the user."

### 10. Is verification live or reference-data based?
> "In this prototype, CM/L licenses and gold HUIDs are verified against curated reference datasets. In production, with official API authorization from BIS, this module connects directly to live Manakonline and AHC databases."

### 11. What is prototype-only?
> "The AI camera OCR scanner, mobile bill auditor, and e-commerce link analyzer are prototype demonstration features. The hybrid RAG retrieval, canonical standard resolution, and Grounding Score engine are fully implemented."

### 12. How will this scale?
> "Our retrieval pipeline is stateless and containerized. For national scale, in-memory arrays can transition to a distributed vector store like Qdrant or Milvus behind standard caching and rate-limiting reverse proxies."

---

### 🛑 FINAL "DO NOT SAY" CHECKLIST FOR THE TEAM
*(Saying any of these terms will invite immediate judge scrutiny)*

❌ **DO NOT SAY:** `"100% accurate"`  
👉 *Say instead:* `"Evidence-grounded with verified clause citations."`

❌ **DO NOT SAY:** `"Hallucination-proof"`  
👉 *Say instead:* `"Hallucination-resistant through strict evidence grounding and score verification."`

❌ **DO NOT SAY:** `"Live government database"` or `"Official real-time registry"`  
👉 *Say instead:* `"Verified against indexed BIS reference datasets."`

❌ **DO NOT SAY:** `"70% faster"`  
👉 *Say instead:* `"Sub-second colloquial discovery compared to manual document navigation."`

❌ **DO NOT SAY:** `"50% subsidy"`  
👉 *Say instead:* `"50% marking fee concession under Scheme-I for eligible MSMEs."`

❌ **DO NOT SAY:** `"Dual LLM"`  
👉 *Say instead:* `"Google Gemini with multi-model fallback cascade."`

❌ **DO NOT SAY:** `"Groq"`  
👉 *(Groq has been removed; Gemini is the single provider).*

❌ **DO NOT SAY:** `"Cryptographic SHA-256 fingerprint"`  
👉 *Say instead:* `"Document provenance identifier / content hash."`

❌ **DO NOT SAY:** `"All 23,401 standards have semantic full-text embeddings"`  
👉 *Say instead:* `"All 23,401 standards are indexed in the national catalog, with full-text semantic clause embeddings for high-priority mandatory standards."`

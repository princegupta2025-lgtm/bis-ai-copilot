# BIS Trust Copilot — Judge Q&A Defense Guide
**Smart India Hackathon 2026 | Problem Statement: SIH26107**  
**Team BYTE-BUSTERS | Final Screening Preparation**

---

### 1. What problem are you solving?
Indian Standards and Quality Control Orders (QCOs) span over 23,000 documents and multiple government portals, making compliance confusing for MSMEs and authenticity checks cumbersome for consumers. BIS Trust Copilot bridges this gap by unifying technical standards retrieval, compliance checklist generation, and certificate verification into one accessible, grounded interface.

### 2. Why not simply use ChatGPT?
General LLMs frequently hallucinate standard numbers, confuse obsolete revisions with active ones, and invent non-existent test limits or clause citations. Our system grounds every answer in authoritative Indian Standards documents using hybrid retrieval, showing exact clauses, page numbers, and Grounding Scores that judges and engineers can independently verify.

### 3. What makes your system trustworthy?
Trust is enforced architecturally through a dual-signal verification pipeline and server-side citation enforcement. The LLM only explains evidence retrieved from our indexed BIS reference database; if evidence is missing or ambiguous, the system explicitly reports the standard as not indexed rather than guessing.

### 4. Where does your BIS data come from?
Our data is ingested from official Bureau of Indian Standards public records, including the National Standards Catalog (23,401 entries), Gazette Quality Control Orders (769 QCOs), and published Scheme of Testing & Inspection (STI) guidelines. Authorized statutory standards are parsed, chunked, and embedded into 384-dimensional dense vectors alongside Okapi BM25 inverted indexes.

### 5. How does RAG work here?
When a query arrives, it runs in parallel through dense vector retrieval (BAAI/bge-small-en-v1.5) and sparse lexical search (Okapi BM25). The candidate chunks are fused using Reciprocal Rank Fusion (RRF, k=60), and the top-ranked statutory excerpts are injected as immutable context into Gemini’s system instruction to produce a grounded explanation.

### 6. Why BM25 + BGE?
Dense models excel at semantic intent and synonyms (e.g., mapping colloquial terms like "sariya" to "reinforcement bars"), but often miss exact alphanumeric codes. Okapi BM25 guarantees precise keyword and standard code matching (e.g., "IS 1786:2008 Clause 9.1"), ensuring neither semantic context nor exact statutory references are missed.

### 7. Why RRF?
Reciprocal Rank Fusion merges dense and lexical rankings based on rank position rather than raw score normalization, avoiding the distortion caused by disparate score distributions. This provides robust, stable retrieval even when embedding cosine similarities and BM25 BM-scores vary drastically in scale.

### 8. What happens if Gemini fails?
If Gemini is unreachable or throttled, our server-side cascade automatically attempts backup Gemini models (`gemini-3.5-flash-lite`, `gemini-3.5-flash`, `gemini-3.6-flash`). If all external AI connectivity fails, the interface gracefully renders the locally retrieved BIS standard evidence, clauses, and citation drawer directly to the user with a transparent offline notice.

### 9. How do you handle outdated standards?
Each standard in our database carries active metadata fields including `status`, `supersedes`, `revisionYear`, and `effectiveDate`. When an older standard is requested (such as IS 4151:1993), our system flags it with an explicit "SUPERSEDED" warning and automatically points the user to the active mandatory version (IS 4151:2015).

### 10. How do you prevent hallucination?
Hallucination is prevented by keeping Gemini strictly as an explanation engine rather than a knowledge store. The model is constrained by server-side system prompts to cite only the injected statutory RAG context; if the query cannot be substantiated from the evidence, the system calculates a low Grounding Score and flags unverified statements.

### 11. Is this live BIS verification?
No, in this prototype, licence (CM/L) and gold hallmarking (HUID) lookups are evaluated against indexed BIS reference datasets rather than a live government API. In a production deployment with official API credentials, this module can directly query the live Manakonline and National Assaying & Hallmarking Centre databases.

### 12. What is prototype vs production-ready?
The hybrid RAG retrieval pipeline, canonical standard resolution, Grounding Score calculation, and offline evidence fallback are fully implemented and production-ready. The OCR camera scanner, mobile bill auditor, and external portal verification use prototype demonstration reference datasets and require formal API integration and high-volume load testing before nationwide deployment.

### 13. How will you scale this?
The architecture scales horizontally because the retrieval pipeline is stateless, and the vector index can transition from in-memory arrays to a distributed vector database like Qdrant or Milvus. The Express proxy can be containerized with Docker behind a reverse proxy (NGINX or Cloudflare) with rate limiting and Redis caching.

### 14. Who are the users?
Our solution serves three distinct user personas: consumers verifying product authenticity and reporting fake marks; MSMEs and manufacturers navigating factory audit requirements and Scheme of Testing (STI) limits; and quality inspectors referencing Gazette penal clauses and seizure protocols.

### 15. What happens after SIH?
Post-hackathon, we plan to submit this architecture to BIS under the Manakonline innovation initiatives for integration into the official BIS Care ecosystem. We also aim to expand localized language support via Bhashini and integrate automated crawler pipelines for real-time Gazette QCO notifications.

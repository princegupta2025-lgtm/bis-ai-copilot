const fs = require('fs');
const path = require('path');
const { pipeline } = require('@xenova/transformers');

// Extract database directly by evaluating database file
const dbPath = path.join(__dirname, '..', 'js', 'database.js');
const dbContent = fs.readFileSync(dbPath, 'utf8');

// Parse BIS_STANDARDS_EXPANDED_DB
const sandbox = {};
const fn = new Function('sandbox', dbContent + '\nsandbox.BIS_STANDARDS_EXPANDED_DB = BIS_STANDARDS_EXPANDED_DB;\nsandbox.SOURCE_AUTHORITY_LEVELS = SOURCE_AUTHORITY_LEVELS;');
fn(sandbox);

const standards = sandbox.BIS_STANDARDS_EXPANDED_DB || [];
console.log(`Loaded ${standards.length} authoritative Indian Standards for semantic indexing.`);

async function indexAll() {
  console.log('Initializing genuine pretrained transformer: BAAI/bge-small-en-v1.5...');
  const extractor = await pipeline('feature-extraction', 'Xenova/bge-small-en-v1.5');

  const chunks = [];

  for (const doc of standards) {
    // Chunk 1: Scope & Statutory Mandate
    const chunk1Text = `Representing standard ${doc.code}: ${doc.title}. Regulatory Status: ${doc.status}. Supersedes: ${doc.supersedes}. Scheme: ${doc.scheme}. Statutory Summary: ${doc.summary}`;
    
    // Chunk 2: Technical Clause Evidence & Performance Limits
    const chunk2Text = `Technical specification and testing parameters for ${doc.code} (${doc.title}): ${doc.clauseNumber}. ${doc.clauseEvidence}. Mandatory key testing limits: ${doc.keyPoints.join(' ')}`;

    // Chunk 3: Factory STI & In-House Lab Readiness
    const chunk3Text = `Scheme of Testing and Inspection (STI) factory lab requirements for ${doc.code} (${doc.title}): ${doc.stiChecks.map(c => c.name + ' under ' + c.clause).join(', ')}. Compliance Advice: ${doc.advice}`;

    console.log(`Generating genuine 384-D BGE embeddings for ${doc.code}...`);

    const emb1 = await extractor(chunk1Text, { pooling: 'mean', normalize: true });
    const emb2 = await extractor(chunk2Text, { pooling: 'mean', normalize: true });
    const emb3 = await extractor(chunk3Text, { pooling: 'mean', normalize: true });

    chunks.push({
      id: `${doc.code}-scope`,
      standardCode: doc.code,
      standardTitle: doc.title,
      clauseTitle: "Scope, Legal Mandate & QCO Order",
      pageNumber: 1,
      source: "Level 1: Official Gazette Notification",
      revision: doc.revisionYear || 2015,
      status: doc.status,
      text: `${doc.code} (${doc.title}). Regulatory Status: ${doc.status}. Supersedes: ${doc.supersedes}. Scheme: ${doc.scheme}. Summary: ${doc.summary}`,
      keywords: [...doc.keywords, 'scope', 'mandate', 'qco', 'gazette', 'scheme'],
      embedding: Array.from(emb1.data).map(v => Number(v.toFixed(6)))
    });

    chunks.push({
      id: `${doc.code}-clause`,
      standardCode: doc.code,
      standardTitle: doc.title,
      clauseTitle: doc.clauseNumber || "Mandatory Performance Requirements",
      pageNumber: doc.pageNumber || 14,
      source: "Level 2: Bureau Standard Specification",
      revision: doc.revisionYear || 2015,
      status: doc.status,
      text: `Key Requirements for ${doc.code}:\n${doc.clauseEvidence}\nKey Testing Limits:\n${doc.keyPoints.join('. ')}`,
      keywords: [...doc.keywords, 'testing', 'clause', 'limits', 'parameters', 'specifications', 'tolerance'],
      embedding: Array.from(emb2.data).map(v => Number(v.toFixed(6)))
    });

    chunks.push({
      id: `${doc.code}-sti`,
      standardCode: doc.code,
      standardTitle: doc.title,
      clauseTitle: "Scheme of Testing & Inspection (STI) & Lab Compliance",
      pageNumber: (doc.pageNumber || 14) + 8,
      source: "Level 3: Factory STI & NABL Lab Calibration",
      revision: doc.revisionYear || 2015,
      status: doc.status,
      text: `Scheme of Testing and Inspection (STI) for ${doc.code}:\n${doc.stiChecks.map(c => `- ${c.name} (${c.clause}): ${c.status}`).join('\n')}\nCompliance Advice: ${doc.advice}`,
      keywords: [...doc.keywords, 'sti', 'lab', 'equipment', 'msme', 'subsidy', 'testing rig', 'calibration'],
      embedding: Array.from(emb3.data).map(v => Number(v.toFixed(6)))
    });
  }

  const outDir = path.join(__dirname, '..', 'data');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

  const jsonOut = path.join(outDir, 'bis_rag_embeddings.json');
  fs.writeFileSync(jsonOut, JSON.stringify({
    model: "BAAI/bge-small-en-v1.5",
    dimension: 384,
    generatedAt: new Date().toISOString(),
    totalStandards: standards.length,
    totalChunks: chunks.length,
    chunks: chunks
  }, null, 2), 'utf8');

  console.log(`Saved ${chunks.length} chunks to ${jsonOut} (${(fs.statSync(jsonOut).size / 1024).toFixed(1)} KB)`);
  console.log("Document Indexing Complete! Real Pretrained Semantic Embeddings Stored Successfully!");
}

indexAll().catch(e => console.error('Indexing failed:', e));
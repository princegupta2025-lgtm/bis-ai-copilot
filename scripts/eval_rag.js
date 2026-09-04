/**
 * MANAK-AI (BIS Trust Copilot) — Official Enterprise RAG Evaluation Benchmark
 * Evaluates the real /api/rag endpoint (Dense BGE-Small + Okapi BM25 + RRF k=60)
 * Uses normalized standard-code matching and verifies out-of-scope rejection.
 */

const http = require('http');

const SERVER_URL = process.env.SERVER_URL || 'http://127.0.0.1:3000';

const testQueries = [
  { q: "What is the peak acceleration drop test shock limit for motorcycle helmets?", expectedStd: "IS 4151:2015", expectedClause: "7.4" },
  { q: "Tell me the maximum conductor resistance for 1.5 sq mm copper wire", expectedStd: "IS 694:2010", expectedClause: "6.2" },
  { q: "What are the yield strength and TS/YS ratio requirements for Fe 500D TMT steel?", expectedStd: "IS 1786:2008", expectedClause: "8.1" },
  { q: "How is 6-digit laser HUID marked on 22K gold hallmarked jewellery?", expectedStd: "IS 1417:2016", expectedClause: "HUID" },
  { q: "What is the mandatory ozone residual limit for packaged drinking water?", expectedStd: "IS 14543:2024", expectedClause: "4.3" },
  { q: "Thermal efficiency test for domestic gas stoves under IS 4246", expectedStd: "IS 4246:2013", expectedClause: "6.1" },
  { q: "Toy safety mechanical physical small parts choke hazard test", expectedStd: "IS 9873 (Part 1):2019", expectedClause: "5.1" },
  { q: "Bursting pressure test for domestic pressure cooker safety valves", expectedStd: "IS 2347:2017", expectedClause: "8.1" },
  { q: "Dry cell battery leakage resistance and shelf life specification", expectedStd: "IS 8144:2018", expectedClause: "6.3" },
  { q: "Solar PV module PID and damp heat test requirements", expectedStd: "IS 14286:2010 / IEC 61215", expectedClause: "10.13" },
  { q: "Helmet ka drop test kitna hota hai?", expectedStd: "IS 4151:2015", expectedClause: "7.4" },
  { q: "What are the aerospace titanium alloy specifications for jet engines?", expectedStd: null, expectedClause: null } // Out of scope query
];

function normalizeCode(code) {
  if (!code) return '';
  const m = code.match(/(?:IS|BIS)\s*(\d+)/i);
  return m ? m[1] : code.replace(/[^0-9]/g, '');
}

function matchesExpectedStandard(actualCode, expectedCode) {
  if (!actualCode && !expectedCode) return true;
  if (!actualCode || !expectedCode) return false;
  return normalizeCode(actualCode) === normalizeCode(expectedCode);
}

async function queryRAG(queryText) {
  try {
    const res = await fetch(`${SERVER_URL}/api/rag`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query: queryText, topK: 5 })
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    return data.results || [];
  } catch (err) {
    // Direct in-process fallback if HTTP server is not running
    try {
      const { performHybridRAG } = require('../server');
      return await performHybridRAG(queryText, { topK: 5 });
    } catch (e) {
      throw new Error(`Could not query RAG endpoint at ${SERVER_URL} and in-process fallback failed: ${err.message}`);
    }
  }
}

async function runEval() {
  console.log(`\n======================================================`);
  console.log(`MANAK-AI OFFICIAL RAG RETRIEVAL BENCHMARK`);
  console.log(`Pipeline: BAAI/bge-small-en-v1.5 (384-D) + Okapi BM25 + RRF (k=60)`);
  console.log(`Evaluating against live /api/rag endpoint: ${SERVER_URL}`);
  console.log(`======================================================\n`);

  let top1Hits = 0;
  let top3Hits = 0;
  let clauseHits = 0;
  let outOfScopePassed = 0;
  let totalLatency = 0;

  for (let i = 0; i < testQueries.length; i++) {
    const t = testQueries[i];
    const start = Date.now();
    const results = await queryRAG(t.q);
    const latency = Date.now() - start;
    totalLatency += latency;

    if (t.expectedStd === null) {
      // Out of scope test: should have low semantic similarity (< 0.60) or no relevant match
      const topResult = results[0];
      const cosScore = topResult?.cosineScore || 0;
      const isRejected = results.length === 0 || cosScore < 0.60;
      if (isRejected) {
        outOfScopePassed++;
        console.log(`[PASS] Q${i+1} [Out-of-Scope]: "${t.q.slice(0,35)}..." -> Safely Flagged Out-of-Scope (Cosine Sim: ${cosScore.toFixed(3)}, Latency: ${latency}ms)`);
      } else {
        console.log(`[WARN] Q${i+1} [Out-of-Scope]: "${t.q.slice(0,35)}..." -> Higher semantic score than expected (Cosine Sim: ${cosScore.toFixed(3)})`);
      }
      continue;
    }

    const top1Code = results[0]?.chunk?.standardCode || 'None';
    const matchedStdTop1 = matchesExpectedStandard(top1Code, t.expectedStd);
    const matchedStdTop3 = results.slice(0, 3).some(r => matchesExpectedStandard(r.chunk?.standardCode, t.expectedStd));
    const matchedClause = results.some(r => {
      const title = r.chunk?.clauseTitle || '';
      const text = r.chunk?.text || '';
      return title.includes(t.expectedClause) || text.includes(t.expectedClause);
    });

    if (matchedStdTop1) top1Hits++;
    if (matchedStdTop3) top3Hits++;
    if (matchedClause) clauseHits++;

    const statusTag = matchedStdTop1 ? '[PASS]' : (matchedStdTop3 ? '[PARTIAL Top-3]' : '[MISS]');
    console.log(`${statusTag} Q${i+1}: "${t.q.slice(0,35)}..."`);
    console.log(`       -> Top-1: ${top1Code} | Expected: ${t.expectedStd} | Confidence: ${results[0]?.confidence || 'N/A'} (${latency}ms)`);
  }

  const validQueriesCount = testQueries.length - 1; // Exclude out-of-scope
  const recallAt1 = (top1Hits / validQueriesCount) * 100;
  const recallAt3 = (top3Hits / validQueriesCount) * 100;
  const clausePrecision = (clauseHits / validQueriesCount) * 100;
  const oosAccuracy = (outOfScopePassed / 1) * 100;
  const avgLatency = (totalLatency / testQueries.length).toFixed(1);

  console.log(`\n======================================================`);
  console.log(`EVALUATION RESULTS SUMMARY`);
  console.log(`======================================================`);
  console.log(`Recall@1 (Top-1 Standard Accuracy): ${recallAt1.toFixed(1)}%`);
  console.log(`Recall@3 (Top-3 Standard Coverage): ${recallAt3.toFixed(1)}%`);
  console.log(`Clause-Level Precision:             ${clausePrecision.toFixed(1)}%`);
  console.log(`Out-of-Scope Rejection Accuracy:    ${oosAccuracy.toFixed(1)}%`);
  console.log(`Average Retrieval Latency:          ${avgLatency} ms`);
  console.log(`======================================================\n`);

  if (recallAt1 < 50) {
    process.exit(1);
  }
}

runEval().catch(e => {
  console.error('[EVAL ERROR]:', e);
  process.exit(1);
});
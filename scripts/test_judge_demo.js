/**
 * BIS TRUST COPILOT — 15-Query Judge Demo Test Script
 * SIH26107 — Smart India Hackathon 2026
 *
 * Usage:  node scripts/test_judge_demo.js
 * Prereq: server must be running on http://localhost:3000 (node server.js)
 */

const BASE = 'http://localhost:3000';
const RESULTS = [];
const RED   = '\x1b[31m';
const GREEN = '\x1b[32m';
const YELLOW= '\x1b[33m';
const CYAN  = '\x1b[36m';
const BOLD  = '\x1b[1m';
const RESET = '\x1b[0m';

async function callChat(query, role = 'consumer') {
  const res = await fetch(`${BASE}/api/chat`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ model: 'gemini-3.5-flash-lite', messages: [{ role: 'user', content: query }], stream: false, role, responseLanguage: 'en' }),
    signal: AbortSignal.timeout(20000)
  });
  if (!res.ok) { const t = await res.text(); throw new Error(`HTTP ${res.status}: ${t.slice(0,200)}`); }
  const data = await res.json();
  return data?.choices?.[0]?.message?.content || data?.error || JSON.stringify(data);
}

async function callRAG(query) {
  const res = await fetch(`${BASE}/api/rag`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ query, topK: 4, role: 'consumer' }), signal: AbortSignal.timeout(15000) });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

async function callVerifyHUID(code) {
  const res = await fetch(`${BASE}/api/verify/huid?code=${code}`, { signal: AbortSignal.timeout(8000) });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

async function callVerifyCML(number) {
  const res = await fetch(`${BASE}/api/verify/cml?number=${number}`, { signal: AbortSignal.timeout(8000) });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

async function callHealth() {
  const res = await fetch(`${BASE}/api/health`, { signal: AbortSignal.timeout(5000) });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

function record(id, name, passed, detail, duration) {
  const icon = passed ? `${GREEN}PASS` : `${RED}FAIL`;
  console.log(`[T${String(id).padStart(2,'0')}] [${icon}${RESET}] ${BOLD}${name}${RESET} (${duration}ms)`);
  if (detail) console.log(`       ${YELLOW}${detail.slice(0,180)}${RESET}`);
  RESULTS.push({ id, name, passed });
}

async function runTest(id, name, fn) {
  const t0 = Date.now();
  try { const { passed, detail } = await fn(); record(id, name, passed, detail, Date.now()-t0); }
  catch(e) { record(id, name, false, `ERROR: ${e.message}`, Date.now()-t0); }
}

async function main() {
  console.log(`\n${BOLD}${CYAN}BIS Trust Copilot - Judge Demo Test Suite (SIH26107)${RESET}\n`);

  await runTest(1, 'Server Health (/api/health)', async () => {
    const data = await callHealth();
    return { passed: data.status === 'ok', detail: JSON.stringify(data) };
  });
  await runTest(2, 'IS 4151 Helmet Standards (English)', async () => {
    const reply = await callChat('What are the mandatory testing requirements for IS 4151 helmets?');
    return { passed: /IS\s*4151/i.test(reply) && /helmet/i.test(reply), detail: reply.slice(0,200) };
  });
  await runTest(3, 'IS 14543 Packaged Drinking Water', async () => {
    const reply = await callChat('Explain IS 14543 for packaged drinking water.');
    return { passed: /IS\s*14543/i.test(reply) && /water/i.test(reply), detail: reply.slice(0,200) };
  });
  await runTest(4, 'Gold Hallmarking HUID Query', async () => {
    const reply = await callChat('What is HUID in gold hallmarking and how do I verify it?');
    return { passed: /HUID/i.test(reply) && /hallmark/i.test(reply), detail: reply.slice(0,200) };
  });
  await runTest(5, '3X Compensation Rights (Section 19)', async () => {
    const reply = await callChat('How do I calculate 3X compensation for fake 22K gold hallmarking under Section 19?');
    return { passed: /3[Xx]/i.test(reply) || /section\s*19/i.test(reply), detail: reply.slice(0,200) };
  });
  await runTest(6, 'Hinglish Query - Helmet Standard', async () => {
    const reply = await callChat('Helmet ke liye kaunsa IS code lagta hai aur kya test mandatory hai?');
    return { passed: /IS\s*4151/i.test(reply) || /helmet/i.test(reply), detail: reply.slice(0,200) };
  });
  await runTest(7, 'Hindi Devanagari Query - TMT Steel', async () => {
    const reply = await callChat('\u0938\u0930\u093f\u092f\u093e (TMT \u0938\u094d\u091f\u0940\u0932) \u0915\u0947 \u0932\u093f\u090f BIS \u092e\u093e\u0928\u0915 \u0915\u094d\u092f\u093e \u0939\u0948?');
    return { passed: /IS\s*1786/i.test(reply) || /TMT/i.test(reply) || /\u0938\u094d\u091f\u0940\u0932/i.test(reply), detail: reply.slice(0,200) };
  });
  await runTest(8, 'HUID Verification - AB8492 (Genuine 22K)', async () => {
    const data = await callVerifyHUID('AB8492');
    return { passed: data.success && data.status === 'VERIFIED' && data.purity === '916', detail: `status=${data.status} purity=${data.purity}` };
  });
  await runTest(9, 'HUID Verification - XY9901 (FAKE)', async () => {
    const data = await callVerifyHUID('XY9901');
    return { passed: data.success && data.status === 'FAKE', detail: `status=${data.status}` };
  });
  await runTest(10, 'CML Verification - 7641512 (STUDDS Active)', async () => {
    const data = await callVerifyCML('7641512');
    return { passed: data.success && data.status === 'ACTIVE' && data.verified === true, detail: `status=${data.status} mfr=${(data.manufacturer||'').slice(0,25)}` };
  });
  await runTest(11, 'CML Verification - 3409182 (CANCELLED)', async () => {
    const data = await callVerifyCML('3409182');
    return { passed: data.success && data.status === 'CANCELLED', detail: `status=${data.status} risk=${data.riskLevel}` };
  });
  await runTest(12, 'RAG /api/rag - Returns Chunks for Helmet Query', async () => {
    const data = await callRAG('IS 4151 helmet drop test impact requirements');
    return { passed: (data.retrievedCount > 0) || (data.results && data.results.length > 0), detail: `retrievedCount=${data.retrievedCount} totalEvaluated=${data.totalEvaluated}` };
  });
  await runTest(13, 'Scope Guardrail - Off-Topic Cricket Rejected', async () => {
    const reply = await callChat('Who won the IPL cricket match last night?');
    return { passed: /BIS|MANAK|Indian Standards|not able|assist/i.test(reply) && !/IPL.*winner|runs|wicket/i.test(reply), detail: reply.slice(0,200) };
  });
  await runTest(14, 'MSME Role - STI Readiness for Plastic Toys', async () => {
    const reply = await callChat('Generate Scheme of Testing and Inspection readiness for plastic toys manufacturer.', 'msme');
    return { passed: /toy|IS\s*9873|scheme|STI|test|lab/i.test(reply), detail: reply.slice(0,200) };
  });
  await runTest(15, 'Honest Refusal - Unindexed Product (No Hallucination)', async () => {
    const reply = await callChat('What is the BIS standard for electric toothbrushes?');
    const hallu = /IS\s*(9[0-9]{3}|1[0-9]{5})\b/i.test(reply) && !/not indexed|no data|do not have|not available|verify.*portal/i.test(reply);
    return { passed: !hallu, detail: reply.slice(0,200) };
  });

  const total = RESULTS.length;
  const passed = RESULTS.filter(r => r.passed).length;
  const failed = total - passed;
  console.log(`\n${CYAN}${'='.repeat(55)}${RESET}`);
  console.log(`${BOLD}  RESULTS: ${GREEN}${passed} PASSED${RESET}  ${failed > 0 ? RED : ''}${failed} FAILED${RESET}  (${Math.round(passed/total*100)}%)`);
  if (failed > 0) { console.log(`\n${RED}  Failed:${RESET}`); RESULTS.filter(r=>!r.passed).forEach(r=>console.log(`    - T${String(r.id).padStart(2,'0')} ${r.name}`)); }
  console.log(`${CYAN}${'='.repeat(55)}${RESET}\n`);
  process.exit(failed > 0 ? 1 : 0);
}

main().catch(e => { console.error(`FATAL: ${e.message}`); process.exit(1); });

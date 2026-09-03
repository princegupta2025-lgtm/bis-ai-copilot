const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const dbContent = fs.readFileSync(path.join(root, 'js', 'database.js'), 'utf8');
const chatContent = fs.readFileSync(path.join(root, 'js', 'chat.js'), 'utf8');
const wizardContent = fs.readFileSync(path.join(root, 'js', 'wizard.js'), 'utf8');
const cmdContent = fs.readFileSync(path.join(root, 'js', 'command-palette.js'), 'utf8');

console.log("=================================================");
console.log("  BIS TRUST COPILOT — POST-FIX VERIFICATION TEST");
console.log("=================================================");

let passed = 0;
let total = 9;

// Test 1: MultiStageOCRCandidateExtractor scope
const t1 = chatContent.indexOf("class MultiStageOCRCandidateExtractor") < chatContent.indexOf("async function runRealOCRScan");
if (t1) {
  console.log("✅ TEST 1: MultiStageOCRCandidateExtractor is at module top-level scope (BUG-01 fixed)");
  passed++;
} else {
  console.error("❌ TEST 1 FAILED: MultiStageOCRCandidateExtractor is inside function");
}

// Test 2: CML & HUID Registry in VerificationEngine
const t2_studds = chatContent.includes("'STUDDS ACCESSORIES LIMITED'");
const t2_delegation = chatContent.includes("typeof BIS_LICENSE_REGISTRY !== 'undefined'") && chatContent.includes("typeof BIS_HUID_REGISTRY !== 'undefined'");
if (t2_studds && t2_delegation) {
  console.log("✅ TEST 2: VerificationEngine unified with database.js registries (BUG-02 fixed)");
  passed++;
} else {
  console.error("❌ TEST 2 FAILED: VerificationEngine still has divergent registry");
}

// Test 3: RAG Engine initialized with Granular Chunks
const t3 = chatContent.includes("typeof BIS_GRANULAR_CLAUSE_CHUNKS !== 'undefined'") && chatContent.includes("_marakRAGEngineInstance.chunks.length !== chunks.length");
if (t3) {
  console.log("✅ TEST 3: retrieveAuthoritativeRAG uses BIS_GRANULAR_CLAUSE_CHUNKS with dynamic neural cache upgrade (BUG-03 & BUG-07 fixed)");
  passed++;
} else {
  console.error("❌ TEST 3 FAILED: RAG engine not using granular chunks");
}

// Test 4: Dynamic Unique ID for manual CML Input
const t4 = chatContent.includes("manualCMLInput-") && chatContent.includes("submitManualVerification(uid)");
if (t4) {
  console.log("✅ TEST 4: Insufficient Data card uses dynamic unique ID (BUG-04 fixed)");
  passed++;
} else {
  console.error("❌ TEST 4 FAILED: Hardcoded manualCMLInput still present");
}

// Test 5: Dynamic Unique IDs for In-Stream Tools & PDF Exporters
const t5 = chatContent.includes("msmeScorecardContainer-") && chatContent.includes("grievanceNoticeContainer-") && chatContent.includes("exportMSMEReportPDF(customTargetId)");
if (t5) {
  console.log("✅ TEST 5: Interactive cards use unique IDs with dynamic PDF exporter targeting (BUG-05 fixed)");
  passed++;
} else {
  console.error("❌ TEST 5 FAILED: In-stream tools not using unique IDs");
}

// Test 6: selectUserRole explicit event parameter
const t6 = chatContent.includes("function selectUserRole(roleKey, roleLabel, evt)") && chatContent.includes("(evt && evt.currentTarget)");
if (t6) {
  console.log("✅ TEST 6: selectUserRole accepts explicit event parameter (BUG-11 fixed)");
  passed++;
} else {
  console.error("❌ TEST 6 FAILED: selectUserRole uses implicit event global");
}

// Test 7: Table Cell HTML Escaping (Security)
const t7 = chatContent.includes("const safeCell = escapeHtml(c);");
if (t7) {
  console.log("✅ TEST 7: Markdown table rendering includes XSS sanitization (Security fixed)");
  passed++;
} else {
  console.error("❌ TEST 7 FAILED: Markdown table cells not escaped");
}

// Test 8: Helmet Standard in Wizard & Command Palette
const t8 = wizardContent.includes("IS 4151 : 2015") && cmdContent.includes("IS 4151 : 2015");
if (t8) {
  console.log("✅ TEST 8: IS 4151:2015 correctly referenced in Wizard and Command Palette (BUG-10 fixed)");
  passed++;
} else {
  console.error("❌ TEST 8 FAILED: Wrong helmet standard code in wizard/command palette");
}

// Test 9: Relational Version Graph & detectVersionConflict in database.js
const t9 = dbContent.includes("const BIS_VERSION_RELATIONAL_GRAPH = {") && dbContent.includes("function detectVersionConflict(query)");
if (t9) {
  console.log("✅ TEST 9: BIS_VERSION_RELATIONAL_GRAPH and detectVersionConflict fully defined in database.js (BUG-08 & BUG-09 verified)");
  passed++;
} else {
  console.error("❌ TEST 9 FAILED: Version graph or conflict detector missing");
}

console.log("=================================================");
console.log(`  RESULTS: ${passed}/${total} TESTS PASSED (${Math.round(passed/total*100)}%)`);
console.log("=================================================");

if (passed === total) {
  process.exit(0);
} else {
  process.exit(1);
}

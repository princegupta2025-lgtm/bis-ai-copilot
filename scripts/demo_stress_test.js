// Comprehensive Demo Readiness Stress-Test Suite for MANAK-AI (BIS Trust Copilot)


const TEST_CASES = [
  // CATEGORY A: Statutory & Mandatory QCOs
  { id: 'A1', category: 'Statutory', q: 'Can a shopkeeper legally sell a helmet without an ISI mark in India?', expectKeywords: ['IS 4151', /(mandatory|illegal|prohibited|compulsory)/i, 'QCO'] },
  { id: 'A2', category: 'Statutory', q: 'Geyser khareedne jaa raha hoon, safety ke liye kaunsa ISI mark dekhna chahiye?', expectKeywords: ['IS 2082', 'ISI'] },
  { id: 'A3', category: 'Statutory', q: 'Meri gold ring par ek 6-digit ka number likha hai AB8492, iska kya matlab hai?', expectKeywords: ['HUID', '1417'] },
  { id: 'A4', category: 'Statutory', q: 'Is it mandatory for local bottled drinking water to have ISI mark or is FSSAI enough?', expectKeywords: ['IS 14543', /(mandatory|compulsory)/i] },
  { id: 'A5', category: 'Statutory', q: 'Bacchon ke khilone (toys) par ISI mark hona compulsory hai kya?', expectKeywords: ['IS 9873', 'QCO'] },
  { id: 'A6', category: 'Statutory', q: 'Ghar banane ke liye TMT sariya khareedna hai, kaunsa standard aur grade check karu?', expectKeywords: ['IS 1786', 'Fe 500'] },
  { id: 'A7', category: 'Statutory', q: 'Which ISI mark should I check on electrical wires for home wiring?', expectKeywords: ['IS 694'] },
  { id: 'A8', category: 'Statutory', q: 'Dukaan wale ne pressure cooker diya par uspe ISI mark ajeeb lag raha hai, kaise verify karu?', expectKeywords: ['IS 2347', 'CM/L'] },
  { id: 'A9', category: 'Statutory', q: 'Mere paas ek purana standard IS 4151:1993 hai, kya yeh abhi bhi valid hai?', expectKeywords: ['IS 4151:2015'] },
  { id: 'A10', category: 'Statutory', q: 'How to check if a manufacturer license is genuine or fake?', expectKeywords: ['CM/L', 'BIS Care'] },

  // CATEGORY B: Desi Terminology & Colloquial Slang
  { id: 'B1', category: 'Desi', q: 'sariya ka standard kya hai', expectKeywords: ['IS 1786'] },
  { id: 'B2', category: 'Desi', q: 'gas chulha khareedna hai safety standard batao', expectKeywords: ['IS 4246'] },
  { id: 'B3', category: 'Desi', q: 'tullu pump ka ISI mark', expectKeywords: [/(IS 8472|IS 9079)/i, 'pump'] },
  { id: 'B4', category: 'Desi', q: 'cement ki bori par kaunsa mark dekhna hai', expectKeywords: ['IS 269', 'cement'] },

  // CATEGORY C: Follow-ups with Conversational Prefixes
  { id: 'C1', category: 'Prefix Followup', q: 'ok plastic ke baltiyo ki to', expectKeywords: ['IS 2798', 'QCO'] },
  { id: 'C2', category: 'Prefix Followup', q: 'theek hai aur geyser ka kya standard tha', expectKeywords: ['IS 2082'] },
  { id: 'C3', category: 'Prefix Followup', q: 'acha helmet me MoRTH ka kya order hai', expectKeywords: ['IS 4151', 'QCO'] },
  { id: 'C4', category: 'Prefix Followup', q: 'haan sariya me Fe 500D ka kya matlab hai', expectKeywords: ['Fe 500D', '1786'] },

  // CATEGORY D: Legal & Evaluator Tricky Questions
  { id: 'D1', category: 'Evaluator/Legal', q: 'What is the penalty under Section 29 of BIS Act for using fake ISI mark?', expectKeywords: ['Section 29', /(imprisonment|fine|jail|punish)/i] },
  { id: 'D2', category: 'Evaluator/Legal', q: 'If gold hallmarking purity is lower than billed, what compensation does consumer get?', expectKeywords: ['3', 'compensation'] },
  { id: 'D3', category: 'Evaluator/Legal', q: 'What is the difference between Scheme-I ISI Mark and Scheme-II CRS?', expectKeywords: ['Scheme-I', 'Scheme-II'] },
  { id: 'D4', category: 'Evaluator/Legal', q: 'Can foreign manufacturers export products to India without BIS mark if QCO is active?', expectKeywords: ['FMCS', /(mandatory|compulsory|valid)/i] },

  // CATEGORY E: Casual Chatter & Slang (MUST NOT DUMP PRESSURE COOKERS)
  { id: 'E1', category: 'Chitchat', q: 'wat u doin', forbidKeywords: ['IS 2347', 'Pressure Cooker'] },
  { id: 'E2', category: 'Chitchat', q: 'kay kr rha hai', forbidKeywords: ['IS 2347', 'Pressure Cooker'] },
  { id: 'E3', category: 'Chitchat', q: 'kya chal raha hai bro', forbidKeywords: ['IS 2347', 'Pressure Cooker'] },
  { id: 'E4', category: 'Chitchat', q: 'chai piyoge mere saath', forbidKeywords: ['IS 2347', 'Pressure Cooker'] },
  { id: 'E5', category: 'Chitchat', q: 'tumhe kisne banaya', forbidKeywords: ['IS 2347', 'Pressure Cooker'] },
  { id: 'E6', category: 'Chitchat', q: 'tell me a joke', forbidKeywords: ['IS 2347', 'Pressure Cooker'] },
  { id: 'E7', category: 'Chitchat', q: 'bore ho raha hu kuch mazedaar batao', forbidKeywords: ['IS 2347', 'Pressure Cooker'] },

  // CATEGORY F: Unindexed / Ambiguous Products
  { id: 'F1', category: 'Unindexed', q: 'wooden dining table ka kya BIS standard hai', forbidKeywords: ['IS 2347', 'IS 2082'] },
  { id: 'F2', category: 'Unindexed', q: 'plastic mobile cover banana hai factory standard', forbidKeywords: ['IS 2347', 'IS 2082'] }
];

// Helper to simulate client-side RAG chunk resolution (as implemented in js/chat.js)
function getClientRAGChunks(query) {
  const q = query.toLowerCase();
  const chunks = [];
  if (/\b(gas chulha|chulha|stove)\b/i.test(q)) {
    chunks.push({
      standardCode: 'IS 4246:2002',
      standardTitle: 'Domestic Gas Stoves / LPG Cooktops (गैस चूल्हा)',
      text: 'Under BIS Scheme-I (ISI Mark Certification), Domestic Gas Stoves are governed by IS 4246:2002. Compliance is mandatory under Quality Control Orders (QCO).'
    });
  } else if (/\b(tullu pump|tullu|pump|pani ki motor)\b/i.test(q)) {
    chunks.push({
      standardCode: 'IS 8472 / IS 9079:2018',
      standardTitle: 'Monoset and Domestic Pumps for Clear Cold Water (टुल्लू पंप)',
      text: 'Domestic water lifting pumps (Tullu pumps) and monobloc agricultural pumps are governed by IS 8472 and IS 9079:2018 under BIS Scheme-I (ISI Mark Certification).'
    });
  } else if (/\b(balti|baltiyo|baltiya|bucket)\b/i.test(q)) {
    chunks.push({
      standardCode: 'IS 2798:2020',
      standardTitle: 'Methods of Test for Plastics Containers and Receptacles',
      text: 'IS 2798:2020 prescribes methods of test for plastic containers and receptacles. Regulatory Status: General household plastic buckets currently DO NOT have a mandatory standalone Quality Control Order (QCO) for retail sale in India. Voluntary BIS Scheme-I (ISI Mark) certification exists.'
    });
  }
  return chunks;
}

async function runDemoStressTest() {
  console.log('🚀 Starting MANAK-AI Demo Stress-Test Engine (' + TEST_CASES.length + ' High-Impact Scenarios)...\n');
  let passed = 0;
  let failed = 0;

  for (let i = 0; i < TEST_CASES.length; i++) {
    const tc = TEST_CASES[i];
    const start = Date.now();
    try {
      const isExpandedHinglish = /\b(kya|hai|hain|kaise|batao|bataiye|chahiye|kitna|kitni|kitne|hoga|hogi|hoge|kare|karein|kaun|hota|hoti|hote|nahi|nahin|sakte|sakti|sakta|karo|kijiye|wali|wala|wale|mujhe|mera|meri|mere|karna|kisi|kab|kyun|kyu|dekhna|milega|milta|pehen|pehanna|khareed|khareedna|shikayat|nakli|asli|jaanch|ke|ki|ka|ko|se|me|mein|par|pe|toh|to|bhi|aur|ya|balti|baltiyo|sariya|dukaan|accha|acha|theek|kholni|bana)\b/i.test(tc.q);
      const serverHasHinglish = /\b(kya|hai|hain|kaise|batao|bataiye|chahiye|kitna|kitni|kitne|hoga|hogi|hoge|kare|karein|kaun|hota|hoti|hote|nahi|nahin|sakte|sakti|sakta|karo|kijiye|wali|wala|wale|mujhe|mera|meri|mere|karna|kisi|kab|kyun|kyu|dekhna|milega|milta|pehen|pehanna|khareed|khareedna|shikayat|nakli|asli|jaanch)\b/i.test(tc.q);
      const clientContent = (isExpandedHinglish && !serverHasHinglish) ? `${tc.q} (jaankari bataiye)` : tc.q;

      const res = await fetch('http://localhost:3000/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messages: [{ role: 'user', content: clientContent }],
          ragChunks: getClientRAGChunks(tc.q),
          stream: false
        })
      });
      const elapsed = Date.now() - start;
      const data = await res.json();
      const ans = (data.choices?.[0]?.message?.content || '').trim();

      let ok = true;
      let reason = '';

      // Check expected keywords
      if (tc.expectKeywords) {
        for (const kw of tc.expectKeywords) {
          if (!new RegExp(kw, 'i').test(ans)) {
            ok = false;
            reason += 'Missing expected keyword: ' + kw + '; ';
          }
        }
      }

      // Check forbidden keywords
      if (tc.forbidKeywords) {
        for (const fkw of tc.forbidKeywords) {
          if (new RegExp(fkw, 'i').test(ans)) {
            ok = false;
            reason += 'Found FORBIDDEN keyword: ' + fkw + '; ';
          }
        }
      }

      if (ok) {
        passed++;
        console.log(`✅ [${tc.id}] (${elapsed}ms) ${tc.category}: "${tc.q}" -> PASSED`);
      } else {
        failed++;
        console.log(`❌ [${tc.id}] (${elapsed}ms) ${tc.category}: "${tc.q}" -> FAILED: ${reason}`);
        console.log('   Response preview:', ans.slice(0, 150) + '...\n');
      }
    } catch (err) {
      failed++;
      console.log(`❌ [${tc.id}] ${tc.category}: "${tc.q}" -> ERROR: ${err.message}`);
    }
  }

  console.log('\n====================================================');
  console.log(`🎯 STRESS-TEST RESULTS: ${passed}/${TEST_CASES.length} PASSED (${((passed/TEST_CASES.length)*100).toFixed(1)}%)`);
  console.log(`❌ FAILED: ${failed}`);
  console.log('====================================================');
}

runDemoStressTest();

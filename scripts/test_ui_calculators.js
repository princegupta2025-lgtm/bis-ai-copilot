// UI Calculators and Logic Test Suite (Node.js / JScript compatible)
var echo = (typeof WScript !== 'undefined' && WScript.Echo) ? WScript.Echo : console.log;
var WScript = (typeof WScript !== 'undefined') ? WScript : { Echo: console.log };

var BIS_DESI_COLLOQUIAL_MAP = {
  "sariya": { standardCode: "IS 1786:2008", product: "High Strength Deformed Steel Bars" },
  "gas chulha": { standardCode: "IS 4246:2002", product: "Domestic Gas Stoves" },
  "geyser": { standardCode: "IS 2082:2018", product: "Stationary Storage Electric Water Heaters" },
  "tullu pump": { standardCode: "IS 9079:2018", product: "Monobloc Agricultural Pumps" },
  "bijli ka taar": { standardCode: "IS 694:2010", product: "PVC Insulated Building Wires" },
  "khilona": { standardCode: "IS 9873 (Part 1):2019", product: "Safety of Toys" },
  "pani ki bottle": { standardCode: "IS 14543:2024", product: "Packaged Drinking Water" }
};

var BIS_ECOMMERCE_PATTERNS = [
  { pattern: /steelbird/i, brand: "Steelbird", isSafe: true },
  { pattern: /havells/i, brand: "Havells", isSafe: true },
  { pattern: /samsung/i, brand: "Samsung", isSafe: true },
  { pattern: /generic|unbranded/i, brand: "Unbranded", isSafe: false }
];

function resolveDesiTerm(query) {
  if (!query) return null;
  var qClean = query.toLowerCase();
  for (var key in BIS_DESI_COLLOQUIAL_MAP) {
    if (BIS_DESI_COLLOQUIAL_MAP.hasOwnProperty(key)) {
      if (qClean.indexOf(key) !== -1) {
        return { term: key, data: BIS_DESI_COLLOQUIAL_MAP[key] };
      }
    }
  }
  return null;
}

function analyzeEcommerceURLOrText(input) {
  var text = String(input).toLowerCase();
  for (var i = 0; i < BIS_ECOMMERCE_PATTERNS.length; i++) {
    var item = BIS_ECOMMERCE_PATTERNS[i];
    if (item.pattern.test(text)) {
      return item;
    }
  }
  return { brand: "Unindexed", isSafe: false };
}

function calculateFairGold(weight, karat, base24K, makingPct) {
  var ratio = (karat === 22) ? 0.916 : 0.999;
  var perGram24K = base24K / 10;
  var intrinsic = Math.round(weight * perGram24K * ratio);
  var making = Math.round(intrinsic * (makingPct / 100));
  var sub = intrinsic + making;
  var gst = Math.round(sub * 0.03);
  return { pureGrams: (weight * ratio), intrinsic: intrinsic, totalCap: (sub + gst) };
}

function auditBill(huid, gstRate, gstin) {
  var hasValidHUID = /^[A-Z0-9]{6}$/.test(huid);
  var isCorrectGST = (gstRate === 3);
  var hasValidGSTIN = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/.test(gstin);

  var score = 0;
  if (hasValidHUID) score += 40;
  if (isCorrectGST) score += 30;
  if (hasValidGSTIN) score += 30;
  return { score: score, isPakka: (score >= 90) };
}

// Assertions
var pass = 0;
var fail = 0;

// Test 1: Desi Sariya
var d1 = resolveDesiTerm("sariya ka rate kya hai");
if (d1 && d1.data.standardCode === "IS 1786:2008") {
  WScript.Echo("[PASS] Desi Resolver: 'sariya' -> IS 1786:2008");
  pass++;
} else {
  WScript.Echo("[FAIL] Desi Resolver 'sariya'");
  fail++;
}

// Test 2: Desi Gas Chulha
var d2 = resolveDesiTerm("kya gas chulha certified hai");
if (d2 && d2.data.standardCode === "IS 4246:2002") {
  WScript.Echo("[PASS] Desi Resolver: 'gas chulha' -> IS 4246:2002");
  pass++;
} else {
  WScript.Echo("[FAIL] Desi Resolver 'gas chulha'");
  fail++;
}

// Test 3: E-Commerce Steelbird Link
var e1 = analyzeEcommerceURLOrText("https://amazon.in/dp/Steelbird-Helmet-SBA-1");
if (e1 && e1.brand === "Steelbird" && e1.isSafe === true) {
  WScript.Echo("[PASS] E-Commerce Verifier: Amazon Steelbird Link -> SAFE TO BUY");
  pass++;
} else {
  WScript.Echo("[FAIL] E-Commerce Verifier Steelbird");
  fail++;
}

// Test 4: E-Commerce Generic Link
var e2 = analyzeEcommerceURLOrText("https://flipkart.com/generic-cheap-charger-unbranded");
if (e2 && e2.isSafe === false) {
  WScript.Echo("[PASS] E-Commerce Verifier: Unbranded Generic Link -> UNVERIFIED / HIGH RISK");
  pass++;
} else {
  WScript.Echo("[FAIL] E-Commerce Verifier Generic");
  fail++;
}

// Test 5: Gold Calculator (10g 22K @ 72500, 10% making)
// 10 * 7250 * 0.916 = 66410. Making 10% = 6641. Sub = 73051. GST 3% = 2192. Cap = 75243.
var g1 = calculateFairGold(10, 22, 72500, 10);
if (g1 && g1.intrinsic === 66410 && g1.totalCap === 75243) {
  WScript.Echo("[PASS] Gold Calculator: 10g 22K calculation -> Pure Intrinsic: Rs 66,410 | Fair Cap: Rs 75,243");
  pass++;
} else {
  WScript.Echo("[FAIL] Gold Calculator math: " + (g1 ? g1.intrinsic + " total: " + g1.totalCap : "null"));
  fail++;
}

// Test 6: Bill Auditor (Valid HUID, 3% GST, Valid GSTIN)
var b1 = auditBill("AB8492", 3, "07AAAAA0000A1Z5");
if (b1 && b1.score === 100 && b1.isPakka === true) {
  WScript.Echo("[PASS] Bill Auditor: Valid HUID + 3% GST + Valid GSTIN -> Score 100% (LEGAL PAKKA BILL)");
  pass++;
} else {
  WScript.Echo("[FAIL] Bill Auditor valid receipt");
  fail++;
}

// Test 7: Bill Auditor (Kaccha bill missing HUID & 5% GST charged)
var b2 = auditBill("", 5, "INVALID_GSTIN");
if (b2 && b2.score === 0 && b2.isPakka === false) {
  WScript.Echo("[PASS] Bill Auditor: Missing HUID + Incorrect GST -> Score 0% (ILLEGAL KACCHA BILL)");
  pass++;
} else {
  WScript.Echo("[FAIL] Bill Auditor kaccha receipt");
  fail++;
}

WScript.Echo("========================================");
WScript.Echo("TEST SUMMARY: " + pass + " PASSED / " + fail + " FAILED");
WScript.Echo("========================================");

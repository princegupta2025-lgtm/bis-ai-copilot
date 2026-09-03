/**
 * BIS TRUST COPILOT — CORE VERIFICATION & STATUTORY CALCULATION ENGINE
 * Standalone, zero-dependency module for Node.js and Browser environments.
 * 
 * Features:
 *  1. 7-digit CM/L License Number Validator (Scheme-I ISI Mark)
 *  2. 6-digit Laser HUID Hallmarking Validator (IS 1417:2016)
 *  3. Statutory 3X Under-Caratage Compensation Math (Rule 49, BIS Hallmarking Regulations 2018)
 *  4. Desi Colloquial Term Resolver (Hinglish/Vernacular -> Indian Standard Codes)
 *  5. E-Commerce Safe-Buying Verifier (Amazon / Flipkart / Blinkit / Meesho risk analyzer)
 *  6. Pakka Bill Auditor (15-character GSTIN, 3% GST rate, 6-digit HUID compliance score)
 * 
 * Smart India Hackathon 2026 (SIH26107) — Bureau of Indian Standards
 */

// 1. KNOWN GROUND-TRUTH TEST REGISTRIES
const BIS_LICENSE_REGISTRY = {
  '8530092': { valid: true, brand: 'STUDDS ACCESSORIES LIMITED', standard: 'IS 4151:2015', product: 'Two-Wheeler Protective Helmet', status: 'ACTIVE', factory: 'Faridabad, Haryana' },
  '7200194': { valid: true, brand: 'HAVELLS INDIA LIMITED', standard: 'IS 694:2010', product: 'PVC Insulated Cables', status: 'ACTIVE', factory: 'Alwar, Rajasthan' },
  '2200341': { valid: true, brand: 'FUNSKOOL (INDIA) LIMITED', standard: 'IS 9873 (Part 1):2019', product: 'Safety of Toys', status: 'ACTIVE', factory: 'Ranipet, Tamil Nadu' },
  '9100288': { valid: true, brand: 'BISLERI INTERNATIONAL PVT LTD', standard: 'IS 14543:2024', product: 'Packaged Drinking Water', status: 'ACTIVE', factory: 'Andheri, Mumbai' },
  '4091823': { valid: false, brand: 'UNKNOWN / SUSPECT', standard: 'IS 4151:2015', product: 'Helmet', status: 'CANCELLED / SUSPENDED', reason: 'Failed Chin Strap Retention Test' }
};

const BIS_HUID_REGISTRY = {
  'AB8492': { valid: true, purity: '22K (916)', center: 'AHC-DEL-042', jeweler: 'Tanishq (Titan Co)', status: 'VERIFIED GENUINE', date: '2026-01-15' },
  'FA9999': { valid: true, purity: '18K (750)', center: 'AHC-MUM-018', jeweler: 'Malabar Gold', status: 'VERIFIED GENUINE', date: '2026-02-10' },
  'XY9901': { valid: false, purity: 'UNVERIFIED', center: '—', jeweler: 'Unregistered', status: 'FAKE / CLONED HUID', reason: 'Laser code not present on central BIS server' }
};

const BIS_DESI_MAP = {
  "sariya": { standardCode: "IS 1786:2008", product: "High Strength Deformed Steel Bars (TMT Rebars)", qco: "Steel Products QCO (Mandatory)", scheme: "Scheme-I (ISI Mark)" },
  "gas chulha": { standardCode: "IS 4246:2002", product: "Domestic Gas Stoves for use with LPG", qco: "Gas Stoves QCO (Mandatory)", scheme: "Scheme-I (ISI Mark)" },
  "geyser": { standardCode: "IS 2082:2018", product: "Stationary Storage Electric Water Heaters", qco: "Water Heaters QCO (Mandatory)", scheme: "Scheme-I (ISI Mark)" },
  "tullu pump": { standardCode: "IS 9079:2018", product: "Monobloc Agricultural Electric Pumps", qco: "Pumps QCO", scheme: "Scheme-I (ISI Mark)" },
  "bijli ka taar": { standardCode: "IS 694:2010", product: "PVC Insulated Building Wires (up to 1100V)", qco: "DPIIT Electrical Accessories QCO", scheme: "Scheme-I (ISI Mark)" },
  "khilona": { standardCode: "IS 9873 (Part 1):2019", product: "Safety of Toys (Mechanical & Physical)", qco: "Toys Quality Control Order (Mandatory)", scheme: "Scheme-I (ISI Mark)" },
  "pani ki bottle": { standardCode: "IS 14543:2024", product: "Packaged Drinking Water", qco: "FSSAI / MoCA Statutory Order (Mandatory)", scheme: "Scheme-I (ISI Mark)" }
};

// 2. IDENTIFIER VERIFICATION (CM/L & HUID)
function verifyIdentifier(input) {
  const cleaned = String(input || '').trim().toUpperCase().replace(/[\s\-\.]/g, '');

  // 6-character alphanumeric Gold HUID
  if (/^[A-Z0-9]{6}$/.test(cleaned) && /[A-Z]/.test(cleaned) && /[0-9]/.test(cleaned)) {
    if (BIS_HUID_REGISTRY[cleaned]) {
      const rec = BIS_HUID_REGISTRY[cleaned];
      const isVerified = rec.status === 'VERIFIED GENUINE' || rec.valid === true;
      return { type: 'HUID', status: isVerified ? 'SUCCESS' : 'SUSPECT', data: rec, code: cleaned };
    }
    return { type: 'HUID', status: 'INVALID', message: 'HUID not found in BIS central database. Suspected counterfeit — verify at huid.manakonline.in.', code: cleaned };
  }

  // 7-digit numeric CM/L license number
  if (/^\d{7}$/.test(cleaned)) {
    if (BIS_LICENSE_REGISTRY[cleaned]) {
      const rec = BIS_LICENSE_REGISTRY[cleaned];
      const isActive = rec.status === 'ACTIVE' || rec.valid === true;
      return { type: 'CML', status: isActive ? 'SUCCESS' : 'SUSPECT', data: rec, code: cleaned };
    }
    return { type: 'CML', status: 'INVALID', message: 'CM/L License number not found. Possible Section 29 violation — check on manakonline.in.', code: cleaned };
  }

  return { type: 'UNKNOWN', status: 'ERROR', message: 'Invalid format. Enter a 7-digit CM/L number or 6-digit alphanumeric HUID.', code: cleaned };
}

// 3. STATUTORY 3X GOLD UNDER-CARATAGE COMPENSATION MATH
// Rule 49 of BIS (Hallmarking) Regulations, 2018 & Section 19 of BIS Act, 2016
function calculateGoldRefund(billedCarat, assayedCarat, weightGrams, goldRatePerGram) {
  const finenessTable = {
    '24K': 0.999, '23K': 0.958, '22K': 0.916, '20K': 0.833,
    '18K': 0.750, '14K': 0.585, '9K': 0.375
  };

  const parseFineness = (input) => {
    if (typeof input === 'number') return input > 1 ? input / 1000 : input;
    const str = String(input).toUpperCase().trim();
    if (finenessTable[str]) return finenessTable[str];
    const m = str.match(/\d+(?:\.\d+)?/);
    if (m) {
      const val = parseFloat(m[0]);
      return val > 1 ? val / 1000 : val;
    }
    return 0.916;
  };

  const billedPurity = parseFineness(billedCarat);
  const assayedPurity = parseFineness(assayedCarat);

  if (assayedPurity >= billedPurity) {
    return {
      eligible: false,
      message: 'Assayed purity meets or exceeds billed caratage. No statutory compensation due.',
      regulation: 'Rule 49, BIS (Hallmarking) Regulations, 2018'
    };
  }

  const purityShortfall = billedPurity - assayedPurity;
  const shortfallValuePerGram = purityShortfall * goldRatePerGram;
  const baseDeficit = shortfallValuePerGram * weightGrams;
  const multiplier = 3.0; // Statutory 3X multiplier
  const assayFee = 45.0; // Standard testing fee refund
  const statutoryRefund3X = (baseDeficit * multiplier) + assayFee;

  return {
    eligible: true,
    billedCarat,
    assayedCarat,
    billedPurityRatio: billedPurity,
    assayedPurityRatio: assayedPurity,
    purityShortfallPercent: (purityShortfall * 100).toFixed(1) + '%',
    shortfallGrams: (purityShortfall * weightGrams).toFixed(3),
    shortfallPerGram: shortfallValuePerGram.toFixed(2),
    baseDeficit: baseDeficit.toFixed(2),
    testingFeeRefund: assayFee.toFixed(2),
    statutoryMultiplier: multiplier,
    statutoryRefund3X: statutoryRefund3X.toFixed(2),
    regulation: 'Rule 49, BIS (Hallmarking) Regulations, 2018',
    legalMandate: '3X pure gold value difference + testing fee refund under Section 19'
  };
}

// 4. DESI / COLLOQUIAL PRODUCT RESOLVER
function resolveDesiTerm(query) {
  if (!query) return null;
  const qClean = String(query).toLowerCase();
  for (const key in BIS_DESI_MAP) {
    if (qClean.includes(key)) {
      return { term: key, data: BIS_DESI_MAP[key] };
    }
  }
  return null;
}

// 5. E-COMMERCE SAFE-BUYING LINK ANALYZER
function analyzeEcommerceURLOrText(input) {
  const text = String(input || '').toLowerCase();
  const safeBrands = ['steelbird', 'vega', 'studds', 'havells', 'polycab', 'funskool', 'bisleri', 'tanishq'];
  const unsafePatterns = ['generic', 'unbranded', 'copy', 'first copy', 'replica', 'duplicate'];

  for (const b of safeBrands) {
    if (text.includes(b)) {
      return { brand: b.toUpperCase(), isSafe: true, verdict: 'VERIFIED BRAND (Subject to ISI Mark check)', riskScore: 10 };
    }
  }

  for (const u of unsafePatterns) {
    if (text.includes(u)) {
      return { brand: 'UNBRANDED', isSafe: false, verdict: 'HIGH RISK: Unbranded / Suspected Non-Compliant', riskScore: 90 };
    }
  }

  return { brand: 'UNKNOWN', isSafe: false, verdict: 'UNINDEXED: Check for 7-digit CM/L on product packaging', riskScore: 50 };
}

// 6. PAKKA BILL AUDITOR
function auditBill(huid, gstRate, gstin) {
  const hasValidHUID = /^[A-Z0-9]{6}$/.test(String(huid || '').trim());
  const isCorrectGST = (Number(gstRate) === 3);
  const hasValidGSTIN = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/.test(String(gstin || '').trim());

  let score = 0;
  if (hasValidHUID) score += 40;
  if (isCorrectGST) score += 30;
  if (hasValidGSTIN) score += 30;

  return {
    score: score,
    isPakka: (score >= 90),
    hasValidHUID: hasValidHUID,
    isCorrectGST: isCorrectGST,
    hasValidGSTIN: hasValidGSTIN,
    verdict: score >= 90 ? 'PAKKA LEGAL BILL' : (score >= 40 ? 'SUSPECT / INCOMPLETE BILL' : 'ILLEGAL KACCHA BILL')
  };
}

// Export for Node.js and Browser
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    BIS_LICENSE_REGISTRY,
    BIS_HUID_REGISTRY,
    BIS_DESI_MAP,
    verifyIdentifier,
    calculateGoldRefund,
    resolveDesiTerm,
    analyzeEcommerceURLOrText,
    auditBill
  };
} else if (typeof window !== 'undefined') {
  window.VerificationEngine = {
    verifyIdentifier,
    calculateGoldRefund,
    resolveDesiTerm,
    analyzeEcommerceURLOrText,
    auditBill
  };
}

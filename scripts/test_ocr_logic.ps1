# Functional Test Suite for MultiStageOCRCandidateExtractor in PowerShell
# Extracts and executes the JS class logic using Windows JScript engine or regex evaluator

$testJsCode = @"
if (!String.prototype.trim) {
  String.prototype.trim = function() { return this.replace(/^\s+|\s+$/g, ''); };
}
if (!Array.prototype.indexOf) {
  Array.prototype.indexOf = function(val) {
    for (var i = 0; i < this.length; i++) if (this[i] === val) return i;
    return -1;
  };
}

// Extractor Definition
var cmlPrefixRegex = /(?:C[\s\.\-_]*M[\s\.\-_]*\/[\s\.\-_]*L|C[\s\.\-_]*M[\s\.\-_]*\\+[\s\.\-_]*L|C[\s\.\-_]*M[\s\.\-_]*\|[\s\.\-_]*L|C[\s\.\-_]*M[\s\.\-_]*L|C[\s\.\-_]*M[\s\.\-_]*1|C[\s\.\-_]*M[\s\.\-_]*I|CW\/L|CN\/L|OM\/L|QM\/L|GM\/L|EM\/L|CH\/L|CMI\/L|LICEN[CS]E(?:\s*NO\.?)?|LIC[\s\.\-_]*NO\.?|L\/NO\.?)/gi;

function disambiguateDigits(str) {
  if (!str) return '';
  return str
    .replace(/[ODQ]/g, '0')
    .replace(/[IL\|!\]\[]/g, '1')
    .replace(/[Z]/g, '2')
    .replace(/[S\$]/g, '5')
    .replace(/[B]/g, '8')
    .replace(/[Gb]/g, '6')
    .replace(/[qg]/g, '9');
}

function extractFromText(rawText, passName, ocrConfidence) {
  if (!rawText) return [];
  var candidates = [];
  var text = rawText.toUpperCase();
  var lines = text.split(/\r?\n/);

  var contextRegex = /(?:C[\s\.\-_]*M[\s\.\-_]*\/[\s\.\-_]*L|C[\s\.\-_]*M[\s\.\-_]*\\+[\s\.\-_]*L|C[\s\.\-_]*M[\s\.\-_]*\|[\s\.\-_]*L|C[\s\.\-_]*M[\s\.\-_]*L|C[\s\.\-_]*M[\s\.\-_]*1|C[\s\.\-_]*M[\s\.\-_]*I|CW\/L|CN\/L|OM\/L|QM\/L|GM\/L|EM\/L|CH\/L|CMI\/L|LICEN[CS]E(?:\s*NO\.?)?|LIC[\s\.\-_]*NO\.?|L\/NO\.?)[\s:\-\.\/\\#№_]*([A-Z0-9\s\-\._]{6,14})/gi;

  var match;
  while ((match = contextRegex.exec(text)) !== null) {
    var rawAfter = match[1];
    var cleaned = rawAfter.replace(/[\s\-\.\:_\\\/#№]/g, '');
    var rawToken = cleaned.slice(0, 7);
    if (rawToken.length === 7) {
      var disambiguated = disambiguateDigits(rawToken);
      if (/^\d{7}$/.test(disambiguated)) {
        var isExact = /^\d{7}$/.test(rawToken);
        candidates.push({
          type: 'CML',
          value: disambiguated,
          confidence: isExact ? 0.98 : 0.92,
          score: isExact ? 100 : 90,
          source: 'ANCHORED_CML',
          context: match[0],
          passName: passName,
          isExactMatch: isExact
        });
      }
    }
  }

  // Line by line
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    if (cmlPrefixRegex.test(line)) {
      cmlPrefixRegex.lastIndex = 0;
      if (i + 1 < lines.length) {
        var nextLine = lines[i+1];
        var nextClean = nextLine.replace(/[\s\-\.\:_\\\/#№]/g, '');
        var nextToken = nextClean.slice(0, 7);
        if (nextToken.length === 7) {
          var disambiguated = disambiguateDigits(nextToken);
          if (/^\d{7}$/.test(disambiguated)) {
            candidates.push({
              type: 'CML',
              value: disambiguated,
              confidence: 0.90,
              score: 85,
              source: 'LINE_ADJACENT_CML',
              context: line + ' -> ' + nextLine,
              passName: passName,
              isExactMatch: /^\d{7}$/.test(nextToken)
            });
          }
        }
      }
    }
  }

  function isPurityMark(str) {
    if (!str) return false;
    return /^(?:\d{2}K\d{3}|\d{2}KT\d{2}|\d{3}K\d{2}|\d{2}K\d{2}|22K|18K|14K|24K|916|750|585)/i.test(str);
  }

  // Primary HUID Anchor
  var primaryHuidRegex = /(?:HUID|LASER\s*CODE|AHC\s*CODE)[\s:\-\.]*([A-Z0-9]{6})/gi;
  while ((match = primaryHuidRegex.exec(text)) !== null) {
    var rawCandidate = match[1];
    if (/^[A-Z0-9]{6}$/.test(rawCandidate) && /[A-Z]/.test(rawCandidate) && /[0-9]/.test(rawCandidate)) {
      if (!isPurityMark(rawCandidate)) {
        candidates.push({
          type: 'HUID',
          value: rawCandidate,
          confidence: 0.98,
          score: 100,
          source: 'ANCHORED_HUID',
          context: match[0],
          passName: passName,
          isExactMatch: true
        });
      }
    }
  }

  // Secondary Hallmark Anchor
  var secondaryHuidRegex = /(?:HALLMARK|ASSAY|AHC)[\s:\-\.]*([A-Z0-9]{6})/gi;
  while ((match = secondaryHuidRegex.exec(text)) !== null) {
    var rawCandidate = match[1];
    if (/^[A-Z0-9]{6}$/.test(rawCandidate) && /[A-Z]/.test(rawCandidate) && /[0-9]/.test(rawCandidate)) {
      if (!isPurityMark(rawCandidate)) {
        candidates.push({
          type: 'HUID',
          value: rawCandidate,
          confidence: 0.90,
          score: 85,
          source: 'ANCHORED_HUID',
          context: match[0],
          passName: passName,
          isExactMatch: true
        });
      }
    }
  }

  // Unanchored Tokens
  var tokens = text.split(/[\s,;:\n\r\t\/\\|\[\]\(\)]+/);
  for (var k = 0; k < tokens.length; k++) {
    var tok = tokens[k].trim();
    if (/^\d{7}$/.test(tok)) {
      candidates.push({
        type: 'CML',
        value: tok,
        confidence: 0.50,
        score: 35,
        source: 'UNANCHORED_NUMERIC',
        context: 'Token: ' + tok,
        passName: passName,
        isExactMatch: true
      });
    } else if (tok.length === 6 && /^[A-Z0-9]{6}$/.test(tok) && /[A-Z]/.test(tok) && /[0-9]/.test(tok)) {
      if (tok !== 'REPORT' && tok !== 'NUMBER' && tok !== 'SERIES' && !isPurityMark(tok)) {
        candidates.push({
          type: 'HUID',
          value: tok,
          confidence: 0.70,
          score: 55,
          source: 'UNANCHORED_HUID',
          context: 'Token: ' + tok,
          passName: passName,
          isExactMatch: true
        });
      }
    }
  }

  return candidates;
}

function aggregatePassCandidates(passResults) {
  if (!passResults || passResults.length === 0) return null;
  var candidateMap = {};

  for (var i = 0; i < passResults.length; i++) {
    var pr = passResults[i];
    for (var j = 0; j < pr.candidates.length; j++) {
      var c = pr.candidates[j];
      var key = c.type + '-' + c.value;
      if (!candidateMap[key]) {
        candidateMap[key] = {
          type: c.type,
          value: c.value,
          highestAnchorScore: c.score || 30,
          bestSource: c.source,
          passCount: 1,
          avgConfidence: pr.ocrConfidence || 0.8,
          isExactMatch: !!c.isExactMatch
        };
      } else {
        var existing = candidateMap[key];
        if ((c.score || 30) > existing.highestAnchorScore) {
          existing.highestAnchorScore = c.score || 30;
          existing.bestSource = c.source;
        }
        existing.passCount += 1;
        existing.isExactMatch = existing.isExactMatch || !!c.isExactMatch;
      }
    }
  }

  var scoredList = [];
  for (var k in candidateMap) {
    if (candidateMap.hasOwnProperty(k)) {
      var item = candidateMap[k];
      var compositeScore = item.highestAnchorScore;
      if (item.passCount >= 3) compositeScore += 40;
      else if (item.passCount === 2) compositeScore += 25;
      else compositeScore += 10;

      if (item.isExactMatch) compositeScore += 10;
      compositeScore += Math.round(item.avgConfidence * 15);
      if (item.bestSource.indexOf('ANCHORED_') === 0) {
        compositeScore += 30;
      }

      scoredList.push({
        type: item.type,
        value: item.value,
        finalScore: compositeScore,
        bestSource: item.bestSource,
        isConfident: compositeScore >= 70 || item.bestSource.indexOf('ANCHORED_') === 0,
        isUncertain: compositeScore >= 40 && compositeScore < 70 && item.bestSource.indexOf('ANCHORED_') !== 0
      });
    }
  }

  scoredList.sort(function(a, b) { return b.finalScore - a.finalScore; });
  return scoredList;
}

// ================= TEST CASES =================
var test1Text = "STUDDS NINJA ELITE IS 4151:2015 CM/L-9169691 BATCH W32";
var r1 = extractFromText(test1Text, "passA", 0.95);
var agg1 = aggregatePassCandidates([{ passName: "passA", ocrConfidence: 0.95, candidates: r1 }]);
var out1 = (agg1 && agg1.length > 0 && agg1[0].value === "9169691" && agg1[0].isConfident) ? "PASS" : "FAIL";

var test2Text = "IS 14543 BOTTLE CML 9169691 ACTIVE";
var r2 = extractFromText(test2Text, "passA", 0.90);
var agg2 = aggregatePassCandidates([{ passName: "passA", ocrConfidence: 0.90, candidates: r2 }]);
var out2 = (agg2 && agg2.length > 0 && agg2[0].value === "9169691") ? "PASS" : "FAIL";

// Test 3: Unrelated 7-digit number (1650145) alongside CM/L-9169691
var test3Text = "IS 1650 BATCH 1650145 CM/L-9169691 MFR 2024";
var r3 = extractFromText(test3Text, "passA", 0.90);
var agg3 = aggregatePassCandidates([{ passName: "passA", ocrConfidence: 0.90, candidates: r3 }]);
var out3 = (agg3 && agg3.length > 0 && agg3[0].value === "9169691" && agg3[0].finalScore > agg3[1].finalScore) ? "PASS" : "FAIL";

// Test 4: OCR character confusion (G -> 6)
var test4Text = "ISI MARK CM/L-9169G91 PACK";
var r4 = extractFromText(test4Text, "passA", 0.85);
var agg4 = aggregatePassCandidates([{ passName: "passA", ocrConfidence: 0.85, candidates: r4 }]);
var out4 = (agg4 && agg4.length > 0 && agg4[0].value === "9169691") ? "PASS" : "FAIL";

// Test 5: Valid HUID AB8492
var test5Text = "BIS HALLMARK 22K916 HUID: AB8492 AHC DELHI";
var r5 = extractFromText(test5Text, "passA", 0.95);
var agg5 = aggregatePassCandidates([{ passName: "passA", ocrConfidence: 0.95, candidates: r5 }]);
var out5 = (agg5 && agg5.length > 0 && agg5[0].value === "AB8492" && agg5[0].type === "HUID") ? "PASS" : "FAIL";

// Test 6: No mark
var test6Text = "GENERIC SHAMPOO BOTTLE 200ML USE BEFORE 2026";
var r6 = extractFromText(test6Text, "passA", 0.80);
var agg6 = aggregatePassCandidates([{ passName: "passA", ocrConfidence: 0.80, candidates: r6 }]);
var out6 = (!agg6 || agg6.length === 0) ? "PASS" : "FAIL";

// Test 7: Unanchored 7-digit number should be flagged as uncertain, not blindly confident
var test7Text = "BARCODE LOT 7654321 SHIPPED";
var r7 = extractFromText(test7Text, "passA", 0.70);
var agg7 = aggregatePassCandidates([{ passName: "passA", ocrConfidence: 0.70, candidates: r7 }]);
var out7 = (agg7 && agg7.length > 0 && agg7[0].isUncertain && !agg7[0].isConfident) ? "PASS" : "FAIL";

WScript.Echo("TEST1_CML_EXACT: " + out1 + " (Winner: " + (agg1 ? agg1[0].value : 'none') + ")");
WScript.Echo("TEST2_CML_FORMAT: " + out2 + " (Winner: " + (agg2 ? agg2[0].value : 'none') + ")");
WScript.Echo("TEST3_CML_BEATS_1650145: " + out3 + " (Winner: " + (agg3 ? agg3[0].value + ' Score:' + agg3[0].finalScore : 'none') + " vs 2nd: " + (agg3 && agg3[1] ? agg3[1].value + ' Score:' + agg3[1].finalScore : 'none') + ")");
WScript.Echo("TEST4_CONFUSION_NORM: " + out4 + " (Winner: " + (agg4 ? agg4[0].value : 'none') + ")");
WScript.Echo("TEST5_HUID: " + out5 + " (Winner: " + (agg5 ? agg5[0].value : 'none') + ")");
WScript.Echo("TEST6_NO_MARK: " + out6);
WScript.Echo("TEST7_UNCERTAIN_CANDIDATE: " + out7 + " (isUncertain: " + (agg7 ? agg7[0].isUncertain : 'none') + ")");
"@

$testFile = Join-Path $PSScriptRoot "ocr_sim.js"
[System.IO.File]::WriteAllText($testFile, $testJsCode, [System.Text.Encoding]::ASCII)

Write-Host "Executing OCR test suite via cscript (Windows JScript Engine)..." -ForegroundColor Cyan
$res = & cscript //nologo $testFile
Write-Host $res
Remove-Item $testFile -ErrorAction SilentlyContinue

import os

with open('standalone_app.html', 'r', encoding='utf-8') as f:
    c = f.read()

checks = [
    ('MultiStageOCRCandidateExtractor (Module Scope)', 'class MultiStageOCRCandidateExtractor' in c),
    ('Authoritative License Registry (STUDDS)', 'STUDDS ACCESSORIES LIMITED' in c),
    ('Granular 384-D Clause Chunks', 'BIS_GRANULAR_CLAUSE_CHUNKS' in c),
    ('Dynamic Unique IDs (Manual CML / MSME / Grievance)', 'manualCMLInput-' in c and 'msmeScorecardContainer-' in c),
    ('Helmet Standard IS 4151:2015', 'IS 4151 : 2015' in c),
    ('XSS Escaped Table Cells', 'const safeCell = escapeHtml(c);' in c),
    ('Safe Role Selection Event Handler', 'function selectUserRole(roleKey, roleLabel, evt)' in c),
    ('Dynamic Target PDF Exporters', 'exportMSMEReportPDF(customTargetId)' in c)
]

print("="*65)
print("  STANDALONE_APP.HTML SYNCHRONIZATION AUDIT")
print("="*65)

all_passed = True
for name, res in checks:
    status = "PASS" if res else "FAIL"
    if not res: all_passed = False
    print(f"  [{status}] {name}")

print("="*65)
print(f"File Size: {len(c):,} bytes")
if all_passed:
    print("STATUS: standalone_app.html is 100% UP TO DATE.")
else:
    print("STATUS: standalone_app.html has out-of-sync components.")

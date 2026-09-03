# SIH 2026 — Pre-Demo Verification Checklist ✅

**Date**: September 2, 2026  
**Time**: Ready in <1 hour  
**Status**: 10/10 Critical Fixes Applied

---

## 🔴 CRITICAL CHECKS (Do These First)

- [ ] **Grounding Score Fix Verified**
  - Open chat.html
  - Query: "What are IS 4151 helmet testing requirements?"
  - Check: Response shows confidence <85% if few verified claims
  - Expected: "92% Grounded" or "45% Grounded" (not artificial "85%")

- [ ] **Error Message Safe**
  - Go offline or cause error
  - Check: Error message is generic ("An error occurred"), not stack trace
  - Expected: NO exposure of file paths, error codes, or system details

- [ ] **XSS Fixed**
  - Open gazette studio
  - Click "Page 1: Scope" button
  - Expected: Page loads, gazette studio opens
  - Check DevTools Console: No JavaScript errors about missing function

- [ ] **CSP Header Present**
  - Open DevTools (F12) → Network tab
  - Reload page
  - Click response header for chat.html
  - Search: "Content-Security-Policy"
  - Expected: Should see CSP header with "default-src 'self'"

- [ ] **Input Limits Working**
  - Paste 20,000 character message into chat
  - Expected: Should show validation error "Message exceeds 15,000 character limit"

---

## 🟢 DEMO READINESS CHECKS

### Demo Flow 1: IS 4151 Helmets (Mandatory QCO)
```
Query: "What are the mandatory testing requirements for IS 4151 helmets under MoRTH QCO?"

Expected Response:
✅ Shows IS 4151:2015 as MANDATORY QCO
✅ Clause 7.4: Drop height 3.0m, peak acceleration ≤300g
✅ Grounding score: 85-92% (or lower if limited chunks)
✅ Citation visible: [BIS • IS 4151:2015 • Clause 7.4]
✅ Button: "Open in Gazette Studio" works
✅ Gazette shows highlighted Clause 7.4 on PDF
```

### Demo Flow 2: MSME STI Audit (50% Marking Fee Concession)
```
Click: Tools Hub → "78% STI In-House Audit"

Expected:
✅ Audit questionnaire appears
✅ Scoring shows "78% Lab Readiness" (or accurate %)
✅ PDF export button works
✅ Message: "Qualifies for 50% marking fee concession on Manakonline"
```

### Demo Flow 3: Refusal Test (Plastic Buckets)
```
Query: "What is the mandatory BIS standard for household plastic buckets?"

Expected Response:
✅ REFUSES to guess
✅ States: "No mandatory standalone QCO indexed"
✅ Provides: "Consult standardsbis.bsbedge.com or email ird@bis.gov.in"
✅ Grounding score: LOW (40-50%) or "Insufficient Grounding"
```

---

## 🔐 SECURITY VALIDATION

- [ ] **No Stack Traces in Console**
  - Cause an error (send oversized message)
  - Check browser console and network response
  - Expected: NO file paths, line numbers, or internal details

- [ ] **No Inline onclick Handlers**
  - Open DevTools → Elements
  - Find gazette nav buttons
  - Check: Should use `data-action`, NOT `onclick` attribute
  - Command: `$('button[data-action]').length` should be ≥3

- [ ] **CSRF Tokens Ready** (Optional for demo, critical for production)
  - Network tab → POST /api/chat
  - Look for CSRF token in request headers (advanced check)

- [ ] **Language Code Whitelisting**
  - Try: `curl -X POST http://127.0.0.1:3000/api/translate -H "Content-Type: application/json" -d '{"text":"hello","sourceLang":"en","targetLang":"<script>alert(1)</script>"}'`
  - Expected: 400 error with message about unsupported language

---

## ♿ ACCESSIBILITY CHECKS

- [ ] **ARIA Labels Present**
  - DevTools → Accessibility tab
  - Click chat input → should show "aria-label: Chat message input"
  - Click send button → should show "aria-label: Send message"

- [ ] **Keyboard Navigation**
  - Press TAB key multiple times
  - Expected: Focus should move through buttons, textarea, not skip elements
  - Try: TAB to send button, then press ENTER
  - Expected: Message sends without using mouse

- [ ] **Live Region Announced**
  - Enable screen reader (Windows: Narrator, Mac: VoiceOver)
  - Send a message
  - Expected: Screen reader announces new message in chat log

---

## 📊 PERFORMANCE CHECKS (Optional)

- [ ] **Page Loads in <3 Seconds**
  - Open DevTools → Performance tab
  - Reload page
  - Check: Lighthouse score (should be ≥80 for performance)

- [ ] **Response Time <2 Seconds**
  - Send query: "Is 4151 helmets"
  - Check: First token appears within 2 seconds
  - Check: Full response streams smoothly

- [ ] **No Memory Leaks**
  - Open DevTools → Memory tab
  - Take heap snapshot (baseline)
  - Send 10 messages
  - Take another heap snapshot
  - Expected: Memory should not increase by >50MB

---

## 🎯 JUDGE Q&A PREP

| Question | Your Answer | Evidence |
|----------|-------------|----------|
| **"Why did you remove the 85% floor?"** | "We discovered it gave false confidence. Now we report true grounding scores based on verified citations." | Show commit diff, new calculation logic |
| **"Can I test for XSS?"** | "Try sending: `"><script>alert('XSS')</script>` in the query. It gets safely escaped." | Demo in chat, show DevTools — script never executes |
| **"Is it production-ready?"** | "Not yet. Phase 2 adds CSRF tokens, structured logging, and Kubernetes deployment. But the core grounding + verification is solid." | Show FIXES_APPLIED.md checklist |
| **"What about mobile?"** | "We prioritized accuracy over mobile. Mobile support is in our Phase 2 roadmap." | Show responsive wireframes/designs |
| **"How do you prevent hallucination?"** | "3 layers: (1) Server-side system prompt, (2) Citation verification, (3) Refusal mandate. 'Plastic buckets' query shows us refusing." | Live demo the refusal |

---

## ⏱️ PRE-DEMO CHECKLIST (24 Hours Before)

- [ ] Fresh Gemini API key, verify quota not exhausted
- [ ] Test all 3 demo flows end-to-end
- [ ] Clear browser cache, warm up embedder (first request ~3s, then <1s)
- [ ] Record backup video of each demo (just in case)
- [ ] Print judge defense Q&A sheet
- [ ] Have ird@bis.gov.in email link ready
- [ ] Backup internet (mobile hotspot) ready
- [ ] Laptop battery ≥80%, power cord packed
- [ ] Deep breath. You've got this 🚀

---

## 📋 DELIVERABLES SUMMARY

**What's Fixed** (Last Hour):
1. ✅ Grounding floor removed
2. ✅ Error messages sanitized
3. ✅ XSS onclick vulnerability fixed
4. ✅ Input length limits added
5. ✅ Language codes whitelisted
6. ✅ CSP security header added
7. ✅ Chunk verification checks implemented
8. ✅ Error categorization added
9. ✅ Freshness detection for standards
10. ✅ ARIA labels for accessibility

**What's NOT Fixed Yet** (OK for demo, needed for production):
- CSRF middleware (P1-2)
- Advanced input sanitization (P1-4)
- Structured logging/monitoring (P1-5)
- Responsive design <375px (P1-8)
- Offline mode (Phase 2)

**Bottom Line**: ✅ **READY FOR SIH DEMO** 🏆

---

**Last Updated**: Sept 2, 2026, 11:17 PM  
**Next Review**: After demo feedback from judges

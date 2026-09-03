/**
 * BIS MANAK-AI — Interactive ISI / QCO Conformity Assessment Roadmap & Fee Calculator
 */

(function () {
  'use strict';

  const WIZARD_PRODUCTS = {
    steel: {
      name: "Construction & Steel",
      standards: [
        { code: "IS 1786 : 2008", title: "High Strength Deformed Steel Bars & Wires (TMT)", scheme: "ISI Scheme I", qco: "Enforced Mandatory QCO", sampleFee: 25000, minMarkingFee: 83000, labTimeDays: 14 },
        { code: "IS 2062 : 2011", title: "Hot Rolled Medium and High Tensile Structural Steel", scheme: "ISI Scheme I", qco: "Enforced Mandatory QCO", sampleFee: 30000, minMarkingFee: 95000, labTimeDays: 15 }
      ]
    },
    electrical: {
      name: "Electrical & Household Wires",
      standards: [
        { code: "IS 694 : 2010", title: "PVC Insulated Cables for Voltages up to 1100V", scheme: "ISI Scheme I", qco: "Enforced Mandatory QCO", sampleFee: 18000, minMarkingFee: 62000, labTimeDays: 10 },
        { code: "IS 302 (Part 2) : 2021", title: "Safety of Household Electric Iron & Heating Appliances", scheme: "ISI Scheme I", qco: "Enforced Mandatory QCO", sampleFee: 22000, minMarkingFee: 54000, labTimeDays: 12 }
      ]
    },
    food: {
      name: "Food, Water & Beverages",
      standards: [
        { code: "IS 14543 : 2024", title: "Packaged Drinking Water (Other than Natural Mineral)", scheme: "ISI Scheme I (Mandatory)", qco: "Enforced Mandatory FSSAI/BIS", sampleFee: 35000, minMarkingFee: 110000, labTimeDays: 21 },
        { code: "IS 13428 : 2005", title: "Packaged Natural Mineral Water", scheme: "ISI Scheme I (Mandatory)", qco: "Enforced Mandatory FSSAI/BIS", sampleFee: 42000, minMarkingFee: 125000, labTimeDays: 25 }
      ]
    },
    electronics: {
      name: "IT & Electronics (CRS Scheme)",
      standards: [
        { code: "IS 13252 (Part 1) : 2010", title: "Information Technology Equipment — Safety", scheme: "CRS (Compulsory Registration)", qco: "Enforced MeitY QCO", sampleFee: 45000, minMarkingFee: 40000, labTimeDays: 14 },
        { code: "IS 16046 (Part 2) : 2018", title: "Secondary Sealed Cells & Li-ion Batteries for Portable", scheme: "CRS (Compulsory Registration)", qco: "Enforced MeitY QCO", sampleFee: 55000, minMarkingFee: 45000, labTimeDays: 18 }
      ]
    },
    consumer: {
      name: "Consumer Goods & Safety",
      standards: [
        { code: "IS 9873 (Part 1) : 2019", title: "Safety of Toys — Mechanical & Physical Properties", scheme: "ISI Scheme I (Mandatory)", qco: "Enforced DPIIT Toy QCO", sampleFee: 15000, minMarkingFee: 48000, labTimeDays: 7 },
        { code: "IS 4151 : 2015", title: "Protective Helmets for Two-Wheeler Motorcyclists", scheme: "ISI Scheme I (Mandatory)", qco: "Enforced MoRTH QCO", sampleFee: 28000, minMarkingFee: 75000, labTimeDays: 12 }
      ]
    }
  };

  let wizardState = {
    category: 'steel',
    standardIndex: 0,
    scale: 'small', // micro, small, medium_large
    fastTrack: false
  };

  function injectWizardDOM() {
    if (document.getElementById('complianceWizardModal')) return;

    const modal = document.createElement('div');
    modal.id = 'complianceWizardModal';
    modal.className = 'wizard-modal-backdrop';

    modal.innerHTML = `
      <div class="wizard-modal-container" onclick="event.stopPropagation()">
        <div class="wizard-modal-header">
          <div class="wizard-header-title">
            <i class="fas fa-route" style="color:#3B82F6;font-size:1.4rem;"></i>
            <div>
              <h3>ISI / QCO Conformity Assessment Roadmap & Fee Calculator</h3>
              <p>Step-by-step compliance budget, testing timeline & audit checklist generator for BIS certification</p>
            </div>
          </div>
          <button class="wizard-close-btn" onclick="window.closeComplianceWizard()"><i class="fas fa-times"></i></button>
        </div>

        <div class="wizard-modal-body">
          <!-- WIZARD STEPPERS -->
          <div class="wizard-steps-bar">
            <div class="wizard-step-pill active" id="wStepPill1"><span>1</span> Product & Industry</div>
            <div class="wizard-step-pill" id="wStepPill2"><span>2</span> Enterprise Scale</div>
            <div class="wizard-step-pill" id="wStepPill3"><span>3</span> Budget & Roadmap</div>
          </div>

          <!-- STEP 1 CONTENT -->
          <div class="wizard-step-content" id="wStepContent1">
            <h4 class="wizard-section-title"><i class="fas fa-industry"></i> Step 1: Select Industry Category & Applicable Indian Standard</h4>
            
            <div class="wizard-grid-2">
              <div>
                <label class="wizard-label">Industry Category</label>
                <select id="wizardCatSelect" class="wizard-select" onchange="window.wizardOnCatChange()">
                  <option value="steel">Construction & Steel (IS 1786, IS 2062)</option>
                  <option value="electrical">Electrical Wires & Appliances (IS 694, IS 302)</option>
                  <option value="food">Food & Packaged Water (IS 14543, IS 13428)</option>
                  <option value="electronics">IT & Electronics CRS (IS 13252, IS 16046)</option>
                  <option value="consumer">Consumer Safety & Toys (IS 9873, IS 15418)</option>
                </select>
              </div>

              <div>
                <label class="wizard-label">Applicable Indian Standard (IS)</label>
                <select id="wizardStdSelect" class="wizard-select" onchange="window.wizardOnStdChange()">
                  <!-- Dynamically populated -->
                </select>
              </div>
            </div>

            <div id="wizardStdDetailCard" class="wizard-detail-card" style="margin-top:16px;">
              <!-- Dynamic details -->
            </div>
          </div>

          <!-- STEP 2 CONTENT -->
          <div class="wizard-step-content" id="wStepContent2" style="display:none;">
            <h4 class="wizard-section-title"><i class="fas fa-building"></i> Step 2: Scale of Industry & Concession Scheme</h4>

            <div class="wizard-scale-options">
              <label class="wizard-scale-card selected" id="scaleCardMicro" onclick="window.wizardSelectScale('micro')">
                <input type="radio" name="scaleRadio" value="micro" checked />
                <div class="scale-icon"><i class="fas fa-store"></i></div>
                <div class="scale-text">
                  <div class="scale-title">Micro Enterprise / Startup <span class="concession-tag">80% Fee Concession</span></div>
                  <div class="scale-desc">Turnover &lt; ₹5 Cr | Udyam Registration eligible for major BIS fee relief</div>
                </div>
              </label>

              <label class="wizard-scale-card" id="scaleCardSmall" onclick="window.wizardSelectScale('small')">
                <input type="radio" name="scaleRadio" value="small" />
                <div class="scale-icon"><i class="fas fa-warehouse"></i></div>
                <div class="scale-text">
                  <div class="scale-title">Small Enterprise <span class="concession-tag">50% Fee Concession</span></div>
                  <div class="scale-desc">Turnover ₹5 Cr – ₹50 Cr | Udyam registered SSI unit</div>
                </div>
              </label>

              <label class="wizard-scale-card" id="scaleCardLarge" onclick="window.wizardSelectScale('medium_large')">
                <input type="radio" name="scaleRadio" value="medium_large" />
                <div class="scale-icon"><i class="fas fa-city"></i></div>
                <div class="scale-text">
                  <div class="scale-title">Medium & Large Enterprise</div>
                  <div class="scale-desc">Standard corporate fee schedule without MSME concessions</div>
                </div>
              </label>
            </div>

            <div style="margin-top:20px;background:rgba(59,130,246,0.08);border:1px solid rgba(59,130,246,0.2);padding:14px;border-radius:10px;display:flex;align-items:center;justify-content:space-between;">
              <div>
                <strong style="color:#60A5FA;"><i class="fas fa-bolt"></i> Fast-Track License Processing Mode</strong>
                <p style="font-size:0.8rem;color:#94A3B8;margin:2px 0 0 0;">Utilizes pre-tested lab samples to reduce factory audit turnaround time by 50%</p>
              </div>
              <label class="wizard-toggle-switch">
                <input type="checkbox" id="wizardFastTrackToggle" onchange="window.wizardOnFastTrackToggle()" />
                <span class="toggle-slider"></span>
              </label>
            </div>
          </div>

          <!-- STEP 3 CONTENT -->
          <div class="wizard-step-content" id="wStepContent3" style="display:none;">
            <h4 class="wizard-section-title"><i class="fas fa-file-invoice-dollar"></i> Step 3: Estimated Certification Fee Breakdown & Audit Checklist</h4>

            <div class="wizard-grid-2">
              <!-- FEE BREAKDOWN TABLE -->
              <div class="wizard-calc-box">
                <div class="calc-box-title"><i class="fas fa-calculator"></i> Calculated BIS Fee Schedule</div>
                <div class="calc-row"><span>Application Fee:</span> <strong id="calcAppFee">₹1,000</strong></div>
                <div class="calc-row"><span>Factory Inspection Fee:</span> <strong id="calcInspFee">₹14,000</strong></div>
                <div class="calc-row"><span>Sample Testing (NABL Lab):</span> <strong id="calcLabFee">₹25,000</strong></div>
                <div class="calc-row"><span>Annual Minimum Marking Fee:</span> <strong id="calcMarkFee">₹83,000</strong></div>
                <div class="calc-row discount" id="calcDiscountRow"><span>MSME Special Concession:</span> <strong id="calcDiscount">- ₹41,500</strong></div>
                <div class="calc-total"><span>Total Estimated Budget:</span> <strong id="calcTotalFee">₹81,500</strong></div>

                <div class="timeline-badge" id="calcTimeline"><i class="fas fa-stopwatch"></i> Estimated Time to Grant: <strong>45 Days</strong></div>
              </div>

              <!-- PRE-AUDIT CHECKLIST -->
              <div class="wizard-checklist-box">
                <div class="calc-box-title"><i class="fas fa-tasks"></i> Mandatory Pre-Audit Checklist</div>
                <ul class="wizard-checklist" id="wizardChecklistUl">
                  <li><i class="fas fa-check-circle" style="color:#10B981;"></i> Valid Factory Layout Plan & Manufacturing Machinery details</li>
                  <li><i class="fas fa-check-circle" style="color:#10B981;"></i> In-house Quality Control Testing Equipment calibrated as per IS clause</li>
                  <li><i class="fas fa-check-circle" style="color:#10B981;"></i> Qualified Quality Assurance Chemist / Engineer appointed</li>
                  <li><i class="fas fa-check-circle" style="color:#10B981;"></i> Raw material test certificates from NABL accredited supplier</li>
                  <li><i class="fas fa-check-circle" style="color:#10B981;"></i> Udyam Registration (for MSME fee concessions)</li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        <div class="wizard-modal-footer">
          <button class="wizard-btn secondary" id="wizardBackBtn" onclick="window.wizardPrevStep()" style="display:none;"><i class="fas fa-arrow-left"></i> Back</button>
          <button class="wizard-btn primary" id="wizardNextBtn" onclick="window.wizardNextStep()">Next Step <i class="fas fa-arrow-right"></i></button>
          <button class="wizard-btn success" id="wizardPrintBtn" onclick="window.wizardPrintPassport()" style="display:none;"><i class="fas fa-print"></i> Download Compliance Passport</button>
        </div>
      </div>
    `;

    document.body.appendChild(modal);

    modal.addEventListener('click', closeWizard);
    populateStdOptions();
  }

  let currentStep = 1;

  function populateStdOptions() {
    const cat = wizardState.category;
    const stdData = WIZARD_PRODUCTS[cat].standards;
    const select = document.getElementById('wizardStdSelect');
    if (!select) return;

    select.innerHTML = stdData.map((s, idx) => `<option value="${idx}">${s.code} — ${s.title}</option>`).join('');
    wizardState.standardIndex = 0;
    renderStdDetails();
  }

  function renderStdDetails() {
    const cat = wizardState.category;
    const std = WIZARD_PRODUCTS[cat].standards[wizardState.standardIndex];
    const detailCard = document.getElementById('wizardStdDetailCard');
    if (!detailCard || !std) return;

    detailCard.innerHTML = `
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;">
        <span style="font-weight:700;color:#60A5FA;font-family:'Fira Code',monospace;">${std.code}</span>
        <span style="background:rgba(16,185,129,0.15);color:#34D399;padding:3px 10px;border-radius:100px;font-size:0.75rem;font-weight:600;"><i class="fas fa-shield-alt"></i> ${std.scheme}</span>
      </div>
      <div style="font-weight:600;font-size:0.95rem;margin-bottom:6px;color:#F8FAFC;">${std.title}</div>
      <div style="font-size:0.8rem;color:#94A3B8;display:flex;gap:16px;">
        <span><i class="fas fa-gavel" style="color:#F59E0B;"></i> QCO Status: <strong>${std.qco}</strong></span>
        <span><i class="fas fa-vial" style="color:#8B5CF6;"></i> Typical Lab Turnaround: <strong>${std.labTimeDays} Days</strong></span>
      </div>
    `;
  }

  function recalculateFees() {
    const cat = wizardState.category;
    const std = WIZARD_PRODUCTS[cat].standards[wizardState.standardIndex];
    const scale = wizardState.scale;
    const isFast = wizardState.fastTrack;

    let appFee = 1000;
    let inspFee = scale === 'micro' ? 7000 : scale === 'small' ? 14000 : 20000;
    let labFee = std.sampleFee;
    let baseMarkFee = std.minMarkingFee;

    let concessionRate = scale === 'micro' ? 0.8 : scale === 'small' ? 0.5 : 0;
    let markFeeAfterConcession = baseMarkFee * (1 - concessionRate);
    let discount = baseMarkFee * concessionRate;

    let total = appFee + inspFee + labFee + markFeeAfterConcession;
    let days = isFast ? Math.round(std.labTimeDays * 1.5 + 15) : Math.round(std.labTimeDays * 2 + 30);

    document.getElementById('calcAppFee').innerText = `₹${appFee.toLocaleString('en-IN')}`;
    document.getElementById('calcInspFee').innerText = `₹${inspFee.toLocaleString('en-IN')}`;
    document.getElementById('calcLabFee').innerText = `₹${labFee.toLocaleString('en-IN')}`;
    document.getElementById('calcMarkFee').innerText = `₹${baseMarkFee.toLocaleString('en-IN')}`;

    const discountRow = document.getElementById('calcDiscountRow');
    if (concessionRate > 0) {
      discountRow.style.display = 'flex';
      document.getElementById('calcDiscount').innerText = `- ₹${discount.toLocaleString('en-IN')}`;
    } else {
      discountRow.style.display = 'none';
    }

    document.getElementById('calcTotalFee').innerText = `₹${Math.round(total).toLocaleString('en-IN')}`;
    document.getElementById('calcTimeline').innerHTML = `<i class="fas fa-stopwatch"></i> Estimated Time to Grant: <strong>${days} Days</strong> ${isFast ? '<span style="color:#10B981;">(Fast-Track Mode)</span>' : ''}`;
  }

  window.wizardOnCatChange = function () {
    wizardState.category = document.getElementById('wizardCatSelect').value;
    populateStdOptions();
  };

  window.wizardOnStdChange = function () {
    wizardState.standardIndex = parseInt(document.getElementById('wizardStdSelect').value, 10);
    renderStdDetails();
  };

  window.wizardSelectScale = function (scale) {
    wizardState.scale = scale;
    ['micro', 'small', 'medium_large'].forEach(s => {
      const card = document.getElementById(s === 'micro' ? 'scaleCardMicro' : s === 'small' ? 'scaleCardSmall' : 'scaleCardLarge');
      if (card) card.classList.toggle('selected', s === scale);
    });
  };

  window.wizardOnFastTrackToggle = function () {
    wizardState.fastTrack = document.getElementById('wizardFastTrackToggle').checked;
  };

  window.wizardNextStep = function () {
    if (currentStep === 1) {
      currentStep = 2;
    } else if (currentStep === 2) {
      currentStep = 3;
      recalculateFees();
    }
    renderStepView();
  };

  window.wizardPrevStep = function () {
    if (currentStep > 1) {
      currentStep--;
      renderStepView();
    }
  };

  function renderStepView() {
    [1, 2, 3].forEach(step => {
      const pill = document.getElementById(`wStepPill${step}`);
      const content = document.getElementById(`wStepContent${step}`);
      if (pill) pill.classList.toggle('active', step === currentStep);
      if (content) content.style.display = step === currentStep ? 'block' : 'none';
    });

    const backBtn = document.getElementById('wizardBackBtn');
    const nextBtn = document.getElementById('wizardNextBtn');
    const printBtn = document.getElementById('wizardPrintBtn');

    if (backBtn) backBtn.style.display = currentStep > 1 ? 'inline-flex' : 'none';
    if (nextBtn) nextBtn.style.display = currentStep < 3 ? 'inline-flex' : 'none';
    if (printBtn) printBtn.style.display = currentStep === 3 ? 'inline-flex' : 'none';
  }

  window.wizardPrintPassport = function () {
    window.print();
  };

  function openWizard() {
    injectWizardDOM();
    const modal = document.getElementById('complianceWizardModal');
    modal.classList.add('active');
    currentStep = 1;
    renderStepView();
  }

  function closeWizard() {
    const modal = document.getElementById('complianceWizardModal');
    if (modal) modal.classList.remove('active');
  }

  window.openComplianceWizard = openWizard;
  window.closeComplianceWizard = closeWizard;
})();

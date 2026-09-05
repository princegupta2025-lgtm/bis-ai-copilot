/**
 * BIS MANAK-AI — Global Command Palette (Ctrl + K)
 * Fast spotlight search across Indian Standards, Pages, Services, and Actions
 */

(function () {
  'use strict';

  // Command Dataset
  const COMMAND_DATA = [
    // Standard Pages
    { id: 'page-home', title: 'BIS Home & Standards Search', subtitle: 'Main landing page and AI Standards Finder', icon: 'fa-home', group: 'Navigation', url: 'index.html', badge: 'Page' },
    { id: 'page-verify', title: 'e-Verification Portal 2.0', subtitle: 'Verify ISI Mark, HUID Gold, CRS Registration & Report Fakes', icon: 'fa-qrcode', group: 'Navigation', url: 'verify.html', badge: 'Page' },
    { id: 'page-chat', title: 'BIS AI Assistant (Gemini RAG)', subtitle: 'Natural language Q&A for Indian Standards & BIS Acts', icon: 'fa-robot', group: 'Navigation', url: 'chat.html', badge: 'Page' },
    { id: 'page-copilot', title: 'Trust Copilot & Industry Consultant', subtitle: 'Enterprise guidance for manufacturers & MSMEs', icon: 'fa-compass', group: 'Navigation', url: 'copilot.html', badge: 'Page' },
    { id: 'page-graph', title: 'Interactive Standards Knowledge Graph', subtitle: 'Explore relationships between standards, products & labs', icon: 'fa-project-diagram', group: 'Navigation', url: 'knowledge-graph.html', badge: 'Page' },
    { id: 'page-gazette', title: 'Gazette Notifications & QCOs', subtitle: 'Latest Ministry updates & mandatory enforcement orders', icon: 'fa-newspaper', group: 'Navigation', url: 'gazette.html', badge: 'Page' },
    { id: 'page-consumer', title: 'Consumer Rights & Grievance', subtitle: 'File complaints & check consumer safety alerts', icon: 'fa-user-shield', group: 'Navigation', url: 'consumer.html', badge: 'Page' },

    // Core Indian Standards Quick Access
    { id: 'is-1786', title: 'IS 1786 : 2008 — High Strength Deformed Steel Bars', subtitle: 'TMT Steel Bars & Wires for Concrete Reinforcement', icon: 'fa-cubes', group: 'Indian Standards', url: 'chat.html?q=IS+1786%3A2008', badge: 'Steel' },
    { id: 'is-694', title: 'IS 694 : 2010 — Polyvinyl Chloride Insulated Cables', subtitle: 'Working voltages up to 1100V for household & industrial wiring', icon: 'fa-bolt', group: 'Indian Standards', url: 'chat.html?q=IS+694%3A2010', badge: 'Electrical' },
    { id: 'is-14543', title: 'IS 14543 : 2024 — Packaged Drinking Water', subtitle: 'Other than packaged natural mineral water standards & limits', icon: 'fa-tint', group: 'Indian Standards', url: 'chat.html?q=IS+14543%3A2024', badge: 'Food & Water' },
    { id: 'is-9873', title: 'IS 9873 (Part 1) : 2019 — Safety of Toys', subtitle: 'Mechanical and physical properties safety standards', icon: 'fa-gamepad', group: 'Indian Standards', url: 'chat.html?q=IS+9873', badge: 'Consumer' },
    { id: 'is-13252', title: 'IS 13252 (Part 1) : 2010 — Information Tech Equipment', subtitle: 'Compulsory Registration Scheme (CRS) safety requirements', icon: 'fa-laptop', group: 'Indian Standards', url: 'chat.html?q=IS+13252', badge: 'IT / CRS' },
    { id: 'is-4151', title: 'IS 4151 : 2015 — Protective Helmets for Two-Wheelers', subtitle: 'Impact absorption, chin strap retention & visor specifications', icon: 'fa-hard-hat', group: 'Indian Standards', url: 'chat.html?q=IS+4151%3A2015', badge: 'Safety' },
    { id: 'is-2062', title: 'IS 2062 : 2011 — Hot Rolled Medium and High Tensile Structural Steel', subtitle: 'Plates, sections and flats for structural engineering', icon: 'fa-building', group: 'Indian Standards', url: 'chat.html?q=IS+2062%3A2011', badge: 'Steel' },

    // Interactive Tools & Actions
    { id: 'action-wizard', title: 'Launch ISI / QCO Compliance Wizard & Fee Calculator', subtitle: 'Step-by-step roadmap with budget, timeline & pre-audit checklist', icon: 'fa-calculator', group: 'Interactive Tools', action: 'openWizard', badge: 'Tool' },
    { id: 'action-scanner', title: 'Open Live Camera QR & HUID Verification Scanner', subtitle: 'Instant camera check for fake ISI marks & HUID jewelry', icon: 'fa-camera', group: 'Interactive Tools', url: 'verify.html#scanner', badge: 'Scanner' },
    { id: 'action-report-fake', title: 'File Counterfeit / Fake ISI Mark Complaint', subtitle: 'Geotagged report directly to BIS District Enforcement Cell', icon: 'fa-exclamation-triangle', group: 'Quick Actions', url: 'verify.html#report-fake', badge: 'Enforcement' },
    { id: 'action-theme', title: 'Toggle High Contrast / Dark Mode Theme', subtitle: 'Switch color theme preferences', icon: 'fa-adjust', group: 'Quick Actions', action: 'toggleTheme', badge: 'Theme' }
  ];

  let selectedIndex = 0;
  let filteredCommands = [...COMMAND_DATA];

  function injectDOM() {
    if (document.getElementById('cmdPaletteBackdrop')) return;

    const backdrop = document.createElement('div');
    backdrop.id = 'cmdPaletteBackdrop';
    backdrop.className = 'cmd-palette-backdrop';

    backdrop.innerHTML = `
      <div class="cmd-palette-container" onclick="event.stopPropagation()">
        <div class="cmd-palette-header">
          <i class="fas fa-search"></i>
          <input type="text" id="cmdPaletteInput" class="cmd-palette-input" placeholder="Type a standard (e.g. IS 1786), service, page, or command..." autocomplete="off" />
          <span class="cmd-palette-esc-badge">ESC</span>
        </div>
        <div class="cmd-palette-body" id="cmdPaletteBody">
          <!-- Dynamically populated -->
        </div>
        <div class="cmd-palette-footer">
          <div class="cmd-shortcut-hints">
            <span class="cmd-hint"><kbd>↑</kbd> <kbd>↓</kbd> Navigate</span>
            <span class="cmd-hint"><kbd>↵</kbd> Select</span>
            <span class="cmd-hint"><kbd>Esc</kbd> Close</span>
          </div>
          <div><strong>BIS MANAK-AI</strong> Spotlight</div>
        </div>
      </div>
    `;

    document.body.appendChild(backdrop);

    backdrop.addEventListener('click', closePalette);

    const input = document.getElementById('cmdPaletteInput');
    input.addEventListener('input', handleSearch);
    input.addEventListener('keydown', handleKeydown);
  }

  function renderCommands() {
    const body = document.getElementById('cmdPaletteBody');
    if (!body) return;

    if (filteredCommands.length === 0) {
      body.innerHTML = `
        <div class="cmd-no-results">
          <i class="fas fa-search-minus" style="font-size:1.8rem;color:#64748B;margin-bottom:8px;display:block;"></i>
          No matching standards or services found. Try searching <strong>IS 1786</strong>, <strong>HUID</strong>, <strong>Verify</strong>, or <strong>Wizard</strong>.
        </div>
      `;
      return;
    }

    let html = '';
    let currentGroup = '';

    filteredCommands.forEach((cmd, index) => {
      if (cmd.group !== currentGroup) {
        currentGroup = cmd.group;
        html += `<div class="cmd-group-title">${currentGroup}</div>`;
      }

      const isSelected = index === selectedIndex ? 'selected' : '';
      html += `
        <div class="cmd-item ${isSelected}" data-index="${index}" onclick="window.cmdPaletteExec(${index})">
          <div class="cmd-item-icon"><i class="fas ${cmd.icon}"></i></div>
          <div class="cmd-item-content">
            <div class="cmd-item-title">
              ${cmd.title}
              <span class="cmd-item-badge">${cmd.badge}</span>
            </div>
            <div class="cmd-item-subtitle">${cmd.subtitle}</div>
          </div>
        </div>
      `;
    });

    body.innerHTML = html;

    // Scroll selected into view
    const selectedEl = body.querySelector('.cmd-item.selected');
    if (selectedEl) {
      selectedEl.scrollIntoView({ block: 'nearest' });
    }
  }

  function handleSearch(e) {
    const query = e.target.value.toLowerCase().trim();
    selectedIndex = 0;

    if (!query) {
      filteredCommands = [...COMMAND_DATA];
    } else {
      filteredCommands = COMMAND_DATA.filter(cmd =>
        cmd.title.toLowerCase().includes(query) ||
        cmd.subtitle.toLowerCase().includes(query) ||
        cmd.group.toLowerCase().includes(query) ||
        cmd.badge.toLowerCase().includes(query)
      );
    }

    renderCommands();
  }

  function handleKeydown(e) {
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      selectedIndex = (selectedIndex + 1) % filteredCommands.length;
      renderCommands();
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      selectedIndex = (selectedIndex - 1 + filteredCommands.length) % filteredCommands.length;
      renderCommands();
    } else if (e.key === 'Enter') {
      e.preventDefault();
      window.cmdPaletteExec(selectedIndex);
    } else if (e.key === 'Escape') {
      closePalette();
    }
  }

  window.cmdPaletteExec = function (index) {
    const cmd = filteredCommands[index];
    if (!cmd) return;

    closePalette();

    if (cmd.action === 'openWizard') {
      if (typeof window.openComplianceWizard === 'function') {
        window.openComplianceWizard();
      } else {
        window.location.href = 'index.html#wizard';
      }
    } else if (cmd.action === 'toggleTheme') {
      if (typeof window.toggleTheme === 'function') {
        window.toggleTheme();
      } else {
        const curTheme = document.documentElement.getAttribute('data-theme') || 'dark';
        document.documentElement.setAttribute('data-theme', curTheme === 'dark' ? 'light' : 'dark');
      }
    } else if (cmd.url) {
      window.location.href = cmd.url;
    }
  };

  function openPalette() {
    injectDOM();
    const backdrop = document.getElementById('cmdPaletteBackdrop');
    const input = document.getElementById('cmdPaletteInput');

    backdrop.classList.add('active');
    input.value = '';
    filteredCommands = [...COMMAND_DATA];
    selectedIndex = 0;
    renderCommands();

    setTimeout(() => input.focus(), 50);
  }

  function closePalette() {
    const backdrop = document.getElementById('cmdPaletteBackdrop');
    if (backdrop) {
      backdrop.classList.remove('active');
    }
  }

  // Global Key Listener for Ctrl+K and Cmd+K
  document.addEventListener('keydown', function (e) {
    if ((e.ctrlKey || e.metaKey) && (e.key === 'k' || e.key === 'K')) {
      e.preventDefault();
      const backdrop = document.getElementById('cmdPaletteBackdrop');
      if (backdrop && (backdrop.classList.contains('active') || backdrop.classList.contains('open'))) {
        closePalette();
      } else {
        openPalette();
      }
    }
  });

  // Global Click Trigger Delegation
  document.addEventListener('click', function (e) {
    const trigger = e.target.closest && e.target.closest('.cmd-palette-trigger, [data-action="cmd-palette"], .btn-sidebar-search');
    if (trigger) {
      e.preventDefault();
      openPalette();
    }
  });

  window.openCommandPalette = openPalette;
  window.closeCommandPalette = closePalette;
})();

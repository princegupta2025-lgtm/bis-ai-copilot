/* ==========================================================================
   BIS MANAK-AI — Centralized Global Theme System (Default Dark SaaS Mode)
   ========================================================================== */

(function () {
  const STORAGE_KEY = 'bis_manak_theme';

  function getPreferredTheme() {
    const savedTheme = localStorage.getItem(STORAGE_KEY);
    if (savedTheme === 'dark' || savedTheme === 'light') {
      return savedTheme;
    }
    // Default theme for BIS MANAK-AI is always dark
    return 'dark';
  }

  function applyTheme(theme) {
    const targetTheme = (theme === 'light') ? 'light' : 'dark';
    if (document.documentElement) {
      document.documentElement.setAttribute('data-theme', targetTheme);
    }
    if (document.body) {
      document.body.setAttribute('data-theme', targetTheme);
    }
    updateToggleIcons(targetTheme);
    
    // Sync checkbox in settings modal if present
    const settingsToggle = document.getElementById('darkModeCheckbox');
    if (settingsToggle) {
      settingsToggle.checked = (targetTheme === 'dark');
    }
  }

  function updateToggleIcons(theme) {
    const toggleBtns = document.querySelectorAll('.theme-toggle-btn');
    toggleBtns.forEach(btn => {
      const icon = btn.querySelector('i');
      if (icon) {
        if (theme === 'dark') {
          icon.className = 'fas fa-sun';
          btn.setAttribute('title', 'Switch to Light Mode');
          btn.setAttribute('aria-label', 'Switch to Light Mode');
        } else {
          icon.className = 'fas fa-moon';
          btn.setAttribute('title', 'Switch to Dark Mode');
          btn.setAttribute('aria-label', 'Switch to Dark Mode');
        }
      }
    });
  }

  window.toggleTheme = function () {
    const currentTheme = (document.documentElement.getAttribute('data-theme') === 'light') ? 'light' : 'dark';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    localStorage.setItem(STORAGE_KEY, newTheme);
    applyTheme(newTheme);
  };

  // Execute immediately to enforce consistent dark theme
  const initialTheme = getPreferredTheme();
  applyTheme(initialTheme);

  document.addEventListener('DOMContentLoaded', () => {
    applyTheme(getPreferredTheme());
  });
})();

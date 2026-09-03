/* ==========================================================================
   BIS MANAK-AI — Centralized Global Theme System (Light / Dark Mode)
   ========================================================================== */

(function () {
  const STORAGE_KEY = 'theme';

  function getPreferredTheme() {
    const savedTheme = localStorage.getItem(STORAGE_KEY);
    if (savedTheme === 'dark' || savedTheme === 'light') {
      return savedTheme;
    }
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  function applyTheme(theme) {
    if (document.documentElement) {
      document.documentElement.setAttribute('data-theme', theme);
    }
    if (document.body) {
      document.body.setAttribute('data-theme', theme);
    }
    updateToggleIcons(theme);
    
    // Sync checkbox in settings modal if present
    const settingsToggle = document.getElementById('darkModeCheckbox');
    if (settingsToggle) {
      settingsToggle.checked = (theme === 'dark');
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
    const currentTheme = (document.documentElement.getAttribute('data-theme') === 'dark') ? 'dark' : 'light';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    localStorage.setItem(STORAGE_KEY, newTheme);
    applyTheme(newTheme);
  };

  // Execute immediately to prevent flash of light theme
  const initialTheme = getPreferredTheme();
  applyTheme(initialTheme);

  document.addEventListener('DOMContentLoaded', () => {
    applyTheme(getPreferredTheme());

    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      if (!localStorage.getItem(STORAGE_KEY)) {
        applyTheme(e.matches ? 'dark' : 'light');
      }
    });
  });
})();

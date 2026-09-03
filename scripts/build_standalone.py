#!/usr/bin/env python3
"""
BIS TRUST COPILOT — STANDALONE APP BUNDLE GENERATOR
Bundles all stabilized modular source files (HTML, CSS, JS, Registries, Engines)
into a single-file standalone distribution (standalone_app.html).
"""

import os
import re

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def build_standalone():
    print("Building synchronized standalone_app.html...")

    chat_html_path = os.path.join(ROOT_DIR, 'chat.html')
    css_path = os.path.join(ROOT_DIR, 'css', 'style.css')
    theme_js_path = os.path.join(ROOT_DIR, 'js', 'theme.js')
    database_js_path = os.path.join(ROOT_DIR, 'js', 'database.js')
    wizard_js_path = os.path.join(ROOT_DIR, 'js', 'wizard.js')
    cmd_js_path = os.path.join(ROOT_DIR, 'js', 'command-palette.js')
    chat_js_path = os.path.join(ROOT_DIR, 'js', 'chat.js')

    with open(chat_html_path, 'r', encoding='utf-8') as f:
        html = f.read()

    css_content = ""
    if os.path.exists(css_path):
        with open(css_path, 'r', encoding='utf-8') as f:
            css_content = f.read()

    with open(theme_js_path, 'r', encoding='utf-8') as f:
        theme_js = f.read()

    with open(database_js_path, 'r', encoding='utf-8') as f:
        database_js = f.read()

    with open(wizard_js_path, 'r', encoding='utf-8') as f:
        wizard_js = f.read()

    with open(cmd_js_path, 'r', encoding='utf-8') as f:
        cmd_js = f.read()

    with open(chat_js_path, 'r', encoding='utf-8') as f:
        chat_js = f.read()

    # Replace <link rel="stylesheet" href="css/style.css"> with inline style
    style_tag = f"<style>\n{css_content}\n</style>"
    html = re.sub(r'<link\s+rel=["\']stylesheet["\']\s+href=["\']css/style\.css(?:\?[^"\']*)?["\']\s*/?>', lambda m: style_tag, html)

    # Replace external script tags with bundled scripts
    bundled_scripts = f"""
  <script>
/* ==========================================================================
   BUNDLED THEME SYSTEM (js/theme.js)
   ========================================================================== */
{theme_js}

/* ==========================================================================
   BUNDLED STATUTORY STANDARDS & REGISTRY DATABASE (js/database.js)
   ========================================================================== */
{database_js}

/* ==========================================================================
   BUNDLED COMPLIANCE WIZARD & ROADMAP (js/wizard.js)
   ========================================================================== */
{wizard_js}

/* ==========================================================================
   BUNDLED GLOBAL COMMAND PALETTE (js/command-palette.js)
   ========================================================================== */
{cmd_js}

/* ==========================================================================
   BUNDLED CHAT & REAL OCR VERIFICATION ENGINE (js/chat.js)
   ========================================================================== */
{chat_js}
  </script>
"""

    # Remove the existing script src tags
    html = re.sub(r'<script\s+src=["\']js/(?:database|chat|command-palette|wizard|theme)\.js(?:\?[^"\']*)?["\']\s*></script>\s*', '', html)

    # Insert bundled_scripts before the closing </body> tag or before service worker script
    if '<script>' in html:
        # insert before the final script block
        last_script_idx = html.rfind('<script>')
        html = html[:last_script_idx] + bundled_scripts + html[last_script_idx:]
    else:
        html = html.replace('</body>', bundled_scripts + '\n</body>')

    out_path = os.path.join(ROOT_DIR, 'standalone_app.html')
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(html)

    print(f"[OK] Successfully compiled standalone_app.html ({os.path.getsize(out_path):,} bytes)")

if __name__ == '__main__':
    build_standalone()

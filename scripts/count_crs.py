import re, os

with open(r'C:\Users\mg910\.gemini\antigravity-ide\brain\837e5e66-64c6-4ca6-ac2f-0af06c190c96\.system_generated\steps\234\content.md', 'r', encoding='utf-8') as f:
    text = f.read()

matches = re.findall(r'<a\s+href="([^"]+\.pdf)"', text)
print('Total PDF links in CRS circulars page:', len(matches))

rows = re.findall(r'<tr>[\s\S]*?</tr>', text)
print('Total table rows in CRS circulars page:', len(rows))

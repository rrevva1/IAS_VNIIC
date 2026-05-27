# -*- coding: utf-8 -*-
from pathlib import Path

p = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views" / "arm" / "index.php"
text = p.read_text(encoding="utf-8")
start = text.index('    <header class="arm-page__header">')
end = text.index('<input type="file" id="armImportFileInput"')

new_block = Path(__file__).with_name("arm_index_chrome.snippet").read_text(encoding="utf-8")
text = text[:start] + new_block + "\n" + text[end:]
p.write_text(text, encoding="utf-8")
print("patched ok")

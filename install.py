#!/usr/bin/env python3
"""Install TuxWalk into an existing Caelestia shell, preserving original files."""
import json
import os
from pathlib import Path
import shutil
from datetime import datetime

source = Path(__file__).resolve().parent
config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
shell = config / "quickshell/caelestia"
bar = shell / "modules/bar/Bar.qml"
settings = config / "caelestia/shell.json"
marker = '        DelegateChoice {\n            roleValue: "clock"'
choice = '''        DelegateChoice {
            roleValue: "tuxwalk"
            delegate: EntryWrapper {
                TuxWalk {
                    objectName: "taskbarTuxWalk"
                }
            }
        }
'''
legacy_choice = '''        DelegateChoice {
            roleValue: "catwalk"
            delegate: EntryWrapper {
                CatWalk {
                    objectName: "taskbarCatWalk"
                }
            }
        }
'''
if not bar.is_file():
    raise SystemExit(f"Caelestia bar not found at {bar}. Install Caelestia first.")
for name in ("TuxWalk.qml", "TuxSprite.qml", "TuxMotion.js"):
    if not (source / "components" / name).is_file():
        raise SystemExit(f"Missing components/{name}. Extract the entire ZIP before installing.")
text = bar.read_text()
data = json.loads(settings.read_text()) if settings.exists() else {}
if 'roleValue: "tuxwalk"' not in text:
    if legacy_choice in text:
        text = text.replace(legacy_choice, choice, 1)
    elif marker in text:
        text = text.replace(marker, choice + marker, 1)
    else:
        raise SystemExit("Cannot locate Caelestia's clock delegate. No files changed.")
entries = data.setdefault("bar", {}).setdefault("entries", {})
old_entries = [item for section in ("start", "center", "end")
               for item in entries.get(section, []) if item.get("id") == "catwalk"]
new_entries = [item for section in ("start", "center", "end")
               for item in entries.get(section, []) if item.get("id") == "tuxwalk"]
if old_entries and new_entries:
    raise SystemExit("Both old and new penguin entries are present; no files changed.")
for item in old_entries:
    item["id"] = "tuxwalk"
# Preserve an existing placement, including entries in another section.
if not any(item.get("id") == "tuxwalk"
           for section in ("start", "center", "end")
           for item in entries.get(section, [])):
    start = entries.setdefault("start", [
        {"id": "logo", "enabled": True},
        {"id": "workspaces", "enabled": True},
    ])
    index = next((i + 1 for i, item in enumerate(start)
                  if item.get("id") == "workspaces"), len(start))
    start.insert(index, {"id": "tuxwalk", "enabled": True})
backup = source / "backups" / datetime.now().strftime("%Y%m%d-%H%M%S-%f")
backup.mkdir(parents=True)
shutil.copy2(bar, backup / "Bar.qml")
if settings.exists():
    shutil.copy2(settings, backup / "shell.json")
for name in ("TuxWalk.qml", "TuxSprite.qml", "TuxMotion.js"):
    target = shell / "modules/bar/components" / name
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        shutil.copy2(target, backup / name)
    shutil.copy2(source / "components" / name, target)
bar.write_text(text)
settings.parent.mkdir(parents=True, exist_ok=True)
settings.write_text(json.dumps(data, indent=4, ensure_ascii=False) + "\n")
print(f"Installed TuxWalk (existing placement preserved; new installs go after workspaces). Backup: {backup}")
print("Restart Caelestia to load the new QML component: caelestia shell -r -d")

#!/usr/bin/env python3
"""Install CatWalk into an existing Caelestia shell, preserving original files."""
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
for name in ("CatWalk.qml", "CatSprite.qml", "CatMotion.js"):
    if not (source / "components" / name).is_file():
        raise SystemExit(f"Missing components/{name}. Extract the entire ZIP before installing.")
text = bar.read_text()
data = json.loads(settings.read_text()) if settings.exists() else {}
if 'roleValue: "catwalk"' not in text:
    if marker not in text:
        raise SystemExit("Cannot locate Caelestia's clock delegate. No files changed.")
    text = text.replace(marker, choice + marker, 1)
entries = data.setdefault("bar", {}).setdefault("entries", {})
# Preserve an existing placement, including entries in another section.
if not any(item.get("id") == "catwalk"
           for section in ("start", "center", "end")
           for item in entries.get(section, [])):
    start = entries.setdefault("start", [
        {"id": "logo", "enabled": True},
        {"id": "workspaces", "enabled": True},
    ])
    index = next((i + 1 for i, item in enumerate(start)
                  if item.get("id") == "workspaces"), len(start))
    start.insert(index, {"id": "catwalk", "enabled": True})
backup = source / "backups" / datetime.now().strftime("%Y%m%d-%H%M%S-%f")
backup.mkdir(parents=True)
shutil.copy2(bar, backup / "Bar.qml")
if settings.exists():
    shutil.copy2(settings, backup / "shell.json")
for name in ("CatWalk.qml", "CatSprite.qml", "CatMotion.js"):
    target = shell / "modules/bar/components" / name
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        shutil.copy2(target, backup / name)
    shutil.copy2(source / "components" / name, target)
bar.write_text(text)
settings.parent.mkdir(parents=True, exist_ok=True)
settings.write_text(json.dumps(data, indent=4, ensure_ascii=False) + "\n")
print(f"Installed CatWalk (existing placement preserved; new installs go after workspaces). Backup: {backup}")
print("Restart Caelestia to load the new QML component: caelestia shell -r -d")

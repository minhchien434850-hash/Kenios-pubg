#!/usr/bin/env python3
import os, json, sys
from pathlib import Path

REQUIRED_FILES = [
    "Makefile", "config/offsets.json", "config/anticheat.json", "config/skins.json",
    "config/menu.json", "config/config.json", "config/languages.json",
    "headers/KeniosCommon.h", "src/KeniosLoader.mm", "src/KeniosAimbot.mm",
    "server/server.js", "scripts/build_ipa.sh", ".github/workflows/main.yml"
]

def check_project(project_dir):
    missing = []
    for file in REQUIRED_FILES:
        if not os.path.exists(os.path.join(project_dir, file)):
            missing.append(file)
    if missing:
        print("❌ Missing files:")
        for m in missing: print(f"  - {m}")
        return False
    print("✅ All required files present")
    return True

if __name__ == "__main__":
    project_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    sys.exit(0 if check_project(project_dir) else 1)

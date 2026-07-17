#!/usr/bin/env python3
"""KENIOS HAX - Auto Update Checker for iOS 16.0-26.5"""
import json, requests, sys
from datetime import datetime, timezone

APP_ID = "1330123889"
OFFSETS_FILE = "config/offsets.json"

def check_version():
    try:
        r = requests.get(f"https://itunes.apple.com/lookup?id={APP_ID}&country=us", timeout=15)
        data = r.json()
        return data['results'][0]['version'] if data['resultCount'] > 0 else None
    except: return None

def update_offsets(version):
    try:
        with open(OFFSETS_FILE, 'r') as f: offsets = json.load(f)
    except: offsets = {}
    if offsets.get('game_version') == version:
        print(f"✅ Up to date: {version}")
        return False
    offsets['game_version'] = version
    offsets['last_updated'] = datetime.now(timezone.utc).isoformat()
    offsets['needs_verification'] = True
    with open(OFFSETS_FILE, 'w') as f: json.dump(offsets, f, indent=2)
    print(f"⚠️ Updated to version {version}")
    return True

if __name__ == "__main__":
    v = check_version()
    if v: update_offsets(v)
    else: print("❌ Cannot check version")

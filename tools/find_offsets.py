#!/usr/bin/env python3
"""
KENIOS HAX - Auto Offset Finder v2.0
Hỗ trợ: iOS 16.0 - 26.5 | PUBG Mobile 4.x
"""

import struct, sys, os, json, hashlib
from datetime import datetime, timezone

BINARY_PATH = "pubg_extracted/Payload/PUBGM.app/PUBGM"
OUTPUT_PATH = "config/offsets.json"
BASE_ADDRESS = 0x100000000

PATTERNS = {
    "GWorld": {"pattern": b'\x48\x8B\x1D', "type": "rip_relative", "desc": "GWorld pointer", "required": True},
    "GNames": {"pattern": b'\x48\x8D\x0D', "type": "rip_relative", "desc": "GNames pointer", "required": True},
    "PersistentLevel": {"pattern": b'\x48\x8B\x8B', "type": "offset", "desc": "UWorld->PersistentLevel", "required": True},
    "Actors": {"pattern": b'\x48\x8B\x87', "type": "offset", "desc": "ULevel->Actors", "required": True},
    "Mesh": {"pattern": b'\x48\x8B\x88', "type": "offset", "desc": "AActor->Mesh", "required": True},
    "PlayerController": {"pattern": b'\x48\x8B\x98', "type": "offset", "desc": "AActor->PlayerController", "required": True},
    "PlayerState": {"pattern": b'\x48\x8B\xB8', "type": "offset", "desc": "APawn->PlayerState", "required": True},
    "PlayerCameraManager": {"pattern": b'\x48\x8B\xB9', "type": "offset", "desc": "PlayerCameraManager", "required": True},
    "ControlRotation": {"pattern": b'\xF3\x0F\x11\x89', "type": "offset", "desc": "ControlRotation", "required": True},
    "TeamID": {"pattern": b'\x8B\x88', "type": "offset", "desc": "TeamID", "required": True},
    "Health": {"pattern": b'\xF3\x0F\x10\x88', "type": "offset", "desc": "Health", "required": True},
    "CurrentAmmo": {"pattern": b'\x8B\x80', "type": "offset", "desc": "CurrentAmmo", "required": False},
    "ViewMatrix": {"pattern": b'\x48\x8D\xB9', "type": "offset", "desc": "ViewMatrix", "required": True},
    "RootComponent": {"pattern": b'\x48\x8B\x80', "type": "offset", "desc": "RootComponent", "required": True},
    "ComponentToWorld": {"pattern": b'\x48\x8D\xA0', "type": "offset", "desc": "ComponentToWorld", "required": True},
    "BoneArray": {"pattern": b'\x48\x8B\xB8', "type": "offset", "desc": "BoneArray", "required": True},
}

class OffsetFinder:
    def __init__(self, binary_path):
        self.binary_path = binary_path
        self.data = None
        self.results = {}

    def load_binary(self):
        if not os.path.exists(self.binary_path):
            print(f"❌ File không tồn tại: {self.binary_path}")
            return False
        with open(self.binary_path, 'rb') as f:
            self.data = f.read()
        print(f"✅ Đã đọc {len(self.data):,} bytes")
        return True

    def find_pattern_positions(self, pattern):
        positions = []
        pos = 0
        while True:
            pos = self.data.find(pattern, pos)
            if pos == -1: break
            positions.append(pos)
            pos += 1
        return positions

    def extract_offset(self, position):
        try:
            return struct.unpack('<i', self.data[position+3:position+7])[0]
        except:
            return 0

    def find_all_offsets(self):
        print(f"\n🔍 Đang quét {len(PATTERNS)} patterns...")
        for name, config in PATTERNS.items():
            positions = self.find_pattern_positions(config['pattern'])
            if positions:
                offset_val = self.extract_offset(positions[0])
                real_addr = BASE_ADDRESS + positions[0] + offset_val if config['type'] == 'rip_relative' else offset_val
                self.results[name] = {'offset': offset_val, 'real_address': real_addr, 'found': True}
                print(f"✅ {name:<22} = 0x{offset_val:04X}")
            else:
                self.results[name] = {'found': False}
                print(f"❌ {name:<22} = NOT FOUND")

    def save_results(self, output_path):
        output = {"version": "auto", "last_updated": datetime.now(timezone.utc).isoformat(), "offsets": {}}
        for name, data in self.results.items():
            if data.get('found'):
                output['offsets'][name] = data['real_address'] if name in ['GWorld','GNames'] else data['offset']
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'w') as f:
            json.dump(output, f, indent=2)
        print(f"\n💾 Đã lưu vào: {output_path}")

if __name__ == "__main__":
    binary_path = sys.argv[1] if len(sys.argv) > 1 else BINARY_PATH
    output_path = sys.argv[2] if len(sys.argv) > 2 else OUTPUT_PATH
    finder = OffsetFinder(binary_path)
    if finder.load_binary():
        finder.find_all_offsets()
        finder.save_results(output_path)

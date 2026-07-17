# 📖 KENIOS HAX - HƯỚNG DẪN CHI TIẾT TỪ A-Z

## 1. CHUẨN BỊ MÔI TRƯỜNG
- macOS + Xcode
- Cài Theos: `git clone --recursive https://github.com/theos/theos.git ~/theos`
- Cài Node.js: `brew install node`

## 2. LẤY IPA GỐC
- Dùng App Store++ hoặc iMazing để lấy file IPA PUBG Mobile

## 3. TÌM OFFSETS
```bash
python3 tools/find_offsets.py "pubg_extracted/Payload/PUBGM.app/PUBGM" "config/offsets.json"

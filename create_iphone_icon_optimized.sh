#!/bin/bash
# iPhone Icon - Optimize Edilmiş
# iPhone için safe area ve hizalama ile icon oluşturur

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# iPhone için özel optimize edilmiş icon dosyası
IPHONE_ICON="$PROJECT_ROOT/master_icon_sade_iphone.png"

# Eğer özel iPhone icon yoksa, normal icon'u kullan
if [ ! -f "$IPHONE_ICON" ]; then
    IPHONE_ICON="$PROJECT_ROOT/master_icon_sade_1024.png"
fi

if [ ! -f "$IPHONE_ICON" ]; then
    IPHONE_ICON="$PROJECT_ROOT/master_icon_sade.png"
fi

if [ ! -f "$IPHONE_ICON" ]; then
    echo "❌ iPhone icon dosyası bulunamadı!"
    echo "💡 Lütfen master_icon_sade_iphone.png dosyasını oluşturun (safe area ile)"
    exit 1
fi

OUTPUT_DIR="$PROJECT_ROOT/Arium/Assets.xcassets/AppIcon.appiconset"

echo "📱 iPhone Icon (Optimize Edilmiş) Oluşturuluyor..."
echo "📁 Kaynak: $IPHONE_ICON"
echo "📁 Çıktı: $OUTPUT_DIR"
echo ""

# Çıktı dizinini oluştur
mkdir -p "$OUTPUT_DIR"

# iPhone icon boyutlarını oluştur
echo "📦 Icon boyutları oluşturuluyor..."

# iPhone
sips -z 40 40 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-20@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-20@2x.png (40x40px)"
sips -z 60 60 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-20@3x.png" > /dev/null 2>&1 && echo "✅ AppIcon-20@3x.png (60x60px)"
sips -z 58 58 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-29@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-29@2x.png (58x58px)"
sips -z 87 87 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-29@3x.png" > /dev/null 2>&1 && echo "✅ AppIcon-29@3x.png (87x87px)"
sips -z 80 80 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-40@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-40@2x.png (80x80px)"
sips -z 120 120 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-40@3x.png" > /dev/null 2>&1 && echo "✅ AppIcon-40@3x.png (120x120px)"
sips -z 120 120 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-60@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-60@2x.png (120x120px)"
sips -z 180 180 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-60@3x.png" > /dev/null 2>&1 && echo "✅ AppIcon-60@3x.png (180x180px)"

# iPad
sips -z 20 20 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-20@1x.png" > /dev/null 2>&1 && echo "✅ AppIcon-20@1x.png (20x20px)"
sips -z 40 40 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-20@2x-ipad.png" > /dev/null 2>&1 && echo "✅ AppIcon-20@2x-ipad.png (40x40px)"
sips -z 29 29 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-29@1x.png" > /dev/null 2>&1 && echo "✅ AppIcon-29@1x.png (29x29px)"
sips -z 58 58 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-29@2x-ipad.png" > /dev/null 2>&1 && echo "✅ AppIcon-29@2x-ipad.png (58x58px)"
sips -z 40 40 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-40@1x.png" > /dev/null 2>&1 && echo "✅ AppIcon-40@1x.png (40x40px)"
sips -z 80 80 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-40@2x-ipad.png" > /dev/null 2>&1 && echo "✅ AppIcon-40@2x-ipad.png (80x80px)"
sips -z 76 76 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-76@1x.png" > /dev/null 2>&1 && echo "✅ AppIcon-76@1x.png (76x76px)"
sips -z 152 152 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-76@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-76@2x.png (152x152px)"
sips -z 167 167 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-83.5@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-83.5@2x.png (167x167px)"

# App Store
sips -z 1024 1024 "$IPHONE_ICON" --out "$OUTPUT_DIR/AppIcon-1024.png" > /dev/null 2>&1 && echo "✅ AppIcon-1024.png (1024x1024px)"

echo ""
echo "✨ iPhone icon'ları hazır!"
echo ""
echo "💡 Not: Icon'un safe area (%10-15) ile hazırlandığından emin olun."




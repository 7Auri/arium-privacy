#!/bin/bash
# iOS App Icon Generator (macOS sips kullanarak)

set -e

# Master icon dosyasını bul
MASTER_ICON=""
POSSIBLE_NAMES=(
    "master_icon_sade.png"
    "master-icon-sade.png"
    "master_icon.png"
    "icon_master.png"
    "AppIcon-master.png"
)

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Dosyayı ara
for name in "${POSSIBLE_NAMES[@]}"; do
    if [ -f "$PROJECT_ROOT/$name" ]; then
        MASTER_ICON="$PROJECT_ROOT/$name"
        break
    fi
done

# Komut satırından da alabilir
if [ -n "$1" ] && [ -f "$1" ]; then
    MASTER_ICON="$1"
fi

if [ -z "$MASTER_ICON" ] || [ ! -f "$MASTER_ICON" ]; then
    echo "📋 Kullanım:"
    echo "   ./create_app_icons.sh <master_icon_path>"
    echo ""
    echo "💡 Master icon dosyasını proje kök dizinine ekleyin:"
    echo "   - master_icon_sade.png (1024x1024px)"
    echo ""
    echo "   Veya komut satırından:"
    echo "   ./create_app_icons.sh /path/to/master_icon_sade.png"
    exit 1
fi

OUTPUT_DIR="$PROJECT_ROOT/Arium/Assets.xcassets/AppIcon.appiconset"

echo "🎨 iOS App Icon Generator"
echo "📁 Master icon: $MASTER_ICON"
echo "📁 Çıktı dizini: $OUTPUT_DIR"
echo ""

# Çıktı dizinini oluştur
mkdir -p "$OUTPUT_DIR"

# Icon boyutlarını oluştur
echo "📦 Icon boyutları oluşturuluyor..."

# iPhone
sips -z 40 40 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-20@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-20@2x.png (40x40px)"
sips -z 60 60 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-20@3x.png" > /dev/null 2>&1 && echo "✅ AppIcon-20@3x.png (60x60px)"
sips -z 58 58 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-29@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-29@2x.png (58x58px)"
sips -z 87 87 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-29@3x.png" > /dev/null 2>&1 && echo "✅ AppIcon-29@3x.png (87x87px)"
sips -z 80 80 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-40@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-40@2x.png (80x80px)"
sips -z 120 120 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-40@3x.png" > /dev/null 2>&1 && echo "✅ AppIcon-40@3x.png (120x120px)"
sips -z 120 120 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-60@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-60@2x.png (120x120px)"
sips -z 180 180 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-60@3x.png" > /dev/null 2>&1 && echo "✅ AppIcon-60@3x.png (180x180px)"

# iPad
sips -z 20 20 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-20@1x.png" > /dev/null 2>&1 && echo "✅ AppIcon-20@1x.png (20x20px)"
sips -z 40 40 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-20@2x-ipad.png" > /dev/null 2>&1 && echo "✅ AppIcon-20@2x-ipad.png (40x40px)"
sips -z 29 29 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-29@1x.png" > /dev/null 2>&1 && echo "✅ AppIcon-29@1x.png (29x29px)"
sips -z 58 58 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-29@2x-ipad.png" > /dev/null 2>&1 && echo "✅ AppIcon-29@2x-ipad.png (58x58px)"
sips -z 40 40 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-40@1x.png" > /dev/null 2>&1 && echo "✅ AppIcon-40@1x.png (40x40px)"
sips -z 80 80 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-40@2x-ipad.png" > /dev/null 2>&1 && echo "✅ AppIcon-40@2x-ipad.png (80x80px)"
sips -z 76 76 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-76@1x.png" > /dev/null 2>&1 && echo "✅ AppIcon-76@1x.png (76x76px)"
sips -z 152 152 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-76@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-76@2x.png (152x152px)"
sips -z 167 167 "$MASTER_ICON" --out "$OUTPUT_DIR/AppIcon-83.5@2x.png" > /dev/null 2>&1 && echo "✅ AppIcon-83.5@2x.png (167x167px)"

# App Store (1024x1024 - zaten master icon)
cp "$MASTER_ICON" "$OUTPUT_DIR/AppIcon-1024.png" && echo "✅ AppIcon-1024.png (1024x1024px)"

echo ""
echo "🎉 Tüm icon boyutları oluşturuldu!"
echo "✨ Icon'lar $OUTPUT_DIR dizinine eklendi."




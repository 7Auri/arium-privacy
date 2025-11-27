#!/bin/bash
# Uygulama içi icon'ları oluştur (SADE ve DETAYLI)

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Master icon dosyalarını bul
MASTER_SADE=""
MASTER_DETAYLI=""

POSSIBLE_SADE=(
    "master_icon_sade.png"
    "master-icon-sade.png"
    "icon_sade.png"
    "sade.png"
)

POSSIBLE_DETAYLI=(
    "master_icon_detayli.png"
    "master-icon-detayli.png"
    "icon_detayli.png"
    "detayli.png"
)

# SADE icon'u ara
for name in "${POSSIBLE_SADE[@]}"; do
    if [ -f "$PROJECT_ROOT/$name" ]; then
        MASTER_SADE="$PROJECT_ROOT/$name"
        break
    fi
done

# DETAYLI icon'u ara
for name in "${POSSIBLE_DETAYLI[@]}"; do
    if [ -f "$PROJECT_ROOT/$name" ]; then
        MASTER_DETAYLI="$PROJECT_ROOT/$name"
        break
    fi
done

# Komut satırından da alabilir
if [ -n "$1" ] && [ -f "$1" ]; then
    MASTER_SADE="$1"
fi

if [ -n "$2" ] && [ -f "$2" ]; then
    MASTER_DETAYLI="$2"
fi

OUTPUT_SADE="$PROJECT_ROOT/Arium/Assets.xcassets/AppIconSade.imageset"
OUTPUT_DETAYLI="$PROJECT_ROOT/Arium/Assets.xcassets/AppIconDetayli.imageset"

echo "🎨 Uygulama İçi Icon Generator"
echo ""

# SADE icon'ları oluştur
if [ -n "$MASTER_SADE" ] && [ -f "$MASTER_SADE" ]; then
    echo "📦 SADE icon boyutları oluşturuluyor..."
    mkdir -p "$OUTPUT_SADE"
    
    # 1x, 2x, 3x boyutları (genellikle 1024x1024'ten oluşturulur)
    # Uygulama içinde kullanım için 512x512, 1024x1024, 1536x1536 gibi boyutlar uygun
    sips -z 512 512 "$MASTER_SADE" --out "$OUTPUT_SADE/AppIconSade.png" > /dev/null 2>&1 && echo "✅ AppIconSade.png (512x512px)"
    sips -z 1024 1024 "$MASTER_SADE" --out "$OUTPUT_SADE/AppIconSade@2x.png" > /dev/null 2>&1 && echo "✅ AppIconSade@2x.png (1024x1024px)"
    sips -z 1536 1536 "$MASTER_SADE" --out "$OUTPUT_SADE/AppIconSade@3x.png" > /dev/null 2>&1 && echo "✅ AppIconSade@3x.png (1536x1536px)"
    echo "✨ SADE icon'ları oluşturuldu!"
else
    echo "⚠️  SADE master icon bulunamadı. Lütfen dosyayı ekleyin:"
    echo "   - master_icon_sade.png (1024x1024px)"
fi

echo ""

# DETAYLI icon'ları oluştur
if [ -n "$MASTER_DETAYLI" ] && [ -f "$MASTER_DETAYLI" ]; then
    echo "📦 DETAYLI icon boyutları oluşturuluyor..."
    mkdir -p "$OUTPUT_DETAYLI"
    
    sips -z 512 512 "$MASTER_DETAYLI" --out "$OUTPUT_DETAYLI/AppIconDetayli.png" > /dev/null 2>&1 && echo "✅ AppIconDetayli.png (512x512px)"
    sips -z 1024 1024 "$MASTER_DETAYLI" --out "$OUTPUT_DETAYLI/AppIconDetayli@2x.png" > /dev/null 2>&1 && echo "✅ AppIconDetayli@2x.png (1024x1024px)"
    sips -z 1536 1536 "$MASTER_DETAYLI" --out "$OUTPUT_DETAYLI/AppIconDetayli@3x.png" > /dev/null 2>&1 && echo "✅ AppIconDetayli@3x.png (1536x1536px)"
    echo "✨ DETAYLI icon'ları oluşturuldu!"
else
    echo "⚠️  DETAYLI master icon bulunamadı. Lütfen dosyayı ekleyin:"
    echo "   - master_icon_detayli.png (1024x1024px)"
fi

echo ""
echo "📋 Kullanım:"
echo "   Swift kodunda:"
echo "   Image(\"AppIconSade\")"
echo "   Image(\"AppIconDetayli\")"




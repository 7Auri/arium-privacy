#!/bin/bash
# Icon dosyalarını indir ve kur

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
DOWNLOAD_DIR="$PROJECT_ROOT/icon_downloads"

echo "📥 Icon dosyalarını hazırlıyorum..."
echo ""

# İndirme dizinini oluştur
mkdir -p "$DOWNLOAD_DIR"

echo "📋 Lütfen görselleri şu şekilde kaydedin:"
echo ""
echo "1. İlk görseli (DETAYLI - iki dalga) PNG olarak kaydedin:"
echo "   Dosya adı: master_icon_detayli.png"
echo "   Boyut: 1024x1024px"
echo "   Konum: $DOWNLOAD_DIR/"
echo ""
echo "2. İkinci görseli (SADE - tek dalga) PNG olarak kaydedin:"
echo "   Dosya adı: master_icon_sade.png"
echo "   Boyut: 1024x1024px"
echo "   Konum: $DOWNLOAD_DIR/"
echo ""
echo "💡 Görselleri kaydetmek için:"
echo "   - Görsele sağ tıklayın → 'Save Image As...'"
echo "   - Veya görseli açıp File → Export → PNG"
echo ""
echo "⏳ Dosyaları ekledikten sonra Enter'a basın..."
read -r

# Dosyaları kontrol et
SADE_FILE="$DOWNLOAD_DIR/master_icon_sade.png"
DETAYLI_FILE="$DOWNLOAD_DIR/master_icon_detayli.png"

if [ ! -f "$SADE_FILE" ]; then
    echo "❌ Hata: $SADE_FILE bulunamadı!"
    echo "   Lütfen dosyayı ekleyin ve tekrar çalıştırın."
    exit 1
fi

if [ ! -f "$DETAYLI_FILE" ]; then
    echo "❌ Hata: $DETAYLI_FILE bulunamadı!"
    echo "   Lütfen dosyayı ekleyin ve tekrar çalıştırın."
    exit 1
fi

echo "✅ Dosyalar bulundu!"
echo ""

# Dosya boyutlarını kontrol et
SADE_SIZE=$(sips -g pixelWidth -g pixelHeight "$SADE_FILE" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | head -1)
DETAYLI_SIZE=$(sips -g pixelWidth -g pixelHeight "$DETAYLI_FILE" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | head -1)

echo "📏 Dosya boyutları:"
echo "   SADE: ${SADE_SIZE}x${SADE_SIZE}px"
echo "   DETAYLI: ${DETAYLI_SIZE}x${DETAYLI_SIZE}px"
echo ""

# Dosyaları proje kök dizinine kopyala
cp "$SADE_FILE" "$PROJECT_ROOT/master_icon_sade.png"
cp "$DETAYLI_FILE" "$PROJECT_ROOT/master_icon_detayli.png"

echo "✅ Dosyalar proje kök dizinine kopyalandı!"
echo ""

# Script'leri çalıştır
echo "🎨 App icon boyutları oluşturuluyor..."
"$PROJECT_ROOT/create_app_icons.sh" "$PROJECT_ROOT/master_icon_sade.png"

echo ""
echo "🎨 Uygulama içi icon boyutları oluşturuluyor..."
"$PROJECT_ROOT/create_internal_icons.sh" "$PROJECT_ROOT/master_icon_sade.png" "$PROJECT_ROOT/master_icon_detayli.png"

echo ""
echo "✨ Tamamlandı! Tüm icon'lar hazır."
echo ""
echo "📁 Oluşturulan dosyalar:"
echo "   - App Icon: Arium/Assets.xcassets/AppIcon.appiconset/"
echo "   - AppIconSade: Arium/Assets.xcassets/AppIconSade.imageset/"
echo "   - AppIconDetayli: Arium/Assets.xcassets/AppIconDetayli.imageset/"


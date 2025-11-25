#!/bin/bash
# Watch Icon - Yuvarlak Mask ile Oluştur
# watchOS için yuvarlak icon oluşturur

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Watch için özel yuvarlak icon dosyası
WATCH_ICON="$PROJECT_ROOT/master_icon_sade_watch.png"

# Eğer özel watch icon yoksa, normal icon'u kullan
if [ ! -f "$WATCH_ICON" ]; then
    WATCH_ICON="$PROJECT_ROOT/master_icon_sade_1024.png"
fi

if [ ! -f "$WATCH_ICON" ]; then
    WATCH_ICON="$PROJECT_ROOT/master_icon_sade.png"
fi

if [ ! -f "$WATCH_ICON" ]; then
    echo "❌ Watch icon dosyası bulunamadı!"
    echo "💡 Lütfen master_icon_sade_watch.png dosyasını oluşturun (yuvarlak mask ile)"
    exit 1
fi

WATCH_OUTPUT="$PROJECT_ROOT/AriumWatch Watch App/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
WIDGET_OUTPUT="$PROJECT_ROOT/AriumWatchWidget/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

echo "⌚ Watch Icon (Yuvarlak) Oluşturuluyor..."
echo "📁 Kaynak: $WATCH_ICON"
echo ""

# Watch icon'ları oluştur
sips -z 1024 1024 "$WATCH_ICON" --out "$WATCH_OUTPUT" > /dev/null 2>&1
echo "✅ Watch App icon: $WATCH_OUTPUT"

sips -z 1024 1024 "$WATCH_ICON" --out "$WIDGET_OUTPUT" > /dev/null 2>&1
echo "✅ Watch Widget Extension icon: $WIDGET_OUTPUT"

echo ""
echo "✨ Watch icon'ları hazır!"
echo ""
echo "💡 Not: Icon'un yuvarlak mask ile hazırlandığından emin olun."


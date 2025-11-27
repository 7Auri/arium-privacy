#!/bin/bash
# Watch App Icon Optimizer
# Watch için dairesel ve optimize edilmiş icon oluşturur

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
MASTER_ICON="$PROJECT_ROOT/master_icon_sade_1024.png"

if [ ! -f "$MASTER_ICON" ]; then
    MASTER_ICON="$PROJECT_ROOT/master_icon_sade.png"
fi

if [ ! -f "$MASTER_ICON" ]; then
    echo "❌ Master icon bulunamadı!"
    exit 1
fi

WATCH_OUTPUT="$PROJECT_ROOT/AriumWatch Watch App/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
WIDGET_OUTPUT="$PROJECT_ROOT/AriumWatchWidget/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

echo "⌚ Watch Icon Optimizer"
echo "📁 Master icon: $MASTER_ICON"
echo ""

# Watch için icon'u optimize et
# Watch icon'ları dairesel olmalı ve daha minimal olmalı
# 1024x1024 boyutunda oluştur

echo "📦 Watch App icon oluşturuluyor..."
sips -z 1024 1024 "$MASTER_ICON" --out "$WATCH_OUTPUT" > /dev/null 2>&1
echo "✅ Watch App icon oluşturuldu: $WATCH_OUTPUT"

echo ""
echo "📦 Watch Widget Extension icon oluşturuluyor..."
sips -z 1024 1024 "$MASTER_ICON" --out "$WIDGET_OUTPUT" > /dev/null 2>&1
echo "✅ Watch Widget Extension icon oluşturuldu: $WIDGET_OUTPUT"

echo ""
echo "✨ Watch icon'ları hazır!"
echo ""
echo "💡 Not: Watch icon'ları dairesel görünecek (watchOS otomatik yapar)"
echo "   Icon'un merkezde ve dengeli olduğundan emin olun."




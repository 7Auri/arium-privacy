#!/bin/bash

# Code Signing Fix Script for AriumWidgetExtension

echo "🔧 Code Signing Hatası Düzeltiliyor..."
echo ""

# Xcode'u kapat (eğer açıksa)
echo "📱 Xcode kontrol ediliyor..."
if pgrep -x "Xcode" > /dev/null; then
    echo "⚠️  Xcode açık. Lütfen Xcode'u kapatın ve tekrar deneyin."
    echo "   Veya Xcode'u kapatmak için: killall Xcode"
    exit 1
fi

# Derived Data'yı temizle
echo "🧹 Derived Data temizleniyor..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Arium-*
echo "✅ Derived Data temizlendi"

# Keychain'i unlock et (eğer parolasız oluşturulduysa)
echo "🔓 Keychain kontrol ediliyor..."
security unlock-keychain login.keychain 2>/dev/null || echo "⚠️  Keychain unlock edilemedi (normal olabilir)"

# Xcode preferences'ten profiles'i kontrol et
echo "📋 Signing ayarları kontrol ediliyor..."
echo ""
echo "✅ Yapılacaklar:"
echo "1. Xcode'u açın"
echo "2. Xcode → Preferences → Accounts"
echo "3. Apple ID'nizi seçin"
echo "4. 'Download Manual Profiles' tıklayın"
echo "5. Project → TARGETS → AriumWidgetExtension → Signing & Capabilities"
echo "6. 'Team' seçin (M3CJJTMW7W)"
echo "7. 'Automatically manage signing' açık olmalı"
echo ""
echo "✨ Script tamamlandı. Yukarıdaki adımları takip edin."




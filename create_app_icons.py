#!/usr/bin/env python3
"""
iOS App Icon Generator
1024x1024 master icon'dan tüm iOS boyutlarını oluşturur
"""

import os
import sys
from PIL import Image
import json

# iOS App Icon boyutları (pt x px)
ICON_SIZES = [
    # iPhone
    {"size": "20x20", "scale": 2, "filename": "AppIcon-20@2x.png", "idiom": "iphone"},  # 40x40
    {"size": "20x20", "scale": 3, "filename": "AppIcon-20@3x.png", "idiom": "iphone"},  # 60x60
    {"size": "29x29", "scale": 2, "filename": "AppIcon-29@2x.png", "idiom": "iphone"},  # 58x58
    {"size": "29x29", "scale": 3, "filename": "AppIcon-29@3x.png", "idiom": "iphone"},  # 87x87
    {"size": "40x40", "scale": 2, "filename": "AppIcon-40@2x.png", "idiom": "iphone"},  # 80x80
    {"size": "40x40", "scale": 3, "filename": "AppIcon-40@3x.png", "idiom": "iphone"},  # 120x120
    {"size": "60x60", "scale": 2, "filename": "AppIcon-60@2x.png", "idiom": "iphone"},  # 120x120
    {"size": "60x60", "scale": 3, "filename": "AppIcon-60@3x.png", "idiom": "iphone"},  # 180x180
    
    # iPad
    {"size": "20x20", "scale": 1, "filename": "AppIcon-20@1x.png", "idiom": "ipad"},  # 20x20
    {"size": "20x20", "scale": 2, "filename": "AppIcon-20@2x-ipad.png", "idiom": "ipad"},  # 40x40
    {"size": "29x29", "scale": 1, "filename": "AppIcon-29@1x.png", "idiom": "ipad"},  # 29x29
    {"size": "29x29", "scale": 2, "filename": "AppIcon-29@2x-ipad.png", "idiom": "ipad"},  # 58x58
    {"size": "40x40", "scale": 1, "filename": "AppIcon-40@1x.png", "idiom": "ipad"},  # 40x40
    {"size": "40x40", "scale": 2, "filename": "AppIcon-40@2x-ipad.png", "idiom": "ipad"},  # 80x80
    {"size": "76x76", "scale": 1, "filename": "AppIcon-76@1x.png", "idiom": "ipad"},  # 76x76
    {"size": "76x76", "scale": 2, "filename": "AppIcon-76@2x.png", "idiom": "ipad"},  # 152x152
    {"size": "83.5x83.5", "scale": 2, "filename": "AppIcon-83.5@2x.png", "idiom": "ipad"},  # 167x167
    
    # App Store
    {"size": "1024x1024", "scale": 1, "filename": "AppIcon-1024.png", "idiom": "ios-marketing"},  # 1024x1024
]

def create_icon_sizes(master_icon_path, output_dir):
    """Master icon'dan tüm boyutları oluştur"""
    
    if not os.path.exists(master_icon_path):
        print(f"❌ Hata: Master icon dosyası bulunamadı: {master_icon_path}")
        return False
    
    # Master icon'u yükle
    try:
        master_icon = Image.open(master_icon_path)
        if master_icon.size != (1024, 1024):
            print(f"⚠️  Uyarı: Master icon 1024x1024 değil, yeniden boyutlandırılıyor...")
            master_icon = master_icon.resize((1024, 1024), Image.Resampling.LANCZOS)
    except Exception as e:
        print(f"❌ Hata: Master icon yüklenemedi: {e}")
        return False
    
    # Çıktı dizinini oluştur
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"📦 {len(ICON_SIZES)} icon boyutu oluşturuluyor...")
    
    created_files = []
    
    for icon_config in ICON_SIZES:
        # Boyutu hesapla
        size_str = icon_config["size"]
        scale = icon_config["scale"]
        
        # "83.5x83.5" gibi ondalıklı boyutları parse et
        if "x" in size_str:
            width, height = map(float, size_str.split("x"))
            target_size = (int(width * scale), int(height * scale))
        else:
            target_size = (int(size_str) * scale, int(size_str) * scale)
        
        # Icon'u yeniden boyutlandır (yüksek kaliteli)
        resized_icon = master_icon.resize(target_size, Image.Resampling.LANCZOS)
        
        # Dosyayı kaydet
        output_path = os.path.join(output_dir, icon_config["filename"])
        resized_icon.save(output_path, "PNG", optimize=True)
        created_files.append(icon_config["filename"])
        
        print(f"✅ {icon_config['filename']} ({target_size[0]}x{target_size[1]}px) oluşturuldu")
    
    print(f"\n🎉 Toplam {len(created_files)} icon dosyası oluşturuldu!")
    return True

def create_contents_json(output_dir, icon_configs):
    """Contents.json dosyasını oluştur"""
    
    images = []
    
    for config in icon_configs:
        image_entry = {
            "filename": config["filename"],
            "idiom": config["idiom"],
            "size": config["size"],
        }
        
        if config["scale"] > 1:
            image_entry["scale"] = f"{config['scale']}x"
        
        images.append(image_entry)
    
    # Dark mode ve tinted için de ekle (eğer varsa)
    # Şimdilik sadece normal icon'u ekliyoruz
    
    contents = {
        "images": images,
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    contents_path = os.path.join(output_dir, "Contents.json")
    with open(contents_path, "w", encoding="utf-8") as f:
        json.dump(contents, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Contents.json oluşturuldu")

if __name__ == "__main__":
    # Master icon dosyasını bul
    master_icon_path = None
    
    # Olası dosya isimleri
    possible_names = [
        "master_icon_sade.png",
        "master-icon-sade.png",
        "master_icon.png",
        "icon_master.png",
        "AppIcon-master.png",
    ]
    
    # Proje kök dizininde ara
    project_root = os.path.dirname(os.path.abspath(__file__))
    
    for name in possible_names:
        path = os.path.join(project_root, name)
        if os.path.exists(path):
            master_icon_path = path
            break
    
    # Komut satırından da alabilir
    if len(sys.argv) > 1:
        master_icon_path = sys.argv[1]
    
    if not master_icon_path or not os.path.exists(master_icon_path):
        print("📋 Kullanım:")
        print(f"   python3 {sys.argv[0]} <master_icon_path>")
        print("\n💡 Master icon dosyasını proje kök dizinine ekleyin:")
        print("   - master_icon_sade.png (1024x1024px)")
        print("\n   Veya komut satırından:")
        print(f"   python3 {sys.argv[0]} /path/to/master_icon_sade.png")
        sys.exit(1)
    
    # Çıktı dizini
    output_dir = os.path.join(project_root, "Arium", "Assets.xcassets", "AppIcon.appiconset")
    
    print(f"🎨 iOS App Icon Generator")
    print(f"📁 Master icon: {master_icon_path}")
    print(f"📁 Çıktı dizini: {output_dir}\n")
    
    # Icon boyutlarını oluştur
    if create_icon_sizes(master_icon_path, output_dir):
        # Contents.json oluştur
        create_contents_json(output_dir, ICON_SIZES)
        print(f"\n✨ Tamamlandı! Icon'lar {output_dir} dizinine eklendi.")
    else:
        print("\n❌ Hata oluştu!")
        sys.exit(1)


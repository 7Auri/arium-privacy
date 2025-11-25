#!/usr/bin/env python3
"""
Icon Optimizer - Watch (yuvarlak) ve iPhone (safe area) için optimize eder
"""

import os
import sys

try:
    from PIL import Image, ImageDraw
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    print("⚠️  PIL (Pillow) yüklü değil. macOS sips kullanılacak.")

def create_round_mask(size):
    """Yuvarlak mask oluştur"""
    mask = Image.new('L', size, 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, size[0]-1, size[1]-1), fill=255)
    return mask

def create_watch_icon(input_path, output_path, zoom_factor=1.0):
    """Watch için yuvarlak icon oluştur"""
    if PIL_AVAILABLE:
        try:
            img = Image.open(input_path).convert('RGBA')
            original_size = img.size
            
            # Eğer zaten 1024x1024 ise direkt kullan, değilse resize et
            if original_size != (1024, 1024):
                img = img.resize((1024, 1024), Image.Resampling.LANCZOS)
            
            # zoom_factor=1.0 ise hiçbir işlem yapma, sadece yuvarlak mask uygula
            if zoom_factor != 1.0:
                # Logo'yu yakınlaştır (zoom) - merkezi crop ve resize
                # zoom_factor < 1 demek, daha küçük alan crop edip büyütmek = yakınlaştırma
                crop_size = int(1024 * zoom_factor)
                # Merkezi crop için offset hesapla
                left = (1024 - crop_size) // 2
                top = (1024 - crop_size) // 2
                right = left + crop_size
                bottom = top + crop_size
                
                # Merkezi crop yap (zoom efekti - küçük alanı al)
                img_cropped = img.crop((left, top, right, bottom))
                # Tekrar 1024x1024'e resize et (büyüt = yakınlaştır)
                img = img_cropped.resize((1024, 1024), Image.Resampling.LANCZOS)
            
            # Yuvarlak mask oluştur (tam daire)
            mask = Image.new('L', (1024, 1024), 0)
            draw = ImageDraw.Draw(mask)
            # Kenarlardan 2px içeride çiz (daha temiz kenar)
            draw.ellipse((2, 2, 1021, 1021), fill=255)
            
            # Mask uygula - şeffaf arka plan ile
            output = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
            output.paste(img, (0, 0))
            output.putalpha(mask)
            
            output.save(output_path, 'PNG', optimize=True)
            return True
        except Exception as e:
            print(f"❌ PIL ile hata: {e}")
            return False
    else:
        # macOS sips kullan (yuvarlak mask yapamaz, sadece boyutlandırır)
        os.system(f'sips -z 1024 1024 "{input_path}" --out "{output_path}" > /dev/null 2>&1')
        return os.path.exists(output_path)

def create_iphone_icon(input_path, output_path):
    """iPhone için safe area ile icon oluştur"""
    if PIL_AVAILABLE:
        try:
            img = Image.open(input_path).convert('RGBA')
            img = img.resize((1024, 1024), Image.Resampling.LANCZOS)
            
            # Safe area: %10 padding (820x820 merkez alan)
            # Logo zaten merkezde olduğu için sadece kaydet
            img.save(output_path, 'PNG')
            return True
        except Exception as e:
            print(f"❌ PIL ile hata: {e}")
            return False
    else:
        # macOS sips kullan
        os.system(f'sips -z 1024 1024 "{input_path}" --out "{output_path}" > /dev/null 2>&1')
        return os.path.exists(output_path)

if __name__ == "__main__":
    project_root = os.path.dirname(os.path.abspath(__file__))
    
    # Watch icon kaynağını bul (kullanıcı değiştirmiş olabilir)
    watch_source = os.path.join(project_root, "AriumWatch Watch App/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
    
    # Eğer Watch icon varsa onu kullan, yoksa master icon'u kullan
    if os.path.exists(watch_source):
        watch_input = watch_source
        print("🎨 Icon Optimizer")
        print(f"📁 Watch Kaynak: {watch_input} (güncellenmiş)")
    else:
        # Master icon dosyalarını bul
        master_sade = os.path.join(project_root, "master_icon_sade_1024.png")
        if not os.path.exists(master_sade):
            master_sade = os.path.join(project_root, "master_icon_sade.png")
        
        if not os.path.exists(master_sade):
            print("❌ Master icon bulunamadı!")
            sys.exit(1)
        
        watch_input = master_sade
        print("🎨 Icon Optimizer")
        print(f"📁 Kaynak: {watch_input}")
    
    print("")
    
    # Watch icon'ları oluştur
    watch_output = os.path.join(project_root, "AriumWatch Watch App/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
    widget_output = os.path.join(project_root, "AriumWatchWidget/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
    
    print("⌚ Watch icon'ları oluşturuluyor (yuvarlak)...")
    if create_watch_icon(watch_input, watch_output):
        print(f"✅ Watch App: {watch_output}")
    if create_watch_icon(watch_input, widget_output):
        print(f"✅ Watch Widget: {widget_output}")
    
    print("")
    
    # iPhone icon'ları için master icon'u bul
    master_sade = os.path.join(project_root, "master_icon_sade_1024.png")
    if not os.path.exists(master_sade):
        master_sade = os.path.join(project_root, "master_icon_sade.png")
    
    if os.path.exists(master_sade):
        # iPhone icon'ları oluştur
        iphone_output = os.path.join(project_root, "Arium/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
        
        print("📱 iPhone icon'ları oluşturuluyor (optimize edilmiş)...")
        if create_iphone_icon(master_sade, iphone_output):
            print(f"✅ iPhone: {iphone_output}")
    else:
        print("⚠️  iPhone master icon bulunamadı, atlanıyor...")
    
    print("")
    print("✨ Tamamlandı!")
    
    if not PIL_AVAILABLE:
        print("")
        print("⚠️  Not: PIL yüklü değil, sadece boyutlandırma yapıldı.")
        print("   Yuvarlak mask için: pip3 install Pillow")


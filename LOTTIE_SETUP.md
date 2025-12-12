# Lottie Animasyon Kurulumu

Kedi teması için Lottie animasyonları eklemek için aşağıdaki adımları izleyin:

## 1. Lottie Paketini Ekleme

### Xcode'da:
1. Xcode'da projeyi açın
2. **File > Add Package Dependencies...** menüsüne gidin
3. URL alanına şunu yazın: `https://github.com/airbnb/lottie-spm`
4. Version: **4.4.0** veya daha yeni seçin
5. **Add Package** butonuna tıklayın
6. **Arium** target'ını seçin ve **Add** butonuna tıklayın

### Alternatif (Manuel):
Eğer SPM çalışmazsa, `Package.swift` dosyası oluşturup ekleyebilirsiniz.

## 2. Lottie Animasyon Dosyalarını Ekleme

### Animasyon Dosyalarını İndirme:
1. [LottieFiles](https://lottiefiles.com) sitesinden kedi temalı animasyonlar indirin
2. Önerilen animasyonlar:
   - `cat-idle.json` - Boş ekran için (sakin kedi)
   - `cat-celebration.json` - Kutlama için (mutlu kedi)
   - `cat-happy.json` - Genel kullanım için

### Dosyaları Projeye Ekleme:
1. İndirdiğiniz `.json` dosyalarını `Arium/Resources/` klasörüne kopyalayın
   - Klasör yolu: `/Users/zorbey/Desktop/Repo/Arium/Arium/Resources/`
2. Xcode'da projeye sağ tıklayın > **Add Files to "Arium"...**
3. `Arium/Resources/` klasörünü seçin
4. **Copy items if needed** seçeneğini işaretleyin
5. **Create groups** seçeneğini seçin (folder references değil)
6. **Add** butonuna tıklayın
7. Xcode'da dosyaların **Target Membership**'inde **Arium** target'ının işaretli olduğundan emin olun

## 3. LottieView.swift Dosyasını Güncelleme

Lottie paketi eklendikten sonra `LottieView.swift` dosyasını güncelleyin:

```swift
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    let speed: CGFloat
    
    enum LottieLoopMode {
        case loop
        case playOnce
        case repeatCount(Int)
    }
    
    init(
        animationName: String,
        loopMode: LottieLoopMode = .loop,
        speed: CGFloat = 1.0
    ) {
        self.animationName = animationName
        self.loopMode = loopMode
        self.speed = speed
    }
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = convertLoopMode(loopMode)
        animationView.animationSpeed = speed
        animationView.play()
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        // Güncelleme gerekirse buraya eklenir
    }
    
    private func convertLoopMode(_ mode: LottieLoopMode) -> LottieLoopMode {
        switch mode {
        case .loop:
            return .loop
        case .playOnce:
            return .playOnce
        case .repeatCount(let count):
            return .repeat(count)
        }
    }
}
```

## 4. Animasyon Dosyalarını Test Etme

1. Uygulamayı çalıştırın
2. Ayarlar'dan kedi temasını seçin
3. Empty state, celebration ve confetti ekranlarında animasyonları kontrol edin

## Notlar

- Şu anda fallback olarak SwiftUI animasyonlu emoji kullanılıyor
- Lottie paketi eklendikten sonra animasyonlar otomatik olarak çalışacak
- Animasyon dosyaları bulunamazsa fallback gösterilecek
- Performans için animasyon dosyalarının boyutunu küçük tutun (< 500KB)

## Önerilen Animasyonlar

- **cat-idle**: Sakin, yavaş hareket eden kedi (empty state için)
- **cat-celebration**: Mutlu, zıplayan kedi (celebration için)
- **cat-happy**: Genel kullanım için neşeli kedi

Bu animasyonları [LottieFiles](https://lottiefiles.com/search?q=cat&category=animations) sitesinden bulabilirsiniz.

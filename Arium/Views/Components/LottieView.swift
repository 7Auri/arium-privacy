//
//  LottieView.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

#if canImport(Lottie)
import Lottie
#endif

/// Lottie animasyon wrapper view
/// Lottie paketi eklendiyse gerçek animasyonları gösterir, yoksa fallback gösterir
struct LottieAnimationView: View {
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
    
    var body: some View {
        Group {
            #if canImport(Lottie)
            // Lottie 4.3.0+ native SwiftUI view kullanıyoruz
            LottieNativeView(
                animationName: animationName,
                loopMode: loopMode,
                speed: speed
            )
            #else
            // Fallback: Basit animasyonlu emoji veya SF Symbol
            // Lottie paketi import edilemiyor - debug mesajı
            let _ = print("⚠️ Lottie paketi import edilemiyor - canImport(Lottie) false döndü")
            fallbackView
            #endif
        }
        .onAppear {
            // Her zaman debug mesajı göster (DEBUG flag olmadan)
            #if canImport(Lottie)
            print("✅ Lottie paketi mevcut - canImport(Lottie) = true")
            print("   Animasyon yükleniyor: \(animationName)")
            #else
            print("❌ Lottie paketi mevcut DEĞİL - canImport(Lottie) = false")
            print("   ⚠️ Lottie paketi target'a eklenmemiş!")
            print("   📋 Çözüm:")
            print("   1. Xcode'da Project Navigator'da projeye tıklayın")
            print("   2. Arium target'ını seçin")
            print("   3. General > Frameworks, Libraries, and Embedded Content")
            print("   4. + butonuna tıklayın")
            print("   5. 'Lottie' paketini bulun ve ekleyin")
            print("   VEYA")
            print("   File > Add Package Dependencies > lottie-spm > Arium target'ını seçin")
            #endif
        }
    }
    
    private var fallbackView: some View {
        Group {
            if animationName.contains("cat") || animationName.contains("Cat") {
                // Kedi animasyonu için fallback
                CatAnimationFallback()
            } else {
                // Diğer animasyonlar için genel fallback
                Image(systemName: "sparkles")
                    .applyAppFont(size: 60, weight: .light)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }
}

#if canImport(Lottie)
/// Lottie native SwiftUI view wrapper
@MainActor
struct LottieNativeView: View {
    let animationName: String
    let loopMode: LottieAnimationView.LottieLoopMode
    let speed: CGFloat
    
    @State private var animationAvailable = false
    
    var body: some View {
        Group {
            if animationAvailable {
                // Lottie 4.5.2 API: Framework'ün gerçek LottieView'ını kullan
                // Typealias çakışmasını önlemek için tam namespace kullan
                NativeLottieViewWrapper(
                    animationName: animationName,
                    loopMode: convertLoopMode(loopMode),
                    speed: speed
                )
            } else {
                // Animasyon yüklenene kadar fallback göster
                CatAnimationFallback()
                    .onAppear {
                        // Hemen kontrol et
                        checkAnimationAvailability()
                    }
                    .onChange(of: animationName) { _, _ in
                        // İsim değişirse yeniden kontrol et
                        checkAnimationAvailability()
                    }
            }
        }
    }
    
    // Lottie framework'ün gerçek LottieView'ını kullanan wrapper
    // Typealias çakışmasını önlemek için ayrı struct ve typealias kaldırıldı
    private struct NativeLottieViewWrapper: View {
        let animationName: String
        let loopMode: LottieLoopMode
        let speed: CGFloat
        
        var body: some View {
            // Lottie framework'ün gerçek LottieView'ı
            // Lottie 4.5.2 API: LottieAnimation.named() kullan
            // Typealias çakışmasını önlemek için tam namespace
            // AnyView kaldırıldı - frame modifier'ının düzgün çalışması için
            let animation = Lottie.LottieAnimation.named(animationName)
            Lottie.LottieView(animation: animation)
                .playing(loopMode: loopMode)
                .animationSpeed(speed)
                .aspectRatio(contentMode: .fit) // Aspect ratio'yu koru
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Frame'i zorla uygula
        }
    }
    
    private func convertLoopMode(_ mode: LottieAnimationView.LottieLoopMode) -> LottieLoopMode {
        switch mode {
        case .loop:
            return .loop
        case .playOnce:
            return .playOnce
        case .repeatCount(let count):
            return .repeat(Float(count))
        }
    }
    
    private func checkAnimationAvailability() {
        #if DEBUG
        print("🔍 Lottie animasyon kontrol ediliyor: \(animationName)")
        #endif
        
        // Yöntem 1: Main bundle'dan direkt (en yaygın) - LottieView direkt .named() kullanır
        if let _ = try? LottieAnimation.named(animationName, bundle: .main) {
            #if DEBUG
            print("✅ Lottie animasyon bulundu (yöntem 1): \(animationName)")
            #endif
            animationAvailable = true
            return
        }
        
        // Yöntem 2: Resources klasöründen path ile
        if let path = Bundle.main.path(forResource: animationName, ofType: "json", inDirectory: "Resources"),
           let _ = try? LottieAnimation.filepath(path) {
            #if DEBUG
            print("✅ Lottie animasyon bulundu (yöntem 2): \(path)")
            #endif
            animationAvailable = true
            return
        }
        
        // Yöntem 3: URL ile Resources klasöründen
        if let url = Bundle.main.url(forResource: animationName, withExtension: "json", subdirectory: "Resources"),
           let _ = try? LottieAnimation.filepath(url.path) {
            #if DEBUG
            print("✅ Lottie animasyon bulundu (yöntem 3): \(url.path)")
            #endif
            animationAvailable = true
            return
        }
        
        // Yöntem 4: Tüm bundle içeriğini tarayarak bul
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            if let contents = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                for item in contents {
                    if item == "\(animationName).json" || item.hasPrefix("\(animationName).json") {
                        let fullPath = (resourcePath as NSString).appendingPathComponent(item)
                        if let _ = try? LottieAnimation.filepath(fullPath) {
                            #if DEBUG
                            print("✅ Lottie animasyon bulundu (yöntem 4 - tarama): \(fullPath)")
                            #endif
                            animationAvailable = true
                            return
                        }
                    }
                }
            }
        }
        
        // Yöntem 5: Resources klasörünü recursive olarak ara
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            if let enumerator = fileManager.enumerator(atPath: resourcePath) {
                while let element = enumerator.nextObject() as? String {
                    if element.hasSuffix("\(animationName).json") {
                        let fullPath = (resourcePath as NSString).appendingPathComponent(element)
                        if let _ = try? LottieAnimation.filepath(fullPath) {
                            #if DEBUG
                            print("✅ Lottie animasyon bulundu (yöntem 5 - recursive): \(fullPath)")
                            #endif
                            animationAvailable = true
                            return
                        }
                    }
                }
            }
        }
        
        // Hiçbiri çalışmazsa detaylı hata logla
        #if DEBUG
        print("⚠️ Lottie animasyon bulunamadı: \(animationName)")
        print("   Denenen yöntemler:")
        print("   1. LottieAnimation.named(\(animationName), bundle: .main)")
        print("   2. Bundle.main.path(forResource: \(animationName), ofType: json, inDirectory: Resources)")
        print("   3. Bundle.main.url(forResource: \(animationName), withExtension: json, subdirectory: Resources)")
        print("   4. Bundle içeriğinde tarama")
        print("   5. Recursive arama")
        if let resourcePath = Bundle.main.resourcePath {
            print("   Bundle resource path: \(resourcePath)")
            let fileManager = FileManager.default
            if let contents = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                print("   Bundle içeriği (JSON dosyaları):")
                contents.filter { $0.hasSuffix(".json") }.forEach { print("      - \($0)") }
            }
        }
        print("   → Fallback gösteriliyor")
        #endif
    }
}
#endif

// Typealias kaldırıldı - Lottie framework'ün LottieView'ı ile çakışmasın diye
// Artık LottieAnimationView kullanılıyor (bizim custom wrapper)

/// Kedi animasyonu için SwiftUI fallback
struct CatAnimationFallback: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var eyeBlink: Bool = false
    
    var body: some View {
        ZStack {
            // Kedi emojisi
            Text("🐱")
                .applyAppFont(size: 80)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
            
            // Göz kırpma efekti
            if eyeBlink {
                Text("😑")
                    .applyAppFont(size: 80)
                    .opacity(0.3)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            // Sallanma animasyonu
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                rotation = 15
            }
            
            // Sürekli sallanma
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7).repeatForever(autoreverses: true)) {
                    rotation = -15
                }
            }
            
            // Göz kırpma
            startBlinking()
        }
    }
    
    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                eyeBlink = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    eyeBlink = false
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LottieAnimationView(animationName: "cat-happy")
        LottieAnimationView(animationName: "cat-celebration", loopMode: .playOnce)
        CatAnimationFallback()
    }
    .padding()
}

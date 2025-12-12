//
//  AppFont.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import SwiftUI

enum AppFont: String, Codable, CaseIterable, Identifiable {
    // System Fonts
    case system = "system"
    case rounded = "rounded"
    case serif = "serif"
    case monospaced = "monospaced"
    
    // San Francisco Variants
    case sfPro = "sfPro"
    case sfCompact = "sfCompact"
    
    // Sans-Serif Fonts
    case avenir = "avenir"
    case avenirNext = "avenirNext"
    case helvetica = "helvetica"
    case helveticaNeue = "helveticaNeue"
    case futura = "futura"
    case optima = "optima"
    case trebuchet = "trebuchet"
    case verdana = "verdana"
    
    // Serif Fonts
    case georgia = "georgia"
    case times = "times"
    case palatino = "palatino"
    case baskerville = "baskerville"
    case newYork = "newYork"
    
    // Monospaced Fonts
    case menlo = "menlo"
    case courier = "courier"
    case courierNew = "courierNew"
    case andaleMono = "andaleMono"
    
    // Display Fonts
    case chalkboard = "chalkboard"
    case markerFelt = "markerFelt"
    case noteworthy = "noteworthy"
    case papyrus = "papyrus"
    
    var id: String { rawValue }
    
    var category: FontCategory {
        switch self {
        case .system, .rounded, .sfPro, .sfCompact:
            return .system
        case .avenir, .avenirNext, .helvetica, .helveticaNeue, .futura, .optima, .trebuchet, .verdana:
            return .sansSerif
        case .serif, .georgia, .times, .palatino, .baskerville, .newYork:
            return .serif
        case .monospaced, .menlo, .courier, .courierNew, .andaleMono:
            return .monospaced
        case .chalkboard, .markerFelt, .noteworthy, .papyrus:
            return .display
        }
    }
    
    var displayName: String {
        switch self {
        case .system: return L10n.t("font.system")
        case .rounded: return L10n.t("font.rounded")
        case .serif: return L10n.t("font.serif")
        case .monospaced: return L10n.t("font.monospaced")
        case .sfPro: return L10n.t("font.sfPro")
        case .sfCompact: return L10n.t("font.sfCompact")
        case .avenir: return L10n.t("font.avenir")
        case .avenirNext: return L10n.t("font.avenirNext")
        case .helvetica: return L10n.t("font.helvetica")
        case .helveticaNeue: return L10n.t("font.helveticaNeue")
        case .futura: return L10n.t("font.futura")
        case .optima: return L10n.t("font.optima")
        case .trebuchet: return L10n.t("font.trebuchet")
        case .verdana: return L10n.t("font.verdana")
        case .georgia: return L10n.t("font.georgia")
        case .times: return L10n.t("font.times")
        case .palatino: return L10n.t("font.palatino")
        case .baskerville: return L10n.t("font.baskerville")
        case .newYork: return L10n.t("font.newYork")
        case .menlo: return L10n.t("font.menlo")
        case .courier: return L10n.t("font.courier")
        case .courierNew: return L10n.t("font.courierNew")
        case .andaleMono: return L10n.t("font.andaleMono")
        case .chalkboard: return L10n.t("font.chalkboard")
        case .markerFelt: return L10n.t("font.markerFelt")
        case .noteworthy: return L10n.t("font.noteworthy")
        case .papyrus: return L10n.t("font.papyrus")
        }
    }
    
    var preview: String {
        "Aa"
    }
    
    func font(size: CGFloat = 17, weight: Font.Weight = .regular) -> Font {
        switch self {
        // System Fonts
        case .system:
            return .system(size: size, weight: weight)
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        case .monospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        
        // San Francisco Variants
        case .sfPro:
            if UIFont(name: "SFProDisplay-Regular", size: size) != nil {
                return .custom("SFProDisplay-Regular", size: size)
            }
            return .system(size: size, weight: weight)
        case .sfCompact:
            if UIFont(name: "SFCompactText-Regular", size: size) != nil {
                return .custom("SFCompactText-Regular", size: size)
            }
            return .system(size: size, weight: weight)
        
        // Sans-Serif Fonts
        case .avenir:
            if UIFont(name: "Avenir-Book", size: size) != nil {
                return .custom("Avenir-Book", size: size)
            }
            return .system(size: size, weight: weight)
        case .avenirNext:
            if UIFont(name: "AvenirNext-Regular", size: size) != nil {
                return .custom("AvenirNext-Regular", size: size)
            }
            return .system(size: size, weight: weight)
        case .helvetica:
            if UIFont(name: "Helvetica", size: size) != nil {
                return .custom("Helvetica", size: size)
            }
            return .system(size: size, weight: weight)
        case .helveticaNeue:
            if UIFont(name: "HelveticaNeue", size: size) != nil {
                return .custom("HelveticaNeue", size: size)
            }
            return .system(size: size, weight: weight)
        case .futura:
            if UIFont(name: "Futura-Medium", size: size) != nil {
                return .custom("Futura-Medium", size: size)
            }
            return .system(size: size, weight: weight)
        case .optima:
            if UIFont(name: "Optima-Regular", size: size) != nil {
                return .custom("Optima-Regular", size: size)
            }
            return .system(size: size, weight: weight)
        case .trebuchet:
            if UIFont(name: "TrebuchetMS", size: size) != nil {
                return .custom("TrebuchetMS", size: size)
            }
            return .system(size: size, weight: weight)
        case .verdana:
            if UIFont(name: "Verdana", size: size) != nil {
                return .custom("Verdana", size: size)
            }
            return .system(size: size, weight: weight)
        
        // Serif Fonts
        case .georgia:
            if UIFont(name: "Georgia", size: size) != nil {
                return .custom("Georgia", size: size)
            }
            return .system(size: size, weight: weight, design: .serif)
        case .times:
            if UIFont(name: "TimesNewRomanPSMT", size: size) != nil {
                return .custom("TimesNewRomanPSMT", size: size)
            }
            return .system(size: size, weight: weight, design: .serif)
        case .palatino:
            if UIFont(name: "Palatino-Roman", size: size) != nil {
                return .custom("Palatino-Roman", size: size)
            }
            return .system(size: size, weight: weight, design: .serif)
        case .baskerville:
            if UIFont(name: "Baskerville", size: size) != nil {
                return .custom("Baskerville", size: size)
            }
            return .system(size: size, weight: weight, design: .serif)
        case .newYork:
            if #available(iOS 13.0, *) {
                if UIFont(name: "NewYork-Regular", size: size) != nil {
                    return .custom("NewYork-Regular", size: size)
                }
            }
            return .system(size: size, weight: weight, design: .serif)
        
        // Monospaced Fonts
        case .menlo:
            if UIFont(name: "Menlo-Regular", size: size) != nil {
                return .custom("Menlo-Regular", size: size)
            }
            return .system(size: size, weight: weight, design: .monospaced)
        case .courier:
            if UIFont(name: "Courier", size: size) != nil {
                return .custom("Courier", size: size)
            }
            return .system(size: size, weight: weight, design: .monospaced)
        case .courierNew:
            if UIFont(name: "CourierNewPSMT", size: size) != nil {
                return .custom("CourierNewPSMT", size: size)
            }
            return .system(size: size, weight: weight, design: .monospaced)
        case .andaleMono:
            if UIFont(name: "AndaleMono", size: size) != nil {
                return .custom("AndaleMono", size: size)
            }
            return .system(size: size, weight: weight, design: .monospaced)
        
        // Display Fonts
        case .chalkboard:
            if UIFont(name: "ChalkboardSE-Regular", size: size) != nil {
                return .custom("ChalkboardSE-Regular", size: size)
            }
            return .system(size: size, weight: weight)
        case .markerFelt:
            if UIFont(name: "MarkerFelt-Thin", size: size) != nil {
                return .custom("MarkerFelt-Thin", size: size)
            }
            return .system(size: size, weight: weight)
        case .noteworthy:
            if UIFont(name: "Noteworthy-Light", size: size) != nil {
                return .custom("Noteworthy-Light", size: size)
            }
            return .system(size: size, weight: weight)
        case .papyrus:
            if UIFont(name: "Papyrus", size: size) != nil {
                return .custom("Papyrus", size: size)
            }
            return .system(size: size, weight: weight)
        }
    }
}

enum FontCategory: String {
    case system
    case sansSerif
    case serif
    case monospaced
    case display
    
    var displayName: String {
        switch self {
        case .system: return L10n.t("font.category.system")
        case .sansSerif: return L10n.t("font.category.sansSerif")
        case .serif: return L10n.t("font.category.serif")
        case .monospaced: return L10n.t("font.category.monospaced")
        case .display: return L10n.t("font.category.display")
        }
    }
}

@MainActor
class FontManager: ObservableObject {
    static let shared = FontManager()
    
    @Published var selectedFont: AppFont = .system
    
    private let saveKey = "SelectedFont"
    private let appGroupSaveKey = "AppFont"
    
    private init() {
        loadFont()
    }
    
    func loadFont() {
        // First try App Group (widgets can access)
        if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
           let savedFont = sharedDefaults.string(forKey: appGroupSaveKey),
           let font = AppFont(rawValue: savedFont) {
            selectedFont = font
            return
        }
        
        // Fallback to normal UserDefaults
        if let savedFont = UserDefaults.standard.string(forKey: saveKey),
           let font = AppFont(rawValue: savedFont) {
            selectedFont = font
            // Also save to App Group for widget access
            if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium") {
                sharedDefaults.set(font.rawValue, forKey: appGroupSaveKey)
                sharedDefaults.synchronize()
            }
        }
    }
    
    func setFont(_ font: AppFont) {
        guard selectedFont != font else { return }
        
        selectedFont = font
        
        // Save to both local and App Group
        UserDefaults.standard.set(font.rawValue, forKey: saveKey)
        
        if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium") {
            sharedDefaults.set(font.rawValue, forKey: appGroupSaveKey)
            sharedDefaults.synchronize()
        }
        
        // Post notification to trigger UI updates
        NotificationCenter.default.post(name: NSNotification.Name("FontChanged"), object: font)
        
        // Force objectWillChange to trigger view updates
        objectWillChange.send()
    }
}



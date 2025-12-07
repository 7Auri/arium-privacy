//
//  SoundManager.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import Foundation
import SwiftUI
import AVFoundation
import AudioToolbox

@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    @AppStorage("soundEffectsEnabled") var soundEnabled: Bool = true
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playCelebrationSound(for type: ConfettiManager.CelebrationType) {
        guard soundEnabled else { return }
        
        // Use system sound for celebration
        let soundID: SystemSoundID
        
        switch type {
        case .allHabitsCompleted:
            soundID = 1057 // System success sound
        case .streak7Days:
            soundID = 1054 // System alert sound
        case .streak30Days:
            soundID = 1053 // System sound
        case .streak100Days:
            soundID = 1052 // System sound
        case .milestone:
            soundID = 1057 // Success sound
        }
        
        AudioServicesPlaySystemSound(soundID)
    }
    
    func playCompletionSound() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1057) // Success sound
    }
}

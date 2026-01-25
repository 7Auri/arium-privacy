//
//  CertificateView.swift
//  Arium
//
//  Created by Arium AI.
//

import SwiftUI

struct CertificateView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitStore: HabitStore
    @EnvironmentObject var achievementManager: AchievementManager
    
    @State private var userName: String = ""
    @State private var generatedImage: UIImage?
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Input Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text(L10n.t("certificate.name.prompt"))
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        TextField(L10n.t("certificate.name.placeholder"), text: $userName)
                            .textFieldStyle(ModernTextFieldStyle())
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal)
                    
                    // Certificate Preview
                    certificateCard
                        .shadow(radius: 10)
                        .padding(.horizontal)
                    
                    // Action Buttons
                    Button {
                        generateAndShare()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text(L10n.t("certificate.share"))
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(userName.isEmpty ? Color.gray : AriumTheme.accent)
                        .cornerRadius(16)
                    }
                    .disabled(userName.isEmpty)
                    .padding(.horizontal)
                    
                    Text(L10n.t("certificate.disclaimer"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(L10n.t("certificate.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.close")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = generatedImage {
                    ShareSheet(items: [image])
                }
            }
            .onAppear {
                // Pre-fill name if possibly stored (mock for now or userDefaults)
                if let savedName = UserDefaults.standard.string(forKey: "userName") {
                    userName = savedName
                }
            }
        }
    }
    
    private var certificateCard: some View {
        ZStack {
            // Background
            Image("certificate_bg") // Fallback or gradient
                .resizable()
                .scaledToFill()
                .frame(height: 500) // Aspect ratio roughly A4 or 4:5
                .background(Color(red: 0.98, green: 0.96, blue: 0.93)) // Cream paper color
            
            // Border
            RoundedRectangle(cornerRadius: 0)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(hex: "D4AF37"), Color(hex: "C5A028")], // Gold
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 8
                )
                .padding(20)
            
            // Content
            VStack(spacing: 20) {
                // Header Logo
                Image("AppIconMain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
                    .shadow(radius: 4)
                
                Text("CERTIFICATE OF ACHIEVEMENT")
                    .font(.custom("Palatino", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "333333"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                
                Text(L10n.t("certificate.presented_to"))
                    .font(.custom("Palatino-Italic", size: 18))
                    .foregroundColor(.secondary)
                
                Text(userName.isEmpty ? "Your Name" : userName)
                    .font(.custom("Snell Roundhand", size: 42)) // Script font
                    .fontWeight(.bold)
                    .foregroundColor(AriumTheme.accent)
                    .underline(true, color: .gray.opacity(0.3))
                
                Text(L10n.t("certificate.description"))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
                
                Divider()
                    .frame(width: 100)
                    .padding(.vertical, 10)
                
                // Stats Grid
                HStack(spacing: 30) {
                    VStack {
                        Text("\(habitStore.habits.count)")
                            .font(.title2.bold())
                        Text(L10n.t("statistics.totalHabits"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(habitStore.getTotalCompletions())")
                            .font(.title2.bold())
                        Text(L10n.t("statistics.totalCompletions"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("LVL \(achievementManager.userLevel)")
                            .font(.title2.bold())
                        Text("Level")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)
                
                Spacer()
                
                // Footer
                HStack {
                    VStack(alignment: .leading) {
                        Text(Date().formatted(date: .long, time: .omitted))
                            .font(.caption)
                        Rectangle()
                            .frame(height: 1)
                            .frame(width: 100)
                        Text(L10n.t("certificate.date"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Image(systemName: "signature") // Placeholder for signature
                            .font(.title)
                        Rectangle()
                            .frame(height: 1)
                            .frame(width: 100)
                        Text("Arium Team")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .padding(.vertical, 40)
        }
        .frame(width: 350, height: 500) // Fixed size for consistent image generation
        .background(Color(red: 0.98, green: 0.96, blue: 0.93))
        .cornerRadius(12)
    }
    
    @MainActor
    private func generateAndShare() {
        // Save name for future
        UserDefaults.standard.set(userName, forKey: "userName")
        
        // Render view to image
        let renderer = ImageRenderer(content: certificateCard)
        renderer.scale = UIScreen.main.scale
        
        if let image = renderer.uiImage {
            generatedImage = image
            showingShareSheet = true
        }
    }
}



#Preview {
    CertificateView()
        .environmentObject(HabitStore())
        .environmentObject(AchievementManager.shared)
}

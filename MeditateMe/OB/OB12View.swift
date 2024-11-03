//
//  OB12View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

// THIS IS THE DUPLICATE OF HOW MANY WORDS IN A WEEK

struct OB12View: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @Environment(\.dismiss) private var dismiss
    @State private var isNotificationRequested = false
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
                
            VStack(spacing: 20) {
                // Top navigation bar with back button and progress
                
                HStack {
                    Button(action: {
                        // Navigation action will be added later
                        onboardingManager.previousStep()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    }
                    .padding(.leading)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .foregroundColor(Color(hex: "#8FE055"))
                                .frame(width: geometry.size.width * 1.0, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Lottie animation and message
                HStack {
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    Text("I'll remind you to\npractice so it becomes a\nhabit!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Notification Permission Box
               VStack(spacing: 8) {
                    Text("FlameGame Would Like to\nSend You Notifications")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 20)
                    
                    Text("Notifications may include alerts,\nsounds, and icon badges. These can be\nconfigured in Settings.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineSpacing(2)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 4)
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack(spacing: 0) {
                        Button("Don't Allow") {
                            // Action
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 20, weight: .regular))
                        .padding(.bottom, 8)
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        Button("Allow") {
                            requestNotificationPermission()
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.cyan)
                        .font(.system(size: 20, weight: .regular))
                        .padding(.bottom, 8)
                    }
                    .frame(height: 44)
                }
                .frame(width: 270)
                .background(Color(.systemGray6).opacity(0.6))
                .cornerRadius(14)
                
                // Blue arrow
                // Arrow and line pointing to Allow
                VStack(spacing: -3) { // Reduced spacing between arrow and line
                                        Image(systemName: "arrow.up")
                                            .font(.system(size: 50))
                                            .foregroundColor(.cyan)
                                        
                                        
                                    }
                                    .offset(x: 67, y: 15) // Adjusted offset
                
                Spacer()
                
                // Blue arrow pointing up at Allow button
               
                
                // Continue button
                Button(action: {
                    // Button action will be added later
                    onboardingManager.nextStep()
                }) {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#1C232D"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#8FE055"))
                        )
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        print("Requesting notification permission...")
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                isNotificationRequested = true
                if granted {
                    print("✅ Notification permission granted")
                    checkNotificationStatus()
                } else {
                    print("❌ Notification permission denied")
                    if let error = error {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings:")
            print("Authorization status: \(settings.authorizationStatus.rawValue)")
            print("Alert setting: \(settings.alertSetting.rawValue)")
            print("Sound setting: \(settings.soundSetting.rawValue)")
            print("Badge setting: \(settings.badgeSetting.rawValue)")
        }
    }
    
    
}



struct OB12View_Previews: PreviewProvider {
    static var previews: some View {
        OB12View()
    }
}

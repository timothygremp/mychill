//
//  OB4View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB4View: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack(spacing: 25) {
                    // Duolingo mascot image - replace with your own image asset
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 200, height: 200)
                    
                    VStack(spacing: 15) {
                        Text("Starting your Journey...")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.gray)
                            .tracking(2) // Letter spacing
                        
                        Text("Get ready to join the 1m+ people")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("currently on a meditation journey with\nChillMe!")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            // Start timer when view appears
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                onboardingManager.nextStep()
            }
        }
        .onDisappear {
            // Cancel timer if view disappears
            timer?.invalidate()
            timer = nil
        }
    }
}

#Preview {
    OB4View()
}

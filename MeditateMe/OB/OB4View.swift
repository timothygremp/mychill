//
//  OB4View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB4View: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Back button area
                HStack {
                    Button(action: {
                        onboardingManager.previousStep()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                    .padding(.leading)
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
                
                VStack(spacing: 25) {
                    // Duolingo mascot image - replace with your own image asset
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 200, height: 200)
                    
                    VStack(spacing: 15) {
                        Text("COURSE BUILDING...")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.gray)
                            .tracking(2) // Letter spacing
                        
                        Text("Get ready to join the 1m plus people")
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
                    
                    // Continue button
                    Button(action: {
                        onboardingManager.nextStep()
                    }) {
                        Text("CONTINUE")
                            .font(.system(size: 17, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#8FE055"))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 34)
                    
                   
                    
                    // Progress bar
                    
                }
            }
        }
    }
}

#Preview {
    OB4View()
}

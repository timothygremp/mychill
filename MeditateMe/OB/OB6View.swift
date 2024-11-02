//
//  OB6View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB6View: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    
    private var messageText: String {
        let experience = onboardingManager.onboardingData.experience
        switch experience {
        case 1:
            return "Okay, we'll start fresh!"
        case 2...3:
            return "Okay, we'll build on what you know!"
        case 4...5:
            return "Wow, that's great!"
        default:
            return "Okay, we'll start fresh!"
        }
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Top navigation bar with back button and progress
                HStack {
                    Button(action: {
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
                                .frame(width: geometry.size.width * 0.4, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Duolingo mascot and dynamic message
                HStack {
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    Text(messageText)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding()
                
                Spacer()
                
                // Continue button
                Button(action: {
                    onboardingManager.nextStep()
                }) {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
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
}

struct OB6View_Previews: PreviewProvider {
    static var previews: some View {
        OB6View()
            .environmentObject(OnboardingManager())
    }
}

//
//  OB13View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

import SwiftUI

struct OB13View: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
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
                    
                    Text("You can also add my\nwidget for extra\nmotivation!")
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
                
                // Phone mockup with widget
                ZStack {
                    // Phone frame
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 200, height: 300)
                    
                    // Notch
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 12)
                        .offset(y: -135)
                    
                    // Widget
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "#A558C8")) // Purple background
                                .frame(width: 60, height: 60)
                            
                            VStack(spacing: 0) {
                                HStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 12))
                                    Text("3")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                
                                Image("duolingo_sleeping") // Add your own image asset
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    .offset(x: -50, y: -80) // Position widget in top-left area
                    
                    // Other app icons (grayed out)
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .offset(
                                x: CGFloat(((index % 3) - 1) * 50),
                                y: CGFloat((index / 3) * 50) - 80
                            )
                    }
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // Add widget action
                    }) {
                        Text("ADD WIDGET")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#1C232D"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "#8FE055"))
                            )
                    }
                    
                    Button(action: {
                        // Not now action
                        onboardingManager.nextStep()
                    }) {
                        Text("NOT NOW")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#8FE055"))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    OB13View()
}

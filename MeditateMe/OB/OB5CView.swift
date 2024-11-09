//
//  OB5CView.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 11/8/24.
//

import SwiftUI

struct OB5CView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var relationshipLevel: Double
    @State private var animationAmount: CGFloat = 1.0
    
    init(onboardingManager: OnboardingManager) {
        _relationshipLevel = State(initialValue: Double(onboardingManager.onboardingData.relationship))
    }
    
    var body: some View {
        ZStack {
            // Dark background
            // Color(hex: "#1C232D")
            //     .edgesIgnoringSafeArea(.all)
             Image("cove_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Color.black.opacity(0.5)  // Add a dark overlay for content visibility
                )
            
            // Subtle particle effect
            ParticleEffect()
                .opacity(0.15)
            
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
                                .foregroundColor(Color(hex: "#8FE055")) // Duolingo green
                                .frame(width: geometry.size.width * 0.2, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding(.top, 48)
                
                // Duolingo mascot and question
                HStack {
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    Text("How would you rate your relationships with others?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding()
                
                // New Slider Section
                VStack(spacing: 25) {
                    // Labels with enhanced styling and better spacing
                    HStack {
                        VStack(spacing: 8) {
                            Text("Great")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 4)
                           
                            Text("Each one is healthy")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 4)
                                .padding(.bottom, 4)
                        }
                        .frame(width: 160)
                        .padding(.leading, 8)
                        
                        Spacer()
                        
                        VStack(spacing: 8) {
                            Text("Toxic")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 4)
                            
                            Text("Each one is toxic")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 4)
                                .padding(.bottom, 4)
                        }
                        .frame(width: 160)
                        .padding(.trailing, 8)
                    }
                    .padding(.horizontal, 8)
                    
                    // Enhanced Custom Slider
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        // Filled portion
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#4B95E7"), Color(hex: "#6BA5EA")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: max(0, min(CGFloat(relationshipLevel) / 100 * (UIScreen.main.bounds.width - 48), UIScreen.main.bounds.width - 48)))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        // Slider handle
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            .offset(x: max(0, min(CGFloat(relationshipLevel) / 100 * (UIScreen.main.bounds.width - 48), UIScreen.main.bounds.width - 48)) - 14)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let width = UIScreen.main.bounds.width - 48 // Accounting for horizontal padding
                                        let xLocation = value.location.x
                                        let percentage = min(max(0, xLocation / width * 100), 100)
                                        relationshipLevel = Double(percentage)
                                    }
                            )
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.1))
                        .padding(.horizontal)
                )
                
                Spacer()
                
                // Continue button
                Button(action: {
                    onboardingManager.onboardingData.relationship = Int(relationshipLevel)
                    onboardingManager.nextStep()
                }) {
                    Text("CONTINUE")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#FFB347"), Color(hex: "#FF69B4")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 34)
                .scaleEffect(animationAmount)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: animationAmount
                )
            }
        }
    }
}


#Preview {
    OB5CView(onboardingManager: OnboardingManager())
        .environmentObject(OnboardingManager())
}

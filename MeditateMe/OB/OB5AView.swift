//
//  OB5AView.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 11/7/24.
//

import SwiftUI

struct OB5AView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var depressionLevel: Double
    
    init(onboardingManager: OnboardingManager) {
        _depressionLevel = State(initialValue: Double(onboardingManager.onboardingData.depression))
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
                .padding(.top)
                
                // Duolingo mascot and question
                HStack {
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    Text("How would you rate your depression?")
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
                            Text("None")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 4)
                            
                            Text("Rarely feel depressed")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 4)
                                .padding(.bottom, 4)
                        }
                        .frame(width: 160)
                        .padding(.leading, 8)
                        
                        Spacer()
                        
                        VStack(spacing: 8) {
                            Text("A Lot")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 4)
                            
                            Text("Frequently depressed")
                                .foregroundColor(.gray)
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
                            .frame(width: max(0, min(CGFloat(depressionLevel) / 100 * (UIScreen.main.bounds.width - 48), UIScreen.main.bounds.width - 48)))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        // Slider handle
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            .offset(x: max(0, min(CGFloat(depressionLevel) / 100 * (UIScreen.main.bounds.width - 48), UIScreen.main.bounds.width - 48)) - 14)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let width = UIScreen.main.bounds.width - 48 // Accounting for horizontal padding
                                        let xLocation = value.location.x
                                        let percentage = min(max(0, xLocation / width * 100), 100)
                                        depressionLevel = Double(percentage)
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
                    onboardingManager.onboardingData.depression = Int(depressionLevel)
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
            }
        }
    }
}


#Preview {
    OB5AView(onboardingManager: OnboardingManager())
        .environmentObject(OnboardingManager())
}

//
//  OB7View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB7View: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var selectedOptions: Set<String> = []
    
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
                                .frame(width: geometry.size.width * 0.6, height: 8) // Increased progress to 60%
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Lottie animation and question
                HStack {
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    Text("Why do you want to meditate? Select 1 or multiple☺️")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding()
                
//                ["Relaxation", "Focus", "Sleep", "Anxiety Relief", "Mindfulness"]
                
                // Options list
                VStack(spacing: 12) {
                    makeOptionButton("Reduce Anxiety", icon: "💼")
                    makeOptionButton("Reduce Depression", icon: "💼")
                    makeOptionButton("Boost Self Esteem", icon: "🎉")
                    makeOptionButton("Improve Focus", icon: "📚")
                    makeOptionButton("Improve Sleep", icon: "✈️")
                    makeOptionButton("Relaxation", icon: "🧠")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    onboardingManager.onboardingData.meditationGoals = Array(selectedOptions)
                    onboardingManager.nextStep()
                }) {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#1C232D"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedOptions.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "#8FE055"))
                        )
                        .padding(.horizontal)
                }
                .disabled(selectedOptions.isEmpty)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            // Restore previous selections if they exist
            if !onboardingManager.onboardingData.meditationGoals.isEmpty {
                selectedOptions = Set(onboardingManager.onboardingData.meditationGoals)
            }
        }
    }
    
    private func makeOptionButton(_ text: String, icon: String) -> some View {
        Button(action: {
            if selectedOptions.contains(text) {
                selectedOptions.remove(text)
            } else {
                selectedOptions.insert(text)
            }
        }) {
            HStack {
                Text(icon)
                    .font(.system(size: 24))
                    .frame(width: 40)
                
                Text(text)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: selectedOptions.contains(text) ? 2 : 0)
            )
        }
    }
}

struct OB7View_Previews: PreviewProvider {
    static var previews: some View {
        OB7View()
    }
}

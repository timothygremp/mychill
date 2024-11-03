//
//  OB5View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB5View: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var selectedLevel: Int? = nil
    
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
                    
                    Text("How much meditating have you done?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding()
                
                // Options list
                VStack(spacing: 12) {
                    makeOptionButton("I'm new to meditating", level: 1)
                    makeOptionButton("I've done a little bit", level: 2)
                    makeOptionButton("I was into it then stopped", level: 3)
                    makeOptionButton("I meditate occassionally", level: 4)
                    makeOptionButton("I meditate every day", level: 5)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    if let level = selectedLevel {
                        onboardingManager.onboardingData.experience = level
                        onboardingManager.nextStep()
                    }
                }) {
                    Text("CONTINUE")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedLevel != nil ? Color(hex: "#8FE055") : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .disabled(selectedLevel == nil)
                .padding(.horizontal)
                .padding(.bottom, 34)
            }
        }
    }
    
    private func makeOptionButton(_ text: String, level: Int) -> some View {
        Button(action: {
            selectedLevel = level
        }) {
            HStack {
                // Level indicator bars
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Rectangle()
                            .fill(index < level ? Color(hex: "#4B95E7") : Color.gray.opacity(0.3))
                            .cornerRadius(5)
                            .frame(width: 5, height: 25)
                    }
                }
                .padding(.leading)
                
                Text(text)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 8)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: selectedLevel == level ? 2 : 0)
            )
        }
    }
}

struct OB5View_Previews: PreviewProvider {
    static var previews: some View {
        OB5View()
    }
}

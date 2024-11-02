//
//  OB5View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB5View: View {
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
                    
                    Text("How much French do\nyou know?")
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
                    makeOptionButton("I'm new to French", level: 1)
                    makeOptionButton("I know some common words", level: 2)
                    makeOptionButton("I can have basic conversations", level: 3)
                    makeOptionButton("I can talk about various topics", level: 4)
                    makeOptionButton("I can discuss most topics\nin detail", level: 5)
                }
                .padding(.horizontal)
                
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
            }
        }
    }
    
    private func makeOptionButton(_ text: String, level: Int) -> some View {
        Button(action: {
            // Button action will be added later
        }) {
            HStack {
                // Level indicator bars
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Rectangle()
                            .fill(index < level ? Color(hex: "#4B95E7") : Color.gray.opacity(0.3))
                            .frame(width: 5, height: 20)
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
            
        }
    }
}

struct OB5View_Previews: PreviewProvider {
    static var previews: some View {
        OB5View()
    }
}

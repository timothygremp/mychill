//
//  OB9View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB9View: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var selectedTime: String? = nil
    
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
                                .frame(width: geometry.size.width * 0.9, height: 8)
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
                    
                    Text("What's your daily\nlearning goal?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding()
                
                // Time options
                VStack(spacing: 12) {
                    makeOptionButton(time: "5 min / day", level: "Casual")
                    makeOptionButton(time: "10 min / day", level: "Regular")
                    makeOptionButton(time: "15 min / day", level: "Serious")
                    makeOptionButton(time: "20 min / day", level: "Intense")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // I'm Committed button
                Button(action: {
                    onboardingManager.nextStep()
                }) {
                    Text("I'M COMMITTED")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                        )
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            // Restore previous selection if it exists
            if onboardingManager.onboardingData.dailyGoalMinutes > 0 {
                selectedTime = "\(onboardingManager.onboardingData.dailyGoalMinutes) min / day"
            }
        }
    }
    
    private func makeOptionButton(time: String, level: String) -> some View {
        Button(action: {
            selectedTime = time
            // Extract just the number from strings like "5 min / day"
            if let minutes = time.split(separator: " ").first {
                onboardingManager.onboardingData.dailyGoalMinutes = Int(minutes) ?? 0
            }
        }) {
            HStack {
                Text(time)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(level)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: selectedTime == time ? 2 : 0)
            )
        }
    }
}

struct OB9View_Previews: PreviewProvider {
    static var previews: some View {
        OB9View()
            .environmentObject(OnboardingManager())
    }
}

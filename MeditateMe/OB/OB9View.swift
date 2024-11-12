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
    @State private var showPlanInfo: Bool = false
    @State private var selectedLevel: String = ""
    
    var body: some View {
        ZStack {
            // Dark background
//            Color(hex: "#1C232D")
//                .edgesIgnoringSafeArea(.all)
            GradientBackgroundView()
            
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
                    
                    Text("Pick a custom healing plan")
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
                    makeOptionButton(time: "1 min / day", level: "Casual")
                    makeOptionButton(time: "3 min / day", level: "Regular")
                    makeOptionButton(time: "4 min / day", level: "Serious")
                    makeOptionButton(time: "5 min / day", level: "Intense")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // I'M COMMITTED button
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
            selectedLevel = level
            showPlanInfo = true
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
                    .foregroundColor(.white)
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
        .sheet(isPresented: $showPlanInfo) {
            MeditationPlanSheet(level: selectedLevel, minutesPerDay: onboardingManager.onboardingData.dailyGoalMinutes)
                .environmentObject(onboardingManager)
                .presentationDetents([.fraction(0.6)])
                .presentationCornerRadius(25)
        }
    }
}

struct MeditationPlanSheet: View {
    let level: String
    let minutesPerDay: Int
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var onboardingManager: OnboardingManager
    
    private var sortedAssessments: [(String, Int)] {
        let scores = [
            ("Anxiety", onboardingManager.onboardingData.anxiety),
            ("Depression", onboardingManager.onboardingData.depression),
            ("Trauma", onboardingManager.onboardingData.trauma),
            ("Relationships", onboardingManager.onboardingData.relationship),
            ("Self-Esteem", onboardingManager.onboardingData.esteem)
        ]
        return scores.sorted { $0.1 > $1.1 } // Sort by severity (highest scores first)
    }
    
    private var minutesPerMeditation: Int {
        if minutesPerDay >= 10 {
            return minutesPerDay / 5 // Divide total minutes by number of assessments
        } else {
            return minutesPerDay // For plans less than 10 minutes, use full time
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("\(level) Healing Plan")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                }
            }
            
            Text("Your personalized \(minutesPerDay)-minute daily meditation plan:")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            VStack(spacing: 12) {
                ForEach(Array(sortedAssessments.prefix(5).enumerated()), id: \.element.0) { index, assessment in
                    HStack {
                        Text("Day \(index + 1)")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                        Spacer()
                        Text("\(assessment.0) Meditation")
                            .foregroundColor(.white)
                        Text("(\(minutesPerMeditation)min)")
                            .foregroundColor(.green)
                    }
                    .font(.system(size: 16, weight: .medium))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "2C2C2E"))
    }
}

struct OB9View_Previews: PreviewProvider {
    static var previews: some View {
        OB9View()
            .environmentObject(OnboardingManager())
    }
}

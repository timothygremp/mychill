//
//  OB18View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 11/1/24.
//

import SwiftUI

struct OB18View: View {
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
                    LottieView(name: "flow_women", loopMode: .loop)
                        .frame(width: 80, height: 80)
                    
                    Text("Here's what you can\nachieve in 3 months!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding(.horizontal)
                
                // Achievement items
                VStack(spacing: 24) {
                    achievementRow(
                        icon: "💬",
                        iconBackground: Color(hex: "#A558C8"), // Purple
                        title: "Converse with confidence",
                        subtitle: "Stress-free speaking and\nlistening exercises"
                    )
                    
                    achievementRow(
                        icon: "🔤",
                        iconBackground: Color(hex: "#4B95E7"), // Blue
                        title: "Build up your vocabulary",
                        subtitle: "Common words and practical phrases"
                    )
                    
                    achievementRow(
                        icon: "⌚️",
                        iconBackground: Color(hex: "#FFA500"), // Orange
                        title: "Develop a learning habit",
                        subtitle: "Smart reminders, fun challenges,\nand more"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    // Button action will be added later
                }) {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#1C232D"))
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
    
    private func achievementRow(icon: String, iconBackground: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            // Icon with background
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconBackground)
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
    }
}

struct OB18View_Previews: PreviewProvider {
    static var previews: some View {
        OB18View()
    }
}

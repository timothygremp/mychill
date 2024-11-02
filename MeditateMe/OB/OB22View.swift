//
//  OB22View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 11/1/24.
//

import SwiftUI

struct OB22View: View {
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Top navigation bar with back button
                HStack {
                    Button(action: {
                        // Navigation action will be added later
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
                
                // Celebration animation and message
                VStack(spacing: 20) {
                    // Fireworks
                    HStack {
                        Spacer()
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                            .font(.system(size: 40))
                        Spacer()
                        Image(systemName: "sparkles")
                            .foregroundColor(.green)
                            .font(.system(size: 40))
                        Spacer()
                    }
                    
                    // Lottie animation
                    LottieView(name: "flow_women", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    // Message
                    Text("Learning legend!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#FFD700")) // Gold color
                    
                    Text("You just completed your first lesson!")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Stats
                HStack(spacing: 20) {
                    statBox(title: "TOTAL XP", value: "23", color: Color(hex: "#FFD700")) // Yellow
                    statBox(title: "GOOD", value: "86%", color: Color(hex: "#8FE055")) // Green
                    statBox(title: "SPEEDY", value: "2:06", color: Color(hex: "#4B95E7")) // Blue
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Claim XP button
                Button(action: {
                    // Button action will be added later
                }) {
                    Text("CLAIM XP")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#1C232D"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#4B95E7")) // Blue
                        )
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    private func statBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 100, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color, lineWidth: 2)
        )
    }
}

struct OB22View_Previews: PreviewProvider {
    static var previews: some View {
        OB22View()
    }
}

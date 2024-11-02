//
//  OB11View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB11View: View {
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
                                .frame(width: geometry.size.width * 0.98, height: 8) // Increased progress to 98%
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
                    
                    HStack {
                        Text("That's ")
                            .foregroundColor(.white) +
                        Text("25 words")
                            .foregroundColor(Color(hex: "#A558C8")) + // Purple color
                        Text(" in your\nfirst week!")
                            .foregroundColor(.white)
                    }
                    .font(.system(size: 24, weight: .bold))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.2))
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
}

struct OB11View_Previews: PreviewProvider {
    static var previews: some View {
        OB11View()
    }
}

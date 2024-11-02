//
//  OB9View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB9View: View {
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
                                .frame(width: geometry.size.width * 0.9, height: 8) // Increased progress to 90%
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Lottie animation and question
                HStack {
                    LottieView(name: "flow_women", loopMode: .loop)
                        .frame(width: 80, height: 80)
                    
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
                    // Button action will be added later
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
    }
    
    private func makeOptionButton(time: String, level: String) -> some View {
        Button(action: {
            // Button action will be added later
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
        }
    }
}

struct OB9View_Previews: PreviewProvider {
    static var previews: some View {
        OB9View()
    }
}

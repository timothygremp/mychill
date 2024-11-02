//
//  OB17View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 11/1/24.
//

import SwiftUI

struct OB17View: View {
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
                    
                    Text("Then, tap the + button\nand add my widget!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Phone mockup with + button
                ZStack {
                    // Phone frame
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 280, height: 500)
                    
                    // Your image here
                    Image("phone_mockup") // Replace with your actual image name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260, height: 480)
                    
                    // Blue + button overlay
                    VStack {
                        HStack {
                            Spacer()
                            Text("+")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Color(hex: "#4B95E7")) // Blue color
                                .cornerRadius(15)
                                .padding(.trailing, 150)
                                .padding(.top, -200)
                        }
                        Spacer()
                    }
                }
                
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

struct OB17View_Previews: PreviewProvider {
    static var previews: some View {
        OB17View()
    }
}

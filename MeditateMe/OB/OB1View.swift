//
//  OB1View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB1View: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var animationAmount: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Gradient background
            GradientBackgroundView()
            
            VStack {
                Spacer()
                
                LottieView(name: "sloth_10s", loopMode: .loop)
                    .frame(width: 250, height: 250)
                
                Text("MyChill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.red)
                
                
                Text("The focus is you")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    
                
                Spacer()
                
                Button(action: {
                    onboardingManager.nextStep()
                }) {
                    Text("CONTINUE")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#FFB347"), Color(hex: "#FF69B4")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .scaleEffect(animationAmount)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: animationAmount
                )
                .padding(.bottom, 34)
            }
        }
        .onAppear {
            animationAmount = 1.05
        }
        .statusBar(hidden: false)
    }
}

    

#Preview {
    OB1View()
}

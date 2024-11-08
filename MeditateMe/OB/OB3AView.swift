//
//  OB3AView.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 11/2/24.
//

import SwiftUI

struct OB3AView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var displayedText = ""
    let fullText = "Now it's time for a selfie with AI emotional analysis to finish creating your Inner Peace score."
    @State private var isAnimating = false
    @State private var animationAmount: CGFloat = 1.0
    
    var body: some View {
        ZStack {
//             Dark background
            // Color(hex: "1C1B1F")
            //     .ignoresSafeArea()
//            Color(.black)
//                .ignoresSafeArea()
            GradientBackgroundView()
            
            VStack {
                // Back button area
                HStack {
                    Button(action: {
                        onboardingManager.previousStep()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                    .padding(.leading)
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
                
                // Message bubble with animated text
                Text(displayedText)
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .frame(idealWidth: 260, maxWidth: 260, alignment: .leading)
                    .fixedSize(horizontal: true, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background {
                        MessageBubble()
                            .fill(Color(hex: "2C2C2E").opacity(0.8))
                            .animation(.spring(duration: 0.2), value: displayedText.count)
                    }
                    .background {
                        MessageBubble()
                            .stroke(Color.white.opacity(0.15), lineWidth: 3.5)
                            .animation(.spring(duration: 0.2), value: displayedText.count)
                    }
                
                // Duo mascot
                ZStack {
                    // Shadow circle
                   
                    
                    // Green owl shape
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 200, height: 200)
                }
                
                Spacer()
                
                // Continue button
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
                .padding(.bottom, 34)
                .scaleEffect(animationAmount)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: animationAmount
                )
            }
        }
        .onAppear {
            startTypingAnimation()
        }
    }
    
    func startTypingAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        var charIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if charIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                displayedText += String(fullText[index])
                charIndex += 1
            } else {
                timer.invalidate()
                isAnimating = false
            }
        }
    }
}


#Preview {
    OB3AView()
}

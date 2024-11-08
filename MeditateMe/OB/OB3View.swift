//
//  OB3View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB3View: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var displayedText = ""
    let fullText = "Just 5 quick questions before we know your Inner Peace Score & create your first meditation."
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
//             Dark background
            Color(hex: "1C1B1F")
                .ignoresSafeArea()
//            Color(.black)
//                .ignoresSafeArea()
            
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
    OB3View()
}

//
//  OB3View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB3View: View {
    @State private var displayedText = ""
    let fullText = "We all have love languages, but sometimes it can be hard for us to give each other what we need without a little nudge from time to time!"
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
//                        
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
                    Circle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 65, height: 65)
                        .offset(y: 2)
                    
                    // Green owl shape
                    Image("rj_single_flower")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260, height: 260)
                        .foregroundColor(Color(hex: "58CC02"))
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    
                }) {
                    Text("CONTINUE")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.red))
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

//
//  OB2View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct MessageBubble: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Constants for the pointer
        let pointerWidth: CGFloat = 20
        let pointerHeight: CGFloat = 12
        let cornerRadius: CGFloat = 16
        
        // Calculate pointer position (centered)
        let pointerX = rect.width/2 - pointerWidth/2
        
        // Start from the left side
        path.move(to: CGPoint(x: cornerRadius, y: rect.maxY))
        
        // Draw the left side up to where the pointer starts
        path.addLine(to: CGPoint(x: pointerX, y: rect.maxY))
        
        // Draw the pointer (flipped)
        path.addLine(to: CGPoint(x: pointerX + pointerWidth/2, y: rect.maxY + pointerHeight))
        path.addLine(to: CGPoint(x: pointerX + pointerWidth, y: rect.maxY))
        
        // Complete the rectangle with rounded corners
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                   radius: cornerRadius,
                   startAngle: .degrees(90),
                   endAngle: .degrees(0),
                   clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.maxX, y: cornerRadius))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: cornerRadius),
                   radius: cornerRadius,
                   startAngle: .degrees(0),
                   endAngle: .degrees(-90),
                   clockwise: true)
        
        path.addLine(to: CGPoint(x: cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                   radius: cornerRadius,
                   startAngle: .degrees(-90),
                   endAngle: .degrees(180),
                   clockwise: true)
        
        path.addLine(to: CGPoint(x: 0, y: rect.maxY - cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: rect.maxY - cornerRadius),
                   radius: cornerRadius,
                   startAngle: .degrees(180),
                   endAngle: .degrees(90),
                   clockwise: true)
        
        path.closeSubpath()
        return path
    }
}

struct TypingMessageView: View {
    @State private var displayedText = ""
    let fullText = "Hi there! I'm R! and I'm J!"
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "1C1B1F")
                .ignoresSafeArea()
            
            VStack {
                // Back button area
                HStack {
                    Button(action: {}) {
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
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background {
                        MessageBubble()
                            .fill(Color(hex: "2C2C2E").opacity(0.8))
                    }
                    .background {
                        // Increased border thickness to 3.5
                        MessageBubble()
                            .stroke(Color.white.opacity(0.15), lineWidth: 3.5)
                    }
                    .fixedSize()
                    
                
                // Duo mascot
                ZStack {
                    // Shadow circle
                    Circle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 65, height: 65)
                        .offset(y: 2)
                    
                    // Green owl shape
                    Image("r&J_welcome")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260, height: 260)
                        .foregroundColor(Color(hex: "58CC02"))
                }
                
                Spacer()
                
                // Continue button
                Button(action: {}) {
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

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


struct OB2View: View {
    @State private var displayedText = ""
    let fullText = "Hi there! I'm R! and I'm J!"
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "1C1B1F")
                .ignoresSafeArea()
            
            VStack {
                // Back button area
                HStack {
                    Button(action: {
//                        onboardingManager.goBack()
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
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background {
                        MessageBubble()
                            .fill(Color(hex: "2C2C2E").opacity(0.8))
                    }
                    .background {
                        // Increased border thickness to 3.5
                        MessageBubble()
                            .stroke(Color.white.opacity(0.15), lineWidth: 3.5)
                    }
                    .fixedSize()
                    
                
                // Duo mascot
                ZStack {
                    // Shadow circle
                    Circle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 65, height: 65)
                        .offset(y: 2)
                    
                    // Green owl shape
                    Image("r&J_welcome")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260, height: 260)
                        .foregroundColor(Color(hex: "58CC02"))
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
//                    onboardingManager.moveToNextState()
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
    OB2View()
}

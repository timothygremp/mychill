//
//  OB13AView.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 11/12/24.
//

import SwiftUI

struct OB13AView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var name: String = ""
    @State private var animationAmount: CGFloat = 1.0
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name
    }
    
    var body: some View {
        ZStack {
            // Background image
            Image("lake_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Color.black.opacity(0.5)  // Dark overlay for content visibility
                )
            
            // Subtle particle effect
            ParticleEffect()
                .opacity(0.15)
            
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
                .padding(.top, 48)
                
                // Lottie animation and question
                HStack {
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    Text("Step 1:\n What's your first name?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding()
                
                // Name input field
                TextField("", text: $name)
                    .placeholder(when: name.isEmpty) {
                        Text("Your First Name").foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.2))
                    )
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .focused($focusedField, equals: .name)
                    .padding(.horizontal)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                focusedField = nil
                            }
                            .foregroundColor(.white)
                        }
                    }
                
                Spacer()
                
                // Modified continue button with gradient style
                Button(action: {
                    UserDefaults.standard.set(name, forKey: "userName")
                    onboardingManager.nextStep()
                }) {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Group {
                                if !name.isEmpty {
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "#FFB347"), Color(hex: "#FF69B4")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                } else {
                                    Color.gray.opacity(0.3)
                                }
                            }
                        )
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                }
                .disabled(name.isEmpty)
                .opacity(name.isEmpty ? 0.5 : 1.0)
                .scaleEffect(animationAmount)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: animationAmount
                )
                .padding(.bottom, 50)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            animationAmount = 1.05
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    OB13AView()
}

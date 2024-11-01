//
//  SwiftUIView.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/22/24.
//

import SwiftUI
import Lottie

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @Binding var audioFiles: [AudioFileModel]
    @ObservedObject var meditationCredits: MeditationCredits
    @State private var name: String = ""
    @State private var pronunciation: String = ""
    @FocusState private var focusedField: Field?
    @State private var showFirstMeditationView = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var animationAmount: CGFloat = 1
    
    enum Field {
        case name, pronunciation
    }
    
    var body: some View {
        if showFirstMeditationView {
            FirstMeditationView(isOnboardingComplete: $isOnboardingComplete, audioFiles: $audioFiles)
        } else {
            ZStack {
                GradientBackgroundView()
                
                VStack(spacing: 20) {
                    LottieViewOnBoard(name: "sloth_10s")
                        .frame(width: 400, height: 400)
                    
                    VStack(spacing: 5) {
                        Text("MyChill")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                        
                        Text("Custom audio meditations inspired by you")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, -25)
                    .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        StylishTextField(text: $name, placeholder: "Your First Name")
                            .focused($focusedField, equals: .name)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        UserDefaults.standard.set(name, forKey: "userName")
                        UserDefaults.standard.set(pronunciation, forKey: "userPronunciation")
                        meditationCredits.useCredit()
                        showFirstMeditationView = true
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#FFB347"), Color(hex: "#FF69B4")]), startPoint: .leading, endPoint: .trailing))
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
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.5 : 1.0)
                    
                    Spacer(minLength: 0)
                }
                .padding()
                .offset(y: -keyboardHeight / 2)
            }
            .onTapGesture {
                focusedField = nil
            }
            .onAppear {
                setupKeyboardObservers()
                self.animationAmount = 1.1
            }
            .onDisappear {
                removeKeyboardObservers()
            }
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

struct AnimatedGradientBackground: View {
    @State private var start = UnitPoint(x: 0, y: 0)
    @State private var end = UnitPoint(x: 1, y: 1)
    
    let colors = [Color(hex: "#9999ff"), Color(hex: "#cc99cc")]
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .edgesIgnoringSafeArea(.all)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 2)) {
                    self.start = UnitPoint(x: 1, y: 1)
                    self.end = UnitPoint(x: 0, y: 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 2)) {
                        self.start = UnitPoint(x: 0, y: 0)
                        self.end = UnitPoint(x: 1, y: 1)
                    }
                }
            }
    }
}

struct StylishTextField: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        TextField("", text: $text)
            .placeholder(when: text.isEmpty) {
                Text(placeholder).foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .foregroundColor(.white)
            .accentColor(.white)
    }
}

struct LottieViewOnBoard: UIViewRepresentable {
    var name: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (1, 1, 1, 0)
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue:  Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

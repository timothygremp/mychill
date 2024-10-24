import SwiftUI
import Foundation

struct FirstMeditationView: View {
    @Binding var isOnboardingComplete: Bool
    @Binding var audioFiles: [AudioFileModel]
    @State private var message = ""
    @State private var selectedThemes: Set<String> = []
    @State private var textViewHeight: CGFloat = 40
    @State private var isGeneratingMeditation = false
    @State private var meditationGenerated = false
    @AppStorage("audioFiles") private var audioFilesData: Data = Data()
    @AppStorage("userName") private var userName: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var animationAmount: CGFloat = 1
    @FocusState private var isInputFocused: Bool
    
    let availableThemes = ["Relaxation", "Focus", "Sleep", "Anxiety Relief", "Mindfulness"]
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            ScrollView {
                VStack(spacing: 15) {
                    Text("Hello, \(userName)👋")
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Let's Create Your First Meditation🥳")
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("To Get Started:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                        
                        InstructionRow(icon: "1.circle.fill", text: "Type a message describing what you'd like your meditation/affirmation to be about. Examples like: I'm stressed about school or having family issues. You can make it about anything. You can also add as many selected themes as you want too. ")

                        InstructionRow(icon: "2.circle.fill", text: "Hit the send button and wait for your meditation to be created!😍")
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Themes section
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(availableThemes, id: \.self) { theme in
                                ThemeButton(theme: theme, isSelected: selectedThemes.contains(theme)) {
                                    if selectedThemes.contains(theme) {
                                        selectedThemes.remove(theme)
                                    } else {
                                        selectedThemes.insert(theme)
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 50)
                    
                    // Message input and send button
                    HStack(alignment: .bottom) {
                        ExpandingTextView(text: $message, height: $textViewHeight) {
                            // Handle done action
                        }
                        .frame(height: textViewHeight)
                        .background(Color(UIColor.systemBackground).opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .focused($isInputFocused)
                        
                        Button(action: {
                            generateMeditation()
                            isInputFocused = false // Dismiss keyboard
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                        }
                        .padding(.leading, 8)
                    }
                    
                    if meditationGenerated {
                        Button(action: {
                            isOnboardingComplete = true
                        }) {
                            Text("Go to My First Meditation")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .scaleEffect(animationAmount)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: animationAmount
                        )
                        .onAppear {
                            self.animationAmount = 1.1
                        }
                    }
                }
                .padding()
                .offset(y: -keyboardHeight / 2)
            }
            
            if isGeneratingMeditation {
                LoadingOverlay()
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                withAnimation(.easeOut(duration: 0.25)) {
                    self.keyboardHeight = keyboardRectangle.height - 50 // Subtracting 50 to leave some space at the bottom
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                self.keyboardHeight = 0
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // http://localhost:3000/generate-meditation
    // https://us-central1-meditation-438805.cloudfunctions.net/generate-meditation
    
    func generateMeditation() {
        isInputFocused = false // Dismiss keyboard
        isGeneratingMeditation = true
        let currentMessage = message
        message = ""
        
        let url = URL(string: "https://us-central1-meditation-438805.cloudfunctions.net/generate-meditation")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "message": currentMessage,
            "themes": Array(selectedThemes),
            "userName": userName
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isGeneratingMeditation = false
                if let data = data {
                    do {
                        let fileName = "meditation_\(Date().timeIntervalSince1970).mp3"
                        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
                        try data.write(to: fileURL)
                        
                        let newAudioFile = AudioFileModel(
                            id: UUID(),
                            fileName: fileName,
                            creationDate: Date(),
                            message: currentMessage,
                            themes: Array(selectedThemes),
                            isFavorite: false,
                            hasBeenPlayed: false
                        )
                        
                        // Update both audioFiles and audioFilesData
                        audioFiles.insert(newAudioFile, at: 0)
                        if let encodedData = try? JSONEncoder().encode(audioFiles) {
                            audioFilesData = encodedData
                        }
                        
                        meditationGenerated = true
                        selectedThemes.removeAll()
                    } catch {
                        print("Error saving audio file: \(error)")
                    }
                }
            }
        }.resume()
    }
}

struct FirstMeditationView_Previews: PreviewProvider {
    static var previews: some View {
        FirstMeditationView(isOnboardingComplete: .constant(false), audioFiles: .constant([]))
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 24))
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

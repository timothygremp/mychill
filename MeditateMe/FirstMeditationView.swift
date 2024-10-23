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
    
    let availableThemes = ["Relaxation", "Focus", "Sleep", "Anxiety Relief", "Mindfulness"]
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            
            VStack(spacing: 20) {
                Text("Let's Create Your First Meditation")
                    .font(.title2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("You can pick a selected theme or you can type a message describing what you would like your meditation/affirmation to be about")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
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
                    .padding(.horizontal)
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
                    
                    Button(action: generateMeditation) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                    }
                    .padding(.leading, 8)
                }
                .padding(.horizontal)
                
                if meditationGenerated {
                    Button(action: {
                        isOnboardingComplete = true
                    }) {
                        Text("See my 1st Meditation")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            
            if isGeneratingMeditation {
                LoadingOverlay()
            }
        }
    }

    // http://localhost:3000/generate-meditation
    // https://us-central1-meditation-438805.cloudfunctions.net/generate-meditation
    
    func generateMeditation() {
        isGeneratingMeditation = true
        let currentMessage = message
        message = ""
        
        let url = URL(string: "http://localhost:3000/generate-meditation")!
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

//
//  OB13BView.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 11/13/24.
//

import SwiftUI

struct OB13BView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    @Environment(\.dismiss) var dismiss
    @State private var message: String = ""
    @State private var animationAmount: CGFloat = 1.0
    @State private var isGeneratingMeditation = false
    @State private var meditationGenerated = false
    @AppStorage("audioFiles") private var audioFilesData: Data = Data()
    @AppStorage("userName") private var userName: String = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case message
    }
    
    private var lowestScoringAssessment: String {
        let scores = [
            ("Anxiety", 100 - onboardingManager.onboardingData.anxiety),
            ("Depression", 100 - onboardingManager.onboardingData.depression),
            ("Trauma", 100 - onboardingManager.onboardingData.trauma),
            ("Relationships", 100 - onboardingManager.onboardingData.relationship),
            ("Self-Esteem", 100 - onboardingManager.onboardingData.esteem)
        ]
        
        return scores.sorted { $0.1 < $1.1 }.first?.0 ?? "Anxiety"
    }
    
    var body: some View {
        ZStack {
            // Background image
            Image("granite_bg")
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
                
                // Lottie animation and step text
                HStack {
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    Text("Step 2:\nAdd details")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding()
                
                // Assessment type heading
                 Text("Day 1")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 5)

                Text("\(lowestScoringAssessment) Meditation")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
                
                // Multi-line message input field
                ZStack(alignment: .topLeading) {
                    if message.isEmpty {
                        Text("Add any details about your \(lowestScoringAssessment) to make it more personalized. You can add anything you'd like.")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $message)
                        .frame(height: 160) // Approximately 8 lines
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .focused($focusedField, equals: .message)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                )
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
                
                // Continue button
                Button(action: {
                    generateMeditation()
                }) {
                    Text("CREATE MEDITATION")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Group {
                                if !message.isEmpty {
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
                .disabled(message.isEmpty)
                .opacity(message.isEmpty ? 0.5 : 1.0)
                
                if meditationGenerated {
                    Button(action: {
                        isOnboardingComplete = true
                        dismiss() // Dismiss the current view
                        // Force UI update
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
                        }
                    }) {
                        Text("Go to My Meditation")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#FFB347"), Color(hex: "#FF69B4")]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .scaleEffect(animationAmount)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: animationAmount
                    )
                }
            }
            
            if isGeneratingMeditation {
                LoadingOverlay()
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
    
    private func generateMeditation() {
        focusedField = nil // Dismiss keyboard
        isGeneratingMeditation = true
        let currentMessage = message
        message = ""
        
        let url = URL(string: "https://us-central1-meditation-438805.cloudfunctions.net/generate-meditation")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "message": currentMessage,
            "themes": [lowestScoringAssessment],
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
                        
                        let newBackgroundImageName = "background1"
                        
                        let newAudioFile = AudioFileModel(
                            id: UUID(),
                            fileName: fileName,
                            creationDate: Date(),
                            message: currentMessage,
                            themes: [lowestScoringAssessment],
                            isFavorite: false,
                            hasBeenPlayed: false,
                            backgroundImageName: newBackgroundImageName
                        )
                        
                        // Update audioFilesData
                        var audioFiles = [AudioFileModel]()
                        if let existingData = try? JSONDecoder().decode([AudioFileModel].self, from: audioFilesData) {
                            audioFiles = existingData
                        }
                        audioFiles.insert(newAudioFile, at: 0)
                        if let encodedData = try? JSONEncoder().encode(audioFiles) {
                            audioFilesData = encodedData
                        }
                        
                        meditationGenerated = true
                    } catch {
                        print("Error saving audio file: \(error)")
                    }
                }
            }
        }.resume()
    }
}


#Preview {
    OB13BView()
}

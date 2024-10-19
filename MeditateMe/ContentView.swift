//
//  ContentView.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/18/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var message = ""
    @State private var selectedThemes: Set<String> = []
    @State private var isLoading = false
    @State private var audioFiles: [AudioFileModel] = []
    let availableThemes = ["Relaxation", "Focus", "Sleep", "Anxiety Relief", "Mindfulness"]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            // List of audio files
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(audioFiles) { audioFile in
                        AudioFileView(audioFile: audioFile, onDelete: { deleteAudioFile(audioFile) })
                            .aspectRatio(1/1.618, contentMode: .fit) // Golden ratio
                    }
                }
                .padding()
            }

            Spacer()

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
                ExpandingTextView(text: $message)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 30))
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .overlay(
            LoadingView()
                .opacity(isLoading ? 1 : 0)
        )
        .onAppear(perform: loadAudioFiles)
    }

    func sendMessage() {
        isLoading = true
        let url = URL(string: "http://localhost:3000/generate-meditation")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "message": message,
            "themes": Array(selectedThemes)
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    do {
                        let fileName = "meditation_\(Date().timeIntervalSince1970).mp3"
                        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
                        try data.write(to: fileURL)
                        
                        let newAudioFile = AudioFileModel(id: UUID(), fileName: fileName, creationDate: Date())
                        audioFiles.insert(newAudioFile, at: 0)
                        saveAudioFiles()
                    } catch {
                        print("Error saving audio file: \(error)")
                    }
                } else if let error = error {
                    print("Error: \(error)")
                }
            }
        }.resume()

        message = ""
        selectedThemes.removeAll()
    }

    func loadAudioFiles() {
        if let data = UserDefaults.standard.data(forKey: "audioFiles") {
            if let decodedAudioFiles = try? JSONDecoder().decode([AudioFileModel].self, from: data) {
                audioFiles = decodedAudioFiles
            }
        }
    }

    func saveAudioFiles() {
        if let encodedData = try? JSONEncoder().encode(audioFiles) {
            UserDefaults.standard.set(encodedData, forKey: "audioFiles")
        }
    }

    func deleteAudioFile(_ audioFile: AudioFileModel) {
        if let index = audioFiles.firstIndex(where: { $0.id == audioFile.id }) {
            audioFiles.remove(at: index)
            saveAudioFiles()
            
            // Delete the actual file
            do {
                try FileManager.default.removeItem(at: audioFile.url)
            } catch {
                print("Error deleting file: \(error)")
            }
        }
    }
}

struct AudioFileView: View {
    let audioFile: AudioFileModel
    let onDelete: () -> Void
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: TimeInterval = 0
    @State private var errorMessage: String?
    @State private var isDragging = false
    @State private var showingDeleteConfirmation = false
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.1))
                
                ProgressArc(progress: progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showingDeleteConfirmation = true }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 24))
                        }
                    }
                    .padding(8)
                    
                    Spacer()
                    
                    HStack {
                        Text(timeString(time: duration))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Spacer()
                        
                        Button(action: togglePlayPause) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                        }
                        .disabled(errorMessage != nil)
                    }
                }
                .padding(12)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let angle = Double(atan2(value.location.y - geometry.size.height / 2,
                                                 value.location.x - geometry.size.width / 2))
                        var normalizedAngle = (angle + .pi / 2) / (.pi * 2)
                        if normalizedAngle < 0 {
                            normalizedAngle += 1
                        }
                        progress = normalizedAngle
                    }
                    .onEnded { _ in
                        isDragging = false
                        if let player = audioPlayer {
                            player.currentTime = progress * player.duration
                            if isPlaying {
                                player.play()
                            }
                        }
                    }
            )
        }
        .aspectRatio(1/1.618, contentMode: .fit)
        .onAppear(perform: setupAudioPlayer)
        .onReceive(timer) { _ in
            if isPlaying && !isDragging {
                if let player = audioPlayer {
                    progress = player.currentTime / player.duration
                }
            }
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Meditation"),
                message: Text("Are you sure you want to delete this meditation? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func setupAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile.url)
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            errorMessage = nil
        } catch {
            print("Error creating audio player: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    private func togglePlayPause() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
    }

    private func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let second = Int(time) % 60
        return String(format: "%02d:%02d", minute, second)
    }
}

struct ProgressArc: Shape {
    var progress: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2 - 6, // Adjusted to account for the wider stroke
                    startAngle: .degrees(0),
                    endAngle: .degrees(360 * progress),
                    clockwise: false)
        return path
    }
}

struct AudioFileModel: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let creationDate: Date
    
    var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }
}

struct ThemeButton: View {
    let theme: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(theme)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(15)
        }
    }
}

struct ExpandingTextView: View {
    @Binding var text: String
    @State private var textViewHeight: CGFloat = 40

    var body: some View {
        ZStack(alignment: .leading) {
            Text(text.isEmpty ? "Enter your message" : text)
                .foregroundColor(text.isEmpty ? .gray : .clear)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })

            TextEditor(text: $text)
                .frame(height: max(40, textViewHeight))
                .padding(4)
        }
        .onPreferenceChange(ViewHeightKey.self) { textViewHeight = $0 }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
        }
    }
}

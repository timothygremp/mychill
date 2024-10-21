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
                        AudioFileView(
                            audioFile: audioFile,
                            onDelete: { deleteAudioFile(audioFile) },
                            onToggleFavorite: { toggleFavorite(audioFile) }
                        )
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
                        
                        let newAudioFile = AudioFileModel(
                            id: UUID(),
                            fileName: fileName,
                            creationDate: Date(),
                            message: message,
                            themes: Array(selectedThemes),
                            isFavorite: false
                        )
                        audioFiles.insert(newAudioFile, at: 0)
                        saveAudioFiles()
                        
                        // Clear input fields after successful creation
                        message = ""
                        selectedThemes.removeAll()
                    } catch {
                        print("Error saving audio file: \(error)")
                    }
                }
            }
        }.resume()
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

    func toggleFavorite(_ audioFile: AudioFileModel) {
        if let index = audioFiles.firstIndex(where: { $0.id == audioFile.id }) {
            audioFiles[index].isFavorite.toggle()
            saveAudioFiles()
        }
    }
}

struct AudioFileView: View {
    let audioFile: AudioFileModel
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: TimeInterval = 0
    @State private var currentTime: TimeInterval = 0
    @State private var errorMessage: String?
    @State private var isDragging = false
    @State private var showingInfoPopup = false
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.1))
                
                ProgressBorder(progress: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .blue, .purple, .red, .orange, .yellow, .green, .blue
                            ]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                
                if isPlaying || isDragging || progress > 0 {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .position(positionForProgress(progress, in: geometry.size))
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    updateProgress(value: value, in: geometry)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    if let player = audioPlayer {
                                        player.currentTime = progress * player.duration
                                        currentTime = player.currentTime
                                        if isPlaying {
                                            player.play()
                                        }
                                    }
                                }
                        )
                }

                VStack {
                    HStack {
                        Button(action: { showingInfoPopup = true }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.system(size: 24))
                        }
                        Spacer()
                        Button(action: onToggleFavorite) {
                            Image(systemName: audioFile.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                                .font(.system(size: 24))
                        }
                    }
                    .padding(8)
                    
                    Spacer()
                    
                    HStack {
                        // Time display
                        Text(timeDisplay())
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        Spacer()
                        
                        // Play/Pause button
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
        }
        .aspectRatio(1/1.618, contentMode: .fit)
        .onAppear(perform: setupAudioPlayer)
        .onReceive(timer) { _ in
            if isPlaying && !isDragging {
                if let player = audioPlayer {
                    progress = player.currentTime / player.duration
                    currentTime = player.currentTime
                }
            }
        }
        .sheet(isPresented: $showingInfoPopup) {
            InfoPopupView(audioFile: audioFile, onDelete: onDelete)
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

    private func timeDisplay() -> String {
        if isPlaying || progress > 0 {
            return "\(timeString(time: currentTime, includeLeadingZero: false)) / \(timeString(time: duration))"
        } else {
            return timeString(time: duration)
        }
    }

    private func timeString(time: TimeInterval, includeLeadingZero: Bool = true) -> String {
        let minute = Int(time) / 60
        let second = Int(time) % 60
        if includeLeadingZero {
            return String(format: "%02d:%02d", minute, second)
        } else {
            return String(format: "%d:%02d", minute, second)
        }
    }

    private func positionForProgress(_ progress: Double, in size: CGSize) -> CGPoint {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 - 6 // Adjusted to match the ProgressBorder radius
        let angle = Angle(degrees: -90 + 360 * progress) // Start from top
        return CGPoint(
            x: center.x + radius * CGFloat(cos(angle.radians)),
            y: center.y + radius * CGFloat(sin(angle.radians))
        )
    }

    private func updateProgress(value: DragGesture.Value, in geometry: GeometryProxy) {
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        let touchPoint = value.location
        
        let angle = atan2(touchPoint.y - center.y, touchPoint.x - center.x)
        var normalizedAngle = (angle + .pi / 2) / (2 * .pi)
        if normalizedAngle < 0 {
            normalizedAngle += 1
        }
        
        progress = normalizedAngle
        isDragging = true
    }
}

struct ProgressBorder: Shape {
    var progress: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 6
        let startAngle = Angle(degrees: -90) // Start from top
        let endAngle = Angle(degrees: -90 + 360 * progress)
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

struct AudioFileModel: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let creationDate: Date
    let message: String
    let themes: [String]
    var isFavorite: Bool
    
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
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 20, height: 20)
                        .offset(y: -30)
                        .rotationEffect(Angle(degrees: Double(index) * 72))
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .animation(Animation.easeInOut(duration: 1).repeatForever().delay(Double(index) * 0.2), value: isAnimating)
                }
            }
            .rotationEffect(isAnimating ? .degrees(360) : .degrees(0))
            .animation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct InfoPopupView: View {
    let audioFile: AudioFileModel
    let onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Creation Date")) {
                    Text(formattedDate(audioFile.creationDate))
                }
                Section(header: Text("Message")) {
                    Text(audioFile.message)
                }
                Section(header: Text("Themes")) {
                    ForEach(audioFile.themes, id: \.self) { theme in
                        Text(theme)
                    }
                }
                Section {
                    Button(action: { showingDeleteConfirmation = true }) {
                        Text("Delete Meditation")
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Meditation Info", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Delete Meditation"),
                    message: Text("Are you sure you want to delete this meditation? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        onDelete()
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

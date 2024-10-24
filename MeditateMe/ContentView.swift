//
//  ContentView.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/18/24.
//

import SwiftUI
import AVFoundation
import Lottie
import UIKit
import SuperwallKit

class MeditationCredits: ObservableObject {
    @Published var creditsUsed: Int {
        didSet {
            UserDefaults.standard.set(creditsUsed, forKey: "creditsUsed")
        }
    }
    
    let maxFreeCredits = 5
    
    init() {
        creditsUsed = UserDefaults.standard.integer(forKey: "creditsUsed")
    }
    
    func useCredit() {
        if creditsUsed < maxFreeCredits {
            creditsUsed += 1
        }
    }
    
    var remainingCredits: Int {
        return max(0, maxFreeCredits - creditsUsed)
    }
}

struct ContentView: View {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = false
    @State private var message = ""
    @State private var selectedThemes: Set<String> = []
    @State private var isLoading = false
    @State private var audioFiles: [AudioFileModel] = []
    let availableThemes = ["Relaxation", "Focus", "Sleep", "Anxiety Relief", "Mindfulness"]
    
    let totalBackgroundImages = 6

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @State private var isGeneratingMeditation = false
    @State private var isConversationActive = false
    @State private var sentMessage: String?
    @State private var textViewHeight: CGFloat = 40
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("audioFiles") private var audioFilesData: Data = Data()
    @StateObject private var meditationCredits = MeditationCredits()
    @State private var showPaywall = false
    @StateObject private var purchaseManager = PurchaseManager()
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            
            if isOnboardingComplete {
                VStack(spacing: 0) {
                    // List of audio files or "No Meditations" message
                    if audioFiles.isEmpty {
                        VStack {
                            Spacer()
                            Text("Hello, \(userName)👋")
                                .font(.title2)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 8)
                            Text("No meditations/affirmations yet🥺")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(Array(audioFiles.enumerated()), id: \.element.id) { index, audioFile in
                                    AudioFileView(
                                        audioFile: binding(for: audioFile),
                                        backgroundImageName: getBackgroundImageName(for: index),
                                        onDelete: { deleteAudioFile(audioFile) },
                                        onToggleFavorite: { toggleFavorite(audioFile) },
                                        onPlay: { markAsPlayed($0) }
                                    )
                                    .aspectRatio(1/1.618, contentMode: .fit)
                                }
                            }
                            .padding()
                        }
                    }

                    Spacer(minLength: 0)

                    // Thinner white divider
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                        .padding(.vertical, 10)

                    // Only show credits info if not subscribed
                    if !purchaseManager.isSubscribed {
                        Text("\(meditationCredits.creditsUsed) of \(meditationCredits.maxFreeCredits) free credits used")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }

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

                    Spacer(minLength: 0)

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

                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .overlay(
                    Group {
                        if isGeneratingMeditation {
                            LoadingOverlay()
                        }
                    }
                )
            } else {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete, audioFiles: $audioFiles, meditationCredits: meditationCredits)
            }
        }
        .overlay(
            LoadingView()
                .opacity(isLoading ? 1 : 0)
        )
        .onAppear {
            loadAudioFiles()
            setupAudioSession()
            Task {
                purchaseManager.resetSubscriptionCheck()
                await purchaseManager.updateSubscriptionStatus()
                print("ContentView appeared, isSubscribed: \(purchaseManager.isSubscribed)")
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(purchaseManager: purchaseManager)
        }
    }

    private func loadAudioFiles() {
        if let decodedAudioFiles = try? JSONDecoder().decode([AudioFileModel].self, from: audioFilesData) {
            audioFiles = decodedAudioFiles
        }
    }

    // Add this function to get the background image name
    private func getBackgroundImageName(for index: Int) -> String {
        let adjustedIndex = (index % totalBackgroundImages) + 1
        return "background\(adjustedIndex)"
    }
    // https://us-central1-meditation-438805.cloudfunctions.net/generate-meditation
//    http://localhost:3000/generate-meditation

    func sendMessage() {
        Task {
            purchaseManager.resetSubscriptionCheck()
            await purchaseManager.updateSubscriptionStatus()
            print("Send button pressed, isSubscribed: \(purchaseManager.isSubscribed)")
            if purchaseManager.isSubscribed || meditationCredits.remainingCredits > 0 {
                if !purchaseManager.isSubscribed {
                    meditationCredits.useCredit()
                    print("Used a credit, remaining: \(meditationCredits.remainingCredits)")
                }
                // Existing send message logic
                isGeneratingMeditation = true
                sentMessage = message
                let currentMessage = message // Store the current message
                message = "" // Clear the input field immediately
                
                let url = URL(string: "https://us-central1-meditation-438805.cloudfunctions.net/generate-meditation")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body: [String: Any] = [
                    "message": currentMessage,
                    "themes": Array(selectedThemes),
                    "userName": userName // Add this line
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
                                audioFiles.insert(newAudioFile, at: 0)
                                saveAudioFiles()
                                
                                // Reset the view
                                selectedThemes.removeAll()
                                isConversationActive = false
                                sentMessage = nil
                            } catch {
                                print("Error saving audio file: \(error)")
                            }
                        }
                    }
                }.resume()
            } else {
                print("Showing paywall")
                showPaywall = true
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

    private func binding(for audioFile: AudioFileModel) -> Binding<AudioFileModel> {
        guard let index = audioFiles.firstIndex(where: { $0.id == audioFile.id }) else {
            fatalError("Can't find audio file in array")
        }
        return $audioFiles[index]
    }

    func markAsPlayed(_ audioFile: AudioFileModel) {
        if let index = audioFiles.firstIndex(where: { $0.id == audioFile.id }) {
            audioFiles[index].hasBeenPlayed = true
            saveAudioFiles()
        }
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
}

struct AudioFileView: View {
    @Binding var audioFile: AudioFileModel  // Change this to a binding
    let backgroundImageName: String
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    let onPlay: (AudioFileModel) -> Void
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioPlayerManager: AudioPlayerManager?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: TimeInterval = 0
    @State private var currentTime: TimeInterval = 0
    @State private var errorMessage: String?
    @State private var isDragging = false
    @State private var showingInfoPopup = false
    @State private var hasPlaybackStarted = false
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                Image(backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // Progress Arc
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
                
                if isPlaying || (progress > 0 && progress < 1) {
                    // Draggable Knob
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .position(positionForProgress(progress, in: geometry.size))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    updateProgress(value: value, in: geometry.size)
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
                                .foregroundColor(.white)
                                .font(.system(size: 28))
                        }
                        Spacer()
                        if !audioFile.hasBeenPlayed {
                            Text("NEW")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        Spacer()
                        Button(action: onToggleFavorite) {
                            Image(systemName: audioFile.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                                .font(.system(size: 28))
                        }
                    }
                    .padding(10)
                    
                    Spacer()
                    
                    HStack {
                        Text(timeDisplay())
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        Spacer()
                        
                        Button(action: togglePlayPause) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .disabled(errorMessage != nil)
                    }
                }
                .padding(12)

                // Date and Time
                VStack(spacing: 2) {
                    Text(formatDate(audioFile.creationDate))
                        .font(.system(size: 12, weight: .medium))
                    Text(formatTime(audioFile.creationDate))
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(6)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .aspectRatio(1/1.618, contentMode: .fit)
        .onAppear(perform: setupAudioPlayer)
        .onReceive(timer) { _ in
            if let player = audioPlayer, !isDragging {
                progress = player.currentTime / player.duration
                currentTime = player.currentTime
            }
        }
        .sheet(isPresented: $showingInfoPopup) {
            InfoPopupView(audioFile: audioFile, onDelete: onDelete)
        }
        .onAppear {
            print("Audio file creation date: \(audioFile.creationDate)")
            print("Formatted date: \(formatDate(audioFile.creationDate))")
            print("Formatted time: \(formatTime(audioFile.creationDate))")
        }
    }

    private func positionForProgress(_ progress: Double, in size: CGSize) -> CGPoint {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 - 6
        let angle = 2 * .pi * progress - .pi / 2
        return CGPoint(
            x: center.x + radius * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(sin(angle))
        )
    }

    private func updateProgress(value: DragGesture.Value, in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
//        let radius = min(size.width, size.height) / 2 - 6
        let vector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
        let angle = atan2(vector.dy, vector.dx) + .pi / 2
        var progress = (angle + .pi * 2).truncatingRemainder(dividingBy: .pi * 2) / (.pi * 2)
        progress = min(max(progress, 0), 1)
        
        self.progress = progress
        if let player = audioPlayer {
            player.currentTime = progress * player.duration
            currentTime = player.currentTime
        }
        isDragging = true
    }

    private func setupAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile.url)
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            
            audioPlayerManager = AudioPlayerManager {
                DispatchQueue.main.async {
                    self.isPlaying = false
                    self.progress = 0
                    self.currentTime = 0
                }
            }
            audioPlayer?.delegate = audioPlayerManager
            
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
            if progress >= 1.0 {
                audioPlayer?.currentTime = 0
                progress = 0
                currentTime = 0
            }
            audioPlayer?.play()
            hasPlaybackStarted = true
            audioFile.hasBeenPlayed = true  // Update the hasBeenPlayed status
            onPlay(audioFile)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    var onFinish: () -> Void
    var player: AVAudioPlayer?
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}

struct ProgressBorder: Shape {
    var progress: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 6
        let startAngle = Angle(degrees: -90)
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
    var hasBeenPlayed: Bool  // This should be var, not let
    
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
                .background(isSelected ? Color.blue : Color.white.opacity(0.2))
                .foregroundColor(.white) // This makes the text white
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

struct ExpandingTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    var onDone: () -> Void

    func makeUIView(context: Context) -> GradientPlaceholderTextView {
        let textView = GradientPlaceholderTextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.returnKeyType = .done
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.placeholder = "I'm stressed about..."
        textView.gradientColors = [UIColor(hex: "#9999ff"), UIColor(hex: "#cc99cc")]
        textView.textColor = .white
        return textView
    }

    func updateUIView(_ uiView: GradientPlaceholderTextView, context: Context) {
        uiView.text = text
        DispatchQueue.main.async {
            self.height = self.calculateHeight(uiView)
            uiView.isScrollEnabled = uiView.contentSize.height > 150
        }
    }

    private func calculateHeight(_ uiView: UITextView) -> CGFloat {
        let sizeThatFits = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        return min(max(40, sizeThatFits.height), 150)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ExpandingTextView

        init(_ parent: ExpandingTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.height = parent.calculateHeight(textView)
            textView.isScrollEnabled = textView.contentSize.height > 150
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()
                parent.onDone()
                return false
            }
            return true
        }
    }
}

class GradientPlaceholderTextView: UITextView {
    var placeholder: String = ""
    var gradientColors: [UIColor] = []
    
    override var text: String! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if text.isEmpty {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: self.font ?? UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7) // Changed to white with slight transparency
            ]
            
            placeholder.draw(in: rect.inset(by: textContainerInset), withAttributes: attributes)
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = max(value, nextValue())
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

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.7) // Increased opacity for more fog
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                LottieView(name: "flow_women", loopMode: .loop)
                    .frame(width: 250, height: 250) // Increased size of the animation
                
                Text("Generating your meditation...")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top)
            }
        }
    }
}

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {}
}

extension UIColor {
    convenience init(hex: String) {
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
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue:  CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}











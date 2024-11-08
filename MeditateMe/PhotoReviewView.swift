import SwiftUI
import Photos

struct PhotoReviewView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var animationAmount: CGFloat = 1.0
    @State private var showScores = false
    @State private var showImage = false
    @State private var isAnalyzing = true
    
    // Calculate current score (average of all 5 scores, inverted, and randomly adjusted)
    private var currentScore: Int {
        let scores = [
            onboardingManager.onboardingData.anxiety,
            onboardingManager.onboardingData.depression,
            onboardingManager.onboardingData.trauma,
            onboardingManager.onboardingData.relationship,
            onboardingManager.onboardingData.esteem
        ]
        let average = scores.reduce(0, +) / scores.count
        let inverted = 100 - average
        
        // Random adjustment between -4 and +4
        let randomAdjustment = Int.random(in: -3...3)
        
        // Ensure the final score stays within 0-100 range
        return max(0, min(100, inverted + randomAdjustment))
    }
    
    // Calculate potential score with more granular improvement factors
    private var potentialScore: Int {
        let current = Double(currentScore)
        
        let improvementFactor: Double
        switch current {
        case 0...10:
            improvementFactor = Double.random(in: 8.1...8.5)  // Ensures minimum 81, maximum 85 for lowest scores
        case 11...20:
            improvementFactor = Double.random(in: 4.05...4.25)  // For scores 11-20
        case 21...30:
            improvementFactor = Double.random(in: 2.7...2.83)  // For scores 21-30
        case 31...40:
            improvementFactor = Double.random(in: 2.02...2.13)  // For scores 31-40
        case 41...50:
            improvementFactor = Double.random(in: 1.62...1.7)  // For scores 41-50
        case 51...60:
            improvementFactor = Double.random(in: 1.35...1.42)  // For scores 51-60
        case 61...70:
            improvementFactor = Double.random(in: 1.16...1.22)  // For scores 61-70
        case 71...80:
            improvementFactor = Double.random(in: 1.04...1.09)  // For scores 71-80
        case 81...90:
            improvementFactor = Double.random(in: 1.02...1.05)  // For scores 81-90
        default:  // 91...100
            improvementFactor = Double.random(in: 1.01...1.03)  // For scores 91-100
        }
        
        // Calculate potential score with a ceiling of 98 and floor of 81
        let potential = min(max(current * improvementFactor, 86), 98)
        return Int(potential)
    }
    
    init(onboardingManager: OnboardingManager) {
        // Initialize with onboardingManager
    }
    
    var body: some View {
        ZStack {
            // Gradient background with animation
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1C232D"),
                    Color(hex: "#2C3440")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            
            // Subtle particle effect
            ParticleEffect()
                .opacity(0.15)
            
            VStack(spacing: 15) {
                // Add back the consistent chevron button
                HStack {
                    Button(action: {
                        onboardingManager.previousStep()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                .padding(.top)
                
                // Image section with card effect
                if let image = onboardingManager.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width * 0.65, height: UIScreen.main.bounds.width * 0.65)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "#FFB347").opacity(0.5), Color(hex: "#FF69B4").opacity(0.5)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .opacity(showImage ? 1 : 0)
                        .offset(y: showImage ? 0 : 20)
                }
                
                // Logo and Score Title closer together
                VStack(spacing: 5) {
                    // Logo section
                    HStack(alignment: .center, spacing: 0) {
                        LottieView(name: "sloth_10s", loopMode: .loop)
                            .frame(width: 70, height: 70)
                        
                        Text("ChillMe")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, -10)
                    }
                    
                    Text("🧘‍♀️InnerPeace🧘‍♂️ Score")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Scores section
                HStack(spacing: 40) {
                    // Current Score
                    ScoreCard(
                        title: "Current",
                        score: currentScore,
                        color1: Color(hex: "#FFB347"),
                        color2: Color(hex: "#FF69B4"),
                        showScore: showScores
                    )
                    
                    // Potential Score
                    ScoreCard(
                        title: "Potential",
                        score: potentialScore,
                        color1: Color(hex: "#4B95E7"),
                        color2: Color(hex: "#6BA5EA"),
                        showScore: showScores
                    )
                }
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(hex: "2C2C2E").opacity(0.8))
                        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 10)
                )
                .padding(.horizontal)
                
                Spacer(minLength: 0)
                
                // Continue button
                Button(action: {
                    onboardingManager.nextStep()
                }) {
                    Text("SEE MY HEALING PLAN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#FFB347"), Color(hex: "#FF69B4")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
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
                .padding(.bottom, 10)
            }
            .padding(.top, 10)
            
            if isAnalyzing {
                AnalyzingOverlay()
            }
        }
        .onAppear {
            animationAmount = 1.05
            withAnimation(.easeOut(duration: 0.8)) {
                showImage = true
            }
            
            // Add timer to remove overlay and show scores
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isAnalyzing = false
                }
                withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                    showScores = true
                }
            }
        }
    }
}

// Supporting Views
struct ScoreCard: View {
    let title: String
    let score: Int
    let color1: Color
    let color2: Color
    let showScore: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.system(size: 22))
                .foregroundColor(.gray)
            
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [color1.opacity(0.3), color2.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                
                Circle()
                    .trim(from: 0, to: showScore ? Double(score) / 100 : 0)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [color1, color2]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.5), value: showScore)
                
                Text("\(score)")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(showScore ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.5), value: showScore)
            }
            .frame(width: 120, height: 120)
        }
    }
}

struct ParticleEffect: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timeInterval = timeline.date.timeIntervalSinceReferenceDate
                let angle = Angle.degrees(timeInterval.remainder(dividingBy: 3) * 120)
                
                for i in 0..<20 {
                    let position = CGPoint(
                        x: size.width * 0.5 + CGFloat(cos(angle.radians + Double(i))) * 50,
                        y: size.height * 0.5 + CGFloat(sin(angle.radians + Double(i))) * 50
                    )
                    
                    let path = Path(ellipseIn: CGRect(x: position.x, y: position.y, width: 4, height: 4))
                    context.fill(path, with: .color(.white.opacity(0.1)))
                }
            }
        }
    }
}

struct AnalyzingOverlay: View {
    var body: some View {
        ZStack {
            // Use our consistent gradient background
            GradientBackgroundView()
                // .opacity(0.95)  // High opacity to ensure visibility
            
            // Add a semi-transparent black overlay for better contrast
            // Color.black.opacity(0.7)
            //     .edgesIgnoringSafeArea(.all)
            
            VStack {
                LottieView(name: "sloth_10s", loopMode: .loop)
                    .frame(width: 250, height: 250)
                
                Text("Creating your\n 🧘‍♀️InnerPeace🧘‍♂️ Score...")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.top)
            }
        }
    }
}

#Preview {
    PhotoReviewView(onboardingManager: OnboardingManager())
        .environmentObject(OnboardingManager())
}

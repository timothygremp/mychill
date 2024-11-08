import SwiftUI
import Photos

struct PhotoReviewView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var animationAmount: CGFloat = 1.0
    
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
        let randomAdjustment = Int.random(in: -4...4)
        
        // Ensure the final score stays within 0-100 range
        return max(0, min(100, inverted + randomAdjustment))
    }
    
    // Calculate potential score with more granular improvement factors
    private var potentialScore: Int {
        let current = Double(currentScore)
        
        // Define improvement potential based on current score with more precise multipliers
        let improvementFactor: Double
        switch current {
        case 0...20:   // Very low scores
            improvementFactor = Double.random(in: 2.87...3.13)
        case 21...40:  // Low scores
            improvementFactor = Double.random(in: 2.34...2.67)
        case 41...60:  // Medium scores
            improvementFactor = Double.random(in: 1.43...1.76)
        case 61...80:  // Higher scores
            improvementFactor = Double.random(in: 1.22...1.38)
        default:       // Very high scores
            improvementFactor = Double.random(in: 1.08...1.14)
        }
        
        // Calculate potential score with a ceiling of 100
        let potential = min(current * improvementFactor, 100)
        return Int(potential)
    }
    
    init(onboardingManager: OnboardingManager) {
        // Initialize with onboardingManager
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            GradientBackgroundView()
            
            VStack(spacing: 0) {
                // Top navigation bar with back button
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
                
                // Image container
                if let image = onboardingManager.capturedImage {
                    GeometryReader { geometry in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width / 1.5, height: geometry.size.width / 1.5)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .frame(height: UIScreen.main.bounds.width / 1.5)
                }
                
                // Horizontal Logo
                HStack(alignment: .bottom, spacing: 0) {
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 60, height: 60)
                    
                    Text("ChillMe")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.red)
                        .padding(.leading, -10)
                        .padding(.bottom, 4)
                }
                .padding(.top, 5)
                
                // Inner Peace Score section
                VStack(spacing: 15) {
                    Text("Inner Peace Score")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    HStack(spacing: 50) {
                        VStack {
                            Text("Current:")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                            Text("\(currentScore)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack {
                            Text("Potential:")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                            Text("\(potentialScore)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
                
                // Updated animated button
                Button(action: {
                    onboardingManager.nextStep()
                }) {
                    Text("CONTINUE")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
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
                .padding(.bottom, 34)
            }
        }
        .onAppear {
            animationAmount = 1.05  // Start the button animation
        }
    }
}

#Preview {
    PhotoReviewView(onboardingManager: OnboardingManager())
        .environmentObject(OnboardingManager())
}

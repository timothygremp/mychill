import SwiftUI
import Photos

struct PhotoReviewView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    

    
    // Calculate current score (average of all 5 scores)
    private var currentScore: Int {
        let scores = [
            onboardingManager.onboardingData.anxiety,
            onboardingManager.onboardingData.depression,
            onboardingManager.onboardingData.trauma,
            onboardingManager.onboardingData.relationship,
            onboardingManager.onboardingData.esteem
        ]
        return scores.reduce(0, +) / scores.count
    }
    
    // Calculate potential score with more granular improvement factors
    private var potentialScore: Int {
        let current = Double(currentScore)
        
        // Define improvement potential based on current score with more precise multipliers
        let improvementFactor: Double
        switch current {
        case 0...20:   // Very low scores
            improvementFactor = Double.random(in: 1.91...2.05)
        case 21...40:  // Low scores
            improvementFactor = Double.random(in: 1.63...1.80)
        case 41...60:  // Medium scores
            improvementFactor = Double.random(in: 1.24...1.42)
        case 61...80:  // Higher scores
            improvementFactor = Double.random(in: 1.10...1.37)
        default:       // Very high scores
            improvementFactor = Double.random(in: 1.13...1.24)
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
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
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
                
                // Continue button
                Button(action: {
                    onboardingManager.nextStep()
                }) {
                    Text("CONTINUE")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#8FE055"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom, 34)
            }
        }
    }
}

#Preview {
    PhotoReviewView(onboardingManager: OnboardingManager())
        .environmentObject(OnboardingManager())
}

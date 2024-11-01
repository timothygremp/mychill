import SwiftUI

struct OB25View: View {
    @State private var selectedStreak: Int? = nil
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("Commit to learning!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                // Streak options
                VStack(spacing: 16) {
                    streakOption(day: 7, description: "Good")
                    streakOption(day: 14, description: "Great")
                    streakOption(day: 30, description: "Incredible")
                    streakOption(day: 50, description: "Unstoppable")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Lottie animation and message
                VStack(spacing: 20) {
                    LottieView(name: "flow_women", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    Text("Streak goals help\nyou stay committed!")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                
                Spacer()
                
                // Commit button
                Button(action: {
                    // Button action will be added later
                }) {
                    Text("COMMIT TO MY GOAL")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(selectedStreak != nil ? Color(hex: "#1C232D") : .gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedStreak != nil ? Color(hex: "#4B95E7") : Color.gray.opacity(0.5))
                        )
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    private func streakOption(day: Int, description: String) -> some View {
        HStack {
            Text("\(day) day streak")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(description)
                .font(.system(size: 18))
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selectedStreak == day ? Color(hex: "#4B95E7") : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            selectedStreak = day
        }
    }
}

struct OB25View_Previews: PreviewProvider {
    static var previews: some View {
        OB25View()
    }
} 
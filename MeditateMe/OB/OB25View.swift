import SwiftUI

struct OB25View: View {
    @State private var selectedStreak: Int? = nil
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("Commit to learning!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                // Streak goals list
                VStack(spacing: 0) {
                    streakRow(days: 7, achievement: "Good", isSelected: selectedStreak == 7) {
                        selectedStreak = 7
                    }
                    
                    streakRow(days: 14, achievement: "Great", isSelected: selectedStreak == 14) {
                        selectedStreak = 14
                    }
                    
                    streakRow(days: 30, achievement: "Incredible", isSelected: selectedStreak == 30) {
                        selectedStreak = 30
                    }
                    
                    streakRow(days: 50, achievement: "Unstoppable", isSelected: selectedStreak == 50) {
                        selectedStreak = 50
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Lottie animation and message
                HStack {
                    LottieView(name: "flow_women", loopMode: .loop)
                        .frame(width: 80, height: 80)
                    
                    Text("Streak goals help\nyou stay\ncommitted!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Commit button
                Button(action: {
                    // Button action will be added later
                }) {
                    Text("COMMIT TO MY GOAL")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedStreak != nil ? Color(hex: "#4B95E7") : Color.gray.opacity(0.3))
                        )
                        .padding(.horizontal)
                }
                .disabled(selectedStreak == nil)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func streakRow(days: Int, achievement: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text("\(days) day streak")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(achievement)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            .padding()
            .background(isSelected ? Color.gray.opacity(0.3) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OB25View_Previews: PreviewProvider {
    static var previews: some View {
        OB25View()
    }
} 
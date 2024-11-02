import SwiftUI

struct OB24View: View {
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Lottie flame animation
                LottieView(name: "flow_women", loopMode: .loop)
                    .frame(width: 120, height: 120)
                
                // Day streak number
                Text("1")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(Color(hex: "#FFA500")) // Orange
                
                Text("day streak")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "#FFA500")) // Orange
                
                // Week view
                VStack(spacing: 12) {
                    // Days of week
                    HStack(spacing: 20) {
                        ForEach(["Th", "Fr", "Sa", "Su", "Mo", "Tu", "We"], id: \.self) { day in
                            Text(day)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(day == "Th" ? Color(hex: "#FFA500") : Color.gray)
                        }
                    }
                    
                    // Circles
                    HStack(spacing: 20) {
                        // Checked circle for Thursday
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#FFA500"))
                                .frame(width: 24, height: 24)
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .bold))
                        }
                        
                        // Empty circles for other days
                        ForEach(0..<6) { _ in
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Message
                Text("Practice each day so your streak\nwon't reset!")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Spacer()
                
                // I'm Committed button
                Button(action: {
                    // Button action will be added later
                }) {
                    Text("I'M COMMITTED")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#1C232D"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#4B95E7")) // Blue
                        )
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct OB24View_Previews: PreviewProvider {
    static var previews: some View {
        OB24View()
    }
} 



import SwiftUI

struct OB24View: View {
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Lottie animation for flame
                LottieView(name: "flow_women", loopMode: .loop)
                    .frame(width: 120, height: 120)
                
                // Streak count
                Text("1")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(Color(hex: "#FFA500")) // Orange color
                
                // Streak text
                Text("day streak")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#FFA500")) // Orange color
                
                // Streak calendar
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        ForEach(["Th", "Fr", "Sa", "Su", "Mo", "Tu", "We"], id: \.self) { day in
                            VStack {
                                Text(day)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(day == "Th" ? .white : .gray)
                                
                                if day == "Th" {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: "#FFA500")) // Orange
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    Text("Practice each day so your streak\nwon’t reset!")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                )
                .padding(.horizontal)
                
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
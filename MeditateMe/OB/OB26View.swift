import SwiftUI

struct OB26View: View {
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Title text
                Text("Learners with our widget are\n60% more likely to keep their\nstreak for a month!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
                
                Spacer()
                
                // Phone mockup
                ZStack {
                    // Phone frame
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 280, height: 500)
                    
                    // App icon with streak count
                    // VStack {
                    //     HStack {
                    //         ZStack {
                    //             RoundedRectangle(cornerRadius: 16)
                    //                 .fill(Color(hex: "#FF4B4B")) // Red background
                    //                 .frame(width: 80, height: 80)
                                
                    //             VStack(spacing: 0) {
                    //                 HStack(spacing: 2) {
                    //                     Image(systemName: "flame.fill")
                    //                         .foregroundColor(.white)
                    //                     Text("1")
                    //                         .foregroundColor(.white)
                    //                         .font(.system(size: 16, weight: .bold))
                    //                 }
                    //                 .padding(.bottom, 4)
                                    
                    //                 LottieView(name: "flow_women", loopMode: .loop)
                    //                     .frame(width: 50, height: 50)
                    //             }
                    //         }
                    //         Spacer()
                    //     }
                    //     .padding(.top, -160)
                    //     .padding(.leading, 60)
                        
                    //     Spacer()
                    // }
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // Add widget action
                    }) {
                        Text("ADD WIDGET")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#1C232D"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "#4B95E7")) // Blue
                            )
                    }
                    
                    Button(action: {
                        // Not now action
                    }) {
                        Text("NOT NOW")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#4B95E7")) // Blue
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}

struct OB26View_Previews: PreviewProvider {
    static var previews: some View {
        OB26View()
    }
} 
import SwiftUI

struct OB29View: View {
    @State private var name: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Top navigation bar with back button and progress
                HStack {
                    Button(action: {
                        // Navigation action will be added later
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    }
                    .padding(.leading)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .foregroundColor(Color(hex: "#8FE055"))
                                .frame(width: geometry.size.width * 0.4, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Question
                Text("What is your name?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Name input field
                TextField("Name", text: $name)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .focused($isFocused)
                
                // Next button
                Button(action: {
                    // Button action will be added later
                }) {
                    Text("NEXT")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(name.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "#4B95E7"))
                        )
                        .padding(.horizontal)
                }
                .disabled(name.isEmpty)
                
                Spacer()
                
                // Social sign up buttons
                VStack(spacing: 16) {
                    socialButton(text: "SIGN UP WITH GOOGLE", image: "google_logo", backgroundColor: Color.gray.opacity(0.2))
                    socialButton(text: "SIGN UP WITH FACEBOOK", image: "facebook_logo", backgroundColor: Color.gray.opacity(0.2))
                    socialButton(text: "SIGN UP WITH APPLE", image: "apple_logo", backgroundColor: Color.gray.opacity(0.2))
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            isFocused = true // Automatically show keyboard
        }
    }
    
    private func socialButton(text: String, image: String, backgroundColor: Color) -> some View {
        Button(action: {
            // Social sign up action will be added later
        }) {
            HStack {
                Image(image) // Make sure to add these images to your assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(text)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
        }
    }
}

struct OB29View_Previews: PreviewProvider {
    static var previews: some View {
        OB29View()
    }
} 
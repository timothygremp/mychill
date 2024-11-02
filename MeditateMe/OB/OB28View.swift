import SwiftUI

struct OB28View: View {
    @State private var age: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Top navigation bar with X and progress
                HStack {
                    Button(action: {
                        // Navigation action will be added later
                    }) {
                        Image(systemName: "xmark")
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
                                .frame(width: geometry.size.width * 0.2, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Question
                Text("How old are you?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                // Age input field
                TextField("Age", text: $age)
                    .keyboardType(.numberPad)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .focused($isFocused)
                
                Spacer()
                
                // Terms text
                Text("By signing in to Duolingo, you agree to our ")
                    .foregroundColor(.gray) +
                Text("Terms")
                    .foregroundColor(.white) +
                Text(" and ")
                    .foregroundColor(.gray) +
                Text("Privacy Policy")
                    .foregroundColor(.white) +
                Text(".")
                    .foregroundColor(.gray)
                
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
                                .fill(age.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "#4B95E7"))
                        )
                        .padding(.horizontal)
                }
                .disabled(age.isEmpty)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            isFocused = true // Automatically show keyboard
        }
    }
}

struct OB28View_Previews: PreviewProvider {
    static var previews: some View {
        OB28View()
    }
} 
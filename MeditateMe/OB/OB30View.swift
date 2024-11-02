import SwiftUI

struct OB30View: View {
    @State private var email: String = ""
    @FocusState private var isFocused: Bool
    let userName: String = "Danny" // This would come from previous view
    
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
                                .frame(width: geometry.size.width * 0.6, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Question
                Text("What is your email address,\n\(userName)?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Email input field
                TextField("Email", text: $email)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
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
                                .fill(email.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "#4B95E7"))
                        )
                        .padding(.horizontal)
                }
                .disabled(email.isEmpty)
                
                Spacer()
            }
        }
        .onAppear {
            isFocused = true // Automatically show keyboard
        }
    }
}

struct OB30View_Previews: PreviewProvider {
    static var previews: some View {
        OB30View()
    }
} 
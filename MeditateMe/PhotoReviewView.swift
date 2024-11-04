import SwiftUI
import AVFoundation
import Photos

struct PhotoReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scanningOffset: CGFloat = 0
    @State private var isAnimating = false
    @State private var progressValue: CGFloat = 0
    let selectedImage: UIImage
    
    var body: some View {
        ZStack {
            // Black background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Dismiss button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .padding()
                    Spacer()
                }
                
                Spacer()
                
                // Image with scanning animation
                ZStack {
                    // Selected image
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(hex: "#4BE055"), lineWidth: 2)
                        )
                        .padding(.horizontal)
                    
                    // Scanning line animation
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#4BE055").opacity(0),
                                    Color(hex: "#4BE055").opacity(0.5),
                                    Color(hex: "#4BE055").opacity(0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 60)
                        .offset(y: scanningOffset)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Circular progress with Lottie
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 80, height: 80)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(Color(hex: "#4BE055"), lineWidth: 3)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    // Lottie animation
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 60, height: 60)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Start scanning animation
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                scanningOffset = UIScreen.main.bounds.height / 3
            }
            
            // Start progress animation
            withAnimation(.linear(duration: 5)) {
                progressValue = 1.0
            }
        }
    }
}

// Preview
struct PhotoReviewView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoReviewView(selectedImage: UIImage())
    }
} 

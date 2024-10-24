import SwiftUI

struct ThemeButton: View {
    let theme: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(theme)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    ZStack {
                        if isSelected {
                            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FFB347"), Color(hex: "#FF69B4")]), startPoint: .leading, endPoint: .trailing)
                        } else {
                            Color.white.opacity(0.2)
                        }
                    }
                )
                .foregroundColor(.white) // This makes the text white
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle()) // Ensure no default button style is applied
    }
}

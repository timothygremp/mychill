import SwiftUI

struct ThemeButton: View {
    let theme: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(theme)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        if isSelected {
                            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FFB347"), Color(hex: "#FF69B4")]), startPoint: .leading, endPoint: .trailing)
                                .cornerRadius(20)
                        } else {
                            Color.white.opacity(0.2)
                                .cornerRadius(20)
                        }
                    }
                )
                .foregroundColor(isSelected ? .white : .black)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle()) // Ensure no default button style is applied
    }
}

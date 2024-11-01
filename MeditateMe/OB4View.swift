//
//  OB4View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB4View: View {
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#1C232D")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                // Duolingo mascot image - replace with your own image asset
                Image("duolingo_reading") // Make sure to add your own image asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 15) {
                    Text("COURSE BUILDING...")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color.gray)
                        .tracking(2) // Letter spacing
                    
                    Text("Get ready to join the 7 million people")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("currently learning French with\nDuolingo!")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Progress bar
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.white))
                    .frame(width: 150)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OB4View()
}

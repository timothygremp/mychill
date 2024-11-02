//
//  OB1View.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/31/24.
//

import SwiftUI

struct OB1View: View {

    
    var body: some View {
        ZStack {
//            Color(red: 0.1, green: 0.1, blue: 0.1).edgesIgnoringSafeArea(.all)
//            Color(.black).edgesIgnoringSafeArea(.all)
            Color(hex: "1C1B1F").edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Image("r&J_welcome")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .foregroundColor(.red)
                
                Text("FlameGame")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.red)
                
                
                Text("Love Language Maxxing❤️‍🔥")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("GET STARTED")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: {
                    // Action for I ALREADY HAVE AN ACCOUNT
                }) {
                    Text("I ALREADY HAVE AN ACCOUNT")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer().frame(height: 20)
            }
        }
        .statusBar(hidden: false)
    }
}

    

#Preview {
    OB1View()
}

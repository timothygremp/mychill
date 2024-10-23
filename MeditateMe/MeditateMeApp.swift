//
//  MeditateMeApp.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/18/24.
//

import SwiftUI
import SuperwallKit

@main
struct MeditateMeApp: App {
    
    init() {
        Superwall.configure(apiKey: "pk_c76acc0ba1a073bd1245aa0f57bd6117473050b8f13693f1")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

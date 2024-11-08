//
//  MeditateMeApp.swift
//  MeditateMe
//
//  Created by Alaryce Patterson on 10/18/24.
//

import SwiftUI
//import SuperwallKit
import StoreKit

@main
struct MeditateMeApp: App {
    @StateObject private var onboardingManager = OnboardingManager()
    
    init() {
//        Superwall.configure(apiKey: "pk_c76acc0ba1a073bd1245aa0f57bd6117473050b8f13693f1")
        Task {
                    for await result in Transaction.updates {
                        do {
                            let transaction = try checkVerified(result)
                            // Handle successful purchase
                            await transaction.finish()
                        } catch {
                            print("Transaction failed verification")
                        }
                    }
                }
    }
    
   
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            OnboardingContainerView()
//            CameraView()
            
        }
    }
}

func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .unverified:
        throw StoreError.failedVerification
    case .verified(let safe):
        return safe
    }
}

enum StoreError: Error {
    case failedVerification
}

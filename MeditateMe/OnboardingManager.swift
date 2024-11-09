import SwiftUI

class OnboardingManager: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var onboardingData = OnboardingData()
    @Published var capturedImage: UIImage?
    
    // Navigation functions
    func nextStep() {
        if currentStep < 20 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 1 {
            currentStep -= 1
        }
    }
    
    // Save to database function
    func saveOnboardingData() {
        // Implement your database saving logic here
        print("Saving onboarding data: \(onboardingData)")
    }
}

// Struct to hold all onboarding data
struct OnboardingData {
    var name: String = ""
    var age: Int = 0
    var email: String = ""
    var anxiety: Int = 50
    var depression: Int = 50
    var trauma: Int = 50
    var relationship: Int = 50
    var esteem: Int = 50
    var experience: Int = 50
    var meditationGoals: [String] = []
    var dailyGoalMinutes: Int = 0
    // Add o
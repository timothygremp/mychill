import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var onboardingManager = OnboardingManager()
    
    var body: some View {
        Group {
            switch onboardingManager.currentStep {
            case 1:
                OB1View()
            case 2:
                OB2View()
            case 3:
                OB3AView()
            case 4:
                OB3View()
            case 5:
                OB4View()
            case 6:
                OB5View()
            case 7:
                OB5AView()
            case 8:
                OB5BView()
            case 9:
                OB5CView()
            case 10:
                OB5DView()
            case 11:
                OB11View()
            case 12:
                OB12View()
            case 13:
                OB13View()
            case 14:
                OB14View()
            case 15:
                OB16View()
            case 16:
                OB17View()
            case 17:
                OB18View()
            case 18:
                OB19View()
            case 19:
                OB20View()
            case 20:
                OB21View()
            default:
                Text("Invalid step")
            }
        }
        .environmentObject(onboardingManager)
    }
} 

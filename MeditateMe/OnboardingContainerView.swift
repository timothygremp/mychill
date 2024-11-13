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
                OB3View()
            case 4:
                OB5View(onboardingManager: onboardingManager)
            case 5:
                OB5AView(onboardingManager: onboardingManager)
            case 6:
                OB5BView(onboardingManager: onboardingManager)
            case 7:
                OB5CView(onboardingManager: onboardingManager)
            case 8:
                OB5DView(onboardingManager: onboardingManager)
            case 9:
                OB3AView()
            case 10:
                CameraView(onboardingManager: onboardingManager)
            case 11:
                PhotoReviewView(onboardingManager: onboardingManager)
            case 12:
                OB9View()
            case 13:
                OB12View()
            case 14:
                OB13AView()
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

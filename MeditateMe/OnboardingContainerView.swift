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
                OB4View()
            case 5:
                OB5View()
            case 6:
                OB6View()
            case 7:
                OB7View()
            case 8:
                OB8View()
            case 9:
                OB9View()
            case 10:
                OB10View()
            case 11:
                OB11View()
            case 12:
                OB12View()
            case 13:
                OB13View()
            case 14:
                OB14View()
            case 15:
                OB15View()
            case 16:
                OB16View()
            case 17:
                OB17View()
            case 18:
                OB18View()
            case 19:
                OB19View()
            case 20:
                OB20View()
            default:
                Text("Invalid step")
            }
        }
        .environmentObject(onboardingManager)
    }
} 
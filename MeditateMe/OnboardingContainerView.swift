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
                OB6View()
            case 8:
                OB7View()
            case 9:
                OB8View()
            case 10:
                OB9View()
            case 11:
                OB10View()
            case 12:
                OB11View()
            case 13:
                OB12View()
            case 14:
                OB13View()
            case 15:
                OB14View()
            case 16:
                OB15View()
            case 17:
                OB16View()
            case 18:
                OB17View()
            case 19:
                OB18View()
            case 20:
                OB19View()
            case 21:
                OB20View()
            default:
                Text("Invalid step")
            }
        }
        .environmentObject(onboardingManager)
    }
} 

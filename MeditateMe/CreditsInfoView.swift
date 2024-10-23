import SwiftUI

struct CreditsInfoView: View {
    @ObservedObject var meditationCredits: MeditationCredits

    var body: some View {
        Text("\(meditationCredits.creditsUsed) of \(meditationCredits.maxFreeCredits) free credits used")
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal)
    }
}

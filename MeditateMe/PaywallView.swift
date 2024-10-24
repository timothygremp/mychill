import SwiftUI
import StoreKit

class PurchaseManager: ObservableObject {
    @Published var products: [StoreKit.Product] = []
    @Published var isSubscribed = false
    private var hasCheckedSubscription = false
    
    // Make sure this matches your product ID in App Store Connect
    private let subscriptionProductID = "weekly_299_0d_trial"
    
    init() {
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    @MainActor
    func loadProducts() async {
        do {
            let products = try await StoreKit.Product.products(for: ["weekly_299_0d_trial"])
            self.products = products
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: StoreKit.Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                await setSubscriptionStatus(true)
                print("Purchase successful, isSubscribed: \(isSubscribed)")
                return true
            case .unverified:
                print("Purchase unverified")
                return false
            }
        case .userCancelled:
            print("Purchase cancelled by user")
            return false
        case .pending:
            print("Purchase pending")
            return false
        @unknown default:
            print("Unknown purchase result")
            return false
        }
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        if hasCheckedSubscription {
            return
        }
        
        print("Checking subscription status...")
        var foundValidSubscription = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                print("Found transaction: \(transaction.productID)")
                print("Transaction state: \(transaction.revocationDate == nil ? "Active" : "Revoked")")
                if let expirationDate = transaction.expirationDate {
                    print("Expiration date: \(expirationDate)")
                    print("Is expired: \(expirationDate <= Date())")
                } else {
                    print("No expiration date")
                }
                
                if transaction.productID == subscriptionProductID {
                    if let expirationDate = transaction.expirationDate, expirationDate > Date() {
                        foundValidSubscription = true
                        await setSubscriptionStatus(true)
                        print("Valid subscription found")
                        break
                    }
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        if !foundValidSubscription {
            await setSubscriptionStatus(false)
            print("No valid subscription found")
        }
        
        hasCheckedSubscription = true
    }
    
    @MainActor
    private func setSubscriptionStatus(_ status: Bool) async {
        isSubscribed = status
        hasCheckedSubscription = true
        print("Subscription status set to: \(isSubscribed)")
    }
    
    func resetSubscriptionCheck() {
        hasCheckedSubscription = false
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}



struct PaywallView: View {
    @ObservedObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @State private var isPurchasing = false
    @State private var animationAmount: CGFloat = 1

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("Unlock Premium")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                    
                    VStack(spacing: 20) {
                        FeatureRow(iconName: "infinity", text: "Unlimited Meditations")
                        FeatureRow(iconName: "wand.and.stars", text: "Exclusive Themes")
                        FeatureRow(iconName: "chart.line.uptrend.xyaxis", text: "Progress Tracking")
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    if purchaseManager.products.isEmpty {
                        ProgressView()
                            .scaleEffect(1.5)
                            .foregroundColor(.white)
                    } else {
                        ForEach(purchaseManager.products, id: \.id) { product in
                            Button(action: {
                                Task {
                                    await purchaseProduct(product)
                                }
                            }) {
                                Text("Subscribe Now - \(product.displayPrice)")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                            }
                            .scaleEffect(animationAmount)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animationAmount)
                            .disabled(isPurchasing)
                        }
                    }
                    
                    Text("7-day free trial, then \(purchaseManager.products.first?.displayPrice ?? "$X.XX") / week")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button("Restore Purchases") {
                        Task {
                            // Implement restore purchases functionality
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            }
        }
        .onAppear {
            Task {
                await purchaseManager.loadProducts()
            }
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                animationAmount = 1.05
            }
        }
    }
    
    func purchaseProduct(_ product: StoreKit.Product) async {
        isPurchasing = true
        do {
            if try await purchaseManager.purchase(product) {
                print("Purchase completed, dismissing PaywallView")
                dismiss()
            }
        } catch {
            print("Purchase failed: \(error)")
        }
        isPurchasing = false
    }
}

struct FeatureRow: View {
    let iconName: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.white)
                .font(.system(size: 22, weight: .semibold))
                .frame(width: 30, height: 30)
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
            Spacer()
        }
    }
}

//struct PaywallView_Previews: PreviewProvider {
//    static var previews: some View {
//        PaywallView()
//    }
//}

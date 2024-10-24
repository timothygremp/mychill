import SwiftUI
import StoreKit
import Lottie

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
    
    func restorePurchases() async {
        print("Attempting to restore purchases...")
        do {
            try await AppStore.sync()
            self.resetSubscriptionCheck()
            await self.updateSubscriptionStatus()
            print("Restore completed. Subscription status: \(self.isSubscribed)")
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
}



struct PaywallView: View {
    @ObservedObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 20) {
                LottieView(name: "flow_women", loopMode: .loop)
                    .frame(width: 200, height: 200)
                
                Text("Unlock Premium")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Create unlimited meditations and keep your 100% custom meditation journey alive!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)
                
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
                            Text("Subscribe Now - \(product.displayPrice)/week")
                                .font(.headline)
                                .foregroundColor(.purple)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(15)
                        }
                        .disabled(isPurchasing)
                    }
                }
                
                Button("Restore Purchases") {
                    Task {
                        await restorePurchases()
                    }
                }
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
                .disabled(isRestoring)
            }
            .padding()
            
            // Dismiss button (X) in the upper left corner
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                            .padding(10)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    Spacer()
                }
                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Restore Purchases"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func purchaseProduct(_ product: StoreKit.Product) async {
        isPurchasing = true
        do {
            if try await purchaseManager.purchase(product) {
                dismiss()
            }
        } catch {
            print("Purchase failed: \(error)")
        }
        isPurchasing = false
    }

    func restorePurchases() async {
        isRestoring = true
        await purchaseManager.restorePurchases()
        if purchaseManager.isSubscribed {
            alertMessage = "Your purchases have been restored successfully."
            dismiss()
        } else {
            alertMessage = "No active subscriptions found to restore."
        }
        isRestoring = false
        showAlert = true
    }
}

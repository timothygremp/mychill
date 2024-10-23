import SwiftUI
import StoreKit
import SuperwallKit

class PurchaseManager: ObservableObject {
    @Published var products: [StoreKit.Product] = []
    @Published var purchasedProductIDs = Set<String>()

    init() {
        Task {
            await loadProducts()
        }
    }

    @MainActor
    func loadProducts() async {
        do {
            let products = try await StoreKit.Product.products(for: [])
            self.products = products
            for product in products {
                print("Product ID: \(product.id)")
                print("  Type: \(product.type)")
                print("  Price: \(product.price)")
                print("  Subscription Period: \(product.subscription?.subscriptionPeriod.debugDescription ?? "N/A")")
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: StoreKit.Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verificationResult):
            switch verificationResult {
            case .verified(let transaction):
                await transaction.finish()
                purchasedProductIDs.insert(product.id)
                return true
            case .unverified:
                return false
            }
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }
}

struct PaywallView: View {
    @StateObject private var purchaseManager = PurchaseManager()
    @State private var isPurchasing = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Upgrade to Premium")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Create unlimited meditations and unlock all features!")
                .multilineTextAlignment(.center)
                .padding()

            if purchaseManager.products.isEmpty {
                ProgressView()
            } else {
                ForEach(purchaseManager.products, id: \.id) { product in
                    Button(action: {
                        Task {
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
                    }) {
                        Text("Upgrade Now - \(product.displayPrice)")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isPurchasing)
                }
            }

            if isPurchasing {
                ProgressView()
            }
        }
        .padding()
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}

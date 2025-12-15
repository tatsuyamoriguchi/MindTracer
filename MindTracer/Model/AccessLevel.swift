//
//  AccessLevel.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 11/11/25.
//


enum AccessLevel: String {
    case free
    case premium
}

/*
 🧩 1. Inside your CloudKit data models
 As you’re already doing in SubscriptionStatus:
 @Published var tier: AccessLevel
 ✅ This prevents invalid values from ever being stored or read from CloudKit.
 ✅ When saving to CloudKit, you use tier.rawValue, keeping your record clean.
 
 💡 2. In your business logic / feature gating
 You’ll often write logic like:
 if subscriptionStatus.tier == .premium {
     unlockAdvancedAnalytics()
 } else {
     showUpgradePrompt()
 }
 ✅ This is safer and clearer than string comparisons.
 ✅ Later, if you add .pro, .team, or .lifetime, you only extend the enum instead of changing code everywhere.

 🎛️ 3. In your SwiftUI Views
 You can use it to conditionally show or hide premium-only UI:
 if userSubscription.tier == .premium {
     PremiumMoodChart()
 } else {
     Button("Upgrade to Premium") {
         showingPurchaseView = true
     }
 }
 or even control modifiers:
 .opacity(subscription.tier == .premium ? 1 : 0.5)
 .disabled(subscription.tier == .free)
 
 🧠 4. In your ViewModels / Environment objects
 For example:
 final class AppAccessManager: ObservableObject {
     @Published var accessLevel: AccessLevel = .free

     var isPremium: Bool { accessLevel == .premium }
 }
 This lets you inject @EnvironmentObject var accessManager: AppAccessManager
 and globally manage which views are unlocked.
 
 🧾 5. In your purchase verification logic
 When StoreKit verifies a transaction, you can easily map it:
 func updateAccessLevel(from transaction: Transaction) {
     if transaction.productID == "mindtracer.premium.subscription" {
         accessLevel = .premium
     } else {
         accessLevel = .free
     }
 }
 
 ☁️ 6. In CloudKit queries or filters
 When fetching users by access level (for analytics or admin tools):
 let predicate = NSPredicate(format: "tier == %@", AccessLevel.premium.rawValue)
 let query = CKQuery(recordType: "PurchaseStatus", predicate: predicate)
 
 🧩 7. In persistence (UserDefaults, localCredential, etc.)
 You can easily store or restore it locally:
 UserDefaults.standard.set(accessLevel.rawValue, forKey: "AccessLevel")
 and later:
 let level = AccessLevel(rawValue: UserDefaults.standard.string(forKey: "AccessLevel") ?? "free") ?? .free
 
 */

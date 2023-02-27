//
//  Store.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/2/14.
//

import Foundation
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
	case failedVerification
}

//Define our app's subscription tiers by level of service, in ascending order.
public enum SubscriptionTier: Int, Comparable {
		case none = 0
		case standard = 1
		case silver = 2

		public static func < (lhs: Self, rhs: Self) -> Bool {
				return lhs.rawValue < rhs.rawValue
		}
}

class Store: ObservableObject {
	@Published private(set) var subscriptions: [Product]
	@Published private(set) var purchasedSubscriptions: [Product] = []
	@Published private(set) var subscriptionGroupStatus: RenewalState?
	var updateListenerTask: Task<Void, Error>? = nil
	private let productIDs:[String] = ["scorewind.standard"]//["scorewind.standard","scorewind.silver"]

	init() {
		//Initialize empty products, and then do a product request asynchronously to fill them in.
		subscriptions = []
		
		//Start a transaction listener as close to app launch as possible so you don't miss any transactions.
		updateListenerTask = listenForTransactions()
		
		Task {
			//During store initialization, request products from the App Store.
			await requestProducts()
			
			//Deliver products that the customer purchases.
			await updateCustomerProductStatus()
		}
	}
	
	deinit {
		updateListenerTask?.cancel()
	}
	
	func listenForTransactions() -> Task<Void, Error> {
			return Task.detached {
					//Iterate through any transactions that don't come from a direct call to `purchase()`.
					for await result in Transaction.updates {
							do {
									let transaction = try self.checkVerified(result)

									//Deliver products to the user.
									await self.updateCustomerProductStatus()

									//Always finish a transaction.
									await transaction.finish()
							} catch {
									//StoreKit has a transaction that fails verification. Don't deliver content to the user.
									print("Transaction failed verification")
							}
					}
			}
	}
	
	@MainActor
	func requestProducts() async {
		do {
			//Request products from the App Store using the identifiers that the Products.plist file defines.
			let storeProducts = try await Product.products(for: productIDs)
			var newSubscriptions: [Product] = []
			
			//Filter the products into categories based on their type.
			for product in storeProducts {
				switch product.type {
				case .autoRenewable:
					newSubscriptions.append(product)
				default:
					//Ignore this product.
					print("Unknown product")
				}
			}
			
			//Sort each product category by price, lowest to highest, to update the store.
			subscriptions = newSubscriptions.sorted(by: { return $0.price < $1.price })
		} catch {
			print("Failed product request from the App Store server: \(error)")
		}
	}
	
	func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
		//Check whether the JWS passes StoreKit verification.
		switch result {
		case .unverified:
			//StoreKit parses the JWS, but it fails verification.
			throw StoreError.failedVerification
		case .verified(let safe):
			//The result is verified. Return the unwrapped value.
			return safe
		}
	}
	
	@MainActor
	func updateCustomerProductStatus() async {
		print("[debug] Store, updateCustomerProductStatus()")
		var purchasedSubscriptions: [Product] = []
		//Iterate through all of the user's purchased products.
		for await result in Transaction.currentEntitlements {
			print("[debug] Store, updateCustomerProductStatus result in currentEntitlements")
			do {
				//Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
				let transaction = try checkVerified(result)
				print("[debug] Store, updateCustomerProductStatus, transaction.productID \(transaction.productID)")
				//Check the `productType` of the transaction and get the corresponding product from the store.
				if transaction.productType == .autoRenewable {
					if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
						purchasedSubscriptions.append(subscription)
						print("[debug] Store, updateCustomerProductStatus .autoRenewable corresponding product \(subscription.displayName)")
					}
				}
			} catch {
				print()
			}
		}
	
		//Update the store information with auto-renewable subscription products.
		self.purchasedSubscriptions = purchasedSubscriptions
		
		//Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
		//is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
		//group, so products in the subscriptions array all belong to the same group. The statuses that
		//`product.subscription.status` returns apply to the entire subscription group.
		subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state
	}
	
	func purchase(_ product: Product) async throws -> Transaction? {
			//Begin purchasing the `Product` the user selects.
			let result = try await product.purchase()

			switch result {
			case .success(let verification):
					//Check whether the transaction is verified. If it isn't,
					//this function rethrows the verification error.
					let transaction = try checkVerified(verification)

					//The transaction is verified. Deliver content to the user.
					await updateCustomerProductStatus()

					//Always finish a transaction.
					await transaction.finish()

					return transaction
			case .userCancelled, .pending:
					return nil
			default:
					return nil
			}
	}
	
	func isPurchased(_ product: Product) async throws -> Bool {
			//Determine whether the user purchases a given product.
		if product.type == .autoRenewable {
			return purchasedSubscriptions.contains(product)
		} else {
			return false
		}
	}
	
	//Get a subscription's level of service using the product ID.
	func tier(for productId: String) -> SubscriptionTier {
			switch productId {
			case "subscription.standard":
					return .standard
			case "subscription.silver":
				return .silver
			default:
					return .none
			}
	}
}

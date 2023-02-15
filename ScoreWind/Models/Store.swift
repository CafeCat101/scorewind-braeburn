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

class Store: ObservableObject {
	@Published private(set) var subscriptions: [Product]
	@Published private(set) var purchasedSubscriptions: [Product] = []
	@Published private(set) var subscriptionGroupStatus: RenewalState?
	var updateListenerTask: Task<Void, Error>? = nil
	private let productIDs:[String] = ["subscription.standard"]

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
		var purchasedSubscriptions: [Product] = []
		
		//Iterate through all of the user's purchased products.
		for await result in Transaction.currentEntitlements {
			do {
				//Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
				let transaction = try checkVerified(result)
				
				//Check the `productType` of the transaction and get the corresponding product from the store.
				if transaction.productType == .autoRenewable {
					if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
						purchasedSubscriptions.append(subscription)
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
	
	
	
	
	
	
}

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
	//@Published var isSubscriptionValid = false
	@Published var enablePurchase = true
	@Published var offerIntroduction = false
	var isPublicUserVersion = false
	@Published var couponState:CouponState = .notActivated

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
		
		let readCouponState = UserDefaults.standard.object(forKey: "IsCouponValid") as? Int ?? CouponState.notActivated.rawValue
		if readCouponState == CouponState.notActivated.rawValue {
			couponState = .notActivated
		} else if readCouponState == CouponState.valid.rawValue {
			couponState = .valid
		} else if readCouponState == CouponState.expired.rawValue {
			couponState = .expired
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
						print("[debug] Store, updateCustomerProductStatus(), \(transaction.id) \(String(describing: transaction.offerType?.rawValue))")
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
		print("[debug] Store, purchasedSubscriptions.count \(self.purchasedSubscriptions.count)")
		
		//Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
		//is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
		//group, so products in the subscriptions array all belong to the same group. The statuses that
		//`product.subscription.status` returns apply to the entire subscription group.
		subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state
		
		if await checkCurrentSubscriptionIsValid() {
			self.enablePurchase = false
		} else {
			self.enablePurchase = true
		}
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
	
	@MainActor
	private func checkCurrentSubscriptionIsValid() async -> Bool {
		//::this function is copied from StoreView's updateSubscriptionStatus
		do {
			//var currentSubscription: Product?
			//var status: Product.SubscriptionInfo.Status?
			
			//This app has only one subscription group, so products in the subscriptions
			//array all belong to the same group. The statuses that
			//`product.subscription.status` returns apply to the entire subscription group.
			guard let product = self.subscriptions.first,
						let statuses = try await product.subscription?.status else {
				print("[debug] Store checkCurrentSubscriptionIsValid, no result for product and statuses ")
				return false
			}
			
			var highestStatus: Product.SubscriptionInfo.Status? = nil
			var highestProduct: Product? = nil
			
			//Iterate through `statuses` for this subscription group and find
			//the `Status` with the highest level of service that isn't
			//in an expired or revoked state. For example, a customer may be subscribed to the
			//same product with different levels of service through Family Sharing.
			for status in statuses {
				switch status.state {
				case .expired, .revoked:
					continue
				default:
					let renewalInfo = try self.checkVerified(status.renewalInfo)
					
					//Find the first subscription product that matches the subscription status renewal info by comparing the product IDs.
					guard let newSubscription = self.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
						continue
					}
					
					guard let currentProduct = highestProduct else {
						highestStatus = status
						highestProduct = newSubscription
						continue
					}
					
					let highestTier = self.tier(for: currentProduct.id)
					let newTier = self.tier(for: renewalInfo.currentProductID)
					
					if newTier > highestTier {
						highestStatus = status
						highestProduct = newSubscription
					}
				}
			}
			if highestProduct != nil {
				self.offerIntroduction = await eligibleForIntro(product: highestProduct!)
			} else {
				self.offerIntroduction = await eligibleForIntro(product: product)
			}
			print("[debug] Store checkCurrentSubscriptionIsValid eligibleForIntro \(String(describing: self.offerIntroduction))")
			
			print("[debug] Store checkCurrentSubscriptionIsValid highestStatus \(String(describing: highestStatus?.state))")
			print("[debug] Store checkCurrentSubscriptionIsValid highestProduct \(String(describing: highestProduct?.id))")
			
			if highestStatus?.state == .subscribed {
				return true
			} else {
				return false
			}
			
			
		} catch {
			print("Could not update subscription status \(error)")
			return false
		}
		
	}
	
	@MainActor
	func eligibleForIntro(product: Product) async -> Bool {
			guard let renewableSubscription = product.subscription else {
					// No renewable subscription is available for this product.
					return false
			}
			if await renewableSubscription.isEligibleForIntroOffer {
					// The product is eligible for an introductory offer.
					return true
			}
			return false
	}
	
	func validateCoupon(couponCode: String = "") async {
		print("[debug] Store, validateCoupon, couponCode \(couponCode)")
		if couponState == .notActivated && couponCode.isEmpty == false {
			//send post request to activate
			let mySendJsonObject = sendJsonObject(AppName: "scorewind-guitar-violin", CouponCode: couponCode)
			
			
			Task {
				do {
					let payload = try JSONEncoder().encode(mySendJsonObject)
					guard let url = URL(string: "https://music.scorewind.com/mobileapp_coupon_use.php") else { fatalError("Missing URL") }
					var urlRequest = URLRequest(url: url)
					urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
					urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
					urlRequest.httpMethod = "POST"
					//let useAppName = "scorewind-guitar-violin"
					//urlRequest.httpBody = payload
					
					/*URLSession.shared.dataTask(with: urlRequest) { data, response, error in
						guard error == nil else {
							print("Error: error calling POST")
							print(error!)
							return
						}
						guard let data = data else {
							print("Error: Did not receive data")
							return
						}
						guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
							print("Error: HTTP request failed")
							return
						}
						do {
							guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
								print("Error: Cannot convert data to JSON object")
								return
							}
							guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
								print("Error: Cannot convert JSON object to Pretty JSON data")
								return
							}
							guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
								print("Error: Couldn't print JSON in String")
								return
							}
							
							print(prettyPrintedJson)
						} catch {
							print("Error: Trying to convert JSON data to string")
							return
						}
					}.resume()*/
					
					
					let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: payload)
					
					guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
					
					let successInfo = try JSONDecoder().decode(responseInfo.self, from: data)
					
					print(String(data: data, encoding: .utf8) ?? "default value")
					print("Success: \(successInfo.Success)")
					print("CouponIsValid: \(successInfo.CouponIsValid)")
					print("Error: \(successInfo.Error)")
					DispatchQueue.main.async {
						if successInfo.CouponIsValid {
							self.couponState = .valid
						} else if successInfo.CouponIsValid == false {
							self.couponState = .expired
						}
					}
					
				} catch {
					print(error)
				}
				
			}
		} else {
			//check couponCode exists or not to make sure the coupon is being used from the device. if it is, send post request to validate it
			//if unable to validate it(ex: no internet), just leave it be, it's fine. The CouponIsValid mark is redding from device, the last value will be used.
		}
	}
}

struct sendJsonObject: Encodable {
	let AppName:String
	let CouponCode: String
}

struct responseInfo: Decodable {
	let Success: Bool
	let CouponIsValid: Bool
	let Error: String
}

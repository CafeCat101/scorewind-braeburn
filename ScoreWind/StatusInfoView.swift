import SwiftUI
import StoreKit

struct StatusInfoView: View {
	@EnvironmentObject var store: Store
	
	let product: Product
	let status: Product.SubscriptionInfo.Status
	@Environment(\.verticalSizeClass) var verticalSize
	@Environment(\.colorScheme) var colorScheme
	
	var body: some View {
		/*Text(statusDescription())
			.bold()
			.foregroundColor(Color("Dynamic/MainBrown+6"))
			.multilineTextAlignment(.center)
			.frame(maxWidth: .infinity, alignment: .center)*/
		
		VStack {
			(Text(product.displayPrice)+Text(" / ")+Text(getFriendlyPeriodName(product.subscription!, isIntroduction: false)))
				.bold()
				//.padding(.bottom, 20)
			if isInTrial() {
				HStack(spacing:0) {
					Spacer()
					/*Image(systemName: "gift.fill")
						.resizable()
						.scaledToFit()
						.frame(maxWidth: 25)
						.padding(.trailing,5)*/
					Text("1-month free trial")
						.bold()
						.padding([.top,.bottom], 5)
						.multilineTextAlignment(.center)
					Spacer()
				}
			}
		}
		
		if status.state == .subscribed {
			HStack {
				if colorScheme == .light {
					Text("Subscribed")
						.fontWeight(Font.Weight.bold)
						.foregroundColor(Color("Dynamic/ShadowReverse"))
				} else {
					Text("Subscribed")
						.foregroundColor(Color("Dynamic/StoreViewTitle"))
						.fontWeight(Font.Weight.medium)
				}
				
				Text(Image(systemName: "checkmark"))
					.bold()
					.foregroundColor(Color("Dynamic/ShadowReverse"))
			}
			.frame(maxWidth: verticalSize == .regular ? UIScreen.main.bounds.size.width*0.7 : UIScreen.main.bounds.size.width*0.5)
			.padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
			.background(
				RoundedRectangle(cornerRadius: CGFloat(17))
					.foregroundColor(colorScheme == .light ? Color("Dynamic/StoreViewTitle") : Color("Dynamic/MainBrown"))
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					.opacity(colorScheme == .light ? 1 : 0.25)
					.overlay {
						RoundedRectangle(cornerRadius: 17)
							.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
					}
			)
		}
		
		if isInTrial() {
			Text("Yoy will not be charged during your trial.")
				.foregroundColor(Color("Dynamic/MainBrown+6"))
				.bold()
				.padding([.leading,.trailing,.top], 30)
				.font(.subheadline)
		}
		
		Text(statusDescription())
			.foregroundColor(Color("Dynamic/MainBrown+6"))
			.bold()
			.padding([.leading,.trailing], 30)
			.padding(.top, isInTrial() ? 0 : 30)
			.font(.subheadline)
		
	}
	
	private func isInTrial() -> Bool {
		guard case .verified(let transaction) = status.transaction else {
			return false
		}
		
		if transaction.offerType != nil {
			return true
		}else {
			return false
		}
	}
	
	//Build a string description of the subscription status to display to the user.
	fileprivate func statusDescription() -> String {
		guard case .verified(let renewalInfo) = status.renewalInfo,
					case .verified(let transaction) = status.transaction else {
			return "The App Store could not verify your subscription status."
		}
		
		do {
			let data = try JSONEncoder().encode(transaction.jsonRepresentation)
			let jsonString = String(data: data, encoding: .utf8)!
			print(jsonString)
			print(transaction.purchaseDate)
			print(transaction.originalPurchaseDate)
		} catch {
			
		}
		
		if transaction.offerType != nil {
			print("[debug]transaction.offerType: \(String(describing: transaction.offerType))")
			print("[debug]renewalInfo.offerType: \(String(describing: renewalInfo.offerType))")
		}else {
			print("[debug]no offerType")
		}
		print("transaction.offerType - \(String(describing: transaction.offerType))")
		print("renewalInfo.offerType - \(String(describing: renewalInfo.offerType))")
		print("\(String(describing: transaction.expirationDate))")
		
		var description = ""
		
		switch status.state {
		case .subscribed:
			description = ""//subscribedDescription()
		case .expired:
			if let expirationDate = transaction.expirationDate,
				 let expirationReason = renewalInfo.expirationReason {
				description = expirationDescription(expirationReason, expirationDate: expirationDate)
			}
		case .revoked:
			if let revokedDate = transaction.revocationDate {
				description = "The App Store refunded your subscription to \(product.displayName) on \(revokedDate.storeFormattedDate())."
			}
		case .inGracePeriod:
			description = gracePeriodDescription(renewalInfo)
		case .inBillingRetryPeriod:
			description = billingRetryDescription()
		default:
			break
		}
		
		if let expirationDate = transaction.expirationDate {
			description += renewalDescription(renewalInfo, expirationDate)
		}
		
		if description.isEmpty && status.state == .subscribed && renewalInfo.willAutoRenew == false {
			//:: no renew date but subscribed, user has cancelled.
			description += "You can still access \(product.displayName) until \(transaction.expirationDate!.storeFormattedDate())."
		}
		return description
	}
	
	private func getFriendlyPeriodName(_ subscription: Product.SubscriptionInfo, isIntroduction: Bool) -> String {
		let unit: String
		if isIntroduction {
			let plural = 1 < subscription.introductoryOffer?.period.value ?? 0
			switch subscription.introductoryOffer?.period.unit {
			case .day:
				unit = plural ? "\(subscription.subscriptionPeriod.value) days" : "day"
			case .week:
				unit = plural ? "\(subscription.subscriptionPeriod.value) weeks" : "week"
			case .month:
				unit = plural ? "\(subscription.subscriptionPeriod.value) months" : "month"
			case .year:
				unit = plural ? "\(subscription.subscriptionPeriod.value) years" : "year"
			case .none:
				unit = ""
			@unknown default:
				unit = ""
			}
		} else {
			let plural = 1 < subscription.subscriptionPeriod.value
			switch subscription.subscriptionPeriod.unit {
			case .day:
				unit = plural ? "\(subscription.subscriptionPeriod.value) days" : "day"
			case .week:
				unit = plural ? "\(subscription.subscriptionPeriod.value) weeks" : "week"
			case .month:
				unit = plural ? "\(subscription.subscriptionPeriod.value) months" : "month"
			case .year:
				unit = plural ? "\(subscription.subscriptionPeriod.value) years" : "year"
			@unknown default:
				unit = "period"
			}
		}
		
		return unit
	}
	
	fileprivate func billingRetryDescription() -> String {
		var description = "The App Store could not confirm your billing information for \(product.displayName)."
		description += " Please verify your billing information to resume service."
		return description
	}
	
	fileprivate func gracePeriodDescription(_ renewalInfo: RenewalInfo) -> String {
		var description = "The App Store could not confirm your billing information for \(product.displayName)."
		if let untilDate = renewalInfo.gracePeriodExpirationDate {
			description += " Please verify your billing information to continue service after \(untilDate.storeFormattedDate())"
		}
		
		return description
	}
	
	fileprivate func subscribedDescription() -> String {
		return "You are currently subscribed to \(product.displayName)."
	}
	
	fileprivate func renewalDescription(_ renewalInfo: RenewalInfo, _ expirationDate: Date) -> String {
		var description = ""
		
		if let newProductID = renewalInfo.autoRenewPreference {
			if let newProduct = store.subscriptions.first(where: { $0.id == newProductID }) {
				//description += "\nYour subscription to \(newProduct.displayName)"
				//description += " will begin when your current subscription expires on \(expirationDate.storeFormattedDate())."
				description += "\(newProduct.displayName) renews \(expirationDate.storeFormattedDate())"
			}
		} else if renewalInfo.willAutoRenew {
			description += "\nNext billing date: \(expirationDate.storeFormattedDate())."
		}
		
		return description
	}
	
	//Build a string description of the `expirationReason` to display to the user.
	fileprivate func expirationDescription(_ expirationReason: RenewalInfo.ExpirationReason, expirationDate: Date) -> String {
		var description = ""
		
		switch expirationReason {
		case .autoRenewDisabled:
			if expirationDate > Date() {
				description += "Your subscription to \(product.displayName) will expire on \(expirationDate.storeFormattedDate())."
			} else {
				description += "Your subscription to \(product.displayName) expired on \(expirationDate.storeFormattedDate())."
			}
		case .billingError:
			description = "Your subscription to \(product.displayName) was not renewed due to a billing error."
		case .didNotConsentToPriceIncrease:
			description = "Your subscription to \(product.displayName) was not renewed due to a price increase that you disapproved."
		case .productUnavailable:
			description = "Your subscription to \(product.displayName) was not renewed because the product is no longer available."
		default:
			description = "Your subscription to \(product.displayName) was not renewed."
		}
		
		return description
	}
}

struct StatusInfoView_Previews: PreviewProvider {
	@StateObject static var store = Store()
	@State static var subscription: Product?
	@State static var subscriptionStatus: Product.SubscriptionInfo.Status?
	
	static var previews: some View {
		Group {
			if let subscription, let subscriptionStatus {
				StatusInfoView(product: subscription, status: subscriptionStatus)
					.environmentObject(store)
			}
		}
		.task {
			guard let product = store.purchasedSubscriptions.first else {
				return
			}
			subscription = product
			subscriptionStatus = try? await product.subscription?.status.last
		}
	}
}

extension Date {
	func storeFormattedDate() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
		return dateFormatter.string(from: self)
	}
}

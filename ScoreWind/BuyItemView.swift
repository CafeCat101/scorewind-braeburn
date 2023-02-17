//
//  BuyItemView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/2/16.
//

import SwiftUI
import StoreKit

struct BuyItemView: View {
	@EnvironmentObject var store: Store
	@State var isPurchased: Bool = false
	@State var errorTitle = ""
	@State var isShowingError: Bool = false
	
	let product: Product
	let purchasingEnabled: Bool
	
	init(product: Product, purchasingEnabled: Bool = true) {
		self.product = product
		self.purchasingEnabled = purchasingEnabled
	}
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(product.displayName)
					.bold()
				Text(product.description)
					.padding([.bottom],10)
				if product.subscription?.introductoryOffer?.period.value ?? 0 > 0 {
					Text(getIntroductionLabelText(product:product))
				}
			}
			Spacer()
			buyButton
		}
		.padding([.leading,.trailing],15)
		.padding([.bottom],10)
	}
	
	var buyButton: some View {
			Button(action: {
					Task {
							await buy()
					}
			}) {
					if isPurchased {
							Text(Image(systemName: "checkmark"))
									.bold()
									.foregroundColor(.white)
					} else {
						VStack {
							Text(product.displayPrice)
							Divider()
							Text(getFriendlyPeriodName(product.subscription!, isIntroduction: false))
						}
					}
			}
			.frame(width:UIScreen.main.bounds.size.width*0.3)
				.foregroundColor(Color("LessonListStatusIcon"))
				.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
				.background {
					RoundedRectangle(cornerRadius: 26)
						.foregroundColor(Color("AppYellow"))
				}
			.onAppear {
					Task {
							isPurchased = (try? await store.isPurchased(product)) ?? false
					}
			}
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
	
	private func getIntroductionLabelText(product: Product) -> String {
		let value = product.subscription?.introductoryOffer?.period.value ?? 0
		let unitFriendlyName = getFriendlyPeriodName(product.subscription!, isIntroduction: true)
		return "Includs free trial \(value) \(unitFriendlyName)"
	}
	
	func buy() async {
			do {
					if try await store.purchase(product) != nil {
							withAnimation {
									isPurchased = true
							}
					}
			} catch StoreError.failedVerification {
					errorTitle = "Your purchase could not be verified by the App Store."
					isShowingError = true
			} catch {
					print("Failed purchase for \(product.id): \(error)")
			}
	}
}


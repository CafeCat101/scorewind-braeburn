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
		VStack {
			HStack{
				Text(product.displayName)
					.font(.footnote)
					.bold()
				Spacer()
			}
			.padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))
			HStack {
				VStack {
					Text(product.displayPrice)
					Divider().frame(height:2)
					Text(getFriendlyPeriodName(product.subscription!, isIntroduction: false))
				}
				.padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 5))
				buyButton
					.padding([.trailing], 15)
			}
		}
		.background(Color("MyCourseItem"))
		.cornerRadius(15)
		.alert(isPresented: $isShowingError, content: {
				Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
		})
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
				Text("SUBSCRIBE\nIT")
			}
		}
		//.frame(width:UIScreen.main.bounds.size.width*0.3)
		.foregroundColor(Color("LessonListStatusIcon"))
		.padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
		.background {
			RoundedRectangle(cornerRadius: 20)
				.foregroundColor(isPurchased ? .green : Color("AppYellow"))
		}
		.disabled(isPurchased)
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
		return "+ \(value) \(unitFriendlyName) free trial"
	}
	
	func buy() async {
		do {
			if try await store.purchase(product) != nil {
				print("[debug] BuyItemView, buy, store.purchase(product) != ni")
				withAnimation {
					isPurchased = true
				}
			}
		} catch StoreError.failedVerification {
			print("[debug] BuyItemView, buy, StoreError.failedVerification")
			errorTitle = "Your purchase could not be verified by the App Store."
			isShowingError = true
		} catch {
			print("Failed purchase for \(product.id): \(error)")
			isShowingError = true
			errorTitle = error.localizedDescription
		}
	}
}


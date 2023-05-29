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
	@Environment(\.verticalSizeClass) var verticalSize
	@State private var showPurchaseWaiting = false
	@Environment(\.colorScheme) var colorScheme
	@Binding var offerIntroduction:Bool
	
	let product: Product
	let purchasingEnabled: Bool
	
	init(product: Product, purchasingEnabled: Bool = true, offerIntroduction: Binding<Bool>) {
		self.product = product
		self.purchasingEnabled = purchasingEnabled
		self._offerIntroduction = offerIntroduction
	}
	
	var body: some View {
		VStack{
			(Text(product.displayPrice)+Text(" / ")+Text(getFriendlyPeriodName(product.subscription!, isIntroduction: false)))
				.bold()
				//.padding(.bottom, 20)
			if offerIntroduction {
				HStack(spacing:0) {
					Spacer()
					Image(systemName: "gift.fill")
						.resizable()
						.scaledToFit()
						.frame(maxWidth: 25)
						.padding(.trailing,5)
					Text("Plus 1-month free trial!")
						.bold()
						.padding([.top,.bottom], 5)
						.multilineTextAlignment(.center)
					Spacer()
				}
			}
			
			buyButton
				.padding([.trailing,.leading], 15)
				.padding(.top, 20)
			/*HStack {
				Spacer().frame(width: verticalSize == .regular ? 0 : UIScreen.main.bounds.size.width*0.15)
				
				VStack {
					HStack{
						Text(product.displayName)
							.foregroundColor(Color("Dynamic/MainBrown+6"))
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
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 5))
						buyButton
							.padding([.trailing], 15)
					}.padding(.bottom, 5)
				}
				Spacer().frame(width: verticalSize == .regular ? 0 : UIScreen.main.bounds.size.width*0.15)
			}*/
		}
		/*.background(
			RoundedCornersShape(corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 17)
				.fill(Color("Dynamic/LightGray"))
				.opacity(0.85)
				.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
		)*/
		.alert(isPresented: $isShowingError, content: {
				Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
		})
	}
	
	var buyButton: some View {
		
		Button(action: {
			showPurchaseWaiting = true
			Task {
				await buy()
			}
		}) {
			if isPurchased {
				Text(Image(systemName: "checkmark"))
					.bold()
					.foregroundColor(Color("Dynamic/ShadowReverse"))
			} else {
				if showPurchaseWaiting == false {
					if colorScheme == .light {
						Text("Subscribe Now")
							.fontWeight(Font.Weight.bold)
							.foregroundColor(Color("Dynamic/ShadowReverse"))
					} else {
						Text("Subscribe Now")
							.foregroundColor(Color("Dynamic/StoreViewTitle"))
							.fontWeight(Font.Weight.medium)
					}
					
				} else {
					DownloadSpinnerView(iconColor: Color("Dynamic/MainBrown+6"), spinnerColor: Color("AppYellow"), iconSystemImage: "music.note")
				}
			}
		}
		.frame(maxWidth: verticalSize == .regular ? UIScreen.main.bounds.size.width*0.7 : UIScreen.main.bounds.size.width*0.5)
		.padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
		.background(
			RoundedRectangle(cornerRadius: CGFloat(17))
				.foregroundColor(colorScheme == .light ? Color("Dynamic/StoreViewTitle") : Color("Dynamic/MainBrown"))
				.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
				.opacity(colorScheme == .light ? 1 : 0.25)
				//.opacity(isPurchased ? 0.85 : 0.25)
				.overlay {
					RoundedRectangle(cornerRadius: 17)
						.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
				}
		)
		.disabled(isPurchased)
		.onAppear {
			Task {
				isPurchased = (try? await store.isPurchased(product)) ?? false
			}
		}
		.onDisappear(perform: {
			showPurchaseWaiting = false
		})
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
					showPurchaseWaiting = false
				}
			}
		} catch StoreError.failedVerification {
			print("[debug] BuyItemView, buy, StoreError.failedVerification")
			errorTitle = "Your purchase could not be verified by the App Store."
			isShowingError = true
			showPurchaseWaiting = false
		} catch {
			print("Failed purchase for \(product.id): \(error)")
			isShowingError = true
			errorTitle = error.localizedDescription
			showPurchaseWaiting = false
		}
	}
}


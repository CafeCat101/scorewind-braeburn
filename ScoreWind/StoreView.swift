//
//  StoreView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/2/14.
//

import SwiftUI
import StoreKit

struct StoreView: View {
	@EnvironmentObject var store:Store
	@Binding var showStore:Bool
	@State var isPurchased: Bool = false
	@State var selectedInfoTab = "TAbout"
	@State var currentSubscription: Product?
	@State var status: Product.SubscriptionInfo.Status?
	@Environment(\.verticalSizeClass) var verticalSize
	@Environment(\.colorScheme) var colorScheme
	@State private var showResotreWaiting = 0
	//@State private var offerIntroduction = false
	//@State private var enableBuyButton = true
	@State private var studentCouponCode:String = ""
	@State private var showCouponWaiting = 0 //test
	
	var availableSubscriptions: [Product] {
		store.subscriptions.filter { $0.id != currentSubscription?.id }
	}
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				if verticalSize != .regular {
					displayLogo()
				}
				Label("Close", systemImage: "xmark.circle")
					.labelStyle(.iconOnly)
					.font(verticalSize == .regular ? .title2 : .title3)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					//.padding(15)
					.onTapGesture {
						showStore = false
					}
			}
			.padding(EdgeInsets(top: 10, leading: 15, bottom: 15, trailing: 15))
			
			/*HStack {
				Spacer()
				Text("Stay Curious with ScoreWind WizPack")
					.font(verticalSize == .regular ? .title : .title3)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.bold()
					.multilineTextAlignment(.center)
				Spacer()
			}.padding(EdgeInsets(top: 10, leading: 15, bottom: 15, trailing: 15))*/
			
				
			//Text("This is the place where you subscribe scorewind")
			ScrollView(.vertical) {
				VStack(spacing:0) {
					 if verticalSize == .regular {
						 HStack {
							 Spacer()
							 displayLogo()
							 Spacer()
						 }
					 }
					 
					 HStack(spacing:0) {
						 Spacer()
						 Text("Stay Curious with")
							 .font(verticalSize == .regular ? .title : .title3)
							 .foregroundColor(Color("Dynamic/MainBrown+6"))
							 .fontWeight(Font.Weight.bold)
							 .multilineTextAlignment(.center)
						 Spacer()
					 }
					 /*Text("with").font(verticalSize == .regular ? .title : .title3)
						 .foregroundColor(Color("Dynamic/MainBrown+6"))
						 .fontWeight(Font.Weight.bold)*/
					 HStack(spacing:0) {
						 Spacer()
						 Text("ScoreWind ")
							 .font(verticalSize == .regular ? .title : .title3)
							 .foregroundColor(Color("Dynamic/MainBrown+6"))
							 .fontWeight(Font.Weight.bold)
							 .multilineTextAlignment(.center)
						 Text("WizPack")
							 .fontWeight(Font.Weight.bold)
							 .foregroundColor(colorScheme == .light ? Color("Dynamic/ShadowReverse") : Color("Dynamic/Shadow"))
							 .font(verticalSize == .regular ? .title3 : .subheadline)
							 .padding(EdgeInsets(top: 6, leading: 17, bottom: 6, trailing: 17))
							 .background(colorScheme == .light ? Color("Dynamic/DarkGray") : Color("AppYellow"))
							 .cornerRadius(20)
							 .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 2))
						 Spacer()
					 }
				 }.padding(EdgeInsets(top: 10, leading: 15, bottom: 15, trailing: 15))
				 VStack(alignment: .leading, spacing:0) {
					 VStack(alignment: .leading, spacing:0) {
						 Label(title: {
							 Text("Unlimited access to all lessons in the learning path.")
						 }, icon: {
							 Image(systemName: "checkmark.seal.fill")
								 .resizable()
								 .frame(width:22, height:22)
						 }).padding(.bottom, 5)
						 
						 Label(title: {
							 Text("Unlimited access to all courses in the ScoreWind.")
						 }, icon: {
							 Image(systemName: "checkmark.seal.fill")
								 .resizable()
								 .frame(width:22, height:22)
						 }).padding(.bottom, 5)
						 
						 Label(title: {
							 Text("Unlock all the features in the Courses & Lessons")
						 }, icon: {
							 Image(systemName: "checkmark.seal.fill")
								 .resizable()
								 .frame(width:22, height:22)
						 }).padding(.bottom, 5)
						 /*HStack(spacing:0) {
							 Spacer()
							 Text("Plus 1-month free trial!")
								 .bold()
								 .padding(.bottom, 5)
								 .multilineTextAlignment(.center)
							 Spacer()
						 }*/
					 }.padding(20)
				 }
				 .foregroundColor(Color("Dynamic/MainBrown+6"))
				 .background(
					 RoundedRectangle(cornerRadius: CGFloat(17))
						 .foregroundColor(Color("Dynamic/StoreViewTextBackground"))
						 .opacity(0.25)
						 .shadow(color: Color("Dynamic/ShadowReverse"),radius: CGFloat(5))
				 )
				 .padding([.leading,.trailing], 15)
				 .padding(.bottom, 15)
				 
				 HStack {
					 Spacer()
					 Text("Ignite your mind. Discover, learn, and embrace curiosity.")
						 .bold()
						 .font(.title3)
						 .multilineTextAlignment(.center)
						 .foregroundColor(Color("Dynamic/StoreViewTitle"))
					 Spacer()
				 }.padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
				 
				 VStack {
					 (Text(displayProductPrice())+Text(" / ")+Text(displaySubscriptionPeriod()))
						 .bold()
						 //.padding(.bottom, 20)

					 if store.offerIntroduction || isInTrial() {
						 HStack(spacing:0) {
							 Spacer()
							 if isInTrial() == false && store.offerIntroduction {
								 Image(systemName: "gift.fill")
									 .resizable()
									 .scaledToFit()
									 .frame(maxWidth: 25)
									 .padding(.trailing,5)
							 }
							 
							 if isInTrial() {
								 Text("1-month free trial!")
									 .bold()
									 .padding([.top,.bottom], 5)
									 .multilineTextAlignment(.center)
							 } else {
								 Text("Plus 1-month free trial!")
									 .bold()
									 .padding([.top,.bottom], 5)
									 .multilineTextAlignment(.center)
							 }
							 
							 Spacer()
						 }
					 }
					 
					 BuyButtonView(product: getProductForBuyButton())
						 .padding([.leading, .trailing],15)
						 .padding([.top, .bottom], 10)
						 .frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.width*0.9)
					 
					 
					 if let currentSubscription = currentSubscription {
						 if let status = status {
							 StatusInfoView(product: currentSubscription, status: status)
						 }
					 } else {
						 if store.offerIntroduction {
							 Text("Once you purchase, your 1-month free trial starts immediately. When your 1-month free trial ends, you will automatically be charged the monthly fee of \(displayAvailableSubscriptionPrice()). Your subscription will automatically renew 24 hours before each subscription period ends.")
								 .foregroundColor(Color("Dynamic/MainBrown+6"))
								 .bold()
								 .padding([.leading,.trailing,.top], 30)
								 .font(.subheadline)
						 } else {
							 Text("Once you purchase you will automatically be charged the monthly fee of \(displayAvailableSubscriptionPrice()). Your subscription will automatically renew 24 hours before each subscription period ends.")
								 .foregroundColor(Color("Dynamic/MainBrown+6"))
								 .bold()
								 .padding([.leading,.trailing,.top], 30)
								 .font(.subheadline)
						 }
						 
					 }
				 }
				 
				 Divider()
					 .padding([.leading,.trailing], 15)
					 .padding([.top,.bottom], 30)
				 
				 TabView {
					 //infoTabAbout.padding(15)
					 infoTabPurchased
					 infoTaCancel
				 }
				 .tabViewStyle(.page)
				 .padding([.leading,.trailing,.bottom], 15)
				 .frame(height: verticalSize == .regular ? UIScreen.main.bounds.size.height*0.4 : UIScreen.main.bounds.size.height*0.8)
				 /*.background(
					 RoundedRectangle(cornerRadius: CGFloat(17))
						 .foregroundColor(Color("Dynamic/MainBrown"))
						 .opacity(0.25)
				 )
				 .padding(15)
				 .frame(height: verticalSize == .regular ? UIScreen.main.bounds.size.height*0.5 : UIScreen.main.bounds.size.height*0.8)*/
				 
				 Button(action: {
					 showResotreWaiting = 1
					 Task {
						 //This call displays a system prompt that asks users to authenticate with their App Store credentials.
						 //Call this function only in response to an explicit user action, such as tapping a button.
						 try? await AppStore.sync()
						 
						 Task {
							 await updateSubscriptionStatus()
							 //showResotreWaiting = 2
							 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
								 showResotreWaiting = 0
							 }
						 }
					 }
				 }) {
					 HStack {
						 Spacer()
						 Text("Restore Subscription")
						 if showResotreWaiting > 0 {
							 if showResotreWaiting == 1 {
								 DownloadSpinnerView(iconColor: Color("Dynamic/MainBrown+6"), spinnerColor: Color("Dynamic/IconHighlighted"), iconSystemImage: "music.note")
							 } else {
								 Label("Restored", systemImage: "checkmark")
									 .labelStyle(.iconOnly)
									 .foregroundColor(Color("Dynamic/MainBrown+6"))
							 }
						 }
						 Spacer()
					 }
				 }
				 .foregroundColor(Color("Dynamic/MainBrown+6"))
				 .frame(maxWidth: verticalSize == .regular ? UIScreen.main.bounds.size.width*0.7 : UIScreen.main.bounds.size.width*0.5)
				 .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
				 .background(
					 RoundedRectangle(cornerRadius: CGFloat(17))
						 .foregroundColor(Color("Dynamic/MainBrown"))
						 .shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						 .opacity(0.25)
						 .overlay {
							 RoundedRectangle(cornerRadius: 17)
								 .stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
						 }
				 )

				
				Divider()
					.padding([.leading,.trailing], 15)
					.padding([.top,.bottom], 30)
				
				VStack {
					Text("I Have ScoreWind Student Coupon")
						.font(.title2)
						.foregroundColor(Color("Dynamic/StoreViewTitle"))
						.padding([.bottom],10)
					VStack(alignment: .leading){
						HStack {
							TextField(
								"Write your coupon code here",
								text: $studentCouponCode
							)
							.textFieldStyle(DefaultTextFieldStyle())
							.onSubmit {
								print(studentCouponCode)
							}
							
							Label("Send", systemImage: "paperplane.circle")
								.frame(maxWidth: 35, maxHeight:20)
								.labelStyle(.iconOnly)
								.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
								.foregroundColor(Color("Dynamic/MainBrown+6"))
								.background(
									RoundedRectangle(cornerRadius: CGFloat(17))
										.foregroundColor(Color("Dynamic/MainBrown"))
										.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
										.opacity(0.25)
										.overlay {
											RoundedRectangle(cornerRadius: 17)
												.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
										}
								)
								.onTapGesture {
									print(studentCouponCode)
								}
						}
						.padding(15)
					}
					.background(
						RoundedRectangle(cornerRadius: CGFloat(17))
							.foregroundColor(Color("Dynamic/StoreViewTextBackground"))
							.opacity(0.25)
							.shadow(color: Color("Dynamic/ShadowReverse"),radius: CGFloat(5))
					)
					.padding([.leading,.trailing],30)
					Spacer()
				}
				.foregroundColor(Color("Dynamic/MainBrown+6"))
				.padding(.bottom, 50)
			 }
		}
		.background(colorScheme == .light ? appBackgroundImage(colorMode: colorScheme) : appBackgroundImage(colorMode: colorScheme))
		.onAppear {
			showResotreWaiting = 0
			Task {
				//When this view appears, get the latest subscription status.
				await updateSubscriptionStatus()
			}
		}
		.onChange(of: store.purchasedSubscriptions) { _ in
			Task {
				//When `purchasedSubscriptions` changes, get the latest subscription status.
				await updateSubscriptionStatus()
			}
		}
	}
	
	struct buyItemPadding: ViewModifier {
		var isLastItem = false
		var isOnlyOne = false
		@Environment(\.verticalSizeClass) var verticalSize
		
		func body(content: Content) -> some View {
			if isOnlyOne {
				content
					.padding([.leading, .trailing],15)
					.padding([.top, .bottom], 10)
					.frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.width*0.9)
			} else {
				if isLastItem {
					content
						.padding([.leading, .trailing],15)
						.padding([.top, .bottom], 10)
						.frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width*0.9 : UIScreen.main.bounds.size.width*0.8)
				} else {
					content
						.padding([.leading],15)
						.padding([.top, .bottom], 10)
						.frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width*0.9 : UIScreen.main.bounds.size.width*0.8)
				}
			}
		}
	}
	
	@MainActor
	func updateSubscriptionStatus() async {
		do {
			//This app has only one subscription group, so products in the subscriptions
			//array all belong to the same group. The statuses that
			//`product.subscription.status` returns apply to the entire subscription group.
			guard let product = store.subscriptions.first,
						let statuses = try await product.subscription?.status else {
				return
			}
			print("[debug] StoreView, updateSubscriptionStatus() product \(String(describing: await product.subscription?.isEligibleForIntroOffer))")
			var highestStatus: Product.SubscriptionInfo.Status? = nil
			var highestProduct: Product? = nil
			
			//Iterate through `statuses` for this subscription group and find
			//the `Status` with the highest level of service that isn't
			//in an expired or revoked state. For example, a customer may be subscribed to the
			//same product with different levels of service through Family Sharing.
			for status in statuses {
				switch status.state {
				case .expired, .revoked:
					print("[debug] StoreView, updateSubscriptionStatus(), status.expired, status.revoked")
					continue
				default:
					let renewalInfo = try store.checkVerified(status.renewalInfo)
					print("[debug] StoreView, updateSubscriptionStatus(), renewalInfo(\(String(describing: renewalInfo.currentProductID)) \(String(describing: renewalInfo.willAutoRenew)))")
					//Find the first subscription product that matches the subscription status renewal info by comparing the product IDs.
					guard let newSubscription = store.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
						continue
					}
					
					guard let currentProduct = highestProduct else {
						highestStatus = status
						highestProduct = newSubscription
						continue
					}
					
					let highestTier = store.tier(for: currentProduct.id)
					let newTier = store.tier(for: renewalInfo.currentProductID)
					
					if newTier > highestTier {
						highestStatus = status
						highestProduct = newSubscription
					}
				}
			}
			
			status = highestStatus
			currentSubscription = highestProduct
			print("[debug] StoreView, updateSubscriptionStatus() status \(String(describing: status?.state))")
			print("[debug] StoreView, updateSubscriptionStatus() currentSubscription \(String(describing: currentSubscription?.id))")
			if status?.state == .subscribed {
				store.enablePurchase = false
			} else {
				store.enablePurchase = true
			}
			
			//store.offerIntroduction = await store.eligibleForIntro(product: product)
			
			if highestProduct != nil {
				store.offerIntroduction = await store.eligibleForIntro(product: highestProduct!)
			} else {
				store.offerIntroduction = await store.eligibleForIntro(product: product)
			}
			
			print("[debug] StoreView, updateSubscriptionStatus() eligibleForIntro \(store.offerIntroduction)")
			//print("[debug] StoreView, updateSubscriptionStatus() offerIntroduction \(String(describing: await currentSubscription?.subscription?.isEligibleForIntroOffer))")
			print("[debug] StoreView, updateSubscriptionStatus() store.purchasedSubscription.count \(store.purchasedSubscriptions.count)")
			print("[debug] StoreView, updateSubscriptionStatus() availableSubscription.count \(availableSubscriptions.count)")
		} catch {
			print("Could not update subscription status \(error)")
		}
	}
	
	private func displayProductPrice() -> String {
		if let currentSubscription = currentSubscription {
			return currentSubscription.displayPrice
		} else {
			return availableSubscriptions.first?.displayPrice ?? "--"
		}
	}
	
	private func displaySubscriptionPeriod() -> String {
		if let currentSubscription = currentSubscription {
			return getFriendlyPeriodName(subscription: (currentSubscription.subscription)!)
		} else {
			return getFriendlyPeriodName(subscription: (availableSubscriptions.first?.subscription)!)
		}
	}
	
	private func getFriendlyPeriodName(subscription: Product.SubscriptionInfo) -> String {
		let unit: String
		
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
		
		return unit
	}
	
	/*private func eligibleForIntro(product: Product) async -> Bool {
			guard let renewableSubscription = product.subscription else {
					// No renewable subscription is available for this product.
					return false
			}
			if await renewableSubscription.isEligibleForIntroOffer {
					// The product is eligible for an introductory offer.
					return true
			}
			return false
	}*/
	
	private func isInTrial() -> Bool {
		if let status = status {
			guard case .verified(let transaction) = status.transaction else {
				return false
			}
			
			if transaction.offerType != nil {
				print("[debug] StoreView, isInTrial true")
				return true
			}else {
				return false
			}
		} else {
			return false
		}
	}
	
	private func getProductForBuyButton() -> Product {
		if let currentSubscription = currentSubscription {
			return currentSubscription
		} else {
			return availableSubscriptions.first!
		}
	}
	
	private func displayAvailableSubscriptionPrice() -> String {
		return availableSubscriptions.first?.displayPrice ?? "--"
	}
	
	/*private func enableBuyButton() -> Bool {
		if let statusxx = status {
			return false
			/*if status.state == .subscribed {
				return false
			} else {
				return true
			}*/
		} else {
			return true
		}
	}*/
	
	/*private func getIntroductionLabelText(product: Product) -> String {
		let value = product.subscription?.introductoryOffer?.period.value ?? 0
		let unitFriendlyName = getFriendlyPeriodName(product.subscription!, isIntroduction: true)
		return "+ \(value) \(unitFriendlyName) free trial"
	}*/
	
	var infoTabPurchased: some View {
		VStack {
			Text("See Your Subscription")
				.font(.title2)
				.foregroundColor(Color("Dynamic/StoreViewTitle"))
				.padding([.bottom],10)
			VStack(alignment: .leading){
				Text("· Go to ScoreWind \(Image(systemName: "music.note.house")) Home.").padding(.bottom,3)
				Text("· Tap \(Image(systemName: "gear")) menu in the right top corner.").padding(.bottom,3)
				Text("· Tap ScoreWind WizPack").padding(.bottom,3)
			}
			Spacer()
		}
		.foregroundColor(Color("Dynamic/MainBrown+6"))
	}
	
	var infoTaCancel: some View {
		VStack {
			Text("Cancel Subscription")
				.font(.title2)
				.foregroundColor(Color("Dynamic/StoreViewTitle"))
				.padding([.bottom], 10)
			VStack(alignment:.leading) {
				Text("· Open the Settings app on your phone.").padding(.bottom, 3)
				Text("· Tap your name.").padding(.bottom, 3)
				Text("· Tap Subscriptions.").padding(.bottom, 3)
				Text("· Find the ScoreWind app and tap Cancel.").padding(.bottom, 3)
			}
			.padding([.bottom],10)
			
			Link(destination: URL(string: "https://support.apple.com/en-us/HT202039")!, label: {
				Text("For more information about it, go to Apple Support, ")+Text("click here.").bold()
			})
			/*Link("For more information about it on Apple Support, click here.", destination: URL(string: "https://support.apple.com/en-us/HT202039")!)*/
			//Text("Here is the place to help user learn how to manage the subscription. I'll fill up this information soon.")
			Spacer()
		}.foregroundColor(Color("Dynamic/MainBrown+6"))
	}
	
	@ViewBuilder
	private func displayLogo() -> some View {
		if colorScheme == .light {
			Image("logo")
				.resizable()
				.scaledToFit()
				.frame(maxWidth: verticalSize == .regular ? 46 : 23)
		} else {
			Image("logo")
				.resizable()
				.scaledToFit()
				.frame(maxWidth: verticalSize == .regular ? 46 : 23)
				.padding(verticalSize == .regular ? 15 : 5)
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("AppYellow"))
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						.overlay {
							RoundedRectangle(cornerRadius: 17)
								.stroke(Color("Dynamic/ShadowReverse"), lineWidth: 1)
						}
				)
		}
	}
	

}
/*
 struct StoreView_Previews: PreviewProvider {
 static var previews: some View {
 StoreView(showStore:.constant(false)).environmentObject(Store())
 StoreView(showStore:.constant(false)).environmentObject(Store())
 .environment(\.colorScheme, .dark)
 .previewDisplayName("dark")
 StoreView(showStore:.constant(false)).environmentObject(Store())
 .previewInterfaceOrientation(InterfaceOrientation.landscapeLeft)
 .previewDisplayName("Light LandscapeLeft")
 }
 }
 */

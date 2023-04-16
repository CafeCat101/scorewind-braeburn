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
	
	var availableSubscriptions: [Product] {
		store.subscriptions.filter { $0.id != currentSubscription?.id }
	}
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Text("ScoreWind Subscription")
					.font(verticalSize == .regular ? .title2 : .title3)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.bold()
				Spacer()
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
			
				
			//Text("This is the place where you subscribe scorewind")
			ScrollView(.vertical) {
				VStack(alignment: .leading, spacing:0) {
					VStack(alignment: .leading, spacing:0) {
						Label(title: {
							Text("Unlock all lessons in the learning path and the courses.")
						}, icon: {
							Image(systemName: "circle.fill")
								.resizable()
								.frame(width:6, height:6)
						}).padding(.bottom, 5)
						
						Label(title: {
							Text("Access to all the features in the courses and the lessons.")
						}, icon: {
							Image(systemName: "circle.fill")
								.resizable()
								.frame(width:6, height:6)
						}).padding(.bottom, 5)
						
						Label(title: {
							Text("1-month free trial.")
						}, icon: {
							Image(systemName: "circle.fill")
								.resizable()
								.frame(width:6, height:6)
						}).padding(.bottom, 5)
						/*Label("Unlock all lessons in the learning path and the courses.", systemImage: "circle.fill")
						Label("Access to all the features in the courses and the lessons", systemImage: "circle.fill")
						Label("1 month free trial.", systemImage: "circle.fill")*/
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
				
				
				if let currentSubscription = currentSubscription {
					Divider()
					HStack {
						Text("My Current Subscription")
							.font(.title2)
							.foregroundColor(Color("Dynamic/StoreViewTitle"))
						Spacer()
					}.padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
					
					VStack {
						VStack {
							HStack{
								Text(currentSubscription.displayName)
									.foregroundColor(Color("Dynamic/MainBrown+6"))
									.font(.footnote)
									.bold()
								Spacer()
							}.padding([.bottom], 5)
							if let status = status {
								StatusInfoView(product: currentSubscription, status: status)
							}
						}
						.padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
					}
					.background(
						RoundedRectangle(cornerRadius: CGFloat(17))
							.foregroundColor(Color("Dynamic/StoreViewTextBackground"))
							.opacity(0.20)
							.shadow(color: Color("Dynamic/ShadowReverse"),radius: CGFloat(5))
							.overlay(content: {
								Image("play_any")
									.resizable()
									.scaledToFill()
									.padding(30)
									.opacity(0.25)
							})
					)
					.modifier(buyItemPadding(isLastItem: true, isOnlyOne: true))
				}
				
				if availableSubscriptions.count > 0 {
					Divider()
					HStack {
						Text("Available Subscription")
							.font(.title2)
							.foregroundColor(Color("Dynamic/StoreViewTitle"))
						Spacer()
					}.padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
					
					ScrollView(.horizontal, showsIndicators: false) {
						HStack {
							ForEach(availableSubscriptions) { product in
								BuyItemView(product: product)
									//.padding(15)
									.modifier(buyItemPadding(isLastItem: product.id == availableSubscriptions.last?.id ? true : false ,isOnlyOne: availableSubscriptions.count == 1 ? true : false))
							}
						}
					}//.frame(width: UIScreen.main.bounds.size.width)
				}
				
				TabView {
					//infoTabAbout.padding(15)
					infoTabPurchased.padding(15)
					infoTaCancel.padding(15)
				}
				.tabViewStyle(.page)
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/MainBrown"))
						.opacity(0.25)
				)
				.padding(15)
				.frame(height: verticalSize == .regular ? UIScreen.main.bounds.size.height*0.5 : UIScreen.main.bounds.size.height*0.8)
				
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
				.frame(width:UIScreen.main.bounds.size.width*0.8)
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
					let renewalInfo = try store.checkVerified(status.renewalInfo)
					
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
		} catch {
			print("Could not update subscription status \(error)")
		}
	}
	
	var infoTabAbout: some View {
		VStack {
			Text("Subscription Content")
				.font(.title2)
				.padding([.bottom],10)
			Text("Access to all the lessons in the learning path.\nDownload course video for offline viewing.\nMark lessons as completed.\n")
		}.foregroundColor(Color("Dynamic/MainBrown+6"))
	}
	
	var infoTabPurchased: some View {
		VStack {
			Text("See Your Subscription")
				.font(.title2)
				.foregroundColor(Color("Dynamic/StoreViewTitle"))
				.padding([.bottom],10)
			Text("When you want to view your subscription status, go to \(Image(systemName: "music.note.house")) Home tab, and open the \(Image(systemName: "gear")) menu in the top right corner.")
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
				Label("Open the Settings app on your phone.", systemImage: "number.circle.fill")
				Label("Tap your name.", systemImage: "number.circle.fill")
				Label("Tap Subscriptions.", systemImage: "number.circle.fill")
				Label("Find the ScoreWind app and tap Cancel.", systemImage: "number.circle.fill")
			}
			.padding([.bottom],10)
			
			Link(destination: URL(string: "https://support.apple.com/en-us/HT202039")!, label: {
				Text("For more information about it on Apple Support, ")+Text("click here.").bold()
			})
			/*Link("For more information about it on Apple Support, click here.", destination: URL(string: "https://support.apple.com/en-us/HT202039")!)*/
			//Text("Here is the place to help user learn how to manage the subscription. I'll fill up this information soon.")
		}.foregroundColor(Color("Dynamic/MainBrown+6"))
	}
}

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

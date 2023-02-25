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
	
	var availableSubscriptions: [Product] {
		store.subscriptions.filter { $0.id != currentSubscription?.id }
	}
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Label("Close", systemImage: "xmark.circle")
					.labelStyle(.iconOnly)
					.font(.title2)
					.padding(15)
					.onTapGesture {
						showStore = false
					}
			}
			Text("ScoreWind Subscription")
				.font(.title)
				.padding([.top,.bottom], 5)
			//Text("This is the place where you subscribe scorewind")
			ScrollView(.vertical) {
				VStack(alignment: .leading) {
					Label("Unlock all lessons in the learning path and the courses.", systemImage: "circle.fill")
					Label("Access to all the features in the courses and the lessons", systemImage: "circle.fill")
					Label("1 month free trial.", systemImage: "circle.fill")
					//Text("+ Unlock all lessons in the learning path and the courses.")
						//.multilineTextAlignment(.leading)
					//Text("+ Access to all the features in the courses and the lessons.")
					//Text("+ 1 month free trial.")
				}
				.padding([.leading,.trailing], 15)
				
				if let currentSubscription = currentSubscription {
					HStack {
						Text("My current subscription")
							.font(.title2)
						Spacer()
					}.padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
					
					VStack {
						VStack {
							HStack{
								Text(currentSubscription.displayName)
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
					.background(Color("MyCourseItem"))
					.cornerRadius(15)
					.modifier(buyItemPadding(isLastItem: true, isOnlyOne: true))
				}
				
				if availableSubscriptions.count > 0 {
					Divider()
					HStack {
						Text("Available subscription")
							.font(.title2)
						Spacer()
					}.padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
					ScrollView(.horizontal, showsIndicators: false) {
						HStack {
							ForEach(availableSubscriptions) { product in
								BuyItemView(product: product)
									.modifier(buyItemPadding(isLastItem: product.id == availableSubscriptions.last?.id ? true : false ,isOnlyOne: availableSubscriptions.count == 1 ? true : false))
							}
						}
					}
				}
				
				TabView {
					infoTabAbout.padding(15)
					infoTabPurchased.padding(15)
					infoTaCancel.padding(15)
				}
				.tabViewStyle(.page)
				.background(Color("AppYellow"))
				.cornerRadius(25)
				.padding(15)
				.frame(height: UIScreen.main.bounds.size.height*0.5)
				
				Button(action: {
					Task {
							//This call displays a system prompt that asks users to authenticate with their App Store credentials.
							//Call this function only in response to an explicit user action, such as tapping a button.
							try? await AppStore.sync()
					}
				}) {
					Text("Restore subscription")
				}
				.frame(width:UIScreen.main.bounds.size.width*0.8)
				.foregroundColor(Color("ListDivider"))
				.padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
				.background {
					RoundedRectangle(cornerRadius: 20)
						.foregroundColor(.gray)
				}
			}
		}
		.onAppear {
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
		func body(content: Content) -> some View {
			if isOnlyOne {
				content
					.padding([.leading, .trailing],15)
					.padding([.top, .bottom], 10)
					.frame(width: UIScreen.main.bounds.size.width)
			} else {
				if isLastItem {
					content
						.padding([.leading, .trailing],15)
						.padding([.top, .bottom], 10)
						.frame(width: UIScreen.main.bounds.size.width*0.9)
				} else {
					content
						.padding([.leading],15)
						.padding([.top, .bottom], 10)
						.frame(width: UIScreen.main.bounds.size.width*0.9)
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
			Text("After you subscribe...")
				.font(.title2)
				.padding([.bottom],10)
			Text("When you configure ScoreWind to build a learning path, you'll unlock all the lessons inside it, not just the starting lesson in the learning path.\n\nBesides using synchornized interactive score viewer, with subscription, you'll also have access to feature of offline course and tracking completed lessons.")
		}
	}
	
	var infoTabPurchased: some View {
		VStack {
			Text("See your subscription")
				.font(.title2)
				.padding([.bottom],10)
			Text("When you want to view your subscription status, go to \(Image(systemName: "music.note.house")) Home tab, and open the \(Image(systemName: "gear")) menu on the top right corner.")
		}
	}
	
	var infoTaCancel: some View {
		VStack {
			Text("Cancel subscription")
				.font(.title2)
				.padding([.bottom], 10)
			VStack(alignment:.leading) {
				Label("Open the Settings app on your phone.", systemImage: "number.circle.fill")
				Label("Tap your name", systemImage: "number.circle.fill")
				Label("Tap Subscriptions", systemImage: "number.circle.fill")
				Label("Find the ScoreWind app and tap Cancel", systemImage: "number.circle.fill")
			}
			.padding([.bottom],10)
			
			Link("For more information about it on Apple Support, click here.", destination: URL(string: "https://support.apple.com/en-us/HT202039")!)
			//Text("Here is the place to help user learn how to manage the subscription. I'll fill up this information soon.")
		}
	}
}

struct StoreView_Previews: PreviewProvider {
	static var previews: some View {
		StoreView(showStore:.constant(false)).environmentObject(Store())
	}
}

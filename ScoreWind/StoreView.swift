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
					Text("Study Plan")
						.font(.title)
						.padding([.bottom],20)
					//Text("This is the place where you subscribe scorewind")
					TabView {
						infoTabAbout.padding(15)
						infoTabPurchased.padding(15)
						infoTaCancel.padding(15)
					}
					.tabViewStyle(.page)
					.background(Color("AppYellow"))
					.cornerRadius(25)
					.padding(15)
					.frame(minHeight: 300)
					
					
					if let currentSubscription = currentSubscription {
						Text("My current subscription").font(.title2)
							.padding([.top],10)
						HStack {
							VStack(alignment:.leading) {
								Text(currentSubscription.displayName)
									.bold()
								Text(currentSubscription.description)
									.frame(alignment: .leading)
							}
							Spacer()
						}
						.padding([.bottom], 10)
						.padding([.leading,.trailing],15)
					}
					
					if availableSubscriptions.count > 0 {
						ScrollView(.vertical) {
							Text("Available subscription")
								.font(.title2)
								.padding([.top],10)
							ForEach(availableSubscriptions) { product in
								BuyItemView(product: product)
							}
						}
						
					}
					Spacer()
				
				
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
			Text("Subscription Content").font(.title2)
			Text("When you configure ScoreWind and let it build you a learning path, you'll have full access to the courses and lessons in it.\n\nScoreWind lessons are prepared by teachers with care, together with lesson videos and synchornized interactive scores to help you learn and practice.")
		}
	}
	
	var infoTabPurchased: some View {
		VStack {
			Text("See Your Subscription").font(.title2)
			Text("When you want to view your subscription status, go to \(Image(systemName: "music.note.house")) Home tab, and open the \(Image(systemName: "gear")) menu on the top right corner.")
		}
	}
	
	var infoTaCancel: some View {
		VStack {
			Text("Cancel Subscription").font(.title2)
			Text("Here is the place to help user learn how to manage the subscription.")
		}
	}
}

struct StoreView_Previews: PreviewProvider {
	static var previews: some View {
		StoreView(showStore:.constant(false)).environmentObject(Store())
	}
}

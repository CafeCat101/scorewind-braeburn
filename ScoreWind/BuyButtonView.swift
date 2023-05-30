//
//  BuyButtonView2.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/5/29.
//

import SwiftUI
import StoreKit

struct BuyButtonView: View {
	@EnvironmentObject var store: Store
	//@State var isPurchased: Bool = false
	@State var errorTitle = ""
	@State var isShowingError: Bool = false
	@Environment(\.verticalSizeClass) var verticalSize
	@State private var showPurchaseWaiting = false
	@Environment(\.colorScheme) var colorScheme
	
	let product: Product
	@Binding var purchasingEnabled: Bool
	
	var body: some View {
		VStack{
			Button(action: {
				showPurchaseWaiting = true
				Task {
					await buy()
				}
			}) {
				HStack {
					Text(purchasingEnabled ? "Subscribe Now" : "Subscribed")
						.fontWeight(colorScheme == .light ? Font.Weight.bold : Font.Weight.medium)
						.foregroundColor(colorScheme == .light ? Color("Dynamic/ShadowReverse") : Color("Dynamic/StoreViewTitle"))
					if showPurchaseWaiting {
						DownloadSpinnerView(iconColor: Color("Dynamic/MainBrown+6"), spinnerColor: Color("AppYellow"), iconSystemImage: "music.note")
					}
					if purchasingEnabled == false {
						Text(Image(systemName: "checkmark"))
							.bold()
							.foregroundColor(colorScheme == .light ? Color("Dynamic/ShadowReverse") : Color("Dynamic/StoreViewTitle"))
					}
				}
				
				
				/*if purchasingEnabled == false {
					Text(Image(systemName: "checkmark"))
						.bold()
						.foregroundColor(colorScheme == .light ? Color("Dynamic/ShadowReverse") : Color("Dynamic/StoreViewTitle"))
				} else {
					if showPurchaseWaiting == false {
						Text("Subscribe Now")
							.fontWeight(colorScheme == .light ? Font.Weight.bold : Font.Weight.medium)
							.foregroundColor(colorScheme == .light ? Color("Dynamic/ShadowReverse") : Color("Dynamic/StoreViewTitle"))
					} else {
						DownloadSpinnerView(iconColor: Color("Dynamic/MainBrown+6"), spinnerColor: Color("AppYellow"), iconSystemImage: "music.note")
					}
				}*/
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
			.disabled(purchasingEnabled ? false : true)
			.onAppear {
				print("[debug] BuyButtonView, purchasingEnabled \(purchasingEnabled)")
				/*Task {
					isPurchased = (try? await store.isPurchased(product)) ?? false
				}*/
			}
			.onDisappear(perform: {
				showPurchaseWaiting = false
			})
			.padding([.trailing,.leading], 15)
			.padding(.top, 20)
		}
		.alert(isPresented: $isShowingError, content: {
				Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
		})
	}
	

	func buy() async {
		do {
			if try await store.purchase(product) != nil {
				print("[debug] BuyItemView, buy, store.purchase(product) != ni")
				withAnimation {
					//isPurchased = true
					showPurchaseWaiting = false
					purchasingEnabled = false
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


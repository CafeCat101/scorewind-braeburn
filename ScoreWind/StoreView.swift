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
			Text("Your Study Plan")
				.font(.title)
				.padding([.bottom],30)
			//Text("This is the place where you subscribe scorewind")
			ForEach(store.subscriptions) { product in
				BuyItemView(product: product)
			}
			Spacer()
		}
		.onAppear {
			Task {
					//When this view appears, get the latest subscription status.
				await store.updateCustomerProductStatus()
			}
		}
	}
}

struct StoreView_Previews: PreviewProvider {
	static var previews: some View {
		StoreView(showStore:.constant(false)).environmentObject(Store())
	}
}

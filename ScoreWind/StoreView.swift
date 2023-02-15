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
			Text("This is the place where you subscribe scorewind")
			Spacer()
		}
	}
}

struct StoreView_Previews: PreviewProvider {
	static var previews: some View {
		StoreView(showStore:.constant(false)).environmentObject(Store())
	}
}

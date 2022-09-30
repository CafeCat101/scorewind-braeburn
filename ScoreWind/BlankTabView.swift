//
//  BlankTabView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/7/3.
//

import SwiftUI

struct BlankTabView: View {
	@State var message = ""
	var body: some View {
		VStack {
			Label("Scorewind", systemImage: "music.note")
				.labelStyle(.titleAndIcon)
			Spacer()
			Text(message)
				.padding(15)
			Spacer()
		}
		
	}
}

struct BlankTabView_Previews: PreviewProvider {
	static var previews: some View {
		BlankTabView()
	}
}

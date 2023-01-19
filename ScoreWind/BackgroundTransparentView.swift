//
//  BackgroundTransparentView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/18.
//

import SwiftUI

struct BackgroundTransparentView: UIViewRepresentable {
	func makeUIView(context: Context) -> UIView {
		let view = UIView()
		DispatchQueue.main.async {
			view.superview?.superview?.backgroundColor = .clear
		}
		return view
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {}
}

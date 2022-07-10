//
//  TipModalView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/7/9.
//

import SwiftUI

struct TipModalView: View {
	@Environment(\.presentationMode) var presentationMode
	@EnvironmentObject var scorewindData:ScorewindData
	private var userDefaults = UserDefaults.standard
	
	var body: some View {
		VStack {
			/*Spacer()
			 .frame(maxWidth: .infinity, minHeight: 100)
			 .background(Color.black)
			 .opacity(0.3)*/
			Button(action: {
				if scorewindData.currentTip == .lessonScoreViewer {
					var tipCount = userDefaults.object(forKey: Tip.lessonScoreViewer.rawValue) as? Int ?? 0
					tipCount = tipCount + 1
					userDefaults.set(tipCount,forKey: Tip.lessonScoreViewer.rawValue)
				}
				presentationMode.wrappedValue.dismiss()
			}, label: {
				VStack {
					/*Spacer()
					 .frame(maxWidth: .infinity, minHeight: .infinity)
					 .background(Color.black)
					 .opacity(0.3)*/
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(Color.black)
				.foregroundColor(Color.white)
				.opacity(0.6)
				.overlay(content: {
					if scorewindData.currentTip == Tip.lessonScoreViewer {
						Circle()
							.strokeBorder(.gray,lineWidth: 1)
							.background(Circle().foregroundColor(.white))
							.frame(width:200,height:200)
							.overlay(
								Text("Tip! Swipe left to see score.").foregroundColor(.black)
							)
					} else {
						Circle()
							.strokeBorder(.gray,lineWidth: 1)
							.background(Circle().foregroundColor(.white))
							.frame(width:200,height:200)
							.overlay(
								Text("Tip! Tips for new comers.").foregroundColor(.black)
							)
					}
				})
			})
			/*Button("Dismiss") {
			 presentationMode.wrappedValue.dismiss()
			 }
			 .frame(maxWidth: .infinity, maxHeight: 300)
			 .background(Color.black)
			 .foregroundColor(Color.white)
			 Spacer()
			 .frame(maxWidth: .infinity, minHeight: 100)
			 .background(Color.black)
			 .opacity(0.3)*/
		}
		.background(BackgroundCleanerView())
	}
	
	struct BackgroundCleanerView: UIViewRepresentable {
		func makeUIView(context: Context) -> UIView {
			let view = UIView()
			DispatchQueue.main.async {
				view.superview?.superview?.backgroundColor = .clear
			}
			return view
		}
		
		func updateUIView(_ uiView: UIView, context: Context) {}
	}
}


struct TipModalView_Previews: PreviewProvider {
	static var previews: some View {
		TipModalView().environmentObject(ScorewindData())
	}
}

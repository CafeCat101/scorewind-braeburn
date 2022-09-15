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
				var tipCount = userDefaults.object(forKey: scorewindData.currentTip.rawValue) as? Int ?? 0
				tipCount = tipCount + 1
				userDefaults.set(tipCount,forKey: scorewindData.currentTip.rawValue)
				
				presentationMode.wrappedValue.dismiss()
			}, label: {
				VStack {
					/*Spacer()
					 .frame(maxWidth: .infinity, minHeight: .infinity)
					 .background(Color.black)
					 .opacity(0.3)*/
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(Color.black)//.foregroundColor(Color.white)
				.opacity(0.6)
				.overlay(content: {
					if scorewindData.currentTip == Tip.lessonView {
						Circle()
							.strokeBorder(.gray,lineWidth: 1)
							.background(Circle().foregroundColor(.white))
							.frame(width:400,height:500)
							.overlay(
								Text("Tip! Tab the lesson title to find out what you can do in the menu.\n\nTo remember lesson you've learned, just mark it \"Completed\" from there.").foregroundColor(.black)
									.frame(width:300,height:400)
							)
					} else if scorewindData.currentTip == Tip.myCourseView {
						Circle()
							.strokeBorder(.gray,lineWidth: 1)
							.background(Circle().foregroundColor(.white))
							.frame(width:400,height:500)
							.overlay(
								Text("My Courses\n\nA plcae to continue where you left off.\n\nWhen you mark a lesson completed or watched, you can find the course for it here.").foregroundColor(.black)
									.frame(width:300,height:400)
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

//
//  TipTransparentModalView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/19.
//

import SwiftUI

struct TipTransparentModalView: View {
	@Binding var showStepTip:Bool
	@Binding var tipContent:AnyView
	//let screenSize: CGRect = UIScreen.main.bounds
	//@State private var userDefaults = UserDefaults.standard
	
	var body: some View {
		VStack {
			VStack{
			}.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(Color.black)//.foregroundColor(Color.white)
			 .opacity(0.77)
			 .overlay(content: {
				 tipContent
				 /*
				 VStack{
					 Spacer()
					 tipContent
					 Spacer()
					 VStack{
						 Button(action: {
							 print("ok")
							 showStepTip = false
						 }, label: {
							 Text("OK")
						 })
						 .foregroundColor(Color("LessonSheet"))
						 .padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
						 .background {
							 RoundedRectangle(cornerRadius: 26)
								 .foregroundColor(Color("AppYellow"))
						 }
						 
						 Button(action: {
							 print("don't show me again")
							 var hideTips:[String] = userDefaults.object(forKey: "hideTips") as? [String] ?? []
							 if hideTips.contains(Tip.wizardExperience.rawValue) == false {
								 hideTips.append(Tip.wizardExperience.rawValue)
								 userDefaults.set(hideTips,forKey: "hideTips")
							 }
							 
							 showStepTip = false
						 }, label: {
							 Text("Don't show me again")
						 }).foregroundColor(Color("LessonSheet"))
							 .padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
								.background {
									RoundedRectangle(cornerRadius: 26)
										.foregroundColor(Color("BadgeScoreAvailable"))
								}
					 }
				 }*/
			 })
			 .onTapGesture {
				 showStepTip = false
			 }
		}.background(BackgroundTransparentView())
	}
}

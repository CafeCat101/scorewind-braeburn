//
//  TipContentMakerView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/28.
//

import SwiftUI

struct TipContentMakerView: View {
	@Binding var showStepTip:Bool
	var hideTipValue:String = ""
	var tipMainContent:AnyView
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var userDefaults = UserDefaults.standard
	
	var body: some View {
		VStack{
			Spacer()
			//tip content ==>
			tipMainContent
			//<===
			Spacer()
			VStack{
				Button(action: {
					print("ok")
					showStepTip = false
				}, label: {
					Text("OK").frame(minWidth:150)
				})
				.foregroundColor(Color("LessonListStatusIcon"))
				.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
				.background {
					RoundedRectangle(cornerRadius: 26)
						.foregroundColor(Color("AppYellow"))
				}
				Spacer().frame(maxHeight:20)
				Button(action: {
					print("don't show me again")
					var hideTips:[String] = userDefaults.object(forKey: "hideTips") as? [String] ?? []
					if hideTips.contains(hideTipValue) == false {
						hideTips.append(hideTipValue)
						userDefaults.set(hideTips,forKey: "hideTips")
					}
					
					showStepTip = false
				}, label: {
					Text("Don't show me again").frame(minWidth:150)
				}).foregroundColor(Color("LessonSheet"))
					.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
					 .background {
						 RoundedRectangle(cornerRadius: 26)
							 .foregroundColor(Color("BadgeScoreAvailable"))
					 }
			}
		}
	}
}

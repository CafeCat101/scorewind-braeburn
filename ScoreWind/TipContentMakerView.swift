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
	@State private var userDefaults = UserDefaults.standard
	var allowHideForever = false
	@Environment(\.verticalSizeClass) var verticalSize
	
	var body: some View {
		VStack{
			Spacer()
			//tip content ==>
			if verticalSize == .regular {
				tipMainContent.frame(height: UIScreen.main.bounds.height*0.6)
			} else {
				tipMainContent
			}
			
			//<===
			Spacer()
			
			if verticalSize == .regular {
				VStack {
					displayOkButton()
					
					Spacer().frame(maxHeight:44)
					
					if allowHideForever == false {
						displayHideButton()
					}
				}
				
				Spacer()
			} else {
				HStack{
					Spacer()
					displayOkButton()
					Spacer().frame(width:20)
					if allowHideForever == false {
						displayHideButton()
					}
					Spacer()
				}
			}
		}
	}
	
	@ViewBuilder
	private func displayOkButton() -> some View {
		Label("Ok", systemImage: "doc.plaintext")
			.frame(maxWidth: 35, maxHeight:20)
			.labelStyle(.titleOnly)
			.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
			.foregroundColor(Color("MainBrown+6"))
			.background(
				RoundedRectangle(cornerRadius: CGFloat(26))
					.foregroundColor(Color("AppYellow"))
					.shadow(color: Color("Dynamic/ShadowLight"),radius: CGFloat(7))
					.opacity(0.90)
			)
			.onTapGesture {
				print("ok")
				showStepTip = false
			}
	}
	
	@ViewBuilder
	private func displayHideButton() -> some View {
		
			Label("Don't show me again", systemImage: "doc.plaintext")
				.frame(maxHeight:20)
				.labelStyle(.titleOnly)
				.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
				.foregroundColor(Color("MainBrown+6"))
				.background(
					RoundedRectangle(cornerRadius: CGFloat(26))
						.foregroundColor(Color("LightGray"))
						.shadow(color: Color("Dynamic/ShadowLight"),radius: CGFloat(7))
						.opacity(0.90)
				)
				.onTapGesture {
					print("don't show me again")
					var hideTips:[String] = userDefaults.object(forKey: "hideTips") as? [String] ?? []
					if hideTips.contains(hideTipValue) == false {
						hideTips.append(hideTipValue)
						userDefaults.set(hideTips,forKey: "hideTips")
					}
					
					showStepTip = false
				}
			
			/*Button(action: {
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
				 }*/
	}
}

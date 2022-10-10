//
//  WizardInstrument.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/10.
//

import SwiftUI

struct WizardInstrument: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	
	var body: some View {
		VStack {
			Spacer()
			Text("Which instrument do you want to learn?")
				.font(.headline)
			
			HStack {
				Button(action:{
					stepName = .wizardPlayable
					studentData.updateInstrumentChoice(instrument: .guitar)
				}){
					Circle()
						.strokeBorder(Color.black,lineWidth: 1)
						.background(Circle().foregroundColor(Color.white))
						.frame(width:100,height:100)
						.overlay(
							Image("instrument-guitar-icon")
								.resizable()
								.scaleEffect(0.6)
						)
				}
				
				Button(action:{
					stepName = .wizardPlayable
					studentData.updateInstrumentChoice(instrument: .violin)
				}){
					Circle()
						.strokeBorder(Color.black,lineWidth: 1)
						.background(Circle().foregroundColor(Color.white))
						.frame(width:100,height:100)
						.overlay(
							Image("instrument-violin-icon")
								.resizable()
								.scaleEffect(0.6)
						)
				}
			}
			
			Spacer()
		}
	}
}

struct WizardInstrument_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardChooseInstrument
	static var previews: some View {
		WizardInstrument(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

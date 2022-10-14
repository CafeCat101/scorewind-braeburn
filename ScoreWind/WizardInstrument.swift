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
				.font(.title3)
			
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
							getChoiceIcon(instrumentImage: "instrument-guitar-icon", isSelected: isInstrumentSelected(askInstrument: .guitar))
						)
				}.padding()
				
				Button(action:{
					stepName = .wizardPlayable
					studentData.updateInstrumentChoice(instrument: .violin)
				}){
					Circle()
						.strokeBorder(Color.black,lineWidth: 1)
						.background(Circle().foregroundColor(Color.white))
						.frame(width:100,height:100)
						.overlay(
							getChoiceIcon(instrumentImage: "instrument-violin-icon", isSelected: isInstrumentSelected(askInstrument: .violin))
						)
				}.padding()
			}
			
			Spacer()
		}
	}
	
	@ViewBuilder
	private func getChoiceIcon(instrumentImage:String, isSelected:Bool) -> some View {
		Image(instrumentImage)
			.resizable()
			.scaleEffect(0.6)
			.overlay(
				alignment:.bottom,
				content: {
					Label("select",systemImage: "checkmark.circle.fill")
						.labelStyle(.iconOnly)
						.font(.title)
						.opacity(isSelected ? 1.0 : 0.0)
				})
	}
	
	private func isInstrumentSelected(askInstrument: InstrumentType) -> Bool {
		if studentData.getInstrumentChoice() == askInstrument.rawValue {
			return true
		} else {
			return false
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

//
//  WizardInstrument.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/10.
//

import SwiftUI

struct WizardInstrumentView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	
	var body: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()
				Text("Choose your instrument")
					.font(.title3)
					.foregroundColor(Color("WizardBackArrow"))
					.bold()
				Spacer()
			}
			
			
			HStack {
				Button(action:{
					stepName = .wizardExperience
					studentData.updateInstrumentChoice(instrument: .guitar)
					studentData.removeAKey(keyName: "experience")
					studentData.wizardStepNames.append(stepName)
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
					stepName = .wizardExperience
					studentData.updateInstrumentChoice(instrument: .violin)
					studentData.wizardStepNames.append(stepName)
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
		.background(Color("AppBackground"))
		.onAppear(perform: {
			if studentData.wizardStepNames.count == 0 {
				//:: start over, reset everything
				studentData.resetWizrdChoice()
				studentData.wizardRange.removeAll()
				studentData.removeAKey(keyName: "wizardResult")
				studentData.wizardResult = WizardResult()
				studentData.wizardStepNames = [.wizardChooseInstrument]
			} else {
				stepName = Page.wizardResult
			}
			/*
			let iCloudLearningPathCount = studentData.getWizardResult().learningPath.count
			if iCloudLearningPathCount > 0  && studentData.wizardResult.learningPath.count == 0 {
				//has wizardResult saved on icloud before and at app launch
				stepName = Page.wizardResult
			} else if iCloudLearningPathCount > 0 && studentData.wizardResult.learningPath.count > 0 && studentData.wizardStepNames.count > 0 {
				//:: after app launches, had done learning configuration before
				stepName = Page.wizardResult
			}
			else {
				//:: start over, reset everything
				studentData.resetWizrdChoice()
				studentData.wizardRange.removeAll()
				studentData.removeAKey(keyName: "wizardResult")
				studentData.wizardResult = WizardResult()
				studentData.wizardStepNames = [.wizardChooseInstrument]

				print("[debug] WizardInstrument, wizardStepNames \(studentData.wizardStepNames)")
			}*/
			
		})
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
	@State static var tab = "THome"
	@State static var step:Page = .wizardChooseInstrument
	static var previews: some View {
		WizardInstrumentView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

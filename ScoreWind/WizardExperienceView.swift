//
//  WizardExperienceView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/23.
//

import SwiftUI

struct WizardExperienceView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	
	var body: some View {
		VStack {
			Text("Start with Starter Kit")
				.modifier(FeedbackOptionsModifier())
				.onTapGesture {
					print("choose Starter Kit")
					stepName = .wizardResult
					studentData.wizardStepNames.append(stepName)
				}
			
			Text("Pick something else")
				.modifier(FeedbackOptionsModifier())
				.onTapGesture {
					print("choose Pick something else")
					stepName = .wizardDoYouKnow
					studentData.wizardStepNames.append(stepName)
				}
		}
		.background(Color("AppBackground"))
		.onAppear(perform: {
			studentData.wizardStepNames = [.wizardExperience]
		})
	}
}

struct WizardExperienceView_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardChooseInstrument
	static var previews: some View {
		WizardExperienceView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

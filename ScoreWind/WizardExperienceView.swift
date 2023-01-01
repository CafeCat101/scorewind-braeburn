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
			Spacer()
			Text(ExperienceFeedback.starterKit.getLabel())
				.modifier(FeedbackOptionsModifier())
				.onTapGesture {
					print("choose Starter Kit")
					gotFeedback(selectedFeedback: .starterKit)
				}
				.padding(.bottom,20)
			
			Text(ExperienceFeedback.continueLearning.getLabel())
				.modifier(FeedbackOptionsModifier())
				.onTapGesture {
					print("choose Pick something else")
					gotFeedback(selectedFeedback: .continueLearning)
				}
				.padding(.bottom,20)
			
			Text(ExperienceFeedback.experienced.getLabel())
				.modifier(FeedbackOptionsModifier())
				.onTapGesture {
					print("choose Pick something else")
					gotFeedback(selectedFeedback: .experienced)
				}
			Spacer()
		}
		.background(Color("AppBackground"))
		.onAppear(perform: {
			
		})
	}
	
	private func gotFeedback(selectedFeedback: ExperienceFeedback) {
		studentData.updateExperience(experience: selectedFeedback)
		
		let nextStepPage = scorewindData.createRecommendation(studentData: studentData)
		
		if nextStepPage != .wizardChooseInstrument {
			stepName = nextStepPage
			studentData.wizardStepNames.append(nextStepPage)
		}
	}
}

struct WizardExperienceView_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardChooseInstrument
	static var previews: some View {
		WizardExperienceView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

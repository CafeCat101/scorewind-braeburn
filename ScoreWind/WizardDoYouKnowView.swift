//
//  WizardDoYouKnow.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/23.
//

import SwiftUI

struct WizardDoYouKnowView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	@StateObject var viewModel = ViewModel()
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var currentQuestionIndex = 0
	@State private var feedbackScores:[Int] = []
	
	var body: some View {
		VStack {
			Spacer()
			VStack{
				Text("Do you know?")
					.font(.title3)
					.bold()
					.foregroundColor(Color("WizardBackArrow"))
					.padding(EdgeInsets(top: 50, leading: 30, bottom: 30, trailing: 30))
				Text("\(scorewindData.getListInCourse(targetText: scorewindData.wizardPickedCourse.content, listName: .requirement)[currentQuestionIndex])")
					.padding(EdgeInsets(top: 0, leading: 30, bottom: 50, trailing: 30))
			}
			.background(Color("WizardFeedBack"))
			.clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
			.padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
			
			Spacer()
			
			VStack {
				ForEach(DoYouKnowFeedback.allCases, id: \.self) {feedbackItem in
					Text(feedbackItem.getLabel())
						.modifier(FeedbackOptionsModifier())
						.onTapGesture {
							print("feedback clicked value \(feedbackItem.rawValue)")
							feedbackScores.append(feedbackItem.rawValue)
							print("feedback scores sum \(feedbackScores)")
							
							if (currentQuestionIndex + 1) < scorewindData.getListInCourse(targetText: scorewindData.wizardPickedCourse.content, listName: .requirement).count {
								currentQuestionIndex = currentQuestionIndex + 1
							} else {
								studentData.updateDoYouKnow(courseID: scorewindData.wizardPickedCourse.id, feedbackValues: feedbackScores)
								let nextStep = scorewindData.createRecommendation(availableCourses: scorewindData.allCourses, studentData: studentData)
								
								if nextStep != .wizardChooseInstrument {
									stepName = nextStep
									studentData.wizardStepNames.append(nextStep)
								}
							}
							
						}
				}
			}.padding(EdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20))
		}
		.background(Color("AppBackground"))
		.onAppear(perform: {
			print("[debug] WizardDoYouKnowView, wizardStepNames \(studentData.wizardStepNames)")
			currentQuestionIndex = 0
		})
	}
}

struct WizardDoYouKnow_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardDoYouKnow
	
	static var previews: some View {
		WizardDoYouKnowView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
		WizardDoYouKnowView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData()).environment(\.colorScheme, .dark)
	}
}

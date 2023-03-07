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
	@State private var questions:[String] = []
	let feedback = UIImpactFeedbackGenerator(style: .heavy)
	
	var body: some View {
		VStack {
			if currentQuestionIndex < questions.count {
				//show questions
				Spacer()
				HStack {
					Spacer()
					Text("Do you know?")
						.font(.title)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.bold()
					Spacer()
				}
				Divider().frame(width:screenSize.width*0.85)
				
				VStack {
					Text("\(questions[currentQuestionIndex])")
						.font(.headline)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.multilineTextAlignment(.center)
						.padding(EdgeInsets(top: 30, leading: 15, bottom: 30, trailing: 15))
				}
				.frame(width:screenSize.width*0.85)
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/MainBrown"))
						.opacity(0.25)
				)
				
				Spacer()
				
				VStack {
					HStack {
						displayFeedbackItem(feedbackItem: .allOfThem, iconName: "feedbackYes")
						
						Spacer().frame(width:15)
						
						displayFeedbackItem(feedbackItem: .fewOfThem, iconName: "feedbackNo")

					}
					
					Spacer().frame(height:15)
					
					displayFeedbackItem(feedbackItem: .someOfThem, iconName: "feedbackFamiliar")
				}
				.padding([.top, .bottom], 10)
				.frame(width: screenSize.width*0.85)
				
			}
			Spacer()
			
			Text("course:\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedCourse.title))").font(.footnote)
		}
		.onAppear(perform: {
			print("[debug] WizardDoYouKnowView, wizardStepNames \(studentData.wizardStepNames)")
			currentQuestionIndex = 0
			feedbackScores = []
			questions = scorewindData.getListInCourse(targetText: scorewindData.wizardPickedCourse.content, listName: .requirement)
		})
	}
	
	@ViewBuilder
	private func displayFeedbackItem(feedbackItem: DoYouKnowFeedback, iconName: String) -> some View{
		HStack {
			Spacer()
			VStack {
				Image(iconName)
					.resizable()
					.scaledToFit()
					.shadow(color: Color("Dynamic/MainBrown+6").opacity(0.5), radius: CGFloat(5))
				Text(feedbackItem.getLabel())
			}
			.padding(10)
			.frame(maxHeight: 120)
			Spacer()
		}
		.frame(minHeight: 80)
		.foregroundColor(Color("Dynamic/MainBrown+6"))
		.background {
			RoundedRectangle(cornerRadius: 17)
				.foregroundColor(Color("Dynamic/LightGray"))
				.shadow(color: Color("Dynamic/ShadowLight"),radius: CGFloat(5))
		}
		.onTapGesture {
			tapFeedback(feedbackItem: feedbackItem)
		}
	}
	
	private func tapFeedback(feedbackItem:DoYouKnowFeedback) {
		print("[debug] WizardDoYouKnowView, feedback clicked value \(feedbackItem.rawValue)")
		feedback.impactOccurred()
		
		if scorewindData.wizardPickedCourse.category.contains(where: {$0.name == "Guitar 103" || $0.name == "Violin 103"}) {
			if feedbackItem == .someOfThem {
				feedbackScores.append(feedbackItem.rawValue)
				print("[debug] WizardDoYouKnowView, feedbackScores.append \(feedbackItem.rawValue)")
			} else {
				feedbackScores.append(feedbackItem.rawValue)
				print("[debug] WizardDoYouKnowView, feedbackScores.append \(feedbackItem.rawValue)")
			}
		} else {
			feedbackScores.append(feedbackItem.rawValue)
			print("[debug] WizardDoYouKnowView, feedbackScores.append \(feedbackItem.rawValue)")
		}
		
		print("[debug] WizardDoYouKnowView, feedback scores sum \(feedbackScores)")
		
		if (currentQuestionIndex+1) < questions.count {
			withAnimation (.timingCurve(0.2, 0.8, 0.2, 1, duration: 1)) {
				currentQuestionIndex = currentQuestionIndex + 1
			}
			
		} else {
			studentData.updateDoYouKnow(courseID: scorewindData.wizardPickedCourse.id, feedbackValues: feedbackScores)
			var nextStep:Page
			
			if studentData.wizardRange.count < 10 {
				nextStep = scorewindData.createRecommendation(studentData: studentData)
			} else {
				scorewindData.finishWizardNow(studentData: studentData)
				nextStep = Page.wizardResult
			}
			
			if nextStep != .wizardChooseInstrument {
				stepName = nextStep
				studentData.wizardStepNames.append(nextStep)
				//RESET SCORES AND QUESTION INDEX FOR POSSIBLE NEXT DO YOU NOW VIEW
				currentQuestionIndex = 0
				feedbackScores = []
				questions = scorewindData.getListInCourse(targetText: scorewindData.wizardPickedCourse.content, listName: .requirement)
			}
			
		}
	}
}

struct WizardDoYouKnow_Previews: PreviewProvider {
	@StateObject static var scorewindData = ScorewindData()
	@State static var tab = "THome"
	@State static var step:Page = .wizardDoYouKnow
	
	static var previews: some View {
		WizardDoYouKnowView(selectedTab: $tab, stepName: $step, studentData: StudentData())
			.environmentObject(scorewindData)
			.environment(\.colorScheme, .light)
		
		WizardDoYouKnowView(selectedTab: $tab, stepName: $step, studentData: StudentData())
			.environmentObject(scorewindData)
			.environment(\.colorScheme, .dark)
	}
	
}

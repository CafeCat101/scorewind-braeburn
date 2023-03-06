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
					RoundedRectangle(cornerRadius: CGFloat(28))
						.foregroundColor(Color("Dynamic/MainBrown"))
						.opacity(0.25)
				)
				
				
				/*VStack{
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
				 */
				
				Spacer()
				
				VStack {
					ForEach(DoYouKnowFeedback.allCases, id: \.self) {feedbackItem in
						Text(feedbackItem.getLabel())
							.modifier(FeedbackOptionsModifier())
							.padding(.bottom, 10)
							.onTapGesture {
								print("[debug] WizardDoYouKnowView, feedback clicked value \(feedbackItem.rawValue)")
								feedback.impactOccurred()
								
								if scorewindData.wizardPickedCourse.category.contains(where: {$0.name == "Guitar 103" || $0.name == "Violin 103"}) {
									if feedbackItem == .someOfThem {
										feedbackScores.append(DoYouKnowFeedback.allOfThem.rawValue)
										print("[debug] WizardDoYouKnowView, feedbackScores.append \(DoYouKnowFeedback.allOfThem.rawValue)")
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
									currentQuestionIndex = currentQuestionIndex + 1
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
				}.padding(EdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20))
				
				Spacer()
			}
			
			
			Text("course:\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedCourse.title))").font(.footnote)
		}
		//.background(Color("AppBackground"))
		.onAppear(perform: {
			print("[debug] WizardDoYouKnowView, wizardStepNames \(studentData.wizardStepNames)")
			currentQuestionIndex = 0
			feedbackScores = []
			questions = scorewindData.getListInCourse(targetText: scorewindData.wizardPickedCourse.content, listName: .requirement)
		})
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

//
//  WizardResult.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/16.
//

import SwiftUI

struct WizardResultView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	@State private var dummyLearningPath:[String] = ["Course1","Course2","Course3"]
	@State private var showMeMore:Bool = false
	@State private var thisWizardResult:WizardResult = WizardResult(getAllCourses: [], getAllTimestamps: [])
	
	
	var body: some View {
		ScrollView(.vertical) {
			VStack {
				HStack {
					Text(thisWizardResult.resultTitle)
						.font(.title)
						.bold()
					Spacer()
				}
				
				if showMeMore == false {
					Spacer()
					Text(thisWizardResult.resultExplaination)
					//Text("\n\nTo learn more about the findings, please click \"Tell me more\""+". Thank you!")
					Spacer()
				}
				
				HStack {
					Text("The lesson")
						.font(.title2)
						.bold()
					Spacer()
				}.padding([.top,.bottom], 15)
				VStack {
					Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedLesson.title))
						.foregroundColor(Color("LessonListStatusIcon"))
						.font(.title2)
						.bold()
						.padding([.top, .bottom], 15)
						.frame(maxWidth: .infinity, minHeight: 100)
						.background(.yellow)
						.cornerRadius(25)
					if showMeMore == false {
						Text(scorewindData.wizardPickedLesson.description)
							.foregroundColor(Color("LessonListStatusIcon"))
							.padding([.leading, .bottom, .trailing], 15)
					}
				}
				.onTapGesture {
					scorewindData.currentCourse = scorewindData.wizardPickedCourse
					
					scorewindData.currentLesson = scorewindData.wizardPickedLesson
					scorewindData.setCurrentTimestampRecs()
					scorewindData.lastPlaybackTime = 0.0
					self.selectedTab = "TLesson"
					scorewindData.lessonChanged = true
				}
				.background {
					RoundedRectangle(cornerRadius: 26)
					.foregroundColor(Color("AppYellow"))}
				
				
				Button(action: {
					withAnimation {
						showMeMore.toggle()
					}
				}, label: {
					Text(showMeMore ? "Show me less" : "Tell me more")
						.foregroundColor(Color("LessonListStatusIcon"))
						.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
						.background(Color("AppYellow"))
						.cornerRadius(26)
				})
				.padding([.top],15)
				Spacer()
				
				if showMeMore {
					HStack {
						Text("The Course")
							.font(.title2)
							.bold()
						Spacer()
					}.padding([.top,.bottom], 15)
					Text("You may be interested to know that ")+Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedLesson.title)).bold()+Text(" is coming from this course. Click the course title if you want to learn more about it.")
					Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedCourse.title))
						.foregroundColor(Color("LessonListStatusIcon"))
						.font(.title2)
						.bold()
						.padding([.top, .bottom], 15)
						.frame(maxWidth: .infinity, minHeight: 100)
						.background(.yellow)
						.cornerRadius(25)
						.onTapGesture {
							scorewindData.currentCourse = scorewindData.wizardPickedCourse
							scorewindData.currentView = Page.course
							self.selectedTab = "TCourse"
							scorewindData.currentLesson = scorewindData.wizardPickedCourse.lessons[0]
							scorewindData.setCurrentTimestampRecs()
							//scorewindData.lastViewAtScore = true
							scorewindData.lastPlaybackTime = 0.0
							scorewindData.lessonChanged = true
						}
					
					VStack {
						HStack {
							Text(thisWizardResult.learningPathTitle)
								.font(.title2)
								.bold()
							Spacer()
						}.padding([.top,.bottom], 15)
						Text(thisWizardResult.learningPathExplaination)
						
						WizardResultPathView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData, thisLearningPath: getLearningPath())
						
					}
					
					
				}
				
				
			}
			.background(Color("AppBackground"))
			.padding([.leading, .trailing], 15)
			.onAppear(perform: {
				print("[debug] WizardResultView.onAppear, wizardStepNames \(studentData.wizardStepNames)")
				thisWizardResult = WizardResult(getAllCourses: scorewindData.allCourses, getAllTimestamps: scorewindData.allTimestamps)
			})
		}
	}
	
	private func getLearningPath() -> [WizardLearningPathItem] {
		let getExperience = experienceFeedbackToCase(caseValue: studentData.getExperience())
		return thisWizardResult.getLearningPath(wizardRange: studentData.wizardRange, experienceType: getExperience)
	}
	
	private func experienceFeedbackToCase(caseValue: String) -> ExperienceFeedback {
		switch caseValue {
		case ExperienceFeedback.starterKit.rawValue:
			return .starterKit
		case ExperienceFeedback.continueLearning.rawValue:
			return .continueLearning
		case ExperienceFeedback.experienced.rawValue:
			return .experienced
		default:
			return .starterKit
		}
	}
	
	
}

struct WizardResult_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardResult
	
	static var previews: some View {
		WizardResultView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

/**
 texts to replace
 "Discovered a lesson" - title to summerize the wizard result.
 "You've completed the wizard. Scorewind a found lesson for you." - paragraph to explain what does the title mean. ex: This is your next up comming lesson await for you to be completed.
 "Your learning path" - title to summerize the wizard.range
 "(optional text) below Your learning path" - paragraph to explain what does the content in wizard.range represent.
 */

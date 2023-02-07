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
	@State private var showStepTip = false
	@State private var tipContent:AnyView = AnyView(Text("Tip"))
	@State private var userDefaults = UserDefaults.standard
	@Binding var showLessonView:Bool
	
	var body: some View {
		ScrollView(.vertical) {
			VStack {
				HStack {
					Text(studentData.wizardResult.resultTitle)
						.font(.title)
						.bold()
					Spacer()
				}
				
				if showMeMore == false {
					Spacer()
					Text(studentData.wizardResult.resultExplaination)
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
					self.selectedTab = "TCourse"
					showLessonView = true
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
					Text(showMeMore ? "Hide details" : "Tell me more")
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
							Text(studentData.wizardResult.learningPathTitle)
								.font(.title2)
								.bold()
							Spacer()
						}.padding([.top,.bottom], 15)
						Text(studentData.wizardResult.learningPathExplaination)
						
						WizardResultPathView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData, showLessonView: $showLessonView)
						
					}
					
					
				}
				
				
			}
			.background(Color("AppBackground"))
			.padding([.leading, .trailing], 15)
			.onAppear(perform: {
				print("[debug] WizardResultView.onAppear, wizardResult.learningPath.count \(studentData.wizardResult.learningPath.count)")
				
			})
		}
		.onAppear(perform: {
			print("[debug] WizardResultView, onAppear, icloud wizardResult \(studentData.getWizardResult())")
			print("[debug] WizardResultView, onAppear, local wizardResult \(studentData.wizardResult)")
			if studentData.wizardRange.count > 0 && studentData.wizardResult.learningPath.count > 0 && studentData.getWizardResult().learningPath.count == 0 {
				//:: from finishing the wizard, wizardPicked is already assigned from createRecommendation
				studentData.updateWizardResult(result: studentData.wizardResult)
				handleTip()
			} else if studentData.getWizardResult().learningPath.count > 0 {
				//:: probably has wizardResult on iCloud, unlless the app crashes
					studentData.wizardResult = studentData.getWizardResult()
					let getPickedItem = studentData.wizardResult.learningPath.first(where: {$0.startHere == true}) ?? WizardLearningPathItem()
					if getPickedItem.courseID > 0 && getPickedItem.lessonID > 0 {
						scorewindData.wizardPickedCourse = scorewindData.allCourses.first(where: {$0.id == getPickedItem.courseID}) ?? Course()
						scorewindData.wizardPickedLesson = scorewindData.wizardPickedCourse.lessons.first(where: {$0.id == getPickedItem.lessonID}) ?? Lesson()
						scorewindData.wizardPickedTimestamps = (scorewindData.allTimestamps.first(where: {$0.id == getPickedItem.courseID})?.lessons.first(where: {$0.id == getPickedItem.lessonID})!.timestamps) ?? []
						handleTip()
					} else {
						stepName = Page.wizardChooseInstrument
					}
			} else {
				stepName = Page.wizardChooseInstrument
			}
			
			
			
		})
		.fullScreenCover(isPresented: $showStepTip, content: {
			TipTransparentModalView(showStepTip: $showStepTip, tipContent: $tipContent)
		})
	}
	
	private func handleTip() {
		let hideTips:[String] = userDefaults.object(forKey: "hideTips") as? [String] ?? []
		if hideTips.contains(Tip.wizardResult.rawValue) == false {
			tipContent = AnyView(TipContentMakerView(showStepTip: $showStepTip, hideTipValue: Tip.wizardResult.rawValue, tipMainContent: AnyView(tipHere())))
			if studentData.getExperience() == ExperienceFeedback.starterKit.rawValue {
				//:: delay tip a little because starterkit doesn't have steps
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					showStepTip = true
				}
			} else {
				showStepTip = true
			}
		}
	}
	
	@ViewBuilder
	private func tipHere() -> some View {
		VStack {
			Text("The place to discover new lessons!")
			.font(.headline)
			.modifier(StepExplainingText())
			VStack(alignment:.leading) {
				Text("You can always restart the wizard again by click the \(Image(systemName: "goforward")) button in the top left corner.")
					.modifier(TipExplainingParagraph())
				Text("Your last result is also saved, so you can revisit it whenever you want.")
					.modifier(TipExplainingParagraph())
			}.padding([.bottom], 18)
		}.background {
			RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("AppYellow"))
			.frame(width: UIScreen.main.bounds.width*0.9)}
	}
}



struct WizardResult_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardResult
	
	static var previews: some View {
		WizardResultView(selectedTab: $tab, stepName: $step, studentData: StudentData(), showLessonView: .constant(false)).environmentObject(ScorewindData())
	}
}

/**
 texts to replace
 "Discovered a lesson" - title to summerize the wizard result.
 "You've completed the wizard. Scorewind a found lesson for you." - paragraph to explain what does the title mean. ex: This is your next up comming lesson await for you to be completed.
 "Your learning path" - title to summerize the wizard.range
 "(optional text) below Your learning path" - paragraph to explain what does the content in wizard.range represent.
 */

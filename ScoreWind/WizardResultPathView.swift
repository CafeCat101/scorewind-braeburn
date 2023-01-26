//
//  WizardResultPathView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/21.
//

import SwiftUI

struct WizardResultPathView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	var body: some View {
		VStack {
			ForEach(studentData.wizardResult.learningPath) { pathItem in
				pathItemView(pathItem: pathItem, startHere: pathItem.startHere)
				
				if pathItem.lessonID != studentData.wizardResult.learningPath[studentData.wizardResult.learningPath.count - 1].lessonID {
					HStack {
						Spacer()
						Label("Next", systemImage: "arrow.down")
							.labelStyle(.iconOnly)
						Spacer()
					}
				}
			}
		}
	}
	
	@ViewBuilder
	private func pathItemView(pathItem: WizardLearningPathItem, startHere: Bool) -> some View {
		if pathItem.showCourseTitle {
			Text("Course: \(scorewindData.replaceCommonHTMLNumber(htmlString: pathItem.courseTitle))")
				.foregroundColor(Color("LessonSheet"))
				.frame(maxWidth: .infinity, minHeight: 60)
				.padding([.leading, .trailing], 15)
				.background(Color("BadgeWatchLearn"))
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
		}
		
		if (scorewindData.wizardPickedCourse.lessons[0].id != pathItem.lessonID) && (studentData.wizardResult.learningPath[0].lessonID == pathItem.lessonID) {
			Label("Next", systemImage: "arrow.down")
				.labelStyle(.iconOnly)
			Label("Next", systemImage: "arrow.down")
				.labelStyle(.iconOnly)
		}
		
		if startHere {
			VStack {
				Label(title: {
					Text("Start here")
					.bold()
					.foregroundColor(.yellow)
				}, icon: {
						Image(systemName: "paperplane.circle")
						.foregroundColor(.yellow)
				}).padding([.bottom],-5)
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: pathItem.lessonTitle))
					.modifier(lessonItemInPath())
					.onTapGesture {
						goToLesson(toCourseID: pathItem.courseID, toLessonID: pathItem.lessonID)
					}
			}
			.background {
				RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("BadgeWatchLearn"))}
		} else {
			Text(scorewindData.replaceCommonHTMLNumber(htmlString: pathItem.lessonTitle))
				.modifier(lessonItemInPath())
				.onTapGesture {
					goToLesson(toCourseID: pathItem.courseID, toLessonID: pathItem.lessonID)
				}
		}
	}
	
	struct lessonItemInPath: ViewModifier {
		func body(content: Content) -> some View {
			content
				.foregroundColor(Color("LessonListStatusIcon"))
				.frame(maxWidth: .infinity, minHeight: 100)
				.padding([.leading, .trailing], 15)
				.background(Color("WizardRangeItemBackground"))
				.cornerRadius(25)
		}
	}

	private func goToLesson(toCourseID: Int, toLessonID: Int) {
		let theCourse = scorewindData.allCourses.first(where: {$0.id == toCourseID}) ?? Course()
		let theLesson = theCourse.lessons.first(where: {$0.id == toLessonID}) ?? Lesson()
		
		if theLesson.id > 0 {
			scorewindData.currentCourse = theCourse
			
			scorewindData.currentLesson = theLesson
			scorewindData.setCurrentTimestampRecs()
			scorewindData.lastPlaybackTime = 0.0
			self.selectedTab = "TLesson"
			scorewindData.lessonChanged = true
		}
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

struct WizardResultPathView_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardResult
	@State static var wizardResult: WizardResult = WizardResult()
	
	static var previews: some View {
		WizardResultPathView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

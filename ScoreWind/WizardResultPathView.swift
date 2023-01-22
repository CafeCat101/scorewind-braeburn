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
				
				if pathItem.lesson.id != studentData.wizardResult.learningPath[studentData.wizardResult.learningPath.count - 1].lesson.id {
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
			Text("Course: \(scorewindData.replaceCommonHTMLNumber(htmlString: pathItem.course.title))")
				.foregroundColor(Color("LessonSheet"))
				.frame(maxWidth: .infinity, minHeight: 60)
				.padding([.leading, .trailing], 15)
				.background(Color("BadgeWatchLearn"))
				.cornerRadius(25)
		}
		
		if startHere {
			VStack {
				Label(title: {
					Text("Start here")
					.bold()
					.foregroundColor(Color("LessonSheet"))
				}, icon: {
						Image(systemName: "paperplane.circle")
						.foregroundColor(Color("LessonSheet"))
				}).padding([.bottom],-5)
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: pathItem.lesson.title))
					.modifier(lessonItemInPath())
					.onTapGesture {
						goToLesson(toCourse: pathItem.course, toLesson: pathItem.lesson)
					}
				/*Label("Start here", systemImage:"paperplane.circle")
				 .foregroundColor(Color("LessonSheet"))*/
			}
			.background {
				RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("BadgeWatchLearn"))}
		} else {
			Text(scorewindData.replaceCommonHTMLNumber(htmlString: pathItem.lesson.title))
				.modifier(lessonItemInPath())
				.onTapGesture {
					goToLesson(toCourse: pathItem.course, toLesson: pathItem.lesson)
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

	private func goToLesson(toCourse: Course, toLesson: Lesson) {
		if toLesson.id > 0 {
			scorewindData.currentCourse = toCourse
			
			scorewindData.currentLesson = toLesson
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
	@State static var wizardResult: WizardResult = WizardResult(getAllCourses: [], getAllTimestamps: [])
	
	static var previews: some View {
		WizardResultPathView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

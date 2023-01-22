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
	var thisLearningPath:[WizardLearningPathItem] = []
	var body: some View {
		
		ForEach(thisLearningPath) { pathItem in
			pathItemView(pathItem: pathItem, startHere: pathItem.startHere)
			
			if pathItem.lesson.id != thisLearningPath[thisLearningPath.count - 1].lesson.id {
				HStack {
					Spacer()
					Label("Next", systemImage: "arrow.down")
						.labelStyle(.iconOnly)
					Spacer()
				}
			}
		}
	}
	
	@ViewBuilder
	private func pathItemView(pathItem: WizardLearningPathItem, startHere: Bool) -> some View {
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
					.foregroundColor(Color("LessonListStatusIcon"))
					.frame(maxWidth: .infinity, minHeight: 100)
					.padding([.leading, .trailing], 15)
					.background(Color("WizardRangeItemBackground"))
					.cornerRadius(25)
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
				.foregroundColor(Color("LessonListStatusIcon"))
				.frame(maxWidth: .infinity, minHeight: 100)
				.padding([.leading, .trailing], 15)
				.background(Color("WizardRangeItemBackground"))
				.cornerRadius(25)
				.onTapGesture {
					goToLesson(toCourse: pathItem.course, toLesson: pathItem.lesson)
				}
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
}

struct WizardResultPathView_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardResult
	
	static var previews: some View {
		WizardResultPathView(selectedTab: $tab, stepName: $step, studentData: StudentData(), thisLearningPath: []).environmentObject(ScorewindData())
	}
}

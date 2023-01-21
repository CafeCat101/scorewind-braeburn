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
		
		ForEach(studentData.wizardRange) { rangeItem in
			if rangeItem.lessonID == studentData.wizardRange[0].lessonID {
				
				pathItem(rangeItem: rangeItem, startHere: true)
			} else {
				pathItem(rangeItem: rangeItem, startHere: false)
			}
			
			if rangeItem.lessonID != studentData.wizardRange[studentData.wizardRange.count - 1].lessonID {
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
	private func pathItem(rangeItem: WizardPicked,startHere: Bool) -> some View {
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
				Text("\(getLessonTitle(courseID:rangeItem.courseID, lessonID:rangeItem.lessonID))")
					.foregroundColor(Color("LessonListStatusIcon"))
					.frame(maxWidth: .infinity, minHeight: 100)
					.padding([.leading, .trailing], 15)
					.background(Color("WizardRangeItemBackground"))
					.cornerRadius(25)
					.onTapGesture {
						goToLesson(courseID:rangeItem.courseID, lessonID: rangeItem.lessonID)
					}
				/*Label("Start here", systemImage:"paperplane.circle")
				 .foregroundColor(Color("LessonSheet"))*/
			}
			.background {
				RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("BadgeWatchLearn"))}
		} else {
			Text("\(getLessonTitle(courseID:rangeItem.courseID, lessonID:rangeItem.lessonID))")
				.foregroundColor(Color("LessonListStatusIcon"))
				.frame(maxWidth: .infinity, minHeight: 100)
				.padding([.leading, .trailing], 15)
				.background(Color("WizardRangeItemBackground"))
				.cornerRadius(25)
				.onTapGesture {
					goToLesson(courseID:rangeItem.courseID, lessonID: rangeItem.lessonID)
				}
		}
	}
	
	private func getLessonTitle(courseID:Int, lessonID: Int) -> String {
		var title = "Lesson Title"
		
		let course:Course = scorewindData.allCourses.first(where: {$0.id == courseID}) ?? Course()
		let lesson:Lesson = course.lessons.first(where: {$0.id == lessonID}) ?? Lesson()
		if lesson.id > 0 {
			title = scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title)
		}
		return title
	}

	private func goToLesson(courseID:Int, lessonID: Int) {
		let course:Course = scorewindData.allCourses.first(where: {$0.id == courseID}) ?? Course()
		let lesson:Lesson = course.lessons.first(where: {$0.id == lessonID}) ?? Lesson()
		if lesson.id > 0 {
			scorewindData.currentCourse = course
			
			scorewindData.currentLesson = lesson
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
		WizardResultPathView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

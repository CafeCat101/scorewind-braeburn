//
//  CourseLessonListItemView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/1.
//

import SwiftUI

struct CourseLessonListItemView: View {
	@Binding var selectedTab:String
	var lesson:Lesson
	@EnvironmentObject var scorewindData:ScorewindData
	@ObservedObject var downloadManager:DownloadManager
	@ObservedObject var studentData:StudentData
	
	var body: some View {
		VStack {
			HStack {
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title))
					.multilineTextAlignment(.leading)
					.foregroundColor(.black)
					.onTapGesture {
						scorewindData.currentLesson = lesson
						scorewindData.setCurrentTimestampRecs()
						scorewindData.lastPlaybackTime = 0.0
						self.selectedTab = "TLesson"
						scorewindData.lessonChanged = true
					}
				Spacer()
				downloadIconView(getLessonID: lesson.id)
					.foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
				
				lessonIsons(scorewindID: lesson.scorewindID)
			}
			Spacer()
				.frame(height:10)
		}
	}
	
	@ViewBuilder
	private func downloadIconView(getLessonID: Int) -> some View {
		let getStatus =  downloadManager.checkDownloadStatus(lessonID: getLessonID)
		if getStatus == DownloadStatus.inQueue.rawValue {
			Image(systemName: "arrow.down.to.line.compact")
				.foregroundColor(Color("LessonListStatusIcon"))
		} else if getStatus == DownloadStatus.downloading.rawValue {
			Image(systemName: "arrow.down.circle")
				.foregroundColor(Color("LessonListStatusIcon"))
		} else if getStatus == DownloadStatus.downloaded.rawValue {
			Image(systemName: "arrow.down.circle.fill")
				.foregroundColor(Color("LessonListStatusIcon"))
		} else if getStatus == DownloadStatus.failed.rawValue {
			Image(systemName: "exclamationmark.circle.fill")
				.foregroundColor(Color("LessonListStatusIcon"))
		}
	}
	
	@ViewBuilder
	private func lessonIsons(scorewindID:Int) -> some View {
		let completedLessons = studentData.getCompletedLessons(courseID: scorewindData.currentCourse.id)
		if completedLessons.contains(scorewindID) {
			Label("completed", systemImage: "checkmark.circle.fill")
				.labelStyle(.iconOnly)
				.foregroundColor(Color("LessonListStatusIcon"))
		}
		
		let watchedLessons = studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id)
		if watchedLessons.contains(scorewindID) {
			Label("watched", systemImage: "eye.circle.fill")
				.labelStyle(.iconOnly)
				.foregroundColor(Color("LessonListStatusIcon"))
		}
	}
	
}

struct CourseLessonListItemView_Previews: PreviewProvider {
	@State static var tab = "TCourse"
	static var previews: some View {
		CourseLessonListItemView(selectedTab:$tab, lesson: Lesson(), downloadManager: DownloadManager(), studentData: StudentData()).environmentObject(ScorewindData())
	}
}

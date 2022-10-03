//
//  MyCouseItemview.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/1.
//

import SwiftUI

struct MyCouseItemview: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	var aCourse:MyCourse
	@ObservedObject var downloadManager:DownloadManager
	@ObservedObject var studentData:StudentData
	
	var body: some View {
		VStack {
			HStack {
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: aCourse.courseTitle))
					.font(.headline)
					.multilineTextAlignment(.leading)
					.foregroundColor(getColorHere(colorFor: "MyCourseItemText", courseID: aCourse.courseID))
				Spacer()
			}
			.padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))
			
			HStack {
				if aCourse.completedLessons.count>0 {
					courseProgressView(myCourse: aCourse)
					Spacer()
						.frame(width:20)
				}
				
				if aCourse.watchedLessons.count>0 {
					Label("\(aCourse.watchedLessons.count)", systemImage: "eye.circle.fill")
						.labelStyle(.titleAndIcon)
						.foregroundColor(getColorHere(colorFor: "MyCourseItemText", courseID: aCourse.courseID))
					Spacer()
						.frame(width:20)
				}
				
				if downloadManager.checkDownloadStatus(courseID: aCourse.courseID, lessonsCount: getLessonCount(courseID: aCourse.courseID)) == DownloadStatus.downloaded {
					Label("Downloaded", systemImage: "arrow.down.circle.fill")
						.labelStyle(.iconOnly)
						.foregroundColor(getColorHere(colorFor: "MyCourseItemText", courseID: aCourse.courseID))
					Spacer()
						.frame(width:20)
				}
				
				if aCourse.isFavourite {
					Label("favourite", systemImage: "heart.circle.fill")
						.labelStyle(.iconOnly)
						.foregroundColor(getColorHere(colorFor: "MyCourseItemText", courseID: aCourse.courseID))
					Spacer()
						.frame(width:20)
				}
				
				Spacer()
			}
			.padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
			
			if aCourse.completedLessons.count > 0 || aCourse.watchedLessons.count > 0 {
				HStack() {
					lastCompletedWatchedTime(courseID: aCourse.courseID)
					Spacer()
				}.padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
			}
			
		}
		.background{
			RoundedRectangle(cornerRadius: 10)
				.foregroundColor(getColorHere(colorFor: "MyCourseItem", courseID: aCourse.courseID))
		}
		.onTapGesture(perform: {
			scorewindData.currentCourse = scorewindData.allCourses.first(where: {$0.id == aCourse.courseID}) ?? Course()
			scorewindData.currentView = Page.course
			self.selectedTab = "TCourse"
			if aCourse.completedLessons.count > 0 || aCourse.watchedLessons.count > 0 {
				let dateCollections:[Date:String] = getDateCollectionsFromAllStatus(courseID: aCourse.courseID)
				let lastUpdatedItemValue = (dateCollections.sorted(by: {$0.key > $1.key})[0].value).split(separator:"/")
				let courseLessons = scorewindData.allCourses.first(where: {$0.id == aCourse.courseID})?.lessons
				let latestUpdatedLessonIndex = courseLessons?.firstIndex(where: {$0.scorewindID == Int(lastUpdatedItemValue[1])}) ?? 0
				scorewindData.currentLesson = scorewindData.currentCourse.lessons[latestUpdatedLessonIndex]
			} else {
				scorewindData.currentLesson = scorewindData.currentCourse.lessons[0]
			}
			
			scorewindData.setCurrentTimestampRecs()
			//scorewindData.lastViewAtScore = true
			scorewindData.lastPlaybackTime = 0.0
			scorewindData.lessonChanged = true
		})
	}
	
	@ViewBuilder
	private func courseProgressView(myCourse:MyCourse) -> some View {
		let findCourseInAll = scorewindData.allCourses.first(where: {$0.id == myCourse.courseID}) ?? Course()
		if findCourseInAll.id > 0 {
			if myCourse.completedLessons.count > 0 {
				Label("\(myCourse.completedLessons.count)/\(findCourseInAll.lessons.count) lessons", systemImage: "checkmark.circle.fill")
					.labelStyle(.titleAndIcon)
					.foregroundColor(myCourse.courseID == scorewindData.currentCourse.id ? Color("MyCourseItemTextHighlited") : Color("MyCourseItemText"))
			}
		}
	}
	
	@ViewBuilder
	private func lastCompletedWatchedTime(courseID: Int) -> some View {
		let dateCollections:[Date:String] = getDateCollectionsFromAllStatus(courseID: courseID)
		let lastUpdatedItemValue = (dateCollections.sorted(by: {$0.key > $1.key})[0].value).split(separator:"/")
		let courseLessons = scorewindData.allCourses.first(where: {$0.id == courseID})?.lessons
		let latestUpdatedLesson = courseLessons?.first(where: {$0.scorewindID == Int(lastUpdatedItemValue[1])}) ?? Lesson()
		
		VStack(alignment:.leading) {
			Text("\(String(describing: scorewindData.replaceCommonHTMLNumber(htmlString: latestUpdatedLesson.title)))")
				.foregroundColor(courseID == scorewindData.currentCourse.id ? Color("MyCourseItemTextHighlited") : Color("MyCourseItemText"))
			Text("\(String(lastUpdatedItemValue[0])) \(getFriendlyDateTimeDiff(targetDateTime: dateCollections.sorted(by: {$0.key > $1.key})[0].key))").foregroundColor(courseID == scorewindData.currentCourse.id ? Color("FriednlyTimeDiffText") : .gray)
		}
	}
	
	private func getColorHere(colorFor: String, courseID:Int) -> Color {
		if colorFor == "MyCourseItemText" {
			if courseID == scorewindData.currentCourse.id {
				return Color("MyCourseItemTextHighlited")
			} else {
				return Color("MyCourseItemText")
			}
		} else if colorFor == "MyCourseItem" {
			if courseID == scorewindData.currentCourse.id {
				return Color("AppYellow")
			} else {
				return Color("MyCourseItem")
			}
		} else {
			return .black
		}
	}
	
	private func getDateCollectionsFromAllStatus(courseID: Int) -> [Date:String] {
		var dateCollections:[Date:String] = [:]
		
		let allCompletedLessons = studentData.getCompletedLessons().filter({
			($0.value as! String).contains(String(courseID)+"/")
		})
		let allWatchedLessons = studentData.getWatchedLessons().filter({
			($0.value as! String).contains(String(courseID)+"/")
		})
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		
		for lesson in allWatchedLessons {
			let stringToDate = dateFormatter.date(from: (lesson.value as! String).replacingOccurrences(of: String(courseID)+"/", with: "")) ?? Date()
			dateCollections.updateValue("Watched/\(lesson.key)", forKey: stringToDate )
		}
		
		for lesson in allCompletedLessons {
			let stringToDate = dateFormatter.date(from: (lesson.value as! String).replacingOccurrences(of: String(courseID)+"/", with: "")) ?? Date()
			dateCollections.updateValue("Completed/\(lesson.key)", forKey: stringToDate )
		}
		
		return dateCollections
	}
	
	private func getFriendlyDateTimeDiff(targetDateTime: Date) -> String {
		var  printTime = ""
		let today = Date()
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		
		let calculateSecondsDiff = Calendar.current.dateComponents([.second], from: targetDateTime, to: today).second ?? 0
		let byMinute = calculateSecondsDiff/60
		let byHour = calculateSecondsDiff/3600
		let byDay = calculateSecondsDiff/86400
		let byWeek = calculateSecondsDiff/604800
		let byMonth = calculateSecondsDiff/2419200
		
		if calculateSecondsDiff < 60 {
			if calculateSecondsDiff == 0 {
				printTime = "just yet"
			} else if calculateSecondsDiff == 1 {
				printTime = "\(calculateSecondsDiff) second ago"
			} else {
				printTime = "\(calculateSecondsDiff) seconds ago"
			}
		} else if byMinute < 60 {
			if byMinute < 5 {
				printTime = "few minutes ago"
			} else{
				printTime = "\(byMinute) minutes ago"
			}
		} else if byHour < 24 {
			if byHour == 1 {
				printTime = "an hour ago"
			} else {
				printTime = "\(byHour) hours ago"
			}
		}else if byDay < 7 {
			if byDay == 1 {
				printTime = "a day ago"
			} else {
				printTime = "\(byDay) days ago"
			}
		} else if byWeek < 5 {
			if byWeek == 1 {
				printTime = "a week ago"
			} else {
				printTime = "\(byWeek) weeks ago"
			}
		} else if byMonth < 3 {
			if byMonth == 1 {
				printTime = "one month ago"
			} else {
				printTime = "\(byMonth) months ago"
			}
		} else {
			let dateFormatter2 = DateFormatter()
			dateFormatter2.dateStyle = .medium
			dateFormatter2.timeStyle = .none
			dateFormatter2.locale = Locale(identifier: "en_US")
			printTime = "on \(dateFormatter2.string(from: targetDateTime))"
		}
		
		return printTime
	}
	
	private func getLessonCount(courseID: Int) -> Int {
		let findCourse = scorewindData.allCourses.first(where: {$0.id == courseID}) ?? Course()
		return findCourse.lessons.count
	}
}

struct MyCouseItemview_Previews: PreviewProvider {
	@State static var tab = "TMyCourses"
	static var previews: some View {
		MyCouseItemview(selectedTab:$tab, aCourse: MyCourse(), downloadManager: DownloadManager(), studentData: StudentData()).environmentObject(ScorewindData())
	}
}

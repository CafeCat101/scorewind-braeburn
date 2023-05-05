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
	@Environment(\.verticalSizeClass) var verticalSize
	
	var body: some View {
		/*if aCourse.courseID == scorewindData.currentCourse.id {
			HStack {
				HStack {
					HStack {
						VStack {
							Image(getIconTitleName())
								.resizable()
								.scaledToFit()
								.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
						}
						.frame(maxHeight: 33)
						Text("Currently")
							.bold()
							.foregroundColor(Color("Dynamic/DarkPurple"))
							.font(.headline)
							.frame(maxHeight: 33)
						Spacer()
					}
					.padding(EdgeInsets(top: 10, leading: 0, bottom: 33, trailing: 0))
				}
				.padding(.leading, 15)
				.frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width*0.7 : (UIScreen.main.bounds.size.width*0.7)*0.5)
				.background(
					RoundedCornersShape(corners: verticalSize == .regular ? [.topRight, .bottomRight] : [.allCorners], radius: 17)
						.fill(Color("Dynamic/MainBrown"))
						.opacity(0.25)
				)
				.offset(x: -15)
				Spacer()
			}
		}*/
		
		
		VStack(spacing: 0) {
			if aCourse.courseID == scorewindData.currentCourse.id {
				HStack {
					HStack {
						HStack {
							VStack {
								Image(getIconTitleName())
									.resizable()
									.scaledToFit()
									.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
							}
							.frame(maxHeight: 24)
							Text("Currently")
								.bold()
								.foregroundColor(Color("Dynamic/DarkPurple"))
								.font(.subheadline)
								.frame(maxHeight: 24)
						}
						.padding(EdgeInsets(top: 10, leading: 22, bottom: 8, trailing: 31))
					}
					.background(
						RoundedCornersShape(corners: [.allCorners], radius: 17)
							.fill(Color("Dynamic/MainBrown"))
							.opacity(0.25)
					)
					.padding(EdgeInsets(top: 15, leading: 17, bottom: 0, trailing: 0))
					Spacer()
				}
			}
			HStack {
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: aCourse.courseTitle))
					.bold()
					.multilineTextAlignment(.leading)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
				Spacer()
			}
			.padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
			
			HStack {
				if aCourse.completedLessons.count>0 {
					courseProgressView(myCourse: aCourse)
					Spacer()
						.frame(width:20)
				}
				
				if aCourse.watchedLessons.count>0 {
					Label("\(aCourse.watchedLessons.count)", systemImage: "eye.circle.fill")
						.labelStyle(.titleAndIcon)
						.foregroundColor(Color("Dynamic/MainGreen"))
					Spacer()
						.frame(width:20)
				}
				
				/*if downloadManager.checkDownloadStatus(courseID: aCourse.courseID, lessonsCount: getLessonCount(courseID: aCourse.courseID)) == DownloadStatus.downloaded {
					Label("Downloaded", systemImage: "arrow.down.circle.fill")
						.labelStyle(.iconOnly)
						.foregroundColor(getColorHere(colorFor: "MyCourseItemText", courseID: aCourse.courseID))
					Spacer()
						.frame(width:20)
				}*/
				if getCourseDownloadStatusIcon(courseID: aCourse.courseID).isEmpty == false {
					//print("myString \(myString)")
					Label("Downloaded", systemImage: getCourseDownloadStatusIcon(courseID: aCourse.courseID))
						.labelStyle(.iconOnly)
						.foregroundColor(Color("Dynamic/MainGreen"))
					Spacer()
						.frame(width:20)
				}
				
				if aCourse.isFavourite {
					Label("favourite", systemImage: "heart.circle.fill")
						.labelStyle(.iconOnly)
						.foregroundColor(Color("Dynamic/MainGreen"))
					Spacer()
						.frame(width:20)
				}
				
				Spacer()
			}
			.padding(EdgeInsets(top: 5, leading: 16, bottom: 0, trailing: 16))
			
			Divider()
				.padding([.top,.bottom], 10)
			
			if aCourse.completedLessons.count > 0 || aCourse.watchedLessons.count > 0  || aCourse.isFavourite{
				HStack() {
					Label("Go to course", systemImage: "arrow.left.circle.fill")
						.labelStyle(.iconOnly)
					  .font(.title2)
						.foregroundColor(Color("Dynamic/MainGreen"))
					lastCompletedWatchedTime(courseID: aCourse.courseID)
					Spacer()
				}
				.padding(EdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16))
			}
			//Text("\(aCourse.courseID):\(testDateToString(getDate:aCourse.lastUpdatedDate))")
		}
		//.frame(minHeight: 86)
		.background(
			RoundedCornersShape(corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 17)
				.fill(aCourse.courseID == scorewindData.currentCourse.id ? Color("Dynamic/LightGreen") : Color("Dynamic/LightGray"))
				.opacity(0.85)
				.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
		)
		//.padding(.top, aCourse.courseID == scorewindData.currentCourse.id ? -33 : 0)
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
	
	private func getIconTitleName() -> String {
		if scorewindData.currentCourse.instrument == InstrumentType.guitar.rawValue {
			return "iconGuitar"
		} else {
			return "iconViolin"
		}
	}
	
	@ViewBuilder
	private func courseProgressView(myCourse:MyCourse) -> some View {
		let findCourseInAll = scorewindData.allCourses.first(where: {$0.id == myCourse.courseID}) ?? Course()
		if findCourseInAll.id > 0 {
			if myCourse.completedLessons.count > 0 {
				Label(title: {
					Text("\(myCourse.completedLessons.count)/\(findCourseInAll.lessons.count) lessons")
						.foregroundColor(Color("Dynamic/MainBrown+6"))
				}, icon: {
					Image(systemName: "checkmark.circle.fill")
						.foregroundColor(Color("Dynamic/MainGreen"))
				})
				.labelStyle(.titleAndIcon)
			}
		}
	}

	private func getCourseDownloadStatusIcon(courseID: Int) -> String {
		let getStatus = downloadManager.checkDownloadStatus(courseID: courseID, lessonsCount: getLessonCount(courseID: courseID))
		if getStatus == DownloadStatus.inQueue {
			return "arrow.down.to.line.compact"
		} else if getStatus == DownloadStatus.downloading {
			return "arrow.down.circle"
		} else if getStatus == DownloadStatus.downloaded {
			return "arrow.down.circle.fill"
		} else if getStatus == DownloadStatus.failed {
			return "exclamationmark.circle.fill"
		} else{
			return ""
		}
		
	}
	
	@ViewBuilder
	private func lastCompletedWatchedTime(courseID: Int) -> some View {
		let theCourse: Course = scorewindData.allCourses.first(where: {$0.id == courseID}) ?? Course()
		let dateCollections:[Date:String] = getDateCollectionsFromAllStatus(courseID: courseID)
		let lastUpdatedItemValue = (dateCollections.sorted(by: {$0.key > $1.key})[0].value).split(separator:"/")
		let courseLessons = scorewindData.allCourses.first(where: {$0.id == courseID})?.lessons
		let latestUpdatedLesson = courseLessons?.first(where: {$0.scorewindID == Int(lastUpdatedItemValue[1])}) ?? Lesson()
		
		VStack(alignment:.leading, spacing:0) {
			if latestUpdatedLesson.id > 0 {
				/*Text(scorewindData.arrangedTitle(title: latestUpdatedLesson.title, instrumentType: theCourse.instrument))
					.foregroundColor(courseID == scorewindData.currentCourse.id ? Color("Dynamic/MainBrown+6") : Color("Dynamic/MainBrown+6"))*/
				if scorewindData.arrangedTitle(title: latestUpdatedLesson.title, instrumentType: theCourse.instrument).count > 1 {
					(Text(scorewindData.arrangedTitle(title: latestUpdatedLesson.title, instrumentType: theCourse.instrument)[0]).font(.caption) + Text("\n") + Text(scorewindData.arrangedTitle(title: latestUpdatedLesson.title, instrumentType: theCourse.instrument)[1]).bold() ).foregroundColor(Color("Dynamic/MainBrown+6"))
				} else {
					Text(scorewindData.arrangedTitle(title: latestUpdatedLesson.title, instrumentType: theCourse.instrument)[0])
						.bold()
						.foregroundColor(Color("Dynamic/MainBrown+6"))
				}
				
			}
			Text("\(String(lastUpdatedItemValue[0])) \(getFriendlyDateTimeDiff(targetDateTime: dateCollections.sorted(by: {$0.key > $1.key})[0].key))").foregroundColor(courseID == scorewindData.currentCourse.id ? Color("Dynamic/IconHighlighted") : .gray)
				.font(.subheadline)
				.padding(.top, 5)
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
		
		let findInMyCourse = studentData.myCourses.first(where: {$0.courseID == courseID}) ?? MyCourse()
		 
		
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
		
		if findInMyCourse.isFavourite {
			dateCollections.updateValue("Favourited/-1", forKey: findInMyCourse.favouritedDate)
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
	
	private func testDateToString(getDate: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		return dateFormatter.string(from: getDate)
	}
}

struct MyCouseItemview_Previews: PreviewProvider {
	@State static var tab = "TMyCourses"
	static var previews: some View {
		MyCouseItemview(selectedTab:$tab, aCourse: MyCourse(), downloadManager: DownloadManager(), studentData: StudentData()).environmentObject(ScorewindData())
	}
}

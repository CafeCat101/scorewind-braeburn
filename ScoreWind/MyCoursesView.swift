//
//  MyCoursesView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct MyCoursesView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@ObservedObject var downloadManager:DownloadManager
	//@State private var getMyCourses:[MyCourse] = []
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var showTip = false
	@State private var saveLastUpdatedLesson:[Int:Lesson] = [:]
	@ObservedObject var studentData:StudentData
	
	var body: some View {
		VStack {
			Label("My Courses", systemImage: "music.note")
				.labelStyle(.titleAndIcon)
			/*HStack {
				Label("By last completed or watched", systemImage: "arrow.up.arrow.down")
					.labelStyle(.titleAndIcon)
				Spacer()
			}.padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))*/
			
			//::FILTER TAGS::
			HStack {
				Label("Favourite", systemImage: "suit.heart")
					.labelStyle(.titleOnly)
					.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
					.background {
						RoundedRectangle(cornerRadius: 20)
							.stroke(Color("MyCourseFilterTagBorder"), lineWidth: 1)
							.background(RoundedRectangle(cornerRadius: 20).fill(Color("MyCourseItem")))
					}
					.foregroundColor(Color("MyCourseItemText"))
					.onTapGesture {
						
					}
				Label("Downloaded", systemImage: "arrow.down.circle.fill")
					.labelStyle(.titleOnly)
					.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
					.background {
						RoundedRectangle(cornerRadius: 20)
							.stroke(Color("MyCourseFilterTagBorder"), lineWidth: 1)
							//.foregroundColor(Color("BadgeScoreAvailable"))
					}
					.foregroundColor(Color("MyCourseItemText"))
					.onTapGesture {
						
					}
				Spacer()
			}.padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
			
			//::MY COURSE LIST::
			ScrollViewReader { proxy in
				if studentData.myCourses.count > 0 {
					ScrollView {
						Spacer().frame(height:10)
						ForEach(studentData.myCourses) { aCourse in
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
									}
									
									if aCourse.watchedLessons.count>0 {
										Label("\(aCourse.watchedLessons.count)", systemImage: "eye.circle.fill")
											.labelStyle(.titleAndIcon)
											.foregroundColor(getColorHere(colorFor: "MyCourseItemText", courseID: aCourse.courseID))
									}
									
									if downloadManager.checkDownloadStatus(courseID: aCourse.courseID, lessonsCount: getLessonCount(courseID: aCourse.courseID)) == DownloadStatus.downloaded {
										Text("*")
									}
									
									Spacer()
								}
								.padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
								
								HStack() {
									lastCompletedWatchedTime(courseID: aCourse.courseID)
									Spacer()
								}.padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
							}
							.id(aCourse.courseID)
							.background{
								RoundedRectangle(cornerRadius: 10)
									.foregroundColor(getColorHere(colorFor: "MyCourseItem", courseID: aCourse.courseID))
							}
							.padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
							.onTapGesture(perform: {
								scorewindData.currentCourse = scorewindData.allCourses.first(where: {$0.id == aCourse.courseID}) ?? Course()
								scorewindData.currentView = Page.course
								self.selectedTab = "TCourse"
								
								let dateCollections:[Date:String] = getDateCollectionsFromAllStatus(courseID: aCourse.courseID)
								let lastUpdatedItemValue = (dateCollections.sorted(by: {$0.key > $1.key})[0].value).split(separator:"/")
								let courseLessons = scorewindData.allCourses.first(where: {$0.id == aCourse.courseID})?.lessons
								let latestUpdatedLessonIndex = courseLessons?.firstIndex(where: {$0.scorewindID == Int(lastUpdatedItemValue[1])}) ?? 0
								scorewindData.currentLesson = scorewindData.currentCourse.lessons[latestUpdatedLessonIndex]
								scorewindData.setCurrentTimestampRecs()
								//scorewindData.lastViewAtScore = true
								scorewindData.lastPlaybackTime = 0.0
								scorewindData.lessonChanged = true
							})
						}
					}
					.onAppear(perform: {
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
							if studentData.myCourses.firstIndex(where: {$0.courseID == scorewindData.currentCourse.id}) ?? -1 > -1 {
								print("[debug] MyCourseView, scrollView onAppear, currentCourse.id is found")
								withAnimation {
									proxy.scrollTo(scorewindData.currentCourse.id, anchor: .top)
								}
								
							}
						}
					})
					
					
				} else {
					Spacer()
					Text("After you've completed or watched a lesson, you can find the course for it here.")
						.padding(15)
					Spacer()
				}
			}
			Spacer()
		}
		.onAppear(perform: {
			print("[debug] MyCourseView, onAppear")
			
			//DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				//withAnimation {
					//studentData.myCourses = scorewindData.studentData.myCourses
					//print("[debug] MyCourseView, getMyCourses.count \(studentData.myCourses.count)")
				//}
				
			//}
			
			if scorewindData.getTipCount(tipType: .myCourseView) < 1 {
				scorewindData.currentTip = .myCourseView
				showTip = true
			}
		})
		.fullScreenCover(isPresented: $showTip, content: {
			TipModalView()
		})
	}
	
	private func getLessonCount(courseID: Int) -> Int {
		let findCourse = scorewindData.allCourses.first(where: {$0.id == courseID}) ?? Course()
		return findCourse.lessons.count
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
	
	private func getDateCollectionsFromAllStatus(courseID: Int) -> [Date:String] {
		let allCompletedLessons = studentData.getCompletedLessons().filter({
			($0.value as! String).contains(String(courseID)+"/")
		})
		let allWatchedLessons = studentData.getWatchedLessons().filter({
			($0.value as! String).contains(String(courseID)+"/")
		})
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		
		var dateCollections:[Date:String] = [:]
		
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
	
	private func getFriendlyTimeDiff(StartWord:String, lessoniCloudValue:[String:Any], courseID:Int) -> String {
		var  printTime = ""
		let today = Date()
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		
		var allSecondDiff:[Int] = []
		var allDates:[Date] = []
		for lesson in lessoniCloudValue {
			let completedDate = dateFormatter.date(from: (lesson.value as! String).replacingOccurrences(of: String(courseID)+"/", with: ""))!
			let calculateSecondsDiff = Calendar.current.dateComponents([.second], from: completedDate, to: today).second ?? 0
			allSecondDiff.append(calculateSecondsDiff)
			allDates.append(completedDate)
		}
		allDates = allDates.sorted(by: {$0 < $1})
		//print("[debug] MyCourseView, lastCompletedWatchedTime(courseID:\(courseID), allSecondDiff \(allSecondDiff)")
		allSecondDiff = allSecondDiff.sorted(by: {$0 < $1})
		//print("[debug] MyCourseView, lastCompletedWatchedTime(courseID:\(courseID), allSecondDiff.sorted \(allSecondDiff)")
		
		let byMinute = allSecondDiff[0]/60
		let byHour = allSecondDiff[0]/3600
		let byDay = allSecondDiff[0]/86400
		let byWeek = allSecondDiff[0]/604800
		let byMonth = allSecondDiff[0]/2419200
		//print("[debug] MyCourseView, lastCompletedWatchedTime(courseID:\(courseID), by sec\(allSecondDiff[0])-min\(byMinute)-hour\(byHour)-day\(byDay)-week\(byWeek)")
		
		if allSecondDiff[0] < 60 {
			if allSecondDiff[0] == 0 {
				printTime = "\(StartWord) just yet"
			} else if allSecondDiff[0] == 1 {
				printTime = "\(StartWord) \(allSecondDiff[0]) second ago"
			} else {
				printTime = "\(StartWord) \(allSecondDiff[0]) seconds ago"
			}
		} else if byMinute < 60 {
			if byMinute < 5 {
				printTime = "\(StartWord) few minutes ago"
			} else{
				printTime = "\(StartWord) \(byMinute) minutes ago"
			}
		} else if byHour < 24 {
			if byHour == 1 {
				printTime = "\(StartWord) an hour ago"
			} else {
				printTime = "\(StartWord) \(byHour) hours ago"
			}
		}else if byDay < 7 {
			if byDay == 1 {
				printTime = "\(StartWord) a day ago"
			} else {
				printTime = "\(StartWord) \(byDay) days ago"
			}
		} else if byWeek < 5 {
			if byWeek == 1 {
				printTime = "\(StartWord) a week ago"
			} else {
				printTime = "\(StartWord) \(byWeek) weeks ago"
			}
		} else if byMonth < 3 {
			if byMonth == 1 {
				printTime = "\(StartWord) one month ago"
			} else {
				printTime = "\(StartWord) \(byMonth) months ago"
			}
		} else {
			let dateFormatter2 = DateFormatter()
			dateFormatter2.dateStyle = .medium
			dateFormatter2.timeStyle = .none
			dateFormatter2.locale = Locale(identifier: "en_US")
			printTime = "\(StartWord) on \(dateFormatter2.string(from: allDates[0]))"
		}
		
		return printTime
	}
	
	private func testDateToString(getDate: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		return dateFormatter.string(from: getDate)
	}
}

struct MyCoursesView_Previews: PreviewProvider {
	@State static var tab = "TMyCourses"
	static var previews: some View {
		MyCoursesView(selectedTab:$tab, downloadManager: DownloadManager(), studentData: StudentData()).environmentObject(ScorewindData())
	}
}

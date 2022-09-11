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
	@State private var getMyCourses:[MyCourse] = []
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var showTip = false
	
	var body: some View {
		VStack {
			Label("My Courses", systemImage: "music.note")
					.labelStyle(.titleAndIcon)
			
			ScrollView {
				Spacer().frame(height:10)
				ForEach(getMyCourses) { aCourse in
					VStack {
						HStack {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: aCourse.courseTitle))
								.font(.headline)
								.multilineTextAlignment(.leading)
								.foregroundColor(Color("MyCourseItemText"))
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
									.foregroundColor(.gray)
							}
							Spacer()
						}
						.padding(EdgeInsets(top: 5, leading: 15, bottom: 0, trailing: 15))
						
						HStack {
							if aCourse.completedLessons.count == 0 {
								Text(lastCompletedWatchedTime(ask: "watched", courseID: aCourse.courseID)).foregroundColor(.gray)
							} else {
								Text(lastCompletedWatchedTime(ask: "completed", courseID: aCourse.courseID)).foregroundColor(.gray)
							}
							Spacer()
						}
						.padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
					}
					.background{
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(Color("MyCourseItem"))
					}
					.padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
					.onTapGesture(perform: {
						scorewindData.currentCourse = scorewindData.allCourses.first(where: {$0.id == aCourse.courseID}) ?? Course()
						scorewindData.currentView = Page.course
						self.selectedTab = "TCourse"
						scorewindData.currentLesson = scorewindData.currentCourse.lessons[0]
						scorewindData.setCurrentTimestampRecs()
						//scorewindData.lastViewAtScore = true
						scorewindData.lastPlaybackTime = 0.0
					})
				}
			}
			
			Spacer()
			/*if scorewindData.studentData.getInstrumentChoice() == "" {
			 Text("== no instrument choice ==")
			 }else{
			 Text(scorewindData.studentData.getInstrumentChoice())
			 }*/
			/*ForEach(scorewindData.allCourses, id: \.id) { course in
			 Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
			 }*/
			
		}
		.onAppear(perform: {
			print("[debug] MyCourseView, onAppear")
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				getMyCourses = scorewindData.studentData.myCourses(allCourses: scorewindData.allCourses)
				print("[debug] MyCourseView, getMyCourses.count \(getMyCourses.count)")
			}
			
			if scorewindData.getTipCount(tipType: .myCourseView) < 1 {
				scorewindData.currentTip = .myCourseView
				showTip = true
			}
		})
		.fullScreenCover(isPresented: $showTip, content: {
			TipModalView()
		})
	}
	
	@ViewBuilder
	private func courseProgressView(myCourse:MyCourse) -> some View {
		let findCourseInAll = scorewindData.allCourses.first(where: {$0.id == myCourse.courseID}) ?? Course()
		if findCourseInAll.id > 0 {
			if myCourse.completedLessons.count > 0 {
				Label("\(myCourse.completedLessons.count)/\(findCourseInAll.lessons.count) lessons", systemImage: "checkmark.circle.fill")
					.labelStyle(.titleAndIcon)
					.foregroundColor(.gray)
			}			
		}
	}
	
	private func lastCompletedWatchedTime(ask:String, courseID: Int) -> String {		
		if ask == "completed" {
			let allCompletedLessons = scorewindData.studentData.getCompletedLessons().filter({
				($0.value as! String).contains(String(courseID)+"/")
			})
			return getFriendlyTimeDiff(StartWord: "Completed", lessoniCloudValue: allCompletedLessons, courseID: courseID)
			
		} else if ask == "watched" {
			let allWatchedLessons = scorewindData.studentData.getWatchedLessons().filter({
				($0.value as! String).contains(String(courseID)+"/")
			})
			return getFriendlyTimeDiff(StartWord: "Watched", lessoniCloudValue: allWatchedLessons, courseID: courseID)
		} else {
			return ""
		}
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
		print("[debug] MyCourseView, lastCompletedWatchedTime(courseID:\(courseID), allSecondDiff \(allSecondDiff)")
		allSecondDiff = allSecondDiff.sorted(by: {$0 < $1})
		print("[debug] MyCourseView, lastCompletedWatchedTime(courseID:\(courseID), allSecondDiff.sorted \(allSecondDiff)")
		
		let byMinute = allSecondDiff[0]/60
		let byHour = allSecondDiff[0]/3600
		let byDay = allSecondDiff[0]/86400
		let byWeek = allSecondDiff[0]/604800
		let byMonth = allSecondDiff[0]/2419200
		print("[debug] MyCourseView, lastCompletedWatchedTime(courseID:\(courseID), by sec\(allSecondDiff[0])-min\(byMinute)-hour\(byHour)-day\(byDay)-week\(byWeek)")
		
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
}

struct MyCoursesView_Previews: PreviewProvider {
	@State static var tab = "TMyCourses"
	static var previews: some View {
		MyCoursesView(selectedTab:$tab).environmentObject(ScorewindData())
	}
}

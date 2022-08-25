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
	
	var body: some View {
		VStack {
			/*HStack {
				Spacer()
				Label("Scorewind", systemImage: "music.note")
						.labelStyle(.titleAndIcon)
				Spacer()
			}.padding().background(Color("ScreenTitleBg"))*/
			Label("My Courses", systemImage: "music.note")
					.labelStyle(.titleAndIcon)
			
			ScrollView {
				ForEach(getMyCourses) { aCourse in
					VStack {
						HStack {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: aCourse.courseTitle))
								.font(.headline)
								.multilineTextAlignment(.leading)
								.foregroundColor(.black)
							Spacer()
						}
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
						.padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 10))
					}
					.frame(width:screenSize.width*0.9)
					.padding(EdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 10))
					.background{
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(Color("MyCourseItem"))
					}
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
			.padding()
			
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
			getMyCourses = scorewindData.studentData.myCourses(allCourses: scorewindData.allCourses)
			print("[debug] MyCourseView, getMyCourses.count \(getMyCourses.count)")
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
}

struct MyCoursesView_Previews: PreviewProvider {
	@State static var tab = "TMyCourses"
	static var previews: some View {
		MyCoursesView(selectedTab:$tab).environmentObject(ScorewindData())
	}
}

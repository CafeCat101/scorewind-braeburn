//
//  WizardTeacherView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/8.
//

import SwiftUI

struct WizardTeacherView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	
	var body: some View {
		List {
			/*
			Section(header: Text("All")) {
				ForEach(scorewindData.allCourses) { course in
					Button(action: {
						scorewindData.currentCourse = course
						scorewindData.currentView = Page.course
						self.selectedTab = "TCourse"
						scorewindData.currentLesson = scorewindData.currentCourse.lessons[0]
						scorewindData.setCurrentTimestampRecs()
						//scorewindData.lastViewAtScore = true
						scorewindData.lastPlaybackTime = 0.0
					}) {
						if course.id == scorewindData.currentCourse.id {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
								.foregroundColor(Color("WizardListTextHighlight"))
						} else {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
								.foregroundColor(Color("MyCourseItemText"))
						}
						
					}
				}
			}
			 */
			Section(header: Text("Guitar - Step By Step")) {
				ForEach(guitarCourses(type: "step")) { course in
					Button(action: {
						scorewindData.currentCourse = course
						scorewindData.currentView = Page.course
						self.selectedTab = "TCourse"
						scorewindData.currentLesson = scorewindData.currentCourse.lessons[0]
						scorewindData.setCurrentTimestampRecs()
						//scorewindData.lastViewAtScore = true
						scorewindData.lastPlaybackTime = 0.0
						scorewindData.lessonChanged = true
					}) {
						if course.id == scorewindData.currentCourse.id {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
								.foregroundColor(Color("WizardListTextHighlight"))
						} else {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
								.foregroundColor(Color("MyCourseItemText"))
						}
						
					}
				}
			}
			
			Section(header: Text("Violin - Step By Step")) {
				ForEach(violinCourses(type: "step")) { course in
					Button(action: {
						scorewindData.currentCourse = course
						scorewindData.currentView = Page.course
						self.selectedTab = "TCourse"
						scorewindData.currentLesson = scorewindData.currentCourse.lessons[0]
						scorewindData.setCurrentTimestampRecs()
						//scorewindData.lastViewAtScore = true
						scorewindData.lastPlaybackTime = 0.0
						scorewindData.lessonChanged = true
					}) {
						if course.id == scorewindData.currentCourse.id {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
								.foregroundColor(Color("WizardListTextHighlight"))
						} else {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
								.foregroundColor(Color("MyCourseItemText"))
						}
						
					}
				}
			}
			
			Section(header: Text("Guitar - Path")) {
				ForEach(guitarCourses(type: "path")) { course in
					Button(action: {
						scorewindData.currentCourse = course
						scorewindData.currentView = Page.course
						self.selectedTab = "TCourse"
						scorewindData.currentLesson = scorewindData.currentCourse.lessons[0]
						scorewindData.setCurrentTimestampRecs()
						//scorewindData.lastViewAtScore = true
						scorewindData.lastPlaybackTime = 0.0
						scorewindData.lessonChanged = true
					}) {
						if course.id == scorewindData.currentCourse.id {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
								.foregroundColor(Color("WizardListTextHighlight"))
						} else {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
								.foregroundColor(Color("MyCourseItemText"))
						}
						
					}
				}
			}
			
			Section(header: Text("Violin - Path")) {
				ForEach(violinCourses(type: "path")) { course in
					Button(action: {
						scorewindData.currentCourse = course
						scorewindData.currentView = Page.course
						self.selectedTab = "TCourse"
						scorewindData.currentLesson = scorewindData.currentCourse.lessons[0]
						scorewindData.setCurrentTimestampRecs()
						//scorewindData.lastViewAtScore = true
						scorewindData.lastPlaybackTime = 0.0
						scorewindData.lessonChanged = true
					}) {
						if course.id == scorewindData.currentCourse.id {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
								.foregroundColor(Color("WizardListTextHighlight"))
						} else {
							Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
								.foregroundColor(Color("MyCourseItemText"))
						}
						
					}
				}
			}
		}
		.listStyle(GroupedListStyle())
		.background(Color("LessonListTextBg"))
	}
	
	private func guitarCourses(type: String) -> [Course] {
		var allGuitarCourses = scorewindData.allCourses.filter({$0.instrument == InstrumentType.guitar.rawValue})
		if type == "step" {
			allGuitarCourses = allGuitarCourses.filter({$0.category.contains(where: {$0.name == "Step By Step"})})
		}
		if type == "path" {
			allGuitarCourses = allGuitarCourses.filter({$0.category.contains(where: {$0.name == "Path"})})
		}
		allGuitarCourses = allGuitarCourses.sorted(by: {$0.level < $1.level})
		return allGuitarCourses
	}
	
	private func violinCourses(type: String) -> [Course] {
		var allViolinCourses = scorewindData.allCourses.filter({$0.instrument == InstrumentType.violin.rawValue})
		if type == "step" {
			allViolinCourses = allViolinCourses.filter({$0.category.contains(where: {$0.name == "Step By Step"})})
		}
		if type == "path" {
			allViolinCourses = allViolinCourses.filter({$0.category.contains(where: {$0.name == "Path"})})
		}
		allViolinCourses = allViolinCourses.sorted(by: {$0.level < $1.level})
		return allViolinCourses
	}
	
	
}

struct WizardTeacherView_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	static var previews: some View {
		WizardTeacherView(selectedTab: $tab).environmentObject(ScorewindData())
	}
}

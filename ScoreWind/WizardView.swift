//
//  WizardView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct WizardView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@State private var userRole = "student"
	@State private var stepName:WizardStep = .chooseInstrument
	
	var body: some View {
		VStack {
			Label("Scorewind", systemImage: "music.note")
				.labelStyle(.titleAndIcon)
				.contextMenu {
					Button(action: {
						userRole = "student"
					}){
						Label("I'm a student", systemImage: "face.smiling")
							.labelStyle(.titleAndIcon)
					}
					Button(action: {
						userRole = "teacher"
					}){
						Label("Teachers only", systemImage: "brain.head.profile")
							.labelStyle(.titleAndIcon)
					}
				}
			
			if userRole == "teacher" {
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
			} else {
				if stepName == .chooseInstrument {
					Spacer()
					Text("Which instrument do you want to learn?")
						.font(.headline)
					
					HStack {
						Button(action:{
							
						}){
							Circle()
								.strokeBorder(Color.black,lineWidth: 1)
								.background(Circle().foregroundColor(Color.white))
								.frame(width:100,height:100)
								.overlay(
									Image("instrument-guitar-icon")
										.resizable()
										.scaleEffect(0.6)
								)
						}
						
						Button(action:{
							
						}){
							Circle()
								.strokeBorder(Color.black,lineWidth: 1)
								.background(Circle().foregroundColor(Color.white))
								.frame(width:100,height:100)
								.overlay(
									Image("instrument-violin-icon")
										.resizable()
										.scaleEffect(0.6)
								)
						}
					}
					
					Spacer()
				}
			}
			
			
			
		}
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

struct WizardView_Previews: PreviewProvider {
	@State static var tab = "TMyCourses"
	static var previews: some View {
		Group {
			WizardView(selectedTab: $tab).environmentObject(ScorewindData())
			WizardView(selectedTab: $tab).environmentObject(ScorewindData()).environment(\.colorScheme, .dark)
		}
		
	}
}

//
//  HomeView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/13.
//

import SwiftUI

struct HomeView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State private var selectedTab = "THome"
	@ObservedObject var downloadManager: DownloadManager
	@Environment(\.scenePhase) var scenePhase
	@StateObject var studentData = StudentData()
	@State private var userDefaults = UserDefaults.standard
	@State private var showLessonView = false
	@EnvironmentObject var store:Store
	@State private var stepName:Page = .wizardChooseInstrument
	
	var body: some View {
		TabView(selection: $selectedTab) {
			WizardView(selectedTab: $selectedTab, studentData: studentData, showLessonView: $showLessonView, downloadManager: downloadManager, stepName: $stepName)
				.tabItem {
					Image(systemName: "music.note.house")
					Text("Home")
				}.tag("THome")
			
			CourseView(selectedTab: $selectedTab, downloadManager: downloadManager, studentData: studentData, showLessonView: $showLessonView)
				.tabItem {
					Image(systemName: "note.text")
					Text("Course")
				}.tag("TCourse")

			MyCoursesView(selectedTab: $selectedTab, downloadManager: downloadManager, studentData: studentData)
				.tabItem {
					Image(systemName: "music.note.list")
					Text("My Courses")
				}.tag("TMyCourses")
		}
		.accentColor(Color("Dynamic/MainGreen"))
		.ignoresSafeArea()
		.onAppear{
			//==>>>> app is launched...
			print("[debug] HomeView, onAppear")
			if downloadManager.appState == .background {
				//hide codes here so it won't be triggered when switching full lesson screen view to tab view
				print("[debug] HomeView, tabview, downloadManager.appState=background")
				setupDataObjects()
				activateDownloadVideoXML()
				studentData.updateMyCoursesDownloadStatus(allCourses: scorewindData.allCourses, downloadManager: downloadManager)
			}
			downloadManager.appState = .active
			
			//:: remember last viewed course or lesson
			let lastViewedCourseID:Int = userDefaults.object(forKey: "lastViewedCourse") as? Int ?? 0
			if lastViewedCourseID > 0 {
				scorewindData.currentCourse = scorewindData.allCourses.first(where: {$0.id == lastViewedCourseID}) ?? Course()
			}
			let lastViewedLessonID:Int = userDefaults.object(forKey: "lastViewedLesson") as? Int ?? 0
			if lastViewedLessonID > 0 {
				scorewindData.currentLesson = scorewindData.currentCourse.lessons.first(where: {$0.id == lastViewedLessonID}) ?? Lesson()
				scorewindData.setCurrentTimestampRecs()
				scorewindData.lastPlaybackTime = 0.0
			}
			
			//:: decide on which step to start before any step view is called in WizardView
			if studentData.wizardResult.learningPath.count > 0 {
				if scorewindData.wizardPickedCourse.id == 0 || scorewindData.wizardPickedLesson.id == 0 {
					let getPickedItem = studentData.wizardResult.learningPath.first(where: {$0.startHere == true}) ?? WizardLearningPathItem()
				print("[debug] WizardResultView, onAppear,  pickedCourse\(getPickedItem.courseID), pickedLesson\(getPickedItem.lessonID)")
					if getPickedItem.courseID > 0 && getPickedItem.lessonID > 0 {
						scorewindData.wizardPickedCourse = scorewindData.allCourses.first(where: {$0.id == getPickedItem.courseID}) ?? Course()
						scorewindData.wizardPickedLesson = scorewindData.wizardPickedCourse.lessons.first(where: {$0.id == getPickedItem.lessonID}) ?? Lesson()
						scorewindData.wizardPickedTimestamps = (scorewindData.allTimestamps.first(where: {$0.id == getPickedItem.courseID})?.lessons.first(where: {$0.id == getPickedItem.lessonID})!.timestamps) ?? []
					}
				}
				stepName = .wizardResult
			} else {
				stepName = .wizardChooseInstrument
			}
			//<<<<==
		}
		.onChange(of: scenePhase, perform: { newPhase in
			if newPhase == .active {
				print("[deubg] HomeView, app is active")
				if downloadManager.appState == .background {
					print("[debug] HomeView, tabview, downloadManager.appState=background")
					activateDownloadVideoXML()
					studentData.updateMyCoursesDownloadStatus(allCourses: scorewindData.allCourses, downloadManager: downloadManager)
				}
				downloadManager.appState = .active
			} else if newPhase == .inactive {
				print("[debug] HomeView, appp is inactive")
			} else if newPhase == .background {
				print("[debug] HomeView, app is in the background")
				downloadManager.appState = .background
				if (scorewindData.currentLesson.scorewindID > 0) && (scorewindData.lastPlaybackTime >= 10) {
					print("[debug] HomeView.onChange, .background lastPlayBackTime>=10")
					studentData.updateWatchedLessons(courseID: scorewindData.currentCourse.id, lessonID: scorewindData.currentLesson.scorewindID, addWatched: true)
					studentData.updateMyCourses(allCourses: scorewindData.allCourses)
					studentData.updateMyCoursesDownloadStatus(allCourses: scorewindData.allCourses, downloadManager: downloadManager)
				}
			}
		})
		.onChange(of: selectedTab, perform: { newValue in
			print("[deubg] HomeView, onChange selectedTab\(selectedTab)")
			if newValue == "TCourse" {
				/*if hasAccessToCourses() == false {
					scorewindData.currentCourse = Course()
					scorewindData.currentLesson = Lesson()
					scorewindData.currentTimestampRecs.removeAll()
				}*/
				print("[deubg] HomeView, onChange of selectedTab, TCourse")
			}
		})
		.onReceive(downloadManager.downloadTaskPublisher, perform: { clonedDownloadList in
			print("[deubg] HomeView,onRecieve, downloadTaskPublisher:\(clonedDownloadList.count)")
			
			/*for courseID in clonedDownloadList {
			 print("[debug] HomeView, onRecieve - \(courseID)")
			 }*/
			if downloadManager.compareDownloadList(downloadTargets: clonedDownloadList) == false {
				print("[deubg] HomeView, onRecieve, cloned and original are different, call downloadXMLVideo")
				Task {
					print("[debug] HomeView, onRecieve, Task:downloadVideoXML")
					do {
						try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
					} catch {
						print("[debug] HomeView, onRecieve, Task:downloadVideoXML, catch, \(error)")
					}
				}
			}
		})
		
	}
	
	private func activateDownloadVideoXML() {
		downloadManager.buildDownloadListFromJSON(allCourses: scorewindData.allCourses)
		Task {
			print("[debug] HomeView, Task:downloadVideoXML")
			do {
				try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
			} catch {
				print("[debug] HomeView, Task:downloadVideoXML, catch, \(error)")
			}
		}
	}
	
	private func setupDataObjects(){
		print("[debug] HomeView, setupDataObject()")
		scorewindData.launchSetup(syncData: false)
		scorewindData.initiateTimestampsFromLocal()
		scorewindData.initiateCoursesFromLocal()
		studentData.updateMyCourses(allCourses: scorewindData.allCourses)
		studentData.wizardResult = studentData.getWizardResult()
	}
	
	private func hasAccessToCourses() -> Bool {
		if !store.purchasedSubscriptions.isEmpty {
			return true
		} else {
			return false
		}
	}
}

struct storeViewCover: ViewModifier {
	@EnvironmentObject var store: Store
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var showStore:Bool
	@Binding var selectedTab: String
	
	func body(content: Content) -> some View {
		if !store.purchasedSubscriptions.isEmpty {
			if selectedTab == "TCourse" {
				content
			} else {
				content.sheet(isPresented: $showStore, content: {
					StoreView(showStore: $showStore)
				})
			}
		} else {
			content.sheet(isPresented: $showStore, content: {
				StoreView(showStore: $showStore)
			})
		}
	}
}
/*
struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(downloadManager: DownloadManager()).environmentObject(ScorewindData())
	}
}*/

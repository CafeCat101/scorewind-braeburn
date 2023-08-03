//
//  WizardTeacherView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/8.
//

import SwiftUI

struct WizardTeacherView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@EnvironmentObject var store: Store
	@Binding var selectedTab:String
	@ObservedObject var studentData:StudentData
	@ObservedObject var downloadManager:DownloadManager
	let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	@State private var resetAllAlert = false
	@State private var resetTipAlert = false
	@State private var userDefaults = UserDefaults.standard
	@State private var showRemoveAllDataAlrt = false
	
	var body: some View {
		VStack {
			Text("Internal Testers Only").font(.title)
			List {
				Section(header: Text("Guitar - Step By Step")) {
					ForEach(guitarCourses(type: "step")) { course in
						Button(action: {
							scorewindData.currentCourse = course
							scorewindData.currentView = Page.course
							self.selectedTab = "TCourse"
							scorewindData.currentLesson = scorewindData.currentCourse.lessons[0]
							scorewindData.setCurrentTimestampRecs()
							scorewindData.lastPlaybackTime = 0.0
							scorewindData.lessonChanged = true
						}) {
							if course.id == scorewindData.currentCourse.id {
								Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
									.foregroundColor(Color("Dynamic/Pink"))
							} else {
								Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
									.foregroundColor(Color("Dynamic/MainBrown+6"))
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
							scorewindData.lastPlaybackTime = 0.0
							scorewindData.lessonChanged = true
						}) {
							if course.id == scorewindData.currentCourse.id {
								Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
									.foregroundColor(Color("Dynamic/Pink"))
							} else {
								Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
									.foregroundColor(Color("Dynamic/MainBrown+6"))
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
									.foregroundColor(Color("Dynamic/Pink"))
							} else {
								Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
									.foregroundColor(Color("Dynamic/MainBrown+6"))
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
									.foregroundColor(Color("Dynamic/Pink"))
							} else {
								Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
									.foregroundColor(Color("Dynamic/MainBrown+6"))
							}
							
						}
					}
				}
				/*
				Section(header: Text("Reset Data")) {
					Button(action: {
						removeDataOnDevice()
						removeDataOniCloud()
						showResetDataDialog = true
					}, label: {
						Text("Remove all data").foregroundColor(Color("MyCourseItemText"))
					})
					.alert("Please restart the app now!", isPresented: $showResetDataDialog, actions: {
						Button("ok", action:{
							showResetDataDialog = false
						})
					}, message: {
						Text("Data is removed.\n\nRemember to restart the app to see the effect.")
					})
					
					Button(action: {
						studentData.removeAUserDefaultKey(keyName: "hideTips")
						showResetDataDialog = true
					}, label: {
						Text("Remove viewed tip data only").foregroundColor(Color("MyCourseItemText"))
					})
					.alert("Remove viewed tip data", isPresented: $showResetDataDialog, actions: {
						Button("ok", action:{
							showResetDataDialog = false
						})
					}, message: {
						Text("All tips are visible again now.")
					})
					
					/*Button(action: {
						removeDataOnDevice()
						showResetDataDialog = true
					}, label: {
						VStack {
							Text("Remove all data on the device").foregroundColor(Color("MyCourseItemText")).font(.headline)
							Text("To delete data about last viewed lesson, course, tips and downloaded video courses.").foregroundColor(Color("MyCourseItemText"))
						}
					})
					.alert("Please restart the app now!", isPresented: $showResetDataDialog, actions: {
						Button("ok", action:{
							showResetDataDialog = false
						})
					}, message: {
						Text("Data is removed.\n\nRemember to restart the app to see the effect.")
					})
					
					Button(action: {
						removeDataOniCloud()
						showResetDataDialog = true
					}, label: {
						VStack {
							Text("Remove all data on the cloud").foregroundColor(Color("MyCourseItemText")).font(.headline)
							Text("To delete data about favourite courses, lessons you've finished or watched.\n\nThe result of wizard will also be removed.").foregroundColor(Color("MyCourseItemText"))
						}
					})
					.alert("Please restart the app now!", isPresented: $showResetDataDialog, actions: {
						Button("ok", action:{
							showResetDataDialog = false
						})
					}, message: {
						Text("Data is removed.\n\nRemember to restart the app to see the effect.")
					})*/
				}
				 */
			}
			.listStyle(GroupedListStyle())
			.background(Color("Dynamic/LightGray"))
			.cornerRadius(17)
			.padding([.leading,.trailing], 15)
			
			Button(action: {
				showRemoveAllDataAlrt = true
			}, label: {
				Text("Remove all data")
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
					.background(
						RoundedRectangle(cornerRadius: CGFloat(17))
							.foregroundColor(Color("Dynamic/MainBrown"))
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							.opacity(0.25)
							.overlay {
								RoundedRectangle(cornerRadius: 17)
									.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
							}
					)
			})
			.padding([.top,.bottom],15)
		}
		.alert("Remove All Data", isPresented: $showRemoveAllDataAlrt, actions: {
			Button("ok", action:{
				print("[debug] My CourseView, alert ok.")
				
				removeDataOniCloud()
				removeDataOnDevice()
				
				//:: reset in memory variable
				studentData.myCourses.removeAll()
				downloadManager.downloadList.removeAll()
				
				studentData.resetWizrdChoice()
				studentData.wizardStepNames.removeAll()
				studentData.wizardRange.removeAll()
				studentData.wizardResult = WizardResult()
				scorewindData.wizardPickedCourse = Course()
				scorewindData.wizardPickedLesson = Lesson()
				scorewindData.wizardPickedTimestamps.removeAll()
				
				scorewindData.currentCourse = Course()
				scorewindData.currentLesson = Lesson()
				
				resetAllAlert = true
			})
			Button("Cancel", role:.cancel, action:{
				print("[debug] My CourseView, alert cancel.")
			})
		}, message: {
			Text("This step will remove all your data in MyCourses, History of Current Course/Lesson, Completed and Watched Lessons, Offline Course Videos, Recent Learning Path, Viewed Tips. Continuet?")
		})
		.alert("Please RESTART the app now!", isPresented: $resetAllAlert, actions: {
			Button("ok", action:{
				resetAllAlert = false
			})
		}, message: {
			Text("Data is removed.\n\nRemember to restart the app to see the effect.")
		})
		
		
		
		
		/*Button(action: {
			removeDataOniCloud()
			removeDataOnDevice()
			
			//:: reset in memory variable
			studentData.myCourses.removeAll()
			downloadManager.downloadList.removeAll()
			
			studentData.resetWizrdChoice()
			studentData.wizardStepNames.removeAll()
			studentData.wizardRange.removeAll()
			studentData.wizardResult = WizardResult()
			scorewindData.wizardPickedCourse = Course()
			scorewindData.wizardPickedLesson = Lesson()
			scorewindData.wizardPickedTimestamps.removeAll()
			
			scorewindData.currentCourse = Course()
			scorewindData.currentLesson = Lesson()
			resetAllAlert = true
		}, label: {
			Text("Remove all data")
				.foregroundColor(Color("MyCourseItemText"))
				.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
				.background(Color("MyCourseItem"))
				.cornerRadius(15)
		})
		.padding([.bottom],15)*/
		
		
		/*
		Button(action: {
			studentData.removeAUserDefaultKey(keyName: "hideTips")
			resetTipAlert = true
		}, label: {
			Text("Remove viewed tip data only").foregroundColor(Color("MyCourseItemText"))
				.foregroundColor(Color("MyCourseItemText"))
				.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
				.background(Color("MyCourseItem"))
				.cornerRadius(15)
		})
		.padding([.bottom],15)
		.alert("Remove viewed tip data", isPresented: $resetTipAlert, actions: {
			Button("ok", action:{
				resetTipAlert = false
			})
		}, message: {
			Text("All tips are visible again now.")
		})
		 */
	}
	
	private func removeDataOnDevice() {
		studentData.removeAUserDefaultKey(keyName: "lastViewedLesson")
		studentData.removeAUserDefaultKey(keyName: "lastViewedCourse")
		studentData.removeAUserDefaultKey(keyName: "hideTips")
		studentData.removeAUserDefaultKey(keyName: "wizardChooseInstrument")
		
		let courseOfflineList = userDefaults.object(forKey: "courseOffline") as? [Int] ?? []
		if courseOfflineList.count > 0 {
			var isDirectory = ObjCBool(true)
			for courseID in courseOfflineList {
				if FileManager.default.fileExists(atPath: URL(string: "course\(courseID)", relativeTo: docsUrl)!.path, isDirectory: &isDirectory) {
					do {
						try FileManager.default.removeItem(atPath: URL(string: "course\(courseID)", relativeTo: docsUrl)!.path)
					} catch {
						print("[debug] WizardTeacherView, remove course/all downloaded file, catch,\(error)")
					}
				} else {
					print("[debug] WizardTeacherView, \(URL(string: "course\(courseID)", relativeTo: docsUrl)!.path) doesn't exist.")
				}
			}
			
		}
		studentData.removeAUserDefaultKey(keyName: "courseOffline")
		studentData.removeAUserDefaultKey(keyName: "courseOfflineDate")
		studentData.removeAUserDefaultKey(keyName: "dataVersion")
		
		userDefaults.removeObject(forKey: "IsCouponValid")
		store.couponState = .notActivated
		userDefaults.removeObject(forKey: "CouponErrorCode")
		store.lastCouponErrorCode = 0
		
		for usageAction in UsageActions.allCases {
			userDefaults.removeObject(forKey: usageAction.rawValue)
		}
		
		userDefaults.removeObject(forKey: "eventLogs")
		
		//studentData.updateMyCourses(allCourses: scorewindData.allCourses)
		//studentData.updateMyCoursesDownloadStatus(allCourses: scorewindData.allCourses, downloadManager: downloadManager)
	}
	
	private func removeDataOniCloud() {
		studentData.removeAKey(keyName: "completedLessons")
		studentData.removeAKey(keyName: "watchedLessons")
		studentData.removeAKey(keyName: "favouritedCourses")
		
		studentData.removeAKey(keyName: "instrument")
		studentData.removeAKey(keyName: "experience")
		studentData.removeAKey(keyName: "doYouKnow")
		studentData.removeAKey(keyName: "playable")
		studentData.removeAKey(keyName: "wizardResult")
		
		let useriCloudKeyValueStore = NSUbiquitousKeyValueStore.default
		useriCloudKeyValueStore.removeObject(forKey: "ScoreWindCouponCode")
		useriCloudKeyValueStore.synchronize()
		
		//studentData.updateMyCourses(allCourses: scorewindData.allCourses)
		//studentData.updateMyCoursesDownloadStatus(allCourses: scorewindData.allCourses, downloadManager: downloadManager)
	}
	
	private func guitarCourses(type: String) -> [Course] {
		var allGuitarCourses = scorewindData.allCourses.filter({$0.instrument == InstrumentType.guitar.rawValue})
		if type == "step" {
			allGuitarCourses = allGuitarCourses.filter({$0.category.contains(where: {$0.name == "Step By Step"})})
		}
		if type == "path" {
			allGuitarCourses = allGuitarCourses.filter({$0.category.contains(where: {$0.name == "Path"})})
		}
		allGuitarCourses = allGuitarCourses.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
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
		allViolinCourses = allViolinCourses.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
		return allViolinCourses
	}
	
	
}

struct WizardTeacherView_Previews: PreviewProvider {
	@State static var tab = "THome"
	static var previews: some View {
		WizardTeacherView(selectedTab: $tab, studentData: StudentData(), downloadManager: DownloadManager()).environmentObject(ScorewindData())
	}
}

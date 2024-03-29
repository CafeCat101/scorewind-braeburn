//
//  StudentData.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/4/4.
//

import Foundation
import SwiftUI
import Combine


class StudentData: ObservableObject {
	@Published var myCourses:[MyCourse] = []
	private let useriCloudKeyValueStore = NSUbiquitousKeyValueStore.default
	private var userDefaults = UserDefaults.standard
	@Published var wizardStepNames:[Page] = []
	@Published var playableViewVideoOnly = true
	var wizardRange:[WizardPicked] = []
	var wizardResult:WizardResult = WizardResult()
	private var wizardInstrumentChoice: String = ""
	private var wizardExperienceChoice: String = ""
	private var wizardDoYouKnowChoice:[String:Any] = [:]
	private var wizardPlayableChoice:[String:Any] = [:]
	var userUsageTimerCount = 0
	var userUsageTimerCountTotal = 0
	private var launchUUID:UUID?
	var logVideoPlaybackTime:[String] = []
	
	/*
	 DATA FOR MY COURSES
	 */
	//track completed lessons
	func getCompletedLessons() -> [String:Any] {
		return useriCloudKeyValueStore.dictionary(forKey: "completedLessons") ?? [:]
	}
	
	func getCompletedLessons(courseID:Int)->[Int] {
		var filteredLessons:[Int] = []
		for lesson in getCompletedLessons() {
			if (lesson.value as! String).contains(String(courseID)+"/") {
				filteredLessons.append(Int(lesson.key)!)
			}
		}
		return filteredLessons
	}
	
	func updateCompletedLesson(courseID:Int, lessonID:Int, isCompleted:Bool) {
		var allLessons = getCompletedLessons()
		let now = Date()
		let nowFormatter = DateFormatter()
		nowFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		let completedString = String(courseID)+"/"+nowFormatter.string(from: now)
		
		if isCompleted {
			allLessons.updateValue(completedString, forKey: String(lessonID))
		} else{
			allLessons.removeValue(forKey: String(lessonID))
		}
		
		useriCloudKeyValueStore.set(allLessons,forKey: "completedLessons")
		useriCloudKeyValueStore.synchronize()
	}
	
	//track watched lessons
	func getWatchedLessons() -> [String:Any] {
		return useriCloudKeyValueStore.dictionary(forKey: "watchedLessons") ?? [:]
	}
	
	func getWatchedLessons(courseID:Int)->[Int] {
		var filteredLessons:[Int] = []
		for watchedItem in getWatchedLessons() {
			if (watchedItem.value as! String).contains(String(courseID)+"/") {
				filteredLessons.append(Int(watchedItem.key)!)
			}
		}
		print("[debug] StudentData, getWatchedLessons, courseID\(courseID), \(filteredLessons)")
		return filteredLessons
	}
	
	func updateWatchedLessons(courseID:Int, lessonID:Int, addWatched:Bool) {
		var allLessons = getWatchedLessons()
		let now = Date()
		let nowFormatter = DateFormatter()
		nowFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		let watchedString = String(courseID)+"/"+nowFormatter.string(from: now)
		
		if addWatched {
			allLessons.updateValue(watchedString, forKey: String(lessonID))
		} else{
			allLessons.removeValue(forKey: String(lessonID))
		}
		
		useriCloudKeyValueStore.set(allLessons,forKey: "watchedLessons")
		useriCloudKeyValueStore.synchronize()
	}
	
	func getFavouritedCourses() -> [String:Any] {
		return useriCloudKeyValueStore.dictionary(forKey: "favouritedCourses") ?? [:]
	}
	
	func updateFavouritedCourse(courseID: Int) {
		var getFavouriteCourses = getFavouritedCourses()
		let now = Date()
		let nowFormatter = DateFormatter()
		nowFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		
		if getFavouriteCourses.contains(where: {Int($0.key) == courseID}) {
			getFavouriteCourses.removeValue(forKey: String(courseID))
		} else {
			getFavouriteCourses.updateValue(nowFormatter.string(from: now), forKey: String(courseID))//.append(courseID)
		}
		
		useriCloudKeyValueStore.set(getFavouriteCourses,forKey: "favouritedCourses")
		useriCloudKeyValueStore.synchronize()
	}
	
	
	func removeAKey(keyName:String){
		useriCloudKeyValueStore.removeObject(forKey: keyName)
		useriCloudKeyValueStore.synchronize()
	}
	
	func backendReadAllKeys(){
		for(key,value) in useriCloudKeyValueStore.dictionaryRepresentation {
			print("=====\(key)======")
			print("\(value)")
		}
	}
	
	func readAllUserDefaultKeys(keys:[String]) {
		for(key,value) in userDefaults.dictionaryRepresentation() {
			print("=====\(key)======")
			print("\(value)")
		}
	}
	
	func removeAUserDefaultKey(keyName: String){
		userDefaults.removeObject(forKey: keyName)
		var matchCount = 0
		for(key,value) in userDefaults.dictionaryRepresentation() {
			if key == keyName {
				matchCount = matchCount + 1
				print("=====\(key) is still here======")
				print("\(value)")
			}
		}
		if matchCount == 0 {
			print("=====\(keyName) is removed======")
		}
	}
	
	func updateMyCourses(allCourses:[Course]) {
		print("[debug] StudentData, myCourses")
		myCourses.removeAll()
		
		refilMyCourses(allCourses: allCourses, statusType: "completed")
		refilMyCourses(allCourses: allCourses, statusType: "watched")
		refilMyCourses(allCourses: allCourses, statusType: "favourited")

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		
		for (index,course) in myCourses.enumerated() {
			//print("[debug] StudentData, myCourses-title, \(course.courseTitle)")
			var dateCollection:[Date] = []
			
			for lesson in getCompletedLessons() {
				//print("[debug] StudentData, completed scorewindID \(lesson.key)")
				//print("[debug] StudentData, completed scorewindID \(lesson.value as! String)")
				if (lesson.value as! String).contains(String(course.courseID)+"/") {
					let completedDateStr = (lesson.value as! String).replacingOccurrences(of: String(course.courseID)+"/", with: "")
					//print("[debug] StudentData, completed \(completedDateStr)")
					dateCollection.append(dateFormatter.date(from: completedDateStr) ?? Date())
				}
			}
			
			for lesson in getWatchedLessons() {
				//print("[debug] StudentData, watched scorewindID \(lesson.key)")
				//print("[debug] StudentData, watched scorewindID \(lesson.value as! String)")
				if (lesson.value as! String).contains(String(course.courseID)+"/") {
					let completedDateStr = (lesson.value as! String).replacingOccurrences(of: String(course.courseID)+"/", with: "")
					//print("[debug] StudentData, watched \(completedDateStr)")
					dateCollection.append(dateFormatter.date(from: completedDateStr) ?? Date())
				}
			}
			
			for favouriteCourse in getFavouritedCourses() {
				if Int(favouriteCourse.key) == course.courseID {
					dateCollection.append(course.favouritedDate)
				}
			}
			
			//updateMyCoursesFavouriteStatus(allCourses: allCourses)
			if dateCollection.count > 0 {
				dateCollection = dateCollection.sorted(by: {$0 > $1})
				print("[debug] StudentData, myCourses-dateCollection(courseID:\(course.courseID) \(dateCollection)")
				myCourses[index].lastUpdatedDate = dateCollection[0]
			}
			
		}
		
		myCourses = myCourses.sorted(by: {$0.lastUpdatedDate > $1.lastUpdatedDate})
	}
	
	private func refilMyCourses(allCourses:[Course], statusType: String) {
		var processArray:[String:Any] = [:]
		if statusType == "completed" {
			processArray = getCompletedLessons()
		} else if statusType == "watched" {
			processArray = getWatchedLessons()
		} else if statusType == "favourited" {
			processArray = getFavouritedCourses()
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		
		for item in processArray {
			var findCourseInAll:Course = Course()
			if statusType == "favourited" {
				findCourseInAll = allCourses.first(where: {$0.id == Int(item.key)}) ?? Course()
			} else {
				findCourseInAll = allCourses.first(where: {(item.value as! String).contains(String($0.id)+"/")}) ?? Course()
			}
			
			if findCourseInAll.id > 0 {
				let findMyCourseIndex = myCourses.firstIndex(where: {$0.courseID == findCourseInAll.id}) ?? -1
				if findMyCourseIndex > -1 {
					if statusType == "completed" {
						if myCourses[findMyCourseIndex].completedLessons.contains(Int(item.key)!) == false {
							myCourses[findMyCourseIndex].completedLessons.append(Int(item.key)!)
						}
					} else if statusType == "watched" {
						if myCourses[findMyCourseIndex].watchedLessons.contains(Int(item.key)!) == false {
							myCourses[findMyCourseIndex].watchedLessons.append(Int(item.key)!)
						}
					} else if statusType == "favourited" {
						myCourses[findMyCourseIndex].isFavourite = true
						print("[debug] StudentDaata, refileMyCourses, favouritedDate(\(item.key): \(item.value as! String)")
						myCourses[findMyCourseIndex].favouritedDate = dateFormatter.date(from: item.value as! String) ?? Date()
					}
				} else {
					var addNewCourse = MyCourse()
					addNewCourse.courseID = findCourseInAll.id
					addNewCourse.courseTitle = findCourseInAll.title
					addNewCourse.courseShortDescription = findCourseInAll.shortDescription
					
					if statusType == "completed" {
						addNewCourse.completedLessons.append(Int(item.key)!)
					} else if statusType == "watched" {
						addNewCourse.watchedLessons.append(Int(item.key)!)
					} else if statusType == "favourited" {
						addNewCourse.isFavourite = true
						print("[debug] StudentDaata, refileMyCourses, favouritedDate(\(item.key): \(item.value as! String)")
						addNewCourse.favouritedDate = dateFormatter.date(from: item.value as! String) ?? Date()
					}
					
					myCourses.append(addNewCourse)
				}
			}
		}
	}
	
	func updateMyCoursesDownloadStatus(allCourses:[Course], downloadManager:DownloadManager){
		let courseOfflineDateList = userDefaults.object(forKey: "courseOfflineDate") as? [String:Any] ?? [:]
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		
		if myCourses.count > 0 {
			for (index,course) in myCourses.enumerated() {
				//update downloadStatus for course in self.myCourses first
				let findInAllCourses = allCourses.first(where: {$0.id == course.courseID}) ?? Course()
				myCourses[index].downloadStatus = downloadManager.checkDownloadStatus(courseID: course.courseID, lessonsCount: findInAllCourses.lessons.count).rawValue
				
				//update lastUpdateDate for course in self.myCourses against courseOfflineDate Key-Value if it's necessary
				let findInCourseOfflineDate = courseOfflineDateList.first(where: { Int($0.key) == course.courseID})
				if findInCourseOfflineDate != nil {
					let getCourseOfflineDate = findInCourseOfflineDate!.value as! Date
					if course.lastUpdatedDate < getCourseOfflineDate {
						myCourses[index].lastUpdatedDate = getCourseOfflineDate
					}
				}
			}
			
			if courseOfflineDateList.count > 0 {
				//add courses that exist in Key-Value courseOfflineDate but not in self.myCourses
				for dateItem in courseOfflineDateList {
					if myCourses.contains(where: {$0.courseID == Int(dateItem.key)}) == false {
						let findInAllCourses = allCourses.first(where: {$0.id == Int(dateItem.key)}) ?? Course()
						var newCourse = MyCourse()
						newCourse.courseID = findInAllCourses.id
						newCourse.courseTitle = findInAllCourses.title
						newCourse.courseShortDescription = findInAllCourses.shortDescription
						newCourse.downloadStatus = downloadManager.checkDownloadStatus(courseID: Int(dateItem.key)!, lessonsCount: findInAllCourses.lessons.count).rawValue
						newCourse.lastUpdatedDate = dateItem.value as! Date
						myCourses.append(newCourse)
					}
				}
			}
			
			myCourses = myCourses.sorted(by: {$0.lastUpdatedDate > $1.lastUpdatedDate})
			
		}
	}
	
	/*
	 DATA FOR WIZARD
	 */
	
	func getInstrumentChoice()->String{
		let wizardChooseInstrumentValue:String = userDefaults.string(forKey: "wizardChooseInstrument") ?? ""
		if wizardChooseInstrumentValue.isEmpty == false {
			wizardInstrumentChoice = wizardChooseInstrumentValue
			return wizardInstrumentChoice
		} else {
			return wizardInstrumentChoice
		}
		//return useriCloudKeyValueStore.string(forKey:"instrument") ?? ""
	}
	
	func updateInstrumentChoice(instrument:InstrumentType) {
		wizardInstrumentChoice = instrument.rawValue
		userDefaults.set(instrument.rawValue, forKey: "wizardChooseInstrument")
		//useriCloudKeyValueStore.set(instrument.rawValue, forKey: "instrument")
		//useriCloudKeyValueStore.synchronize()
	}
	
	func getExperience()->String {
		return wizardExperienceChoice
		//return useriCloudKeyValueStore.string(forKey:"experience") ?? ""
	}
	
	func updateExperience(experience: ExperienceFeedback) {
		wizardExperienceChoice = experience.rawValue
		//useriCloudKeyValueStore.set(experience.rawValue, forKey: "experience")
		//useriCloudKeyValueStore.synchronize()
	}
	
	func getDoYouKnow()-> [String:Any] {
		return wizardDoYouKnowChoice
		//return useriCloudKeyValueStore.dictionary(forKey: "doYouKnow") ?? [:]
	}
	
	func updateDoYouKnow(courseID:Int, feedbackValues:[Int]) {
		wizardDoYouKnowChoice.updateValue(feedbackValues, forKey: String(courseID))
		//var lastDoYouKnow = getDoYouKnow()
		//lastDoYouKnow.updateValue(feedbackValues, forKey: String(courseID))
		//useriCloudKeyValueStore.set(lastDoYouKnow, forKey: "doYouKnow")
		//useriCloudKeyValueStore.synchronize()
	}
	
	func getPlayable() -> [String:Any] {
		return wizardPlayableChoice
		//return useriCloudKeyValueStore.dictionary(forKey: "playable") ?? [:]
	}
	
	func updatePlayable(courseID: Int, lessonID: Int, feedbackValue: Int) {
		let playableValue = String(feedbackValue) + "|" + String(courseID)
		wizardPlayableChoice.updateValue(playableValue, forKey: String(lessonID))
		//var lastPlayable = getPlayable()
		//let playableValue = String(feedbackValue) + "|" + String(courseID)
		//lastPlayable.updateValue(playableValue, forKey: String(lessonID))
		//useriCloudKeyValueStore.set(lastPlayable, forKey: "playable")
		//useriCloudKeyValueStore.synchronize()
	}
	
	func getTotalCompletedLessonCount() -> Int {
		var countLesson = 0
		for course in myCourses {
			countLesson = countLesson + course.completedLessons.count
		}
		return countLesson
	}
	
	func updateWizardResult(result: WizardResult) {
		do {
			let encoder = JSONEncoder()
			let data = try encoder.encode(result)
			useriCloudKeyValueStore.set(data, forKey: "wizardResult")
			useriCloudKeyValueStore.synchronize()
		} catch {
			print("unable to encode result \(error)")
		}
	}
	
	func getWizardResult() -> WizardResult {
		var wizardResult = WizardResult()
		
		if let data = useriCloudKeyValueStore.data(forKey: "wizardResult") {
			do {
				let decoder = JSONDecoder()
				let result = try decoder.decode(WizardResult.self, from:data)
				//print("result title \(result.resultTitle)")
				//print("result, first course title in learningPath \(result.learningPath[0].course.title)")
				wizardResult.resultTitle = result.resultTitle
				wizardResult.resultExplaination = result.resultExplaination
				wizardResult.learningPathTitle = result.learningPathTitle
				wizardResult.learningPathExplaination = result.learningPathExplaination
				wizardResult.learningPath = result.learningPath
				wizardResult.resultExperience = result.resultExperience
				return wizardResult
			} catch {
				wizardResult = WizardResult()
				print("unable to decode wizardResult \(error)")
			}
		}
		
		return wizardResult
	}
	
	func resetWizrdChoice() {
		removeAUserDefaultKey(keyName: "wizardChooseInstrument")
		wizardExperienceChoice = ""
		wizardDoYouKnowChoice.removeAll()
		wizardPlayableChoice.removeAll()
	}
	
	func getWizardMode() -> WizardCalculationMode {
		let wizardModeSaved:String = userDefaults.object(forKey: "wizardCalculationMode") as? String ?? WizardCalculationMode.assessment.rawValue
		if wizardModeSaved == WizardCalculationMode.explore.rawValue {
			return WizardCalculationMode.explore
		} else {
			return WizardCalculationMode.assessment
		}
	}
	
	func updateWizardMode(wizardMode: WizardCalculationMode) {
		userDefaults.set(wizardMode.rawValue, forKey: "wizardCalculationMode")
	}
	
	func showSavedActionCount() {
		for usageAction in UsageActions.allCases {
			let getActionCount = userDefaults.object(forKey: usageAction.rawValue) as? Int ?? 0
			print("== \(usageAction.rawValue) : \(getActionCount) == ")
		}
	}
	
	func updateUsageActionCount(actionName: UsageActions) {
		var actionCount:Int = userDefaults.object(forKey: actionName.rawValue) as? Int ?? 0
		actionCount = actionCount + 1
		userDefaults.set(actionCount, forKey: actionName.rawValue)
	}
	
	func getUserUsageActionTotalCount() -> Int {
		var totalActionCount = 0
		for usageAction in UsageActions.allCases {
			let getActionCount = userDefaults.object(forKey: usageAction.rawValue) as? Int ?? 0
			totalActionCount = totalActionCount + getActionCount
		}
		return totalActionCount
	}
	
	private func getLogsCount() -> Int {
		let logs = getLogs()
		return logs.count
	}
	
	func sendUserUsageActionCount(runNow:Bool = false) async {
		//print("[debug]StudentData-Track Action, totalUsageCount \(getUserUsageActionTotalCount())")
		print("[debug]StudentData-Track Action, userUsageTimerCount/total \(userUsageTimerCount)/\(userUsageTimerCountTotal)")
		print("[debug]StudentData-Track Action, getLogsCount \(getLogsCount())")
		//if userUsageTimerCount >= 120 || getUserUsageActionTotalCount() >= 5 {
		if userUsageTimerCount >= 120 || getLogsCount() >= 5 || runNow || (userUsageTimerCountTotal<=20&&getLogsCount()>0) {
			Task {
				/* :::::::::::;>
				var mySendJsonObject:sendJsonObject = sendJsonObject(ActionCounts: [])
				for usageAction in UsageActions.allCases {
					let getActionCount = userDefaults.object(forKey: usageAction.rawValue) as? Int ?? 0
					mySendJsonObject.ActionCounts.append(sendActionCountObject(ActionName: usageAction.rawValue, Count: getActionCount))
				}
				 < :::::::::::::*/
				var mySendJsonObject:sendLogObjects = sendLogObjects(InstallID:getInstallID(), Logs: [], Locale: "")
				mySendJsonObject.Logs = getLogs()
				mySendJsonObject.Locale = Locale.current.description
				print("[debug]StudentData-Track Action, mySendJsonObject \(mySendJsonObject)")
				userUsageTimerCount = 0
				/* :::::::::::;>
				for usageAction in UsageActions.allCases {
					userDefaults.removeObject(forKey: usageAction.rawValue)
				}
				 < :::::::::::::*/
				userDefaults.removeObject(forKey: "eventLogs")
				
				do {
					let payload = try JSONEncoder().encode(mySendJsonObject)
					//guard let url = URL(string: "https://music.scorewind.com/mobileapp_update_usage_action_count.php") else { fatalError("Missing URL") }
					guard let url = URL(string: "https://music.scorewind.com/test_mobileapp_iOS_event_log.php") else { fatalError("Missing URL") }
					var urlRequest = URLRequest(url: url)
					urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
					urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
					urlRequest.httpMethod = "POST"
					
					let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: payload)
					print("[debug]StudentData, upload payload \(payload)")
					
					if (response as? HTTPURLResponse)?.statusCode == 200 {
						if userUsageTimerCount != -1 {
							let successInfo = try JSONDecoder().decode(responseInfo.self, from: data)
							
							print("-Track Action \(String(data: data, encoding: .utf8) ?? "default value")")
							print("-Track Action Success: \(successInfo.Success)")
							print("-Track Action Error: \(successInfo.Error)")
						} else {
							print("-Track Action: probably gone background")
						}
						
					} else {
						print("-Track Action httpurl response statusCode is not 200")
					}
				} catch {
					print("-Track Action \(error)")
				}
				
			}
		}
	}
	
	func setLaunchUUID() {
		launchUUID = UUID()
	}
	
	func getLogs() -> [String] {
		let lastLogs = userDefaults.object(forKey: "eventLogs") as? [String] ?? []
		return lastLogs
	}
	
	func updateLogs(title: UsageActions, content: String) {
		//the post format
		//uuid[datetime]: log content
		//format of log content, scope is seperated by |
		var theLogs = getLogs()
		var newLog:[String] = [] //= launchUUID?.uuidString ?? ""
		
		var setSessionID = launchUUID?.uuidString ?? ""
		if setSessionID.isEmpty {
			setLaunchUUID()
			setSessionID = launchUUID?.uuidString ?? ""
		}
		//newLog.append(getInstallID()) //0
		newLog.append(setSessionID) //0
		
		let myTodayFormatter = DateFormatter()
		myTodayFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
		myTodayFormatter.timeZone = TimeZone(identifier: "UTC")
		let nowString = myTodayFormatter.string(from: Date())
		newLog.append(nowString) //1
		
		newLog.append(title.rawValue) //2
		newLog.append(content) //3
		
		theLogs.append(newLog.joined(separator: "|"))
		userDefaults.set(theLogs, forKey: "eventLogs")
	}
	
	struct sendJsonObject: Encodable {
		var ActionCounts:[sendActionCountObject]
	}
	
	struct sendActionCountObject: Encodable {
		let ActionName:String
		let Count: Int
	}
	
	struct sendLogObjects: Encodable {
		var InstallID:String
		var Logs:[String]
		var Locale: String
	}

	struct responseInfo: Decodable {
		let Success: Bool
		let Error: String
		let ErrorCode: Int
	}
	
	func getInstallID() -> String {
		let userLaunchID = userDefaults.object(forKey: "installID") as? String ?? ""
		return userLaunchID
	}
	
	func setInstallID() {
		var newInstallID = UUID().uuidString ?? ""
		userDefaults.set(newInstallID, forKey: "installID")
	}
	
}

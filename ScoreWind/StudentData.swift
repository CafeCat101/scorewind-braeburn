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
	
	func getInstrumentChoice()->String{
		return useriCloudKeyValueStore.string(forKey:"instrument") ?? ""
	}
	
	func setInstrumentChoice(instrument:String) {
		useriCloudKeyValueStore.set(instrument,forKey: "instrument")
		useriCloudKeyValueStore.synchronize()
	}
	
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
	
	func getFavouritedCourses() -> [Any] {
		return useriCloudKeyValueStore.array(forKey: "favouritedCourses") ?? []
	}
	
	func updateFavouritedCourse(courseID: Int) {
		var getFavouriteCourses = getFavouritedCourses()
		if getFavouriteCourses.contains(where: {$0.self as! Int == courseID}) {
			getFavouriteCourses.remove(at: getFavouriteCourses.firstIndex(where: {$0.self as! Int == courseID}) ?? -1)
		} else {
			getFavouriteCourses.append(courseID)
		}
		
		useriCloudKeyValueStore.set(getFavouriteCourses,forKey: "favouritedCourses")
		useriCloudKeyValueStore.synchronize()
	}
	
	
	func removeAKey(keyName:String){
		useriCloudKeyValueStore.removeObject(forKey: keyName)
	}
	
	func backendReadAllKeys(){
		for(key,value) in useriCloudKeyValueStore.dictionaryRepresentation {
			print("=====\(key)======")
			print("\(value)")
		}
	}
	
	func updateMyCourses(allCourses:[Course]) {
		print("[debug] StudentData, myCourses")
		myCourses.removeAll()
		refilMyCourses(allCourses: allCourses, statusType: "completed")
		refilMyCourses(allCourses: allCourses, statusType: "watched")

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
			
			updateMyCoursesFavouriteStatus(allCourses: allCourses)
			
			dateCollection = dateCollection.sorted(by: {$0 > $1})
			//print("[debug] StudentData, myCourses-dateCollection \(dateCollection)")
			myCourses[index].lastUpdatedDate = dateCollection[0]
		}
		
		myCourses = myCourses.sorted(by: {$0.lastUpdatedDate > $1.lastUpdatedDate})
	}
	
	private func refilMyCourses(allCourses:[Course], statusType: String) {
		for lesson in (statusType=="completed" ? getCompletedLessons() : getWatchedLessons()) {
			let findCourseInAll = allCourses.first(where: {(lesson.value as! String).contains(String($0.id)+"/")}) ?? Course()
			
			if findCourseInAll.id > 0 {
				let findMyCourseIndex = myCourses.firstIndex(where: {$0.courseID == findCourseInAll.id}) ?? -1
				if findMyCourseIndex > -1 {
					if statusType == "completed" {
						if myCourses[findMyCourseIndex].completedLessons.contains(Int(lesson.key)!) == false {
							myCourses[findMyCourseIndex].completedLessons.append(Int(lesson.key)!)
						}
					} else {
						if myCourses[findMyCourseIndex].watchedLessons.contains(Int(lesson.key)!) == false {
							myCourses[findMyCourseIndex].watchedLessons.append(Int(lesson.key)!)
						}
					}
				} else {
					var addNewCourse = MyCourse()
					addNewCourse.courseID = findCourseInAll.id
					addNewCourse.courseTitle = findCourseInAll.title
					addNewCourse.courseShortDescription = findCourseInAll.shortDescription
					if statusType == "completed" {
						addNewCourse.completedLessons.append(Int(lesson.key)!)
					} else {
						addNewCourse.watchedLessons.append(Int(lesson.key)!)
					}
					
					myCourses.append(addNewCourse)
				}
			}
		}
	}
	
	func updateMyCoursesFavouriteStatus(allCourses:[Course]) {
		for courseID in getFavouritedCourses() {
			let findCourseFromScoewindData = allCourses.first(where: {$0.id == courseID as! Int}) ?? Course()
			let findMyCourseIndex = myCourses.firstIndex(where: {$0.courseID == courseID as! Int}) ?? -1
			if findMyCourseIndex > -1 {
				myCourses[findMyCourseIndex].isFavourite = true
			} else {
				var addNewCourse = MyCourse()
				addNewCourse.courseID = findCourseFromScoewindData.id
				addNewCourse.courseTitle = findCourseFromScoewindData.title
				addNewCourse.courseShortDescription = findCourseFromScoewindData.shortDescription
				addNewCourse.isFavourite = true
				myCourses.append(addNewCourse)
			}
		}
		
		for (index,course) in myCourses.enumerated() {
			if getFavouritedCourses().contains(where: {$0.self as! Int == course.courseID}) == false {
				myCourses[index].isFavourite = false
			}
		}
	}

}

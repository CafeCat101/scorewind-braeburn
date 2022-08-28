//
//  StudentData.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/4/4.
//

import Foundation
import SwiftUI


class StudentData: ObservableObject {
	private var myCourses:[MyCourse] = []
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
			if lesson.value as! Int == courseID {
				filteredLessons.append(Int(lesson.key)!)
			}
		}
		return filteredLessons
	}
	
	func updateCompletedLesson(courseID:Int, lessonID:Int, isCompleted:Bool) {
		var allLessons = getCompletedLessons()
		if isCompleted {
			allLessons.updateValue(courseID, forKey: String(lessonID))
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
	
	
	func removeAKey(keyName:String){
		useriCloudKeyValueStore.removeObject(forKey: keyName)
	}
	
	func backendReadAllKeys(){
		for(key,value) in useriCloudKeyValueStore.dictionaryRepresentation {
			print("=====\(key)======")
			print("\(value)")
		}
	}
	
	func myCourses(allCourses:[Course]) -> [MyCourse] {
		print("[debug] StudentData, myCourses")
		myCourses.removeAll()
		let lessons = getCompletedLessons().sorted { (Int($0.key)!)<(Int($1.key)!)}
		for lesson in lessons {
			let findCourseInAll = allCourses.first(where: {$0.id == (lesson.value as! Int)}) ?? Course()
			print("[debug] StudentData, myCourses, findCourseInAll.id \(findCourseInAll.id)")
			
			if findCourseInAll.id > 0 {
				let findMyCourseIndex = myCourses.firstIndex(where: {$0.courseID == findCourseInAll.id}) ?? -1
				if findMyCourseIndex > -1 {
					if myCourses[findMyCourseIndex].completedLessons.contains(Int(lesson.key)!) == false {
						myCourses[findMyCourseIndex].completedLessons.append(Int(lesson.key)!)
					}
				} else {
					var addNewCourse = MyCourse()
					addNewCourse.courseID = findCourseInAll.id
					addNewCourse.courseTitle = findCourseInAll.title
					addNewCourse.courseShortDescription = findCourseInAll.shortDescription
					addNewCourse.completedLessons.append(Int(lesson.key)!)
					myCourses.append(addNewCourse)
				}
			}
		}
		
		for lesson in getWatchedLessons() {
			let findCourseInAll = allCourses.first(where: {(lesson.value as! String).contains(String($0.id)+"/")}) ?? Course()
			
			if findCourseInAll.id > 0 {
				let findMyCourseIndex = myCourses.firstIndex(where: {$0.courseID == findCourseInAll.id}) ?? -1
				if findMyCourseIndex > -1 {
					if myCourses[findMyCourseIndex].watchedLessons.contains(Int(lesson.key)!) == false {
						myCourses[findMyCourseIndex].watchedLessons.append(Int(lesson.key)!)
					}
				} else {
					var addNewCourse = MyCourse()
					addNewCourse.courseID = findCourseInAll.id
					addNewCourse.courseTitle = findCourseInAll.title
					addNewCourse.courseShortDescription = findCourseInAll.shortDescription
					addNewCourse.watchedLessons.append(Int(lesson.key)!)
					myCourses.append(addNewCourse)
				}
			}
		}
		
		myCourses = myCourses.sorted(by: {$0.courseTitle < $1.courseTitle})
		
		return myCourses
	}
}

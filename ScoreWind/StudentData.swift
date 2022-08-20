//
//  StudentData.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/4/4.
//

import Foundation
import SwiftUI


class StudentData: ObservableObject {
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
}

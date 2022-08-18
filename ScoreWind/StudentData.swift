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
	
	func getEnrolledCourses()->[String:Any] {
		return useriCloudKeyValueStore.dictionary(forKey:"enrolledCourses") ?? [:]
	}
	
	func updateEnrolledCourse(courseID:Int, isCompleted: Bool) {
		var enrolledCourses = getEnrolledCourses()
		enrolledCourses.updateValue(isCompleted, forKey: String(courseID))
		useriCloudKeyValueStore.set(enrolledCourses,forKey: "enrolledCourses")
		useriCloudKeyValueStore.synchronize()
	}
	
	func getCompletedLessons() -> [String:Any] {
		return useriCloudKeyValueStore.dictionary(forKey: "completedLessons") ?? [:]
	}
	
	func getCompletedLessons(courseID:Int)->[Int] {
		let getAllCompletedLessons = useriCloudKeyValueStore.dictionary(forKey:"completedLessons") ?? [:]
		var filteredLessons:[Int] = []
		
		for lesson in getAllCompletedLessons {
			if lesson.value as! Int == courseID {
				filteredLessons.append(Int(lesson.key)!)
			}
		}
		print(filteredLessons)
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

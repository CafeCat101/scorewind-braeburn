//
//  WizardRange.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/11/30.
//
/*
 Represent item that is selected course/lesson at each wizard step
 */
import Foundation
struct WizardPicked: Hashable, Identifiable {
	let id:UUID = UUID()
	var courseID: Int
	var lessonID: Int
	var courseSortValue: String
	var lessonSortValue: String
	var sortHelper: Double
	var feedbackValue: Double
	
	init(theCourse:Course, theLesson: Lesson, sortHelper:Double, feedbackValue: Double) {
		if theCourse.id > 0 {
			self.courseID = theCourse.id
			self.lessonID = theLesson.id
			self.courseSortValue = theCourse.sortValue
			if theLesson.id > 0 {
				self.lessonSortValue = theLesson.sortValue
				self.sortHelper = sortHelper
				/*let intToString = String(theLesson.step)
				var initialNumber:Int = 1
				for _ in 1...intToString.count {
					initialNumber = initialNumber*10
				}
				self.sortHelper = Double(theCourse.sortValue)! + Double(theLesson.step)/Double(initialNumber)
				 */
			} else {
				self.lessonSortValue = ""
				self.sortHelper =  Double(theCourse.sortValue) ?? 0.0
			}
			self.feedbackValue = feedbackValue
		} else {
			self.courseID = 0
			self.lessonID = 0
			self.courseSortValue = ""
			self.lessonSortValue = ""
			self.sortHelper = 0.0
			self.feedbackValue = 0.0
		}
		/*
		courseID = 0
		lessonID = 0
		courseSortValue = ""
		lessonSortValue = ""
		feedbackValue = 0
		*/
	}
	
	private func getNumberToDivide(targetInt: Int) -> Double {
		let intToString = String(targetInt)
		var initialNumber:Int = 1
		for _ in 1...intToString.count {
			initialNumber = initialNumber*10
		}
		return Double(initialNumber)
	}
}

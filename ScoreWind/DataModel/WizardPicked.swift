//
//  WizardRange.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/11/30.
//

import Foundation
struct WizardPicked {
	var courseID: Int
	var lessonID: Int
	var courseSortValue: String
	var lessonSortValue: String
	var feedbackValue: Double
	
	init(allCourses:[Course], courseID:Int, lessonID: Int, feedbackValue: Double) {
		let theCourse = allCourses.first(where: {$0.id == courseID}) ?? Course()
		if theCourse.id > 0 {
			self.courseID = courseID
			self.lessonID = lessonID
			self.courseSortValue = theCourse.sortValue
			let theLesson = theCourse.lessons.first(where: {$0.id == lessonID}) ?? Lesson()
			if theLesson.id > 0 {
				self.lessonSortValue = theLesson.sortValue
			} else {
				self.lessonSortValue = ""
			}
			self.feedbackValue = feedbackValue
		} else {
			self.courseID = 0
			self.lessonID = 0
			self.courseSortValue = ""
			self.lessonSortValue = ""
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
}

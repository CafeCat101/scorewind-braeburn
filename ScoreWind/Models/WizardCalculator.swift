//
//  WizardCalculator.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/23.
//

import Foundation

extension ScorewindData {
	func createRecommendation(availableCourses:[Course]) {
		let testCourseId = 96111
		let testLessonId = 13828
		wizardPickedCourse = availableCourses.first(where: {$0.id == testCourseId}) ?? Course()
		wizardPickedLesson = wizardPickedCourse.lessons.first(where: {$0.scorewindID == testLessonId}) ?? Lesson()
		wizardPickedTimestamps = (allTimestamps.first(where: {$0.id == testCourseId})?.lessons.first(where: {$0.scorewindID == testLessonId})!.timestamps)!
	}
}

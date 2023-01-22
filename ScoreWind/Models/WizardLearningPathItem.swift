//
//  WizardLearningPathItem.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/21.
//

import Foundation
struct WizardLearningPathItem: Identifiable {
	let id:UUID = UUID()
	var course: Course
	var lesson: Lesson
	var sortHelper: Double
	var feedbackValue: Double
	var showCourseTitle: Bool
	var startHere: Bool
	
	init() {
		course = Course()
		lesson = Lesson()
		sortHelper = 0.0
		feedbackValue = 0.0
		showCourseTitle = false
		startHere = false
	}
}

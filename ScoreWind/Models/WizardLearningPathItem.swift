//
//  WizardLearningPathItem.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/21.
//

import Foundation
struct WizardLearningPathItem: Identifiable, Codable {
	var id: UUID
	var courseID: Int
	var lessonID: Int
	var sortHelper: Double
	var feedbackValue: Double
	var showCourseTitle: Bool
	var startHere: Bool
	var courseTitle: String
	var lessonTitle: String
	var friendlyID: Int
	
	init() {
		id = UUID()
		courseID = 0
		lessonID = 0
		sortHelper = 0.0
		feedbackValue = 0.0
		showCourseTitle = false
		startHere = false
		courseTitle = "Course"
		lessonTitle = "Lesson"
		friendlyID = 0
	}
}

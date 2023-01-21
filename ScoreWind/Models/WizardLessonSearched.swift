//
//  WizardLessonSearched.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/12.
//

import Foundation

struct WizardLessonSearched {
	var courseID: Int
	var lesson: Lesson
	
	init(courseID: Int, lesson: Lesson) {
		self.courseID = courseID
		self.lesson = lesson
	}
}

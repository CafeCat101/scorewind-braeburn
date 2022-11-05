//
//  WizardCalculator.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/23.
//

import Foundation

extension ScorewindData {
	func createRecommendation(availableCourses:[Course], studentData: StudentData, experienceFeedback: ExperienceFeedback) {
		var testCourseId = 96111
		var testLessonId = 95419
		
		if experienceFeedback == .continueLearning {
			testCourseId = 96111
			testLessonId = 95419
		} else if experienceFeedback == .playedBefore {
			if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
				testCourseId = 96111
				testLessonId = 95427
			} else if studentData.getInstrumentChoice() == InstrumentType.violin.rawValue {
				testCourseId = 94069
				testLessonId = 90662
			}
		} else {
			if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
				testCourseId = 93950
				testLessonId = 90696
			} else if studentData.getInstrumentChoice() == InstrumentType.violin.rawValue {
				testCourseId = 94069
				testLessonId = 90662
			}
		}
		
		wizardPickedCourse = availableCourses.first(where: {$0.id == testCourseId}) ?? Course()
		wizardPickedLesson = wizardPickedCourse.lessons.first(where: {$0.id == testLessonId}) ?? Lesson()
		wizardPickedTimestamps = (allTimestamps.first(where: {$0.id == testCourseId})?.lessons.first(where: {$0.id == testLessonId})!.timestamps)!
	}
}

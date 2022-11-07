//
//  WizardCalculator.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/23.
//

import Foundation

extension ScorewindData {
	func createRecommendation(availableCourses:[Course], studentData: StudentData) -> Bool {
		var testCourseId = 0
		var testLessonId = 0
		
		if studentData.wizardStepNames[studentData.wizardStepNames.count-1] == Page.wizardExperience {
			if studentData.getExperience() == ExperienceFeedback.continueLearning.rawValue {
				if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
					testCourseId = 96111
					testLessonId = 95419
				} else if studentData.getInstrumentChoice() == InstrumentType.violin.rawValue {
					testCourseId = 94882
					testLessonId = 94949
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
		}
		
		if testCourseId > 0 && testLessonId > 0 {
			wizardPickedCourse = availableCourses.first(where: {$0.id == testCourseId}) ?? Course()
			wizardPickedLesson = wizardPickedCourse.lessons.first(where: {$0.id == testLessonId}) ?? Lesson()
			wizardPickedTimestamps = (allTimestamps.first(where: {$0.id == testCourseId})?.lessons.first(where: {$0.id == testLessonId})!.timestamps)!
			
			return true
		} else {
			return false
		}
	}

}

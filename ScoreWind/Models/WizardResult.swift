//
//  WizardResult.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/22.
//
/**
 To pass organized final result to WizardResultView
 */
import Foundation

struct WizardResult {
	let id:UUID = UUID()
	var resultTitle: String
	var resultExplaination: String
	var learningPathTitle: String
	var learningPathExplaination: String
	var allCourses:[Course]
	var allTimestamps:[Timestamp]
	
	init(getAllCourses:[Course], getAllTimestamps:[Timestamp]) {
		allCourses = getAllCourses
		allTimestamps = getAllTimestamps
		resultTitle = "Discovered a lesson!"
		resultExplaination = "You've completed the wizard. Scorewind found a lesson for you."
		learningPathTitle = "Your leaninr path"
		learningPathExplaination = "These are lessons that await for you to complete them."
	}
	
	public func getLearningPath(wizardRange: [WizardPicked], experienceType: ExperienceFeedback) -> [WizardLearningPathItem] {
		//let calculatorHelper = WizardCalculatorHelper()
		let sortedWizardRange = wizardRange.sorted(by: {$0.sortHelper < $1.sortHelper})
		var learningPath:[WizardLearningPathItem] = []
		print("[debug] WizardResult, getLearningPath sortedWizardRange.count \(sortedWizardRange.count)")
		for i in 0..<sortedWizardRange.count {
			//print("[debug] WizardResult, getLearningPath allCourse.count \(calculatorHelper.allCourses.count)")
			var learningPathItem = WizardLearningPathItem()
			learningPathItem.course = allCourses.first(where: {$0.id == sortedWizardRange[i].courseID}) ?? Course()
			learningPathItem.lesson = learningPathItem.course.lessons.first(where: {$0.id == sortedWizardRange[i].lessonID}) ?? Lesson()
			learningPathItem.feedbackValue = sortedWizardRange[i].feedbackValue
			learningPathItem.sortHelper = sortedWizardRange[i].sortHelper
			if i == 0 {
				learningPathItem.showCourseTitle = true
				learningPathItem.startHere = true
			} else {
				if sortedWizardRange[i].courseID != sortedWizardRange[i-1].courseID {
					learningPathItem.showCourseTitle = true
				}
			}
			learningPath.append(learningPathItem)
		}
		
		
		return learningPath
	}
}

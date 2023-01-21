//
//  WizardResult.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/22.
//

import Foundation

struct WizardResult {
	let id:UUID = UUID()
	var resultTitle: String
	var resultExplaination: String
	var learningPathTitle: String
	var learningPathExplaination: String
	
	init() {
		resultTitle = "Discovered a lesson!"
		resultExplaination = "You've completed the wizard. Scorewind found a lesson for you."
		learningPathTitle = "Your leaninr path"
		learningPathExplaination = "These are lessons that await for you to complete them."
	}
	
	public func getLearningPath(wizardRange: [WizardPicked], experienceType: ExperienceFeedback) -> [WizardLearningPathItem] {
		let calculatorHelper = WizardCalculatorHelper()
		var learningPath:[WizardLearningPathItem] = []
		
		for rangeItem in wizardRange {
			var learningPathItem = WizardLearningPathItem()
			learningPathItem.course = calculatorHelper.allCourses.first(where: {$0.id == courseID}) ?? Course()
			learningPathItem.lesson = 
		}
		
		
		return learningPath
	}
}

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

struct WizardResult: Codable {
	var id:UUID
	var resultTitle: String
	var resultExplaination: String
	var learningPathTitle: String
	var learningPathExplaination: String
	var learningPath:[WizardLearningPathItem]
	var resultExperience: String
	
	init() {
		id = UUID()
		resultTitle = "A Lesson is Discovered!"
		resultExplaination = "You've completed the configuration. Checkout out the next lesson to learn."
		learningPathTitle = "Your Learning Path"
		learningPathExplaination = "These are some lessons that await for you to complete them."
		learningPath = []
		resultExperience = ExperienceFeedback.starterKit.rawValue
	}
	
	
}

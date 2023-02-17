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
	
	init() {
		id = UUID()
		resultTitle = "Discovered a lesson!"
		resultExplaination = "You've completed the configuration. ScoreWind found a lesson for you."
		learningPathTitle = "Your learning path"
		learningPathExplaination = "These are some lessons that await for you to complete them."
		learningPath = []
	}
	
	
}

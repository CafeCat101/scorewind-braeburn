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
	var learningPath:[WizardLearningPathItem]
	
	init() {
		resultTitle = "Discovered a lesson!"
		resultExplaination = "You've completed the wizard. Scorewind found a lesson for you."
		learningPathTitle = "Your leaninr path"
		learningPathExplaination = "These are some lessons that await for you to complete them."
		learningPath = []
	}
	
	
}

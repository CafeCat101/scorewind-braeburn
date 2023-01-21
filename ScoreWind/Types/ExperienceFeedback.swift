//
//  ExperienceFeedback.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/11/5.
//

import Foundation
enum ExperienceFeedback:String {
	case starterKit = "start" //always start from first uncompleted lesson
	case continueLearning = "continue" //use calculation to explore uncompleted lessons, take challanges
	case experienced = "repository" //to explore uncompleted path course and lessons
	
	var rawToCase: String {
		switch self {
		case .starterKit: return "start"
		case .continueLearning: return "continue"
		case .experienced: return "repository"
		}
	}
	
	func getLabel() -> String{
		switch self {
		case .starterKit:
			return "Take me to the beginning of the unpaved journey."
		case .continueLearning:
			return "Feeling adventurous.\nI want to explore!"
		case .experienced:
			return "I'm skilled.\nGo to explore the repositories now."
		}
	}
	
	func getKeyName() -> String {
		return "experience"
	}
}

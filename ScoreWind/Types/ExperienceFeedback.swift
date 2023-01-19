//
//  ExperienceFeedback.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/11/5.
//

import Foundation
enum ExperienceFeedback:String {
	case starterKit = "start" //never played it, should start from 101
	case continueLearning = "continue" //If prior wizard data exists, show this option. Start from last completed lesson or course or 103
	case experienced = "repository"
	
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

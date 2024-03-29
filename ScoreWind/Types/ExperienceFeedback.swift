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
	
	func getLabel() -> String{
		switch self {
		case .starterKit:
			return "Based on the lessons you've completed, see your next lessons." //"Take me to the beginning of the unpaved journey."
		case .continueLearning:
			return "Configure the next learning path based on your feedback and completed lessons."//"Feeling adventurous.\nI want to explore!"
		case .experienced:
			return "Find a learning path for a fast-paced learning style."//"I'm skilled.\nGo to explore the repositories now."
		}
	}
	
	func getTitle() -> String{
		switch self {
		case .starterKit:
			return "Journey"
		case .continueLearning:
			return "Explore"
		case .experienced:
			return "Advancing"
		}
	}
	
	func getKeyName() -> String {
		return "experience"
	}
}

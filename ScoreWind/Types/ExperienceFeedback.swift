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
	
	func getLabel() -> String{
		switch self {
		case .starterKit:
			return "I've never played it before"
		case .continueLearning:
			return "Continue learning"
		}
	}
	
	func getKeyName() -> String {
		return "experience"
	}
}

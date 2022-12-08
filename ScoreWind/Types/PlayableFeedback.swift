//
//  WizardScoreFeedback.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/14.
//

import Foundation

enum PlayableFeedback: Int, CaseIterable {
	case easyPeasy = 5
	case comfortable = 4
	case canLearn = 3
	case littleDifficult = 2
	case veryHard = 1
	
	func getLabel() -> String {
		switch self {
		case .easyPeasy:
			return "Easy peasy"
		case .comfortable:
			return "Comfortable"
		case .canLearn:
			return "I can learn it"
		case .littleDifficult:
			return "Little difficult"
		case .veryHard:
			return "Very hard"
		}
	}
	
	func getKeyName() -> String {
		return "playable"
	}
	
}

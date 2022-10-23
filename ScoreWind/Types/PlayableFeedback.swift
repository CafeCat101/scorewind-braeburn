//
//  WizardScoreFeedback.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/14.
//

import Foundation

enum PlayableFeedback: Int, CaseIterable {
	case easyPeasy = 0
	case comfortable = 1
	case canLearn = 2
	case littleDifficult = 3
	case veryHard = 4
	
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
	
}

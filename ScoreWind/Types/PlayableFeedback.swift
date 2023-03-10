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
			return "Easy Peasy"
		case .comfortable:
			return "Comfortable"
		case .canLearn:
			return "Start Learning"
		case .littleDifficult:
			return "A Little Difficult"
		case .veryHard:
			return "Very Hard"
		}
	}
	
	func getKeyName() -> String {
		return "playable"
	}
	
}

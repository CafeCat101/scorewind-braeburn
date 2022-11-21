//
//  WizardHighlightFeedback.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/14.
//

import Foundation

enum DoYouKnowFeedback: Int, CaseIterable {
	case allOfThem = 3
	case someOfThem = 2
	case fewOfThem = 1
	
	func getLabel() -> String {
		switch self {
		case .allOfThem:
			return "Yes"
		case .someOfThem:
			return "Somewhat familiar"
		case .fewOfThem:
			return "No"
		}
	}
	
	func getKeyName() -> String {
		return "doYouKnow"
	}
	
}

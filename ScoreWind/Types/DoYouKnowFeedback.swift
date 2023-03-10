//
//  WizardHighlightFeedback.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/14.
//

import Foundation
/**
 The "Good to go" answer (allOfThem) needs to have the same value as PlayableFeedback's "Good to go" answer(can learn)
 */
enum DoYouKnowFeedback: Int, CaseIterable {
	case allOfThem = 3
	case someOfThem = 2
	case fewOfThem = 1
	
	func getLabel() -> String {
		switch self {
		case .allOfThem:
			return "Yes"
		case .someOfThem:
			return "Somewhat Familiar"
		case .fewOfThem:
			return "No"
		}
	}
	
	func getKeyName() -> String {
		return "doYouKnow"
	}
	
}

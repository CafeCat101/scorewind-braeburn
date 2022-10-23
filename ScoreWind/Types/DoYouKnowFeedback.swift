//
//  WizardHighlightFeedback.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/14.
//

import Foundation

enum DoYouKnowFeedback: Int, CaseIterable {
	case allOfThem = 0
	case someOfThem = 1
	case fewOfThem = 2
	
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
}

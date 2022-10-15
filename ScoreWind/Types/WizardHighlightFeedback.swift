//
//  WizardHighlightFeedback.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/14.
//

import Foundation

enum WizardHighlightFeedback: Int, CaseIterable {
	case allOfThem = 0
	case someOfThem = 1
	case fewOfThem = 2
	
	func getLabel() -> String {
		switch self {
		case .allOfThem:
			return "All of them"
		case .someOfThem:
			return "Some of them"
		case .fewOfThem:
			return "Few of them"
		}
	}
}

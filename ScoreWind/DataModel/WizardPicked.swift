//
//  WizardRange.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/11/30.
//

import Foundation
struct WizardPicked {
	var courseID: Int
	var lessonID: Int
	var courseSortValue: String
	var lessonSortValue: String
	var feedbackValue: Int
	
	init() {
		courseID = 0
		lessonID = 0
		courseSortValue = ""
		lessonSortValue = ""
		feedbackValue = 0
	}
}

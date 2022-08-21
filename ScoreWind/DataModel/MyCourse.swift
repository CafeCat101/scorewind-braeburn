//
//  MyCourse.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/8/20.
//

import Foundation

struct MyCourse: Identifiable{
	var id: UUID
	var courseID: Int
	var courseTitle: String
	var courseShortDescription: String
	var completedLessons: [Int]
	var watchedLessons: [Int]
	var lastWatchedDate: String
	
	init() {
		id = UUID()
		courseID = 0
		courseTitle = ""
		courseShortDescription = ""
		completedLessons = []
		watchedLessons = []
		lastWatchedDate = ""
	}
}

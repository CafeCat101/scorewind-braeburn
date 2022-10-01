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
	var lastUpdatedDate: Date
	var downloadStatus: Int
	
	init() {
		id = UUID()
		courseID = 0
		courseTitle = ""
		courseShortDescription = ""
		completedLessons = []
		watchedLessons = []
		lastUpdatedDate = Date()
		downloadStatus = DownloadStatus.notInQueue.rawValue
	}
}

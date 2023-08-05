//
//  UsageActions.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/7/24.
//

import Foundation

enum UsageActions: String, CaseIterable {
	case launchApp = "launchApp"
	case selectJourney = "selectJourney"
	case selectExplore = "selectExplore"
	case selectAdvancing = "selectAdvancing"
	case viewCourse = "viewCourse"
	case viewLesson = "viewLesson"
	case viewMyCourse = "viewMyCourse"
	case viewPayWall = "viewPayWall"
	case lessonNoScore = "lessonNoScore"
	case lessonHasScore = "lessonHasScore"
	case viewLearningPath = "viewLearningPath"
	case error = "error"
	case streamLessonVideo = "streamLessonVideo"
}

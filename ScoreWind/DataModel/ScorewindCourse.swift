//
//  ScorewindCourse.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import Foundation

struct Course: Codable, Identifiable{
	var id: Int
	var title: String
	var content: String
	var image: String
	var tag: [String]
	var category: [CourseCategory]
	var shortDescription: String
	var instrument: String
	var level: String
	var sortValue: String
	var duration: String?
	var lessons: [Lesson]
	
	enum CodingKeys: String, CodingKey{
		case id = "id"
		case title = "course_title"
		case content = "course_content"
		case image = "course_image"
		case tag = "course_tag"
		case category = "course_category"
		case shortDescription = "course_short_description"
		case instrument = "course_instrument"
		case level = "course_level"
		case sortValue = "course_sort_value"
		case duration = "course_duration"
		case lessons = "lessons"
	}
	
	init(){
		id = 0
		title = "Scorewind Course"
		content = "<h4>Highlights</h4>\n<ul>\n <li>\nLearn how to plau</li>\n <li>\nHave good time with your instrument</li>\n</ul>\n<h4>Description</h4>\nCourses are prepared to focus on a specific subject or technique and they are shaped in a progressive way for the player to get better at a given subject. Want it in a nutshell? In courses you will find unique progressive paths, designed with a step by step approach. They are available for various levels and instruments, and you will have the chance to practice specific techniques or develop stylistic interpretation based on composer.\n<h4>Requirement</h4>\n<ul>\n <li>\nHave your instrument.</li>\n <li>\nSubscribe the app</li>\n</ul>\n<h4>What's next</h4>\n<p style=\"margin-bottom: 0px;\">Next course: <a href=\"https://scorewind.com/courses/guitar-103-2-finger-2-and-3-on-one-string/#tab-course-section__overview\">Next course name</a></p>"
		image = "course/image"
		tag = ["tag"]
		category = [CourseCategory()]
		shortDescription = ""
		instrument = ""
		level = "beginner"
		sortValue = ""
		duration = "1d"
		lessons = [Lesson()]
		
	}

	
}


struct CourseCategory: Codable, Identifiable{
	var id: Int
	var parent: Int
	var name: String
	
	init(){
		id = 0
		parent = 0
		name = "Main"
	}
}


struct Lesson: Codable, Identifiable{
	var id: Int
	var scorewindID: Int
	var title: String
	var content: String
	var description: String
	var composer: String
	var video: String
	var videoMP4: String
	var scoreViewer: String
	var image: String
	var step: Int
	var sortValue: String
	
	enum CodingKeys: String, CodingKey{
		case id = "id"
		case scorewindID = "scorewind_id"
		case title = "lesson_title"
		case content = "lesson_content"
		case description = "lesson_short_description"
		case composer = "lesson_composer"
		case video = "lesson_mp3u8"
		case videoMP4 = "lesson_video"
		case scoreViewer = "lesson_score_viewer"
		case image = "lesson_image"
		case step = "lesson_step"
		case sortValue = "lesson_sort_value"
	}
	
	init(){
		id = 0
		scorewindID = 0
		title = "Scorewind Lesson"
		content = "Self study music is a joyful journey. It fills your soul, challenges your mind and gives you a path to share your passions. Self study is one of many ways to learn to play music. It’s affordable, and offers flexible studying hours. You can learn at your own pace, and develop your learning path based on your own interests. So, why wait, let’s start playing music!"
		description = "In the lesson, scorewind teacher prepare vidoe and score for you to learn how to play easier than ever!"
		composer = "Scorewind Teacher"
		video = "lesson/video"
		videoMP4 = "lesson/videoMP4"
		scoreViewer = "lesson/scoreViewer"
		image = "lesson/image"
		step = 1
		sortValue = ""
	}
}

//
//  WizardCalculator.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/23.
//

import Foundation

extension ScorewindData {
	func createRecommendation(availableCourses:[Course], studentData: StudentData) -> Page {
		var assignedCourseId = 0
		var assignedLessonId = 0
		var goToWizardStep:Page = .wizardChooseInstrument
		let currentStepName = studentData.wizardStepNames[studentData.wizardStepNames.count-1]
		
		if currentStepName == Page.wizardExperience {
			if studentData.getExperience() == ExperienceFeedback.continueLearning.rawValue {
				if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
					assignedCourseId = 96111
					assignedLessonId = 0//95419
				} else if studentData.getInstrumentChoice() == InstrumentType.violin.rawValue {
					assignedCourseId = 94882
					assignedLessonId = 0//94949
				}
				
			} else {
				if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
					assignedCourseId = 93950
					assignedLessonId = 90696
				} else if studentData.getInstrumentChoice() == InstrumentType.violin.rawValue {
					assignedCourseId = 94069
					assignedLessonId = 90662
				}
				goToWizardStep = .wizardResult
			}
		}
		
		if currentStepName == .wizardDoYouKnow {
			print("[debug] createRecommendation, getDoYouKnow \(studentData.getDoYouKnow())")
			let getCurrentDoYouKnow = studentData.getDoYouKnow().first(where: {$0.key == String(wizardPickedCourse.id)})
			let finalFeedback = getDoYouKnowScore(answers: getCurrentDoYouKnow?.value as! [Int])
			print("[debug] createRecommendation, finalFeedback \(finalFeedback)")
			
			if wizardPickedCourse.id > 0 {
				if finalFeedback == .allOfThem {
					// "playable" to find the last lesson with score in current course
					let getLastLessonInCourse = assignLastLessonInCourse(targetCourse: wizardPickedCourse)
					assignedCourseId = getLastLessonInCourse["courseID"] ?? 0
					assignedLessonId = getLastLessonInCourse["lessonID"] ?? 0
				} else if finalFeedback == .someOfThem {
					// "Playable" to find the middle lesson with score in previous course
					let getMiddleLesson = assignMiddleLessonInCourse(targetCourse: wizardPickedCourse)
					assignedCourseId = getMiddleLesson["courseID"] ?? 0
					assignedLessonId = getMiddleLesson["lessonID"] ?? 0
				} else {
					// "Do you know" to previous course
					assignedCourseId = assignPrevioudCourse(targetCourse: wizardPickedCourse)
					assignedLessonId = 0
				}
			}
		}
		
		if assignedCourseId > 0 {
			wizardPickedCourse = availableCourses.first(where: {$0.id == assignedCourseId}) ?? Course()
			print("[debug] createRecommendation, assignCourseId \(assignedCourseId)")
		} else {
			wizardPickedCourse = Course()
		}
		
		if assignedLessonId > 0 {
			wizardPickedLesson = wizardPickedCourse.lessons.first(where: {$0.id == assignedLessonId}) ?? Lesson()
			wizardPickedTimestamps = (allTimestamps.first(where: {$0.id == assignedCourseId})?.lessons.first(where: {$0.id == assignedLessonId})!.timestamps)!
			print("[debug] createRecommendation, assignLessonId \(assignedLessonId)")
		} else {
			wizardPickedLesson = Lesson()
			wizardPickedTimestamps = []
		}
		
		
		if assignedCourseId > 0 && assignedLessonId > 0 {
			goToWizardStep = .wizardPlayable
		} else {
			goToWizardStep = .wizardDoYouKnow
		}
		return goToWizardStep
	}
	
	private func findSortOrderString(targetCourse: Course, order: SearchParameter) -> String {
		let sortOrderArr = currentCourse.sortValue.components(separatedBy: "-")
		print("[debug] WizardCalculator, sortOrderArr \(sortOrderArr)")
		var sortOrderStr = ""
		
		if sortOrderArr.count > 0 {
			let incrementNumber = (order == SearchParameter.ASC) ? 1 : -1
			
			if sortOrderArr.count > 1 {
				print("[debug] WizardCalculator, increasement \((Int(sortOrderArr[1]) ?? 0) + incrementNumber)")
				sortOrderStr = sortOrderArr[0]+"-"+String((Int(sortOrderArr[1]) ?? 0) + incrementNumber)
			} else if sortOrderArr.count == 1 {
				print("[debug] WizardCalculator, increasement \((Int(sortOrderArr[0]) ?? 0) + incrementNumber)")
				sortOrderStr = String((Int(cleanSortOrder(sortValue: sortOrderArr[0])) ?? 0) + incrementNumber)
			}
			print("[debug] WizardCalculator, sortOrderStr \(sortOrderStr)")
		}
		
		return sortOrderStr
	}
	
	private func assignPrevioudCourse(targetCourse: Course) -> Int {
		var findCourse = Course()
		if targetCourse.sortValue.isEmpty == false {
			let previoudSortValue = findSortOrderString(targetCourse: targetCourse, order: .DESC)
			if previoudSortValue.isEmpty == false {
				findCourse = allCourses.first(where: {cleanSortOrder(sortValue: $0.sortValue) == previoudSortValue && $0.instrument == currentCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: currentCourse.category, depth: 2)}) ?? Course()
			}
		}
		return findCourse.id
	}
	
	private func assignLastLessonInCourse(targetCourse: Course) -> [String:Int] {
		var result:[String:Int] = [:]
		let currentLessons = targetCourse.lessons
		for lesson in currentLessons.sorted(by: {$0.step > $1.step}) {
			let findTimestamps = (allTimestamps.first(where: {$0.id == targetCourse.id})?.lessons.first(where: {$0.id == lesson.id})!.timestamps)!
			if findTimestamps.count > 0 {
				result["courseID"] = wizardPickedCourse.id
				result["lessonID"] = lesson.id
				break
			}
		}
		return result
	}
	
	private func assignMiddleLessonInCourse(targetCourse: Course) -> [String:Int] {
		var result:[String:Int] = [:]
		var lessonWithScore:[Int] = []
		for lesson in targetCourse.lessons {
			let findTimestamps = (allTimestamps.first(where: {$0.id == targetCourse.id})?.lessons.first(where: {$0.id == lesson.id})!.timestamps)!
			if findTimestamps.count > 0 {
				lessonWithScore.append(lesson.id)
			}
		}
		
		if lessonWithScore.count > 0 {
			result["courseID"] = targetCourse.id
			var middleIndex:Double = Double((lessonWithScore.count/2))
			middleIndex.round(.towardZero)
			result["lessonID"] = lessonWithScore[Int(middleIndex)]
		}
		
		return result
	}
	
	private func getDoYouKnowScore(answers:[Int]) -> DoYouKnowFeedback {
		print("[debug] getDoYouKnowScore, answers \(answers)")
		let scoreTotal = answers.reduce(0,+)
		let scoreAverage = scoreTotal/answers.count
		print("[debug] getDoYouKnowScore, scoreAverage \(scoreAverage)")
		
		var calculateScore:[DoYouKnowFeedback:Double] = [:]
		
		for feedback in DoYouKnowFeedback.allCases {
			let absoluteDiff = abs((Double(feedback.rawValue)) - Double(scoreAverage))
			print("[debug] getDoYouKnowScore, feedbackRaw \(feedback.rawValue) : absoluteDiff \(absoluteDiff)")
			calculateScore[feedback] = absoluteDiff
		}
		
		let sortedScores = calculateScore.sorted(by: {$0.value < $1.value})
		print("[debug] getDoYouKnowScore, sortedScores \(sortedScores)")
		return sortedScores[0].key
		
	}

}

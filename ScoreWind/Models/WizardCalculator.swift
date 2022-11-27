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
					let guitar103Courses = availableCourses.filter({$0.instrument == InstrumentType.guitar.rawValue && $0.category.contains(where: {$0.name == "Guitar 103"})})
					if guitar103Courses.count > 0 {
						assignedCourseId = guitar103Courses.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})[0].id //G103.1 id:96100
						assignedLessonId = 0
					} else {
						//remember to handle this
					}
				} else if studentData.getInstrumentChoice() == InstrumentType.violin.rawValue {
					let violin103Courses = availableCourses.filter({$0.instrument == InstrumentType.violin.rawValue && $0.category.contains(where: {$0.name == "Violin 103"})})
					if violin103Courses.count > 0 {
						assignedCourseId = violin103Courses.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})[0].id //V103.1 id:98384
						assignedLessonId = 0
					} else {
						//remember to handle this
					}
				}
			} else {
				let veryFirstCourse = availableCourses.first(where: {$0.instrument == studentData.getInstrumentChoice() && $0.sortValue == "1"}) ?? Course()
				if veryFirstCourse.id > 0 {
					assignedCourseId = veryFirstCourse.id
					assignedLessonId = veryFirstCourse.lessons[0].id
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
					let previousCourse = assignPrevioudCourse(targetCourse: wizardPickedCourse)
					
					if previousCourse.category.contains(where: {$0.name == "Guitar 102" || $0.name == "Guitar 101" || $0.name == "Violin 101" || $0.name == "Violin 102"}) {
						let veryFirstCourse = availableCourses.first(where: {$0.instrument == studentData.getInstrumentChoice() && $0.sortValue == "1"}) ?? Course()
						assignedCourseId = veryFirstCourse.id
						assignedLessonId = 0
					} else {
						let getMiddleLesson = assignMiddleLessonInCourse(targetCourse: previousCourse)
						assignedCourseId = getMiddleLesson["courseID"] ?? 0
						assignedLessonId = getMiddleLesson["lessonID"] ?? 0
					}
				} else {
					// "Do you know" to previous course
					let previousCourse = assignPrevioudCourse(targetCourse: wizardPickedCourse)
					
					if previousCourse.category.contains(where: {$0.name == "Guitar 102" || $0.name == "Guitar 101" || $0.name == "Violin 101" || $0.name == "Violin 102"}) {
						let veryFirstCourse = availableCourses.first(where: {$0.instrument == studentData.getInstrumentChoice() && $0.sortValue == "1"}) ?? Course()
						assignedCourseId = veryFirstCourse.id
					} else {
						assignedCourseId = assignPrevioudCourse(targetCourse: wizardPickedCourse).id
					}
					
					assignedLessonId = 0
					
					/**FOR GIVING THE APP TO ESIN AND RICARDO ONLY**/
					/*if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
						assignedCourseId = 93950
						assignedLessonId = 90696
					} else if studentData.getInstrumentChoice() == InstrumentType.violin.rawValue {
						assignedCourseId = 94069
						assignedLessonId = 90662
					}
					goToWizardStep = .wizardResult*/
					/***********************************************/
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
			wizardPickedTimestamps = (allTimestamps.first(where: {$0.id == assignedCourseId})?.lessons.first(where: {$0.id == assignedLessonId})!.timestamps) ?? []
			print("[debug] createRecommendation, assignLessonId \(assignedLessonId)")
		} else {
			wizardPickedLesson = Lesson()
			wizardPickedTimestamps = []
		}
		
		if goToWizardStep != .wizardResult {
			if assignedCourseId > 0 && assignedLessonId > 0 {
				goToWizardStep = .wizardPlayable
			} else {
				goToWizardStep = .wizardDoYouKnow
			}
		}
		
		print("[debug] createRecommendation, goToWizardStep \(goToWizardStep)")
		return goToWizardStep
	}
	
	private func findSortOrderString(targetCourse: Course, order: SearchParameter) -> String {
		let sortOrderArr = targetCourse.sortValue.components(separatedBy: "-")
		print("[debug] WizardCalculator, course.id \(targetCourse.id), sortOrderArr \(sortOrderArr)")
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
	
	private func assignPrevioudCourse(targetCourse: Course) -> Course {
		var findCourse = Course()
		if targetCourse.sortValue.isEmpty == false {
			let previoudSortValue = findSortOrderString(targetCourse: targetCourse, order: .DESC)
			if previoudSortValue.isEmpty == false {
				findCourse = allCourses.first(where: {cleanSortOrder(sortValue: $0.sortValue) == previoudSortValue && $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2)}) ?? Course()
			}
		}
		return findCourse
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

//
//  WizardCalculatorHelper.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/22.
//

import Foundation
class WizardCalculatorHelper:ScorewindData {
	func assignPreviousCourse(targetCourse: Course, studentData: StudentData) -> Course {
		var findCourse = Course()
		var sameCategoryCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) && Int($0.sortValue)! < Int(targetCourse.sortValue)! })
		
		sameCategoryCourses = excludeCoursesCompleted(targetCourse: sameCategoryCourses, useStudentData: studentData)
		
		if sameCategoryCourses.count > 0 {
			findCourse = sameCategoryCourses.sorted(by: {Int($0.sortValue)! > Int($1.sortValue)!})[0]
		}
		
		return findCourse
	}
	
	func assignNextCourse(targetCourse: Course, studentData: StudentData) -> Course {
		var findCourse = Course()
		var sameCategoryCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) && Int($0.sortValue)! > Int(targetCourse.sortValue)! })
		
		sameCategoryCourses = excludeCoursesCompleted(targetCourse: sameCategoryCourses, useStudentData: studentData)
		
		if sameCategoryCourses.count > 0 {
			findCourse = sameCategoryCourses.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})[0]
		}
		return findCourse
	}
	

	
	/*
	 Exclude courses have all lessons marked completed
	 */
	func excludeCoursesCompleted(targetCourse: [Course], useStudentData: StudentData) -> [Course] {
		var processed:[Course] = targetCourse
		
		for courseItem in useStudentData.myCourses {
			let findACourseInAll = allCourses.first(where: {$0.id == courseItem.courseID})
			if courseItem.completedLessons.count == findACourseInAll?.lessons.count {
				processed.removeAll(where: {$0.id == courseItem.courseID})
			}
		}
		
		return processed
	}
	
	func excludeLessonsAsked(targetLessons: [Lesson], useStudentData: StudentData) -> [Lesson] {
		var processLessons = targetLessons
		
		for rangeItem in useStudentData.wizardRange {
			processLessons.removeAll(where: {$0.id == rangeItem.lessonID})
		}
		
		return processLessons
	}
	
	func excludeLessonsCompleted(targetCourseID: Int, targetLessons: [Lesson], useStudentData: StudentData) -> [Lesson] {
		var processLessons = targetLessons
		let findCourseInMine = useStudentData.myCourses.first(where: {$0.courseID == targetCourseID})
		
		if findCourseInMine?.completedLessons.count ?? 0 > 0 {
			for lessonItem in findCourseInMine?.completedLessons ?? [] {
				print("[debug] wizardCalculator, excldueLessonsCompleted, completedLessonItem \(lessonItem)")
				processLessons.removeAll(where: {$0.scorewindID == lessonItem})
			}
			print("[debug] wizardCalculator, excldueLessonsCompleted, processLessons.count \(processLessons.count)")
		}
		
		return processLessons
	}
	
	/*
	 Find the last lesson that is not completed, not asked and is playable in the selected course.
	 Use case: feedback "All of them" from DoYouKnow view. Designed to go to IsPlayable view only
	 */
	func assignLastLessonInCourse(targetCourse: Course, useStudentData:StudentData) -> [String:Int] {
		var result:[String:Int] = [:]
		var currentLessons = targetCourse.lessons
		
		currentLessons = excludeLessonsAsked(targetLessons: currentLessons, useStudentData: useStudentData)
		currentLessons = excludeLessonsCompleted(targetCourseID: targetCourse.id, targetLessons: currentLessons, useStudentData: useStudentData)
		
		for lesson in currentLessons.sorted(by: {$0.step > $1.step}) {
			if checkIfLessonPlayable(targetCourseID: targetCourse.id, targetLesson: lesson) {
				result["courseID"] = wizardPickedCourse.id
				result["lessonID"] = lesson.id
				break
			}
		}
		return result
	}
	
	func getDoYouKnowScore(answers:[Int]) -> DoYouKnowFeedback {
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
	
	func getNextLessons(targetCourse: Course, targetLesson: Lesson, useStudnetData: StudentData, range: Int) -> [WizardLessonSearched]{
		print("[debug] wizardCalcaultor, getNextLessons, range \(range)")
		var lessons:[WizardLessonSearched] = []
		var nextCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) && Int($0.sortValue)! >= Int(targetCourse.sortValue)! })
		
		nextCourses = nextCourses.sorted(by: { Int($0.sortValue)! < Int($1.sortValue)!})
		print("[debug] wizardCalcaultor, getNextLessons, nextCourses[0].title \(nextCourses[0].title)")
		nextCourses = excludeCoursesCompleted(targetCourse: nextCourses, useStudentData: useStudnetData)
		lessons = appendLessonsFromCourses(targetLessonStep:targetLesson.step ,courseCollection: nextCourses, useStudnetData: useStudnetData, limit: range, appendingOrder: .ASC)
		
		return lessons
	}
	
	func getPreviousLessons(targetCourse: Course, targetLesson: Lesson, useStudnetData: StudentData, range: Int) -> [WizardLessonSearched] {
		print("[debug] wizardCalcaultor, getPreviousLessons, range \(range)")
		var lessons:[WizardLessonSearched] = []
		var previousCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) && Int($0.sortValue)! <= Int(targetCourse.sortValue)! })
		
		previousCourses = previousCourses.sorted(by: {Int($0.sortValue)! > Int($1.sortValue)!})
		previousCourses = excludeCoursesCompleted(targetCourse: previousCourses, useStudentData: useStudnetData)
		lessons = appendLessonsFromCourses(targetLessonStep:targetLesson.step ,courseCollection: previousCourses, useStudnetData: useStudnetData, limit: range, appendingOrder: .DESC)
		
		return lessons
	}
	
	func checkIfLessonPlayable(targetCourseID: Int,targetLesson: Lesson) -> Bool {
		var result = false
		let findTimestamps = (allTimestamps.first(where: {$0.id == targetCourseID})?.lessons.first(where: {$0.id == targetLesson.id})!.timestamps)!
		let playableBars = findTimestamps.filter({($0.notes == "" || $0.notes == "play") && $0.type == "piano"})
		
		if findTimestamps.count > 0 && playableBars.count > 0 {
			result = true
		}
		
		return result
	}
	
	func appendLessonsFromCourses(targetLessonStep: Int,courseCollection: [Course], useStudnetData: StudentData, limit: Int, appendingOrder: SearchParameter) -> [WizardLessonSearched] {
		var lessons:[WizardLessonSearched] = []
		
		//courseCollection has the current wizardPickedCourse
		if courseCollection.count > 0 {
			for course in courseCollection {
				print("[debug] appendLessonsFromCourses, course.id \(course.title)")
				if course.category.contains(where: {$0.name == "Methods"}) && course.category.contains(where: {$0.name == "Step By Step"}) && course.category.count == 2 {
					if course.id == courseCollection[0].id {
						//StepByStep before 101 only last lesson is revelant so there is no need to process other lesson in current course
						continue
					}
					
					var lessonsInCourse = [course.lessons[course.lessons.count-1]]
					lessonsInCourse = excludeLessonsAsked(targetLessons: lessonsInCourse, useStudentData: useStudnetData)
					lessonsInCourse = excludeLessonsCompleted(targetCourseID: course.id, targetLessons: lessonsInCourse, useStudentData: useStudnetData)
					if lessonsInCourse.count > 0 {
						for lesson in lessonsInCourse {
							if checkIfLessonPlayable(targetCourseID: course.id, targetLesson: lesson) {
								lessons.append(WizardLessonSearched(courseID: course.id, lesson: lesson))
								print("[debug] appendLessonsFromCourses, StepByStep course before 101, lessons.count \(lessons.count):\(limit)")
								if lessons.count >= limit {
									break
								}
							}
						}
					}
				} else {
					var lessonsInCourse = course.lessons
					
					if appendingOrder == .DESC {
						lessonsInCourse.reverse()
					}
					
					lessonsInCourse = excludeLessonsAsked(targetLessons: lessonsInCourse, useStudentData: useStudnetData)
					lessonsInCourse = excludeLessonsCompleted(targetCourseID: course.id, targetLessons: lessonsInCourse, useStudentData: useStudnetData)
					if lessonsInCourse.count > 0 {
						for lesson in lessonsInCourse {
							print("[debug] appendLessonsFromCourses, StepByStep or Path course, lesson.step \(lesson.step):targetLessonStep \(targetLessonStep)")
							if course.id == courseCollection[0].id {
								//becasue courseCollection[0] is the current wizardPickedCourse, don't process the lesson level before or after wizardPickedLesson
								if appendingOrder == .ASC {
									if lesson.step <= targetLessonStep {
										continue
									}
								} else {
									if lesson.step >= targetLessonStep {
										continue
									}
								}
							}
							
							let sortValues = lesson.sortValue.split(separator:"-")
							print("[debug] appendLessonsFromCourses, StepByStep or Path course, lesson.sortValue \(sortValues[0])-\(sortValues[1])")
							let lessonsAtSameLessonLevel = useStudnetData.wizardRange.filter({ $0.lessonSortValue.contains(sortValues[0]+"-"+sortValues[1]) })
							print("[debug] appendLessonsFromCourses, StepByStep or Path course, lessonsAtSameLessonLevel.count \(lessonsAtSameLessonLevel.count)")
							if lessonsAtSameLessonLevel.count > 0 {
								print("[debug] appendLessonsFromCourses, StepByStep or Path course, wizardRange contains more than 1 \(sortValues[0])-\(sortValues[1])")
								continue
							}
							
							if checkIfLessonPlayable(targetCourseID: course.id, targetLesson: lesson) {
								lessons.append(WizardLessonSearched(courseID: course.id, lesson: lesson))
								print("[debug] appendLessonsFromCourses, StepByStep or Path course, lessons.count \(lessons.count):\(limit)")
								if lessons.count >= limit {
									break
								}
							}
						}
					}
				}
				
				if lessons.count >= limit {
					break
				}
			}
		}
		
		return lessons
	}
	
	private func convertDoYouKnowFeedback(feedbackValue: Int) -> Double {
		print("[debug] wizardCalcaultor, convertDoYouKnowFeedback, feedbaclValue \(feedbackValue)")
		print("[debug] wizardCalcaultor, convertDoYouKnowFeedback, PlayableFeedback.allCases.count \(PlayableFeedback.allCases.count)")
		print("[debug] wizardCalcaultor, convertDoYouKnowFeedback, DoYouKnowFeedback.allCases.count \(DoYouKnowFeedback.allCases.count)")
		let originalDouble = Double((PlayableFeedback.allCases.count*feedbackValue))/Double(DoYouKnowFeedback.allCases.count)
		return round(originalDouble * 10) / 10.0
	}
	
	func explorerAlgorithm(useStudentData: StudentData) -> [String:Int] {
		var result:[String:Int] = [:]
		var sortedWizardRange:[WizardPicked] = useStudentData.wizardRange
		
		var sumFeedback = 0.0
		for rangeItem in sortedWizardRange {
			sumFeedback = sumFeedback + rangeItem.feedbackValue
		}
		
		let averageFeedbackValue = sumFeedback / Double(sortedWizardRange.count)

		print("[debug] wizardCalcaultor, explorerAlgorithm, sorted \(sortedWizardRange)")
		
		sortedWizardRange = sortedWizardRange.sorted(by: {$0.sortHelper < $1.sortHelper}).filter({$0.feedbackValue < averageFeedbackValue})
		
		result["courseID"] = sortedWizardRange[0].courseID
		result["lessonID"] = sortedWizardRange[0].lessonID
		return result
	}
	
	func assesmentAlgorithm(useStudentData: StudentData, exampleCourse: Course) -> [String:Int] {
		var result:[String:Int] = [:]
		let sortedWizardRange:[WizardPicked] = useStudentData.wizardRange
		
		let itemWithHighestFeedbackValue = sortedWizardRange.max(by: {$0.feedbackValue < $1.feedbackValue})
		let narrowSortedWizardRange = sortedWizardRange.filter({$0.feedbackValue <= itemWithHighestFeedbackValue!.feedbackValue})
		let averageSortHelperValue = (narrowSortedWizardRange[0].sortHelper + narrowSortedWizardRange[narrowSortedWizardRange.count-1].sortHelper)/2
		let extractCourseSortValue:Int = Int(averageSortHelperValue.rounded(.down))
		
		var coursesTroProcess = allCourses.filter({ $0.instrument == exampleCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: exampleCourse.category, depth: 2) && Int($0.sortValue)! >= extractCourseSortValue })
		
		coursesTroProcess = excludeCoursesCompleted(targetCourse: coursesTroProcess, useStudentData: useStudentData).sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
		
		for course in coursesTroProcess {
			let findUncompletedLessons = excludeLessonsCompleted(targetCourseID: course.id, targetLessons: course.lessons, useStudentData: useStudentData)
			if findUncompletedLessons.count > 0 {
				result["courseID"] = course.id
				result["lessonID"] = findUncompletedLessons[0].id
				break
			}
		}
		
		return result
	}
	
	func getUncompletedLessonsFromCourses(sortedCourses:[Course], lessonCount: Int, useStudentData: StudentData, onlyPlayable: Bool = false) -> [WizardPicked] {
		var uncompletedLessons:[WizardPicked] = []
		var sortedCourses = sortedCourses
		print("[debug] wizardCalculator, getUncompletedLessonsFromCourses, onlyPlayable true")
		sortedCourses = excludeCoursesCompleted(targetCourse: sortedCourses, useStudentData: useStudentData)
		outerLoop:for course in sortedCourses {
			print("[debug] wizardCalculator, getUncompletedLessonsFromCourses, course \(course.title)")
			for lesson in excludeLessonsCompleted(targetCourseID: course.id, targetLessons: course.lessons, useStudentData: useStudentData) {
				print("[debug] wizardCalculator, getUncompletedLessonsFromCourses, lesson \(lesson.title)")
				
				if onlyPlayable {
					
					if checkIfLessonPlayable(targetCourseID: course.id, targetLesson: lesson) {
						uncompletedLessons.append(WizardPicked(allCourses: [course], courseID: course.id, lessonID: lesson.id, feedbackValue: 0.0))
					}
				} else {
					uncompletedLessons.append(WizardPicked(allCourses: [course], courseID: course.id, lessonID: lesson.id, feedbackValue: 0.0))
				}

				print("[debug] wizardCalculator, getUncompletedLessonsFromCourses, uncompletedLesson.count \(uncompletedLessons.count)")
				if uncompletedLessons.count == lessonCount {
					break outerLoop
				}
				
			}
		}
		return uncompletedLessons
	}
}

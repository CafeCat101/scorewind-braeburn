//
//  WizardCalculatorHelper.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/19.
//

import Foundation

extension ScorewindData {/*
	private func areLessonsInCourseAsked(targetCourseID: Int, range: [WizardPicked]) -> Bool {
		let theCourse = allCourses.first(where: {$0.id == targetCourseID}) ?? Course()
		var askedCount = 0
		
		for lesson in theCourse.lessons {
			if range.contains(where: {$0.courseID == theCourse.id && $0.lessonID == lesson.id}) {
				askedCount = askedCount + 1
			}
		}
		
		if askedCount == 0 {
			return false
		} else {
			return true
		}
	}
	
	/*
	 Use case: from DoYouKnow view-some what familiar. It's asking the middle lesson from course in previous level
	 */
	private func assignMiddleLessonInCourse(targetCourse: Course, useStudentData: StudentData) -> [String:Int] {
		var result:[String:Int] = [:]
		var lessonWithScore:[Int] = []
		var targetLessons = targetCourse.lessons
		
		//:: only ask lesson not completed and not asked yet
		targetLessons = excludeLessonsAsked(targetLessons: targetLessons, useStudentData: useStudentData)
		targetLessons = excludeLessonsCompleted(targetCourseID: targetCourse.id, targetLessons: targetLessons, useStudentData: useStudentData)
		
		for lesson in targetLessons {
			if checkIfLessonPlayable(targetCourseID: targetCourse.id, targetLesson: lesson) {
				lessonWithScore.append(lesson.id)
			}
		}
		
		if lessonWithScore.count > 0 {
			//:: found lessons with playable bars, calculate the index in the middle
			result["courseID"] = targetCourse.id
			var middleIndex:Double = Double((lessonWithScore.count/2))
			middleIndex.round(.towardZero)
			result["lessonID"] = lessonWithScore[Int(middleIndex)]
		} else {
			//:: prompt DoYouKnow view instead
			result["courseID"] = targetCourse.id
			result["lessonID"] = 0
		}
		
		return result
	}
	
	/*
	 Find lesson in next level in current course first. If it's not available, find it in the course in next level.
	 */
	private func assignLessonInNextLevel(targetCourse: Course, targetLesson: Lesson, studentData: StudentData) -> [String: Int] {
		var result:[String:Int] = [:]

		let nextLesson:Lesson = findAdjacentLessonInCurrentCourse(targetCourse: targetCourse, targetLesson: targetLesson, direction: .ASC, useStudentData: studentData)
		if nextLesson.id > 0 {
			result["courseID"] = targetCourse.id
			result["lessonID"] = nextLesson.id
		} else {
			let nextCourse = assignNextCourse(targetCourse: targetCourse, studentData: studentData)
			
			if nextCourse.id == 0 {
				 //:: can't find course in next level, probably the end of it.
				result["courseID"] = 0
				result["lessonID"] = 0
			} else{
				if nextCourse.category.contains(where: {$0.name == "Methods"}) && nextCourse.category.contains(where: {$0.name == "Step By Step"}) && nextCourse.category.count == 2 {
					//:: step by step course made before 101 series is found(speical case), only the last lesson is revelent to the wizard
					 
					let sameCategoryCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && $0.category.contains(where: {$0.name == "Method"}) && $0.category.contains(where: {$0.name == "Step By Step"}) && $0.category.count == 2 && Int($0.sortValue)! > Int(targetCourse.sortValue)! })
					for courseItem in sameCategoryCourses {
						let lastLessonID = courseItem.lessons.last?.id ?? 0
						
						if studentData.myCourses.contains(where: {$0.courseID == courseItem.id && $0.completedLessons.contains(where: {$0 == lastLessonID})}) == false && studentData.wizardRange.contains(where: {$0.lessonID == lastLessonID}) {
							//:: verify the last lesson it not completed and ot not asked yet
							//:: no need to prompt DoYouKnow because only the lsat lesson is revelent
							result["courseID"] = courseItem.id
							result["lessonID"] = lastLessonID
							break
						}
					}
					
				} else {
					//:: find lesson from course in next level, only process those not completed and not being asked
					var processLessons = nextCourse.lessons
					processLessons = excludeLessonsAsked(targetLessons: processLessons, useStudentData: studentData)
					processLessons = excludeLessonsCompleted(targetCourseID: targetCourse.id, targetLessons: processLessons, useStudentData: studentData)
					
					for lesson in processLessons {
						let findTimestamps = (allTimestamps.first(where: {$0.id == nextCourse.id})?.lessons.first(where: {$0.id == lesson.id})!.timestamps)!
						let playableBars = findTimestamps.filter({($0.notes == "" || $0.notes == "play") && $0.type == "piano"})
						if findTimestamps.count > 0 && playableBars.count > 0 {
							//:: only show the lesson has playable bar availalbe
							let anyPlayableLessonAsked = studentData.wizardRange.contains(where: { ($0.courseID == nextCourse.id) && ($0.lessonSortValue.isEmpty == false)} )
							if anyPlayableLessonAsked {
								result["courseID"] = nextCourse.id
								result["lessonID"] = lesson.id
								break
							} else {
								//:: if this course has not been asked in DoYouKnow view, prompt DoYouKnow view
								result["courseID"] = nextCourse.id
								result["lessonID"] = 0
								break
							}
						}
					}
				}
			}
		}
		
		return result
	}
	
	private func assignLessonInPreviousLevel(targetCourse: Course, targetLesson: Lesson, studentData: StudentData) -> [String:Int] {
		var result:[String:Int] = [:]
		
		let previousLevelLesson:Lesson = findAdjacentLessonInCurrentCourse(targetCourse: targetCourse, targetLesson: targetLesson, direction: .DESC, useStudentData: studentData)
		if previousLevelLesson.id > 0 {
			result["courseID"] = targetCourse.id
			result["lessonID"] = previousLevelLesson.id
		} else {
			let previousCourse = assignPreviousCourse(targetCourse: targetCourse, studentData: studentData)
			
			if previousCourse.id == 0 {
				//at first course, no course before this
				result["courseID"] = 0
				result["lessonID"] = 0
			} else {
				if studentData.wizardRange.contains(where: {$0.courseID == previousCourse.id}) == true {
					if previousCourse.category.contains(where: {$0.name == "Methods"}) && previousCourse.category.contains(where: {$0.name == "Step By Step"}) && previousCourse.category.count == 2 {
						//this is the step by step made before 101 series
						result["courseID"] = previousCourse.id
						result["lessonID"] = previousCourse.lessons.last?.id ?? 0
					} else {
						for lesson in previousCourse.lessons.sorted(by: {$0.step > $1.step}) {
							let findTimestamps = (allTimestamps.first(where: {$0.id == previousCourse.id})?.lessons.first(where: {$0.id == lesson.id})!.timestamps)!
							let playableBars = findTimestamps.filter({($0.notes == "" || $0.notes == "play") && $0.type == "piano"})
							if findTimestamps.count > 0 && playableBars.count > 0 {
								result["courseID"] = previousCourse.id
								result["lessonID"] = lesson.id
								break
							}
						}
					}
				} else {
					result["courseID"] = previousCourse.id
					result["lessonID"] = 0
				}
				
			}
		}
		
		return result
	}
	
	private func findAdjacentLessonInCurrentCourse(targetCourse: Course, targetLesson: Lesson, direction: SearchParameter, useStudentData: StudentData) -> Lesson {
		var result:Lesson = Lesson()
		let levelBreakdown1 = targetLesson.sortValue.split(separator: "-")
		
		var processLessons = targetCourse.lessons
		processLessons = excludeLessonsAsked(targetLessons: processLessons, useStudentData: useStudentData)
		processLessons = excludeLessonsCompleted(targetCourseID: targetCourse.id, targetLessons: processLessons, useStudentData: useStudentData)
		
		if Int(levelBreakdown1[1]) == 0 && Int(levelBreakdown1[2]) == 0 {
			//the StepByStep made before 101 series only the last lesson has level meaning to wizard
		} else {
			var lessons:[Lesson] = []
			if direction == .ASC {
				lessons = (processLessons).filter({$0.step>targetLesson.step})
			} else {
				lessons = (processLessons).filter({$0.step<targetLesson.step})
				lessons.reverse()
			}
			
			var findScoreAvailable = false
			for lesson in lessons {
				let levelBreakDown2 = lesson.sortValue.split(separator: "-")
				
				if (direction == .ASC) && ( Int(levelBreakDown2[1])! > Int(levelBreakdown1[1])! ) {
					findScoreAvailable = true
				} else if (direction == .DESC) && ( Int(levelBreakDown2[1])! < Int(levelBreakdown1[1])! ) {
					findScoreAvailable = true
				}
				
				if findScoreAvailable {
					let findTimestamps = (allTimestamps.first(where: {$0.id == targetCourse.id})?.lessons.first(where: {$0.id == lesson.id})!.timestamps)!
					let playableBars = findTimestamps.filter({($0.notes == "" || $0.notes == "play") && $0.type == "piano"})
					if findTimestamps.count > 0 && playableBars.count > 0 {
						result = lesson
						break
					}
				}
			}
		}
		
		
		return result
	}
	
	private func assignEquivalentLessonInNextCourseLevel(targetCourse: Course, targetLesson: Lesson, studentData: StudentData) -> [String:Int]{
		var result:[String:Int] = [:]
		let nextCourse = assignNextCourse(targetCourse: targetCourse, studentData: studentData)
		
		if nextCourse.id == 0 {
			//no more course after the target
			result["courseID"] = 0
			result["lessonID"] = 0
		} else {
			if studentData.wizardRange.contains(where: {$0.courseID == nextCourse.id}) == true {
				if nextCourse.category.contains(where: {$0.name == "Methods"}) && nextCourse.category.contains(where: {$0.name == "Step By Step"}) && nextCourse.category.count == 2 {
					//this is the step by step made before 101 series
					result["courseID"] = nextCourse.id
					result["lessonID"] = nextCourse.lessons.last?.id
				} else {
					var nextCourseLessonLevels:[[String]] = []
					var targetCourseLessonLevels:[[String]] = []
					let nextCourseTimestamps = allTimestamps.filter({$0.id == nextCourse.id})
					let targetCourseTimestamps = allTimestamps.filter({$0.id == targetCourse.id})
					
					nextCourseLessonLevels = getLessonLevelStructure(targetCourse: nextCourse, targetTimestamps: nextCourseTimestamps)
					print("[debug] assignEquivalentLessonInNextCourseLevel, nextCourseLessonLevels.count: \(nextCourseLessonLevels.count)")
					print("[debug] assignEquivalentLessonInNextCourseLevel, nextCourseLessonLevels \(nextCourseLessonLevels)")
					
					targetCourseLessonLevels = getLessonLevelStructure(targetCourse: targetCourse, targetTimestamps: targetCourseTimestamps)
					print("[debug] assignEquivalentLessonInNextCourseLevel, targetCourseLessonLevels.count \(targetCourseLessonLevels.count)")
					print("[debug] assignEquivalentLessonInNextCourseLevel, targetCourseLessonLevels \(targetCourseLessonLevels)")
					
					let targetLessonLevelIndex = targetCourseLessonLevels.firstIndex(where: {$0.contains(targetLesson.sortValue)}) ?? 0
					print("[debug] assignEquivalentLessonInNextCourseLevel, targetLessonLevelIndex \(targetLessonLevelIndex)")
					var setEquivalentLevel = 0
					if targetLessonLevelIndex > 0 {
						setEquivalentLevel = (nextCourseLessonLevels.count * targetLessonLevelIndex)/targetCourseLessonLevels.count
					}
					print("[debug] assignEquivalentLessonInNextCourseLevel, setEquivalentLevel \(setEquivalentLevel)")
					let equivalentLevel = nextCourseLessonLevels[setEquivalentLevel][0]
					
					result["courseID"] = nextCourse.id
					result["lessonID"] = nextCourse.lessons.first(where: {$0.sortValue == equivalentLevel})?.id
				}
			} else {
				result["courseID"] = nextCourse.id
				result["lessonID"] = 0
			}
			
		}
		
		
		return result
	}
	
	private func assignEquivalentLessonInPreviousCourseLevel(targetCourse: Course, targetLesson: Lesson, studentData: StudentData) -> [String:Int] {
		var result:[String:Int] = [:]
		let previousCourse = assignPreviousCourse(targetCourse: targetCourse, studentData: studentData)
		
		if previousCourse.id == 0 {
			//at first course, no course before this
			result["courseID"] = 0
			result["lessonID"] = 0
		} else {
			if studentData.wizardRange.contains(where: {$0.courseID == previousCourse.id}) == true {
				if previousCourse.category.contains(where: {$0.name == "Methods"}) && previousCourse.category.contains(where: {$0.name == "Step By Step"}) && previousCourse.category.count == 2 {
					//this is the step by step made before 101 series
					result["courseID"] = previousCourse.id
					result["lessonID"] = previousCourse.lessons.last?.id
				} else {
					var previousCourseLessonLevels:[[String]] = []
					var targetCourseLessonLevels:[[String]] = []
					let previousCourseTimestamps = allTimestamps.filter({$0.id == previousCourse.id})
					let targetCourseTimestamps = allTimestamps.filter({$0.id == targetCourse.id})
					
					previousCourseLessonLevels = getLessonLevelStructure(targetCourse: previousCourse, targetTimestamps: previousCourseTimestamps)
					targetCourseLessonLevels = getLessonLevelStructure(targetCourse: targetCourse, targetTimestamps: targetCourseTimestamps)
					let targetLessonLevelIndex = targetCourseLessonLevels.firstIndex(where: {$0.contains(targetLesson.sortValue)}) ?? 0
					var setEquivalentLevel = 0
					if targetLessonLevelIndex > 0 {
						setEquivalentLevel = (previousCourseLessonLevels.count * targetLessonLevelIndex)/targetCourseLessonLevels.count
					}
					
					let equivalentLevel = previousCourseLessonLevels[setEquivalentLevel][0]
					result["courseID"] = previousCourse.id
					result["lessonID"] = previousCourse.lessons.first(where: {$0.sortValue == equivalentLevel})?.id
				}
			} else {
				result["courseID"] = previousCourse.id
				result["lessonID"] = 0
			}
		}
		
		return result
	}
	
	private func getLessonLevelStructure(targetCourse: Course, targetTimestamps: [Timestamp]) -> [[String]] {
		var targetCourseLessonLevels:[[String]] = []
		for lesson in targetCourse.lessons {
			let findTimestamps = (targetTimestamps.first(where: {$0.id == targetCourse.id})?.lessons.first(where: {$0.id == lesson.id})!.timestamps)!
			let playableBars = findTimestamps.filter({($0.notes == "" || $0.notes == "play") && $0.type == "piano"})
			
			if targetCourseLessonLevels.count == 0 {
				if findTimestamps.count > 0 && playableBars.count > 0 {
					targetCourseLessonLevels.append([lesson.sortValue])
				}
			} else {
				let lastLessonLevelSaved = targetCourseLessonLevels[targetCourseLessonLevels.count-1]
				let lastSubLevelSaved = lastLessonLevelSaved[lastLessonLevelSaved.count-1]
				let lastSortValueBreakdown = lastSubLevelSaved.split(separator:"-")
				let thisSortValueBreakdown = lesson.sortValue.split(separator:"-")
				
				if findTimestamps.count > 0 && playableBars.count > 0 {
					if thisSortValueBreakdown[1] == lastSortValueBreakdown[1] {
						targetCourseLessonLevels[targetCourseLessonLevels.count-1].append(lesson.sortValue)
					} else {
						targetCourseLessonLevels.append([lesson.sortValue])
					}
				}
			}
		}
		return targetCourseLessonLevels
	}
													*/
}

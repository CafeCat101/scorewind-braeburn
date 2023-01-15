//
//  WizardCalculator.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/23.
//

import Foundation

extension ScorewindData {
	func createRecommendation(studentData: StudentData) -> Page {
		var assignedCourseId = 0
		var assignedLessonId = 0
		var goToWizardStep:Page = .wizardChooseInstrument
		let currentStepName = studentData.wizardStepNames[studentData.wizardStepNames.count-1]
		var currentFinalFeedbackValue = 0.0
		
		if currentStepName == Page.wizardExperience {
			print("[debug] createRecommendation, Page.wizardExperience, \(studentData.getExperience())")
			if studentData.getExperience() == ExperienceFeedback.continueLearning.rawValue {
				if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
					let guitar103Courses = allCourses.filter({$0.instrument == InstrumentType.guitar.rawValue && $0.category.contains(where: {$0.name == "Guitar 103"})})
					if guitar103Courses.count > 0 {
						assignedCourseId = guitar103Courses.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})[0].id //G103.1 id:96100
						assignedLessonId = 0
					} else {
						//remember to handle this
					}
				} else if studentData.getInstrumentChoice() == InstrumentType.violin.rawValue {
					let violin103Courses = allCourses.filter({$0.instrument == InstrumentType.violin.rawValue && $0.category.contains(where: {$0.name == "Violin 103"})})
					if violin103Courses.count > 0 {
						assignedCourseId = violin103Courses.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})[0].id //V103.1 id:98384
						assignedLessonId = 0
					} else {
						//remember to handle this
					}
				}
			} else if studentData.getExperience() == ExperienceFeedback.experienced.rawValue {
				let pathCourses = allCourses.filter({$0.instrument == studentData.getInstrumentChoice() && $0.category.contains(where: {$0.name == "Path"})})
				if pathCourses.count > 0 {
					let veryFirstPathCourse = pathCourses.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})[0]
					assignedCourseId = veryFirstPathCourse.id
					assignedLessonId = veryFirstPathCourse.lessons[1].id
				}
				
			} else {
				let veryFirstCourse = allCourses.first(where: {$0.instrument == studentData.getInstrumentChoice() && $0.sortValue == "1"}) ?? Course()
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
			print("[debug] createRecommendation, finalFeedback \(finalFeedback)(\(finalFeedback.rawValue))")
			currentFinalFeedbackValue = Double(finalFeedback.rawValue)
			
			if wizardPickedCourse.id > 0 {
				if finalFeedback == .allOfThem {
					// "playable" to find the last lesson with score in current course
					let getLastLessonInCourse = assignLastLessonInCourse(targetCourse: wizardPickedCourse, useStudentData: studentData)
					assignedCourseId = getLastLessonInCourse["courseID"] ?? 0
					assignedLessonId = getLastLessonInCourse["lessonID"] ?? 0
					
					if assignedLessonId == 0 {
						//:: looks like no lesson left in this course to learn
						let nextCourse = assignNextCourse(targetCourse: wizardPickedCourse, studentData: studentData)
						if studentData.wizardRange.contains(where: {$0.courseID == nextCourse.id }) == false {
							assignedCourseId = nextCourse.id
							assignedLessonId = 0
						} else {
							let lastLessonSortValue = wizardPickedCourse.lessons[wizardPickedCourse.lessons.count-1].sortValue
							var lastLessonValue = Int(lastLessonSortValue.split(separator:"-")[1]) ?? 5
							if lastLessonValue == 0 {
								lastLessonValue = 1
							}
							let findLessons = getNextLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedCourse.lessons[wizardPickedCourse.lessons.count-1], useStudnetData: studentData, range: lastLessonValue)
							assignedCourseId = findLessons[0].courseID
							assignedLessonId = findLessons[0].lesson.id
						}
					}
				} else if finalFeedback == .someOfThem {
					//:: "Playable", go few lesson levels down
					let lastLessonSortValue = wizardPickedCourse.lessons[wizardPickedCourse.lessons.count-1].sortValue
					var lastLessonValue = Int(lastLessonSortValue.split(separator:"-")[1]) ?? 6
					if lastLessonValue == 0 {
						lastLessonValue = 1
					} else {
						lastLessonValue = Int(lastLessonValue/2)
					}
					var findLessons = getPreviousLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedCourse.lessons[0], useStudnetData: studentData, range: lastLessonValue)
					findLessons.reverse()
					assignedCourseId = findLessons[0].courseID
					assignedLessonId = findLessons[0].lesson.id
					
					/*
					let previousCourse = assignPreviousCourse(targetCourse: wizardPickedCourse, studentData: studentData)
					if previousCourse.category.contains(where: {$0.name == "Guitar 102" || $0.name == "Guitar 101" || $0.name == "Violin 101" || $0.name == "Violin 102"}) {
						let veryFirstCourse = allCourses.first(where: {$0.instrument == studentData.getInstrumentChoice() && $0.sortValue == "1"}) ?? Course()
						assignedCourseId = veryFirstCourse.id
						assignedLessonId = veryFirstCourse.lessons[0].id
						goToWizardStep = .wizardResult
					} else {
						if previousCourse.category.contains(where: {$0.name == "Methods"}) && previousCourse.category.contains(where: {$0.name == "Step By Step"}) && previousCourse.category.count == 2 {
							//this is the step by step made before 101 series
							assignedCourseId = previousCourse.id
							assignedLessonId = previousCourse.lessons.last?.id ?? 0
						} else {
							let getMiddleLesson = assignMiddleLessonInCourse(targetCourse: previousCourse, useStudentData: studentData)
							assignedCourseId = getMiddleLesson["courseID"] ?? 0
							assignedLessonId = getMiddleLesson["lessonID"] ?? 0
						}
					}
					 */
				} else {
					//:: go DoYouKnow or IsPlayable. Go 1 course level down or few lesson levels down.
					let previousCourse = assignPreviousCourse(targetCourse: wizardPickedCourse, studentData: studentData)
					if studentData.wizardRange.contains(where: {$0.courseID == previousCourse.id}) == false {
						assignedCourseId = previousCourse.id
						assignedLessonId = 0
					} else {
						let lastLessonSortValue = wizardPickedCourse.lessons[wizardPickedCourse.lessons.count-1].sortValue
						var lastLessonValue = Int(lastLessonSortValue.split(separator:"-")[1]) ?? 10
						if lastLessonValue == 0 {
							//StepByStep before 101's lesson sort value is 122-0-0
							lastLessonValue = 1
						}
						let findLessons = getPreviousLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedCourse.lessons[0], useStudnetData: studentData, range: lastLessonValue)
						assignedCourseId = findLessons[0].courseID
						assignedLessonId = findLessons[0].lesson.id
					}
					
				}
			}
		}
		
		if currentStepName == .wizardPlayable {
			let currentPlayableFeedback = studentData.getPlayable().first(where: {$0.key == String(wizardPickedLesson.id)})
			let extractFeedback = (currentPlayableFeedback?.value as! String).split(separator:"|")
			currentFinalFeedbackValue = Double(extractFeedback[0])!
			var findLessons:[WizardLessonSearched] = []
			
			if Int(extractFeedback[0]) == 1 {
				/*
				//course level down
				let lessonCourseDown = assignEquivalentLessonInPreviousCourseLevel(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, studentData: studentData)
				assignedCourseId = lessonCourseDown["courseID"] ?? 0
				assignedLessonId = lessonCourseDown["lessonID"] ?? 0
				 */
				//:: very hard, go many steps down
				let lastLessonSortValue = wizardPickedCourse.lessons[wizardPickedCourse.lessons.count-1].sortValue
				var lessonLevelValue = Int(lastLessonSortValue.split(separator:"-")[1]) ?? 10
				if lessonLevelValue == 0 {
					lessonLevelValue = 1
				}
				findLessons = getPreviousLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: lessonLevelValue)
				findLessons.reverse()

			} else if Int(extractFeedback[0]) == 2 {
				/*
				//lesson level down
				let lessonDown = assignLessonInPreviousLevel(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, studentData: studentData)
				assignedCourseId = lessonDown["courseID"] ?? 0
				assignedLessonId = lessonDown["lessonID"] ?? 0
				 */
				
				//:: a little difficult, go 1 step down
				findLessons = getPreviousLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: 1)
			} else if Int(extractFeedback[0]) == 3 {
				//go to go to wizard result
				assignedCourseId = wizardPickedCourse.id
				assignedLessonId = wizardPickedLesson.id
				goToWizardStep = .wizardResult
			} else if Int(extractFeedback[0]) == 4 {
				/*
				//lesson level up
				let lessonUp = assignLessonInNextLevel(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, studentData: studentData)
				assignedCourseId = lessonUp["courseID"] ?? 0
				assignedLessonId = lessonUp["lessonID"] ?? 0
				 */
				//:: comfortable, go 1 level up
				findLessons = getNextLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: 1)
				
			} else if Int(extractFeedback[0]) == 5 {
				/*
				//course level up
				let lessonCourseUp = assignEquivalentLessonInNextCourseLevel(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, studentData: studentData)
				assignedCourseId = lessonCourseUp["courseID"] ?? 0
				assignedLessonId = lessonCourseUp["lessonID"] ?? 0
				 */
				//:: easy peasy, go many steps up
				let lastLessonSortValue = wizardPickedCourse.lessons[wizardPickedCourse.lessons.count-1].sortValue
				var lessonLevelValue = Int(lastLessonSortValue.split(separator:"-")[1]) ?? 10
				if lessonLevelValue == 0 {
					lessonLevelValue = 1
				}
				findLessons = getNextLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: lessonLevelValue)
				findLessons.reverse()
			}
			
			if findLessons.count > 0 {
				assignedCourseId = findLessons[0].courseID
				//if areLessonsInCourseAsked(targetCourseID: assignedCourseId, range: studentData.wizardRange) == false {
				if studentData.wizardRange.contains(where: {$0.courseID == assignedCourseId}) == false {
					assignedLessonId = 0
				} else {
					assignedLessonId = findLessons[0].lesson.id
				}
			}
		}
		
		//setup wizard picked course object
		if assignedCourseId > 0 {
			wizardPickedCourse = allCourses.first(where: {$0.id == assignedCourseId}) ?? Course()
			print("[debug] createRecommendation, assignCourseId \(assignedCourseId)")
		}
		
		//setup wizard picked lesson object and its teimstamps
		if assignedLessonId > 0 {
			wizardPickedLesson = wizardPickedCourse.lessons.first(where: {$0.id == assignedLessonId}) ?? Lesson()
			wizardPickedTimestamps = (allTimestamps.first(where: {$0.id == assignedCourseId})?.lessons.first(where: {$0.id == assignedLessonId})!.timestamps) ?? []
			print("[debug] createRecommendation, assignLessonId \(assignedLessonId)")
		}
		
		if assignedCourseId == 0 && assignedLessonId == 0 {
			if goToWizardStep != .wizardResult {
				//here is where wizard doesn't have lesson to recommend
				goToWizardStep = .wizardResult
			}
		} else {
			//101 and 102 is a package deal, reassign wizard picked course to the beginning
			if wizardPickedCourse.category.contains(where: {$0.name == "Guitar 102" || $0.name == "Guitar 101" || $0.name == "Violin 101" || $0.name == "Violin 102"}) {
				let veryFirstCourse = allCourses.first(where: {$0.instrument == studentData.getInstrumentChoice() && $0.sortValue == "1"}) ?? Course()
				assignedCourseId = veryFirstCourse.id
				assignedLessonId = veryFirstCourse.lessons[0].id
				
				wizardPickedCourse = veryFirstCourse
				if assignedLessonId > 0 {
					wizardPickedLesson = veryFirstCourse.lessons[0]
					wizardPickedTimestamps = (allTimestamps.first(where: {$0.id == assignedCourseId})?.lessons.first(where: {$0.id == assignedLessonId})!.timestamps) ?? []
				} else {
					wizardPickedLesson = Lesson()
					wizardPickedTimestamps = []
				}
				goToWizardStep = .wizardResult
			}
			
			
		}
		
		//:: register range feedbackvalue of current step
		if currentStepName != Page.wizardChooseInstrument && studentData.wizardRange.count > 0 {
			studentData.wizardRange[studentData.wizardRange.count-1].feedbackValue = currentFinalFeedbackValue
		}
		
		//:: assign next step's wizard view
		if goToWizardStep != .wizardResult {
			if assignedCourseId > 0 && assignedLessonId > 0 {
				goToWizardStep = .wizardPlayable
			} else {
				goToWizardStep = .wizardDoYouKnow
			}
			
			//:: register range for the next step becasue the recommendation at this step is completed.
			if currentStepName != Page.wizardChooseInstrument {
				studentData.wizardRange.append(WizardPicked(allCourses: allCourses, courseID: assignedCourseId, lessonID: assignedLessonId, feedbackValue:0.0))
			}
		}
		
		
		print("[debug] createRecommendation, goToWizardStep \(goToWizardStep)")
		print("[debug] createRecommendation, wizardRange \(studentData.wizardRange)")
		return goToWizardStep
	}
	
	/*
	private func makeWizardPicked(courseID: Int, lessonID: Int, feedbackValue: Int) -> WizardPicked {
		let theCourse = allCourses.first(where: {$0.id == courseID}) ?? Course()
		
		var wizardPicked = WizardPicked()
		if theCourse.id > 0 {
			wizardPicked.courseID = courseID
			wizardPicked.lessonID = lessonID
			wizardPicked.courseSortValue = theCourse.sortValue
			let theLesson = theCourse.lessons.first(where: {$0.id == lessonID}) ?? Lesson()
			if theLesson.id > 0 {
				wizardPicked.lessonSortValue = theLesson.sortValue
			}
			wizardPicked.feedbackValue = feedbackValue
		}
		
		return wizardPicked
	}
	 */
	
	private func assignPreviousCourse(targetCourse: Course, studentData: StudentData) -> Course {
		var findCourse = Course()
		var sameCategoryCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) && Int($0.sortValue)! < Int(targetCourse.sortValue)! })
		
		sameCategoryCourses = excludeCoursesCompleted(targetCourse: sameCategoryCourses, useStudentData: studentData)
		
		if sameCategoryCourses.count > 0 {
			findCourse = sameCategoryCourses.sorted(by: {Int($0.sortValue)! > Int($1.sortValue)!})[0]
		}
		
		return findCourse
	}
	
	private func assignNextCourse(targetCourse: Course, studentData: StudentData) -> Course {
		var findCourse = Course()
		var sameCategoryCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) && Int($0.sortValue)! > Int(targetCourse.sortValue)! })
		
		sameCategoryCourses = excludeCoursesCompleted(targetCourse: sameCategoryCourses, useStudentData: studentData)
		
		if sameCategoryCourses.count > 0 {
			findCourse = sameCategoryCourses.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})[0]
		}
		return findCourse
	}
	
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
	 Exclude courses have all lessons marked completed
	 */
	private func excludeCoursesCompleted(targetCourse: [Course], useStudentData: StudentData) -> [Course] {
		var processed:[Course] = targetCourse
		
		for courseItem in useStudentData.myCourses {
			let findACourseInAll = allCourses.first(where: {$0.id == courseItem.courseID})
			if courseItem.completedLessons.count == findACourseInAll?.lessons.count {
				processed.removeAll(where: {$0.id == courseItem.courseID})
			}
		}
		
		return processed
	}
	
	private func excludeLessonsAsked(targetLessons: [Lesson], useStudentData: StudentData) -> [Lesson] {
		var processLessons = targetLessons
		
		for rangeItem in useStudentData.wizardRange {
			processLessons.removeAll(where: {$0.id == rangeItem.lessonID})
		}
		
		return processLessons
	}
	
	private func excludeLessonsCompleted(targetCourseID: Int, targetLessons: [Lesson], useStudentData: StudentData) -> [Lesson] {
		var processLessons = targetLessons
		let findCourseInMine = useStudentData.myCourses.first(where: {$0.courseID == targetCourseID})
		
		if findCourseInMine?.completedLessons.count ?? 0 > 0 {
			for lessonItem in findCourseInMine?.completedLessons ?? [] {
				processLessons.removeAll(where: {$0.id == lessonItem})
			}
		}
		
		return processLessons
	}
	
	/*
	 Find the last lesson that is not completed, not asked and is playable in the selected course.
	 Use case: feedback "All of them" from DoYouKnow view. Designed to go to IsPlayable view only
	 */
	private func assignLastLessonInCourse(targetCourse: Course, useStudentData:StudentData) -> [String:Int] {
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
	
	private func getNextLessons(targetCourse: Course, targetLesson: Lesson, useStudnetData: StudentData, range: Int) -> [WizardLessonSearched]{
		print("[debug] wizardCalcaultor, getNextLessons, range \(range)")
		var lessons:[WizardLessonSearched] = []
		var nextCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) && Int($0.sortValue)! >= Int(targetCourse.sortValue)! })
		
		nextCourses = nextCourses.sorted(by: { Int($0.sortValue)! < Int($1.sortValue)!})
		print("[debug] wizardCalcaultor, getNextLessons, nextCourses[0].title \(nextCourses[0].title)")
		nextCourses = excludeCoursesCompleted(targetCourse: nextCourses, useStudentData: useStudnetData)
		lessons = appendLessonsFromCourses(targetLessonStep:targetLesson.step ,courseCollection: nextCourses, useStudnetData: useStudnetData, limit: range, appendingOrder: .ASC)
		
		return lessons
	}
	
	private func getPreviousLessons(targetCourse: Course, targetLesson: Lesson, useStudnetData: StudentData, range: Int) -> [WizardLessonSearched] {
		print("[debug] wizardCalcaultor, getPreviousLessons, range \(range)")
		var lessons:[WizardLessonSearched] = []
		var previousCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) && Int($0.sortValue)! <= Int(targetCourse.sortValue)! })
		
		previousCourses = previousCourses.sorted(by: {Int($0.sortValue)! > Int($1.sortValue)!})
		previousCourses = excludeCoursesCompleted(targetCourse: previousCourses, useStudentData: useStudnetData)
		lessons = appendLessonsFromCourses(targetLessonStep:targetLesson.step ,courseCollection: previousCourses, useStudnetData: useStudnetData, limit: range, appendingOrder: .DESC)
		
		return lessons
	}
	
	private func checkIfLessonPlayable(targetCourseID: Int,targetLesson: Lesson) -> Bool {
		var result = false
		let findTimestamps = (allTimestamps.first(where: {$0.id == targetCourseID})?.lessons.first(where: {$0.id == targetLesson.id})!.timestamps)!
		let playableBars = findTimestamps.filter({($0.notes == "" || $0.notes == "play") && $0.type == "piano"})
		
		if findTimestamps.count > 0 && playableBars.count > 0 {
			result = true
		}
		
		return result
	}
	
	private func appendLessonsFromCourses(targetLessonStep: Int,courseCollection: [Course], useStudnetData: StudentData, limit: Int, appendingOrder: SearchParameter) -> [WizardLessonSearched] {
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


}

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
		var currentFinalFeedbackValue = 0
		
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
			currentFinalFeedbackValue = finalFeedback.rawValue
			
			if wizardPickedCourse.id > 0 {
				if finalFeedback == .allOfThem {
					// "playable" to find the last lesson with score in current course
					let getLastLessonInCourse = assignLastLessonInCourse(targetCourse: wizardPickedCourse)
					assignedCourseId = getLastLessonInCourse["courseID"] ?? 0
					assignedLessonId = getLastLessonInCourse["lessonID"] ?? 0
					
					if assignedLessonId == 0 {
						let nextCourse = assignNextCourse(targetCourse: wizardPickedCourse)
						assignedCourseId = nextCourse.id
					}
				} else if finalFeedback == .someOfThem {
					// "Playable" to find the middle lesson with score in previous course
					let previousCourse = assignPreviousCourse(targetCourse: wizardPickedCourse)
					
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
							let getMiddleLesson = assignMiddleLessonInCourse(targetCourse: previousCourse)
							assignedCourseId = getMiddleLesson["courseID"] ?? 0
							assignedLessonId = getMiddleLesson["lessonID"] ?? 0
						}
						
					}
				} else {
					// "Do you know" to previous course
					let previousCourse = assignPreviousCourse(targetCourse: wizardPickedCourse)
					assignedCourseId = previousCourse.id
					assignedLessonId = 0
				}
			}
		}
		
		if currentStepName == .wizardPlayable {
			let currentPlayableFeedback = studentData.getPlayable().first(where: {$0.key == String(wizardPickedLesson.id)})
			let extractFeedback = (currentPlayableFeedback?.value as! String).split(separator:"|")
			if Int(extractFeedback[0]) == 1 {
				//course level down
				let lessonCourseDown = assignEquivalentLessonInPreviousCourseLevel(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson)
				assignedCourseId = lessonCourseDown["courseID"] ?? 0
				assignedLessonId = lessonCourseDown["lessonID"] ?? 0
			} else if Int(extractFeedback[0]) == 2 {
				//lesson level down
				let lessonDown = assignLessonInPreviousLevel(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson)
				assignedCourseId = lessonDown["courseID"] ?? 0
				assignedLessonId = lessonDown["lessonID"] ?? 0
			} else if Int(extractFeedback[0]) == 3 {
				//go to go to wizard result
				assignedCourseId = wizardPickedCourse.id
				assignedLessonId = wizardPickedLesson.id
				goToWizardStep = .wizardResult
			} else if Int(extractFeedback[0]) == 4 {
				//lesson level up
				let lessonUp = assignLessonInNextLevel(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson)
				assignedCourseId = lessonUp["courseID"] ?? 0
				assignedLessonId = lessonUp["lessonID"] ?? 0
			} else if Int(extractFeedback[0]) == 5 {
				//course level up
				let lessonCourseUp = assignEquivalentLessonInNextCourseLevel(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson)
				assignedCourseId = lessonCourseUp["courseID"] ?? 0
				assignedLessonId = lessonCourseUp["lessonID"] ?? 0
			}
		}
		
		//setup wizard picked course object
		if assignedCourseId > 0 {
			wizardPickedCourse = allCourses.first(where: {$0.id == assignedCourseId}) ?? Course()
			print("[debug] createRecommendation, assignCourseId \(assignedCourseId)")
		} else {
			wizardPickedCourse = Course()
		}
		
		//setup wizard picked lesson object and its teimstamps
		if assignedLessonId > 0 {
			wizardPickedLesson = wizardPickedCourse.lessons.first(where: {$0.id == assignedLessonId}) ?? Lesson()
			wizardPickedTimestamps = (allTimestamps.first(where: {$0.id == assignedCourseId})?.lessons.first(where: {$0.id == assignedLessonId})!.timestamps) ?? []
			print("[debug] createRecommendation, assignLessonId \(assignedLessonId)")
		} else {
			wizardPickedLesson = Lesson()
			wizardPickedTimestamps = []
		}
		
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
		
		//register range becasue the recommendation at this step is completed.
		if (currentStepName != Page.wizardChooseInstrument) && (currentStepName != Page.wizardExperience) {
			studentData.wizardRange.append(makeWizardPicked(courseID: assignedCourseId, lessonID: assignedLessonId, feedbackValue: currentFinalFeedbackValue))
		}
		
		//setup wizard view for this step
		if goToWizardStep != .wizardResult {
			if assignedCourseId > 0 && assignedLessonId > 0 {
				goToWizardStep = .wizardPlayable
			} else {
				goToWizardStep = .wizardDoYouKnow
			}
		}
		
		print("[debug] createRecommendation, goToWizardStep \(goToWizardStep)")
		print("[debug] createRecommendation, wizardRange \(studentData.wizardRange)")
		return goToWizardStep
	}
	
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
	
	/*private func findSortOrderString(targetCourse: Course, order: SearchParameter) -> String {
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
	}*/
	
	private func assignPreviousCourse(targetCourse: Course) -> Course {
		var findCourse = Course()
		let sameCategoryCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) && Int($0.sortValue)! < Int(targetCourse.sortValue)! })
		if sameCategoryCourses.count > 0 {
			findCourse = sameCategoryCourses.sorted(by: {Int($0.sortValue)! > Int($1.sortValue)!})[0]
		}
		
		if findCourse.id == 0 {
			let sameCategoryCourses2 = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) })
			findCourse = sameCategoryCourses2.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})[0]
		}
		
		return findCourse
	}
	
	private func assignNextCourse(targetCourse: Course) -> Course {
		var findCourse = Course()
		let sameCategoryCourses = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) && Int($0.sortValue)! > Int(targetCourse.sortValue)! })
		if sameCategoryCourses.count > 0 {
			findCourse = sameCategoryCourses.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})[0]
		}
		
		if findCourse.id == 0 {
			let sameCategoryCourses2 = allCourses.filter({ $0.instrument == targetCourse.instrument && courseCategoryToString(courseCategories: $0.category, depth: 2) == courseCategoryToString(courseCategories: targetCourse.category, depth: 2) })
			findCourse = sameCategoryCourses2.sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})[sameCategoryCourses.count-1]
		}
		return findCourse
	}
	
	private func assignLastLessonInCourse(targetCourse: Course) -> [String:Int] {
		var result:[String:Int] = [:]
		let currentLessons = targetCourse.lessons
		for lesson in currentLessons.sorted(by: {$0.step > $1.step}) {
			let findTimestamps = (allTimestamps.first(where: {$0.id == targetCourse.id})?.lessons.first(where: {$0.id == lesson.id})!.timestamps)!
			let playableBars = findTimestamps.filter({($0.notes == "" || $0.notes == "play") && $0.type == "piano"})
			if findTimestamps.count > 0 && playableBars.count > 0 {
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
			let playableBars = findTimestamps.filter({($0.notes == "" || $0.notes == "play") && $0.type == "piano"})
			if findTimestamps.count > 0 && playableBars.count > 0 {
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
	
	private func assignLessonInNextLevel(targetCourse: Course, targetLesson: Lesson) -> [String: Int] {
		var result:[String:Int] = [:]

		let nextLesson:Lesson = findAdjacentLessonInCurrentCourse(targetCourse: targetCourse, targetLesson: targetLesson, direction: .ASC)
		if nextLesson.id > 0 {
			result["courseID"] = targetCourse.id
			result["lessonID"] = nextLesson.id
		} else {
			let nextCourse = assignNextCourse(targetCourse: targetCourse)
			if nextCourse.category.contains(where: {$0.name == "Methods"}) && nextCourse.category.contains(where: {$0.name == "Step By Step"}) && nextCourse.category.count == 2 {
				//this is the step by step made before 101 series
				result["courseID"] = nextCourse.id
				result["lessonID"] = nextCourse.lessons.last?.id ?? 0
			} else {
				for lesson in nextCourse.lessons {
					let findTimestamps = (allTimestamps.first(where: {$0.id == nextCourse.id})?.lessons.first(where: {$0.id == lesson.id})!.timestamps)!
					let playableBars = findTimestamps.filter({($0.notes == "" || $0.notes == "play") && $0.type == "piano"})
					if findTimestamps.count > 0 && playableBars.count > 0 {
						result["courseID"] = nextCourse.id
						result["lessonID"] = lesson.id
						break
					}
				}
			}
			
		}
		
		return result
	}
	
	private func assignLessonInPreviousLevel(targetCourse: Course, targetLesson: Lesson) -> [String:Int] {
		var result:[String:Int] = [:]
		
		let previousLevelLesson:Lesson = findAdjacentLessonInCurrentCourse(targetCourse: targetCourse, targetLesson: targetLesson, direction: .DESC)
		if previousLevelLesson.id > 0 {
			result["courseID"] = targetCourse.id
			result["lessonID"] = previousLevelLesson.id
		} else {
			let previousCourse = assignPreviousCourse(targetCourse: targetCourse)
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
		}
		
		return result
	}
	
	private func findAdjacentLessonInCurrentCourse(targetCourse: Course, targetLesson: Lesson, direction: SearchParameter) -> Lesson {
		var result:Lesson = Lesson()
		let levelBreakdown1 = targetLesson.sortValue.split(separator: "-")
		
		if Int(levelBreakdown1[1]) == 0 && Int(levelBreakdown1[2]) == 0 {
			//the StepByStep made before 101 series only the last lesson has level meaning to wizard
		} else {
			var lessons:[Lesson] = []
			if direction == .ASC {
				lessons = (targetCourse.lessons).filter({$0.step>targetLesson.step})
			} else {
				lessons = (targetCourse.lessons).filter({$0.step<targetLesson.step})
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
	
	private func assignEquivalentLessonInNextCourseLevel(targetCourse: Course, targetLesson: Lesson) -> [String:Int]{
		var result:[String:Int] = [:]
		let nextCourse = assignNextCourse(targetCourse: targetCourse)
		
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
		return result
	}
	
	private func assignEquivalentLessonInPreviousCourseLevel(targetCourse: Course, targetLesson: Lesson) -> [String:Int] {
		var result:[String:Int] = [:]
		let previousCourse = assignPreviousCourse(targetCourse: targetCourse)
		
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
	
	


}

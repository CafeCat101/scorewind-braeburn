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
				var sortedCourses = allCourses.filter({$0.instrument == studentData.getInstrumentChoice() && $0.category.contains(where: {$0.name == CourseType.stepByStep.getCategoryName()})}).sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
				if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
					sortedCourses = sortedCourses.filter({$0.category.contains(where: {$0.name == "Guitar 101"}) == false && $0.category.contains(where: {$0.name == "Guitar 102"}) == false})
				} else {
					sortedCourses = sortedCourses.filter({$0.category.contains(where: {$0.name == "Violin 101"}) == false && $0.category.contains(where: {$0.name == "Violin 102"}) == false})
				}
				
				sortedCourses = excludeCoursesCompleted(targetCourse: sortedCourses, useStudentData: studentData)
				
				let uncompletedLessons = getUncompletedLessonsFromCourses(sortedCourses: sortedCourses, lessonCount: 1, useStudentData: studentData)
				if uncompletedLessons.count > 0 {
					assignedCourseId = uncompletedLessons[0].courseID
					assignedLessonId = 0
				}
				
			} else if studentData.getExperience() == ExperienceFeedback.experienced.rawValue {
				let pathCourses = allCourses.filter({$0.instrument == studentData.getInstrumentChoice() && $0.category.contains(where: {$0.name == CourseType.path.getCategoryName()})}).sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
				let uncompletedLessons = getUncompletedLessonsFromCourses(sortedCourses: pathCourses, lessonCount: 1, useStudentData: studentData, onlyPlayable: true)
				if uncompletedLessons.count > 0 {
					assignedCourseId = uncompletedLessons[0].courseID
					assignedLessonId = uncompletedLessons[0].lessonID
				}
				
			} else {
				let sortedCourses = allCourses.filter({$0.instrument == studentData.getInstrumentChoice()}).sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
				let uncompletedLessons = getUncompletedLessonsFromCourses(sortedCourses: sortedCourses, lessonCount: 1, useStudentData: studentData)
				assignedCourseId = uncompletedLessons[0].courseID
				assignedLessonId = uncompletedLessons[0].lessonID
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
				//:: very hard, go many steps down
				let lastLessonSortValue = wizardPickedCourse.lessons[wizardPickedCourse.lessons.count-1].sortValue
				var lessonLevelValue = Int(lastLessonSortValue.split(separator:"-")[1]) ?? 10
				if lessonLevelValue == 0 {
					lessonLevelValue = 1
				}
				findLessons = getPreviousLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: lessonLevelValue)
				findLessons.reverse()

			} else if Int(extractFeedback[0]) == 2 {
				//:: a little difficult, go 1 step down
				findLessons = getPreviousLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: 1)
			} else if Int(extractFeedback[0]) == 3 {
				//go to go to wizard result
				assignedCourseId = wizardPickedCourse.id
				assignedLessonId = wizardPickedLesson.id
				goToWizardStep = .wizardResult
			} else if Int(extractFeedback[0]) == 4 {
				//:: comfortable, go 1 level up
				findLessons = getNextLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: 1)
				
			} else if Int(extractFeedback[0]) == 5 {
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
		
		if (studentData.wizardRange.count >= 10) && (studentData.getExperience() != ExperienceFeedback.starterKit.rawValue) {
			let checkCompletedLessonStatus:Double = Double(studentData.getTotalCompletedLessonCount())/5
			if ((checkCompletedLessonStatus  - checkCompletedLessonStatus.rounded(.down) < 1) && (checkCompletedLessonStatus  - checkCompletedLessonStatus.rounded(.down) > 0)) == false {
				let explorer = explorerAlgorithm(useStudentData: studentData)
				assignedCourseId = explorer["courseID"] ?? 0
				assignedLessonId = explorer["lessonID"] ?? 0
			} else {
				let lastCourseInRange = allCourses.first(where: {$0.id == studentData.wizardRange.last?.courseID}) ?? Course()
				let assesment = assesmentAlgorithm(useStudentData: studentData, exampleCourse: lastCourseInRange)
				assignedCourseId = assesment["courseID"] ?? 0
				assignedLessonId = assesment["lessonID"] ?? 0
			}
			goToWizardStep = .wizardResult
		}
		
		if assignedCourseId == 0 && assignedLessonId == 0 {
			if goToWizardStep != .wizardResult {
				//here is where wizard doesn't have lesson to recommend
				goToWizardStep = .wizardResult
			}
		} else {
			//setup wizard picked course object
			if assignedCourseId > 0 {
				wizardPickedCourse = allCourses.first(where: {$0.id == assignedCourseId}) ?? Course()
				
				//101 and 102 is a package deal, reassign wizard picked course to any not completed one between 101~102
				if (wizardPickedCourse.category.contains(where: {$0.name == "Guitar 102" || $0.name == "Guitar 101" || $0.name == "Violin 101" || $0.name == "Violin 102"}) && (studentData.getExperience() != ExperienceFeedback.starterKit.rawValue)) {
					var beginnerCoursePackage = allCourses.filter({$0.instrument == studentData.getInstrumentChoice() && $0.category.contains(where: {$0.name == "Guitar 102" || $0.name == "Guitar 101" || $0.name == "Violin 101" || $0.name == "Violin 102"})}).sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
					beginnerCoursePackage = excludeCoursesCompleted(targetCourse: beginnerCoursePackage, useStudentData: studentData)
					for course in beginnerCoursePackage {
						let uncompletedLesson = excludeLessonsCompleted(targetCourseID: course.id, targetLessons: course.lessons, useStudentData: studentData)
						if uncompletedLesson.count > 0 {
							wizardPickedCourse = course
							assignedCourseId = course.id
							assignedLessonId = uncompletedLesson[0].id
							break
						}
					}
					goToWizardStep = .wizardResult
				}
				
				print("[debug] createRecommendation, assignCourseId \(assignedCourseId)")
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
	
	private func explorerAlgorithm(useStudentData: StudentData) -> [String:Int] {
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
	
	private func assesmentAlgorithm(useStudentData: StudentData, exampleCourse: Course) -> [String:Int] {
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
	
	private func getUncompletedLessonsFromCourses(sortedCourses:[Course], lessonCount: Int, useStudentData: StudentData, onlyPlayable: Bool = false) -> [WizardPicked] {
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

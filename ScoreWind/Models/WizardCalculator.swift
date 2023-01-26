//
//  WizardCalculator.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/23.
//

import Foundation

extension ScorewindData {
	func createRecommendation(studentData: StudentData) -> Page {
		let helper = WizardCalculatorHelper(allCourses: allCourses, allTimestamps: allTimestamps)
		var assignedCourseId = 0
		var assignedLessonId = 0
		var goToWizardStep:Page = .wizardChooseInstrument
		let currentStepName = studentData.wizardStepNames[studentData.wizardStepNames.count-1]
		var currentFinalFeedbackValue = 0.0
		var explainResult = ""
		
		if currentStepName == Page.wizardExperience {
			print("[debug] createRecommendation, Page.wizardExperience, \(studentData.getExperience())")
			if studentData.getExperience() == ExperienceFeedback.continueLearning.rawValue {
				//:: find first uncompleted lesson since 103 as base course and base lesson
				var sortedCourses = allCourses.filter({$0.instrument == studentData.getInstrumentChoice() && $0.category.contains(where: {$0.name == CourseType.stepByStep.getCategoryName()})}).sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
				if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
					sortedCourses = sortedCourses.filter({$0.category.contains(where: {$0.name == "Guitar 101"}) == false && $0.category.contains(where: {$0.name == "Guitar 102"}) == false})
				} else {
					sortedCourses = sortedCourses.filter({$0.category.contains(where: {$0.name == "Violin 101"}) == false && $0.category.contains(where: {$0.name == "Violin 102"}) == false})
				}
				
				sortedCourses = helper.excludeCoursesCompleted(targetCourse: sortedCourses, useStudentData: studentData)
				
				let uncompletedLessons = helper.getUncompletedLessonsFromCourses(sortedCourses: sortedCourses, lessonCount: 1, useStudentData: studentData)
				if uncompletedLessons.count > 0 {
					assignedCourseId = uncompletedLessons[0].courseID
					assignedLessonId = 0
				}
				
			} else if studentData.getExperience() == ExperienceFeedback.experienced.rawValue {
				//:: find first uncompleted lesson in path courses as base course and lesson
				let pathCourses = allCourses.filter({$0.instrument == studentData.getInstrumentChoice() && $0.category.contains(where: {$0.name == CourseType.path.getCategoryName()})}).sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
				let uncompletedLessons = helper.getUncompletedLessonsFromCourses(sortedCourses: pathCourses, lessonCount: 1, useStudentData: studentData, onlyPlayable: true)
				if uncompletedLessons.count > 0 {
					assignedCourseId = uncompletedLessons[0].courseID
					assignedLessonId = uncompletedLessons[0].lessonID
				}
				
			} else {
				//:: idea is showing users all uncompleted lesson from level low to high
				let sortedCourses = allCourses.filter({$0.instrument == studentData.getInstrumentChoice()}).sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
				let uncompletedLessons = helper.getUncompletedLessonsFromCourses(sortedCourses: sortedCourses, lessonCount: 10, useStudentData: studentData)
				studentData.wizardRange = uncompletedLessons
				assignedCourseId = uncompletedLessons[0].courseID
				assignedLessonId = uncompletedLessons[0].lessonID
				goToWizardStep = .wizardResult
			}
		}
		
		if currentStepName == .wizardDoYouKnow {
			print("[debug] createRecommendation, getDoYouKnow \(studentData.getDoYouKnow())")
			let getCurrentDoYouKnow = studentData.getDoYouKnow().first(where: {$0.key == String(wizardPickedCourse.id)})
			let finalFeedback = helper.getDoYouKnowScore(answers: getCurrentDoYouKnow?.value as! [Int])
			print("[debug] createRecommendation, finalFeedback \(finalFeedback)(\(finalFeedback.rawValue))")
			currentFinalFeedbackValue = Double(finalFeedback.rawValue)
			
			if wizardPickedCourse.id > 0 {
				if finalFeedback == .allOfThem {
					// "playable" to find the last lesson with score in current course
					let getLastLessonInCourse = helper.assignLastLessonInCourse(targetCourse: wizardPickedCourse, useStudentData: studentData)
					assignedCourseId = getLastLessonInCourse["courseID"] ?? 0
					assignedLessonId = getLastLessonInCourse["lessonID"] ?? 0
					
					if assignedLessonId == 0 {
						//:: looks like no lesson left in this course to learn
						let nextCourse = helper.assignNextCourse(targetCourse: wizardPickedCourse, studentData: studentData)
						if studentData.wizardRange.contains(where: {$0.courseID == nextCourse.id }) == false {
							assignedCourseId = nextCourse.id
							assignedLessonId = 0
						} else {
							let lastLessonSortValue = wizardPickedCourse.lessons[wizardPickedCourse.lessons.count-1].sortValue
							var lastLessonValue = Int(lastLessonSortValue.split(separator:"-")[1]) ?? 5
							if lastLessonValue == 0 {
								lastLessonValue = 1
							}
							let findLessons = helper.getNextLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedCourse.lessons[wizardPickedCourse.lessons.count-1], useStudnetData: studentData, range: lastLessonValue)
							if findLessons.count > 0 {
								assignedCourseId = findLessons[0].courseID
								assignedLessonId = findLessons[0].lesson.id
							}
							
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
					var findLessons = helper.getPreviousLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedCourse.lessons[0], useStudnetData: studentData, range: lastLessonValue)
					findLessons.reverse()
					if findLessons.count > 0 {
						assignedCourseId = findLessons[0].courseID
						assignedLessonId = findLessons[0].lesson.id
					}
				} else {
					//:: go DoYouKnow or IsPlayable. Go 1 course level down or few lesson levels down.
					let previousCourse = helper.assignPreviousCourse(targetCourse: wizardPickedCourse, studentData: studentData)
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
						let findLessons = helper.getPreviousLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedCourse.lessons[0], useStudnetData: studentData, range: lastLessonValue)
						if findLessons.count > 0 {
							assignedCourseId = findLessons[0].courseID
							assignedLessonId = findLessons[0].lesson.id
						}
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
				findLessons = helper.getPreviousLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: lessonLevelValue)
				findLessons.reverse()

			} else if Int(extractFeedback[0]) == 2 {
				//:: a little difficult, go 1 step down
				findLessons = helper.getPreviousLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: 1)
			} else if Int(extractFeedback[0]) == 3 {
				//:: ends here, go to go to wizard result
				assignedCourseId = wizardPickedCourse.id
				assignedLessonId = wizardPickedLesson.id
				//:: explain->you've choosen...
				explainResult = "Looks like you found a lesson. Go ahread!"
				goToWizardStep = .wizardResult
			} else if Int(extractFeedback[0]) == 4 {
				//:: comfortable, go 1 level up
				findLessons = helper.getNextLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: 1)
				
			} else if Int(extractFeedback[0]) == 5 {
				//:: easy peasy, go many steps up
				let lastLessonSortValue = wizardPickedCourse.lessons[wizardPickedCourse.lessons.count-1].sortValue
				var lessonLevelValue = Int(lastLessonSortValue.split(separator:"-")[1]) ?? 10
				if lessonLevelValue == 0 {
					lessonLevelValue = 1
				}
				findLessons = helper.getNextLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: studentData, range: lessonLevelValue)
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
				let explorer = helper.explorerAlgorithm(useStudentData: studentData)
				assignedCourseId = explorer["courseID"] ?? 0
				assignedLessonId = explorer["lessonID"] ?? 0
				explainResult = "It's time to take a little challenges. Good luck!"
			} else {
				let lastCourseInRange = allCourses.first(where: {$0.id == studentData.wizardRange.last?.courseID}) ?? Course()
				let assesment = helper.assesmentAlgorithm(useStudentData: studentData, exampleCourse: lastCourseInRange)
				assignedCourseId = assesment["courseID"] ?? 0
				assignedLessonId = assesment["lessonID"] ?? 0
				explainResult = "Hi explorer, Scorewind found a lesson that may be your interest."
			}
			//:: explain->hi explorer, it's time to challange or repositioning your level.
			goToWizardStep = .wizardResult
		}
		
		//:: in case of no course or lesson is found but the wizardRange has some data(mostly happen when trying to find something easy in path course),
		//:: use the last doable lesson in it.
		if assignedCourseId == 0 && assignedLessonId == 0 && studentData.wizardRange.count > 0 {
			var sortedWizardRange = studentData.wizardRange.sorted(by: {$0.sortHelper > $1.sortHelper})
			sortedWizardRange.removeAll(where: {$0.feedbackValue < Double(PlayableFeedback.canLearn.rawValue)})
			if sortedWizardRange.count > 0 {
				assignedCourseId = sortedWizardRange[0].courseID
				if sortedWizardRange[0].lessonID > 0 {
					assignedLessonId = sortedWizardRange[0].lessonID
				} else {
					let useCourse = allCourses.first(where: {$0.id == assignedCourseId}) ?? Course()
					assignedLessonId = useCourse.lessons[0].id
				}
			}
			explainResult = "This lesson is forgotten. Let's check it out!"
			goToWizardStep = .wizardResult
		}
		
		if assignedCourseId == 0 && assignedLessonId == 0 {
			if goToWizardStep != .wizardResult {
				//:: explain->wizard doesn't have any lesson to recommend, probably all lessons are completed
				explainResult = "Oooh~Scorewind doesn't have more new lessons for you now."
				goToWizardStep = .wizardResult
			}
		} else {
			//:: setup wizard picked course object
			if assignedCourseId > 0 {
				wizardPickedCourse = allCourses.first(where: {$0.id == assignedCourseId}) ?? Course()
				
				//:: 101 and 102 is a package deal, reassign wizard picked course to any not completed one between 101~102
				if (wizardPickedCourse.category.contains(where: {$0.name == "Guitar 102" || $0.name == "Guitar 101" || $0.name == "Violin 101" || $0.name == "Violin 102"}) && (studentData.getExperience() != ExperienceFeedback.starterKit.rawValue)) {
					var beginnerCoursePackage = allCourses.filter({$0.instrument == studentData.getInstrumentChoice() && $0.category.contains(where: {$0.name == "Guitar 102" || $0.name == "Guitar 101" || $0.name == "Violin 101" || $0.name == "Violin 102"})}).sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
					beginnerCoursePackage = helper.excludeCoursesCompleted(targetCourse: beginnerCoursePackage, useStudentData: studentData)
					for course in beginnerCoursePackage {
						let uncompletedLesson = helper.excludeLessonsCompleted(targetCourseID: course.id, targetLessons: course.lessons, useStudentData: studentData)
						if uncompletedLesson.count > 0 {
							wizardPickedCourse = course
							assignedCourseId = course.id
							assignedLessonId = uncompletedLesson[0].id
							break
						}
					}
					//:: explain->101~102 is the essentail package, don't miss it.
					explainResult = "Series 101 to 102 is an essential package for you to get your hands on the instrument more easily. Don't miss it!"
					goToWizardStep = .wizardResult
				}
				
				print("[debug] createRecommendation, assignCourseId \(assignedCourseId)")
			}
			
			//:: setup wizard picked lesson object and its teimstamps
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
				studentData.wizardRange.append(WizardPicked(theCourse: wizardPickedCourse, theLesson: wizardPickedLesson, sortHelper: helper.lessonSortToSortHelper(courseSortValue: wizardPickedCourse.sortValue, lessonStepValue: wizardPickedLesson.step), feedbackValue: 0.0))
				//studentData.wizardRange.append(WizardPicked(allCourses: allCourses, courseID: assignedCourseId, lessonID: assignedLessonId, feedbackValue:0.0))
			}
		} else {
			studentData.wizardResult = WizardResult()
			studentData.wizardResult.learningPath = setLearningPath(helper:helper, useStudentData: studentData)
			if studentData.getExperience() == ExperienceFeedback.continueLearning.rawValue || studentData.getExperience() == ExperienceFeedback.experienced.rawValue {
				if studentData.getExperience() == ExperienceFeedback.continueLearning.rawValue {
					studentData.wizardResult.resultTitle = "A lesson to explore!"
				} else {
					studentData.wizardResult.resultTitle = "A lesson from repositories"
				}
				
				studentData.wizardResult.resultExplaination = explainResult
				studentData.wizardResult.learningPathExplaination = "Start here and into the near future. These are lessons that await for you to explore them."
			}
		}
		
		studentData.updateWizardResult(result: studentData.wizardResult)
		print("[debug] createRecommendation, goToWizardStep \(goToWizardStep)")
		print("[debug] createRecommendation, wizardRange \(studentData.wizardRange)")
		return goToWizardStep
	}
	
	func setLearningPath(helper:WizardCalculatorHelper, useStudentData: StudentData) -> [WizardLearningPathItem] {
		let experienceType = helper.experienceFeedbackToCase(caseValue: useStudentData.getExperience())
		var sortedWizardRange = useStudentData.wizardRange.sorted(by: {$0.sortHelper < $1.sortHelper})
		var learningPath:[WizardLearningPathItem] = []
		
		if experienceType == .continueLearning || experienceType == .experienced {
			var searchLessons:[WizardLessonSearched] = []
			searchLessons.append(WizardLessonSearched(courseID: wizardPickedCourse.id, lesson: wizardPickedLesson))
			searchLessons.append(contentsOf: helper.getNextLessons(targetCourse: wizardPickedCourse, targetLesson: wizardPickedLesson, useStudnetData: useStudentData, range: 9))
			
			if searchLessons.count > 0 {
				sortedWizardRange = []
				for item in searchLessons {
					let course = allCourses.first(where: {$0.id == item.courseID}) ?? Course()
					if course.id > 0 {
						let itemFromRange = useStudentData.wizardRange.first(where: {$0.courseID == course.id && $0.lessonID == item.lesson.id})
						let getFeedbackValueFromRange = itemFromRange?.feedbackValue ?? 0.0
						var setSortHelperValue = itemFromRange?.sortHelper ?? 0.0
						if setSortHelperValue == 0.0 {
							setSortHelperValue = helper.lessonSortToSortHelper(courseSortValue: course.sortValue, lessonStepValue: item.lesson.step)
						}
						sortedWizardRange.append(WizardPicked(theCourse: course, theLesson: item.lesson, sortHelper: setSortHelperValue, feedbackValue: getFeedbackValueFromRange))
					}
					
				}
			}
		}
		
		for i in 0..<sortedWizardRange.count {
			//print("[debug] WizardResult, getLearningPath allCourse.count \(calculatorHelper.allCourses.count)")
			var learningPathItem = WizardLearningPathItem()
			let findCourse = allCourses.first(where: {$0.id == sortedWizardRange[i].courseID}) ?? Course()
			let findLesson = findCourse.lessons.first(where: {$0.id == sortedWizardRange[i].lessonID}) ?? Lesson()
			learningPathItem.courseID = findCourse.id
			learningPathItem.courseTitle = findCourse.title
			learningPathItem.lessonID = findLesson.id
			learningPathItem.lessonTitle = findLesson.title
			learningPathItem.feedbackValue = sortedWizardRange[i].feedbackValue
			learningPathItem.sortHelper = sortedWizardRange[i].sortHelper
			if sortedWizardRange[i].courseID == wizardPickedCourse.id && sortedWizardRange[i].lessonID == wizardPickedLesson.id {
				learningPathItem.startHere = true
			}
			if i == 0 {
				learningPathItem.showCourseTitle = true
			} else {
				if sortedWizardRange[i].courseID != sortedWizardRange[i-1].courseID {
					learningPathItem.showCourseTitle = true
				}
			}
			learningPath.append(learningPathItem)
		}
		
		
		return learningPath
	}
	
	
}

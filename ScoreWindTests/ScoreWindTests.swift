//
//  ScoreWindTests.swift
//  ScoreWindTests
//
//  Created by Leonore Yardimli on 2022/7/1.
//

import XCTest
@testable import ScoreWind

class ScoreWindTests: XCTestCase {
	var scorewindData = ScorewindData()
	var studentData = StudentData()
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	/*func testPerformanceExample() throws {
	 // This is an example of a performance test case.
	 measure {
	 // Put the code you want to measure the time of here.
	 }
	 }*/
	
	func testFirstLaunch() throws {
		print(scorewindData.firstLaunch())
	}
	
	func testNeedToCheckVersion() throws {
		print(scorewindData.needToCheckVersion())
	}
	
	func testcreateRecommendation() throws {
		//=>test guitar:playable, target:lesson in previous level in current course
		
		studentData.removeAKey(keyName: "experience")
		studentData.removeAKey(keyName: "doYouKnow")
		studentData.removeAKey(keyName: "playable")
		
		studentData.wizardStepNames = [Page.wizardChooseInstrument]
		studentData.updateInstrumentChoice(instrument: .violin)

		studentData.wizardStepNames.append(.wizardExperience)
		studentData.updateExperience(experience: .continueLearning)
		
		studentData.wizardStepNames.append(.wizardDoYouKnow)
		scorewindData.wizardPickedCourse = scorewindData.allCourses.first(where: {$0.id == 96100}) ?? Course()
		print("TEST, wizardPickedCourse.id \(scorewindData.allCourses.count)")
		let feedbackScores:[Int] = [3,3,3]
		studentData.updateDoYouKnow(courseID: 96100, feedbackValues: feedbackScores)
		XCTAssertNoThrow(studentData.backendReadAllKeys())
		XCTAssertNoThrow(print("next step:\(scorewindData.createRecommendation(studentData: studentData))"))
		
		/*studentData.wizardStepNames.append(.wizardPlayable)
		scorewindData.wizardPickedCourse = scorewindData.allCourses.first(where: {$0.id == 96100}) ?? Course()
		scorewindData.wizardPickedLesson = scorewindData.wizardPickedCourse.lessons.first(where: {$0.id == 13768}) ?? Lesson()
		studentData.updatePlayable(courseID: 96100, lessonID: 13768, feedbackValue: 2)*/
		
		
	}
	
	func testReadAllKeys() throws {
		XCTAssertNoThrow(studentData.backendReadAllKeys())
	}
	

	
}

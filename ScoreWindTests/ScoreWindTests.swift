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
		//=>test guitar:do you know
		//reset wizard data
		studentData.removeAKey(keyName: "experience")
		studentData.removeAKey(keyName: "doYouKnow")
		studentData.removeAKey(keyName: "playable")
		
		//wizardInstrumentView
		studentData.wizardStepNames = [.wizardChooseInstrument]
		studentData.updateInstrumentChoice(instrument: .guitar)
		studentData.wizardStepNames.append(Page.wizardExperience)
		
		//wizardExperienceView
		studentData.updateExperience(experience: .continueLearning)
		
		let nextStepPage = scorewindData.createRecommendation(availableCourses: scorewindData.allCourses, studentData: studentData)
		if nextStepPage != .wizardChooseInstrument {
			studentData.wizardStepNames.append(nextStepPage)
		}
	}
	
}

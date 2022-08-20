//
//  iCloudKeyValue.swift
//  ScoreWindTests
//
//  Created by Leonore Yardimli on 2022/7/2.
//

import XCTest
@testable import ScoreWind

class iCloudKeyValue: XCTestCase {

	var studentDataModel = StudentData()
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	/*func testPerformanceExample() throws {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}*/
	
	func testReadAllKeys() throws {
		XCTAssertNoThrow(studentDataModel.backendReadAllKeys())
	}
	
	func testRemoveInstrumentKey() throws {
		//remove enrolled courses: enrolledCourses
		//remove instrument preference: instrument
		//remove completed lessons: completedLessons
		//remove watched lessons:watchedLessons
		XCTAssertNoThrow(studentDataModel.removeAKey(keyName: "watchedLessons"))
		studentDataModel.backendReadAllKeys()
	}
	
	func testSetInstrumentChoice() throws {
		XCTAssertNoThrow(studentDataModel.setInstrumentChoice(instrument: InstrumentType.guitar.rawValue))
	}
	
	func testGetInstrumentChoice() throws {
		XCTAssertNoThrow(print("get instrument choice: "+studentDataModel.getInstrumentChoice()))
	}
	
	func testUpdateCompletedLessons() throws {
		XCTAssertNoThrow(studentDataModel.updateCompletedLesson(courseID: 123, lessonID: 888, isCompleted: true))
		XCTAssertNoThrow(studentDataModel.updateCompletedLesson(courseID: 123, lessonID: 777, isCompleted: true))
	}
	
	func testGetCompletedLessons() throws {
		XCTAssertNoThrow(studentDataModel.getCompletedLessons(courseID: 123));
	}
	
	func testUpdateWatchedLesson() throws {
		XCTAssertNoThrow(studentDataModel.updateWatchedLessons(courseID: 123, lessonID: 888, addWatched: true))
		XCTAssertNoThrow(studentDataModel.updateWatchedLessons(courseID: 124, lessonID: 222, addWatched: true))
	}
	
	func testGetWatchedLessons() throws {
		XCTAssertNoThrow(studentDataModel.getWatchedLessons(courseID: 123))
	}
	
	/*func testUpdateEnrolledCourses() throws {
		let testCourseID = 12347
		let testCourseIsCompelted = true
		XCTAssertNoThrow(studentDataModel.updateEnrolledCourse(courseID: testCourseID, isCompleted: testCourseIsCompelted))
		studentDataModel.backendReadAllKeys()
	}*/
}

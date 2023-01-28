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
	
	func testReadAllMyKeys() throws {
		XCTAssertNoThrow(studentData.readAllUserDefaultKeys(keys: []))
	}
	
	func testRemoveAUserDefaultKey() throws {
		XCTAssertNoThrow(studentData.removeAUserDefaultKey(keyName: "hideTips"))
	}
	
}

//
//  CourseType.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/2/28.
//

import Foundation

enum CourseType {
	case path
	case stepByStep
	case noSpecific
	
	func getCategoryName() -> String{
		switch self {
		case .path:
			return "Path"
		case .stepByStep:
			return "Step By Step"
		case .noSpecific:
			return "Method"
		}
	}
}

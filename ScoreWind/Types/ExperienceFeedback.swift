//
//  ExperienceFeedback.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/11/5.
//

import Foundation
enum ExperienceFeedback:String {
	case starterKit = "I've never played it before" //never played it, start from 101
	case playedBefore = "I played this instrument before" //if no prior wizard data, show this option. Start from 103
	case continueLearning = "Continue learning" //If prior wizard data exists, show this option. Start from last completed lesson or course
}

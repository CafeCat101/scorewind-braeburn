//
//  LessonTextView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/15.
//

import SwiftUI

struct LessonTextView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	
	var body: some View {
		HTMLString(htmlContent: prepareLessonContent())
	}
	
	private func prepareLessonContent() -> String {
		let scoreAvailable = (scorewindData.currentTimestampRecs.count > 0) ? "<span style=\"background-color:#FFAF33;padding:8px;border-radius:10px;color:#4B3D41\"><b>Score Available</b></span>" : ""
		return scoreAvailable + scorewindData.currentLesson.content
	}
}

struct LessonTextView_Previews: PreviewProvider {
	static var previews: some View {
		LessonTextView().environmentObject(ScorewindData())
	}
}

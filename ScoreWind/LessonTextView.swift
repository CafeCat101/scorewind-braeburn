//
//  LessonTextView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/15.
//

import SwiftUI

struct LessonTextView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	let screenSize: CGRect = UIScreen.main.bounds
	
	var body: some View {
		VStack {
			HTMLString(htmlContent: scorewindData.currentLesson.content)
		}
		.background {
			RoundedRectangle(cornerRadius: 10)
				.foregroundColor(.gray)
		}
		.frame(width:screenSize.width*0.8, height: screenSize.height*0.8)
	}
}

struct LessonTextView_Previews: PreviewProvider {
	static var previews: some View {
		LessonTextView().environmentObject(ScorewindData())
	}
}

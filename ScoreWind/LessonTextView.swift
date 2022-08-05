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
	@State private var completedToggle = false
	@State private var completedIconName = "checkmark.bubble"
	
	var body: some View {
		VStack {
			HTMLString(htmlContent: scorewindData.currentLesson.content)
			HStack {
				Text("Score Available")
					.foregroundColor(.black)
					.padding(10)
					.background{
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(Color("ScoreAvailable"))
					}
				Spacer()
				Button(action: {
					print("lesson completed")
					withAnimation {
						if completedToggle == false {
							completedIconName = "checkmark.bubble.fill"
						} else {
							completedIconName = "checkmark.bubble"
						}
						
						completedToggle.toggle()
					}
				}){
					if completedToggle {
						Image(systemName: completedIconName)
							.foregroundColor(Color("ScoreAvailable"))
							.font(.largeTitle)
							.transition(.slide)
					} else {
						Image(systemName: completedIconName)
							.foregroundColor(Color("ScoreAvailable"))
							.font(.largeTitle)
					}
				}
			}
			.padding(8)
			.background(.yellow)
		}
		//HTMLString(htmlContent: prepareLessonContent())
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

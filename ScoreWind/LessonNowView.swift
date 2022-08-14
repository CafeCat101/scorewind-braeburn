//
//  LessonNowView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/8/8.
//

import SwiftUI

struct LessonNowView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@ObservedObject var downloadManager:DownloadManager
	let screenSize: CGRect = UIScreen.main.bounds
	var body: some View {
		NavigationLink(destination: LessonNowView(downloadManager: downloadManager)) {
			VStack {
				if scorewindData.currentView == Page.lesson {
					Button(action:{
						//showLessonSheet = true
					}) {
						HStack {
							Label("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title))", systemImage: "list.bullet.circle")
								.labelStyle(.titleAndIcon)
								.font(.title3)
								.foregroundColor(.black)
								.frame(width:screenSize.width*0.95, height: screenSize.height/25)
								.truncationMode(.tail)
							Spacer()
						}
						.padding(.horizontal, 10)
					}
				}
				Spacer()
				Text("Lesson Now View")
					.font(.largeTitle)
					
				Spacer()
			}
			.onAppear {
				print("[debug] LessonView onAppear")
				if scorewindData.currentView != Page.lessonFullScreen {
					scorewindData.currentView = Page.lesson
				}
			}
			
		}
	}
}

struct LessonNowView_Previews: PreviewProvider {
	static var previews: some View {
		LessonNowView(downloadManager: DownloadManager()).environmentObject(ScorewindData())
	}
}

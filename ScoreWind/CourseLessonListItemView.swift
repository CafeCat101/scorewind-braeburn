//
//  CourseLessonListItemView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/1.
//

import SwiftUI

struct CourseLessonListItemView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@EnvironmentObject var store: Store
	@Binding var selectedTab:String
	var lesson:Lesson
	@ObservedObject var downloadManager:DownloadManager
	@ObservedObject var studentData:StudentData
	@Binding var showLessonView: Bool
	@Binding var showStoreView: Bool
	
	var body: some View {
		VStack{
			if scorewindData.currentLesson.scorewindID == lesson.scorewindID {
				HStack {
					Spacer()
					Image(getIconTitleName())
						.resizable()
						.scaledToFit()
						.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
						.frame(maxHeight: 33)
					Spacer()
				}
				.padding(.top, 21)
				/*
				HStack {
					Spacer()
					HStack {
						HStack {
							VStack {
								Image(getIconTitleName())
									.resizable()
									.scaledToFit()
									.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
							}
						 .frame(maxHeight: 24)
							Text("Now")
								.bold()
								.foregroundColor(Color("Dynamic/DarkPurple"))
								.font(.subheadline)
								.frame(maxHeight: 24)
						}
						.padding(EdgeInsets(top: 10, leading: 22, bottom: 8, trailing: 31))
					}
					//.frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width*0.7 : (UIScreen.main.bounds.size.width*0.7)*0.5)
					.background(
						RoundedCornersShape(corners: [.allCorners], radius: 17)
							.fill(Color("Dynamic/MainBrown"))
							.opacity(0.25)
					)
					.padding(EdgeInsets(top: 15, leading: 17, bottom: 0, trailing: 0))
					Spacer()
				}
				 */
			}
			
			HStack {
				if scorewindData.arrangedTitle(title: lesson.title, instrumentType: scorewindData.currentCourse.instrument).count > 1 {
					VStack(alignment:.leading) {
						Text(scorewindData.arrangedTitle(title: lesson.title, instrumentType: scorewindData.currentCourse.instrument)[0]).font(.caption)
						Text(scorewindData.arrangedTitle(title: lesson.title, instrumentType: scorewindData.currentCourse.instrument)[1])
							.bold()
							.fixedSize(horizontal: false, vertical: true)
					}.foregroundColor(Color("Dynamic/MainBrown+6"))
				} else {
					Text(scorewindData.arrangedTitle(title: lesson.title, instrumentType: scorewindData.currentCourse.instrument)[0])
						.bold()
						.fixedSize(horizontal: false, vertical: true)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
				}
				
				Spacer()
			}
			.padding(EdgeInsets(top: scorewindData.currentLesson.scorewindID != lesson.scorewindID ? 21 : 5, leading: 16, bottom: 21, trailing: 16))

			if hasIcons(scorewindID: lesson.scorewindID, getLessonID: lesson.id) {
				Spacer()
				HStack(spacing:0) {
					//Spacer()
					HStack {
						downloadIconView(getLessonID: lesson.id)
							.foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color("Dynamic/MainBrown+6"))
							.padding(.trailing, 15)
						lessonIsons(scorewindID: lesson.scorewindID)
					}
					.padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 0))
					.background(
						RoundedCornersShape(corners: [.bottomLeft, .topRight], radius: 17)
							.fill(Color("Dynamic/MainBrown"))
							.opacity(0.25)
					)
					Spacer()
				}
			}
		}
		.frame(minHeight: 86)
		.background(
			RoundedCornersShape(corners: [.allCorners], radius: 17)
				.fill(scorewindData.currentLesson.scorewindID == lesson.scorewindID ? Color("Dynamic/PanelHighlighted") : Color("Dynamic/LightGray"))
				.opacity(0.85)
				.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
		)
		.onTapGesture {
			if store.purchasedSubscriptions.isEmpty && scorewindData.wizardPickedLesson.id != lesson.id {
				scorewindData.currentLesson = lesson
				scorewindData.setCurrentTimestampRecs()
				scorewindData.lastPlaybackTime = 0.0
				showStoreView = true
			} else {
				scorewindData.currentLesson = lesson
				scorewindData.setCurrentTimestampRecs()
				scorewindData.lastPlaybackTime = 0.0
				//self.selectedTab = "TLesson"
				scorewindData.lessonChanged = true
				withAnimation(Animation.linear(duration: 0.13)) {
					showLessonView = true
				}
				
			}
		}
	}
	
	private func hasIcons(scorewindID:Int, getLessonID: Int) -> Bool {
		var infoCount = 0
		if studentData.getCompletedLessons(courseID: scorewindData.currentCourse.id).contains(scorewindID) {
			infoCount = infoCount + 1
		}
		
		if studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id).contains(scorewindID) {
			infoCount = infoCount + 1
		}
		
		if downloadManager.checkDownloadStatus(lessonID: getLessonID) != DownloadStatus.notInQueue.rawValue {
			infoCount = infoCount + 1
		}
		
		if infoCount == 0 {
			return false
		} else {
			return true
		}
	}
	
	@ViewBuilder
	private func downloadIconView(getLessonID: Int) -> some View {
		let getStatus =  downloadManager.checkDownloadStatus(lessonID: getLessonID)
		if getStatus == DownloadStatus.inQueue.rawValue {
			Image(systemName: "arrow.down.to.line.compact")
				.foregroundColor(Color("Dynamic/MainBrown+6"))
		} else if getStatus == DownloadStatus.downloading.rawValue {
			/*Image(systemName: "arrow.down.circle")
				.foregroundColor(Color("LessonListStatusIcon"))*/
			DownloadSpinnerView(iconColor: Color("Dynamic/MainBrown+6"), spinnerColor: Color("Dynamic/IconHighlighted"), iconSystemImage: "arrow.down")
		} else if getStatus == DownloadStatus.downloaded.rawValue {
			Image(systemName: "arrow.down.circle.fill")
				.foregroundColor(Color("Dynamic/MainGreen"))
		} else if getStatus == DownloadStatus.failed.rawValue {
			Image(systemName: "exclamationmark.circle.fill")
				.foregroundColor(Color("Dynamic/Pink"))
		}
	}
	
	@ViewBuilder
	private func lessonIsons(scorewindID:Int) -> some View {
		let completedLessons = studentData.getCompletedLessons(courseID: scorewindData.currentCourse.id)
		if completedLessons.contains(scorewindID) {
			Label("completed", systemImage: "checkmark.circle.fill")
				.labelStyle(.iconOnly)
				.foregroundColor(Color("Dynamic/MainGreen"))
				.padding(.trailing, 15)
		}
		
		let watchedLessons = studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id)
		if watchedLessons.contains(scorewindID) {
			Label("watched", systemImage: "eye.circle.fill")
				.labelStyle(.iconOnly)
				.foregroundColor(Color("Dynamic/MainGreen"))
				.padding(.trailing, 15)
		}
	}
	
	private func getIconTitleName() -> String {
		if scorewindData.currentCourse.instrument == InstrumentType.guitar.rawValue {
			return "iconGuitar"
		} else {
			return "iconViolin"
		}
	}
	
}

struct CourseLessonListItemView_Previews: PreviewProvider {
	@State static var tab = "TCourse"
	static var previews: some View {
		CourseLessonListItemView(selectedTab:$tab, lesson: Lesson(), downloadManager: DownloadManager(), studentData: StudentData(), showLessonView: .constant(false), showStoreView: .constant(false)).environmentObject(ScorewindData())
	}
}

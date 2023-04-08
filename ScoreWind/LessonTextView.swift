//
//  LessonTextView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/15.
//

import SwiftUI

struct LessonTextView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@ObservedObject var studentData:StudentData
	@Binding var isCurrentLessonCompleted:Bool
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.verticalSizeClass) var verticalSize
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Text("About")
					.font(verticalSize == .regular ? .headline : .subheadline)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.bold()
				Spacer()
				Label("Close", systemImage: "xmark.circle.fill")
					.labelStyle(.iconOnly)
					.font(verticalSize == .regular ? .title2 : .title3)
					.foregroundColor(Color("Dynamic/MainGreen"))
					.onTapGesture {
						scorewindData.showLessonTextOverlay = false
					}
			}
			.padding(EdgeInsets(top: 15, leading: 15, bottom: 3, trailing: 15))
			/*.overlay(Label("Continue", systemImage: "xmark.circle.fill")
							 //.font(.title3)
				.labelStyle(.titleOnly)
				.foregroundColor(scorewindData.currentTimestampRecs.count>0 ? Color("LessonPlayLearnContinue") : Color("LessonWatchLearnContinue"))
				.padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
				.onTapGesture {
					scorewindData.showLessonTextOverlay = false
				}, alignment: .trailing)*/
			HStack(alignment: .firstTextBaseline) {
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title))
					.font(verticalSize == .regular ? .title2 : .title3)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.bold()
				Spacer()
			}
			.padding(EdgeInsets(top: 0, leading: 15, bottom: 5, trailing: 15))
			
			if isCurrentLessonCompleted || studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id).contains(scorewindData.currentLesson.scorewindID) {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack{
						if isCurrentLessonCompleted {
							Label(title: {
								Text("Completed")
									.bold()
									.foregroundColor(Color("Dynamic/DarkPurple"))
									.font(.headline)
							}, icon: {
								Image(systemName: "checkmark.circle.fill")
									.foregroundColor(Color("Dynamic/MainGreen"))
							})
							.fixedSize()
							.padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 15))
						}
						
						if studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id).contains(scorewindData.currentLesson.scorewindID) {
							if isCurrentLessonCompleted {
								Divider()
							}
							
							Label(title: {
								Text("Video is Watched")
									.bold()
									.foregroundColor(Color("Dynamic/DarkPurple"))
									.font(.headline)
							}, icon: {
								Image(systemName: "eye.circle.fill")
									.foregroundColor(Color("Dynamic/MainGreen"))
							})
							.fixedSize()
							.padding(EdgeInsets(top: 5, leading: isCurrentLessonCompleted ? 15 : 0, bottom: 10, trailing: 15))
							
						}
						Spacer()
					}
				}
				.frame(maxHeight: 35)
				.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
			}
			
			HStack {
				HStack {
					HStack {
						VStack {
							Image(systemName: scorewindData.currentTimestampRecs.count > 0 ? "music.note.tv.fill" : "video.bubble.left.fill")
								.resizable()
								.scaledToFit()
								.foregroundColor(Color("BadgeWatchLearn"))
								.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
						}
						.frame(maxHeight: 33)
						Text(scorewindData.currentTimestampRecs.count > 0 ? "Play and Learn" : "Watch and Learn")
							.bold()
							.foregroundColor(Color("Dynamic/DarkPurple"))
							.font(.headline)
							.frame(maxHeight: 33)
						Spacer()
					}
					.padding(EdgeInsets(top: 10, leading: 0, bottom: 33, trailing: 0))
				}
				.padding(.leading, 15)
				.frame(width: UIScreen.main.bounds.size.width*0.6)
				.background(
					RoundedCornersShape(corners: verticalSize == .regular ? [.topRight, .bottomRight] : [.allCorners], radius: 17)
						.fill(Color("Dynamic/MainBrown"))
						.opacity(0.25)
				)
				Spacer()
			}
			
			VStack{
				ScrollView {
					VStack {
						HStack {
							Text("\(scorewindData.courseContentNoHtml(content: scorewindData.currentLesson.content))")
								.foregroundColor(Color("Dynamic/MainBrown+6"))
							Spacer()
						}
						
						/*if scorewindData.currentTimestampRecs.count > 0 {
							Label("Play and learn", systemImage: "music.note.tv.fill")
								.labelStyle(.titleAndIcon)
								.foregroundColor(Color("LessonSheet"))
								.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
								.background {
									RoundedRectangle(cornerRadius: 26)
										.foregroundColor(Color("BadgeScoreAvailable"))
								}
								.fixedSize()
								.onTapGesture {
									scorewindData.showLessonTextOverlay = false
								}
						} else {
							Label("Watch and learn", systemImage: "video.bubble.left.fill")
								.labelStyle(.titleAndIcon)
								.foregroundColor(Color("LessonSheet"))
								.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
								.background {
									RoundedRectangle(cornerRadius: 26)
										.foregroundColor(Color("BadgeWatchLearn"))
								}
								.fixedSize()
								.onTapGesture {
									scorewindData.showLessonTextOverlay = false
								}
						}*/
					}
					.padding(EdgeInsets(top: 5, leading: 15, bottom: 50, trailing: 15))
				}
				.padding(EdgeInsets(top: 27, leading: 0, bottom: 17, trailing: 0))
			}
			.background(
				RoundedRectangle(cornerRadius: CGFloat(17))
					.foregroundColor(Color("Dynamic/MainBrown"))
					.opacity(0.30)
					.overlay(content: {
						Image(getBlankBackgroundInstrument())
							.resizable()
							.scaledToFill()
							//.scaledToFit()
							.padding(30)
							.opacity(0.25)
					})
			)
			.padding(EdgeInsets(top: -33, leading: 15, bottom: 15, trailing: 15))
			/*ScrollView {
				VStack {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack{
							if isCurrentLessonCompleted {
								Label(title: {
									Text("Completed")
										.bold()
										.foregroundColor(Color("Dynamic/DarkPurple"))
										.font(.headline)
								}, icon: {
									Image(systemName: "checkmark.circle.fill")
										.foregroundColor(Color("Dynamic/MainGreen"))
								})
								.fixedSize()
								.padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 15))
							}
							if studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id).contains(scorewindData.currentLesson.scorewindID) || 1 == 1 {
								if isCurrentLessonCompleted {
									Divider()
								}
								
								Label(title: {
									Text("Video is Watched")
										.bold()
										.foregroundColor(Color("Dynamic/DarkPurple"))
										.font(.headline)
								}, icon: {
									Image(systemName: "eye.circle.fill")
										.foregroundColor(Color("Dynamic/MainGreen"))
								})
								.fixedSize()
								.padding(EdgeInsets(top: 5, leading: isCurrentLessonCompleted ? 15 : 0, bottom: 10, trailing: 15))
								
							}
							Spacer()
						}
					}
					
					
					HStack {
						Text("\(scorewindData.courseContentNoHtml(content: scorewindData.currentLesson.content))")
							.foregroundColor(Color("Dynamic/MainBrown+6"))
						Spacer()
					}
					
					if scorewindData.currentTimestampRecs.count > 0 {
						Label("Play and learn", systemImage: "music.note.tv.fill")
							.labelStyle(.titleAndIcon)
							.foregroundColor(Color("LessonSheet"))
							.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
							.background {
								RoundedRectangle(cornerRadius: 26)
									.foregroundColor(Color("BadgeScoreAvailable"))
							}
							.fixedSize()
							.onTapGesture {
								scorewindData.showLessonTextOverlay = false
							}
					} else {
						Label("Watch and learn", systemImage: "video.bubble.left.fill")
							.labelStyle(.titleAndIcon)
							.foregroundColor(Color("LessonSheet"))
							.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
							.background {
								RoundedRectangle(cornerRadius: 26)
									.foregroundColor(Color("BadgeWatchLearn"))
							}
							.fixedSize()
							.onTapGesture {
								scorewindData.showLessonTextOverlay = false
							}
					}
				}.padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))
			}
			.background {
				Image(getBlankBackgroundInstrument())
					.resizable()
					.scaledToFit()
					.padding(30)
					.opacity(0.3)
			}
			.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))*/
		}
		.background(colorScheme == .light ? appBackgroundImage(colorMode: colorScheme) : appBackgroundImage(colorMode: colorScheme))
	}
	
	private func getBlankBackgroundInstrument() -> String {
		return scorewindData.currentCourse.instrument
		/*if studentData.getInstrumentChoice().isEmpty == false {
			return  studentData.getInstrumentChoice()
		} else {
			return "play_any"
			
		}*/
	}
}

struct LessonTextView_Previews: PreviewProvider {
	static var previews: some View {
		LessonTextView(studentData: StudentData(), isCurrentLessonCompleted: .constant(true))
			.environmentObject(ScorewindData())
	}
}

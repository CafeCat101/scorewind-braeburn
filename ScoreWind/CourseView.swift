//
//  CourseView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI
import WebKit

struct CourseView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State private var showOverview = true
	let screenSize: CGRect = UIScreen.main.bounds
	@Binding var selectedTab:String
	@State private var selectedSection = courseSection.overview
	@ObservedObject var downloadManager:DownloadManager
	@State private var showDownloadAlert = false
	@State private var startPos:CGPoint = .zero
	@State private var isSwipping = true
	@State private var scrollOffset:CGFloat = .zero
	@State private var dragOffset:CGFloat = .zero
	@State private var underlineScrollOffset:CGFloat = .zero
	//@State private var completedLessons:[Int] = []
	//@State private var watchedLessons:[Int] = []
	@State private var vScrolling = false
	@ObservedObject var studentData:StudentData
	
	var body: some View {
		VStack {
			HStack {
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))
					.font(.title3)
					.truncationMode(.tail)
				Spacer()
			}
			.frame(height: screenSize.height/25)
			.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 15))
			
			//show course section menus
			HStack {
				Button(action: {
					selectedSection = courseSection.overview
					withAnimation {
						scrollOffset = getNewOffset(goToSection: selectedSection)
						dragOffset = 0
					}
					
				}) {
					Text("Overview")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(selectedSection == courseSection.overview ? Color("ActiveCourseSectionTitle") : Color.gray)
				}
				.frame(width: screenSize.width/3)
				
				Spacer()
					.frame(width:5)
				
				Button(action: {
					selectedSection = courseSection.lessons
					withAnimation {
						scrollOffset = getNewOffset(goToSection: selectedSection)//getSectionOffset(goToSection: selectedSection)//0
						dragOffset = 0
					}
					
				}) {
					Text("Lessons")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(selectedSection == courseSection.lessons ? Color("ActiveCourseSectionTitle") : Color.gray)
				}
				.frame(width: screenSize.width/3)
				
				Button(action: {
					selectedSection = courseSection.continue
					withAnimation {
						scrollOffset = getNewOffset(goToSection: selectedSection)
						dragOffset = 0
					}
				}) {
					Text("Continue")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(selectedSection == courseSection.continue ? Color("ActiveCourseSectionTitle") : Color.gray)
				}
				.frame(width: screenSize.width/3)
				
			}
			.frame(height:screenSize.height/30-2)
			
			//Section menu underline
			HStack {
				Rectangle()
					.frame(width:screenSize.width/3, height: 2)
					.foregroundColor(Color("AppYellow"))
			}
			.frame(width:screenSize.width*3)
			.offset(x: underlineScrollOffset - dragOffset/3, y: 0)
			
			//show course progress
			courseProgressView()
			.padding(EdgeInsets(top: 3, leading: 10, bottom: 2, trailing: 10))
			
			//show sections in course
			HStack {
				//Overview section
				HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: overViewContent()))
					.frame(width:screenSize.width)
				
				//Lessons section
				VStack {
					ScrollViewReader { proxy in
						courseDownloadButtonView()
						List {
							Section(header: Text("Course content")){
								ForEach(scorewindData.currentCourse.lessons){ lesson in
									VStack {
										HStack {
											Button(action: {
												scorewindData.currentLesson = lesson
												scorewindData.setCurrentTimestampRecs()
												scorewindData.lastPlaybackTime = 0.0
												//scorewindData.lastViewAtScore = true
												self.selectedTab = "TLesson"
												scorewindData.lessonChanged = true
											}) {
												Text(scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title))
													.multilineTextAlignment(.leading)
													.foregroundColor(.black)
													.font(Font.body.bold())
												
											}
											Spacer()
											downloadIconView(getLessonID: lesson.id)
												.foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
											//.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
											
											lessonIsons(scorewindID: lesson.scorewindID)
										}
										Spacer()
											.frame(height:10)
									}
									.padding(EdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 10))
									.background{
										RoundedRectangle(cornerRadius: 10)
											.foregroundColor(scorewindData.currentLesson.scorewindID == lesson.scorewindID ? Color("AppYellow") : Color("LessonListTextBg"))
									}
									.id(lesson.scorewindID)
									
								}
							}
						}
						.listStyle(.plain)
						.onAppear(perform: {
							print("[debug] CourseView, lesson List-onAppear")
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
								withAnimation {
									proxy.scrollTo(scorewindData.currentLesson.scorewindID, anchor: .top)
								}
							
							}
						})
						//}
						Spacer()
					}
					
				}
				.frame(width:screenSize.width)
				//.onAppear(perform: {
					//DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						//print("[debug] CourseView, lesson section, VStack-dispatchQueue+0.5")
						//withAnimation {
							//completedLessons = scorewindData.studentData.getCompletedLessons(courseID: scorewindData.currentCourse.id)
							//watchedLessons = scorewindData.studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id)
						//}
					//}
				//})
				
				//Continue section
				VStack {
					ScrollView {
						if scorewindData.previousCourse.id > 0 {
							HStack {
								Text("Previous course")
									.fontWeight(.medium)
									.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
								Spacer()
							}
							HStack {
								continueCourseButton(order: SearchParameter.DESC)
									.padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
								Spacer()
							}
							Spacer()
								.frame(height:20)
						}
						
						if scorewindData.nextCourse.id > 0 {
							HStack {
								Text("Next course")
									.fontWeight(.medium)
									.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
								Spacer()
							}
							HStack {
								continueCourseButton(order: SearchParameter.ASC)
									.padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
								Spacer()
							}
						}
					}
					Spacer()
				}
				.frame(width:screenSize.width)
				.onAppear(perform: {
					scorewindData.findACourseByOrder(order: SearchParameter.DESC)
					scorewindData.findACourseByOrder(order: SearchParameter.ASC)
				})
			}
			.offset(x: scrollOffset + dragOffset, y: 0)
			.simultaneousGesture(
				DragGesture()
					.onChanged({event in
						if event.translation.width > 80 || event.translation.width < -80 {
							dragOffset = event.translation.width
						}
						
					})
					.onEnded({event in
						// Scroll to where user dragged
						print("[debug] CourseView, onDragEnded, translation.width \(event.translation.width)")
						//if event.translation.width>50 {
							scrollOffset += event.translation.width
							dragOffset = 0
							
							underlineScrollOffset -= event.translation.width/3
							
							// Animate snapping
							withAnimation {
								scrollOffset = getNewOffset()
								print("HStack DragGesture.onEnded scrollOffset \(scrollOffset)")
							}
						//}
						
					})
			)
		}
		.onAppear(perform: {
			print("[debug] CourseView, dragOffset \(dragOffset)")
			underlineScrollOffset = 0-screenSize.width/3
			scrollOffset = getSectionOffset(goToSection: selectedSection)
		})
	}
	
	@ViewBuilder
	private func courseProgressView() -> some View {
		HStack {
			Text("\(calculateCompletedLesson())/\(scorewindData.currentCourse.lessons.count) steps")
				.foregroundColor(.gray)
			HStack {
				if calculateCompletedLesson() > 0 {
					RoundedRectangle(cornerRadius: 4)
						.foregroundColor(Color("AppYellow"))
						.frame(width:calculateProgressBarWidth()[0],height:10)
					RoundedRectangle(cornerRadius: 4)
						.foregroundColor(.gray)
						.frame(width:calculateProgressBarWidth()[1],height:10)
					/*if scorewindData.currentCourse.lessons.count <= 10 {
						ForEach(1...calculateCompletedLesson(), id:\.self){ index in
							Circle()
								.strokeBorder(Color.gray,lineWidth: 1)
								.background(Circle().foregroundColor(Color.yellow))
								.frame(width:10,height:10)
						}
						ForEach(1...(scorewindData.currentCourse.lessons.count - calculateCompletedLesson()), id:\.self){ index in
							Circle()
								.strokeBorder(Color.gray,lineWidth: 1)
								.background(Circle().foregroundColor(Color.white))
								.frame(width:10,height:10)
						}
					} else {
						RoundedRectangle(cornerRadius: 4)
							.foregroundColor(.yellow)
							.frame(width:calculateProgressBarWidth()[0],height:10)
						RoundedRectangle(cornerRadius: 4)
							.foregroundColor(.gray)
							.frame(width:calculateProgressBarWidth()[1],height:10)
					}*/
				} else {
					/*RoundedRectangle(cornerRadius: 4)
						.stroke(.gray, lineWidth: 1)
						.foregroundColor(Color("LessonSheet"))
						.frame(width:calculateProgressBarWidth()[1],height:10)*/
					if scorewindData.currentCourse.lessons.count <= 10 {
						ForEach(((11-scorewindData.currentCourse.lessons.count)...10).reversed(), id:\.self){ number in
							Circle()
								.foregroundColor(Color.gray)
								.background(Circle().foregroundColor(Color.white))
								.frame(width:10,height:10)
						}
					} else {
						ForEach((1...10).reversed(), id:\.self){ number in
							Circle()
								.foregroundColor(Color.gray)
								.background(Circle().foregroundColor(Color.white))
								.frame(width:CGFloat(number),height:10)}
						/*ForEach(1...10, id:\.self){ number in
							if number <= 4 || number >= 8 {
								Circle()
									.strokeBorder(Color.gray,lineWidth: 1)
									.background(Circle().foregroundColor(Color.white))
									.frame(width:10,height:10)
							} else {
								Circle()
									.strokeBorder(Color.gray,lineWidth: 1)
									.background(Circle().foregroundColor(Color.gray))
									.frame(width:5,height:5)
							}
						}*/
					}
				}
			}
		}
	}
	
	private func calculateCompletedLesson() -> Int {
		let getCompletedLessons = studentData.getCompletedLessons(courseID: scorewindData.currentCourse.id)
		var completedCount = 0
		for i in 0..<scorewindData.currentCourse.lessons.count {
			if getCompletedLessons.contains(scorewindData.currentCourse.lessons[i].scorewindID) {
				completedCount += 1
			}
		}
		print("[debug] CourseView, calculateCompletedLesson \(completedCount)")
		return completedCount
	}
	
	private func calculateProgressBarWidth() -> [CGFloat] {
		let totalWidth:CGFloat = screenSize.width*0.7
		let completedLessonCount:CGFloat = CGFloat(calculateCompletedLesson())
		var completedWidth:CGFloat = 0.0
		
		completedWidth = totalWidth*completedLessonCount/10
		
		print("[deubg] CourseView, calculateProgressbarWidth, totalWidth: \(totalWidth)")
		print("[deubg] CourseView, calculateProgressbarWidth, completedWidth: \(completedWidth)")
		print("[deubg] CourseView, calculateProgressbarWidth, inCompletedWidth as int: \(Int((totalWidth-completedWidth)))")
		
		return [completedWidth,(totalWidth-completedWidth)]
	}
	
	@ViewBuilder
	private func downloadIconView(getLessonID: Int) -> some View {
		let getStatus =  downloadManager.checkDownloadStatus(lessonID: getLessonID)
		if getStatus == DownloadStatus.inQueue.rawValue {
			Image(systemName: "arrow.down.square")
				.foregroundColor(Color.gray)
		} else if getStatus == DownloadStatus.downloading.rawValue {
			Image(systemName: "square.and.arrow.down.on.square.fill")
				.foregroundColor(.blue)
		} else if getStatus == DownloadStatus.downloaded.rawValue {
			Image(systemName: "arrow.down.square.fill")
				.foregroundColor(Color.green)
		} else if getStatus == DownloadStatus.failed.rawValue {
			Image(systemName: "exclamationmark.square")
				.foregroundColor(Color.gray)
		}
	}
	
	@ViewBuilder
	private func courseDownloadButtonView() -> some View {
		let getStatus =  downloadManager.checkDownloadStatus(courseID: scorewindData.currentCourse.id, lessonsCount: scorewindData.currentCourse.lessons.count)

		HStack {
			if getStatus == DownloadStatus.notInQueue {
				Image(systemName: "arrow.down.to.line.circle")
					.foregroundColor(Color("AppYelloDynamic"))
			} else if getStatus == DownloadStatus.inQueue {
				Image(systemName: "arrow.down.square")
					.foregroundColor(Color.gray)
			} else if getStatus == DownloadStatus.downloading {
				Image(systemName: "square.and.arrow.down.on.square.fill")
					.foregroundColor(.blue)
			} else if getStatus == DownloadStatus.downloaded {
				Image(systemName: "arrow.down.square.fill")
					.foregroundColor(Color.green)
			} else if getStatus == DownloadStatus.failed {
				Image(systemName: "exclamationmark.square")
					.foregroundColor(Color.green)
			}
			
			Button(action: {
				showDownloadAlert = true
			}) {
				if getStatus == DownloadStatus.notInQueue {
					Text("Download course for offline")
						.foregroundColor(Color("AppYelloDynamic"))
				} else {
					Text("Remove downloads")
						.foregroundColor(Color("AppYelloDynamic"))
				}
			}
			.alert("\(getAlertDialogTitle(downloadStatus:getStatus))", isPresented: $showDownloadAlert, actions: {
				Button("ok", action:{
					print("[debug] CourseView, alert ok.")
					showDownloadAlert = false
					downloadManager.addOrRemoveCourseOffline(currentCourseDownloadStatus: getStatus, courseID: scorewindData.currentCourse.id, lessons: scorewindData.currentCourse.lessons)
					if downloadManager.downloadingCourse == 0 && getStatus == DownloadStatus.notInQueue {
						Task {
							print("[debug] download all Task")
							do {
								try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
							} catch {
								print("[debug] download all, catch, \(error)")
							}
							
						}
					} else {
						print("[debug] downloadVideoXML task is running.")
					}
					
				})
				Button("Cancel", role:.cancel, action:{
					showDownloadAlert = false
				})
			}, message: {
				if getStatus == DownloadStatus.notInQueue {
					Text("128 MB course content will be downloaded into your device. Continue?")
				} else {
					Text("After removing downloads, you can not take course offline. Continue?")
				}
			})
		}
		.padding()
		.background{
			RoundedRectangle(cornerRadius: 10)
				.stroke(Color("downloadCourse"), lineWidth:1)
		}
	}
	
	private func getAlertDialogTitle(downloadStatus: DownloadStatus) -> String {
		if downloadStatus == DownloadStatus.notInQueue {
			return "Download course"
		} else {
			return "Remove download"
		}
	}
	
	@ViewBuilder
	private func continueCourseButton(order: SearchParameter) -> some View {
		if order == SearchParameter.ASC {
			Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.nextCourse.title))
				.foregroundColor(Color("MyCourseItemText"))
				.multilineTextAlignment(.leading)
				.padding()
				.background{
					RoundedRectangle(cornerRadius: 10)
						.foregroundColor(Color("MyCourseItem"))
				}
				.onTapGesture {
					switchCourse(order: order)
				}
		} else {
			Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.previousCourse.title))
				.foregroundColor(Color("MyCourseItemText"))
				.multilineTextAlignment(.leading)
				.padding()
				.background{
					RoundedRectangle(cornerRadius: 10)
						.foregroundColor(Color("MyCourseItem"))
				}
				.onTapGesture {
					switchCourse(order: order)
				}
		}
	}
	
	private func switchCourse(order: SearchParameter) {
		scorewindData.currentCourse = (order == SearchParameter.ASC) ? scorewindData.nextCourse : scorewindData.previousCourse
		scorewindData.currentLesson = scorewindData.currentCourse.lessons[0]
		scorewindData.setCurrentTimestampRecs()
		scorewindData.lastPlaybackTime = 0.0
		selectedSection = courseSection.overview
		scorewindData.findACourseByOrder(order: SearchParameter.DESC)
		scorewindData.findACourseByOrder(order: SearchParameter.ASC)
		
		selectedSection = courseSection.overview
		withAnimation {
			scrollOffset = getNewOffset(goToSection: selectedSection)
			dragOffset = 0
		}
	}
	
	private func overViewContent() -> String {
		let setDuration = scorewindData.currentCourse.duration ?? "n/a"
		return "<b>Category:</b>&nbsp;\(scorewindData.courseCategoryToString(courseCategories: scorewindData.currentCourse.category, depth: 3))<br><b>Level:&nbsp;</b>\(scorewindData.currentCourse.level)<br><b>Duration:&nbsp;</b>\(setDuration)\(scorewindData.currentCourse.content)"
	}
	
	private func getNewOffset(goToSection:courseSection? = nil) -> CGFloat{
		let items: Int = 3
		let itemWidth: CGFloat = screenSize.width
		let itemSpacing: CGFloat = 10.0
		
		// Now calculate which item to snap to
		let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
		let screenWidth = UIScreen.main.bounds.width
		
		// Center position of current offset
		let center = scrollOffset + (screenWidth / 2.0) + (contentWidth / 2.0)
		
		// Calculate which item we are closest to using the defined size
		var index = (center - (screenWidth / 2.0)) / (itemWidth + itemSpacing)
		print("[debug] getNewOffset, index \(index)")
		// Should we stay at current index or are we closer to the next item...
		if index.remainder(dividingBy: 1) > 0.5 {
			index += 1
		} else {
			index = CGFloat(Int(index))
		}
		
		// Protect from scrolling out of bounds
		index = min(index, CGFloat(items) - 1)
		index = max(index, 0)
		print("[debug] getNewOffset, index \(index)")
		// Set final offset (snapping to item)]
		if goToSection != nil {
			if goToSection == courseSection.continue {
				index = 0.0
				underlineScrollOffset = screenSize.width/3
			} else if goToSection == courseSection.lessons {
				index = 1.0
				underlineScrollOffset = 0
			} else {
				index = 2.0
				underlineScrollOffset = 0-screenSize.width/3
			}
		} else {
			if index == 2.0 {
				selectedSection = courseSection.overview
				underlineScrollOffset = 0-screenSize.width/3
			} else if index == 1.0 {
				selectedSection = courseSection.lessons
				underlineScrollOffset = 0
			} else if index == 0.0 {
				selectedSection = courseSection.continue
				underlineScrollOffset = screenSize.width/3
			}
		}
		return index * itemWidth + (index - 1) * itemSpacing - (contentWidth / 2.0) + (screenWidth / 2.0) - ((screenWidth - itemWidth) / 2.0) + itemSpacing
	}
	
	private func getSectionOffset(goToSection:courseSection) -> CGFloat {
		let sectionCount:Int = 3
		let secctionWidth:CGFloat = screenSize.width
		let itemSpacing: CGFloat = 10.0
		let contentWidth: CGFloat = CGFloat(sectionCount) * secctionWidth + CGFloat(sectionCount - 1) * itemSpacing
		if goToSection == courseSection.lessons {
			underlineScrollOffset = 0
			return .zero
		} else if goToSection == courseSection.continue {
			underlineScrollOffset = 0+screenSize.width/3
			return 0-(contentWidth/CGFloat(sectionCount))
		} else {
			underlineScrollOffset = 0-screenSize.width/3
			return contentWidth/CGFloat(sectionCount)
		}
	}
	
	@ViewBuilder
	private func lessonIsons(scorewindID:Int) -> some View {
		let completedLessons = studentData.getCompletedLessons(courseID: scorewindData.currentCourse.id)
		if completedLessons.contains(scorewindID) {
			Label("completed", systemImage: "checkmark.circle.fill")
				.labelStyle(.iconOnly)
				.foregroundColor(Color("LessonListStatusIcon"))
		}
		
		let watchedLessons = studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id)
		if watchedLessons.contains(scorewindID) {
			Label("watched", systemImage: "eye.circle.fill")
				.labelStyle(.iconOnly)
				.foregroundColor(Color("LessonListStatusIcon"))
		}
	}

}

struct CourseView_Previews: PreviewProvider {
	@State static var tab = "TCourse"
	static var previews: some View {
		CourseView(selectedTab: $tab, downloadManager: DownloadManager(), studentData: StudentData()).environmentObject(ScorewindData())
	}
}

enum courseSection {
	case overview
	case lessons
	case `continue`
}

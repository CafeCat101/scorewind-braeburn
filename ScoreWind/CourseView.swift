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
	
	var body: some View {
		VStack {
			Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))")
				.font(.title3)
				.frame(width:screenSize.width*0.95, height: screenSize.height/25)
				.truncationMode(.tail)
			/*.contextMenu(menuItems:{
			 Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))
			 .font(.headline)
			 .frame(width:screenSize.width*0.9, height:screenSize.height*0.5)
			 })*/
			
			HStack {
				Button(action: {
					selectedSection = courseSection.overview
					withAnimation {
						scrollOffset = getNewOffset(goToSection: selectedSection)//getSectionOffset(goToSection: selectedSection)//400
						dragOffset = 0
						//underlineScrollOffset = 0-screenSize.width/3
					}
					
				}) {
					Text("Overview")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(selectedSection == courseSection.overview ? Color.black : Color.gray)
				}
				.frame(width: screenSize.width/3)
				
				Spacer()
					.frame(width:5)
				
				Button(action: {
					selectedSection = courseSection.lessons
					withAnimation {
						scrollOffset = getNewOffset(goToSection: selectedSection)//getSectionOffset(goToSection: selectedSection)//0
						dragOffset = 0
						//underlineScrollOffset = 0
					}
					
				}) {
					Text("Lessons")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(selectedSection == courseSection.lessons ? Color.black : Color.gray)
				}
				.frame(width: screenSize.width/3)
				
				Button(action: {
					selectedSection = courseSection.continue
					withAnimation {
						scrollOffset = getNewOffset(goToSection: selectedSection)//getSectionOffset(goToSection: selectedSection)//-400
						dragOffset = 0
						//underlineScrollOffset = screenSize.width/3
					}
				}) {
					Text("Continue")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(selectedSection == courseSection.continue ? Color.black : Color.gray)
				}
				.frame(width: screenSize.width/3)
				
			}
			.frame(height:screenSize.height/30-2)
			
			//Section menu underline
			HStack {
				Rectangle()
					.frame(width:screenSize.width/3, height: 2)
					.foregroundColor(.yellow)
			}
			.frame(width:screenSize.width*3)
			.offset(x: underlineScrollOffset - dragOffset/3, y: 0)
			
			/*HStack{
			 Rectangle()
			 .frame(width:screenSize.width-4, height: 5)
			 .foregroundColor(.white)
			 }
			 .padding(EdgeInsets(top: 2, leading: 1, bottom: 2, trailing: 1))
			 .background{
			 Rectangle()
			 .frame(width:screenSize.width, height: 30)
			 .foregroundColor(.gray)
			 }*/
			HStack {
				courseProgressView()
				Spacer()
			}
			.padding(EdgeInsets(top: 3, leading: 10, bottom: 2, trailing: 10))
			
			HStack {
				//Overview section
				HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: overViewContent()))
					.frame(width:screenSize.width)
				
				//Lessons section
				VStack {
					courseDownloadButtonView()
					//ScrollView {
					/*ForEach(scorewindData.currentCourse.lessons){ lesson in
					 HStack {
					 downloadIconView(getLessonID: lesson.id)
					 .foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
					 .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
					 
					 Button(action: {
					 scorewindData.currentLesson = lesson
					 scorewindData.setCurrentTimestampRecs()
					 //scorewindData.currentView = Page.lesson
					 scorewindData.lastPlaybackTime = 0.0
					 if scorewindData.currentTimestampRecs.count == 0 {
					 scorewindData.lastViewAtScore = false
					 }
					 self.selectedTab = "TLesson"
					 }) {
					 Text(scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title))
					 .multilineTextAlignment(.leading)
					 .foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
					 }
					 .padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
					 Spacer()
					 }
					 Divider()
					 .frame(height:1)
					 .background(Color("ListDivider"))
					 .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
					 }*/
					List {
						Section(header: Text("In This Course...")){
							ForEach(scorewindData.currentCourse.lessons){ lesson in
								VStack {
									HStack {
										downloadIconView(getLessonID: lesson.id)
											.foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
										//.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
										
										Button(action: {
											scorewindData.currentLesson = lesson
											scorewindData.setCurrentTimestampRecs()
											//scorewindData.currentView = Page.lesson
											scorewindData.lastPlaybackTime = 0.0
											/*if scorewindData.currentTimestampRecs.count == 0 {
												scorewindData.lastViewAtScore = false
											}*/
											self.selectedTab = "TLesson"
										}) {
											Text(scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title))
												.multilineTextAlignment(.leading)
												.foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
												.font(Font.body.bold())
											
										}
										//.padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
										Spacer()
									}
									Spacer()
										.frame(height:10)
									HStack {
										Text(lesson.description)
										Spacer()
									}
								}
								.padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
								.background{
									RoundedRectangle(cornerRadius: 10)
										.foregroundColor(Color("LessonTextBg"))
								}
								
							}
						}
					}
					.listStyle(.plain)
					//}
					Spacer()
				}.frame(width:screenSize.width)
				
				//Continue section
				VStack {
					ScrollView {
						if scorewindData.previousCourse.id > 0 {
							HStack {
								Text("Previous course")
									.foregroundColor(.gray)
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
									.foregroundColor(.gray)
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
				}.frame(width:screenSize.width)
			}
			.offset(x: scrollOffset + dragOffset, y: 0)
			.simultaneousGesture(
				DragGesture()
					.onChanged({event in
						dragOffset = event.translation.width
					})
					.onEnded({event in
						// Scroll to where user dragged
						scrollOffset += event.translation.width
						dragOffset = 0
						
						underlineScrollOffset -= event.translation.width/3
						
						// Animate snapping
						withAnimation {
							scrollOffset = getNewOffset()
							print("HStack DragGesture.onEnded scrollOffset \(scrollOffset)")
						}
					})
			)
		}
		.onAppear(perform: {
			print("[debug] CourseView, dragOffset \(dragOffset)")
			underlineScrollOffset = 0-screenSize.width/3
			scrollOffset = getSectionOffset(goToSection: selectedSection)//getInitialOffset()
			scorewindData.findACourseByOrder(order: SearchParameter.DESC)
			scorewindData.findACourseByOrder(order: SearchParameter.ASC)
		})
	}
	
	@ViewBuilder
	private func courseProgressView() -> some View {
		//come back here after finish marking lesson complete
		ForEach(0...(scorewindData.currentCourse.lessons.count-1), id:\.self){ index in
			Circle()
				.strokeBorder(Color.gray,lineWidth: 1)
				.background(Circle().foregroundColor(Color.white))
				.frame(width:10,height:10)
		}
		Text("0/\(scorewindData.currentCourse.lessons.count) steps")
			.foregroundColor(.gray)
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
				Image(systemName: "arrow.down.to.line")
					.foregroundColor(Color.black)
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
						.foregroundColor(Color.black)
				} else {
					Text("Remove downloads")
						.foregroundColor(Color.black)
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
		Button(action: {
			scorewindData.currentCourse = (order == SearchParameter.ASC) ? scorewindData.nextCourse : scorewindData.previousCourse
			scorewindData.currentLesson = scorewindData.currentCourse.lessons[0]
			scorewindData.setCurrentTimestampRecs()
			scorewindData.lastPlaybackTime = 0.0
			selectedSection = courseSection.overview
			scorewindData.findACourseByOrder(order: SearchParameter.DESC)
			scorewindData.findACourseByOrder(order: SearchParameter.ASC)
		}) {
			if order == SearchParameter.ASC {
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.nextCourse.title))
					.foregroundColor(Color.black)
					.multilineTextAlignment(.leading)
			} else {
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.previousCourse.title))
					.foregroundColor(Color.black)
					.multilineTextAlignment(.leading)
			}
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
	
	struct ScrollingHStackModifier: ViewModifier {
		
		@State private var scrollOffset: CGFloat
		@State private var dragOffset: CGFloat
		
		var items: Int
		var itemWidth: CGFloat
		var itemSpacing: CGFloat
		//var scrollOffset: CGFloat
		
		init(items: Int, itemWidth: CGFloat, itemSpacing: CGFloat, scrollOffset: CGFloat) {
			self.items = items
			self.itemWidth = itemWidth
			self.itemSpacing = itemSpacing
			self.scrollOffset = scrollOffset
			
			// Calculate Total Content Width
			let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
			let screenWidth = UIScreen.main.bounds.width
			
			// Set Initial Offset to first Item
			let initialOffset = (contentWidth/2.0) - (screenWidth/2.0) + ((screenWidth - itemWidth) / 2.0)
			
			self._scrollOffset = State(initialValue: initialOffset)
			self._dragOffset = State(initialValue: 0)
		}
		
		func body(content: Content) -> some View {
			content
				.offset(x: scrollOffset + dragOffset, y: 0)
				.gesture(
					DragGesture()
						.onChanged({ event in
							dragOffset = event.translation.width
						})
						.onEnded({ event in
							// Scroll to where user dragged
							scrollOffset += event.translation.width
							dragOffset = 0
							
							// Now calculate which item to snap to
							let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
							let screenWidth = UIScreen.main.bounds.width
							
							// Center position of current offset
							let center = scrollOffset + (screenWidth / 2.0) + (contentWidth / 2.0)
							
							// Calculate which item we are closest to using the defined size
							var index = (center - (screenWidth / 2.0)) / (itemWidth + itemSpacing)
							
							// Should we stay at current index or are we closer to the next item...
							if index.remainder(dividingBy: 1) > 0.5 {
								index += 1
							} else {
								index = CGFloat(Int(index))
							}
							
							// Protect from scrolling out of bounds
							index = min(index, CGFloat(items) - 1)
							index = max(index, 0)
							
							// Set final offset (snapping to item)
							let newOffset = index * itemWidth + (index - 1) * itemSpacing - (contentWidth / 2.0) + (screenWidth / 2.0) - ((screenWidth - itemWidth) / 2.0) + itemSpacing
							
							// Animate snapping
							withAnimation {
								scrollOffset = newOffset
							}
						})
				)
		}
	}
	
}

struct CourseView_Previews: PreviewProvider {
	@State static var tab = "TCourse"
	static var previews: some View {
		CourseView(selectedTab: $tab, downloadManager: DownloadManager()).environmentObject(ScorewindData())
	}
}

enum courseSection {
	case overview
	case lessons
	case `continue`
}

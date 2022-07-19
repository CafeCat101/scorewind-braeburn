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
	
	var body: some View {
		VStack {
			Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))")
				.font(.title2)
			
			HStack {
				Button(action: {
					selectedSection = courseSection.overview
					withAnimation {
						scrollOffset = getNewNewOffset(goToSection: selectedSection)//400
						dragOffset = 0
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
						scrollOffset = getNewNewOffset(goToSection: selectedSection)//0
						dragOffset = 0
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
						scrollOffset = getNewNewOffset(goToSection: selectedSection)//-400
						dragOffset = 0
					}
				}) {
					Text("Continue")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(selectedSection == courseSection.continue ? Color.black : Color.gray)
				}
				.frame(width: screenSize.width/3)
				
			}
			.frame(height: screenSize.width/10)
			
			
			
			HStack {
				HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: overViewContent()))
					.frame(width:screenSize.width)
				VStack {
					courseDownloadButtonView()
					List {
						Section(header: Text("In this course...")) {
							ForEach(scorewindData.currentCourse.lessons){ lesson in
								HStack {
									downloadIconView(getLessonID: lesson.id)
										.foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
									
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
											.foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
									}
								}
							}
						}
					}
				}.frame(width:screenSize.width)
				
				VStack {
					List {
						if scorewindData.previousCourse.id > 0 {
							Section(header: Text("previous course")) {
								continueCourseButton(order: SearchParameter.DESC)
							}
						}
						if scorewindData.nextCourse.id > 0 {
							Section(header: Text("Next course")) {
								continueCourseButton(order: SearchParameter.ASC)
							}
						}
					}
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

						// Animate snapping
						withAnimation {
							scrollOffset = getNewOffset()
							print("HStack DragGesture.onEnded scrollOffset \(scrollOffset)")
						}
					})
			)
			//.modifier(ScrollingHStackModifier(items: 3, itemWidth: screenSize.width, itemSpacing: 10, scrollOffset: testScrollOffset))
			
			
			//*****************************************************
			/*
			 if selectedSection == courseSection.overview {
			 HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: overViewContent()))
			 } else if selectedSection == courseSection.lessons{
			 VStack {
			 courseDownloadButtonView()
			 List {
			 Section(header: Text("In this course...")) {
			 ForEach(scorewindData.currentCourse.lessons){ lesson in
			 HStack {
			 downloadIconView(getLessonID: lesson.id)
			 .foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
			 
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
			 .foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
			 }
			 }
			 }
			 }
			 }
			 }
			 } else if selectedSection == courseSection.continue {
			 List {
			 if scorewindData.previousCourse.id > 0 {
			 Section(header: Text("previous course")) {
			 continueCourseButton(order: SearchParameter.DESC)
			 }
			 }
			 if scorewindData.nextCourse.id > 0 {
			 Section(header: Text("Next course")) {
			 continueCourseButton(order: SearchParameter.ASC)
			 }
			 }
			 }
			 }
			 */
			//*****************************************************************
			//Spacer()
		}
		.onAppear(perform: {
			scrollOffset = getNewNewOffset(goToSection: selectedSection)//getInitialOffset()
			scorewindData.findACourseByOrder(order: SearchParameter.DESC)
			scorewindData.findACourseByOrder(order: SearchParameter.ASC)
		})
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
			} else {
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.previousCourse.title))
					.foregroundColor(Color.black)
			}
		}
	}
	
	private func overViewContent() -> String {
		let setDuration = scorewindData.currentCourse.duration ?? "n/a"
		return "<b>Category:</b>&nbsp;\(scorewindData.courseCategoryToString(courseCategories: scorewindData.currentCourse.category, depth: 3))<br><b>Level:&nbsp;</b>\(scorewindData.currentCourse.level)<br><b>Duration:&nbsp;</b>\(setDuration)\(scorewindData.currentCourse.content)"
	}
	
	private func getInitialOffset() -> CGFloat{
		let itemWidth: CGFloat = screenSize.width
		let items = 3
		let itemSpacing: CGFloat = 10.0
		let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
		let screenWidth = UIScreen.main.bounds.width
		let scrollOffsetX = (contentWidth/2.0) - (screenWidth/2.0) + ((screenWidth - itemWidth) / 2.0)
		
		if selectedSection == courseSection.overview {
			//scrollOffset = scrollOffsetX
			print("\(scrollOffsetX):\(contentWidth):\(itemWidth)")
			return scrollOffsetX
		} else if selectedSection == courseSection.lessons {
			//scrollOffset = screenWidth*2 + itemSpacing
			return 0-(screenWidth + (screenWidth/2.0) + itemSpacing)
		} else {
			return scrollOffset * 3
		}
	}
	
	private func getNewOffset() -> CGFloat{
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
		
		// Should we stay at current index or are we closer to the next item...
		if index.remainder(dividingBy: 1) > 0.5 {
			index += 1
		} else {
			index = CGFloat(Int(index))
		}
		
		// Protect from scrolling out of bounds
		index = min(index, CGFloat(items) - 1)
		index = max(index, 0)
		
		// Set final offset (snapping to item)]
		return index * itemWidth + (index - 1) * itemSpacing - (contentWidth / 2.0) + (screenWidth / 2.0) - ((screenWidth - itemWidth) / 2.0) + itemSpacing
	}
	
	private func getNewNewOffset(goToSection:courseSection) -> CGFloat {
		let sectionCount:Int = 3
		let secctionWidth:CGFloat = screenSize.width
		let itemSpacing: CGFloat = 10.0
		let contentWidth: CGFloat = CGFloat(sectionCount) * secctionWidth + CGFloat(sectionCount - 1) * itemSpacing
		if goToSection == courseSection.lessons {
			return .zero
		} else if goToSection == courseSection.continue {
			return 0-(contentWidth/CGFloat(sectionCount))
		} else {
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

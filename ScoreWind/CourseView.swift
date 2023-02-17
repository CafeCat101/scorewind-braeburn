//
//  CourseView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI
import WebKit
import StoreKit

struct CourseView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State private var showOverview = false
	let screenSize: CGRect = UIScreen.main.bounds
	@Binding var selectedTab:String
	@State private var selectedSection = courseSection.lessons
	@ObservedObject var downloadManager:DownloadManager
	@State private var startPos:CGPoint = .zero
	@State private var scrollOffset:CGFloat = .zero
	@State private var dragOffset:CGFloat = .zero
	@State private var underlineScrollOffset:CGFloat = .zero
	@ObservedObject var studentData:StudentData
	@State private var isFavourite = false
	@State private var pageCount:CGFloat = 2.0//3.0
	@State private var turncateTitle = false
	@State private var showStepTip = false
	@State private var tipContent:AnyView = AnyView(Text("Tip"))
	@State private var userDefaults = UserDefaults.standard
	@Binding var showLessonView:Bool
	@State private var showStore = false
	@EnvironmentObject var store: Store
	
	var body: some View {
		if scorewindData.currentCourse.id > 0 {
			VStack {
				HStack {
					Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))
						.foregroundColor(Color("AppBlackDynamic"))
						.font(.title2)
						.bold()
						.onTapGesture {
							withAnimation {
								turncateTitle.toggle()
							}
						}
					//.truncationMode(.tail)
					Spacer()
				}
				.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
				.modifier(turncateTheTitle(isTurncating: $turncateTitle))
				
				//show course section menus
				HStack {
					/*
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
					 .frame(width: screenSize.width/pageCount)
					 
					 
					 Spacer()
					 .frame(width:5)
					 */
					
					Button(action: {
						selectedSection = courseSection.lessons
						withAnimation {
							scrollOffset = getNewOffset(goToSection: selectedSection)//getSectionOffset(goToSection: selectedSection)//0
							dragOffset = 0
						}
						
					}) {
						Text("Course content")
							.font(.headline)
							.fontWeight(.semibold)
							.foregroundColor(selectedSection == courseSection.lessons ? Color("ActiveCourseSectionTitle") : Color.gray)
					}
					.frame(width: screenSize.width/pageCount)
					
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
					.frame(width: screenSize.width/pageCount)
					
				}
				.frame(height:screenSize.height/30-2)
				
				//Section menu underline
				HStack {
					Rectangle()
						.frame(width:screenSize.width/pageCount, height: 2)
						.foregroundColor(Color("AppYellow"))
				}
				.frame(width:screenSize.width*pageCount)
				.offset(x: underlineScrollOffset - dragOffset/pageCount, y: 0)
				
				
				
				//show sections in course
				HStack {
					/*
					 //Overview section
					 HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: overViewContent()))
					 .frame(width:screenSize.width)
					 */
					
					//Lessons section
					VStack {
						ScrollViewReader { proxy in
							/*HStack {
							 Text("Category: ").bold() + Text("\(scorewindData.courseCategoryToString(courseCategories: scorewindData.currentCourse.category, depth: 3))")
							 Spacer()
							 }.padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))*/
							//show course progress
							courseProgressView()
								.padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
							
							HStack {
								Text("\(scorewindData.currentCourse.lessons.count) Lessons ").bold()
								
								Text("Duration:").bold()+Text("\(scorewindData.currentCourse.duration ?? "n/a")")
								Spacer()
							}.padding(EdgeInsets(top:0, leading: 15, bottom: 8, trailing: 15))
							
							HStack {
								Label("About", systemImage: "info.circle")
									.labelStyle(.iconOnly)
									.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
									.background {
										RoundedRectangle(cornerRadius: 20)
											.stroke(Color("MyCourseFilterTagBorder"), lineWidth: 1)
											.background(RoundedRectangle(cornerRadius: 20).fill(Color("MyCourseItem")).opacity(0))
									}
									.foregroundColor(Color("MyCourseItemText"))
									.onTapGesture {
										showOverview = true
									}
								Label("Add to favourite", systemImage: isFavourite ? "heart.circle.fill" : "suit.heart")
									.labelStyle(.iconOnly)
									.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
									.background {
										RoundedRectangle(cornerRadius: 20)
											.stroke(Color("MyCourseFilterTagBorder"), lineWidth: 1)
											.background(RoundedRectangle(cornerRadius: 20).fill(Color("MyCourseItem")).opacity(0))
									}
									.foregroundColor(Color("MyCourseItemText"))
									.onTapGesture {
										studentData.updateFavouritedCourse(courseID: scorewindData.currentCourse.id)
										if studentData.getFavouritedCourses().contains(where: { Int($0.key) == scorewindData.currentCourse.id}) {
											isFavourite = true
										} else {
											isFavourite = false
										}
										studentData.updateMyCourses(allCourses: scorewindData.allCourses)
										studentData.updateMyCoursesDownloadStatus(allCourses: scorewindData.allCourses, downloadManager: downloadManager)
									}
								//courseDownloadButtonView()
								
								CourseDownloadButtonView(getStatus: downloadManager.checkDownloadStatus(courseID: scorewindData.currentCourse.id, lessonsCount: scorewindData.currentCourse.lessons.count), downloadManager: downloadManager)
								
								Spacer()
							}.padding(EdgeInsets(top: 0, leading: 15, bottom: 8, trailing: 15))
							
							ScrollView {
								ForEach(scorewindData.currentCourse.lessons){ lesson in
									CourseLessonListItemView(selectedTab: $selectedTab, lesson: lesson, downloadManager: downloadManager, studentData: studentData, showLessonView: $showLessonView)
										.padding(EdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 10))
										.background{
											RoundedRectangle(cornerRadius: 10)
												.foregroundColor(scorewindData.currentLesson.scorewindID == lesson.scorewindID ? Color("AppYellow") : Color("LessonListTextBg"))
										}
										.id(lesson.scorewindID)
								}.padding([.leading,.trailing], 15)
							}
							//.listStyle(.plain)
							.onAppear(perform: {
								print("[debug] CourseView, lesson List-onAppear")
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
									withAnimation {
										proxy.scrollTo(scorewindData.currentLesson.scorewindID, anchor: .top)
									}
									
								}
							})
						}
						Spacer()
					}
					.frame(width:screenSize.width)
					
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
							if event.translation.width > 30 || event.translation.width < (0-30) {
								dragOffset = event.translation.width
							}
							
						})
						.onEnded({event in
							// Scroll to where user dragged
							print("[debug] CourseView, onDragEnded, translation.width \(event.translation.width)")
							//if event.translation.width>50 {
							scrollOffset += event.translation.width
							dragOffset = 0
							
							underlineScrollOffset -= event.translation.width/pageCount
							
							// Animate snapping
							withAnimation {
								scrollOffset = getNewOffset()
								print("HStack DragGesture.onEnded scrollOffset \(scrollOffset)")
							}
							//}
							
						})
				)
			}
			.background(Color("AppBackground"))
			.sheet(isPresented: $showOverview, content: {
				VStack {
					HStack {
						Text("About this course")
							.font(.title2)
							.padding(15)
						Spacer()
						Label("Close", systemImage: "xmark.circle")
							.labelStyle(.iconOnly)
							.font(.title2)
							.padding(15)
							.onTapGesture {
								showOverview = false
							}
					}
					HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: overViewContent()))
				}
				.frame(width:screenSize.width)
				.edgesIgnoringSafeArea(.bottom)
			})
			.fullScreenCover(isPresented: $showStepTip, content: {
				TipTransparentModalView(showStepTip: $showStepTip, tipContent: $tipContent)
			})
			.fullScreenCover(isPresented: $showLessonView, content: {
				LessonView2(selectedTab: $selectedTab, downloadManager: downloadManager, studentData: studentData, showLessonView: $showLessonView)
			})
			.onAppear(perform: {
				print("[debug] CourseView, onAppear, dragOffset \(dragOffset)")
				underlineScrollOffset = 0-screenSize.width/pageCount
				scrollOffset = getSectionOffset(goToSection: selectedSection)
				if studentData.getFavouritedCourses().contains(where: { Int($0.key) == scorewindData.currentCourse.id}) {
					isFavourite = true
				} else {
					isFavourite = false
				}
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
					if turncateTitle == false {
						withAnimation {
							turncateTitle = true
						}
					}
				}
				if showLessonView == false {
					handleTip()
				}
				
				userDefaults.set(scorewindData.currentCourse.id,forKey: "lastViewedCourse")
			})
		} else {
			VStack {
				Label("Course", systemImage: "music.note")
					.labelStyle(.titleAndIcon)
				Spacer()
				Text(studentData.wizardResult.learningPath.count == 0 ? "Ask ScoreWind for a course or a lesson now.":"See the course and the lesson ScoreWind found last time.")
					.padding(15)
				Button(action: {
					selectedTab = "THome"
				}, label: {
					Text("Start").frame(minWidth:150)
				})
				.foregroundColor(Color("LessonListStatusIcon"))
				.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
				.background {
					RoundedRectangle(cornerRadius: 26)
						.foregroundColor(Color("AppYellow"))
				}
				Spacer()
				if store.purchasedSubscriptions.isEmpty {
					Group {
						Spacer()
						Text("View and subscribe to a Study Plan")
							.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
							.foregroundColor(Color("LessonListStatusIcon"))
							.background(Color("AppYellow"))
							.cornerRadius(26)
							.onTapGesture {
								showStore = true
							}
						Spacer()
					}
				}
				
			}
			.modifier(storeViewCover(showStore: $showStore, selectedTab: $selectedTab))
			.onAppear(perform: {
				if store.purchasedSubscriptions.isEmpty {
					DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
						showStore = true
					}
				}
			})
		}
		
	}
	
	private func handleTip() {
		let hideTips:[String] = userDefaults.object(forKey: "hideTips") as? [String] ?? []
		if hideTips.contains(Tip.courseview.rawValue) == false {
			tipContent = AnyView(TipContentMakerView(showStepTip: $showStepTip, hideTipValue: Tip.courseview.rawValue, tipMainContent: AnyView(tipHere())))
			showStepTip = true
		}
	}
	
	@ViewBuilder
	private func tipHere() -> some View {
		VStack {
			Text("This is the course.\nLet's check out what lessons the course has here!")
				.font(.headline)
				.modifier(StepExplainingText())
			VStack(alignment:.leading) {
				Text("You can \(Image(systemName: "hand.tap")) tap the course title to see its full title.")
					.modifier(TipExplainingParagraph())
				Text("You can \(Image(systemName: "suit.heart")) bookmark this course as one of your favourite courses.")
					.modifier(TipExplainingParagraph())
				Text("Or \(Image(systemName: "arrow.down.circle")) download the content of the course for offline usage.")
					.modifier(TipExplainingParagraph())
				Text("Of course, you can also learn more about this course by clicking here \(Image(systemName: "info.circle")). Enjoy!")
					.modifier(TipExplainingParagraph())
			}.padding([.bottom],18)
			
		}.background {
			RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("AppYellow"))
			.frame(width: UIScreen.main.bounds.width*0.9)}
	}
	
	@ViewBuilder
	private func courseProgressView() -> some View {
		HStack {
			Text("\(calculateCompletedLesson())/\(scorewindData.currentCourse.lessons.count) steps")
				.foregroundColor(.gray)
			Spacer()
		}
		
		HStack {
			if calculateCompletedLesson() > 0 {
				RoundedRectangle(cornerRadius: 4)
					.foregroundColor(Color("AppYellow"))
					.frame(width:calculateProgressBarWidth()[0],height:10)
				RoundedRectangle(cornerRadius: 4)
					.foregroundColor(.gray)
					.frame(width:calculateProgressBarWidth()[1],height:10)
			} else {
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
				}
			}
		}
		.padding([.top], -13)
		.frame(width: calculateProgressBarWidth()[2])
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
		let totalWidth:CGFloat = screenSize.width-30//*0.7
		let completedLessonCount:CGFloat = CGFloat(calculateCompletedLesson())
		var completedWidth:CGFloat = 0.0
		
		completedWidth = totalWidth*completedLessonCount/10
		
		print("[deubg] CourseView, calculateProgressbarWidth, totalWidth: \(totalWidth)")
		print("[deubg] CourseView, calculateProgressbarWidth, completedWidth: \(completedWidth)")
		print("[deubg] CourseView, calculateProgressbarWidth, inCompletedWidth as int: \(Int((totalWidth-completedWidth)))")
		
		return [completedWidth, (totalWidth-completedWidth), totalWidth]
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
		/*
		 let setDuration = scorewindData.currentCourse.duration ?? "n/a"
		 return "<b>Category:</b>&nbsp;\(scorewindData.courseCategoryToString(courseCategories: scorewindData.currentCourse.category, depth: 3))<br><b>Level:&nbsp;</b>\(scorewindData.currentCourse.level)<br><b>Duration:&nbsp;</b>\(setDuration)\(scorewindData.currentCourse.content)"
		 */
		return "<b>Category:</b>&nbsp;\(scorewindData.courseCategoryToString(courseCategories: scorewindData.currentCourse.category, depth: 3))<br>\(scorewindData.currentCourse.content)"
	}
	
	private func getNewOffset(goToSection:courseSection? = nil) -> CGFloat{
		let items: Int = Int(pageCount)//3
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
			/*if goToSection == courseSection.continue {
			 index = 0.0
			 underlineScrollOffset = screenSize.width/pageCount
			 } else if goToSection == courseSection.lessons {
			 index = 1.0
			 underlineScrollOffset = 0
			 } else {
			 index = 2.0
			 underlineScrollOffset = 0-screenSize.width/pageCount
			 }*/
			if goToSection == courseSection.continue {
				index = 0.0
				underlineScrollOffset = (screenSize.width/2)/pageCount
			} else if goToSection == courseSection.lessons {
				index = 1.0
				underlineScrollOffset = 0 - (screenSize.width/2)/pageCount
			}
		} else {
			/*if index == 2.0 {
			 selectedSection = courseSection.overview
			 underlineScrollOffset = 0-screenSize.width/pageCount
			 } else if index == 1.0 {
			 selectedSection = courseSection.lessons
			 underlineScrollOffset = 0
			 } else if index == 0.0 {
			 selectedSection = courseSection.continue
			 underlineScrollOffset = screenSize.width/pageCount
			 }*/
			if index == 1.0 {
				selectedSection = courseSection.lessons
				underlineScrollOffset = 0 - (screenSize.width/2)/pageCount
			} else if index == 0.0 {
				selectedSection = courseSection.continue
				underlineScrollOffset = (screenSize.width/2)/pageCount
			}
		}
		return index * itemWidth + (index - 1) * itemSpacing - (contentWidth / 2.0) + (screenWidth / 2.0) - ((screenWidth - itemWidth) / 2.0) + itemSpacing
	}
	
	private func getSectionOffset(goToSection:courseSection) -> CGFloat {
		let sectionCount:Int = Int(pageCount)//3
		let secctionWidth:CGFloat = screenSize.width
		let itemSpacing: CGFloat = 10.0
		let contentWidth: CGFloat = CGFloat(sectionCount) * secctionWidth + CGFloat(sectionCount - 1) * itemSpacing
		if goToSection == courseSection.lessons {
			underlineScrollOffset = 0 - (screenSize.width/2)/pageCount
			return 0+(contentWidth/2)/CGFloat(sectionCount)
		} else {
			underlineScrollOffset = (screenSize.width/2)/pageCount
			return 0-(contentWidth/2)/CGFloat(sectionCount)
		}
		/*
		 if goToSection == courseSection.lessons {
		 underlineScrollOffset = 0
		 return .zero
		 } else if goToSection == courseSection.continue {
		 underlineScrollOffset = 0+screenSize.width/pageCount
		 return 0-(contentWidth/CGFloat(sectionCount))
		 } else {
		 underlineScrollOffset = 0-screenSize.width/pageCount
		 return contentWidth/CGFloat(sectionCount)
		 }
		 */
	}
	
	struct turncateTheTitle: ViewModifier {
		@Binding var isTurncating:Bool
		func body(content: Content) -> some View {
			if isTurncating {
				content
					.frame(height: UIScreen.main.bounds.height/25)
			} else {
				content
			}
			
		}
	}
	
}

struct CourseView_Previews: PreviewProvider {
	@State static var tab = "TCourse"
	static var previews: some View {
		CourseView(selectedTab: $tab, downloadManager: DownloadManager(), studentData: StudentData(), showLessonView: .constant(false)).environmentObject(ScorewindData())
	}
}

enum courseSection {
	case overview
	case lessons
	case `continue`
}

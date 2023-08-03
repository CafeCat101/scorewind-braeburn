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
	@EnvironmentObject var store: Store
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
	@State private var showSubscriberOnlyAlert = false
	@Environment(\.verticalSizeClass) var verticalSize
	@Environment(\.colorScheme) var colorScheme
	
	
	var body: some View {
		VStack(spacing:0) {
			if scorewindData.currentCourse.id > 0 { //!!! put it back to > after done UI !!!!
				//show course title
				HStack {
					if verticalSize == .compact {
						Spacer()
					}
					Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))
						.font(verticalSize == .regular ? .title : .title3)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.bold()
						.modifier(turncateTheTitle(isTurncating: $turncateTitle))
						.truncationMode(.tail)
						/*.onTapGesture {
							withAnimation {
								turncateTitle.toggle()
								forceTurncateTitle.toggle()
							}
						}*/
					Spacer()
				}
				.padding([.leading, .trailing], 15)
				.padding(.top, 5)
				
				HStack(spacing:0) {
					if verticalSize == .compact {
						VStack(spacing:0) {
							displayHeaderContent()
						}.frame(width: UIScreen.main.bounds.size.width*0.35)
					}
					VStack(spacing:0) {
						if verticalSize == .regular {
							displayHeaderContent()
						}
						
						VStack{
							ScrollViewReader { proxy in
								ScrollView {
									VStack(spacing:0) {
										Spacer().frame(height: 10)
										ForEach(scorewindData.currentCourse.lessons){ lesson in
											/*if scorewindData.currentLesson.scorewindID == lesson.scorewindID {
												HStack {
													HStack {
														HStack {
															VStack {
																Image(getIconTitleName())
																	.resizable()
																	.scaledToFit()
																	.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
															}
															.frame(maxHeight: 33)
															Text("Currently")
																.bold()
																.foregroundColor(Color("Dynamic/DarkPurple"))
																.font(.subheadline)
																.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
																.frame(maxHeight: 33)
															//Spacer()
														}
														.padding(EdgeInsets(top: 10, leading: 22, bottom: 8, trailing: 31))
													}
													//.padding(.leading, 15)
													//.frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width*0.7 : (UIScreen.main.bounds.size.width*0.7)*0.5)
													.background(
														RoundedCornersShape(corners: [.topLeft,.topRight], radius: 17)
															.fill(Color("Dynamic/MainBrown"))
															.opacity(0.25)
													)
													.offset(x: 17)
													Spacer()
												}
												.id(lesson.scorewindID)
											}*/
											CourseLessonListItemView(
												selectedTab: $selectedTab,
												lesson: lesson,
												downloadManager: downloadManager,
												studentData: studentData,
												showLessonView: $showLessonView,
												showStoreView: $showStore)
											.id(lesson.scorewindID)
											//.padding(.top, scorewindData.currentLesson.scorewindID == lesson.scorewindID ? 0 : 0)
										}
										.padding([.leading,.trailing], 15)
										.padding([.bottom],12)
										Spacer().frame(height: 50)
									}
									.background(GeometryReader {
										Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .named("scroll")).origin.y)
									})
									.onPreferenceChange(ViewOffsetKey.self) {
										print("offset >> \($0)")
										if $0 > UIScreen.main.bounds.size.height*0.4 {
											withAnimation {
												turncateTitle = true
											}
										}
										
										if $0 <= 10 {
											withAnimation {
												turncateTitle = false
											}
										}
										
									}
								}
								.onAppear(perform: {
									print("[debug] CourseView, lesson List-onAppear")
									DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
										withAnimation {
											proxy.scrollTo(scorewindData.currentLesson.scorewindID, anchor: .top)
										}
									}
								})
								.coordinateSpace(name: "scroll")
							}
							
						}
					}
				}
				.onChange(of: verticalSize, perform: { info in
					if info == .compact {
						if turncateTitle {
							turncateTitle = false
						}
					}
				})
			} else {
				//show blank course look
				Label(title: {
					Text("Course")
						.font(verticalSize == .regular ? .title2 : .title3)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.bold()
				}, icon: {
					Image(systemName: "note.text")
				})
				.padding(.top,5)
				
				Spacer()
				
				VStack {
					Spacer()
					Text("Looks like you haven't started any course yet.")
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.padding(30)
					HStack {
						Text(studentData.wizardResult.learningPath.count == 0 ? "Ask ScoreWind for a course or a lesson now.":"See the course and the lesson ScoreWind found last time.")
							.font(.headline)
							.foregroundColor(Color("Dynamic/MainBrown+6"))
						Spacer()
						Label("Go to lesson", systemImage: "arrow.right.circle.fill")
							.labelStyle(.iconOnly)
							.font(.title2)
							.foregroundColor(Color("Dynamic/MainGreen")) //original is "Dynamic/MainBrown"
					}
					.padding(30)
					.frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width*0.8 : UIScreen.main.bounds.size.width*0.6)
					.background(
						RoundedCornersShape(corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 17)
							.fill(Color("Dynamic/LightGray"))
							.opacity(0.85)
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					)
					.onTapGesture {
						selectedTab = "THome"
					}
					Spacer()
				}
				.frame(width: UIScreen.main.bounds.size.width)
				.background {
					VStack {
						Spacer()
						Image(getBlankBackgroundInstrument())
							.resizable()
							.scaledToFit()
							.opacity(0.3)
							.padding(30)
					}
					
				}
				
				
				Spacer()
			}
			Divider()
		}
		.background(colorScheme == .light ? appBackgroundImage(colorMode: colorScheme) : appBackgroundImage(colorMode: colorScheme))
		.sheet(isPresented: $showOverview, content: {
			CourseOverViewView(showOverview: $showOverview)
		})
		.fullScreenCover(isPresented: $showStepTip, content: {
			TipTransparentModalView(showStepTip: $showStepTip, tipContent: $tipContent)
		})
		/*.fullScreenCover(isPresented: $showLessonView, content: {
			LessonView2(selectedTab: $selectedTab, downloadManager: downloadManager, studentData: studentData, showLessonView: $showLessonView)
		})*/
		/*.confirmationDialog("Subscription is required", isPresented: $showSubscriberOnlyAlert) {
			Button("View subscription", role: nil) {
				showStore = true
			}
			Button("Later", role: .cancel, action: {})
		} message: { Text("Subscription is required") }*/
		//.modifier(storeViewCover(showStore: $showStore, selectedTab: $selectedTab))
		.sheet(isPresented: $showStore, content: {
			StoreView(showStore: $showStore, studentData: studentData)
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
			
			/*DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
				if turncateTitle == false {
					withAnimation {
						turncateTitle = true
					}
				}
			}*/
			if showLessonView == false && showStore == false {
				//:: don't want to show tip again after viewStore sheet is dismissed. the default "Your purchase is all set" alert will trigger onAppear when it is dismissed.
				handleTip()
			}
			userDefaults.set(scorewindData.currentCourse.id,forKey: "lastViewedCourse")
			if scorewindData.currentLesson.id > 0 {
				userDefaults.set(scorewindData.currentLesson.id,forKey: "lastViewedLesson")
			}
			
			if showStore == false {
				Task {
					//When this view appears, get the latest subscription status.
					await store.updateCustomerProductStatus()
				}
				
				if showLessonView == false && scorewindData.isPublicUserVersion {
					//studentData.updateUsageActionCount(actionName: .viewCourse)
					studentData.updateLogs(title: .viewCourse, content: scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))
				}
			}
		})
	}

	private func getBlankBackgroundInstrument() -> String {
		if studentData.getInstrumentChoice().isEmpty == false {
			return studentData.getInstrumentChoice()
		} else {
			return "play_any"
			
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
		VStack(spacing:0) {
			HStack(spacing:0) {
				Label("tip", systemImage: "lightbulb")
					.labelStyle(.iconOnly)
					.font(.title2)
					.foregroundColor(Color("MainBrown+6"))
					.shadow(color: Color("Dynamic/ShadowReverse"),radius: CGFloat(10))
					.padding(EdgeInsets(top: 8, leading: 15, bottom: 4, trailing: 15))
					.background(
						RoundedCornersShape(corners: verticalSize == .regular ? [.topLeft, .topRight] : [.allCorners], radius: 10)
							.fill(Color("AppYellow"))
							.opacity(0.90)
					)
				Spacer()
			}.padding(.leading, 28)
			
			VStack(spacing:0) {
				ScrollView(showsIndicators: true) {
					VStack(alignment: .leading) {
						HStack {
							Spacer()
							Label("Course", systemImage: "note.text")
								.labelStyle(.iconOnly)
								.font(.title)
								.padding(.bottom, 5)
							Spacer()
						}
						HStack {
							Spacer()
							Text("The Course")
							.font(.headline)
							.padding(.bottom, 15)
							.multilineTextAlignment(.center)
							Spacer()
						}

						Divider().padding(.bottom, 20)
						
						CourseTipContent(instrument: scorewindData.currentCourse.instrument)
						/*Text("Let's check out what lessons this course has here and start learning!").padding(.bottom, 15)
						(Text("You can track your learning progress from the progress bar or inspect which lesson you've ")+Text(Image(systemName: "eye.circle.fill"))+Text(" watched or ")+Text(Image(systemName: "checkmark.circle.fill"))+Text(" completed from the lesson list.")).padding(.bottom, 15)*/
						
						/*Divider().padding(.bottom, 20)
						Text("Use features in the course to improve your learning experience.").padding(.bottom, 15)
						(Text("Click ")+Text(Image(systemName: "doc.plaintext"))+Text(" to learn what this course is about in detail.")).padding(.bottom, 8)
						(Text(Image(systemName: "suit.heart"))+Text(" Mark this course as your favorite for revisiting in the future.")).padding(.bottom, 8)
						(Text(Image(systemName: "arrow.down.circle"))+Text(" Download the course videos for your offline moments.")).padding(.bottom, 15)*/
						
						//(Text("Click ")+Text(Image(systemName: "doc.plaintext"))+Text(" to learn what this course is about in details. ")+Text(Image(systemName: "suit.heart"))+Text(" Mark this course as your favorite for revisiting in the future. ")+Text(Image(systemName: "arrow.down.circle"))+Text(" Download the course videos for your offline moments.")).padding(.bottom,15)
					}
					.foregroundColor(Color("MainBrown+6"))
					.padding(EdgeInsets(top: 18, leading: 40, bottom: 18, trailing: 40))
				}
			}
			.background(
				RoundedRectangle(cornerRadius: CGFloat(10))
					.foregroundColor(Color("AppYellow"))
					.shadow(color: Color("Dynamic/ShadowLight"),radius: CGFloat(7))
					.opacity(0.90)
			)
			.padding([.leading,.trailing],15)
		}
		
		
		
		/*VStack {
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
			.frame(width: UIScreen.main.bounds.width*0.9)}*/
	}
	
	@ViewBuilder
	private func courseProgressView() -> some View {
		GeometryReader { reader in
			VStack {
				HStack(spacing:0) {
					if calculateCompletedLesson() > 0 {
						
						RoundedRectangle(cornerRadius: 6)
							.foregroundColor(Color("Dynamic/ProgressBar"))
							.frame(width:calculateProgressBarWidth(frameSize: reader.size.width)[2],height:10)
							.overlay(alignment:.leading, content: {
								RoundedRectangle(cornerRadius: 6)
									.foregroundColor(Color("Dynamic/ProgressBarBG"))
									.frame(width:calculateProgressBarWidth(frameSize: reader.size.width)[0],height:10)
							})
					} else {
						RoundedRectangle(cornerRadius: 6)
							.stroke(Color("Dynamic/ProgressBarBG"), style: StrokeStyle(
								lineWidth: 1,
								lineCap: .round,
								lineJoin: .round,
								miterLimit: 0,
								dash: [50,5],
								dashPhase: 0
							))
							.frame(width:calculateProgressBarWidth(frameSize: reader.size.width)[2],height:10)
					}
				}
				.frame(width: calculateProgressBarWidth(frameSize: reader.size.width)[2])
				
				HStack {
					Text("Completed: \(calculateCompletedLesson())/\(scorewindData.currentCourse.lessons.count)")
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.bold()
					Spacer()
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
	
	private func calculateProgressBarWidth(frameSize: CGFloat) -> [CGFloat] {
		let totalWidth:CGFloat = frameSize//frameSize-30//*0.7
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
			return "Download Course"
		} else {
			return "Remove Download"
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
					if store.enablePurchase || store.couponState != .valid {
						showSubscriberOnlyAlert = true
					} else {
						switchCourse(order: order)
					}
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
					if store.enablePurchase || store.couponState != .valid {
						showSubscriberOnlyAlert = true
					} else {
						switchCourse(order: order)
					}
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
					.frame(maxHeight: 44)
					//.frame(height: UIScreen.main.bounds.height/25)
			} else {
				content
			}
		}
	}
	
	struct ViewOffsetKey: PreferenceKey {
			typealias Value = CGFloat
			static var defaultValue = CGFloat.zero
			static func reduce(value: inout Value, nextValue: () -> Value) {
					value += nextValue()
			}
	}
	
	@ViewBuilder
	private func displayHeaderContent() -> some View {
		if turncateTitle == false || verticalSize == .compact {
			VStack {
				HStack {
					Text("\(scorewindData.currentCourse.lessons.count) Lessons ")
						.bold()
						.foregroundColor(Color("Dynamic/MainBrown+6"))
					Text("Duration:").bold().foregroundColor(Color("Dynamic/MainBrown+6"))+Text("\(scorewindData.currentCourse.duration ?? "n/a")")
						.foregroundColor(Color("Dynamic/MainBrown+6"))
					Spacer()
				}.padding(EdgeInsets(top:8, leading: 15, bottom: 8, trailing: 15))
				
				courseProgressView()
					.frame(maxHeight: 45)
					.padding(EdgeInsets(top: 0, leading: 15, bottom: 8, trailing: 15))
					//.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
			}
			.background(
				RoundedRectangle(cornerRadius: CGFloat(17))
					.foregroundColor(Color("Dynamic/MainBrown"))
					.opacity(0.25)
			)
			.padding([.leading, .trailing], 15)
			.padding([.top,.bottom], 10)
		}
		
		//::feature buttons
		HStack {
			Label("About", systemImage: "doc.plaintext")
				.frame(maxWidth: 35, maxHeight:20)
				.labelStyle(.iconOnly)
				.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
				.foregroundColor(Color("Dynamic/MainBrown+6"))
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/MainBrown"))
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						.opacity(0.25)
						.overlay {
							RoundedRectangle(cornerRadius: 17)
								.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
						}
				)
				.onTapGesture {
					showOverview = true
				}
			Label("Add to favourite", systemImage: isFavourite ? "heart.fill" : "suit.heart")
				.frame(maxWidth: 35, maxHeight:20)
				.labelStyle(.iconOnly)
				.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
				.foregroundColor(isFavourite ? Color("Dynamic/IconHighlighted") : Color("Dynamic/MainBrown+6"))
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/MainBrown"))
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						.opacity(0.25)
						.overlay {
							RoundedRectangle(cornerRadius: 17)
								.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
						}
				)
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
			
			CourseDownloadButtonView(getStatus: downloadManager.checkDownloadStatus(courseID: scorewindData.currentCourse.id, lessonsCount: scorewindData.currentCourse.lessons.count), downloadManager: downloadManager, showStoreView: $showStore)
			
			Spacer()
		}
		.padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
	}
	
	private func getIconTitleName() -> String {
		if scorewindData.currentCourse.instrument == InstrumentType.guitar.rawValue {
			return "iconGuitar"
		} else {
			return "iconViolin"
		}
	}
	
	struct CourseOverViewView: View {
		@EnvironmentObject var scorewindData:ScorewindData
		@Environment(\.verticalSizeClass) var verticalSize
		@Binding var showOverview:Bool
		
		var body: some View {
			VStack(spacing:0) {
				HStack {
					Spacer()
					Text("About This Course")
						.font(verticalSize == .regular ? .title2 : .title3)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.bold()
					Spacer()
					Label("Close", systemImage: "xmark.circle.fill")
						.labelStyle(.iconOnly)
						.font(verticalSize == .regular ? .title2 : .title3)
						.foregroundColor(Color("Dynamic/MainGreen"))
						.onTapGesture {
							showOverview = false
						}
				}
				.padding(EdgeInsets(top: 15, leading: 15, bottom: 5, trailing: 15))
				.background(Color("Dynamic/LightGray"))
				HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: overViewContent()))
					.frame(width:UIScreen.main.bounds.size.width)
			}
			.edgesIgnoringSafeArea(.bottom)
			//.frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.8)
			//.offset(x: showOverview ? 0 : UIScreen.main.bounds.size.width + 50)
		}
		
		private func overViewContent() -> String {
			/*
			 let setDuration = scorewindData.currentCourse.duration ?? "n/a"
			 return "<b>Category:</b>&nbsp;\(scorewindData.courseCategoryToString(courseCategories: scorewindData.currentCourse.category, depth: 3))<br><b>Level:&nbsp;</b>\(scorewindData.currentCourse.level)<br><b>Duration:&nbsp;</b>\(setDuration)\(scorewindData.currentCourse.content)"
			 */
			return "<b>Category:</b>&nbsp;\(scorewindData.courseCategoryToString(courseCategories: scorewindData.currentCourse.category, depth: 3))<br>\(scorewindData.currentCourse.content)"
		}
	}
}

struct CourseView_Previews: PreviewProvider {
	@State static var tab = "TCourse"
	@StateObject static var scorewindData = ScorewindData()
	@StateObject static var store = Store()
	
	static var previews: some View {
		CourseView(selectedTab: $tab, downloadManager: DownloadManager(), studentData: StudentData(), showLessonView: .constant(false))
			.environmentObject(scorewindData)
			.environmentObject(store)
		
		CourseView(selectedTab: $tab, downloadManager: DownloadManager(), studentData: StudentData(), showLessonView: .constant(false))
			.environmentObject(scorewindData)
			.environmentObject(store)
			.previewInterfaceOrientation(InterfaceOrientation.landscapeLeft)
			.previewDisplayName("Light LandscapeLeft")
	}
}

enum courseSection {
	case overview
	case lessons
	case `continue`
}

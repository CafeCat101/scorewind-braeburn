//
//  LessonView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI
import AVKit

struct LessonView2: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@EnvironmentObject var store: Store
	@State private var screenSize: CGRect = UIScreen.main.bounds
	@State private var watchTime = ""
	@StateObject var viewModel = ViewModel()
	@State private var startPos:CGPoint = .zero
	@State private var isSwipping = true
	@Binding var selectedTab:String
	@ObservedObject var downloadManager:DownloadManager
	@State private var showLessonViewTip = false
	@State private var nextLesson = Lesson()
	@State private var previousLesson = Lesson()
	@State private var isCurrentLessonCompleted = false
	@State private var splitScreen = true
	@State private var showScoreZoomIcon = false
	@State private var savePlayerPlayable = false
	@ObservedObject var studentData:StudentData
	@State private var userDefaults = UserDefaults.standard
	@Binding var showLessonView:Bool
	@State private var showOverlayMenu = false
	@State private var viewRotaionDegree = 0.0
	@State private var tipContent:AnyView = AnyView(Text("Tip"))
	@State private var showStoreView = false
	@Environment(\.verticalSizeClass) var verticalSize
	@Environment(\.colorScheme) var colorScheme
	@State private var revealAVPlayer = false
	@State private var showVideoLoader = false
	@State private var tipVideo = AVPlayer(url: URL(fileURLWithPath: "DIY_Notestannd_HD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4"))
	//@State private var logVideoPlaybackTime: [String] = []
	@State private var lastUserUsageTimerCount = 0
	
	var body: some View {
		VStack {
			HStack {
				Label("Back to course", systemImage: "chevron.backward")
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.labelStyle(.iconOnly)
					.font(verticalSize == .regular ? .title2 : .title3)
					.onTapGesture {
						print("[debug] LessonView2 store, Back.onTapGesture")
						let totalCompleted:Double = Double(studentData.getTotalCompletedLessonCount())
						let checkCompletedLessonStatus:Double = totalCompleted/5
						if (checkCompletedLessonStatus - checkCompletedLessonStatus.rounded(.down)) == 0 && checkCompletedLessonStatus > 0.0  {
							studentData.updateWizardMode(wizardMode: .explore)
						}
						withAnimation {
							showLessonView = false
						}
						
					}
					.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 8))
				Menu {
					lessonViewMenuContent()
				} label: {
					HStack {
						Spacer()
						Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title))
							.font(verticalSize == .regular ? .title2 : .title3)
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.bold()
							.truncationMode(.tail)
						if isCurrentLessonCompleted {
							Label("Completed", systemImage: "checkmark.circle.fill")
								.labelStyle(.iconOnly)
								.foregroundColor(Color("Dynamic/MainGreen"))
								.font(verticalSize == .regular ? .title2 : .title3)
						}
						Spacer()
						Label("lesson menu", systemImage: "list.bullet.circle")
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.labelStyle(.iconOnly)
							.font(verticalSize == .regular ? .title2 : .title3)
							.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 15))
					}
				}
			}
			.frame(maxHeight: 44)
			
			if verticalSize == .regular {
				//::LESSON VIDEO::
				/*ZStack {
					if revealAVPlayer {
						if scorewindData.currentLesson.videoMP4.isEmpty == false {
							VideoPlayer(player: viewModel.videoPlayer)
								.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
								.modifier(videoFrameModifier(splitView: splitScreen))
								.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
								.padding([.leading, .trailing], 15)
								.overlay(content: {
									if showVideoLoader {
										VStack {
											ZStack {
												videoLoader(frameSize: getVideoFrame().width*0.3)
											}
										}
										.modifier(videoFrameModifier(splitView: splitScreen))
										.background {
											RoundedRectangle(cornerRadius: 17)
												.foregroundColor(.black)
												.opacity(0.80)
										}
									}
								})
								.onAppear(perform: {
									//VideoPlayer onAppear when comeing from anohter tab view, not when the sheet disappears
									print("[debug] VideoPlayer onAppear")
								})
								.onDisappear(perform: {
									//VideoPlayer disappears when go to another tab view, not when sheet appears
									print("[debug] VideoPlayer onDisappear")
									print("[debug] lastPlaybackTime \(scorewindData.lastPlaybackTime)")
									if scorewindData.lastPlaybackTime >= 10 {
										print("[debug] VideoPlayer onDisappear, lastPlayBackTime>=10")
										studentData.updateWatchedLessons(courseID: scorewindData.currentCourse.id, lessonID: scorewindData.currentLesson.scorewindID, addWatched: true)
										studentData.updateMyCourses(allCourses: scorewindData.allCourses)
										studentData.updateMyCoursesDownloadStatus(allCourses: scorewindData.allCourses, downloadManager: downloadManager)
									}
									viewModel.videoPlayer!.pause()
								})
						}
					}
				}
				.modifier(videoFrameModifier(splitView: splitScreen))*/
				displayVideo()
				
				//::SCORE VIEWER::
				if scorewindData.currentTimestampRecs.count > 0 {
					/*LessonScoreView(viewModel: viewModel)
						.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						.overlay(content: {
							if showScoreZoomIcon {
								displayChangeNoteSize()
							}
						})
						.overlay(content: {
							if showScoreZoomIcon == false && showVideoLoader {
								VStack {
									Spacer()
									HStack {
										Spacer()
										Text("Tap the bar to listen!")
											.font(.headline)
											.foregroundColor(Color("Dynamic/LightGray"))
											.multilineTextAlignment(.center)
											.padding(EdgeInsets(top: 30, leading: 15, bottom: 30, trailing: 15))
											.background(
												RoundedRectangle(cornerRadius: CGFloat(17))
													.foregroundColor(Color("Dynamic/MainBrown+6"))
													.opacity(0.8)
											)
										Spacer()
									}
									Spacer()
								}
								.background(
									RoundedRectangle(cornerRadius: CGFloat(17))
										.foregroundColor(Color("Dynamic/MainBrown"))
										.opacity(0.7)
								)
								.opacity(showVideoLoader ? 1 : 0)
								.disabled(showVideoLoader ? false : true)
							}
						})
						.padding([.leading, .trailing], 15)*/
					displayScoreViewer()
				} else {
					Spacer()
				}
			} else {
				HStack(spacing:0) {
					displayVideo()
					if scorewindData.currentTimestampRecs.count > 0 {
						displayScoreViewer()
					}
				}
			}
			
		}
		/*.alert("Subscription is required", isPresented: $showStoreView) {
			Button("OK", role: .cancel) { }
		}*/
		.background(colorScheme == .light ? appBackgroundImage(colorMode: colorScheme) : appBackgroundImage(colorMode: colorScheme))
		.onAppear(perform: {
			//:LesssonView onAppear will not be triggered after sheet goes away.
			//:LessonView onAppear will be triggered when switching tab/full screen mode.
			print("[debug] LessonView onAppear")
			if scorewindData.lessonChanged {
				//scorewindData.showLessonTextOverlay = true
				scorewindData.lessonChanged = false
			}
			
			viewModel.loadToGo = true
			if scorewindData.currentView != Page.lessonFullScreen {
				scorewindData.currentView = Page.lesson
			}
			
			if scorewindData.currentTimestampRecs.count > 0 {
				splitScreen = true
			} else {
				splitScreen = false
			}
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
				if scorewindData.currentLesson.videoMP4.isEmpty == false {
					withAnimation {
						revealAVPlayer = true
					}
					viewModel.viewedLesson = scorewindData.currentLesson
					viewModel.viewedTimestampRecs = scorewindData.currentTimestampRecs
					setupPlayer()
					if scorewindData.lastPlaybackTime > 0.0 {
						viewModel.playerGoTo(timestamp: scorewindData.lastPlaybackTime)
					} else {
						viewModel.playerGoTo(timestamp: 0.0)
					}
					
					
				}
			}
			checkCurrentLessonCompleted()
			//setNextLesson()
			//setPreviousLesson()
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				handleTip()
				if showLessonViewTip && scorewindData.currentLesson.videoMP4.isEmpty == false {
					viewModel.videoPlayer?.pause()
				}
			}
			userDefaults.set(scorewindData.currentLesson.id,forKey: "lastViewedLesson")
			print("[debug] LessonView onAppear,showLessonSheet \(scorewindData.showLessonTextOverlay)")
			
			if scorewindData.isPublicUserVersion {
				studentData.updateLogs(title: .viewLesson, content: viewLessonLogContent())
				/*studentData.updateUsageActionCount(actionName: .viewLesson)
				if scorewindData.currentTimestampRecs.count == 0 {
					studentData.updateUsageActionCount(actionName: .lessonNoScore)
				} else {
					studentData.updateUsageActionCount(actionName: .lessonHasScore)
				}*/
			}
		})
		.onDisappear(perform: {
			print("[debug] LessonView onDisappear")
			viewModel.videoPlayer!.pause()
			viewModel.videoPlayer!.replaceCurrentItem(with: nil)
			showScoreZoomIcon = false
		})
		.sheet(isPresented: $scorewindData.showLessonTextOverlay, content: {
				LessonTextView(studentData: studentData, isCurrentLessonCompleted: $isCurrentLessonCompleted)
			})
		.sheet(isPresented: $showStoreView, content: {
				StoreView(showStore: $showStoreView, studentData: studentData)
			})
		.fullScreenCover(isPresented: $showLessonViewTip, onDismiss:{
			if scorewindData.currentLesson.videoMP4.isEmpty == false {
				viewModel.videoPlayer?.play()
			}}, content: {
				TipTransparentModalView(showStepTip: $showLessonViewTip, tipContent: $tipContent)
			})
		.onChange(of: verticalSize, perform: {info in
			print("[debug] LessonView, setupPlayer, track verticalSize is changed")
			showVideoLoader = false
			if scorewindData.currentLesson.videoMP4.isEmpty == false {
				viewModel.videoPlayer!.pause()
				viewModel.videoPlayer!.replaceCurrentItem(with: nil)
				
				viewModel.viewedLesson = scorewindData.currentLesson
				viewModel.viewedTimestampRecs = scorewindData.currentTimestampRecs
				
				viewModel.loadToGo = true
				setupPlayer()
				if scorewindData.lastPlaybackTime > 0 {
					viewModel.playerGoTo(timestamp: scorewindData.lastPlaybackTime)
				} else {
					viewModel.playerGoTo(timestamp: 0.0)
				}
			}
		})
	}
	
	@ViewBuilder
	private func displayVideo() -> some View {
		ZStack {
			if revealAVPlayer {
				if scorewindData.currentLesson.videoMP4.isEmpty == false {
					VideoPlayer(player: viewModel.videoPlayer)
						.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
						.modifier(videoFrameModifier(splitView: splitScreen))
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						.padding([.leading, .trailing], 15)
						.overlay(content: {
							if showVideoLoader {
								VStack {
									ZStack {
										videoLoader(frameSize: getVideoFrame().width*0.3)
									}
								}
								.modifier(videoFrameModifier(splitView: splitScreen))
								.background {
									RoundedRectangle(cornerRadius: 17)
										.foregroundColor(.black)
										.opacity(0.80)
								}
							}
						})
						.onAppear(perform: {
							//VideoPlayer onAppear when comeing from anohter tab view, not when the sheet disappears
							print("[debug] VideoPlayer onAppear")
							studentData.logVideoPlaybackTime = []
							lastUserUsageTimerCount = studentData.userUsageTimerCount
						})
						.onDisappear(perform: {
							//VideoPlayer disappears when go to another tab view, not when sheet appears
							print("[debug] VideoPlayer onDisappear")
							print("[debug] lastPlaybackTime \(scorewindData.lastPlaybackTime)")
							if scorewindData.lastPlaybackTime >= 10 {
								print("[debug] VideoPlayer onDisappear, lastPlayBackTime>=10")
								studentData.updateWatchedLessons(courseID: scorewindData.currentCourse.id, lessonID: scorewindData.currentLesson.scorewindID, addWatched: true)
								studentData.updateMyCourses(allCourses: scorewindData.allCourses)
								studentData.updateMyCoursesDownloadStatus(allCourses: scorewindData.allCourses, downloadManager: downloadManager)
							}
							
							if scorewindData.isPublicUserVersion && (studentData.logVideoPlaybackTime.count > 0) {
								studentData.updateLogs(title: .streamLessonVideo, content: "\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title)) (\(studentData.logVideoPlaybackTime.joined(separator: "->")))view changed")
								studentData.logVideoPlaybackTime = []
							}
						})
				}
			}
		}
		.modifier(videoFrameModifier(splitView: splitScreen))
	}
	
	@ViewBuilder
	private func displayScoreViewer() -> some View {
		LessonScoreView(viewModel: viewModel)
			.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
			.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
			.overlay(content: {
				if showScoreZoomIcon {
					displayChangeNoteSize()
				}
			})
			.overlay(content: {
				if showScoreZoomIcon == false && showVideoLoader {
					VStack {
						Spacer()
						HStack {
							Spacer()
							Text("Tap the bar to listen!")
								.font(.headline)
								.foregroundColor(Color("Dynamic/LightGray"))
								.multilineTextAlignment(.center)
								.padding(EdgeInsets(top: 30, leading: 15, bottom: 30, trailing: 15))
								.background(
									RoundedRectangle(cornerRadius: CGFloat(17))
										.foregroundColor(Color("Dynamic/MainBrown+6"))
										.opacity(0.8)
								)
							Spacer()
						}
						Spacer()
					}
					.background(
						RoundedRectangle(cornerRadius: CGFloat(17))
							.foregroundColor(Color("Dynamic/MainBrown"))
							.opacity(0.7)
					)
					.opacity(showVideoLoader ? 1 : 0)
					.disabled(showVideoLoader ? false : true)
				}
			})
			.padding([.leading, .trailing], 15)
	}
	
	private func decodeVideoURL(videoURL:String)->String{
		let decodedURL = videoURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
		return decodedURL
	}
	
	private func createTimeString(time: Float) -> String {
		let timeRemainingFormatter: DateComponentsFormatter = {
			let formatter = DateComponentsFormatter()
			formatter.zeroFormattingBehavior = .pad
			formatter.allowedUnits = [.minute, .second]
			return formatter
		}()
		
		let components = NSDateComponents()
		components.second = Int(max(0.0, time))
		return timeRemainingFormatter.string(from: components as DateComponents)!
	}
	
	private func findMesaureByTimestamp(videoTime: Double)->Int{
		var getMeasure = 0
		for(index, theTime) in scorewindData.currentTimestampRecs.enumerated(){
			//print("index "+String(index))
			//print("timestamp "+String(theTime.measure))
			var endTimestamp = theTime.timestamp + 100
			if index < scorewindData.currentTimestampRecs.count-1 {
				endTimestamp = scorewindData.currentTimestampRecs[index+1].timestamp
			}
			print("[debug] LessonViw,--findMeasureByTimestamp-->")
			print("[debug] LessonViw,loop timestamp "+String(theTime.timestamp))
			print("[debug] LessonViw,endTimestamp "+String(endTimestamp))
			print("[debug] LessonViw,<-------------------------")
			if videoTime >= theTime.timestamp && videoTime < Double(endTimestamp) {
				getMeasure = index//theTime.measure
				break
			}
		}
		
		return getMeasure
	}
	
	private func setupPlayer(){
		print("[debug] LessonView, setupPlayer, begin to setup")
		
		if !scorewindData.currentLesson.videoMP4.isEmpty {
			watchTime = ""
			let courseURL = URL(string: "course\(scorewindData.currentCourse.id)", relativeTo: downloadManager.docsUrl)!
			let mp4VideoURL = URL(string: scorewindData.currentLesson.videoMP4.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
			print("[debug] LessonView, setupPlayer, destVideoURL:\(courseURL.appendingPathComponent(mp4VideoURL.lastPathComponent).path)")
			if FileManager.default.fileExists(atPath: courseURL.appendingPathComponent(mp4VideoURL.lastPathComponent).path) {
				print("[debug] LessonView, setupPlayer, play \(courseURL.appendingPathComponent(mp4VideoURL.lastPathComponent).path)")
				viewModel.videoPlayer = AVPlayer(url: courseURL.appendingPathComponent(mp4VideoURL.lastPathComponent))
			} else {
				print("[debug] LessonView, setupPlayer, play \(decodeVideoURL(videoURL: scorewindData.currentLesson.video))")
				viewModel.videoPlayer = AVPlayer(url: URL(string: decodeVideoURL(videoURL: scorewindData.currentLesson.video))!)
			}
			
			viewModel.videoPlayer!.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 3), queue: .main, using: { time in
				let catchTime = time.seconds
				
				print("[debug] LessonView, setupPlayer, catchTime:"+String(catchTime))
				print("[debug] LessonView, setupPlayer, lastPlaybackTime:"+String(scorewindData.lastPlaybackTime))
				
				print("[debug] LessonView, setupPlayer, track student.timerCount/self.timerCount:\(studentData.userUsageTimerCount):\(lastUserUsageTimerCount)")
				if (studentData.userUsageTimerCount - lastUserUsageTimerCount) > 1 {
					studentData.logVideoPlaybackTime.append(String(format: "%.3f", Float(catchTime)))
					lastUserUsageTimerCount = studentData.userUsageTimerCount
					print("[debug] LessonView, setupPlayer, logVideoPlaybackTime \(studentData.logVideoPlaybackTime)")
				} else {
					if studentData.userUsageTimerCount <= 1 {
						lastUserUsageTimerCount = studentData.userUsageTimerCount
					}
				}
				if scorewindData.isPublicUserVersion {
					if studentData.logVideoPlaybackTime.count >= 4 || (studentData.userUsageTimerCount>=60 && studentData.logVideoPlaybackTime.count>0) {
						//:: log the playback time either when finishing collecting 10 items or wait for the timeer count hits 60(user now may be pausing the video so this timer in PeriodicTimerObserver is on hold)
						studentData.updateLogs(title: .streamLessonVideo, content: "\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title)) (\(studentData.logVideoPlaybackTime.joined(separator: "->")))continue")
						studentData.logVideoPlaybackTime = []
					}
				}
				
				if showVideoLoader {
					if scorewindData.lastPlaybackTime > 0.01 && catchTime > scorewindData.lastPlaybackTime {
						showVideoLoader = false
					}
				}
				
				scorewindData.lastPlaybackTime = catchTime
				
				if scorewindData.currentTimestampRecs.count > 0 {
					let atMeasure = findMesaureByTimestamp(videoTime: catchTime)
					self.viewModel.valuePublisher.send(String(atMeasure))
					//print("[debug] LessonView, setupPlayer, ready to play")
					print("[debug] LessonView, setupPlayer, find measure:"+String(atMeasure))
				}
				
				
				//self.viewModel.highlightBar = atMeasure
				watchTime = String(format: "%.3f", Float(catchTime))//createTimeString(time: Float(time.seconds))
				
			})
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			withAnimation {
				self.showVideoLoader = true
			}
		}
		
	}
	
	private func switchLesson() {
		//when switch lesson with menu, onAppear is not triggered.
		//prepare for the lesson content change here.
		//magnifyStep = 1
		
		viewModel.loadToGo = true
		//withAnimation {
		//scorewindData.showLessonTextOverlay = true
		//}
		scorewindData.setCurrentTimestampRecs()
		scorewindData.lastPlaybackTime = 0.0
		
		if scorewindData.currentTimestampRecs.count > 0 {
			splitScreen = true
		} else {
			splitScreen = false
		}
		
		if scorewindData.currentLesson.videoMP4.isEmpty == false {
			viewModel.videoPlayer?.pause()
			//viewModel.videoPlayer?.replaceCurrentItem(with: nil)
			viewModel.viewedLesson = scorewindData.currentLesson
			viewModel.viewedTimestampRecs = scorewindData.currentTimestampRecs
			setupPlayer()
		}
		scorewindData.lessonChanged = true
		checkCurrentLessonCompleted()
		setPreviousLesson()
		setNextLesson()
	}
	
	@ViewBuilder
	private func lessonViewMenuContent() -> some View {
		//show lesson text in sheet
		if scorewindData.currentLesson.content.isEmpty == false {
			Button(action: {
				//showLessonSheet = true
				if scorewindData.currentLesson.videoMP4.isEmpty == false {
					viewModel.videoPlayer!.pause()
				}
				scorewindData.showLessonTextOverlay = true
			}){
				Label("About the Lesson", systemImage: "doc.plaintext")
					.labelStyle(.titleAndIcon)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
			}
		}
		
		Button(action: {
			if store.enablePurchase || store.couponState != .valid {
				if scorewindData.currentLesson.videoMP4.isEmpty == false {
					viewModel.videoPlayer!.pause()
				}
				showStoreView = true
			} else {
				if isCurrentLessonCompleted {
					studentData.updateCompletedLesson(courseID: scorewindData.currentCourse.id, lessonID: scorewindData.currentLesson.scorewindID, isCompleted: false)
				} else{
					studentData.updateCompletedLesson(courseID: scorewindData.currentCourse.id, lessonID: scorewindData.currentLesson.scorewindID, isCompleted: true)
				}
				
				studentData.updateMyCourses(allCourses: scorewindData.allCourses)
				studentData.updateMyCoursesDownloadStatus(allCourses: scorewindData.allCourses, downloadManager: downloadManager)
				
				checkCurrentLessonCompleted()
			}
		}){
			if isCurrentLessonCompleted {
				Label("Undo Finished", systemImage: "checkmark.circle.fill")
					.labelStyle(.titleAndIcon)
					.foregroundColor(Color("Dynamic/IconHighlighted"))
			} else {
				Label("I Finished It", systemImage: "checkmark.circle")
					.labelStyle(.titleAndIcon)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
			}
		}
		
		/*
		 if previousLesson.id > 0 {
		 Button(action: {
		 scorewindData.currentLesson = previousLesson
		 switchLesson()
		 }){
		 Label("Previous lesson", systemImage: "arrow.backward.circle")
		 .labelStyle(.titleAndIcon)
		 }
		 }
		 
		 if nextLesson.id > 0 {
		 Button(action: {
		 scorewindData.currentLesson = nextLesson
		 switchLesson()
		 }){
		 Label("Next lesson", systemImage: "arrow.forward.circle")
		 .labelStyle(.titleAndIcon)
		 }
		 }
		 */
		
		if scorewindData.currentTimestampRecs.count > 0 {
			Button(action: {
				withAnimation {
					showScoreZoomIcon = true
				}
			}){
				Label("Change Note Size", systemImage: "music.note")
					.labelStyle(.titleAndIcon)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
			}
		}
	}
	
	private func setNextLesson() {
		let lessonArray = scorewindData.currentCourse.lessons
		let getCurrentIndex = lessonArray.firstIndex(where: {$0.id == scorewindData.currentLesson.id}) ?? -1
		print("[debug] LessonView, setNextLesson, getCurrentIndex \(getCurrentIndex)")
		if (getCurrentIndex < (lessonArray.count-1)) && (getCurrentIndex > -1) {
			nextLesson = scorewindData.currentCourse.lessons[getCurrentIndex+1]
		}else{
			nextLesson = Lesson()
		}
	}
	
	private func setPreviousLesson() {
		let lessonArray = scorewindData.currentCourse.lessons
		let getCurrentIndex = lessonArray.firstIndex(where: {$0.id == scorewindData.currentLesson.id}) ?? -1
		print("[debug] LessonView, setPreviousLesson, getCurrentIndex \(getCurrentIndex)")
		if getCurrentIndex > 0 {
			previousLesson = scorewindData.currentCourse.lessons[getCurrentIndex-1]
		}else{
			previousLesson = Lesson()
		}
	}
	
	private func checkCurrentLessonCompleted() {
		print("[debug] LessonView, isLessonCompleted")
		let getCompletedLesson = studentData.getCompletedLessons(courseID: scorewindData.currentCourse.id)
		if getCompletedLesson.contains(scorewindData.currentLesson.scorewindID) {
			isCurrentLessonCompleted = true
		} else{
			isCurrentLessonCompleted = false
		}
	}
	
	private func compareLessonDescription() -> Bool{
		let lessonTextWithoutTags = scorewindData.currentLesson.content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
		if lessonTextWithoutTags.caseInsensitiveCompare(scorewindData.currentLesson.description) == .orderedSame{
			return true
		} else {
			return false
		}
	}
	
	private func getVideoFrame() -> VideoFrame {
		if verticalSize == .regular {
			return VideoFrame(width: UIScreen.main.bounds.width-30, height: (UIScreen.main.bounds.width-30) * 9/16)
		} else {
			return VideoFrame(width: UIScreen.main.bounds.height*0.65 * 16/9, height: UIScreen.main.bounds.height*0.65)
		}
	}
	
	struct videoFrameModifier : ViewModifier {
		var splitView : Bool
		@Environment(\.verticalSizeClass) var verticalSize
		
		@ViewBuilder func body(content: Content) -> some View {
			if splitView {
				content
					.frame(width: getVideoFrame().width, height: getVideoFrame().height)
			} else {
				content
			}
		}
		
		private func getVideoFrame() -> VideoFrame {
			if verticalSize == .regular {
				return VideoFrame(width: UIScreen.main.bounds.width-30, height: (UIScreen.main.bounds.width-30) * 9/16)
			} else {
				return VideoFrame(width: UIScreen.main.bounds.height*0.65 * 16/9, height: UIScreen.main.bounds.height*0.65)
			}
		}
		
		
	}
	
	struct VideoFrame {
		var width:CGFloat
		var height:CGFloat
	}
	
	private func handleTip() {
		let hideTips:[String] = userDefaults.object(forKey: "hideTips") as? [String] ?? []
		if hideTips.contains(Tip.lessonView.rawValue) == false {
			tipContent = AnyView(TipContentMakerView(showStepTip: $showLessonViewTip, hideTipValue: Tip.lessonView.rawValue, tipMainContent: AnyView(tipHere())))
			showLessonViewTip = true
			tipVideo.play()
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
				ScrollView {
					VStack(alignment: .leading) {
						VStack(spacing: 0) {
							HStack {
								Spacer()
								Label(title: {Text("Lesson")}, icon: {
									Image(scorewindData.currentCourse.instrument)
										.resizable()
										.scaledToFit()
										.rotationEffect(Angle(degrees: 45))
										.frame(maxHeight: 80)
								})
								.labelStyle(.iconOnly)
								.padding(.bottom, 5)
								/*Label("Lesson", systemImage: "headphones")
									.labelStyle(.iconOnly)
									.font(.title)
									.padding(.bottom, 5)*/
								Spacer()
							}
							HStack {
								Spacer()
								Text("The Lesson")
								.font(.headline)
								.padding(.bottom, 15)
								.multilineTextAlignment(.center)
								.shadow(color:.white,radius: 15)
								Spacer()
							}
						}
						/*.background(alignment: .topLeading, content:{
							Image("animal_play_\(studentData.getInstrumentChoice())")
								.resizable()
								.scaledToFit()
								.padding(.leading, -30)
						})*/
						Group {
							Divider().padding(.bottom, 20)
							VStack(alignment: .center) {
								HStack {
									Spacer()
									if scorewindData.currentTimestampRecs.count == 0 {
										Text("Lesson is About to Start").font(.title2).bold()
									} else{
										Text("Watch and Practice").font(.title2).bold()
									}
									
									Spacer()
								}.padding([.bottom],15)
								
								if scorewindData.currentTimestampRecs.count == 0 {
									Text("Use the Headset")
										.font(.headline)
									if scorewindData.currentCourse.instrument == InstrumentType.guitar.rawValue {
										VideoLoopView(videoURL:URL(fileURLWithPath: "Ricardo_Headset_UltraHD_720", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.6)
											.padding([.bottom], 15)
									} else {
										VideoLoopView(videoURL:URL(fileURLWithPath: "Esin_Headset_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.6)
											.padding([.bottom], 15)
									}
									
									Text("Find a position at eye level for yor device.")
										.font(.headline)
									VideoLoopView(videoURL:URL(fileURLWithPath: "DIY_Notestannd_HD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.6)
										.padding([.bottom], 15)
								} else {
									Text("Control the video playback by tapping the bar.")
										.font(.headline)
									VideoLoopView(videoURL:URL(fileURLWithPath: scorewindData.currentCourse.instrument == InstrumentType.guitar.rawValue ? "Ricardo_Notestand_TapA_UltraHD" : "Esin_Notestand_TapA_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.6)
										.padding([.bottom], 15)
									
									Text("Use the Headset")
										.font(.headline)
									if scorewindData.currentCourse.instrument == InstrumentType.guitar.rawValue {
										VideoLoopView(videoURL:URL(fileURLWithPath: "Ricardo_Headset_UltraHD_720", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.6)
											.padding([.bottom], 15)
									} else {
										VideoLoopView(videoURL:URL(fileURLWithPath: "Esin_Headset_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.6)
											.padding([.bottom], 15)
									}
								}
							}
						}
						
						Group {
							/*Divider().padding(.bottom, 20)
							Text("When the lesson has a musical score, don't forget to use your headphone to listen and play together with the teacher. \n\nLeave one of your ears open when you are playing.").padding(.bottom, 15)
							Text("It would be ideal for placing your phone at eye level while learning and playing.").padding(.bottom, 15)*/
							
							Divider().padding(.bottom, 20)
							HStack {
								Spacer()
								Text("While Learning").font(.title2).bold()
								Spacer()
							}.padding(.bottom, 15)
							(Text("Use features in the ")+Text(Image(systemName: "list.bullet.circle"))+Text(" lesson menu to improve your learning experience.")).padding(.bottom, 15)
							(Text("Click ")+Text(Image(systemName: "doc.plaintext"))+Text(" to learn what this lesson is about in detail.")).padding(.bottom, 8)
							(Text(Image(systemName: "checkmark.circle"))+Text(" Mark this lesson as completed to track your learning progress.")).padding(.bottom, 8)
							(Text("Click ")+Text(Image(systemName: "music.note"))+Text(" to change the note size in the score.")).padding(.bottom, 15)
							
							Divider().padding(.bottom, 20)
							(Text("At last, ")+Text(Image(systemName: "chevron.backward"))+Text(" will take you back to see the course. Enjoy!")).padding(.bottom, 15)
						}
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
			Text("This is the lesson.\nStart learning and play together with the teacher!")
				.font(.headline)
				.modifier(StepExplainingText())
			VStack(alignment:.leading) {
				Text("When score is availalbe in the lesson, you can \(Image(systemName: "hand.tap")) tap the bar to go to any position in the video.")
					.modifier(TipExplainingParagraph())
				Text("In the top right corner, \(Image(systemName: "list.bullet.circle")) is the menu where you can discover more things to do with this lesson.")
					.modifier(TipExplainingParagraph())
				Text("At last, \(Image(systemName: "chevron.backward")) will take you back to see the course. Enjoy!")
					.modifier(TipExplainingParagraph())
			}.padding([.bottom],18)
			
		}.background {
			RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("AppYellow"))
			.frame(width: UIScreen.main.bounds.width*0.9)}*/
	}
	
	@ViewBuilder
	private func displayChangeNoteSize() -> some View {
		VStack{
			Spacer()
			HStack {
				Image(systemName: "plus.magnifyingglass")
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.padding(20)
					.background(
						RoundedCornersShape(corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 17)
							.fill(Color("Dynamic/LightGray"))
							.opacity(0.85)
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					)
					.onTapGesture(perform: {
						viewModel.zoomInPublisher.send("Zoom In")
					})
				Spacer()
				Image(systemName: "minus.magnifyingglass")
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.padding(20)
					.background(
						RoundedCornersShape(corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 17)
							.fill(Color("Dynamic/LightGray"))
							.opacity(0.85)
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					)
					.onTapGesture(perform: {
						viewModel.zoomInPublisher.send("Zoom Out")
					})
				Spacer()
				Image(systemName: "xmark.circle")
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.padding(20)
					.background(
						RoundedCornersShape(corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 17)
							.fill(Color("Dynamic/LightGray"))
							.opacity(0.85)
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					)
					.onTapGesture(perform: {
						withAnimation {
							showScoreZoomIcon = false
						}
					})
			}
			.padding(15)
		}
		.padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
	}
	
	private func viewLessonLogContent() -> String {
		var logContent = scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title)
		logContent = "\(logContent), \(scorewindData.currentTimestampRecs.count) timestamps"
		return logContent
	}
	
}

struct LessonView2_Previews: PreviewProvider {
	@State static var tab = "TLesson"
	@StateObject static var scorewindData = ScorewindData()
	@StateObject static var store = Store()
	static var previews: some View {
		LessonView2(selectedTab: $tab, downloadManager: DownloadManager(), studentData: StudentData(), showLessonView: .constant(true))
			.environmentObject(scorewindData)
			.environmentObject(store)
	}
}

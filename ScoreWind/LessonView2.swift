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
	@State private var showSubscriberOnlyAlert = false
	@Environment(\.verticalSizeClass) var verticalSize
	@Environment(\.colorScheme) var colorScheme
	@State private var revealAVPlayer = false
	@State private var showVideoLoader = false
	
	var body: some View {
		VStack {
			HStack {
				Label("Back to course", systemImage: "chevron.backward")
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.labelStyle(.iconOnly)
					.font(verticalSize == .regular ? .title2 : .title3)
					.onTapGesture {
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
			
			//::LESSON VIDEO::
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
			.modifier(videoFrameModifier(splitView: splitScreen))
			
			//::SCORE VIEWER::
			if scorewindData.currentTimestampRecs.count > 0 {
				LessonScoreView(viewModel: viewModel)
					.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					.overlay(content: {
						if showScoreZoomIcon {
							displayChangeNoteSize()
						}
					})
					.padding([.leading, .trailing], 15)
			} else {
				Spacer()
			}
		}
		.alert("Subscription is required", isPresented: $showSubscriberOnlyAlert) {
			Button("OK", role: .cancel) { }
		}
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
						if scorewindData.showLessonTextOverlay {
							viewModel.playerSeek(timestamp: scorewindData.lastPlaybackTime)
						} else {
							viewModel.playerGoTo(timestamp: scorewindData.lastPlaybackTime)
						}
					} else {
						if scorewindData.showLessonTextOverlay {
							viewModel.playerSeek(timestamp: 0.0)
						} else {
							viewModel.playerGoTo(timestamp: 0.0)
						}
					}
					withAnimation {
						self.showVideoLoader = true
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
		})
		.onDisappear(perform: {
			print("[debug] LessonView onDisappear")
			showScoreZoomIcon = false
		})
		.sheet(isPresented: $scorewindData.showLessonTextOverlay, onDismiss: {
			if scorewindData.currentLesson.videoMP4.isEmpty == false {
				viewModel.videoPlayer?.play()
			}
		}, content: {
			/*VStack {
				HStack {
					Spacer()
					Text("About")
						.fontWeight(.bold)
						.foregroundColor(Color("AppYellow"))
					Spacer()
				}
				.padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
				.background(Color("LessonTextOverlay"))
				.overlay(Label("Continue", systemImage: "xmark.circle.fill")
								 //.font(.title3)
					.labelStyle(.titleOnly)
					.foregroundColor(scorewindData.currentTimestampRecs.count>0 ? Color("LessonPlayLearnContinue") : Color("LessonWatchLearnContinue"))
					.padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
					.onTapGesture {
						scorewindData.showLessonTextOverlay = false
					}, alignment: .trailing)
				HStack(alignment: .firstTextBaseline) {
					Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title))
						.font(.title)
						.foregroundColor(Color("AppYellow"))
					Spacer()
				}
				.padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
				
				ScrollView {
					VStack {
						HStack{
							if isCurrentLessonCompleted {
								Label("Completed", systemImage: "checkmark.circle.fill")
									.labelStyle(.iconOnly)
									.foregroundColor(Color("LessonSheet"))
									.padding(1)
									.background {
										Circle()
											.foregroundColor(Color("BadgeCompleted"))
									}
									.fixedSize()
								
								Label("Completed", systemImage: "checkmark.circle.fill")
									.labelStyle(.titleOnly)
									.foregroundColor(Color("AppYellow"))
									.padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 15))
									.fixedSize()
							}
							if studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id).contains(scorewindData.currentLesson.scorewindID) {
								Label("Video watched", systemImage: "eye.circle.fill")
									.labelStyle(.iconOnly)
									.foregroundColor(Color("LessonSheet"))
									.padding(1)
									.background {
										Circle()
											.foregroundColor(Color("LessonTitileHeighlight"))
									}
									.fixedSize()
								Label("Video watched", systemImage: "eye.circle.fill")
									.labelStyle(.titleOnly)
									.foregroundColor(Color("AppYellow"))
									.padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 15))
									.fixedSize()
							}
							Spacer()
						}
						HStack {
							Text("\(scorewindData.courseContentNoHtml(content: scorewindData.currentLesson.content))")
								.foregroundColor(Color("LessonSheet"))
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
				.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
			}.background(Color("LessonTextOverlay"))*/
			LessonTextView(studentData: studentData, isCurrentLessonCompleted: $isCurrentLessonCompleted)
		})
		.fullScreenCover(isPresented: $showLessonViewTip, onDismiss:{
			if scorewindData.currentLesson.videoMP4.isEmpty == false {
				viewModel.videoPlayer?.play()
			}
		}, content: {
			TipTransparentModalView(showStepTip: $showLessonViewTip, tipContent: $tipContent)
		})
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
		showVideoLoader = true
		
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
				
				print("catchTime:"+String(catchTime))
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
					print("find measure:"+String(atMeasure))
				}
				
				
				//self.viewModel.highlightBar = atMeasure
				watchTime = String(format: "%.3f", Float(catchTime))//createTimeString(time: Float(time.seconds))
				
			})
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
				scorewindData.showLessonTextOverlay = true
			}){
				Label("About the Lesson", systemImage: "info.circle")
					.labelStyle(.titleAndIcon)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
			}
		}
		
		Button(action: {
			if store.purchasedSubscriptions.isEmpty {
				showSubscriberOnlyAlert = true
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
			return VideoFrame(width: UIScreen.main.bounds.height*0.55 * 16/9, height: UIScreen.main.bounds.height*0.55)
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
				return VideoFrame(width: UIScreen.main.bounds.height*0.55 * 16/9, height: UIScreen.main.bounds.height*0.55)
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
		}
	}
	
	@ViewBuilder
	private func tipHere() -> some View {
		VStack {
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
			.frame(width: UIScreen.main.bounds.width*0.9)}
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

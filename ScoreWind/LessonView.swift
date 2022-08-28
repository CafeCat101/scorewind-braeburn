//
//  LessonView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI
import AVKit

struct LessonView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	//@State private var showLessonSheet = false
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var watchTime = ""
	@StateObject var viewModel = ViewModel()
	@State private var startPos:CGPoint = .zero
	@State private var isSwipping = true
	//@GestureState var magnifyBy = 1.0
	//@State private var magnifyStep = 1
	@ObservedObject var downloadManager:DownloadManager
	@Binding var showTip:Bool
	@State private var nextLesson = Lesson()
	@State private var previousLesson = Lesson()
	@State private var isCurrentLessonCompleted = false
	@State private var splitScreen = true
	//@State private var test = false
	
	var body: some View {
		VStack {
			if scorewindData.currentView == Page.lesson {
				HStack {
					Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title))
						.font(.title3)
						.foregroundColor(.black)
						.truncationMode(.tail)
					Spacer()
					lessonViewMenu()
				}
				.frame(height: screenSize.height/25)
				.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 15))
			}
			
			if scorewindData.currentLesson.videoMP4.isEmpty == false {
				VideoPlayer(player: viewModel.videoPlayer)
				//.frame(height: scorewindData.currentTimestampRecs.count > 0 ? screenSize.height*0.35 : screenSize.height)
					.modifier(videoFrameModifier(splitView: splitScreen, screenHeight: screenSize.height))
					.onAppear(perform: {
						//VideoPlayer onAppear when comeing from anohter tab view, not when the sheet disappears
						print("[debug] VideoPlayer onAppear")
					})
					.onDisappear(perform: {
						//VideoPlayer disappears when go to another tab view, not when sheet appears
						print("[debug] VideoPlayer onDisappear")
						if scorewindData.lastPlaybackTime >= 0.10 {
							print("[debug] VideoPlayer onDisappear, lastPlayBackTime>=0.10")
							scorewindData.studentData.updateWatchedLessons(courseID: scorewindData.currentCourse.id, lessonID: scorewindData.currentLesson.scorewindID, addWatched: true)
						}
						viewModel.videoPlayer!.pause()
						//viewModel.videoPlayer!.replaceCurrentItem(with: nil)
					})
					.background(.black)
					.overlay(lessonViewMenu().opacity(scorewindData.currentView==Page.lessonFullScreen ? 1:0.0).disabled(scorewindData.currentView==Page.lessonFullScreen ? false:true), alignment: .topLeading)
			}
			
			if scorewindData.currentTimestampRecs.count > 0 {
				LessonScoreView(viewModel: viewModel)
				
					.contextMenu {
						Button(action: {
							viewModel.zoomInPublisher.send("Zoom In")
						}){
							Label("Zoom in", systemImage: "minus.magnifyingglass")
								.labelStyle(.titleAndIcon)
						}
						Button(action: {
							viewModel.zoomInPublisher.send("Zoom Out")
						}){
							Label("Zoom out", systemImage: "plus.magnifyingglass")
								.labelStyle(.titleAndIcon)
						}
					}
				 
			} else {
				Spacer()
			}
			
		}
		.onAppear(perform: {
			//:LesssonView onAppear will not be triggered after sheet goes away.
			//:LessonView onAppear will be triggered when switching tab/full screen mode.
			print("[debug] LessonView onAppear")
			viewModel.loadToGo = true
			/*withAnimation {
				test = true
			}*/
			if scorewindData.currentView != Page.lessonFullScreen {
				scorewindData.currentView = Page.lesson
				//scorewindData.lastViewAtScore = true
			}
			
			if scorewindData.currentTimestampRecs.count > 0 {
				splitScreen = true
			} else {
				splitScreen = false
			}
			
			if scorewindData.getTipCount(tipType: .lessonScoreViewer) < TipLimit.lessonScoreViewer.rawValue {
				scorewindData.currentTip = .lessonScoreViewer
				showTip = true
			}
			
			if scorewindData.currentLesson.videoMP4.isEmpty == false {
				setupPlayer()
				if scorewindData.lastPlaybackTime > 0.0 {
					print("[debug] LessonView, call viewModel.playerSeek")
					viewModel.playerSeek(timestamp: scorewindData.lastPlaybackTime)
				}
			}
			
			checkCurrentLessonCompleted()
			setNextLesson()
			setPreviousLesson()
			print("[debug] LessonView onAppear,showLessonSheet \(scorewindData.showLessonTextOverlay)")
		})
		.onDisappear(perform: {
			print("[debug] LessonView onDisappear")
		})
		.simultaneousGesture(
			DragGesture()
				.onChanged { gesture in
					if self.isSwipping {
						self.startPos = gesture.location
						self.isSwipping.toggle()
					}/* else {
						if scorewindData.showLessonTextOverlay && ( gesture.translation.width > 20 || gesture.translation.width < -20 ) {
							withAnimation {
								scorewindData.showLessonTextOverlay = false
							}
						}
					}*/
				}
				.onEnded { gesture in
					let xDist =  abs(gesture.location.x - self.startPos.x)
					let yDist =  abs(gesture.location.y - self.startPos.y)
					if self.startPos.y <  gesture.location.y && yDist > xDist {
						//down
					}
					else if self.startPos.y >  gesture.location.y && yDist > xDist {
						//up
					}
					else if self.startPos.x > gesture.location.x && yDist < xDist {
						//left
						if nextLesson.scorewindID > 0 {
							withAnimation{
								scorewindData.currentLesson = nextLesson
								switchLesson()
							}
						}
					}
					else if self.startPos.x < gesture.location.x && yDist < xDist {
						//right
						if previousLesson.scorewindID > 0 {
							withAnimation{
								scorewindData.currentLesson = previousLesson
								switchLesson()
							}
						}
					}
					self.isSwipping.toggle()
				}
		)
		.sheet(isPresented: $scorewindData.showLessonTextOverlay, content: {
			VStack {
				HStack {
					Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title))
						.font(.title)
						.foregroundColor(.black)
					Spacer()
				}
				.padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
				.background(.yellow)
				
				ScrollView {
					VStack {
						HStack {
							if isCurrentLessonCompleted {
								Label("Completed", systemImage: "checkmark.circle.fill")
									.labelStyle(.titleAndIcon)
									.foregroundColor(Color("LessonSheet"))
									.padding(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
									.background {
										RoundedRectangle(cornerRadius: 20)
											.foregroundColor(Color("BadgeCompleted"))
									}
									.fixedSize()
							}
							if scorewindData.studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id).contains(scorewindData.currentLesson.scorewindID) {
								Label("Video watched", systemImage: "eye.circle.fill")
									.labelStyle(.titleAndIcon)
									.foregroundColor(Color("LessonSheet"))
									.padding(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
									.background {
										RoundedRectangle(cornerRadius: 20)
											.foregroundColor(Color("LessonTitileHeighlight"))
									}
									.fixedSize()
							}
							Spacer()
						}
						VStack {
							HStack {
								if scorewindData.currentTimestampRecs.count > 0 {
									Label("Play and learn", systemImage: "music.note.tv.fill")
										.labelStyle(.titleAndIcon)
										.foregroundColor(Color("LessonSheet"))
										.padding(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
										.background {
											RoundedRectangle(cornerRadius: 20)
												.foregroundColor(Color("BadgeScoreAvailable"))
										}
										.fixedSize()
								} else {
									Label("Watch and learn", systemImage: "video.bubble.left.fill")
										.labelStyle(.titleAndIcon)
										.foregroundColor(Color("LessonSheet"))
										.padding(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
										.background {
											RoundedRectangle(cornerRadius: 20)
												.foregroundColor(Color("BadgeWatchLearn"))
										}
										.fixedSize()
								}
								Spacer()
							}
						}
						Text("\(scorewindData.courseContentNoHtml(content: scorewindData.currentLesson.content))").foregroundColor(Color("LessonSheet"))
					}.padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))
				}
				.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
			}.background(Color("LessonTextOverlay"))
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
				scorewindData.lastPlaybackTime = catchTime
				
				if scorewindData.currentTimestampRecs.count > 0 {
					let atMeasure = findMesaureByTimestamp(videoTime: catchTime)
					self.viewModel.valuePublisher.send(String(atMeasure))
					print("[debug] LessonView, setupPlayer, ready to play")
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
			scorewindData.showLessonTextOverlay = true
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
			setupPlayer()
		}
		//showLessonSheet = true
		if (scorewindData.studentData.getWatchedLessons(courseID: scorewindData.currentCourse.id).contains(scorewindData.currentLesson.scorewindID) == false) && (scorewindData.studentData.getCompletedLessons(courseID: scorewindData.currentCourse.id).contains(scorewindData.currentLesson.scorewindID) == false) {
			scorewindData.showLessonTextOverlay = true
		}
		//scorewindData.lastViewAtScore = true
		checkCurrentLessonCompleted()
		setPreviousLesson()
		setNextLesson()
	}
	
	@ViewBuilder
	private func lessonViewMenu() -> some View {
		Menu {
			Button(action: {
				withAnimation {
					if scorewindData.currentView == Page.lesson {
						scorewindData.currentView = Page.lessonFullScreen
					} else {
						scorewindData.currentView = Page.lesson
					}
				}
			}){
				if scorewindData.currentView == Page.lesson {
					Label("Focus mode", systemImage: "lightbulb.circle")
						.labelStyle(.titleAndIcon)
				} else {
					Label("Explore mode", systemImage: "lightbulb.circle")
						.labelStyle(.titleAndIcon)
				}
			}
			
			Button(action: {
				if isCurrentLessonCompleted {
					scorewindData.studentData.updateCompletedLesson(courseID: scorewindData.currentCourse.id, lessonID: scorewindData.currentLesson.scorewindID, isCompleted: false)
				} else{
					scorewindData.studentData.updateCompletedLesson(courseID: scorewindData.currentCourse.id, lessonID: scorewindData.currentLesson.scorewindID, isCompleted: true)
				}
				checkCurrentLessonCompleted()
			}){
				if isCurrentLessonCompleted {
					Label("Undo completed", systemImage: "checkmark.circle.fill")
						.labelStyle(.titleAndIcon)
				} else {
					Label("Completed", systemImage: "checkmark.circle")
						.labelStyle(.titleAndIcon)
				}
			}
			
			if previousLesson.scorewindID > 0 {
				Button(action: {
					scorewindData.currentLesson = previousLesson
					switchLesson()
				}){
					Text("Previous: \(scorewindData.replaceCommonHTMLNumber(htmlString: previousLesson.title))")
				}
			}
			
			if nextLesson.scorewindID > 0 {
				Button(action: {
					scorewindData.currentLesson = nextLesson
					switchLesson()
				}){
					Text("Next: \(scorewindData.replaceCommonHTMLNumber(htmlString: nextLesson.title))")
				}
			}
		
			//show lesson text in sheet
			if scorewindData.currentLesson.content.isEmpty == false {
				Button(action: {
					//showLessonSheet = true
					scorewindData.showLessonTextOverlay = true
				}){
					Label("Show lesson text", systemImage: "doc.plaintext")
						.labelStyle(.titleAndIcon)
				}
			}
			
		} label: {
			Image(systemName: isCurrentLessonCompleted==false ? "list.bullet.circle":"text.badge.checkmark")
				.resizable()
				.scaledToFit()
				.frame(height: screenSize.height/25 - 4)
				.foregroundColor(scorewindData.currentView == Page.lesson ? .black:.white)
		}
	}
	
	private func setNextLesson() {
		let lessonArray = scorewindData.currentCourse.lessons
		let getCurrentIndex = lessonArray.firstIndex(where: {$0.scorewindID == scorewindData.currentLesson.scorewindID}) ?? -1
		print("[debug] LessonView, setNextLesson, getCurrentIndex \(getCurrentIndex)")
		if (getCurrentIndex < (lessonArray.count-1)) && (getCurrentIndex > -1) {
			nextLesson = scorewindData.currentCourse.lessons[getCurrentIndex+1]
		}else{
			nextLesson = Lesson()
		}
	}
	
	private func setPreviousLesson() {
		let lessonArray = scorewindData.currentCourse.lessons
		let getCurrentIndex = lessonArray.firstIndex(where: {$0.scorewindID == scorewindData.currentLesson.scorewindID}) ?? -1
		print("[debug] LessonView, setPreviousLesson, getCurrentIndex \(getCurrentIndex)")
		if getCurrentIndex > 0 {
			previousLesson = scorewindData.currentCourse.lessons[getCurrentIndex-1]
		}else{
			previousLesson = Lesson()
		}
	}
	
	private func checkCurrentLessonCompleted() {
		print("[debug] LessonView, isLessonCompleted")
		let getCompletedLesson = scorewindData.studentData.getCompletedLessons(courseID: scorewindData.currentCourse.id)
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
	
	struct videoFrameModifier : ViewModifier {
		var splitView : Bool
		var screenHeight: CGFloat
		
		@ViewBuilder func body(content: Content) -> some View {
			if splitView {
				content.frame(height: screenHeight*0.30)
			} else {
				content
			}
		}
	}
	
	struct BackgroundCleanerView: UIViewRepresentable {
		func makeUIView(context: Context) -> UIView {
			let view = UIView()
			DispatchQueue.main.async {
				view.superview?.superview?.backgroundColor = .clear
			}
			return view
		}
		
		func updateUIView(_ uiView: UIView, context: Context) {}
	}
	
}

struct LessonView_Previews: PreviewProvider {
	static var previews: some View {
		LessonView(downloadManager: DownloadManager(),showTip: .constant(false)).environmentObject(ScorewindData())
	}
}

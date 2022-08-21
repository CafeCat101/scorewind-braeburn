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
	
	var body: some View {
		/*ZStack {
			VStack {
				
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color.black)//.foregroundColor(Color.white)
			.opacity(0.6)
			.overlay(content: {
				RoundedRectangle(cornerRadius: 20)
					.foregroundColor(.yellow)
					.frame(width:300, height:300)
			})
		}
		.background(BackgroundCleanerView())
		.onAppear(perform: {
		})*/
		
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
					.frame(height: screenSize.height*0.35)
					.onAppear(perform: {
						//VideoPlayer onAppear when comeing from anohter tab view, not when the sheet disappears
						print("[debug] VideoPlayer onAppear")
					})
					.onDisappear(perform: {
						//VideoPlayer disappears when go to another tab view, not when sheet appears
						print("[debug] VideoPlayer onDisappear")
						if scorewindData.lastPlaybackTime >= 0.10 {
							scorewindData.studentData.updateWatchedLessons(courseID: scorewindData.currentCourse.id, lessonID: scorewindData.currentLesson.scorewindID, addWatched: true)
						}
						viewModel.videoPlayer!.pause()
						viewModel.videoPlayer!.replaceCurrentItem(with: nil)
					})
					.background(.black)
					.overlay(lessonViewMenu().opacity(scorewindData.currentView==Page.lessonFullScreen ? 1:0.0).disabled(scorewindData.currentView==Page.lessonFullScreen ? false:true), alignment: .topLeading)
			}
			
			if scorewindData.currentTimestampRecs.count > 0 {
				LessonScoreView(viewModel: viewModel)
					.overlay {
						if scorewindData.lastViewAtScore == false {
							HTMLString(htmlContent: scorewindData.currentLesson.content)
						}
					}
			} else {
				HTMLString(htmlContent: scorewindData.currentLesson.content)
			}
			Spacer()
		}
		.onAppear(perform: {
			print("[debug] LessonView onAppear")
			if scorewindData.currentView != Page.lessonFullScreen {
				scorewindData.currentView = Page.lesson
				scorewindData.lastViewAtScore = true
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
					}
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
			print("==>")
			print("loop timestamp "+String(theTime.timestamp))
			print("endTimestamp "+String(endTimestamp))
			print("<--")
			if videoTime >= theTime.timestamp && videoTime < Double(endTimestamp) {
				getMeasure = index//theTime.measure
				break
			}
		}
		
		return getMeasure
	}
	
	private func setupPlayer(){
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
		
		if scorewindData.currentLesson.videoMP4.isEmpty == false {
			viewModel.videoPlayer?.pause()
			viewModel.videoPlayer?.replaceCurrentItem(with: nil)
			setupPlayer()
		}
		
		scorewindData.lastViewAtScore = true
		checkCurrentLessonCompleted()
		setPreviousLesson()
		setNextLesson()
	}
	
	@ViewBuilder
	private func lessonViewMenu() -> some View {
		Menu {
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
			
			if scorewindData.currentTimestampRecs.count > 0 {
				//only need to zoom in/out score if score is available
				Menu {
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
				} label: {
					Text("Score")
				}
				
				//always show score first now. So just show/hide text when the score is
				//available
				Button(action: {
					withAnimation {
						scorewindData.lastViewAtScore.toggle()
					}
				}){
					if scorewindData.lastViewAtScore == false {
						Label("Hide lesson text", systemImage: "doc.plaintext")
							.labelStyle(.titleAndIcon)
					} else {
						Label("Show lesson text", systemImage: "doc.plaintext")
							.labelStyle(.titleAndIcon)
					}
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

//
//  WizardPlayable.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/10.
//

import SwiftUI
import AVKit

struct WizardPlayableView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	@Binding var showProgress: Bool
	@StateObject var viewModel = ViewModel()
	//let screenSize: CGRect = UIScreen.main.bounds
	@State private var rememberPlaybackTime:Double = 0.0
	@State private var showContentHint = false
	@State private var animate = false
	let feedbackImpact = UIImpactFeedbackGenerator(style: .heavy)
	@State private var animateVideo = true
	let transition = AnyTransition.asymmetric(insertion: .slide, removal: .scale).combined(with: .opacity)
	@Environment(\.verticalSizeClass) var verticalSize
	@State private var showScoreOverlay = true
	@State private var showVideoLoader = false
	
	@State private var feedbackItemMaxHeight:CGFloat = 60.0
	
	var body: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()
				Text("How do you feel about playing this?")
					.bold()
					.modifier(ViewTitleFont(videoOnly: studentData.playableViewVideoOnly))
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.multilineTextAlignment(.center)
					.onTapGesture(count:3, perform: {
						showContentHint.toggle()
					})
				Spacer()
				if verticalSize == .compact && studentData.playableViewVideoOnly == false {
					viewWithScoreMenu()
						.padding(.trailing, 15)
				}
			}
			
			Divider().frame(width:UIScreen.main.bounds.width*0.85)
			
			Spacer()
			
			VStack {
				if verticalSize == .regular {
					viewWithScoreMenu()
					.frame(width:UIScreen.main.bounds.width*0.85)
					
					displayVideo()
					/*
					VideoPlayer(player: viewModel.videoPlayer)
						.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
						.frame(width: animateVideo ? getVideoFrame().width : 0, height: getVideoFrame().height)
						.offset(x: animateVideo ? 0 : 0 - UIScreen.main.bounds.width*0.85)
						.opacity(animateVideo ? 1 : 0)
						.transition(AnyTransition.asymmetric(insertion: .slide, removal: .scale).combined(with: .opacity))
					 */
					
					if studentData.playableViewVideoOnly == false {
						GeometryReader { scoreSpaceReader in
							HStack(spacing: 0) {
								Spacer()
								LessonScoreView(viewModel: viewModel)
									.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
									.frame(width:UIScreen.main.bounds.width*0.85, height:scoreSpaceReader.size.height)
									.modifier(ScoreViewerOverlay(overlayWidth: UIScreen.main.bounds.width*0.85, overlayHeight: scoreSpaceReader.size.height, showScoreOverlay: $showScoreOverlay))
								Spacer()
							}
						}
					}

					if studentData.playableViewVideoOnly {
						Spacer()
					}
				} else {
					HStack {
						VStack(spacing: 0) {
							displayVideo()
							/*
							VideoPlayer(player: viewModel.videoPlayer)
								.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
								.frame(width: animateVideo ? getVideoFrame().width : 0, height: getVideoFrame().height)
								.offset(x: animateVideo ? 0 : 0 - UIScreen.main.bounds.width*0.85)
								.opacity(animateVideo ? 1 : 0)
								.transition(AnyTransition.asymmetric(insertion: .slide, removal: .scale).combined(with: .opacity))
							 */
						}
						
						if studentData.playableViewVideoOnly  {
							VStack {
								HStack {
									Spacer()
									viewWithScoreMenu()
										.padding(.trailing, 15)
								}
								GeometryReader { optionZSpace in
									displayOptionsZ(frameHeight: optionZSpace.size.height)
								}
							}
						} else {
							GeometryReader { scoreSpaceReader in
								VStack(spacing: 0) {
									HStack(spacing: 0) {
										Spacer()
										LessonScoreView(viewModel: viewModel)
											.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
											.frame(width:scoreSpaceReader.size.width, height:scoreSpaceReader.size.height-feedbackItemMaxHeight)
											.modifier(ScoreViewerOverlay(overlayWidth: scoreSpaceReader.size.width, overlayHeight: scoreSpaceReader.size.height-feedbackItemMaxHeight, showScoreOverlay: $showScoreOverlay))
										Spacer()
									}
									displayOptionsZ(frameHeight: feedbackItemMaxHeight)
								}
							}
						}
					}
				}
				
				if verticalSize == .regular {
					displayOptionsZ(frameHeight: feedbackItemMaxHeight+10)
				}

				if studentData.playableViewVideoOnly {
					Spacer()
				}
			}
			.onAppear(perform: {
				viewModel.loadToGo = false
				viewModel.viewedLesson = scorewindData.wizardPickedLesson
				viewModel.viewedTimestampRecs = scorewindData.wizardPickedTimestamps
				setupPlayer(withoutScoreViewer: studentData.playableViewVideoOnly)
				viewModel.playerGoTo(timestamp: findFirstPlayableTimestamp())
			})
			.onDisappear(perform: {
				viewModel.videoPlayer!.pause()
				viewModel.videoPlayer!.replaceCurrentItem(with: nil)
				studentData.playableViewVideoOnly = true
			})
			
			Spacer()
			
			if showContentHint {
				Text("lesson:\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedLesson.title))").font(.footnote)
			}
		}
		.onAppear(perform: {
			print("[debug] WizardPlayableView, wizardPickedCourse \(scorewindData.wizardPickedCourse.title)")
			print("[debug] WizardPlayableView, wizardPickedLesson \(scorewindData.wizardPickedLesson.title)")
			if verticalSize == .compact {
				feedbackItemMaxHeight = 50.0
				showProgress = false
			} else {
				feedbackItemMaxHeight = 60.0
				showProgress = true
			}
		})
		.onChange(of: verticalSize, perform: { info in
			if info == .compact {
				feedbackItemMaxHeight = 50.0
				showProgress = false
			} else {
				feedbackItemMaxHeight = 60.0
				showProgress = true
			}
			
			if studentData.playableViewVideoOnly == false {
				viewModel.videoPlayer!.pause()
				viewModel.videoPlayer!.replaceCurrentItem(with: nil)
				studentData.playableViewVideoOnly = false
				viewModel.loadToGo = true
				setupPlayer(withoutScoreViewer: studentData.playableViewVideoOnly)
				if rememberPlaybackTime > 0 {
					viewModel.playerGoTo(timestamp: rememberPlaybackTime)
				} else {
					viewModel.playerGoTo(timestamp: 0.0)
				}
			}
		})

	}
	
	private func feedbackTapAction(feedback: PlayableFeedback) {
		feedbackImpact.impactOccurred()
		
		animateVideo = false
		
		viewModel.videoPlayer!.pause()
		viewModel.videoPlayer!.replaceCurrentItem(with: nil)
		studentData.playableViewVideoOnly = true
		
		print("feedback clicked label:value \(feedback.getLabel()):\(feedback.rawValue)")
		studentData.updatePlayable(courseID: scorewindData.wizardPickedCourse.id, lessonID: scorewindData.wizardPickedLesson.id, feedbackValue: feedback.rawValue)
		
		var nextStep:Page
		if studentData.wizardRange.count < 10 {
			nextStep = scorewindData.createRecommendation(studentData: studentData)
		} else {
			scorewindData.finishWizardNow(studentData: studentData)
			nextStep = Page.wizardResult
		}
		
		if nextStep != .wizardChooseInstrument {
			stepName = nextStep
			studentData.wizardStepNames.append(nextStep)
			
			if nextStep == .wizardPlayable {
				rememberPlaybackTime = 0.0
				viewModel.loadToGo = false
				viewModel.viewedLesson = scorewindData.wizardPickedLesson
				viewModel.viewedTimestampRecs = scorewindData.wizardPickedTimestamps
				setupPlayer(withoutScoreViewer: studentData.playableViewVideoOnly)
				viewModel.playerGoTo(timestamp: findFirstPlayableTimestamp())
			}
			
			if nextStep != .wizardPlayable && nextStep != .wizardResult {
				showProgress = true
			}
		}
	}
	
	private func setupPlayer(withoutScoreViewer: Bool){
		showVideoLoader = true
		if withoutScoreViewer == false {
			viewModel.videoPlayer = AVPlayer(url: URL(string: decodeVideoURL(videoURL: scorewindData.wizardPickedLesson.video))!)
			//viewModel.videoPlayer?.play()
			
			viewModel.videoPlayer!.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 3), queue: .main, using: { time in
				let catchTime = time.seconds
				
				print("catchTime:"+String(catchTime))
				if showVideoLoader {
					if self.rememberPlaybackTime > 0.01 && catchTime > self.rememberPlaybackTime {
						showVideoLoader = false
					}
				}
				
				self.rememberPlaybackTime = catchTime
				let atMeasure = findMesaureByTimestamp(videoTime: catchTime)
				self.viewModel.valuePublisher.send(String(atMeasure))
				//print("[debug] LessonView, setupPlayer, ready to play")
				print("find measure:"+String(atMeasure))
				
				
			})
		} else {
			viewModel.videoPlayer = AVPlayer(url: URL(string: decodeVideoURL(videoURL: scorewindData.wizardPickedLesson.video))!)
			viewModel.videoPlayer!.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 3), queue: .main, using: { time in
				let catchTime = time.seconds
				
				print("video catchTime:"+String(catchTime))
				print("video rememberPlaybackTime:"+String(self.rememberPlaybackTime))
				if showVideoLoader {
					if self.rememberPlaybackTime > 0.01 && catchTime > self.rememberPlaybackTime {
						showVideoLoader = false
					}
				}
				
				self.rememberPlaybackTime = catchTime
				
			})
			//viewModel.videoPlayer?.play()
		}
		
		withAnimation {
			animateVideo = true
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.showVideoLoader = true
		}
		print("[debug] WizardPlayableView, rememberPlaybackTime \(self.rememberPlaybackTime)")
	}
	
	private func findFirstPlayableTimestamp() -> Double {
		var result = 0.0
		for timestamp in scorewindData.wizardPickedTimestamps {
			if timestamp.measure > 0 && (timestamp.notes == "" || timestamp.notes == "play") && timestamp.type == "piano" {
				result = timestamp.timestamp
				break
			}
		}
		print("[debug] WizardPlayableView, findFirstPlayableTimestamp \(result)")
		return result
	}
	
	private func findMesaureByTimestamp(videoTime: Double)->Int{
		var getMeasure = 0
		for(index, theTime) in scorewindData.wizardPickedTimestamps.enumerated(){
			//print("index "+String(index))
			//print("timestamp "+String(theTime.measure))
			var endTimestamp = theTime.timestamp + 100
			if index < scorewindData.wizardPickedTimestamps.count-1 {
				endTimestamp = scorewindData.wizardPickedTimestamps[index+1].timestamp
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
	
	private func decodeVideoURL(videoURL:String)->String{
		let decodedURL = videoURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
		return decodedURL
	}
	
	private func getVideoFrame() -> VideoFrame {
		if verticalSize == .regular {
			return VideoFrame(width: UIScreen.main.bounds.width*0.85, height: UIScreen.main.bounds.width*0.85 * 9/16)
		} else {
			return VideoFrame(width: UIScreen.main.bounds.height*0.55 * 16/9, height: UIScreen.main.bounds.height*0.55)
		}
	}
	
	struct displayOption: View {
		let feedbackItem: PlayableFeedback
		var itemWidthBeforeAnimated: CGFloat
		var itemWidthAfterAnimated: CGFloat
		var opHasShadow: Bool
		@Binding var animated: Bool
		let maxHeight:CGFloat
		
		var body: some View {
			VStack {
				VStack {
						HStack(spacing:0) {
							HStack {
								Image(getItemImageName(feedbackItem: feedbackItem))
									.resizable()
									.scaledToFit()
									.shadow(color: Color("Dynamic/MainBrown+6").opacity(0.5), radius: CGFloat(5))
							}
							.padding(10)
							//.frame(width: itemTotalWidth*0.13)
							Text(feedbackItem.getLabel())
								.foregroundColor(Color("Dynamic/MainBrown+6"))
								//.frame(width:itemTotalWidth*0.53)
							Spacer()
						}
					
				}
				.frame(maxWidth: animated ? itemWidthAfterAnimated*0.60 : itemWidthBeforeAnimated*0.60, maxHeight: maxHeight)
				.background {
					if opHasShadow || animated {
						RoundedRectangle(cornerRadius: 17)
							.foregroundColor(Color("Dynamic/LightGray"))
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					} else {
						RoundedRectangle(cornerRadius: 17)
							.foregroundColor(Color("Dynamic/LightGray"))
					}
				}
				.padding(.top, 10)
				Spacer()
			}
		}
		
		private func getItemImageName(feedbackItem: PlayableFeedback) -> String {
			switch feedbackItem {
			case .easyPeasy:
				return "feedbackYes"
			case .comfortable:
				return "feedbackComfortable"
			case .canLearn:
				return "feedbackCanLearn"
			case .littleDifficult:
				return "feedbackLittleDifficult"
			case .veryHard:
				return "feedbackNo"
			}
		}
	}
	
	struct ViewTitleFont: ViewModifier {
		var videoOnly:Bool
		@Environment(\.verticalSizeClass) var verticalSize
		
		func body(content: Content) -> some View {
			if videoOnly {
				if verticalSize == .regular {
					content.font(.title)
				} else {
					content.font(.title2)
				}
			} else {
				if verticalSize == .regular {
					content
						.font(.headline)
				} else {
					content
						.font(.title2)
				}
				
			}
		}
	}
	
	struct VideoFrame {
		var width:CGFloat
		var height:CGFloat
	}
	
	struct ScoreViewerOverlay: ViewModifier {
		var overlayWidth: CGFloat
		var overlayHeight: CGFloat
		@Binding var showScoreOverlay:Bool
		
		func body(content: Content) -> some View {
			content
			.overlay(content: {
				VStack {
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
						.onTapGesture {
							if showScoreOverlay {
								withAnimation{
									showScoreOverlay = false
								}
							}
						}
				}
				.frame(width:overlayWidth, height:overlayHeight)
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/MainBrown"))
						.opacity(0.7)
				)
				.opacity(showScoreOverlay ? 1 : 0)
				.disabled(showScoreOverlay ? false : true)
				.onAppear(perform: {
					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						if showScoreOverlay {
							withAnimation{
								showScoreOverlay = false
							}
						}
					}
				})
			})
			
		}
	}
	
	@ViewBuilder
	private func displayVideo() -> some View {
		VideoPlayer(player: viewModel.videoPlayer)
			.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
			.frame(width: animateVideo ? getVideoFrame().width : 0, height: getVideoFrame().height)
			.offset(x: animateVideo ? 0 : 0 - UIScreen.main.bounds.width*0.85)
			.opacity(animateVideo ? 1 : 0)
			.transition(AnyTransition.asymmetric(insertion: .slide, removal: .scale).combined(with: .opacity))
			.overlay(content: {
				if showVideoLoader {
					VStack {
						ZStack {
							videoLoader(frameSize: getVideoFrame().width*0.3)
						}
					}
					.frame(width: animateVideo ? getVideoFrame().width : 0, height: getVideoFrame().height)
					.background {
						RoundedRectangle(cornerRadius: 17)
							.foregroundColor(.black)
							.opacity(0.80)
					}
				}
			})
	}
	
	@ViewBuilder
	private func feedbackOptionView() -> some View {
		ForEach(PlayableFeedback.allCases, id: \.self){ feedbackItem in
			Text(feedbackItem.getLabel())
				.modifier(FeedbackOptionsModifier())
				.onTapGesture {
					feedbackTapAction(feedback: feedbackItem)
				}
		}
	}
	
	@ViewBuilder
	private func viewWithScoreMenu() -> some View {
		HStack {
			Label(studentData.playableViewVideoOnly == true ? "View It With Score" : "Video Only", systemImage: studentData.playableViewVideoOnly ? "music.quarternote.3" : "person.crop.rectangle.fill")
				.foregroundColor(Color("Dynamic/MainBrown+6"))
				.padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
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
					if studentData.playableViewVideoOnly {
						viewModel.videoPlayer!.pause()
						viewModel.videoPlayer!.replaceCurrentItem(with: nil)
						withAnimation {
							studentData.playableViewVideoOnly = false
						}
						
						viewModel.loadToGo = true
						setupPlayer(withoutScoreViewer: studentData.playableViewVideoOnly)
						if rememberPlaybackTime > 0 {
							viewModel.playerGoTo(timestamp: rememberPlaybackTime)
						} else {
							viewModel.playerGoTo(timestamp: 0.0)
						}
					} else {
						viewModel.videoPlayer!.pause()
						viewModel.videoPlayer!.replaceCurrentItem(with: nil)
						viewModel.loadToGo = false
						
						withAnimation {
							studentData.playableViewVideoOnly = true
						}
						
						setupPlayer(withoutScoreViewer: studentData.playableViewVideoOnly)
						if rememberPlaybackTime > 0 {
							viewModel.playerGoTo(timestamp: rememberPlaybackTime)
						} else {
							viewModel.playerGoTo(timestamp: findFirstPlayableTimestamp())
						}
					}
					
					if animate {
						withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
							animate.toggle()
						}
					}
				}
		}
	}
	
	@ViewBuilder
	private func displayOptionsZ(frameHeight: CGFloat = 50.0) -> some View {
		if verticalSize == .regular {
			GeometryReader { reader in
				ZStack {
					HStack {
						Spacer()
						HStack {
							Spacer()
							Label("Close", systemImage: "xmark")
								.labelStyle(.iconOnly)
								.foregroundColor(Color("Dynamic/MainBrown+6"))
								.padding(15)
							Spacer()
						}
						.frame(width: 48)
						.background {
							RoundedRectangle(cornerRadius: 26)
								.foregroundColor(Color("Dynamic/LightGray"))
								.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						}
						.onTapGesture {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
						}
					}.frame(width:reader.size.width*0.60)
				}
				.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
				.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*6 : reader.size.height-feedbackItemMaxHeight)
				.opacity(animate ? 1 : 0)
				
				ZStack {
					displayOption(feedbackItem: .veryHard, itemWidthBeforeAnimated: reader.size.width*0.80, itemWidthAfterAnimated: reader.size.width, opHasShadow:false, animated: $animate, maxHeight: feedbackItemMaxHeight)
				}
				.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
				.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*1 : reader.size.height-feedbackItemMaxHeight)
				.onTapGesture {
					if animate {
						withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
							animate.toggle()
						}
						feedbackTapAction(feedback: .veryHard)
					}
				}
				
				ZStack {
					displayOption(feedbackItem: .littleDifficult, itemWidthBeforeAnimated: reader.size.width*0.86, itemWidthAfterAnimated: reader.size.width, opHasShadow: false, animated: $animate, maxHeight: feedbackItemMaxHeight)
				}
				.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
				.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*2 : reader.size.height-feedbackItemMaxHeight)
				.opacity(animate ? 1 : 0)
				.onTapGesture {
					if animate {
						withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
							animate.toggle()
						}
						feedbackTapAction(feedback: .littleDifficult)
					}
				}
				
				ZStack {
					displayOption(feedbackItem: .canLearn, itemWidthBeforeAnimated: reader.size.width*0.80, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate, maxHeight: feedbackItemMaxHeight)
				}
				.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
				.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*3 : reader.size.height-feedbackItemMaxHeight)
				.onTapGesture {
					if animate {
						withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
							animate.toggle()
						}
						feedbackTapAction(feedback: .canLearn)
					}
				}
				
				ZStack {
					displayOption(feedbackItem: .comfortable, itemWidthBeforeAnimated: reader.size.width*0.90, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate, maxHeight: feedbackItemMaxHeight)
				}
				.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
				.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*4 : reader.size.height-feedbackItemMaxHeight-5)
				.onTapGesture {
					if animate  {
						withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
							animate.toggle()
						}
						feedbackTapAction(feedback: .comfortable)
					}
				}
				
				ZStack {
					displayOption(feedbackItem: .easyPeasy ,itemWidthBeforeAnimated: reader.size.width, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate, maxHeight: feedbackItemMaxHeight)
				}
				.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
				.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*5 : reader.size.height-feedbackItemMaxHeight-10)
				.onTapGesture {
					if animate {
						withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
							animate.toggle()
						}
						feedbackTapAction(feedback: .easyPeasy)
					} else {
						withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
							animate.toggle()
						}
					}
					
				}
			}.frame(height:frameHeight)
		} else {
			if studentData.playableViewVideoOnly {
				GeometryReader { reader in
					ZStack {
						HStack {
							Spacer()
							HStack {
								Spacer()
								Label("Close", systemImage: "xmark")
									.labelStyle(.iconOnly)
									.foregroundColor(Color("Dynamic/MainBrown+6"))
									.padding(15)
								Spacer()
							}
							.frame(width: 48)
							.background {
								RoundedRectangle(cornerRadius: 26)
									.foregroundColor(Color("Dynamic/LightGray"))
									.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							}
							.onTapGesture {
								withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
									animate.toggle()
								}
							}
						}.frame(width:reader.size.width*0.60)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height/2 - feedbackItemMaxHeight*4 : reader.size.height/2 - feedbackItemMaxHeight)
					.opacity(animate ? 1 : 0)
					
					ZStack {
						displayOption(feedbackItem: .veryHard, itemWidthBeforeAnimated: reader.size.width*0.80, itemWidthAfterAnimated: reader.size.width, opHasShadow:false, animated: $animate, maxHeight: feedbackItemMaxHeight)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height/2 + feedbackItemMaxHeight : reader.size.height/2 - feedbackItemMaxHeight)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .veryHard)
						}
					}
					
					ZStack {
						displayOption(feedbackItem: .littleDifficult, itemWidthBeforeAnimated: reader.size.width*0.86, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate, maxHeight: feedbackItemMaxHeight)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height/2 : reader.size.height/2 - feedbackItemMaxHeight+5)
					//.opacity(animate ? 1 : 0)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .littleDifficult)
						}
					}
					
					ZStack {
						displayOption(feedbackItem: .canLearn, itemWidthBeforeAnimated: reader.size.width*0.80, itemWidthAfterAnimated: reader.size.width, opHasShadow: false, animated: $animate, maxHeight: feedbackItemMaxHeight)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height/2 - feedbackItemMaxHeight : reader.size.height/2 - feedbackItemMaxHeight)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .canLearn)
						}
					}
					
					ZStack {
						displayOption(feedbackItem: .comfortable, itemWidthBeforeAnimated: reader.size.width*0.90, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate, maxHeight: feedbackItemMaxHeight)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height/2 - feedbackItemMaxHeight*2 : reader.size.height/2 - feedbackItemMaxHeight-5)
					.onTapGesture {
						if animate  {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .comfortable)
						}
					}
					
					ZStack {
						displayOption(feedbackItem: .easyPeasy ,itemWidthBeforeAnimated: reader.size.width, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate, maxHeight: feedbackItemMaxHeight)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height/2 - feedbackItemMaxHeight*3 : reader.size.height/2 - feedbackItemMaxHeight)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .easyPeasy)
						} else {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
						}
						
					}
				}.frame(height:frameHeight)
			} else {
				GeometryReader { reader in
					ZStack {
						HStack {
							Spacer()
							HStack {
								Spacer()
								Label("Close", systemImage: "xmark")
									.labelStyle(.iconOnly)
									.foregroundColor(Color("Dynamic/MainBrown+6"))
									.padding(15)
								Spacer()
							}
							.frame(width: 48)
							.background {
								RoundedRectangle(cornerRadius: 26)
									.foregroundColor(Color("Dynamic/LightGray"))
									.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							}
							.onTapGesture {
								withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
									animate.toggle()
								}
							}
						}.frame(width:reader.size.width*0.60)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*6 : reader.size.height-feedbackItemMaxHeight)
					.opacity(animate ? 1 : 0)
					
					ZStack {
						displayOption(feedbackItem: .veryHard, itemWidthBeforeAnimated: reader.size.width*0.80, itemWidthAfterAnimated: reader.size.width, opHasShadow:false, animated: $animate, maxHeight: feedbackItemMaxHeight)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*1 : reader.size.height-feedbackItemMaxHeight)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .veryHard)
						}
					}
					
					ZStack {
						displayOption(feedbackItem: .littleDifficult, itemWidthBeforeAnimated: reader.size.width*0.86, itemWidthAfterAnimated: reader.size.width, opHasShadow: false, animated: $animate, maxHeight: feedbackItemMaxHeight)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*2 : reader.size.height-feedbackItemMaxHeight)
					.opacity(animate ? 1 : 0)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .littleDifficult)
						}
					}
					
					ZStack {
						displayOption(feedbackItem: .canLearn, itemWidthBeforeAnimated: reader.size.width*0.80, itemWidthAfterAnimated: reader.size.width, opHasShadow: false, animated: $animate, maxHeight: feedbackItemMaxHeight)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*3 : reader.size.height-feedbackItemMaxHeight)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .canLearn)
						}
					}
					
					ZStack {
						displayOption(feedbackItem: .comfortable, itemWidthBeforeAnimated: reader.size.width*0.90, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate, maxHeight: feedbackItemMaxHeight)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*4 : reader.size.height-feedbackItemMaxHeight)
					.onTapGesture {
						if animate  {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .comfortable)
						}
					}
					
					ZStack {
						displayOption(feedbackItem: .easyPeasy ,itemWidthBeforeAnimated: reader.size.width, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate, maxHeight: feedbackItemMaxHeight)
					}
					.frame(width: reader.size.width, height: feedbackItemMaxHeight+10)
					.offset(y: animate ? reader.size.height-feedbackItemMaxHeight*5 : reader.size.height-feedbackItemMaxHeight-5)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .easyPeasy)
						} else {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
						}
						
					}
				}.frame(height:frameHeight)
			}
			
		}
		
	}
}

struct videoLoader: View {
	@State private var isLoading = false
	var frameSize: CGFloat
	
	var body: some View {
		Circle()
		//.trim(from: 0, to: 0.85)
			.stroke(Color("AppYellow"), style: StrokeStyle(
				lineWidth: 4,
				lineCap: .round,
				lineJoin: .round,
				miterLimit: 0,
				dash: [50,10],
				dashPhase: 0
			))
		//.stroke(Color("AppYellow"), lineWidth: 3)
			.background{
				Circle()
					.foregroundColor(Color("AppYellow"))
					.opacity(0.7)
			}
			.overlay(content:{
				Image("logo")
					.resizable()
					.scaledToFit()
					.foregroundColor(Color("AppYellow"))
					.padding(15)
			})
			.frame(width: frameSize, height: frameSize)
			.rotationEffect(Angle(degrees: isLoading ? 360 : 0))
		//.animation(Animation.default.repeatForever(autoreverses: false))
			.onAppear() {
				//print("video loader onAppear")
				withAnimation(.default.repeatForever(autoreverses:false).speed(0.2)){
					self.isLoading = true
				}
			}
	}
}

struct WizardPlayable_Previews: PreviewProvider {
	@State static var tab = "THome"
	@State static var step:Page = .wizardPlayable
	@StateObject static var scorewindData = ScorewindData()
	@StateObject static var studentData = StudentData()
	
	static var previews: some View {
		
		WizardPlayableView(selectedTab: $tab, stepName: $step, studentData: studentData, showProgress: .constant(true))
			.environmentObject(scorewindData)
			.environment(\.colorScheme, .light)
			.previewInterfaceOrientation(InterfaceOrientation.portrait)
			.previewDisplayName("Light Portrait")
		WizardPlayableView(selectedTab: $tab, stepName: $step, studentData: studentData, showProgress: .constant(false))
			.environmentObject(scorewindData)
			.environment(\.colorScheme, .light)
			.previewInterfaceOrientation(InterfaceOrientation.landscapeLeft)
			.previewDisplayName("Light LandscapeLeft")
	}
}

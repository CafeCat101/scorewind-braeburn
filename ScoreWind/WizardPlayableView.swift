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
	@StateObject var viewModel = ViewModel()
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var rememberPlaybackTime:Double = 0.0
	@State private var showContentHint = false
	@State private var animate = false
	let feedbackImpact = UIImpactFeedbackGenerator(style: .heavy)
	@State private var animateVideo = true
	let transition = AnyTransition.asymmetric(insertion: .slide, removal: .scale).combined(with: .opacity)
	
	var body: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()
				Text("How do you feel about playing this?")
					.font(studentData.playableViewVideoOnly ? .title : .headline)
					.bold()
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.multilineTextAlignment(.center)
					.onTapGesture(count:3, perform: {
						showContentHint.toggle()
					})
				Spacer()
			}
			Divider().frame(width:screenSize.width*0.85)
			
			Spacer()
			
			VStack {
				HStack {
					/*
					Button(action: {
						if studentData.playableViewVideoOnly {
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
						} else {
							viewModel.videoPlayer!.pause()
							viewModel.videoPlayer!.replaceCurrentItem(with: nil)
							viewModel.loadToGo = false
							studentData.playableViewVideoOnly = true
							setupPlayer(withoutScoreViewer: studentData.playableViewVideoOnly)
							if rememberPlaybackTime > 0 {
								viewModel.playerGoTo(timestamp: rememberPlaybackTime)
							} else {
								viewModel.playerGoTo(timestamp: findFirstPlayableTimestamp())
							}
						}
					}, label: {
						Label(studentData.playableViewVideoOnly == true ? "View It With Score" : "Video Only", systemImage: "music.note")
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
							/*.background {
								RoundedRectangle(cornerRadius: 17)
									.foregroundColor(Color("Dynamic/LightGray"))
									.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							}*/
						/*Text(studentData.playableViewVideoOnly == true ? "View it with score" : "Video only")
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
							.background {
								RoundedRectangle(cornerRadius: 17)
									.foregroundColor(Color("Dynamic/LightGray"))
									.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							}*/
					})
					*/
					
					Label(studentData.playableViewVideoOnly == true ? "View It With Score" : "Video Only", systemImage: studentData.playableViewVideoOnly ? "music.quarternote.3" : "person.crop.rectangle.fill")
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
						.background(
							RoundedRectangle(cornerRadius: CGFloat(17))
								.foregroundColor(Color("Dynamic/MainBrown"))
								.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
								.overlay {
									RoundedRectangle(cornerRadius: 17)
										.stroke(Color("Dynamic/ShadowLight"), lineWidth: 1)
								}
								.opacity(0.25)
								
						)
						.onTapGesture {
							if studentData.playableViewVideoOnly {
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
							} else {
								viewModel.videoPlayer!.pause()
								viewModel.videoPlayer!.replaceCurrentItem(with: nil)
								viewModel.loadToGo = false
								studentData.playableViewVideoOnly = true
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
					
					Spacer()
					if studentData.playableViewVideoOnly == false {
						Text("Tab the bar to hear!")
							.font(.subheadline)
							.foregroundColor(Color("Dynamic/MainBrown+6"))
					}
				}.frame(width:screenSize.width*0.85)
				VideoPlayer(player: viewModel.videoPlayer)
					.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
					.frame(width: animateVideo ? screenSize.width*0.85 : 0, height: screenSize.width*0.85 * 9/16)
					.offset(x: animateVideo ? 0 : 0 - screenSize.width*0.85)
					.opacity(animateVideo ? 1 : 0)
					.transition(AnyTransition.asymmetric(insertion: .slide, removal: .scale).combined(with: .opacity))
				
					//.padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 5))
				if studentData.playableViewVideoOnly == false {
					GeometryReader { scoreSpaceReader in
						HStack(spacing: 0) {
							Spacer()
							LessonScoreView(viewModel: viewModel)
								.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
								.frame(width:screenSize.width*0.85, height:scoreSpaceReader.size.height)
								//.padding(EdgeInsets(top: 3, leading: 5, bottom: 10, trailing: 5))
							Spacer()
						}
					}
				}

				if studentData.playableViewVideoOnly {
					Spacer()
				}
				
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
					.frame(width: reader.size.width, height: 70)
					.offset(y: animate ? reader.size.height-60*6 : reader.size.height-60)
					.opacity(animate ? 1 : 0)
					
					ZStack {
						op1(feedbackItem: .veryHard, itemWidthBeforeAnimated: reader.size.width*0.80, itemWidthAfterAnimated: reader.size.width, opHasShadow:false, animated: $animate)
					}
					.frame(width: reader.size.width, height: 70)
					.offset(y: animate ? reader.size.height-60*1 : reader.size.height-60)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .veryHard)
						}
					}
					
					ZStack {
						op1(feedbackItem: .littleDifficult, itemWidthBeforeAnimated: reader.size.width*0.86, itemWidthAfterAnimated: reader.size.width, opHasShadow: false, animated: $animate)
					}
					.frame(width: reader.size.width, height: 70)
					.offset(y: animate ? reader.size.height-60*2 : reader.size.height-60)
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
						op1(feedbackItem: .canLearn, itemWidthBeforeAnimated: reader.size.width*0.80, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate)
					}
					.frame(width: reader.size.width, height: 70)
					.offset(y: animate ? reader.size.height-60*3 : reader.size.height-60)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .canLearn)
						}
					}
					
					ZStack {
						op1(feedbackItem: .comfortable, itemWidthBeforeAnimated: reader.size.width*0.90, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate)
					}
					.frame(width: reader.size.width, height: 70)
					.offset(y: animate ? reader.size.height-60*4 : reader.size.height-65)
					.onTapGesture {
						if animate  {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .comfortable)
						}
					}
					
					ZStack {
						op1(feedbackItem: .easyPeasy ,itemWidthBeforeAnimated: reader.size.width, itemWidthAfterAnimated: reader.size.width, opHasShadow: true, animated: $animate)
					}
					.frame(width: reader.size.width, height: 70)
					.offset(y: animate ? reader.size.height-60*5 : reader.size.height-70)
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
				}.frame(height:70)

				//:: the tab layout
				/*
				GeometryReader { reader in
					VStack {
						Spacer()
						TabView {
							op1(feedbackItem: .easyPeasy ,itemTotalWidth: reader.size.width)
								.onTapGesture {
									feedbackTapAction(feedback: .easyPeasy)
								}
							op1(feedbackItem: .comfortable,itemTotalWidth: reader.size.width)
								.onTapGesture {
									feedbackTapAction(feedback: .comfortable)
								}

							

						}
						.frame(maxHeight: 130)
						.tabViewStyle(.page)
						Spacer()
					}
					
				}
				*/
				
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
		})
		.onDisappear(perform: {
			viewModel.videoPlayer!.pause()
			viewModel.videoPlayer!.replaceCurrentItem(with: nil)
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
				viewModel.loadToGo = false
				viewModel.viewedLesson = scorewindData.wizardPickedLesson
				viewModel.viewedTimestampRecs = scorewindData.wizardPickedTimestamps
				setupPlayer(withoutScoreViewer: studentData.playableViewVideoOnly)
				viewModel.playerGoTo(timestamp: findFirstPlayableTimestamp())
			}
		}
	}
	
	private func setupPlayer(withoutScoreViewer: Bool){
		if withoutScoreViewer == false {
			//viewModel.videoPlayer = AVPlayer(url: URL(string: decodeVideoURL(videoURL: scorewindData.wizardPickedLesson.video))!)
			viewModel.videoPlayer = AVPlayer(url: URL(string: decodeVideoURL(videoURL: scorewindData.wizardPickedLesson.video))!)
			//viewModel.videoPlayer?.play()
			
			viewModel.videoPlayer!.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 3), queue: .main, using: { time in
				let catchTime = time.seconds
				self.rememberPlaybackTime = catchTime
				let atMeasure = findMesaureByTimestamp(videoTime: catchTime)
				self.viewModel.valuePublisher.send(String(atMeasure))
				//print("[debug] LessonView, setupPlayer, ready to play")
				print("find measure:"+String(atMeasure))
			})
			
			//if viewModel.viewedTimestampRecs!.count > 0 {
			//	viewModel.playerGoTo(timestamp: 0.0)
			//}
		} else {
			/*
			let downloadableVideoURL = URL(string: scorewindData.wizardPickedLesson.videoMP4.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
			let wizardVideoURL = Bundle.main.resourceURL!.appendingPathComponent("WizardVideos/\(downloadableVideoURL.lastPathComponent)")
			print("[debug] WizardPlayableView, wizardVideoUrl.path \(wizardVideoURL.path)")
			if FileManager.default.fileExists(atPath: wizardVideoURL.path) {
				viewModel.videoPlayer = AVPlayer(url: wizardVideoURL)
				viewModel.videoPlayer?.play()
			}
			 */
			viewModel.videoPlayer = AVPlayer(url: URL(string: decodeVideoURL(videoURL: scorewindData.wizardPickedLesson.video))!)
			viewModel.videoPlayer!.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 3), queue: .main, using: { time in
				let catchTime = time.seconds
				self.rememberPlaybackTime = catchTime
			})
			//viewModel.videoPlayer?.play()
		}
		withAnimation {
			animateVideo = true
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
	
	struct op1: View {
		let feedbackItem: PlayableFeedback
		var itemWidthBeforeAnimated: CGFloat
		var itemWidthAfterAnimated: CGFloat
		var opHasShadow: Bool
		@Binding var animated: Bool
		
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
				.frame(maxWidth: animated ? itemWidthAfterAnimated*0.60 : itemWidthBeforeAnimated*0.60, maxHeight: 60)
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
}

extension AnyTransition {
		static var backslide: AnyTransition {
				AnyTransition.asymmetric(
						insertion: .move(edge: .trailing),
						removal: .move(edge: .leading))}
}

struct WizardPlayable_Previews: PreviewProvider {
	@State static var tab = "THome"
	@State static var step:Page = .wizardPlayable
	@StateObject static var scorewindData = ScorewindData()
	@StateObject static var studentData = StudentData()
	
	
	static var previews: some View {
		WizardPlayableView(selectedTab: $tab, stepName: $step, studentData: studentData)
			.environmentObject(scorewindData)
	}
}

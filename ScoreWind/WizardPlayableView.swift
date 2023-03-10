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
				Spacer()
			}
			Divider().frame(width:screenSize.width*0.85)
			
			Spacer()
			
			VStack {
				HStack {
					if studentData.playableViewVideoOnly == false {
						Text("Tab the bar to hear!")
							.font(.subheadline)
					}
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
						Text(studentData.playableViewVideoOnly == true ? "View it with score" : "Video only")
					})
				}
				
				VideoPlayer(player: viewModel.videoPlayer)
					.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
					.frame(width:screenSize.width*0.85, height: screenSize.width*0.85 * 9/16)
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
				
				
					
					//.frame(maxHeight: reader.size.height * 0.45)
				/*if studentData.playableViewVideoOnly == false {
					LessonScoreView(viewModel: viewModel)
						.clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
						.frame(maxWidth:screenSize.width*0.94, maxHeight: screenSize.width*0.94 * 9/16)
						//.padding(EdgeInsets(top: 3, leading: 5, bottom: 10, trailing: 5))
				} else {
					Spacer()
				}*/
				
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
					
					ZStack {
						op1(feedbackItem: .veryHard ,itemTotalWidth: reader.size.width, opHasShadow:false, animated: $animate)
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
						op1(feedbackItem: .littleDifficult ,itemTotalWidth: reader.size.width, opHasShadow: false, animated: $animate)
					}
					.frame(width: reader.size.width, height: 70)
					.offset(y: animate ? reader.size.height-60*2 : reader.size.height-60)
					.onTapGesture {
						if animate {
							withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
								animate.toggle()
							}
							feedbackTapAction(feedback: .littleDifficult)
						}
					}
					
					ZStack {
						op1(feedbackItem: .canLearn ,itemTotalWidth: reader.size.width, opHasShadow: true, animated: $animate)
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
						op1(feedbackItem: .comfortable ,itemTotalWidth: reader.size.width, opHasShadow: true, animated: $animate)
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
						op1(feedbackItem: .easyPeasy ,itemTotalWidth: reader.size.width, opHasShadow: true, animated: $animate)
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
				
				//::the horizontal scroll layout
				/*
				GeometryReader { reader in
					ScrollView(.horizontal) {
						HStack {
							op1(feedbackItem: .easyPeasy ,itemTotalWidth: reader.size.width)
								.onTapGesture {
									feedbackTapAction(feedback: .easyPeasy)
								}
							op1(feedbackItem: .comfortable ,itemTotalWidth: reader.size.width)
								.onTapGesture {
									feedbackTapAction(feedback: .comfortable)
								}
							op1(feedbackItem: .canLearn ,itemTotalWidth: reader.size.width)
								.onTapGesture {
									feedbackTapAction(feedback: .canLearn)
								}
						}
					}
				}.frame(width:screenSize.width ,height: 130)
				*/
					
			
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
				
				/*
				VStack {
					GeometryReader { reader in
						HStack(spacing:0) {
							HStack {
								Image("feedbackYes")
									.resizable()
									.padding(15)
									.scaledToFit()
									.shadow(color: Color("Dynamic/MainBrown+6").opacity(0.5), radius: CGFloat(5))
							}
							.frame(width: CGFloat(reader.size.width*0.3))
							Text("Easy peasy")
								.padding(.trailing,15)
								.frame(width:reader.size.width - reader.size.width*0.3)
						}
					}.frame(maxHeight: 85)
				}
				.foregroundColor(Color("Dynamic/MainBrown+6"))
				.background {
					RoundedRectangle(cornerRadius: 17)
						.foregroundColor(Color("Dynamic/LightGray"))
						.shadow(color: Color("Dynamic/ShadowLight"),radius: CGFloat(5))
				}
				.padding(.top,10)
				.frame(maxWidth: screenSize.width*0.80)
				 */
				if studentData.playableViewVideoOnly {
					Spacer()
				}
				
				/*
				Group {
					HStack {
						Text(PlayableFeedback.easyPeasy.getLabel())
							.modifier(FeedbackOptionsModifier())
							.padding(.trailing,10)
							.onTapGesture {
								feedbackTapAction(feedback: .easyPeasy)
							}
						Text(PlayableFeedback.comfortable.getLabel())
							.modifier(FeedbackOptionsModifier())
							.onTapGesture {
								feedbackTapAction(feedback: .comfortable)
							}
					}.padding(.bottom,10)
					Text(PlayableFeedback.canLearn.getLabel())
						.modifier(FeedbackOptionsModifier())
						.onTapGesture {
							feedbackTapAction(feedback: .canLearn)
						}.padding(.bottom,10)
					HStack {
						Text(PlayableFeedback.littleDifficult.getLabel())
							.modifier(FeedbackOptionsModifier())
							.padding(.trailing,10)
							.onTapGesture {
								feedbackTapAction(feedback: .littleDifficult)
							}
						Text(PlayableFeedback.veryHard.getLabel())
							.modifier(FeedbackOptionsModifier())
							.onTapGesture {
								feedbackTapAction(feedback: .veryHard)
							}
					}.padding(.bottom,10)
					
				}
				 */
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
		var itemTotalWidth: CGFloat
		var opHasShadow: Bool
		@Binding var animated: Bool
		
		var body: some View {
			VStack {
				VStack {
						HStack(spacing:0) {
							HStack {
								Image("feedbackYes")
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
				.frame(maxWidth: itemTotalWidth*0.60, maxHeight: 60)
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
	}
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

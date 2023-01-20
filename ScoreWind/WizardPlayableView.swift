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
	//@State private var videoOnly = true
	
	var body: some View {
		VStack {
			if studentData.playableViewVideoOnly == false {
				HStack {
					Label("Back to video clip", systemImage: "chevron.backward.circle")
						.padding([.leading], 15)
						//.font(.title3)
						.labelStyle(.titleAndIcon)
						.onTapGesture(perform: {
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
						})
					Spacer()
				}
			}
			Text("How do you feel about playing this?")
				.font(.headline)
				.foregroundColor(Color("WizardBackArrow"))
				.bold()
				.padding(EdgeInsets(top: 5, leading: 30, bottom: 0, trailing: 15))
			
			if studentData.playableViewVideoOnly == false {
				Text("Tab the bar to hear!")
					.font(.subheadline)
					.foregroundColor(Color("WizardBackArrow"))
					.bold()
					.padding(EdgeInsets(top: 1, leading: 30, bottom: 0, trailing: 15))
			}
			
			
			GeometryReader { reader in
				VStack {
					VideoPlayer(player: viewModel.videoPlayer)
						.clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
						.padding(EdgeInsets(top: 0, leading: 15, bottom: 2, trailing: 15))
						.frame(maxHeight: reader.size.height * 0.45)
					
					if studentData.playableViewVideoOnly {
						VStack {
							Spacer()
							Group {
								HStack {
									Text(PlayableFeedback.easyPeasy.getLabel())
										.modifier(FeedbackOptionsModifier())
										.onTapGesture {
											feedbackTagAction(feedback: .easyPeasy)
										}
									Text(PlayableFeedback.comfortable.getLabel())
										.modifier(FeedbackOptionsModifier())
										.onTapGesture {
											feedbackTagAction(feedback: .comfortable)
										}
								}
								Text(PlayableFeedback.canLearn.getLabel())
									.modifier(FeedbackOptionsModifier())
									.onTapGesture {
										feedbackTagAction(feedback: .canLearn)
									}
								HStack {
									Text(PlayableFeedback.littleDifficult.getLabel())
										.modifier(FeedbackOptionsModifier())
										.onTapGesture {
											feedbackTagAction(feedback: .littleDifficult)
										}
									Text(PlayableFeedback.veryHard.getLabel())
										.modifier(FeedbackOptionsModifier())
										.onTapGesture {
											feedbackTagAction(feedback: .veryHard)
										}
								}
							}
							Spacer()
							HStack {
								Spacer()
								Button("View it with score") {
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
							}
						}.padding(EdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20))
					} else {
						LessonScoreView(viewModel: viewModel)
							.clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
							.padding(EdgeInsets(top: 0, leading: 15, bottom: 2, trailing: 15))
						ScrollView(.horizontal, showsIndicators: false) {
							HStack {
								feedbackOptionView()
							}.padding(EdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20))
						}
					}
					Text("lesson:\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedLesson.title))").font(.footnote)
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
			}
		}
		.background(Color("AppBackground"))
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
					feedbackTagAction(feedback: feedbackItem)
				}
		}
	}
	
	private func feedbackTagAction(feedback: PlayableFeedback) {
		viewModel.videoPlayer!.pause()
		viewModel.videoPlayer!.replaceCurrentItem(with: nil)
		studentData.playableViewVideoOnly = true
		
		print("feedback clicked value \(feedback.rawValue)")
		studentData.updatePlayable(courseID: scorewindData.wizardPickedCourse.id, lessonID: scorewindData.wizardPickedLesson.id, feedbackValue: feedback.rawValue)
		
		let nextStep = scorewindData.createRecommendation(studentData: studentData)
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
}

struct FeedbackOptionsModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.foregroundColor(Color("WizardFeedbackText"))
			.padding(EdgeInsets(top: 12, leading: 25, bottom: 12, trailing: 25))
			.background {
				RoundedRectangle(cornerRadius: 25)
					.foregroundColor(Color("WizardFeedBack"))
			}
			.fixedSize()
	}
}

struct WizardPlayable_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardPlayable
	
	static var previews: some View {
		WizardPlayableView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

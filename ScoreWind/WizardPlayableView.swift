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
	
	var body: some View {
		VStack {
			/*HStack {
				Label("Back", systemImage: "chevron.backward.circle.fill")
					.labelStyle(.iconOnly)
					.foregroundColor(Color("WizardBackArrow"))
					.font(.title3)
					.onTapGesture(perform: {
						stepName = .wizardChooseInstrument
					})
				/*Image(systemName: "chevron.backward")
					.resizable()
					.scaledToFit()
					.frame(height: screenSize.height/25 - 4)
					.foregroundColor(Color("WizardBackArrow"))
					.onTapGesture(perform: {
						stepName = .wizardChooseInstrument
					})*/
				Spacer()
			}
			.frame(height: screenSize.height/25)
			.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 15))
			*/
			/*Text("How do you feel about playing this?")
				.bold()*/
			
			Text("How do you feel about playing this? \nTab the bar to hear!")
				.font(.title3)
				.foregroundColor(Color("WizardBackArrow"))
				.bold()
				.padding(EdgeInsets(top: 5, leading: 15, bottom: 0, trailing: 15))
			
			GeometryReader { reader in
				VStack {
					/*VStack {
						VideoPlayer(player: viewModel.videoPlayer)
					}
					.background(.black)
					.clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
					.padding(EdgeInsets(top: 0, leading: 15, bottom: 2, trailing: 15))
						.frame(maxHeight: reader.size.height * 0.45)
					
					VStack {
						LessonScoreView(viewModel: viewModel)
					}
					.background(.white)
					.clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
					.padding(EdgeInsets(top: 0, leading: 15, bottom: 2, trailing: 15))*/
					
					VideoPlayer(player: viewModel.videoPlayer)
						.clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
						.padding(EdgeInsets(top: 0, leading: 15, bottom: 2, trailing: 15))
							.frame(maxHeight: reader.size.height * 0.45)
					LessonScoreView(viewModel: viewModel)
						.clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
						.padding(EdgeInsets(top: 0, leading: 15, bottom: 2, trailing: 15))
				}
				.onAppear(perform: {
					viewModel.loadToGo = true
					viewModel.viewedLesson = scorewindData.wizardPickedLesson
					viewModel.viewedTimestampRecs = scorewindData.wizardPickedTimestamps
					setupPlayer()
				})
			}
			
			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					ForEach(PlayableFeedback.allCases, id: \.self){ feedbackItem in
						Text(feedbackItem.getLabel())
							.modifier(FeedbackOptionsModifier())
							.onTapGesture {
								print("feedback clicked value \(feedbackItem.rawValue)")
								stepName = .wizardResult
								studentData.wizardStepNames.append(stepName)
							}
					}
				}.padding(EdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20))
			}
			
			/*
			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					if scorewindData.currentTimestampRecs.count > 0 {
						ForEach(WizardScoreFeedback.allCases, id: \.self){ feedbackItem in
							Text(feedbackItem.getLabel())
								.modifier(FeedbackOptionsModifier())
								.onTapGesture {
									print("feedback clicked value \(feedbackItem.rawValue)")
								}
						}
					} else {
						ForEach(WizardHighlightFeedback.allCases, id: \.self) {feedbackItem in
							Text(feedbackItem.getLabel())
								.modifier(FeedbackOptionsModifier())
								.onTapGesture {
									print("feedback clicked value \(feedbackItem.rawValue)")
								}
						}
					}
					
				}
				.padding(EdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20))
			}
			*/
			
			//Spacer()
		}
		.background(Color("AppBackground"))
		.onAppear(perform: {
			//
		})
	}
	
	private func setupPlayer(){
		viewModel.videoPlayer = AVPlayer(url: URL(string: decodeVideoURL(videoURL: scorewindData.wizardPickedLesson.video))!)
		
		viewModel.videoPlayer!.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 3), queue: .main, using: { time in
			let catchTime = time.seconds
			
			let atMeasure = findMesaureByTimestamp(videoTime: catchTime)
			self.viewModel.valuePublisher.send(String(atMeasure))
			//print("[debug] LessonView, setupPlayer, ready to play")
			print("find measure:"+String(atMeasure))
			
		})
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

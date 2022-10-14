//
//  WizardPlayable.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/10.
//

import SwiftUI
import AVKit

struct WizardPlayable: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	@StateObject var viewModel = ViewModel()
	let screenSize: CGRect = UIScreen.main.bounds
	
	var body: some View {
		VStack {
			/*
			HStack {
				Label("How do you feel about playing this?", systemImage: "chevron.backward.circle")
					.labelStyle(.titleAndIcon)
					.font(.title)
					.onTapGesture(perform: {
						stepName = .wizardChooseInstrument
					})
				Spacer()
			}
			.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))*/
			HStack {
				Image(systemName: "chevron.backward.circle")
					.resizable()
					.scaledToFit()
					.frame(height: screenSize.height/25 - 4)
					.foregroundColor(Color("AppYelloDynamic"))
					.onTapGesture(perform: {
						stepName = .wizardChooseInstrument
					})
				Text("How do you feel about playing this?")
					.font(.title3)
					.truncationMode(.tail)
					.foregroundColor(Color("AppYelloDynamic"))
			}
			.frame(height: screenSize.height/25)
			.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 15))
			
			/*Text("How do you feel about playing this?")
				.bold()*/
			Text("Tap the bar to hear!")
				.bold()
			
			Group {
				VideoPlayer(player: viewModel.videoPlayer)
				LessonScoreView(viewModel: viewModel)
			}.onAppear(perform: {
				viewModel.loadToGo = true
				setupPlayer()
			})
			
			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					ForEach(WizardScoreFeedback.allCases, id: \.self){ feedbackItem in
						Text(feedbackItem.getLabel())
							.foregroundColor(Color("LessonSheet"))
							.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
							.background {
								RoundedRectangle(cornerRadius: 26)
									.foregroundColor(Color("BadgeScoreAvailable"))
							}
							.fixedSize()
							.onTapGesture {
								print("feedback clicked value \(feedbackItem.rawValue)")
							}
					}
				}
				.padding([.leading,.trailing],20)
			}
			
			
			Spacer()
		}
	}
	
	private func setupPlayer(){
		viewModel.videoPlayer = AVPlayer(url: URL(string: decodeVideoURL(videoURL: scorewindData.currentLesson.video))!)
		
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
	
	private func decodeVideoURL(videoURL:String)->String{
		let decodedURL = videoURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
		return decodedURL
	}
}

struct WizardPlayable_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardPlayable
	
	static var previews: some View {
		WizardPlayable(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

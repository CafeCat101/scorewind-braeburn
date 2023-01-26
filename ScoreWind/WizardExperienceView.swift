//
//  WizardExperienceView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/23.
//

import SwiftUI

struct WizardExperienceView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var showStepTip = false
	@State private var tipContent:AnyView = AnyView(Text("Tip"))
	@State private var userDefaults = UserDefaults.standard
	
	var body: some View {
		VStack {
			Spacer()
			Text(ExperienceFeedback.starterKit.getLabel())
				.multilineTextAlignment(.center)
				.frame(width:screenSize.width*0.7)
				.modifier(FeedbackOptionsModifier())
				.onTapGesture {
					print("choose \(ExperienceFeedback.starterKit.rawValue)")
					gotFeedback(selectedFeedback: .starterKit)
					
					
				}
				.padding(.bottom,20)
			
			Text(ExperienceFeedback.continueLearning.getLabel())
				.multilineTextAlignment(.center)
				.frame(width:screenSize.width*0.7)
				.modifier(FeedbackOptionsModifier())
				.onTapGesture {
					print("choose \(ExperienceFeedback.continueLearning.rawValue)")
					gotFeedback(selectedFeedback: .continueLearning)

				}
				.padding(.bottom,20)
			
			Text(ExperienceFeedback.experienced.getLabel())
				.multilineTextAlignment(.center)
				.frame(width:screenSize.width*0.7)
				.modifier(FeedbackOptionsModifier())
				.onTapGesture {
					print("choose \(ExperienceFeedback.experienced.rawValue)")
					gotFeedback(selectedFeedback: .experienced)

				}
			Spacer()
		}
		.background(Color("AppBackground"))
		.onAppear(perform: {
			print("[debug] WizardExperienceView.onAppear")
			//userDefaults.removeObject(forKey: "hideTips")
			print("[debug] WizardExperienceView.onAppear, userDefaults hideTips \(userDefaults.object(forKey: "hideTips") as? [String] ?? [])")
		})
		.fullScreenCover(isPresented: $showStepTip, onDismiss: {
			goToNextStep()
		}, content: {
			TipTransparentModalView(showStepTip: $showStepTip, tipContent: $tipContent)
		})
	}

	private func goToNextStep() {
		let nextStepPage = scorewindData.createRecommendation(studentData: studentData)
		
		if nextStepPage != .wizardChooseInstrument {
			stepName = nextStepPage
			studentData.wizardStepNames.append(nextStepPage)
		}
	}
	
	private func gotFeedback(selectedFeedback: ExperienceFeedback) {
		studentData.updateExperience(experience: selectedFeedback)
		
		let hideTips:[String] = userDefaults.object(forKey: "hideTips") as? [String] ?? []
		if hideTips.contains(Tip.wizardExperience.rawValue) == false {
			tipContent = AnyView(makeTipView(showStepTip: $showStepTip, choise: selectedFeedback))
			showStepTip = true
		} else {
			goToNextStep()
		}
	}
	
	struct makeTipView: View {
		@Binding var showStepTip:Bool
		var choise: ExperienceFeedback
		let screenSize: CGRect = UIScreen.main.bounds
		@State private var userDefaults = UserDefaults.standard
		
		var body: some View {
			VStack{
				Spacer()
				//tip content ==>
				VStack {
					Text("\(choise.getLabel())")
					.font(.headline)
					.modifier(StepExplainingText())
					
					if choise == ExperienceFeedback.continueLearning {
						Text("One step at a time, and you are learning well.\n\nHowever, sometimes you are just wondering what's ahead of you. Maybe you want to take on some challenges.\n\nThere is no time to hesitate. Let's go!")
							.modifier(StepExplainingText())
					} else if choise == ExperienceFeedback.experienced {
						Text("You are skillfull. You can navigate new pieces faster.\nThis step will take you to explore over 400 pieces organized by different techniques in our repositories. Enjoy!")
							.modifier(StepExplainingText())
					} else {
						Text("Scorewind has over 1000 lessons organized by their difficulties. This step will show you the lessons yet completed ahead of you.")
							.modifier(StepExplainingText())
					}
				}.background {
					RoundedRectangle(cornerRadius: 26)
						.foregroundColor(Color("AppYellow"))
					.frame(width: screenSize.width*0.9)}
				//<===
				Spacer()
				VStack{
					Button(action: {
						print("ok")
						showStepTip = false
					}, label: {
						Text("OK").frame(minWidth:150)
					})
					.foregroundColor(Color("LessonListStatusIcon"))
					.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
					.background {
						RoundedRectangle(cornerRadius: 26)
							.foregroundColor(Color("AppYellow"))
					}
					Spacer().frame(maxHeight:20)
					Button(action: {
						print("don't show me again")
						var hideTips:[String] = userDefaults.object(forKey: "hideTips") as? [String] ?? []
						if hideTips.contains(Tip.wizardExperience.rawValue) == false {
							hideTips.append(Tip.wizardExperience.rawValue)
							userDefaults.set(hideTips,forKey: "hideTips")
						}
						
						showStepTip = false
					}, label: {
						Text("Don't show me again").frame(minWidth:150)
					}).foregroundColor(Color("LessonSheet"))
						.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
						 .background {
							 RoundedRectangle(cornerRadius: 26)
								 .foregroundColor(Color("BadgeScoreAvailable"))
						 }
				}
			}
		}
	}
  
	
}

struct WizardExperienceView_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardChooseInstrument
	static var previews: some View {
		WizardExperienceView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}










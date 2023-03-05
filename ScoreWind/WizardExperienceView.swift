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
			
			HStack {
				Spacer()
				Text("Select an experience")
					.font(.title)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.bold()
				Spacer()
			}
			
			Spacer()
			
			VStack {
				//GeometryReader { (proxy: GeometryProxy) in
					TabView {
						displayExperience(experience: .starterKit)
							.onTapGesture {
								print("choose \(ExperienceFeedback.starterKit.rawValue)")
								gotFeedback(selectedFeedback: .starterKit)
							}
						displayExperience(experience: .continueLearning)
							.onTapGesture {
								print("choose \(ExperienceFeedback.continueLearning.rawValue)")
								gotFeedback(selectedFeedback: .continueLearning)
							}
						displayExperience(experience: .experienced)
							.onTapGesture {
								print("choose \(ExperienceFeedback.experienced.rawValue)")
								gotFeedback(selectedFeedback: .experienced)
							}
					}
					.tabViewStyle(.page)
				//}
			}.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.7)
			Spacer()
			
			//original buttons
			/*
			Text(ExperienceFeedback.starterKit.getLabel())
				.multilineTextAlignment(.center)
				.frame(width:screenSize.width*0.7)
				.modifier(FeedbackOptionsModifier())
				.padding(.bottom,20)
				.onTapGesture {
					print("choose \(ExperienceFeedback.starterKit.rawValue)")
					gotFeedback(selectedFeedback: .starterKit)
				}
			
			Text(ExperienceFeedback.continueLearning.getLabel())
				.multilineTextAlignment(.center)
				.frame(width:screenSize.width*0.7)
				.modifier(FeedbackOptionsModifier())
				.onTapGesture {
					print("choose \(ExperienceFeedback.continueLearning.rawValue)")
					
					/*if studentData.getWizardResult().learningPath.count == 0 || scorewindData.wizardPickedCourse.id == 0 || scorewindData.wizardPickedLesson.id == 0 {
						//:: never done the wizard before, set the picked course and lesson to the very first one
						let sortedCourses = scorewindData.allCourses.filter({$0.instrument == studentData.getInstrumentChoice()}).sorted(by: {Int($0.sortValue)! < Int($1.sortValue)!})
						scorewindData.wizardPickedCourse = sortedCourses[0]
						scorewindData.wizardPickedLesson = scorewindData.wizardPickedCourse.lessons[0]
						scorewindData.wizardPickedTimestamps = (scorewindData.allTimestamps.first(where: {$0.id == scorewindData.wizardPickedCourse.id})?.lessons.first(where: {$0.id == scorewindData.wizardPickedLesson.id})!.timestamps) ?? []
					}*/
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
			
			Spacer()*/
		}
		//.background(Color("AppBackground"))
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
	
	private func getExperienceImageName(experience: ExperienceFeedback) -> String {
		var imageName = "testImage"
		
		if experience == .starterKit {
			imageName = "journey"
		} else if experience == .continueLearning {
			imageName = "explore"
		} else {
			imageName = "advancing"
		}
		
		return imageName
	}
	
	@ViewBuilder
	private func displayExperience(experience: ExperienceFeedback) -> some View {
		GeometryReader { (proxy: GeometryProxy) in
			HStack {
				Spacer()
				VStack(spacing:0) {
					VStack {
						HStack {
							Spacer()
							Image(getExperienceImageName(experience: experience))
								.resizable()
								.scaledToFit()
								.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(10))
							Spacer()
						}
					}
					.frame(minHeight:proxy.size.height*0.55)
					.background(
						RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
							.fill(Color("Dynamic/MainBrown"))
					)
					VStack {
						HStack {
							Spacer()
							VStack {
								Text(experience.getTitle().uppercased())
									.font(.headline)
									.foregroundColor(Color("Dynamic/MainBrown+6"))
								Divider()
								Text(experience.getLabel())
									.foregroundColor(Color("Dynamic/MainBrown+6"))
									.multilineTextAlignment(.center)
									//.font(.headline)
									//.foregroundColor(Color("Dynamic/Shadow"))
									
							}
							Spacer()
						}.padding(EdgeInsets(top: 30, leading: 15, bottom: 30, trailing: 15))
					}
					.background(
						RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 28)
							.fill(Color("Dynamic/LightGray"))
					)
				}
				.background(
					RoundedRectangle(cornerRadius: CGFloat(28))
						.foregroundColor(Color("Dynamic/Shadow"))
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
				)
				.frame(width: proxy.size.width*0.85, height: proxy.size.height*0.9)
				Spacer()
			}
		}
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
			tipContent = AnyView(TipContentMakerView(showStepTip: $showStepTip, hideTipValue: Tip.wizardExperience.rawValue, tipMainContent: AnyView(tipHere(choise: selectedFeedback))))
			showStepTip = true
		} else {
			goToNextStep()
		}
	}
	
	@ViewBuilder
	private func tipHere(choise: ExperienceFeedback) -> some View {
		VStack {
			Text("\(choise.getLabel())")
			.font(.headline)
			.modifier(StepExplainingText())
			
			if choise == ExperienceFeedback.continueLearning {
				Text("One step at a time, and you are learning well.\n\nHowever, sometimes you are just wondering what's ahead of you. Maybe you want to take on some challenges.\n\nThere is no time to hesitate. Let's go!")
					.modifier(StepExplainingText())
			} else if choise == ExperienceFeedback.experienced {
				Text("You are skillfull. You can navigate new pieces faster.\n\nThis step will take you to explore over 400 pieces organized by different techniques in our repositories. Enjoy!")
					.modifier(StepExplainingText())
			} else {
				Text("Scorewind has over 1000 lessons organized by their difficulties. This step will show you the lessons yet completed ahead of you.")
					.modifier(StepExplainingText())
			}
		}.background {
			RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("AppYellow"))
			.frame(width: screenSize.width*0.9)}
	}
  
	
}

struct WizardExperienceView_Previews: PreviewProvider {
	@State static var tab = "THome"
	@State static var step:Page = .wizardChooseInstrument
	static var previews: some View {
		WizardExperienceView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}










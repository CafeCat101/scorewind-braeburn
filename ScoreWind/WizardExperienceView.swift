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
			
			//this is the vertical scroll version
			/*
			VStack {
				GeometryReader { (proxy: GeometryProxy) in
					ScrollView(.vertical) {
						HStack {
							Spacer()
							VStack(spacing:0) {
								VStack {
									HStack {
										Spacer()
										Image("testImage")
											.resizable()
											.scaledToFit()
										Spacer()
									}
								}
								.background(
									RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
										.fill(Color("test"))
								)
								VStack {
									HStack {
										Spacer()
										Text(ExperienceFeedback.starterKit.getLabel())
											.font(.headline)
											.foregroundColor(Color("Dynamic/Shadow"))
											.padding(EdgeInsets(top: 30, leading: 25, bottom: 30, trailing: 25))
										Spacer()
									}
								}
								.background(
									RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 28)
										.fill(Color("Dynamic/LightGray"))
								)
							}
							.frame(width: proxy.size.width*0.85, height: proxy.size.height*0.6)
							.background(
								RoundedRectangle(cornerRadius: CGFloat(28))
									.foregroundColor(Color("Dynamic/Shadow"))
									.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							)
							.padding(.top,10)
							Spacer()
						}
						HStack {
							Spacer()
							VStack(spacing:0) {
								VStack {
									HStack {
										Spacer()
										Image("testImage")
											.resizable()
											.scaledToFit()
										Spacer()
									}
								}
								.background(
									RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
										.fill(Color("test"))
								)
								VStack {
									HStack {
										Spacer()
										Text(ExperienceFeedback.starterKit.getLabel())
											.font(.headline)
											.foregroundColor(Color("Dynamic/Shadow"))
											.padding(EdgeInsets(top: 30, leading: 25, bottom: 30, trailing: 25))
										Spacer()
									}
								}
								.background(
									RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 28)
										.fill(Color("Dynamic/LightGray"))
								)
							}
							.frame(width: proxy.size.width*0.85, height: proxy.size.height*0.6)
							.background(
								RoundedRectangle(cornerRadius: CGFloat(28))
									.foregroundColor(Color("Dynamic/Shadow"))
									.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							)
							.padding(.top,10)
							Spacer()
						}
						HStack {
							Spacer()
							VStack(spacing:0) {
								VStack {
									HStack {
										Spacer()
										Image("testImage")
											.resizable()
											.scaledToFit()
										Spacer()
									}
								}
								.background(
									RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
										.fill(Color("test"))
								)
								VStack {
									HStack {
										Spacer()
										Text(ExperienceFeedback.starterKit.getLabel())
											.font(.headline)
											.foregroundColor(Color("Dynamic/Shadow"))
											.padding(EdgeInsets(top: 30, leading: 25, bottom: 30, trailing: 25))
										Spacer()
									}
								}
								.background(
									RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 28)
										.fill(Color("Dynamic/LightGray"))
								)
							}
							.frame(width: proxy.size.width*0.85, height: proxy.size.height*0.6)
							.background(
								RoundedRectangle(cornerRadius: CGFloat(28))
									.foregroundColor(Color("Dynamic/Shadow"))
									.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							)
							.padding(.top,10)
							Spacer()
						}
						Spacer().frame(height: 30)
					}
				}
			}
			 */
			
			//this is the classic tab view version
			
			VStack {
				GeometryReader { (proxy: GeometryProxy) in
					TabView {
						VStack(spacing:0) {
							VStack {
								HStack {
									Spacer()
									Image("testImage")
										.resizable()
										.scaledToFit()
									Spacer()
								}
							}
							.background(
								RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
									.fill(Color("test"))
							)
							VStack {
								HStack {
									Spacer()
									Text(ExperienceFeedback.starterKit.getLabel())
										.font(.headline)
										.foregroundColor(Color("Dynamic/Shadow"))
										.padding(EdgeInsets(top: 30, leading: 25, bottom: 30, trailing: 25))
									Spacer()
								}
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
						
						VStack(spacing:0) {
							VStack {
								HStack {
									Spacer()
									Image("testImage")
										.resizable()
										.scaledToFit()
									Spacer()
								}
							}
							.background(
								RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
									.fill(Color("test"))
							)
							VStack {
								HStack {
									Spacer()
									Text(ExperienceFeedback.starterKit.getLabel())
										.font(.headline)
										.foregroundColor(Color("Dynamic/Shadow"))
										.padding(EdgeInsets(top: 30, leading: 25, bottom: 30, trailing: 25))
									Spacer()
								}
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
						
						VStack(spacing:0) {
							VStack {
								HStack {
									Spacer()
									Image("testImage")
										.resizable()
										.scaledToFit()
									Spacer()
								}
							}
							.background(
								RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
									.fill(Color("test"))
							)
							VStack {
								HStack {
									Spacer()
									Text(ExperienceFeedback.starterKit.getLabel())
										.font(.headline)
										.foregroundColor(Color("Dynamic/Shadow"))
										.padding(EdgeInsets(top: 30, leading: 25, bottom: 30, trailing: 25))
									Spacer()
								}
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
					}
					.tabViewStyle(.page)
					/*.background(
						RoundedRectangle(cornerRadius: CGFloat(28))
							.foregroundColor(Color("Dynamic/LightGray"))
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					)*/
					
				}
			}.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.7)
			Spacer()
			
			//this is the horizontal scroll version
			/*
			VStack {
				GeometryReader { (proxy: GeometryProxy) in
					ScrollView(.horizontal) {
						HStack {
							VStack {
								Spacer()
								VStack(spacing:0) {
									VStack {
										HStack {
											Spacer()
											Image("testImage")
												.resizable()
												.scaledToFit()
											Spacer()
										}
									}
									.background(
										RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
											.fill(Color("test"))
									)
									VStack {
										HStack {
											Spacer()
											Text(ExperienceFeedback.starterKit.getLabel())
												.font(.headline)
												.foregroundColor(Color("Dynamic/Shadow"))
												.padding(EdgeInsets(top: 30, leading: 25, bottom: 30, trailing: 25))
											Spacer()
										}
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
								.frame(width: proxy.size.width*0.85, height: proxy.size.height*0.8)
								.padding(.leading, 35)
								Spacer()
							}
							
							VStack {
								Spacer()
								VStack(spacing:0) {
									VStack {
										HStack {
											Spacer()
											Image("testImage")
												.resizable()
												.scaledToFit()
											Spacer()
										}
									}
									.background(
										RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
											.fill(Color("test"))
									)
									VStack {
										HStack {
											Spacer()
											Text(ExperienceFeedback.starterKit.getLabel())
												.font(.headline)
												.foregroundColor(Color("Dynamic/Shadow"))
												.padding(EdgeInsets(top: 30, leading: 25, bottom: 30, trailing: 25))
											Spacer()
										}
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
								.frame(width: proxy.size.width*0.85, height: proxy.size.height*0.8)
								Spacer()
							}
							
							VStack {
								Spacer()
								VStack(spacing:0) {
									VStack {
										HStack {
											Spacer()
											Image("testImage")
												.resizable()
												.scaledToFit()
											Spacer()
										}
									}
									.background(
										RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
											.fill(Color("test"))
									)
									VStack {
										HStack {
											Spacer()
											Text(ExperienceFeedback.starterKit.getLabel())
												.font(.headline)
												.foregroundColor(Color("Dynamic/Shadow"))
												.padding(EdgeInsets(top: 30, leading: 25, bottom: 30, trailing: 25))
											Spacer()
										}
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
								.frame(width: proxy.size.width*0.85, height: proxy.size.height*0.8)
								.padding(.trailing, 35)
								Spacer()
							}
						}
						
					}.frame(height: proxy.size.height)
				}
			}.frame(height: UIScreen.main.bounds.size.height*0.7)
			*/
			
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










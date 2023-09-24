//
//  WizardExperienceView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/23.
//

import SwiftUI

struct WizardExperienceView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	//@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	//let screenSize: CGRect = UIScreen.main.bounds
	@State private var showStepTip = false
	@State private var tipContent:AnyView = AnyView(Text("Tip"))
	@State private var userDefaults = UserDefaults.standard
	let feedback = UIImpactFeedbackGenerator(style: .heavy)
	@Environment(\.horizontalSizeClass) var horizontalSize
	@Environment(\.verticalSizeClass) var verticalSize
	@State private var selectedExpTab = ExperienceFeedback.starterKit.rawValue
	@Binding var showPathFinder:Bool
	@Binding var showStarterPath:Bool
	//@Environment(\.mainWindowSize) var windowSize
	//@State private var screenSize = UIScreen.main.bounds.size
	
	var body: some View {
		VStack {
			Spacer()
			
			HStack {
				Spacer()
				Text("Select an experience")
					.font(verticalSize == .regular ? .title : .title2)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.bold()
				Spacer()
			}
			
			Spacer()
			
			VStack {
				TabView {
					displayExperience(experience: .starterKit)
						.onTapGesture {
							print("choose \(ExperienceFeedback.starterKit.rawValue)")
							feedback.impactOccurred()
							gotFeedback(selectedFeedback: .starterKit)
						}
					displayExperience(experience: .continueLearning)
						.onTapGesture {
							print("choose \(ExperienceFeedback.continueLearning.rawValue)")
							feedback.impactOccurred()
							gotFeedback(selectedFeedback: .continueLearning)
						}
					displayExperience(experience: .experienced)
						.onTapGesture {
							print("choose \(ExperienceFeedback.experienced.rawValue)")
							feedback.impactOccurred()
							gotFeedback(selectedFeedback: .experienced)
						}
				}
				.tabViewStyle(.page)
			}
			.frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.width*0.8, height: verticalSize == .regular ? UIScreen.main.bounds.size.height*0.66 : UIScreen.main.bounds.size.height*0.5)
			.onChange(of: verticalSize, perform: { info in
				print("info \(String(describing: info))")
				print("info w:\(UIScreen.main.bounds.size.width) / h:\(UIScreen.main.bounds.size.height)")
				selectedExpTab = ExperienceFeedback.starterKit.rawValue
			})
			
			Spacer()
		}
		.onAppear(perform: {
			//print("[debug] WizardExperienceView.onAppear")
			//print("[debug] WizardExperienceView.onAppear, userDefaults hideTips \(userDefaults.object(forKey: "hideTips") as? [String] ?? [])")
		})
		.fullScreenCover(isPresented: $showStepTip, onDismiss: {
			
		}, content: {
			TipTransparentModalView(showStepTip: $showStepTip, tipContent: $tipContent)
		})
	}
	
	private func getExperienceImageName(experience: ExperienceFeedback) -> String {
		var imageName = "journey"
		
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
					if verticalSize == .regular && horizontalSize == .compact {
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
							}
							.padding(EdgeInsets(top: 30, leading: 15, bottom: 30, trailing: 15))
							.overlay(alignment:.topTrailing ,content: {
								Label("help", systemImage: "questionmark.circle.fill")
									.font(.headline)
									.labelStyle(.iconOnly)
									.foregroundColor(Color("Dynamic/MainBrown+6"))
									.padding([.top,.trailing], 10)
									.onTapGesture {
										tipContent = AnyView(TipContentMakerView(showStepTip: $showStepTip, hideTipValue: Tip.wizardExperience.rawValue, tipMainContent: AnyView(tipHere(choise: experience)), allowHideForever: true))
										showStepTip = true
									}
							})
						}
						.background(
							RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 28)
								.fill(Color("Dynamic/LightGray"))
						)
						 
					} else {
						HStack {
							VStack {
								HStack {
									Spacer()
									Image(getExperienceImageName(experience: experience))
										.resizable()
										.scaledToFit()
										.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(10))
										.padding([.top,.bottom], 8)
									Spacer()
								}
							}
							.frame(minHeight:proxy.size.height*0.55)
							.background(
								RoundedCornersShape(corners: [.topLeft, .bottomLeft], radius: 28)
									.fill(Color("Dynamic/MainBrown"))
							)
							VStack {
								VStack {
									Spacer()
									Text(experience.getTitle().uppercased())
										.font(.headline)
										.foregroundColor(Color("Dynamic/MainBrown+6"))
									Divider().padding([.leading,.trailing], 15)
									Text(experience.getLabel())
										.foregroundColor(Color("Dynamic/MainBrown+6"))
										.multilineTextAlignment(.center)
									Spacer()
								}
								.overlay(alignment:.topTrailing ,content: {
									Label("help", systemImage: "questionmark.circle.fill")
										.font(.headline)
										.labelStyle(.iconOnly)
										.foregroundColor(Color("Dynamic/MainBrown+6"))
										.padding(.top, 15)
										.padding(.trailing, 20)
										.onTapGesture {
											tipContent = AnyView(TipContentMakerView(showStepTip: $showStepTip, hideTipValue: Tip.wizardExperience.rawValue, tipMainContent: AnyView(tipHere(choise: experience)), allowHideForever: true))
											showStepTip = true
										}
								})
							}
							.background(
								RoundedCornersShape(corners: [.bottomRight, .topRight], radius: 28)
									.fill(Color("Dynamic/LightGray"))
							)
						}
					}
					
					
				}
				.background(
					RoundedRectangle(cornerRadius: CGFloat(28))
						.foregroundColor(Color("Dynamic/Shadow"))
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
				)
				.frame(width: proxy.size.width*0.85, height: proxy.size.height - 50)// original value:55
				.padding(.top, 8)
				Spacer()
			}
		}
	}

	private func goToNextStep() {
		let nextStepPage = scorewindData.createRecommendation(studentData: studentData)
		
		if nextStepPage != .wizardChooseInstrument {
			stepName = nextStepPage
			studentData.wizardStepNames.append(nextStepPage)
			if stepName == .wizardResult {
				showStarterPath = false
				showPathFinder = false
			}
		}
	}
	
	private func gotFeedback(selectedFeedback: ExperienceFeedback) {
		studentData.updateExperience(experience: selectedFeedback)
		goToNextStep()
		
		if scorewindData.isPublicUserVersion {
			if selectedFeedback == ExperienceFeedback.starterKit {
				//studentData.updateUsageActionCount(actionName: .selectJourney)
				studentData.updateLogs(title: .selectJourney, content: "")
			} else if selectedFeedback == ExperienceFeedback.continueLearning {
				//studentData.updateUsageActionCount(actionName: .selectExplore)
				studentData.updateLogs(title: .selectExplore, content: "")
			} else if selectedFeedback == ExperienceFeedback.experienced {
				//studentData.updateUsageActionCount(actionName: .selectAdvancing)
				studentData.updateLogs(title: .selectAdvancing, content: "")
			}
		}
	}
	
	@ViewBuilder
	private func tipHere(choise: ExperienceFeedback) -> some View {
		VStack(spacing:0) {
			/*Label("tip", systemImage: "lightbulb")
				.labelStyle(.iconOnly)
				.font(.largeTitle)
				.foregroundColor(Color("AppYellow"))
				.shadow(color: Color("Dynamic/ShadowReverse"),radius: CGFloat(10))
				.padding(.bottom, 15)*/
			
			HStack(spacing:0) {
				Label("tip", systemImage: "lightbulb")
					.labelStyle(.iconOnly)
					.font(.title2)
					.foregroundColor(Color("MainBrown+6"))
					.shadow(color: Color("Dynamic/ShadowReverse"),radius: CGFloat(10))
					.padding(EdgeInsets(top: 8, leading: 15, bottom: 4, trailing: 15))
					.background(
						RoundedCornersShape(corners: verticalSize == .regular ? [.topLeft, .topRight] : [.allCorners], radius: 10)
							.fill(Color("AppYellow"))
							.opacity(0.90)
					)
				Spacer()
			}.padding(.leading, 28)
			
			VStack(spacing:0) {
				ScrollView {
					VStack(alignment: .leading) {
						Text("\(choise.getLabel())")
						.font(.headline)
						.padding(.bottom, 15)
						
						if choise == ExperienceFeedback.continueLearning {
							Text("From courses designed with a step-by-step learning style, ScoreWind will show you the next 10 uncompleted lessons based on your feedback and the lessons you've completed.")
							Divider().padding([.top,.bottom], 20)
							Text("Maybe you wonder what the challenges are out there. There is no time to hesitate. Let's go!")
						} else if choise == ExperienceFeedback.experienced {
							Text("According to your answers and completed lessons, ScoreWind will show you the next 10 uncompleted lessons from the courses designed with a fast-paced learning style.")
							Divider().padding([.top,.bottom], 20)
							Text("You are skillful. You can navigate new pieces faster.\n\nCome and explore over 400 pieces organized by different techniques in our repositories. Enjoy!")
						} else {
							Text("Ask ScoreWind to show you the next 10 uncompleted lessons.")
							Divider().padding([.top,.bottom], 20)
							Text("Scorewind has over 1000 lessons organized by their difficulties. This step will show you the lessons yet completed ahead of you.")
						}
					}
					.foregroundColor(Color("MainBrown+6"))
					.padding(EdgeInsets(top: 18, leading: 40, bottom: 18, trailing: 40))
					
				}
			}
			.background(
				RoundedRectangle(cornerRadius: CGFloat(10))
					.foregroundColor(Color("AppYellow"))
					.shadow(color: Color("Dynamic/ShadowLight"),radius: CGFloat(7))
					.opacity(0.90)
			)
			.padding([.leading,.trailing],15)
		}
		
		
		/*.background {
			RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("AppYellow"))
			.frame(width: UIScreen.main.bounds.size.width*0.9)
		}*/
	}

}

struct WizardExperienceView_Previews: PreviewProvider {
	@State static var tab = "THome"
	@State static var step:Page = .wizardExperience
	static var previews: some View {
		VStack {
			WizardExperienceView(stepName: $step, studentData: StudentData(), showPathFinder: .constant(true), showStarterPath: .constant(false))
				.environmentObject(ScorewindData())
				.environment(\.colorScheme, .light)
			
			WizardExperienceView(stepName: $step, studentData: StudentData(), showPathFinder: .constant(true), showStarterPath: .constant(false)).environmentObject(ScorewindData())
				.environment(\.colorScheme, .light)
				.previewInterfaceOrientation(InterfaceOrientation.landscapeLeft)
				.previewDisplayName("Light Landscape")
			
			WizardExperienceView(stepName: $step, studentData: StudentData(), showPathFinder: .constant(true), showStarterPath: .constant(false)).environmentObject(ScorewindData())
			.environment(\.colorScheme, .dark)
		}
		
	}
}










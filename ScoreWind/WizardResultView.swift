//
//  WizardResult.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/16.
//

import SwiftUI

struct WizardResultView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	@State private var dummyLearningPath:[String] = ["Course1","Course2","Course3"]
	@State private var showMeMore:Bool = false
	@State private var showTopLessonDescription:Bool = true
	@State private var showStepTip = false
	@State private var tipContent:AnyView = AnyView(Text("Tip"))
	@State private var userDefaults = UserDefaults.standard
	@Binding var showLessonView:Bool
	@Binding var showStore: Bool
	@State private var showTopDivider = false
	@State private var offset = CGFloat.zero
	@State private var animate = false
	@Environment(\.verticalSizeClass) var verticalSize
	@Environment(\.colorScheme) var uiColor
	
	var body: some View {
		VStack(spacing:0) {
			if showTopDivider {
				Divider()
			}
			
			HStack(spacing:0) {
				if verticalSize != .regular {
					displayContentHeader()
						.frame(width: UIScreen.main.bounds.size.width*0.35)
				}
				
				ScrollView(.vertical) {
					VStack {
						if verticalSize == .regular {
							displayContentHeader()
						}
						
						displayContent(frameSize: verticalSize == .regular ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.width*0.55)
					}
					.padding([.leading,.trailing], 15)
					.background(GeometryReader {
						Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .named("scroll")).origin.y)
					})
					.onPreferenceChange(ViewOffsetKey.self) {
						//print("offset >> \($0)")
						if $0 >= 10 {
							showTopDivider = true
						} else {
							showTopDivider = false
						}
					}
				}
				.onDisappear(perform: {
					animate = false
				})
				.onAppear(perform: {
					//print("[debug] WizardResultView, onAppear, icloud wizardResult \(studentData.getWizardResult())")
					print("[debug] WizardResultView, onAppear, local wizardResult \(studentData.wizardResult)")
					print("[debug] WizardResultView, onAppear, studentData.wizardRange.count \(studentData.wizardRange.count)")
					print("[debug] WizardResultView, onAppear, studentData.getWizardResult().learningPath.count \(studentData.getWizardResult().learningPath.count)")
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
						withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
							animate.toggle()
						}
					}
					
					//:: for Preview only
					if scorewindData.wizardPickedCourse.id == 0 && scorewindData.wizardPickedLesson.id == 0 {
						demoData()
					}
					//:: ================== ::

					if scorewindData.wizardPickedCourse.id > 0 && scorewindData.wizardPickedLesson.id > 0 && showStore == false {
						handleTip()
					}
				})
				.fullScreenCover(isPresented: $showStepTip, content: {
					TipTransparentModalView(showStepTip: $showStepTip, tipContent: $tipContent)
				})
				.coordinateSpace(name: "scroll")
			}
		}
	}
	
	private func getIconTitleName() -> String {
		if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
			return "iconGuitar"
		} else {
			return "iconViolin"
		}
	}
	
	private func handleTip() {
		let hideTips:[String] = userDefaults.object(forKey: "hideTips") as? [String] ?? []
		if hideTips.contains(Tip.wizardResult.rawValue) == false {
			tipContent = AnyView(TipContentMakerView(showStepTip: $showStepTip, hideTipValue: Tip.wizardResult.rawValue, tipMainContent: AnyView(tipHere())))
			if studentData.getExperience() == ExperienceFeedback.starterKit.rawValue {
				//:: delay tip a little because starterkit doesn't have steps
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					showStepTip = true
				}
			} else {
				showStepTip = true
			}
		}
	}
	
	private func demoData() {
		var demoResult = WizardResult()
		var learningPathItem1 = WizardLearningPathItem()
		learningPathItem1.courseID = 93950
		learningPathItem1.courseTitle = "G101.1 &#8211; Introduction to Guitar"
		learningPathItem1.lessonID = 90696
		learningPathItem1.lessonTitle = "G101.1.1 &#8211; The Parts of the Instrument"
		learningPathItem1.startHere = true
		learningPathItem1.showCourseTitle = true
		learningPathItem1.friendlyID = 1
		
		var learningPathItem2 = WizardLearningPathItem()
		learningPathItem2.courseID = 93950
		learningPathItem2.courseTitle = "G101.1 &#8211; Introduction to Guitar"
		learningPathItem2.lessonID = 90694
		learningPathItem2.lessonTitle = "G101.1.2 &#8211; The Playing Posture (intro)"
		learningPathItem2.startHere = false
		learningPathItem2.showCourseTitle = false
		learningPathItem2.friendlyID = 2
		
		var learningPathItem3 = WizardLearningPathItem()
		learningPathItem3.courseID = 93950
		learningPathItem3.courseTitle = "G101.1 &#8211; Introduction to Guitar"
		learningPathItem3.lessonID = 90692
		learningPathItem3.lessonTitle = "G101.1.3 &#8211; Nail Maintenance"
		learningPathItem3.startHere = false
		learningPathItem3.showCourseTitle = false
		learningPathItem3.friendlyID = 3

		scorewindData.wizardPickedCourse = scorewindData.allCourses.first(where: {$0.id == learningPathItem1.courseID}) ?? Course()
		scorewindData.wizardPickedLesson = scorewindData.wizardPickedCourse.lessons.first(where: {$0.id == learningPathItem1.lessonID}) ?? Lesson()
		scorewindData.wizardPickedTimestamps = (scorewindData.allTimestamps.first(where: {$0.id == learningPathItem1.lessonID})?.lessons.first(where: {$0.id == learningPathItem1.lessonID})!.timestamps) ?? []
		
		demoResult.learningPath = [learningPathItem1, learningPathItem2, learningPathItem3]
		demoResult.resultExplaination = "Looks like you found a lesson. Go ahead!"
		studentData.wizardResult = demoResult
	}
	
	@ViewBuilder
	private func tipHere() -> some View {
		VStack {
			Text("The place to discover new lessons!")
			.font(.headline)
			.modifier(StepExplainingText())
			VStack(alignment:.leading) {
				Text("You can always ask ScoreWind again by click the \(Image(systemName: "goforward")) button in the top left corner.")
					.modifier(TipExplainingParagraph())
				Text("Your last learning path ScoreWind found will be saved here, you can revisit it whenever you like.")
					.modifier(TipExplainingParagraph())
			}.padding([.bottom], 18)
		}.background {
			RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("AppYellow"))
			.frame(width: UIScreen.main.bounds.width*0.9)}
	}
	
	@ViewBuilder
	private func displayContentHeader() -> some View {
		VStack(alignment: .center) {
			ZStack {
				Image("resultFound")
					.resizable()
					.scaledToFit()
					.shadow(color: uiColor == .light ? Color("Dynamic/ShadowReverse") : Color("Dynamic/DarkPurple"), radius: CGFloat(10))
					//.padding(.top,18)
			}
			.padding(.top,18)
			//.padding(EdgeInsets(top: 10, leading: 0, bottom: 8, trailing: 0))
			.frame(maxHeight: 120)
			.offset(x: animate ? -7 : 0-UIScreen.main.bounds.size.width)
			
			Text(studentData.wizardResult.resultTitle)
				.font(verticalSize == .regular ? .title : .title2)
				.foregroundColor(Color("Dynamic/MainBrown+6"))
				.bold()
			
			Spacer()
			Text(studentData.wizardResult.resultExplaination)
			Spacer()
		}
		
		
	}
	
	@ViewBuilder
	private func displayContent(frameSize: CGFloat) -> some View {
		//:: Lesson box title
		/*HStack {
			HStack {
				HStack {
					VStack {
						Image(getIconTitleName())
							.resizable()
							.scaledToFit()
							.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
					}
					.frame(maxHeight: 33)
					Text("The Lesson")
						.bold()
						.foregroundColor(Color("Dynamic/DarkPurple"))
						.font(.headline)
						.frame(maxHeight: 33)
					Spacer()
				}
				.padding(EdgeInsets(top: 10, leading: 0, bottom: 33, trailing: 0))
			}
			.padding(.leading, 15)
			.frame(width: frameSize*0.7)
			//.frame(width: UIScreen.main.bounds.size.width*0.7)
			.background(
				RoundedCornersShape(corners: verticalSize == .regular ? [.topRight, .bottomRight] : [.allCorners], radius: 17)
					.fill(Color("Dynamic/MainBrown"))
					.opacity(0.25)
				
			)
			.offset(x: -15, y:33 )
			Spacer()
		}*/
		
		//:: Lesson box
		/*VStack(spacing:0) {
			VStack(alignment: .leading) {
				HStack {
					Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedLesson.title))
						.bold()
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.font(.title2)
					Spacer()
					Label("Go to lesson", systemImage: "arrow.right.circle.fill")
						.labelStyle(.iconOnly)
						.font(.title2)
						.foregroundColor(Color("Dynamic/MainGreen"))
				}
				if showTopLessonDescription {
					Divider()
					Text(scorewindData.wizardPickedLesson.description)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
				}
				
			}.padding(15)
		}
		.background(
			RoundedRectangle(cornerRadius: CGFloat(17))
				.foregroundColor(Color("Dynamic/LightGray"))
				.opacity(0.85)
				.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
		)
		.onTapGesture {
			print("[debug] WizardResultView, lesson.onTapGesture")
			scorewindData.currentCourse = scorewindData.wizardPickedCourse
			scorewindData.currentLesson = scorewindData.wizardPickedLesson
			scorewindData.setCurrentTimestampRecs()
			scorewindData.lastPlaybackTime = 0.0
			self.selectedTab = "TCourse"
			showLessonView = true
			scorewindData.lessonChanged = true
		}*/
		
		/*Label(showMeMore ? "Hide details" : "Tell me more", systemImage: showMeMore ? "chevron.up" : "chevron.down")
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
			.padding(.top, 15)
			.padding(.bottom, showMeMore ? 0 : 50)
			.onTapGesture {
				showMeMore.toggle()
				if showTopLessonDescription == false {
					animate = false
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
						withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
							animate.toggle()
						}
					}
				}
				withAnimation(.linear(duration: 0.2)) {
					showTopLessonDescription.toggle()
				}
			}*/
		
		
		//Spacer()
		
		//if showMeMore {
			//::course box title
			/*HStack {
				HStack {
					HStack {
						VStack {
							Image(getIconTitleName())
								.resizable()
								.scaledToFit()
								.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
						}
						.frame(maxHeight: 33)
						Text("The Course")
							.bold()
							.foregroundColor(Color("Dynamic/DarkPurple"))
							.font(.headline)
							.frame(maxHeight: 33)
						Spacer()
					}
					.padding(EdgeInsets(top: 10, leading: 0, bottom: 33, trailing: 0))
				}
				.padding(.leading, 15)
				.frame(width: frameSize*0.7)
				.background(
					RoundedCornersShape(corners: verticalSize == .regular ? [.topRight, .bottomRight] : [.allCorners], radius: 17)
						.fill(Color("Dynamic/MainBrown"))
						.opacity(0.25)
				)
				.offset(x: -15, y:33 )
				Spacer()
			}*/
			
			//:: course box content summary
			/*VStack(alignment: .center) {
				HStack {
					Spacer()
					Text("You may be interested to know that ").foregroundColor(Color("Dynamic/MainBrown+6"))+Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedLesson.title)).bold().foregroundColor(Color("Dynamic/MainBrown+6"))+Text(" is coming from this course, ").foregroundColor(Color("Dynamic/MainBrown+6"))+Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedCourse.title)).bold().foregroundColor(Color("Dynamic/MainBrown+6"))
					Spacer()
				}
				
			}
			.padding(EdgeInsets(top: 30, leading: 15, bottom: 30, trailing: 15))
			.background(
				RoundedRectangle(cornerRadius: CGFloat(17))
					.foregroundColor(Color("Dynamic/MainBrown"))
					.opacity(0.25)
			)*/
			
			//::course box
			/*VStack(spacing:0) {
				VStack(alignment: .leading) {
					HStack {
						Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedCourse.title))
							.bold()
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.font(.title2)
						Spacer()
						Label("Go to lesson", systemImage: "arrow.right.circle.fill")
							.labelStyle(.iconOnly)
							.font(.title2)
							.foregroundColor(Color("Dynamic/MainGreen"))
					}
				}.padding(15)
			}
			.background(
				RoundedRectangle(cornerRadius: CGFloat(17))
					//.foregroundColor(Color("Dynamic/LightGray"))
					.foregroundColor(Color("Dynamic/LightGreen"))
					.opacity(0.85)
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
			)
			.onTapGesture {
				scorewindData.currentCourse = scorewindData.wizardPickedCourse
				scorewindData.currentView = Page.course
				self.selectedTab = "TCourse"
				scorewindData.currentLesson = scorewindData.wizardPickedCourse.lessons[0]
				scorewindData.setCurrentTimestampRecs()
				//scorewindData.lastViewAtScore = true
				scorewindData.lastPlaybackTime = 0.0
				scorewindData.lessonChanged = true
			}*/
			
			//::learning path box title
			HStack {
				HStack {
					HStack {
						VStack {
							Image("iconLearningPath")
								.resizable()
								.scaledToFit()
								.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
						}
						.frame(maxHeight: 33)
						Text(studentData.wizardResult.learningPathTitle)
							.bold()
							.foregroundColor(Color("Dynamic/DarkPurple"))
							.font(.headline)
							.frame(maxHeight: 33)
						Spacer()
					}
					.padding(EdgeInsets(top: 10, leading: 0, bottom: 33, trailing: 0))
				}
				.padding(.leading, 15)
				.frame(width: frameSize*0.7)
				.background(
					RoundedCornersShape(corners: verticalSize == .regular ? [.topRight, .bottomRight] : [.allCorners], radius: 17)
						.fill(Color("Dynamic/MainBrown"))
						.opacity(0.25)
				)
				.offset(x: -15, y:33 )
				Spacer()
			}
			
			//:: learning path box content summary
			VStack(alignment: .center) {
				HStack {
					Spacer()
					Text(studentData.wizardResult.learningPathExplaination).foregroundColor(Color("Dynamic/MainBrown+6"))
					Spacer()
				}
				
			}
			.padding(EdgeInsets(top: 30, leading: 15, bottom: 30, trailing: 15))
			.background(
				RoundedRectangle(cornerRadius: CGFloat(17))
					.foregroundColor(Color("Dynamic/MainBrown"))
					.opacity(0.25)
			)
			
			WizardResultPathView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData, showLessonView: $showLessonView)
			
		Spacer().frame(minHeight: 50)
		//}
		
	}
	
	struct ViewOffsetKey: PreferenceKey {
			typealias Value = CGFloat
			static var defaultValue = CGFloat.zero
			static func reduce(value: inout Value, nextValue: () -> Value) {
					value += nextValue()
			}
	}
}



struct WizardResult_Previews: PreviewProvider {
	@State static var tab = "THome"
	@State static var step:Page = .wizardResult
	@StateObject static var studentData = StudentData()
	@StateObject static var scorewindData = ScorewindData()

	static var previews: some View {
		WizardResultView(selectedTab: $tab, stepName: $step, studentData: studentData, showLessonView: .constant(false), showStore: .constant(false)).environmentObject(scorewindData)
			.environment(\.colorScheme, .light)
			.background {
				Image("WelcomeViewBg")
			}
			.previewInterfaceOrientation(InterfaceOrientation.portrait)
			.previewDisplayName("Light Portrait")
		
		WizardResultView(selectedTab: $tab, stepName: $step, studentData: studentData, showLessonView: .constant(false), showStore: .constant(false)).environmentObject(scorewindData)
			.environment(\.colorScheme, .light)
			.background {
				Image("WelcomeViewBg")
			}
			.previewInterfaceOrientation(InterfaceOrientation.landscapeLeft)
			.previewDisplayName("Light LandscapeLeft")
		
		WizardResultView(selectedTab: $tab, stepName: $step, studentData: StudentData(), showLessonView: .constant(false), showStore: .constant(false)).environmentObject(ScorewindData())
			.environment(\.colorScheme, .dark)
			.background(
				Image("DarkPolygonBg2")
					.resizable()
					.aspectRatio(contentMode: .fill)
					.edgesIgnoringSafeArea(.all)
			)
	}
}

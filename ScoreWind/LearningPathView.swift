//
//  LearningPathView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/9/11.
//

import SwiftUI

struct LearningPathView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@EnvironmentObject var store: Store
	@Binding var selectedTab:String
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
	@Environment(\.colorScheme) var colorScheme
	@State private var showOtherCourses = false
	let transition = AnyTransition.asymmetric(insertion: .slide, removal: .scale).combined(with: .opacity)
	@State private var showNotification = false
	@State private var showSubscriptionNotice = false
	
	@State private var showDemoLesson = false
	
	var body: some View {
		VStack(spacing:0) {
			if showTopDivider {
				Divider()
			}
			
			HStack(spacing:0) {
				/*if verticalSize != .regular {
					displayContentHeader()
						.frame(width: UIScreen.main.bounds.size.width*0.35)
				}*/
				
				ScrollView(.vertical) {
					VStack(spacing:0){
						Text("Starter Path")
							.font(verticalSize == .regular ? .title : .title2)
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.bold()
							.padding([.bottom], 15)
						/*VStack{
							Spacer()
							/*Image("guitar")
								.resizable()
								.scaledToFit()
								.rotationEffect(Angle(degrees: 65))
								.frame(width:150)*/
							HStack {
								Spacer()
								Text("Know your Instrument")
									.foregroundColor(Color("Dynamic/MainBrown+6"))
									.bold()
									.padding([.top], 5)
									.font(.title2)
									.shadow(color: .white,radius: CGFloat(4))
								Spacer()
							}
							Spacer()
						}
						.frame(minHeight: 150)
						.background(
							RoundedRectangle(cornerRadius: CGFloat(17))
								.foregroundColor(Color("Dynamic/MainBrown"))
								.opacity(colorScheme == .light ? 0.25 : 0.08)
								.background(
									Image("guitar")
									.resizable()
									.scaledToFit()
									.rotationEffect(Angle(degrees: 65))
									.frame(width:150)
									.opacity(0.7)
								)
						)
						.padding([.leading,.trailing], 15)*/
						VStack{
							Spacer()
							Image("guitar")
								.resizable()
								.scaledToFit()
								.rotationEffect(Angle(degrees: 65))
								.frame(width:150)
							HStack {
								Spacer()
								Text("Know Your Instrument")
									.foregroundColor(Color("Dynamic/MainBrown+6"))
									.bold()
									.padding([.top], 5)
									.font(.title2)
									.shadow(color: .white,radius: CGFloat(4))
									.multilineTextAlignment(.center)
								Spacer()
							}
							Spacer()
						}
						.background(
							RoundedRectangle(cornerRadius: CGFloat(17))
								.foregroundColor(Color("Dynamic/MainBrown"))
								.opacity(colorScheme == .light ? 0.25 : 0.08)
						)
						.padding([.leading,.trailing], 15)

						HStack(spacing:0){
							VStack(alignment: .leading) {
								HStack {
									Text("Introduction to Guitar")
										.bold()
										.foregroundColor(Color("Dynamic/MainBrown+6"))
									Spacer()
									Label("Go to course", systemImage: "arrow.right.circle.fill")
										.labelStyle(.iconOnly)
										.font(.title2)
										.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
								}
								Text("Level1")
									.font(.caption)
									.bold()
								
								HStack {
									//Text("8 Lessons")
									Spacer()
									Text("25 min. and 7 sec.")
								}.padding([.top],5)
								
								viewLessonsMenu(lessonCount: 8)
							}
							.padding(EdgeInsets(top: 21, leading: 15, bottom: 21, trailing: 15))
							//.padding(15)
						}
						.background(
							RoundedRectangle(cornerRadius: CGFloat(17))
								.foregroundColor(Color("Dynamic/LightGreen"))
								.opacity(0.85)
								.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						)
						.padding(EdgeInsets(top: 4, leading: 15, bottom: 0, trailing: 15))
						//:::::::::::::::::::
						Rectangle()
							.foregroundColor(Color("Dynamic/MainGreen"))
							.opacity(colorScheme == .light ? 0.85 : 0.08)
							//.rotationEffect(Angle(degrees: 45))
							.frame(width:8, height:20)
							//.padding([.top,.bottom],-6)
						//:::::::::::::::::::
						Group {
							HStack(spacing:0){
								VStack(alignment: .leading) {
									HStack {
										Text("Play With Right Hand")
											.bold()
											.foregroundColor(Color("Dynamic/MainBrown+6"))
										Spacer()
										Label("Go to course", systemImage: "arrow.right.circle.fill")
											.labelStyle(.iconOnly)
											.font(.title2)
											.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
									}
									Text("Level 2")
										.font(.caption)
										.bold()
									HStack {
										//Text("5 Lessons")
										Spacer()
										Text("28 min. and 3 sec.")
									}.padding([.top],5)
									
									viewLessonsMenu(lessonCount: 5)
										.onTapGesture {
											showDemoLesson.toggle()
										}
								}
								.padding(EdgeInsets(top: 21, leading: 15, bottom: 21, trailing: 15))
								//.padding(15)
							}
							.background(
								RoundedRectangle(cornerRadius: CGFloat(17))
									.foregroundColor(Color("Dynamic/LightGreen"))
									.opacity(0.85)
									.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							)
							.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
							if showDemoLesson {
								Group{
									HStack(spacing:0){
										Spacer()
										VStack(spacing:0){
											demoLessonItem()
												.padding([.top],5)
											Rectangle()
												.fill(Color("Dynamic/LightGray"))
												.opacity(0.85)
												.frame(width:8, height:20)
											demoLessonItem()
											Rectangle()
												.fill(Color("Dynamic/LightGray"))
												.opacity(0.85)
												.frame(width:8, height:20)
											demoLessonItem()
										}
									}
								}
							}
							
							//:::::::::::::::::::
							Rectangle()
								.foregroundColor(Color("Dynamic/MainGreen"))
								.opacity(colorScheme == .light ? 0.85 : 0.08)
								//.rotationEffect(Angle(degrees: 45))
								.frame(width:8, height:20)
								//.padding([.top,.bottom],-6)
							//:::::::::::::::::::
						}
						
						HStack(spacing:0){
							VStack(alignment: .leading) {
								HStack {
									Text("Play With Left Hand")
										.bold()
										.foregroundColor(Color("Dynamic/MainBrown+6"))
									Spacer()
									Label("Go to course", systemImage: "arrow.right.circle.fill")
										.labelStyle(.iconOnly)
										.font(.title2)
										.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
								}
								Text("Level3")
									.font(.caption)
									.bold()
								HStack {
									//Text("5 Lessons")
									Spacer()
									Text("28 min. and 3 sec.")
								}.padding([.top],5)
								
								viewLessonsMenu(lessonCount: 9)
							}
							.padding(EdgeInsets(top: 21, leading: 15, bottom: 21, trailing: 15))
							//.padding(15)
						}
						.background(
							RoundedRectangle(cornerRadius: CGFloat(17))
								.foregroundColor(Color("Dynamic/LightGreen"))
								.opacity(0.85)
								.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						)
						.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
						//:::::::::::::::::::
						Rectangle()
							.foregroundColor(Color("Dynamic/MainGreen"))
							.opacity(colorScheme == .light ? 0.85 : 0.08)
							.frame(width:8, height:20)
						//:::::::::::::::::::
						VStack{
							Spacer()
							Image("guitar")
								.resizable()
								.scaledToFit()
								.rotationEffect(Angle(degrees: 65))
								.frame(width:150)
							HStack {
								Spacer()
								Text("Make Sounds and Learn How to Read Notes")
									.foregroundColor(Color("Dynamic/MainBrown+6"))
									.bold()
									.padding([.top], 5)
									.font(.title2)
									.shadow(color: .white,radius: CGFloat(4))
									.multilineTextAlignment(.center)
								Spacer()
							}
							Spacer()
						}
						.background(
							RoundedRectangle(cornerRadius: CGFloat(17))
								.foregroundColor(Color("Dynamic/MainBrown"))
								.opacity(colorScheme == .light ? 0.25 : 0.08)
						)
						.padding([.leading,.trailing], 15)
						HStack(spacing:0){
							VStack(alignment: .leading) {
								HStack {
									Text("The Strings' Note Names and Numbers - Trebles With i,m,a")
										.bold()
										.foregroundColor(Color("Dynamic/MainBrown+6"))
									Spacer()
									Label("Go to course", systemImage: "arrow.right.circle.fill")
										.labelStyle(.iconOnly)
										.font(.title2)
										.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
								}
								Text("Level 4")
									.font(.caption)
									.bold()
								HStack {
									//Text("5 Lessons")
									Spacer()
									Text("35 min. and 18 sec.")
								}.padding([.top],5)
								viewLessonsMenu(lessonCount: 14)
							}
							.padding(EdgeInsets(top: 21, leading: 15, bottom: 21, trailing: 15))
							//.padding(15)
						}
						.background(
							RoundedRectangle(cornerRadius: CGFloat(17))
								.foregroundColor(Color("Dynamic/LightGreen"))
								.opacity(0.85)
								.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						)
						.padding(EdgeInsets(top: 4, leading: 15, bottom: 0, trailing: 15))
						//:::::::::::::::::::
						Rectangle()
							.foregroundColor(Color("Dynamic/MainGreen"))
							.opacity(colorScheme == .light ? 0.85 : 0.08)
							.frame(width:8, height:20)
						//:::::::::::::::::::
					}
					.padding([.leading,.trailing], 15)
					.background(GeometryReader {
						Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .named("scroll")).origin.y)
					})
					.onPreferenceChange(ViewOffsetKey.self) {
						//print("offset >> \($0)")
						if $0 >= 10 {
							withAnimation {
								showTopDivider = true
							}
						} else {
							withAnimation {
								showTopDivider = false
							}
						}
					}
				}
				.onDisappear(perform: {
					animate = false
				})
				.onAppear(perform: {
					//print("[debug] WizardResultView, onAppear, local wizardResult \(studentData.wizardResult)")
					//print("[debug] WizardResultView, onAppear, studentData.wizardRange.count \(studentData.wizardRange.count)")
					//print("[debug] WizardResultView, onAppear, studentData.getWizardResult().learningPath.count \(studentData.getWizardResult().learningPath.count)")
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
						withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8).speed(0.3)) {
							animate.toggle()
						}
					}
					
					if scorewindData.wizardPickedCourse.id > 0 && scorewindData.wizardPickedLesson.id > 0 && showStore == false {
						//handleTip()
					}
					
					if scorewindData.isPublicUserVersion {
						//studentData.updateLogs(title: .viewLearningPath, content: viewLearningPathLogContent())
					}
				})
				.fullScreenCover(isPresented: $showStepTip, onDismiss: {
					if (store.enablePurchase == false || store.couponState == .valid || store.offerIntroduction == false) == false {
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
							withAnimation(Animation.spring(response: 0.15, dampingFraction: 0.4, blendDuration: 0.4).speed(0.3)) {
								if showSubscriptionNotice == false && store.validateSubscriptionNoticeCount() {
									showSubscriptionNotice = true
								}
							}
						}
					}
				},content: {
					TipTransparentModalView(showStepTip: $showStepTip, tipContent: $tipContent)
				})
				.coordinateSpace(name: "scroll")
			}
		}
	}
	
	@ViewBuilder
	private func viewLessonsMenu(lessonCount: Int) -> some View {
		/*Label(title:{
			Text("\(lessonCount) Lessons")
		}, icon: {
			Image(systemName: "tray.2")
		})
			.frame(maxHeight:20)
			.labelStyle(.titleAndIcon)
			.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
			.foregroundColor(Color("Dynamic/LightGray"))
			.background(
				RoundedRectangle(cornerRadius: CGFloat(17))
					.foregroundColor(Color("Dynamic/MainBrown"))
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					.opacity(0.85)
					.overlay {
						RoundedRectangle(cornerRadius: 17)
							.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
					}
			)*/
		Text("8 Lessons")
	}
	
	@ViewBuilder
	private func demoLessonItem() -> some View {
		VStack(spacing:0) {
			VStack(alignment: .leading) {
				HStack {
					Text("A Lesson Title")
						.bold()
						.fixedSize(horizontal: false, vertical: true)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
					Spacer()
					Label("Go to lesson", systemImage: "arrow.right.circle.fill")
						.labelStyle(.iconOnly)
						.font(.title2)
						.foregroundColor(Color("Dynamic/MainGreen")) //original is "Dynamic/MainBrown"
				}
			}
			.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
		}
		.frame(maxWidth:UIScreen.main.bounds.size.width*0.8, minHeight: 86)
		.background(
			RoundedCornersShape(corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 17)
				.fill(Color("Dynamic/LightGray"))
				.opacity(0.85)
				.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
		)
		.padding([.leading,.trailing],15)
	}
	
	struct ViewOffsetKey: PreferenceKey {
		typealias Value = CGFloat
		static var defaultValue = CGFloat.zero
		static func reduce(value: inout Value, nextValue: () -> Value) {
			value += nextValue()
		}
	}
	
}

/*
struct LearningPathView_Previews: PreviewProvider {
	static var previews: some View {
		LearningPathView()
			.environmentObject(ScorewindData())
			.environment(\.colorScheme, .light)
			.environmentObject(Store())
			.previewInterfaceOrientation(InterfaceOrientation.portrait)
	}
}
*/

//
//  WizardView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct WizardView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@EnvironmentObject var store: Store
	@Binding var selectedTab:String
	@State private var userRole:UserRole = .student
	//@State private var stepName:Page = .wizardChooseInstrument
	@ObservedObject var studentData:StudentData
	@State private var showProgress = true
	@Binding var showLessonView:Bool
	@ObservedObject var downloadManager:DownloadManager
	@State private var showViewTitle = false
	@State private var showStore = false
	//@Binding var stepName:Page
	@Environment(\.colorScheme) var colorScheme
	@State private var showRevealAllTipsAlert = false
	@State private var showAboutScorewindAlert = false
	@State private var showPathFinder = false
	@State private var showStarterPath = true
	@State private var currentInstrument:InstrumentType = .guitar
	
	var body: some View {
		VStack(spacing:0) {
			HStack {
				if userRole == .student {
					if showStarterPath {
						Image(getIconTitleName())
							.resizable()
							.scaledToFit()
							.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
							.frame(maxHeight: 33)
							.padding([.trailing],4)
							.onTapGesture {
								if currentInstrument == .guitar {
									studentData.updateInstrumentChoice(instrument: .violin)
									currentInstrument = .violin
								} else {
									studentData.updateInstrumentChoice(instrument: .guitar)
									currentInstrument = .guitar
								}
								print("[debug] WizardView, switch instrument studentData. \(studentData.getInstrumentChoice())")
							}
					}
					
					Label("Starter Path", systemImage: showStarterPath ? "point.topleft.down.curvedto.point.bottomright.up.fill" : "map")//goforward
						.font(.title3)
						.labelStyle(.iconOnly)
						.foregroundColor(Color("AppBlackDynamic"))
						.onTapGesture(perform: {
							showStarterPath.toggle()
						})
						.padding([.trailing],4)
					Label("Path Finder", systemImage: "magnifyingglass")//goforward
						.font(.title3)
						.labelStyle(.iconOnly)
						.foregroundColor(Color("AppBlackDynamic"))
						.onTapGesture(perform: {
							print("[debug] WizardView, Path Finder, onTabGesture")
							//:: restart learning path configuration
							studentData.resetWizrdChoice()
							studentData.wizardRange.removeAll()
							studentData.removeAKey(keyName: "wizardResult")
							studentData.wizardResult = WizardResult()
							scorewindData.wizardPickedCourse = Course()
							scorewindData.wizardPickedLesson = Lesson()
							scorewindData.wizardPickedTimestamps.removeAll()
							studentData.wizardStepNames.removeAll()
							showPathFinder = true
						})
				}
				
				Spacer()
				/*if (store.enablePurchase == false || store.couponState == .valid) == false {
					Label("Subscription", systemImage: getSubscriptionMenuIcon())
						.font(.title3)
						.labelStyle(.iconOnly)
						.foregroundColor(Color("AppBlackDynamic"))
						.padding(.bottom,5)
						.padding(.trailing, 15)
						.onTapGesture {
							showStore = true
						}
				}*/
				/*Label("WizPack", systemImage: getSubscriptionMenuIcon())
					.font(.title3)
					.labelStyle(.iconOnly)
					.foregroundColor(Color("AppBlackDynamic"))
					.padding(.bottom,5)
					.padding(.trailing, 15)
					.onTapGesture {
						showStore = true
					}*/
				Label(title:{
					Text("WizPack")
						.font(.caption)
				}, icon: {
					Image(systemName: getSubscriptionMenuIcon())
				})
					.frame(maxHeight:20)
					.labelStyle(.titleAndIcon)
					.padding(EdgeInsets(top: 4, leading: 15, bottom: 4, trailing: 15))
					.foregroundColor(Color("Dynamic/MainBrown+6"))
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
					.padding([.bottom],4)
					.padding([.trailing],4)
					.onTapGesture {
						showStore = true
					}
				Menu {
					if scorewindData.isPublicUserVersion == false {
						Button(action: {
							if userRole == .student {
								userRole = .teacher
							} else {
								userRole = .student
							}
						}, label: {
							Text(userRole == .student ? "··Internal Tester Only··" : "··Back to Normal User's View··")
						})
					}
					
					Button(action: {
						showAboutScorewindAlert = true
					}, label: {
						Text("Support & About")
					})
					
					if (UserDefaults.standard.object(forKey: "hideTips") as? [String] ?? []).count > 0 {
						Button(action: {
							studentData.removeAUserDefaultKey(keyName: "hideTips")
							showRevealAllTipsAlert = true
						}, label: {
							Text("Show Me All Tips")
						})
					}
					
				} label: {
					Label("ScoreWind", systemImage: "gear")
						.font(.title3)
						.labelStyle(.iconOnly)
						.foregroundColor(Color("AppBlackDynamic"))
						.padding(.bottom,5)
				}
			}
			.padding([.top,.bottom], 5)
			.padding([.leading,.trailing], 15)

			if userRole == .teacher {
				WizardTeacherView(selectedTab: $selectedTab, studentData: studentData, downloadManager: downloadManager)
			} else {
				/*if stepName == .wizardChooseInstrument {
					WizardInstrumentView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
						.onAppear(perform: {
							showProgress = false
							showViewTitle = true
							DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
								withAnimation{
									showViewTitle = false
									//showProgress = true
								}
							}
						})
				} else if stepName == .wizardExperience {
					WizardExperienceView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
						.onAppear(perform: {
							showProgress = false
						})
				} else if stepName == .wizardDoYouKnow {
					WizardDoYouKnowView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
				} else if stepName == .wizardPlayable {
					WizardPlayableView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData, showProgress: $showProgress)
				} else */
				
				
				if showStarterPath == false {
					WizardResultView(selectedTab: $selectedTab, showStarterPath: $showStarterPath, studentData: studentData, showLessonView: $showLessonView, showStore: $showStore)
				} else  {
					LearningPathView(selectedTab: $selectedTab, studentData: studentData, showLessonView: $showLessonView, showStore: $showStore)
				}
			}
			
			if showViewTitle || showProgress {
				VStack {
					if showViewTitle {
						Label("Find courses and lessons", systemImage: "music.note")
							.labelStyle(.titleOnly)
							.font(.footnote)
							.foregroundColor(Color("AppBlackDynamic"))
					}
					/*if showProgress {
						GeometryReader { (proxy: GeometryProxy) in
							HStack {
								Spacer()
								wizardProgressView(barWidth: proxy.size.width*0.85,barHeight: 10)
								Spacer()
							}.onAppear(perform: {
								//print("[debug] showProgress, screensize.size.width \(screenSize.width)")
								//print("[debug] showProgress, proxy.size.width \(proxy.size.width)")
							})
						}.frame(height:10)
					}*/
				}
				.padding([.top,.bottom], 10)
				.padding([.leading,.trailing], 15)
			}
			
			Divider()
		}
		.background(colorScheme == .light ? appBackgroundImage(colorMode: colorScheme) : appBackgroundImage(colorMode: colorScheme))
		.alert("All the tips will be shown again now.", isPresented: $showRevealAllTipsAlert, actions:{})
		//.alert("ScoreWind\n\n\(getVersionNumber())", isPresented: $showAboutScorewindAlert,actions:{})
		.fullScreenCover(isPresented: $showAboutScorewindAlert, content: {
			AbouSupportView(showSupportAbout: $showAboutScorewindAlert, studentData: studentData)
		})
		.sheet(isPresented: $showStore, content: {
			StoreView(showStore: $showStore, studentData: studentData)
		})
		.sheet(isPresented: $showPathFinder, content: {
			LearningPathFinder(studentData: studentData, showPathFinder: $showPathFinder, showStarterPath: $showStarterPath)
		})
		.onAppear(perform: {
			//print("[debug] WizardView, onAppear studentData.wizardResult.learningPath.count \(studentData.wizardResult.learningPath.count)")
			studentData.showSavedActionCount()
			if studentData.getInstrumentChoice() == InstrumentType.guitar.rawValue {
				currentInstrument = .guitar
			} else if studentData.getInstrumentChoice() == InstrumentType.violin.rawValue {
				currentInstrument = .violin
			}
			print("[debug] WizardView, onAppear, student.instrumentChoise \(studentData.getInstrumentChoice())")
		})
	}
	
	/*@ViewBuilder
	private func backgroundImage(colorMode: ColorScheme) -> some View {
		if colorMode == .light {
			Image("WelcomeViewBg")
		} else {
			Image("DarkPolygonBg2")
				.resizable()
				.aspectRatio(contentMode: .fill)
				.edgesIgnoringSafeArea(.all)
		}
	}*/
	
	private func getIconTitleName() -> String {
		if currentInstrument == .guitar {
			return "instrument-guitar-icon" //"iconGuitar"
		} else if currentInstrument == .violin {
			return "instrument-violin-icon"//"iconViolin"
		} else {
			return ""
		}
	}
	
	private func subscriptionMenuLabel() -> String {
		var label = "ScoreWind WizPack"
		if store.enablePurchase {
			if store.offerIntroduction {
				label = "Start Your Free Trial"
			} else {
				label = "Start ScoreWind WizPack"
			}
		}
		return label
	}
	
	private func getSubscriptionMenuIcon() -> String {
		if store.enablePurchase == false || store.couponState == .valid {
			//already unlocked
			return "lock.open"
		} else {
			return "bell.badge"
		}
	}
	
	private func getVersionNumber() -> String {
		//:: CFBundleVersion for build number
		return "Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")  as! String)\nBuild \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")  as! String)"
		//return UIApplication.appVer
	}
	
	/*private func getWizardViewTitle() -> String {
		let findStepIndex = studentData.wizardStepNames.firstIndex(where: {$0.self == stepName}) ?? 0
		
		if userRole == .student {
			if stepName == .wizardResult {
				return "Wizard final step"
			} else {
				return "Wizard step \(findStepIndex+1)"
			}
		} else {
			return "Wizard (Teachers only)"
		}
	}*/
	
	/*
	@ViewBuilder
	private func wizardProgressView(barWidth: CGFloat, barHeight: CGFloat) -> some View {
		let totalWidth = barWidth
		//totalWidth = screenSize.width*0.4
		RoundedRectangle(cornerRadius: 5)
			.foregroundColor(Color("Dynamic/LightGray"))
			.frame(width:totalWidth,height:barHeight)
			.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(1))
			.overlay(alignment:.leading,content: {
				if stepName == .wizardChooseInstrument {
					RoundedRectangle(cornerRadius: 5)
						.foregroundColor(Color("Dynamic/MainBrown"))
						.frame(width:totalWidth*(0.3/10.0),height:barHeight)
				} else if stepName == .wizardExperience {
					RoundedRectangle(cornerRadius: 5)
						.foregroundColor(Color("Dynamic/MainBrown"))
						.frame(width:totalWidth*(0.8/10.0),height:barHeight)
				} else if stepName == .wizardResult {
					RoundedRectangle(cornerRadius: 5)
						.foregroundColor(Color("Dynamic/MainBrown"))
						.frame(width:totalWidth,height:barHeight)
				} else {
					RoundedRectangle(cornerRadius: 5)
						.foregroundColor(Color("Dynamic/MainBrown"))
						.frame(width: (totalWidth*0.95)*(Double(studentData.wizardRange.count)/10.0),height:barHeight)
				}
			})
	}
	 */
}

struct StepExplainingText: ViewModifier {
	func body(content: Content) -> some View {
		content
			.foregroundColor(Color("Dynamic/MainBrown+6"))
			.padding(EdgeInsets(top: 18, leading: 40, bottom: 18, trailing: 40))
	}
}

struct TipExplainingParagraph: ViewModifier {
	func body(content: Content) -> some View {
		content
			.foregroundColor(Color("LessonListStatusIcon"))
			.padding(EdgeInsets(top: 4, leading: 40, bottom: 4, trailing: 40))
	}
}

struct FeedbackOptionsModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			//.font(.headline)
			.foregroundColor(Color("Dynamic/MainBrown+6"))
			.padding(EdgeInsets(top: 10, leading: 22, bottom: 10, trailing: 22))
			.background {
				RoundedRectangle(cornerRadius: 25)
					.foregroundColor(Color("Dynamic/LightGray"))
					.shadow(color: Color("Dynamic/ShadowLight"),radius: CGFloat(5))
			}
			.fixedSize()
	}
}
/*
struct WizardView_Previews: PreviewProvider {
	@State static var tab = "THome"
	@State static var stepName:Page = .wizardPlayable
	
	static var previews: some View {
		
		Group {
			WizardView(selectedTab: $tab, studentData: StudentData(), showLessonView: .constant(false), downloadManager: DownloadManager())
				.environmentObject(ScorewindData())
				.environment(\.colorScheme, .light)
				.environmentObject(Store())
				//.previewInterfaceOrientation(InterfaceOrientation.portrait)
			
			WizardView(selectedTab: $tab, studentData: StudentData(), showLessonView: .constant(false), downloadManager: DownloadManager(), stepName: $stepName).environmentObject(ScorewindData()).environment(\.colorScheme, .dark).environmentObject(Store())
				//.previewInterfaceOrientation(InterfaceOrientation.portrait)
		}
		
		Group {
			WizardView(selectedTab: $tab, studentData: StudentData(), showLessonView: .constant(false), downloadManager: DownloadManager(), stepName: $stepName)
				.environmentObject(ScorewindData())
				.environment(\.colorScheme, .light)
				.environmentObject(Store())
				//.previewInterfaceOrientation(InterfaceOrientation.landscapeLeft)
				.previewDisplayName("Light Landscape")
		}
		
	}
}
*/
enum UserRole {
	case teacher
	case student
}

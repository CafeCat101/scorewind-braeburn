//
//  WizardView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct WizardView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@State private var userRole:UserRole = .student
	@State private var stepName:Page = .wizardChooseInstrument
	@ObservedObject var studentData:StudentData
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var showProgress = true
	@Binding var showLessonView:Bool
	@ObservedObject var downloadManager:DownloadManager
	@State private var showViewTitle = true
	
	var body: some View {
		VStack {
			HStack {
				if (stepName != .wizardChooseInstrument || stepName == .wizardResult) && studentData.playableViewVideoOnly && userRole == .student {
					Label("Restart", systemImage: "goforward")
						.font(.title3)
						.labelStyle(.iconOnly)
						.foregroundColor(Color("AppBlackDynamic"))
						.onTapGesture(perform: {
							//:: restart learning path configuration
							studentData.wizardStepNames.removeAll()
							stepName = Page.wizardChooseInstrument
						})
				}
				Spacer()
				if showViewTitle {
					Label("ScoreWind", systemImage: "music.note")
						.labelStyle(.titleOnly)
						.foregroundColor(Color("AppBlackDynamic"))
						.onTapGesture(count:3, perform: {
							if userRole == .student {
								userRole = .teacher
							} else {
								userRole = .student
							}
						})
				}
				if showProgress {
					GeometryReader { (proxy: GeometryProxy) in
						HStack {
							wizardProgressView(barWidth: proxy.size.width)
						}.onAppear(perform: {
							print("[debug] showProgress, screensize.size.width \(screenSize.width)")
							print("[debug] showProgress, proxy.size.width \(proxy.size.width)")
						})
					}.frame(height:10)
				}
				Spacer()
				Menu {
					Button("Switch role", action: {
						if userRole == .student {
							userRole = .teacher
						} else {
							userRole = .student
						}
					})
				} label: {
					Label("ScoreWind", systemImage: "gear")
						.font(.title3)
						.labelStyle(.iconOnly)
						.foregroundColor(Color("AppBlackDynamic"))
				}
			}
			.padding([.bottom], 5)
			.padding([.leading,.trailing], 15)
			
			/*if showProgress {
				HStack {
					wizardProgressView()
				}.padding([.bottom], 5)
			}*/
			
			if userRole == .teacher {
				WizardTeacherView(selectedTab: $selectedTab, studentData: studentData, downloadManager: downloadManager)
			} else {
				if stepName == .wizardChooseInstrument {
					WizardInstrumentView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
						.onAppear(perform: {
							showViewTitle = true
							showProgress = true
							DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
								withAnimation{
									showViewTitle = false
								}
							}
						})
				} else if stepName == .wizardExperience {
					WizardExperienceView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
				} else if stepName == .wizardDoYouKnow {
					WizardDoYouKnowView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
				} else if stepName == .wizardPlayable {
					WizardPlayableView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
				} else if stepName == .wizardResult {
					WizardResultView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData, showLessonView: $showLessonView).onAppear{
						DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
							withAnimation{
								showViewTitle = true
								showProgress = false
							}
						}
					}
					
				}
			}
			
			
			Divider()
		}
		.background(Color("AppBackground"))
		.onAppear(perform: {			
			print("[debug] WizardView, wizardStepNames \(studentData.wizardStepNames)")
		})
	}
	
	private func getWizardViewTitle() -> String {
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
	}
	
	@ViewBuilder
	private func wizardProgressView(barWidth: CGFloat) -> some View {
		let totalWidth = barWidth
		//totalWidth = screenSize.width*0.4
		RoundedRectangle(cornerRadius: 5)
			.foregroundColor(.gray)
			.frame(width:totalWidth,height:10)
			.overlay(alignment:.leading,content: {
				if stepName == .wizardChooseInstrument {
					RoundedRectangle(cornerRadius: 5)
						.foregroundColor(Color("AppYellow"))
						.frame(width:totalWidth*(0.3/10.0),height:10)
				} else if stepName == .wizardExperience {
					RoundedRectangle(cornerRadius: 5)
						.foregroundColor(Color("AppYellow"))
						.frame(width:totalWidth*(0.8/10.0),height:10)
				} else if stepName == .wizardResult {
					RoundedRectangle(cornerRadius: 5)
						.foregroundColor(Color("AppYellow"))
						.frame(width:totalWidth,height:10)
				} else {
					RoundedRectangle(cornerRadius: 5)
						.foregroundColor(Color("AppYellow"))
						.frame(width:totalWidth*(Double(studentData.wizardRange.count)/10.0),height:10)
				}
			})
	}

}

struct StepExplainingText: ViewModifier {
	func body(content: Content) -> some View {
		content
			.foregroundColor(Color("LessonListStatusIcon"))
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

struct WizardView_Previews: PreviewProvider {
	@State static var tab = "THome"
	static var previews: some View {
		Group {
			WizardView(selectedTab: $tab, studentData: StudentData(), showLessonView: .constant(false), downloadManager: DownloadManager()).environmentObject(ScorewindData())
			WizardView(selectedTab: $tab, studentData: StudentData(), showLessonView: .constant(false), downloadManager: DownloadManager()).environmentObject(ScorewindData()).environment(\.colorScheme, .dark)
		}
		
	}
}

enum UserRole {
	case teacher
	case student
}

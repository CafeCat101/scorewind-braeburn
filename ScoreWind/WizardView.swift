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
	
	var body: some View {
		VStack {
			/*
			Label("Scorewind (\(userRole))", systemImage: "music.note")
				.labelStyle(.titleAndIcon)
				.contextMenu {
					Button(action: {
						userRole = "student"
					}){
						Label("I'm a student", systemImage: "face.smiling")
							.labelStyle(.titleAndIcon)
					}
					Button(action: {
						userRole = "teacher"
					}){
						Label("Teachers only", systemImage: "brain.head.profile")
							.labelStyle(.titleAndIcon)
					}
				}*/
			HStack {
				Spacer()
				Label("Wizard", systemImage: "music.note")
					.labelStyle(.titleOnly)
					.foregroundColor(Color("AppBlackDynamic"))
					.contextMenu {
						Button(action: {
							userRole = .student
							stepName = .wizardChooseInstrument
						}){
							Label("I'm a student", systemImage: "face.smiling")
								.labelStyle(.titleAndIcon)
						}
						Button(action: {
							userRole = .teacher
						}){
							Label("Teachers only", systemImage: "brain.head.profile")
								.labelStyle(.titleAndIcon)
						}
					}
					.onTapGesture {
						if studentData.wizardStepNames.count > 1 && studentData.playableViewVideoOnly && userRole == .student {
							//back to instrument
							studentData.wizardStepNames.removeAll()
							stepName = Page.wizardChooseInstrument
						}
					}
				if showProgress {
					wizardProgressView()
				}
				
				Spacer()
			}
			.overlay(alignment:.leading, content: {
				//:: to navigate back
				if (studentData.wizardStepNames.count > 1 || stepName == .wizardResult) && studentData.playableViewVideoOnly && userRole == .student {
					Label("Restart", systemImage: "goforward")
						.padding([.leading], 15)
						.font(.title3)
						.labelStyle(.iconOnly)
						.onTapGesture(perform: {
							//back to instrument
							studentData.wizardStepNames.removeAll()
							stepName = Page.wizardChooseInstrument
							/*
							//one step back
							studentData.wizardStepNames.removeLast()
							print("[debug] WizardView, wizardStepNames \(studentData.wizardStepNames)")
							stepName = studentData.wizardStepNames[(studentData.wizardStepNames.count-1)]
							*/
						})
					
				}
			})
			.padding([.bottom], 5)
			
			if userRole == .teacher {
				WizardTeacherView(selectedTab: $selectedTab, studentData: studentData, downloadManager: downloadManager)
			} else {
				if stepName == .wizardChooseInstrument {
					WizardInstrumentView(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
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
			if studentData.getWizardResult().learningPath.count > 0 {
				studentData.wizardResult = studentData.getWizardResult()
				let getPickedItem = studentData.wizardResult.learningPath.first(where: {$0.startHere == true})
				scorewindData.wizardPickedCourse = scorewindData.allCourses.first(where: {$0.id == getPickedItem?.courseID}) ?? Course()
				scorewindData.wizardPickedLesson = scorewindData.wizardPickedCourse.lessons.first(where: {$0.id == getPickedItem?.lessonID}) ?? Lesson()
				scorewindData.wizardPickedTimestamps = (scorewindData.allTimestamps.first(where: {$0.id == getPickedItem?.courseID})?.lessons.first(where: {$0.id == getPickedItem?.lessonID})!.timestamps) ?? []
				stepName = .wizardResult
			} else {
				stepName = .wizardChooseInstrument
			}
			
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
	private func wizardProgressView() -> some View {
		RoundedRectangle(cornerRadius: 4)
			.foregroundColor(.gray)
			.frame(width:screenSize.width*0.6+10,height:10)
			.overlay(alignment:.leading,content: {
				if stepName == .wizardChooseInstrument {
					RoundedRectangle(cornerRadius: 4)
						.foregroundColor(Color("AppYellow"))
						.frame(width:screenSize.width*0.6*(0.3/10.0),height:10)
				} else if stepName == .wizardExperience {
					RoundedRectangle(cornerRadius: 4)
						.foregroundColor(Color("AppYellow"))
						.frame(width:screenSize.width*0.6*(0.8/10.0),height:10)
				} else if stepName == .wizardResult {
					RoundedRectangle(cornerRadius: 4)
						.foregroundColor(Color("AppYellow"))
						.frame(width:screenSize.width*0.6+10,height:10)
				} else {
					RoundedRectangle(cornerRadius: 4)
						.foregroundColor(Color("AppYellow"))
						.frame(width:screenSize.width*0.6*(Double(studentData.wizardRange.count)/10.0),height:10)
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
	@State static var tab = "TWizard"
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

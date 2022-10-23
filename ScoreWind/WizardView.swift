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
	@State private var userRole = "student"
	@State private var stepName:Page = .wizardChooseInstrument
	@ObservedObject var studentData:StudentData
	
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
					Label(getWizardViewTitle(), systemImage: "music.note")
						.labelStyle(.titleAndIcon)
						.foregroundColor(Color("AppBlackDynamic"))
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
						}
				Spacer()
			}
			.overlay(alignment:.leading, content: {
				//::NAVIGATE BACK
				if studentData.wizardStepNames.count > 1 {
					Label("Previous step", systemImage: "chevron.backward.circle.fill")
						.padding([.leading], 15)
						.font(.title3)
						.labelStyle(.iconOnly)
						.onTapGesture(perform: {
							studentData.wizardStepNames.removeLast()
							print("[debug] WizardView, wizardStepNames \(studentData.wizardStepNames)")
							stepName = studentData.wizardStepNames[(studentData.wizardStepNames.count-1)]
						})
					
				}
			})
			
			if userRole == "teacher" {
				WizardTeacherView(selectedTab: $selectedTab)
			} else {
				if stepName == .wizardChooseInstrument {
					WizardInstrument(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
				} else if stepName == .wizardDoYouKnow {
					WizardDoYouKnow(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
				} else if stepName == .wizardPlayable {
					WizardPlayable(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
				} else if stepName == .wizardResult {
					WizardResult(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
				}
			}
			
			
			Divider()
		}
		.background(Color("AppBackground"))
		.onAppear(perform: {
			stepName = .wizardChooseInstrument
			print("[debug] WizardView, wizardStepNames \(studentData.wizardStepNames)")
			/*
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				userRole = "teacher"
			}
			 */
		})
	}
	
	private func getWizardViewTitle() -> String {
		if stepName == .wizardChooseInstrument {
			return "Wizard step 1"
		} else if stepName == .wizardPlayable {
			return "Wizard step 2"
		} else if stepName == .wizardResult {
			return "Wizard final step"
		} else {
			return ""
		}
	}

}

struct WizardView_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	static var previews: some View {
		Group {
			WizardView(selectedTab: $tab, studentData: StudentData()).environmentObject(ScorewindData())
			WizardView(selectedTab: $tab, studentData: StudentData()).environmentObject(ScorewindData()).environment(\.colorScheme, .dark)
		}
		
	}
}

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
				}
			
			if userRole == "teacher" {
				WizardTeacherView(selectedTab: $selectedTab)
			} else {
				if stepName == .wizardChooseInstrument {
					WizardInstrument(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
				} else if stepName == .wizardPlayable {
					WizardPlayable(selectedTab: $selectedTab, stepName: $stepName, studentData: studentData)
				}
			}
			
			
			
		}
		.onAppear(perform: {
			/*
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				userRole = "teacher"
			}
			 */
		})
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

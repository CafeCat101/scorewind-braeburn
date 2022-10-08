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
	@State private var stepName:WizardStep = .chooseInstrument
	
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
				if stepName == .chooseInstrument {
					Spacer()
					Text("Which instrument do you want to learn?")
						.font(.headline)
					
					HStack {
						Button(action:{
							
						}){
							Circle()
								.strokeBorder(Color.black,lineWidth: 1)
								.background(Circle().foregroundColor(Color.white))
								.frame(width:100,height:100)
								.overlay(
									Image("instrument-guitar-icon")
										.resizable()
										.scaleEffect(0.6)
								)
						}
						
						Button(action:{
							
						}){
							Circle()
								.strokeBorder(Color.black,lineWidth: 1)
								.background(Circle().foregroundColor(Color.white))
								.frame(width:100,height:100)
								.overlay(
									Image("instrument-violin-icon")
										.resizable()
										.scaleEffect(0.6)
								)
						}
					}
					
					Spacer()
				}
			}
			
			
			
		}
		.onAppear(perform: {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				userRole = "teacher"
			}
		})
	}
	

}

struct WizardView_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	static var previews: some View {
		Group {
			WizardView(selectedTab: $tab).environmentObject(ScorewindData())
			WizardView(selectedTab: $tab).environmentObject(ScorewindData()).environment(\.colorScheme, .dark)
		}
		
	}
}

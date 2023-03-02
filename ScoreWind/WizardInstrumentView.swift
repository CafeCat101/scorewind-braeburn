//
//  WizardInstrument.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/10.
//
/**
 this branch is preserved this view design here
 */

import SwiftUI
import AVFoundation

struct WizardInstrumentView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	let feedback = UIImpactFeedbackGenerator(style: .heavy)
	
	var body: some View {
		VStack {
			Spacer()
			
			HStack {
				Spacer()
				Text("Choose your instrument")
					.font(.title)
					.foregroundColor(Color("Dynamic/MainGreen"))
					.bold()
				Spacer()
			}
			
			GeometryReader { (proxy: GeometryProxy) in
				HStack(spacing: 0) {
					VStack{
						Spacer()
						getChoiceIcon(instrumentImage: "guitar", isSelected: isInstrumentSelected(askInstrument: .guitar)).frame(width:proxy.size.width*0.4,height:proxy.size.width*0.4)
						Text("Guitar").font(.headline).foregroundColor(Color("Dynamic/Shadow"))
						/*Button(action:{
							/*feedback.impactOccurred()
							stepName = .wizardExperience
							studentData.updateInstrumentChoice(instrument: .guitar)
							studentData.removeAKey(keyName: "experience")
							studentData.wizardStepNames.append(stepName)*/
						}){
							Circle()
								//.strokeBorder(Color(UIColor.systemGray5),lineWidth: 1)
								//.background(Circle().foregroundColor(Color("WelceomView")))
								.frame(width:proxy.size.width*0.4,height:proxy.size.width*0.4)
								.overlay(
									getChoiceIcon(instrumentImage: "guitar", isSelected: isInstrumentSelected(askInstrument: .guitar)).offset(x:0)
								)
						}
						.frame(height:proxy.size.height*0.9)
						.foregroundColor(Color("Dynamic/LightGray+1"))*/
						Spacer()
					}
					.frame(width:proxy.size.width*0.5)
					.background(
						RoundedCornersShape(corners: [.topLeft, .bottomLeft], radius: 26)
														.fill(Color("Dynamic/LightGray+1"))
					).onTapGesture {
						print("guitar!")
						feedback.impactOccurred()
					 stepName = .wizardExperience
					 studentData.updateInstrumentChoice(instrument: .guitar)
					 studentData.removeAKey(keyName: "experience")
					 studentData.wizardStepNames.append(stepName)
					}
					
					VStack{
						Spacer()
						getChoiceIcon(instrumentImage: "violin", isSelected: isInstrumentSelected(askInstrument: .violin)).frame(width:proxy.size.width*0.4,height:proxy.size.width*0.4)
						Text("Violin").font(.headline).foregroundColor(Color("Dynamic/Shadow"))
						/*Button(action:{
							feedback.impactOccurred()
							stepName = .wizardExperience
							studentData.updateInstrumentChoice(instrument: .violin)
							studentData.wizardStepNames.append(stepName)
						}){
							Circle()
								//.strokeBorder(Color.black,lineWidth: 1)
								//.background(Circle().foregroundColor(Color.white))
								.frame(width:proxy.size.width*0.4,height:proxy.size.width*0.4)
								.overlay(
									getChoiceIcon(instrumentImage: "violin", isSelected: isInstrumentSelected(askInstrument: .violin)).offset(x:0)
								)
						}
						.frame(height:proxy.size.height*0.9)
						.foregroundColor(Color("Dynamic/LightGray"))*/
						Spacer()
					}
					.frame(width:proxy.size.width*0.5)
					.background(
						RoundedCornersShape(corners: [.topRight, .bottomRight], radius: 26)
														.fill(Color("Dynamic/LightGray"))
					)
					.onTapGesture {
						feedback.impactOccurred()
						stepName = .wizardExperience
						studentData.updateInstrumentChoice(instrument: .violin)
						studentData.wizardStepNames.append(stepName)
					}
				}
			}
			.background(
				RoundedRectangle(cornerRadius: CGFloat(28))
					.foregroundColor(Color("Dynamic/Shadow"))
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
			)
			.frame(width: UIScreen.main.bounds.size.width*0.85, height: UIScreen.main.bounds.size.height*0.6)
			
			
			/*
			HStack(spacing: 0) {
				HStack {
					Button(action:{
						stepName = .wizardExperience
						studentData.updateInstrumentChoice(instrument: .guitar)
						studentData.removeAKey(keyName: "experience")
						studentData.wizardStepNames.append(stepName)
					}){
						/*
						Circle()
							.strokeBorder(Color.black,lineWidth: 1)
							.background(Circle().foregroundColor(Color.white))
							.frame(width:100,height:100)
							.overlay(
								getChoiceIcon(instrumentImage: "instrument-guitar-icon", isSelected: isInstrumentSelected(askInstrument: .guitar))
							)*/
						getChoiceIcon(instrumentImage: "instrument-guitar-icon", isSelected: isInstrumentSelected(askInstrument: .guitar))
					}.padding().shadow(radius: CGFloat(0))
				}
				.background(
					RoundedCornersShape(corners: [.bottomLeft,.topLeft], radius: 16)
						.fill(Color("LessonPlayLearnContinue"))).padding(0)
				.frame(width:UIScreen.main.bounds.size.width*0.4, height: UIScreen.main.bounds.size.height*0.6)
				.shadow(radius: CGFloat(5), x:-5)
				
				HStack(spacing: 0) {
					Button(action:{
						stepName = .wizardExperience
						studentData.updateInstrumentChoice(instrument: .violin)
						studentData.wizardStepNames.append(stepName)
					}){
						/*
						Circle()
							.strokeBorder(Color.black,lineWidth: 1)
							.background(Circle().foregroundColor(Color.white))
							.frame(width:100,height:100)
							.overlay(
								getChoiceIcon(instrumentImage: "instrument-violin-icon", isSelected: isInstrumentSelected(askInstrument: .violin))
							)*/
						getChoiceIcon(instrumentImage: "instrument-violin-icon", isSelected: isInstrumentSelected(askInstrument: .violin))
					}.padding().shadow(radius: CGFloat(0))
				}
					.background(
						RoundedCornersShape(corners: [.topRight, .bottomRight], radius: 16)
						 .fill(Color("WizardFeedBack")))
				 .frame(width:UIScreen.main.bounds.size.width*0.4, height: UIScreen.main.bounds.size.height*0.6)
				 .shadow(radius: CGFloat(5), x:5)
			}
			*/
			Spacer()
		}
		.background(Color("AppBackground"))
		.onAppear(perform: {
			//:: start over, reset everything
			studentData.wizardStepNames = [.wizardChooseInstrument]
		})
	}
	
	@ViewBuilder
	private func getChoiceIcon(instrumentImage:String, isSelected:Bool) -> some View {
		Image(instrumentImage)
			.resizable()
			.scaleEffect(1)
			.overlay(
				alignment:.bottom,
				content: {
					Label("select",systemImage: "checkmark.circle.fill")
						.labelStyle(.iconOnly)
						.font(.title)
						.opacity(isSelected ? 1.0 : 0.0)
				})
	}
	
	private func isInstrumentSelected(askInstrument: InstrumentType) -> Bool {
		if studentData.getInstrumentChoice() == askInstrument.rawValue {
			return true
		} else {
			return false
		}
	}
	
}

struct WizardInstrument_Previews: PreviewProvider {
	@State static var tab = "THome"
	@State static var step:Page = .wizardChooseInstrument
	static var previews: some View {
		WizardInstrumentView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

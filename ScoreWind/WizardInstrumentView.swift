//
//  WizardInstrument.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/10.
//

import SwiftUI
import AVFoundation

struct WizardInstrumentView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	let feedback = UIImpactFeedbackGenerator(style: .heavy)
	let screenSize = UIScreen.main.bounds.size
	@State private var currentIndex = 0

	var body: some View {
		VStack {
			Spacer()
			
			HStack {
				Spacer()
				Text("Choose your instrument")
					.font(.title)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.bold()
				Spacer()
			}
			
			TabView {
				displayInstrument(instrument: InstrumentType.guitar.rawValue)
				displayInstrument(instrument: InstrumentType.violin.rawValue)
			}
			.tabViewStyle(.page)
			.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.6)
			
			//Page dot inside the panel look
			/*
			TabView {
				displayInstrument(instrument: InstrumentType.guitar.rawValue)
				displayInstrument(instrument: InstrumentType.violin.rawValue)
			}
			.tabViewStyle(.page)
			.background(
				RoundedRectangle(cornerRadius: CGFloat(28))
					.foregroundColor(Color("Dynamic/LightGray"))
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
			)
			.frame(width: UIScreen.main.bounds.size.width*0.85, height: UIScreen.main.bounds.size.height*0.6)
			*/
			/*
			GeometryReader { (proxy: GeometryProxy) in
				HStack(spacing: 0) {
					VStack{
						Spacer()
						getChoiceIcon(instrumentImage: "guitar", isSelected: isInstrumentSelected(askInstrument: .guitar)).frame(width:proxy.size.width*0.4,height:proxy.size.width*0.4)
						Text("Guitar").font(.headline).foregroundColor(Color("Dynamic/Shadow"))
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
			 */
			Spacer()
		}
		//.background(Color("AppBackground"))
		.onAppear(perform: {
			//:: start over, reset everything
			studentData.wizardStepNames = [.wizardChooseInstrument]
		})
	}
	
	@ViewBuilder
	private func displayInstrument(instrument:String) -> some View {
		GeometryReader { (proxy: GeometryProxy) in
			HStack {
				Spacer()
				VStack {
					Spacer()
					HStack {
						Spacer()
						getChoiceIcon(instrumentImage: instrument, isSelected: isInstrumentSelected(askInstrument: instrument == InstrumentType.guitar.rawValue ? .guitar : .violin))
							.frame(width:proxy.size.width*0.7,height:proxy.size.width*0.7)
							.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(15))
						Spacer()
					}
					Divider().frame(width: proxy.size.width*0.7)
					Text(instrument.uppercased())
						.font(.headline)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						//.foregroundColor(Color("Dynamic/Shadow"))
					Spacer()
				}
				.frame(width: proxy.size.width*0.85, height:proxy.size.height*0.9)
				.background(
					RoundedRectangle(cornerRadius: CGFloat(28))
						.foregroundColor(Color("Dynamic/LightGray"))
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
				)
				.padding(.top, 10)
				.onTapGesture {
					feedback.impactOccurred()
				 stepName = .wizardExperience
				 studentData.updateInstrumentChoice(instrument: instrument == InstrumentType.guitar.rawValue ? .guitar : .violin)
				 studentData.removeAKey(keyName: "experience")
				 studentData.wizardStepNames.append(stepName)
				}
				Spacer()
			}
		}
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
		Group {
			WizardInstrumentView(selectedTab: $tab, stepName: $step, studentData: StudentData())
				.environmentObject(ScorewindData())
				.environment(\.colorScheme, .light)
			WizardInstrumentView(selectedTab: $tab, stepName: $step, studentData: StudentData())
				.environmentObject(ScorewindData())
				.environment(\.colorScheme, .dark)
		}
	}
}

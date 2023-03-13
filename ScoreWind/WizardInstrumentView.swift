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
	@Environment(\.horizontalSizeClass) var horizontalSize

	var body: some View {
		GeometryReader { mainReader in
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
				.frame(width: mainReader.size.width, height: mainReader.size.height*0.80 )

				Spacer()
			}
			.onAppear(perform: {
				//:: start over, reset everything
				studentData.wizardStepNames = [.wizardChooseInstrument]
				print("[debug] InstrumentView, mainReader w/h \(mainReader.size.width)/\(mainReader.size.height)")
			})
		}
		
	}
	
	@ViewBuilder
	private func displayInstrument(instrument:String) -> some View {
		GeometryReader { (proxy: GeometryProxy) in
			HStack {
				Spacer()
				VStack {
					Spacer()
					if proxy.size.height > proxy.size.width {
						HStack {
							Spacer()
							getChoiceIcon(instrumentImage: instrument, isSelected: isInstrumentSelected(askInstrument: instrument == InstrumentType.guitar.rawValue ? .guitar : .violin))
								.frame(width:proxy.size.width*0.7, height:proxy.size.width*0.7)
								.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(15))
							Spacer()
						}
						Divider().frame(width: proxy.size.width*0.7)
						Text(instrument.uppercased())
							.font(.headline)
							.foregroundColor(Color("Dynamic/MainBrown+6"))
					} else {
						HStack {
							Spacer()
							HStack {
								Spacer()
								getChoiceIcon(instrumentImage: instrument, isSelected: isInstrumentSelected(askInstrument: instrument == InstrumentType.guitar.rawValue ? .guitar : .violin))
									.rotationEffect(Angle(degrees: 30.0))
									.frame(width:proxy.size.height*0.7, height:proxy.size.height*0.7)
									.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(15))
								Spacer()
							}
							Divider().frame(height: proxy.size.height*0.7)
							Text(instrument.uppercased())
								.font(.headline)
								.foregroundColor(Color("Dynamic/MainBrown+6"))
								.frame(width: proxy.size.width*0.25)
							Spacer()
						}
					}
					
					Spacer()
				}
				.frame(width: proxy.size.width*0.85, height:proxy.size.height-55)
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
			.scaledToFit()
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
		let previewOrientation = InterfaceOrientation.portrait
		
		Group {
			WizardInstrumentView(selectedTab: $tab, stepName: $step, studentData: StudentData())
				.environmentObject(ScorewindData())
				.environment(\.colorScheme, .light)
				.previewInterfaceOrientation(previewOrientation)
			
			WizardInstrumentView(selectedTab: $tab, stepName: $step, studentData: StudentData())
				.environmentObject(ScorewindData())
				.environment(\.colorScheme, .dark)
				.previewInterfaceOrientation(previewOrientation)
		}
		
		Group {
			WizardInstrumentView(selectedTab: $tab, stepName: $step, studentData: StudentData())
				.environmentObject(ScorewindData())
				.environment(\.colorScheme, .light)
				.previewInterfaceOrientation(InterfaceOrientation.landscapeLeft)
				.previewDisplayName("Light Landscape")
		}
	}
}

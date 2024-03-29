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
	@Environment(\.verticalSizeClass) var verticalSize
	@State private var selectedInstrumentTab = InstrumentType.guitar.rawValue

	var body: some View {
		VStack {
			Spacer()
			
			HStack {
				Spacer()
				Text("Choose your instrument")
					.font(verticalSize == .regular ? .title : .title2)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.bold()
				Spacer()
			}
			
			Spacer()
			
			VStack {
				TabView(selection: $selectedInstrumentTab) {
					displayInstrument(instrument: InstrumentType.guitar.rawValue)
						.tag(InstrumentType.guitar.rawValue)
					displayInstrument(instrument: InstrumentType.violin.rawValue)
						.tag(InstrumentType.violin.rawValue)
				}
				.tabViewStyle(.page)
			}
			.frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.width*0.60, height: verticalSize == .regular ? UIScreen.main.bounds.size.height*0.60 : UIScreen.main.bounds.size.height*0.5 )
			.onChange(of: verticalSize, perform: { info in
				print("info \(String(describing: info))")
				print("info w:\(UIScreen.main.bounds.size.width)/h:\(UIScreen.main.bounds.size.height)")
				selectedInstrumentTab = InstrumentType.guitar.rawValue
			})

			Spacer()
		}
		.onAppear(perform: {
			//:: start over, reset everything
			studentData.wizardStepNames = [.wizardChooseInstrument]
			print("[debug] InstrumentView, onAppear, screenSize info w：\(UIScreen.main.bounds.size.width)/h:\(UIScreen.main.bounds.size.height)")
		})
		
	}
	
	@ViewBuilder
	private func displayInstrument(instrument:String) -> some View {
		GeometryReader { (proxy: GeometryProxy) in
			HStack {
				Spacer()
				VStack {
					Spacer()
					if verticalSize == .regular && horizontalSize == .compact {
						//:: portrait
						HStack {
							Spacer()
							getChoiceIcon(instrumentImage: instrument, isSelected: isInstrumentSelected(askInstrument: instrument == InstrumentType.guitar.rawValue ? .guitar : .violin))
								.frame(width:proxy.size.width*0.7, height:proxy.size.width*0.7)
								.shadow(color: Color("Dynamic/OuterGlow"), radius: CGFloat(15))
							Spacer()
						}
						Divider().frame(width: proxy.size.width*0.7)
						HStack {
							Spacer()
							if isInstrumentSelected(askInstrument: instrument == InstrumentType.guitar.rawValue ? .guitar : .violin) {
								Label("select",systemImage: "checkmark.circle.fill")
									.labelStyle(.iconOnly)
									.font(.headline)
									.foregroundColor(Color("Dynamic/MainBrown+6"))
							}
							Text(instrument.uppercased())
								.font(.headline)
								.foregroundColor(Color("Dynamic/MainBrown+6"))
							Spacer()
						}
					} else {
						//:: landscape a like
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
							VStack {
								Text(instrument.uppercased())
									.font(.headline)
									.foregroundColor(Color("Dynamic/MainBrown+6"))
									.frame(width: proxy.size.width*0.25)
								if isInstrumentSelected(askInstrument: instrument == InstrumentType.guitar.rawValue ? .guitar : .violin) {
									Label("select",systemImage: "checkmark.circle.fill")
										.labelStyle(.iconOnly)
										.font(.headline)
										.foregroundColor(Color("Dynamic/MainBrown+6"))
								}
							}
							
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

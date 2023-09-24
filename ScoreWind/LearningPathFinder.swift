//
//  LearningPathFinder.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/9/23.
//

import SwiftUI

struct LearningPathFinder: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@ObservedObject var studentData:StudentData
	@Environment(\.colorScheme) var colorScheme
	@State private var showRevealAllTipsAlert = false
	@Binding var showStarterPath:Bool
	@State private var stepName:Page = .wizardChooseInstrument
	
	var body: some View {
		VStack(spacing:0) {
			if stepName == .wizardChooseInstrument {
				WizardInstrumentView(stepName: $stepName, studentData: studentData)
			} else if stepName == .wizardExperience {
				WizardExperienceView(stepName: $stepName, studentData: studentData)
			} else if stepName == .wizardDoYouKnow {
				WizardDoYouKnowView(stepName: $stepName, studentData: studentData)
			} else if stepName == .wizardPlayable {
				WizardPlayableView(stepName: $stepName, studentData: studentData)
			}
		}
		.background(colorScheme == .light ? appBackgroundImage(colorMode: colorScheme) : appBackgroundImage(colorMode: colorScheme))
		.onAppear(perform: {
			if studentData.getInstrumentChoice().isEmpty {
				stepName = .wizardChooseInstrument
			} else {
				stepName = .wizardExperience
			}
		})
	}
}


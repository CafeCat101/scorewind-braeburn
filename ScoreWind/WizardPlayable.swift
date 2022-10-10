//
//  WizardPlayable.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/10.
//

import SwiftUI

struct WizardPlayable: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	
	var body: some View {
		VStack {
			Text("\(studentData.getInstrumentChoice())")
		}
	}
}

struct WizardPlayable_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardPlayable
	
	static var previews: some View {
		WizardPlayable(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

//
//  WizardResult.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/10/16.
//

import SwiftUI

struct WizardResultView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	@State private var dummyLearningPath:[String] = ["Course1","Course2","Course3"]
	
	
	var body: some View {
		VStack {
			HStack {
				Text("Discovered a lesson!")
					.font(.title)
					.bold()
				Spacer()
			}.padding([.leading,.trailing], 15)
			
			ScrollView(.vertical) {
				VStack {
					Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title))
						.font(.title2)
						.bold()
						.frame(maxWidth: .infinity, minHeight: 100)
						.padding([.leading, .trailing], 15)
						.background(.yellow)
						.cornerRadius(25)
					
					Text(scorewindData.currentLesson.description)
					
					HStack {
						Text("Your learning path")
							.font(.title2)
							.bold()
						Spacer()
					}.padding([.top,.bottom], 15)
					
					ForEach(dummyLearningPath, id:\.self) { course in
						Text(course)
							.font(.title2)
							.bold()
							.frame(maxWidth: .infinity, minHeight: 100)
							.padding([.leading, .trailing], 15)
							.background(.blue)
							.cornerRadius(25)
					}
					
				}.padding([.leading,.trailing], 15)
			}
		}
		.background(Color("AppBackground"))
		.onAppear(perform: {
			print("[debug] WizardResultView.onAppear, wizardStepNames \(studentData.wizardStepNames)")
		})
	}
}

struct WizardResult_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardResult
	
	static var previews: some View {
		WizardResultView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

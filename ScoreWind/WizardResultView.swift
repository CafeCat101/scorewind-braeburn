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
	@State private var showMeMore:Bool = false
	
	
	var body: some View {
		VStack {
			HStack {
				Text("Discovered a lesson!")
					.font(.title)
					.bold()
				Spacer()
			}
			
			if showMeMore == false {
				Spacer()
				Text("You've completed the wizard. Scorewind found lesson for you. \n\nTo learn more about the findings, please click \"Tell me more\""+". Thank you!")
				Spacer()
			}
			
			HStack {
				Text("The lesson")
					.font(.title2)
					.bold()
				Spacer()
			}.padding([.top,.bottom], 15)
			VStack {
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.wizardPickedLesson.title))
					.font(.title2)
					.bold()
					.padding([.top, .bottom], 15)
					.frame(maxWidth: .infinity, minHeight: 100)
					.background(.yellow)
					.cornerRadius(25)
				if showMeMore == false {
					Text(scorewindData.wizardPickedLesson.description)
						.padding([.leading, .bottom, .trailing], 15)
				}
				
			}
			.background {
				RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("AppYellow"))}
			
			
			Button(action: {
				withAnimation {
					showMeMore.toggle()
				}
			}, label: {
				Text(showMeMore ? "Show me less" : "Tell me more")
					.foregroundColor(Color("LessonListStatusIcon"))
					.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
					.background(Color("AppYellow"))
					.cornerRadius(26)
			})
			.padding([.top],15)
			Spacer()
			
			if showMeMore {
				ScrollView(.vertical) {
					VStack {
						HStack {
							Text("Your learning path")
								.font(.title2)
								.bold()
							Spacer()
						}.padding([.top,.bottom], 15)
						
						ForEach(studentData.wizardRange, id:\.self) { rangeItem in
							Text("\(getLessonTitle(courseID:rangeItem.courseID, lessonID:rangeItem.lessonID))")
								.foregroundColor(Color("LessonListStatusIcon"))
								.frame(maxWidth: .infinity, minHeight: 100)
								.padding([.leading, .trailing], 15)
								.background(Color("WizardRangeItemBackground"))
								.cornerRadius(25)
						}
						
					}
					
				}
			}
			
			
		}
		.background(Color("AppBackground"))
		.padding([.leading, .trailing], 15)
		.onAppear(perform: {
			print("[debug] WizardResultView.onAppear, wizardStepNames \(studentData.wizardStepNames)")
		})
	}
	
	private func getLessonTitle(courseID:Int, lessonID: Int) -> String {
		var title = "Lesson Title"
		
		let course:Course = scorewindData.allCourses.first(where: {$0.id == courseID}) ?? Course()
		let lesson:Lesson = course.lessons.first(where: {$0.id == lessonID}) ?? Lesson()
		if lesson.id > 0 {
			title = scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title)
		}
		
		return title
	}
}

struct WizardResult_Previews: PreviewProvider {
	@State static var tab = "TWizard"
	@State static var step:Page = .wizardResult
	
	static var previews: some View {
		WizardResultView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
	}
}

/**
 texts to replace
 "Discovered a lesson" - title to summerize the wizard result.
 "You've completed the wizard. Scorewind a found lesson for you." - paragraph to explain what does the title mean. ex: This is your next up comming lesson await for you to be completed.
 "Your learning path" - title to summerize the wizard.range
 "(optional text) below Your learning path" - paragraph to explain what does the content in wizard.range represent.
 */

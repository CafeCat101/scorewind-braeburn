//
//  WizardResultPathView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/21.
//

import SwiftUI

struct WizardResultPathView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@EnvironmentObject var store: Store
	@Binding var selectedTab:String
	@Binding var stepName:Page
	@ObservedObject var studentData:StudentData
	@Binding var showLessonView:Bool
	@Binding var showStore: Bool
	
	var body: some View {
		VStack {
			ForEach(studentData.wizardResult.learningPath) { pathItem in
				pathItemView(pathItem: pathItem)
				
				/*if pathItem.lessonID != studentData.wizardResult.learningPath[studentData.wizardResult.learningPath.count - 1].lessonID {
					HStack {
						Spacer()
						Label("Next", systemImage: "arrow.down")
							.labelStyle(.iconOnly)
						Spacer()
					}
				}*/
			}
		}
	}
	
	private func getItmeTitleTopPadding(courseID: Int) -> CGFloat {
		if courseID == scorewindData.currentCourse.id && studentData.wizardResult.learningPath.contains(where: {$0.lessonID == scorewindData.currentLesson.id}) == false {
			return 5
		} else {
			return 21
		}
	}
	
	@ViewBuilder
	private func pathItemView(pathItem: WizardLearningPathItem) -> some View {
		if pathItem.showCourseTitle {
			VStack(spacing:0) {
				if pathItem.courseID == scorewindData.currentCourse.id && studentData.wizardResult.learningPath.contains(where: {$0.lessonID == scorewindData.currentLesson.id}) == false {
					HStack {
						Spacer()
						Image(getIconTitleName())
							.resizable()
							.scaledToFit()
							.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
							.frame(maxHeight: 33)
						Spacer()
					}.padding(.top, 21)
					/*
					HStack {
						Spacer()
						HStack {
							HStack {
								VStack {
									Image(getIconTitleName())
										.resizable()
										.scaledToFit()
										.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
								}
								.frame(maxHeight: 24)
								Text("Currently")
									.bold()
									.foregroundColor(Color("Dynamic/DarkPurple"))
									.font(.subheadline)
									.frame(maxHeight: 24)
							}
							.padding(EdgeInsets(top: 10, leading: 22, bottom: 8, trailing: 31))
						}
						.background(
							RoundedCornersShape(corners: [.allCorners], radius: 17)
								.fill(Color("Dynamic/MainBrown"))
								.opacity(0.25)
						)
						.padding(EdgeInsets(top: 15, leading: 17, bottom: 0, trailing: 0))
						Spacer()
					}
					 */
				}
				
				VStack(alignment: .leading) {
					Text("Course")
						.font(.subheadline)
						.bold()
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.padding(.bottom, 12)
					HStack {
						Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: pathItem.courseTitle))")
							.bold()
							.foregroundColor(Color("Dynamic/MainBrown+6"))
						
						Spacer()
						Label("Go to course", systemImage: "arrow.right.circle.fill")
							.labelStyle(.iconOnly)
							.font(.title2)
							.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
					}
				}
				.padding(EdgeInsets(top: getItmeTitleTopPadding(courseID: pathItem.courseID), leading: 15, bottom: 21, trailing: 15))
				//.padding(15)
			}
			.background(
				RoundedRectangle(cornerRadius: CGFloat(17))
					.foregroundColor(Color("Dynamic/LightGreen"))
					.opacity(0.85)
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
			)
			.onTapGesture {
				goToCourse(toCourseID: pathItem.courseID)
			}
			.padding(.bottom, 6)
		}
		
		if (scorewindData.wizardPickedCourse.lessons[0].id != pathItem.lessonID) && (studentData.wizardResult.learningPath[0].lessonID == pathItem.lessonID) {
			VStack(spacing:0) {
				Label(title: {Text("dot")}, icon: {
					Image(systemName: "circle.fill")
						.resizable()
						.scaledToFit()
						.frame(width:3, height: 3)
				})
				.labelStyle(.iconOnly)
				.foregroundColor(Color("Dynamic/MainGreen"))
				.font(.headline)
				.padding(.bottom,3)
				Label(title: {Text("dot")}, icon: {
					Image(systemName: "circle.fill")
						.resizable()
						.scaledToFit()
						.frame(width:3, height: 3)
				})
				.labelStyle(.iconOnly)
				.foregroundColor(Color("Dynamic/MainGreen"))
				.font(.headline)
				.padding(.bottom,3)
				Label("Next", systemImage: "chevron.down")
					.labelStyle(.iconOnly)
					.foregroundColor(Color("Dynamic/MainGreen"))
					.font(.headline)
			}.padding([.top,.bottom],3)
		}
		
		//:: Lesson box
		HStack(spacing:0) {
			VStack(spacing:0) {
				Text("\(pathItem.friendlyID)")
					.font(.subheadline)
					.foregroundColor(Color("Dynamic/DarkPurple"))
					.padding(15)
					.frame(height: 55)
					.background(
						RoundedCornersShape(corners: [.topLeft, .bottomLeft], radius: 17)
							.fill(Color("Dynamic/MainBrown"))
							.opacity(0.25)
							//.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					)
					.padding(.top, 17)
				Spacer()
			}
			
			VStack(spacing:0) {
				VStack(alignment: .leading) {
					//:: show where to start in the learning path
					if pathItem.startHere {
						HStack {
							Spacer()
							
							if scorewindData.currentLesson.id == pathItem.lessonID {
								Image(getIconTitleName())
									.resizable()
									.scaledToFit()
									.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
									.frame(maxHeight: 33)
							}
							
							HStack {
								HStack {
									Image("resultFound")
										.resizable()
										.scaledToFit()
										.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
										.frame(maxHeight: 24)
									
									Text("Start Here")
										.bold()
										.foregroundColor(Color("Dynamic/DarkPurple"))
										.font(.subheadline)
										.frame(maxHeight: 24)
								}
								.padding(EdgeInsets(top: 10, leading: 22, bottom: 10, trailing: 25))
							}
							.background(
								RoundedCornersShape(corners: [.allCorners], radius: 17)
									.fill(Color("Dynamic/MainBrown"))
									.opacity(0.25)
							)
							
							Spacer()
						}
						.padding(.top, scorewindData.currentLesson.id == pathItem.lessonID ? 21 : 0)
					}
					
					//:: show this is the current lesson
					if scorewindData.currentLesson.id == pathItem.lessonID && pathItem.startHere == false {
						HStack {
							Spacer()
							Image(getIconTitleName())
								.resizable()
								.scaledToFit()
								.shadow(color: Color("Dynamic/ShadowReverse"), radius: CGFloat(3))
								.frame(maxHeight: 33)
							Spacer()
						}
						.padding(.top, 21)
					}
					
					HStack {
						if scorewindData.arrangedTitle(title: pathItem.lessonTitle, instrumentType: scorewindData.wizardPickedCourse.instrument).count > 1 {
							VStack(alignment:.leading) {
								Text(scorewindData.arrangedTitle(title: pathItem.lessonTitle, instrumentType: scorewindData.wizardPickedCourse.instrument)[0]).font(.caption)
								Text(scorewindData.arrangedTitle(title: pathItem.lessonTitle, instrumentType: scorewindData.wizardPickedCourse.instrument)[1])
									.bold()
									.fixedSize(horizontal: false, vertical: true)
							}.foregroundColor(Color("Dynamic/MainBrown+6"))
							
							/*(Text(scorewindData.arrangedTitle(title: pathItem.lessonTitle, instrumentType: scorewindData.wizardPickedCourse.instrument)[0]).font(.caption) + Text("\n") + Text(scorewindData.arrangedTitle(title: pathItem.lessonTitle, instrumentType: scorewindData.wizardPickedCourse.instrument)[1]).bold())
								.foregroundColor(Color("Dynamic/MainBrown+6"))
								.padding([.top,.bottom],6)*/
						} else {
							Text(scorewindData.arrangedTitle(title: pathItem.lessonTitle, instrumentType: scorewindData.wizardPickedCourse.instrument)[0])
								.bold()
								.fixedSize(horizontal: false, vertical: true)
								.foregroundColor(Color("Dynamic/MainBrown+6"))
						}
						
						Spacer()
						Label("Go to lesson", systemImage: "arrow.right.circle.fill")
							.labelStyle(.iconOnly)
							.font(.title2)
							.foregroundColor(Color("Dynamic/MainGreen")) //original is "Dynamic/MainBrown"
					}
				}
				.padding(EdgeInsets(top: scorewindData.currentLesson.id != pathItem.lessonID ? 21 : 5, leading: 16, bottom: 21, trailing: 16))
			}
			.frame(minHeight: 86)
			.background(
				RoundedCornersShape(corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 17)
					.fill(Color("Dynamic/LightGray"))
					.opacity(0.85)
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
				/*RoundedRectangle(cornerRadius: CGFloat(17))
					.foregroundColor(Color("Dynamic/LightGray"))
					.opacity(0.85)
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))*/
			)
			.onTapGesture {
				goToLesson(toCourseID: pathItem.courseID, toLessonID: pathItem.lessonID)
			}
			.padding(.bottom, 12)
		}
	}
	
	struct lessonItemInPath: ViewModifier {
		func body(content: Content) -> some View {
			content
				.foregroundColor(Color("LessonListStatusIcon"))
				.frame(maxWidth: .infinity, minHeight: 100)
				.padding([.leading, .trailing], 15)
				.background(Color("WizardRangeItemBackground"))
				.cornerRadius(25)
		}
	}

	private func goToLesson(toCourseID: Int, toLessonID: Int) {
		let theCourse = scorewindData.allCourses.first(where: {$0.id == toCourseID}) ?? Course()
		let theLesson = theCourse.lessons.first(where: {$0.id == toLessonID}) ?? Lesson()
		
		if theLesson.id > 0 {
			scorewindData.currentCourse = theCourse
			
			scorewindData.currentLesson = theLesson
			scorewindData.setCurrentTimestampRecs()
			scorewindData.lastPlaybackTime = 0.0
			
			if store.enablePurchase == false || (store.enablePurchase && scorewindData.wizardPickedCourse.id == toCourseID) || store.couponState == .valid {
				self.selectedTab = "TCourse"
				withAnimation(Animation.linear(duration: 0.13)) {
					showLessonView = true
				}
			} else {
				showStore = true
			}
			scorewindData.lessonChanged = true
		}
	}
	
	private func goToCourse(toCourseID: Int) {
		let theCourse = scorewindData.allCourses.first(where: {$0.id == toCourseID}) ?? Course()
		let theLesson = theCourse.lessons[0]
		scorewindData.currentCourse = theCourse
		scorewindData.currentLesson = theLesson
		scorewindData.setCurrentTimestampRecs()
		scorewindData.lastPlaybackTime = 0.0
		self.selectedTab = "TCourse"
		scorewindData.lessonChanged = true
	}
	
	private func experienceFeedbackToCase(caseValue: String) -> ExperienceFeedback {
		switch caseValue {
		case ExperienceFeedback.starterKit.rawValue:
			return .starterKit
		case ExperienceFeedback.continueLearning.rawValue:
			return .continueLearning
		case ExperienceFeedback.experienced.rawValue:
			return .experienced
		default:
			return .starterKit
		}
	}
	
	private func getIconTitleName() -> String {
		if scorewindData.wizardPickedCourse.instrument == InstrumentType.guitar.rawValue {
			return "iconGuitar"
		} else if scorewindData.wizardPickedCourse.instrument == InstrumentType.violin.rawValue {
			return "iconViolin"
		} else {
			return "feedbackYes"
		}
	}
}
/*
 struct WizardResultPathView_Previews: PreviewProvider {
 @State static var tab = "THome"
 @State static var step:Page = .wizardResult
 @State static var wizardResult: WizardResult = WizardResult()
 
 static var previews: some View {
 WizardResultPathView(selectedTab: $tab, stepName: $step, studentData: StudentData(), showLessonView: .constant(false)).environmentObject(ScorewindData())
 }
 }
 */

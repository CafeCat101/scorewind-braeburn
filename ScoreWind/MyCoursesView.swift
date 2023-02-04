//
//  MyCoursesView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct MyCoursesView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	@ObservedObject var downloadManager:DownloadManager
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var showTip = false
	@State private var saveLastUpdatedLesson:[Int:Lesson] = [:]
	@ObservedObject var studentData:StudentData
	@State private var listFilterDownloaded = false
	@State private var listFilterFavourite = false
	@State private var tipContent:AnyView = AnyView(Text("Tip"))
	@State private var userDefaults = UserDefaults.standard
	
	var body: some View {
		VStack {
			Label("My Courses", systemImage: "music.note")
				.labelStyle(.titleAndIcon)
				.foregroundColor(Color("AppBlackDynamic"))
			
			//::FILTER TAGS::
			ScrollView(.horizontal) {
				HStack {
					Label("Favourite", systemImage: "suit.heart")
						.fixedSize(horizontal: true, vertical: true)
						.labelStyle(.titleOnly)
						.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
						.background {
							RoundedRectangle(cornerRadius: 20)
								.stroke(Color("MyCourseFilterTagBorder"), lineWidth: 1)
								.background(
									RoundedRectangle(cornerRadius: 20)
										.fill(Color("MyCourseItem"))
										.opacity(listFilterFavourite ? 1 : 0)
								)
						}
						.foregroundColor(Color("MyCourseItemText"))
						.onTapGesture {
							withAnimation {
								listFilterFavourite.toggle()
							}
						}
						
					Label("Downloaded", systemImage: "arrow.down.circle.fill")
						.fixedSize(horizontal: true, vertical: true)
						.labelStyle(.titleOnly)
						.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
						.background {
							RoundedRectangle(cornerRadius: 20)
								.stroke(Color("MyCourseFilterTagBorder"), lineWidth: 1)
								.background(
									RoundedRectangle(cornerRadius: 20)
										.fill(Color("MyCourseItem"))
										.opacity(listFilterDownloaded ? 1 : 0)
								)
						}
						.foregroundColor(Color("MyCourseItemText"))
						.onTapGesture {
							withAnimation {
								listFilterDownloaded.toggle()
							}
							
						}
					Spacer()
				}.padding(EdgeInsets(top: 2, leading: 10, bottom: 10, trailing: 10))
			}
			
			//::MY COURSE LIST::
			ScrollViewReader { proxy in
				if studentData.myCourses.count > 0 {
					ScrollView {
						Spacer().frame(height:10)
						ForEach(studentData.myCourses) { aCourse in
							if courseItemVisibility(courseID: aCourse.courseID) {
								MyCouseItemview(selectedTab:$selectedTab ,aCourse: aCourse,downloadManager:downloadManager, studentData: studentData)
								.id(aCourse.courseID)
								.padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
							}
						}
					}
					.onAppear(perform: {
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
							if studentData.myCourses.firstIndex(where: {$0.courseID == scorewindData.currentCourse.id}) ?? -1 > -1 {
								print("[debug] MyCourseView, scrollView onAppear, currentCourse.id is found")
								withAnimation {
									proxy.scrollTo(scorewindData.currentCourse.id, anchor: .top)
								}
								
							}
						}
					})
					.onReceive(downloadManager.myCourseRebuildPublisher, perform: { pushDate in
						print("[debug] MyCourseView lessonList onRecieve, \(pushDate)")
						studentData.updateMyCourses(allCourses: scorewindData.allCourses)
						studentData.updateMyCoursesDownloadStatus(allCourses: scorewindData.allCourses, downloadManager: downloadManager)
					})
				} else {
					VStack {
						Spacer()
						Text("Looks like you haven't added any course to favourite or watched any lesson yet.")
							.padding(15)
						if scorewindData.currentCourse.id > 0 {
							Text("Look at my last viewed course and lesson now.")
								.padding(15)
						} else {
							Text("Ask wizard for a course or a lesson now.")
								.padding(15)
						}
						
						Button(action: {
							if scorewindData.currentCourse.id > 0 {
								selectedTab = "TCourse"
							} else {
								selectedTab = "TWizard"
							}
						}, label: {
							Text("Start").frame(minWidth:150)
						})
						.foregroundColor(Color("LessonListStatusIcon"))
						.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
						.background {
							RoundedRectangle(cornerRadius: 26)
								.foregroundColor(Color("AppYellow"))
						}
						Spacer()
					}
				}
			}
			//Spacer()
		}
		.background(Color("AppBackground"))
		.fullScreenCover(isPresented: $showTip, content: {
			TipTransparentModalView(showStepTip: $showTip, tipContent: $tipContent)
		})
		.onAppear(perform: {
			print("[debug] MyCourseView, onAppear")
			handleTip()
		})
	}
	
	private func handleTip() {
		let hideTips:[String] = userDefaults.object(forKey: "hideTips") as? [String] ?? []
		if hideTips.contains(Tip.myCourseView.rawValue) == false {
			print("[debug] MyCourseView, handleTip \(hideTips)")
			tipContent = AnyView(TipContentMakerView(showStepTip: $showTip, hideTipValue: Tip.myCourseView.rawValue, tipMainContent: AnyView(tipHere())))
			showTip = true
		}
	}
	
	@ViewBuilder
	private func tipHere() -> some View {
		VStack {
			Text("You'll find all of your favorite courses, lessons you've watched, and lessons you've finished here.")
				.font(.headline)
				.modifier(StepExplainingText())
			VStack(alignment:.leading) {
				Text("Meanwhile, you can also use \"Downloaded\" filter tag to access the offline courses quickly.")
					.modifier(TipExplainingParagraph())
				Text("Enjoy!")
					.modifier(TipExplainingParagraph())
			}.padding([.bottom],18)
			
		}.background {
			RoundedRectangle(cornerRadius: 26)
				.foregroundColor(Color("AppYellow"))
			.frame(width: UIScreen.main.bounds.width*0.9)}
	}
	
	private func courseItemVisibility(courseID: Int) -> Bool {
		var filterMatchCount = 0
		
		if listFilterDownloaded == false && listFilterFavourite == false {
			return true
		} else {
			if listFilterDownloaded {
				let getLessonCount = scorewindData.allCourses.first(where: {$0.id == courseID})?.lessons.count ?? 0
				if downloadManager.checkDownloadStatus(courseID: courseID, lessonsCount: getLessonCount) == DownloadStatus.downloaded {
					filterMatchCount = filterMatchCount + 1
				}
			}
			
			if listFilterFavourite {
				let findInMyCourses = studentData.myCourses.first(where: {$0.courseID == courseID}) ?? MyCourse()
				if findInMyCourses.isFavourite {
					filterMatchCount = filterMatchCount + 1
				}
			}
			
			if listFilterFavourite && listFilterDownloaded {
				if filterMatchCount == 2 {
					return true
				} else {
					return false
				}
			} else {
				if filterMatchCount > 0 {
					return true
				} else {
					return false
				}
			}
		}
	}
	

}

struct MyCoursesView_Previews: PreviewProvider {
	@State static var tab = "TMyCourses"
	static var previews: some View {
		MyCoursesView(selectedTab:$tab, downloadManager: DownloadManager(), studentData: StudentData()).environmentObject(ScorewindData())
	}
}

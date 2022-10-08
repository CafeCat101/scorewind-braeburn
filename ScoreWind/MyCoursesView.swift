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
	
	var body: some View {
		VStack {
			Label("My Courses", systemImage: "music.note")
				.labelStyle(.titleAndIcon)
			
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
					Spacer()
					Text("After you've completed or watched a lesson, you can find the course for it here.")
						.padding(15)
					Spacer()
				}
			}
			Spacer()
		}
		.onAppear(perform: {
			print("[debug] MyCourseView, onAppear")
			
			//DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				//withAnimation {
					//studentData.myCourses = scorewindData.studentData.myCourses
					//print("[debug] MyCourseView, getMyCourses.count \(studentData.myCourses.count)")
				//}
				
			//}
			
			if scorewindData.getTipCount(tipType: .myCourseView) < 1 {
				scorewindData.currentTip = .myCourseView
				showTip = true
			}
		})
		.fullScreenCover(isPresented: $showTip, content: {
			TipModalView()
		})
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

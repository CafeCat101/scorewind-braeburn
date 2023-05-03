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
	@Environment(\.verticalSizeClass) var verticalSize
	@Environment(\.colorScheme) var colorScheme
	
	var body: some View {
		VStack(spacing:0) {
			Label(title: {
				Text("My Courses")
					.font(verticalSize == .regular ? .title : .title3)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.bold()
			}, icon: {
				Image(systemName: "music.note.list")
			})
			.padding(.top,5)
			
			HStack(spacing:0){
				if verticalSize == .compact {
					//::FILTER TAGS::
					if studentData.myCourses.count > 0 {
						VStack{
							displayFeatureMenu(minWidth: 150)
						}
						.padding([.leading, .trailing], 15)
						.padding([.top,.bottom], 10)
						.frame(width: UIScreen.main.bounds.size.width*0.25)
					}
				}

				//::MY COURSE LIST::
				VStack {
					if verticalSize == .regular {
						//::FILTER TAGS::
						if studentData.myCourses.count > 0 {
							//ScrollView(.horizontal) {
								HStack {
									displayFeatureMenu(minWidth: (UIScreen.main.bounds.size.width - 30)*0.3 )
									Spacer()
								}
								.padding([.leading, .trailing], 15)
								.padding([.top,.bottom], 10)
							//}
						}
					}
					ScrollViewReader { proxy in
						if studentData.myCourses.count > 0 {
							ScrollView {
								VStack(spacing:0){
									Spacer().frame(height:10)
									ForEach(studentData.myCourses) { aCourse in
										if courseItemVisibility(courseID: aCourse.courseID) {
											MyCouseItemview(selectedTab:$selectedTab ,aCourse: aCourse,downloadManager:downloadManager, studentData: studentData)
											.id(aCourse.courseID)
										}
									}
									.padding([.leading,.trailing], 15)
									.padding([.bottom],6)
									
									Spacer().frame(height: 50)
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
									.foregroundColor(Color("Dynamic/MainBrown+6"))
									.padding(30)
								/*
								Button(action: {
									if scorewindData.currentCourse.id > 0 {
										selectedTab = "TCourse"
									} else {
										selectedTab = "THome"
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
								*/
								HStack {
									Text(getExplainText())
										.font(.headline)
										.foregroundColor(Color("Dynamic/MainBrown+6"))
									Spacer()
									Label("Go now", systemImage: "arrow.right.circle.fill")
										.labelStyle(.iconOnly)
										.font(.title2)
										.foregroundColor(Color("Dynamic/MainGreen")) //original is "Dynamic/MainBrown"
								}
								.padding(30)
								.frame(width: verticalSize == .regular ? UIScreen.main.bounds.size.width*0.8 : UIScreen.main.bounds.size.width*0.6)
								.background(
									RoundedCornersShape(corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 17)
										.fill(Color("Dynamic/LightGray"))
										.opacity(0.85)
										.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
								)
								.onTapGesture {
									if scorewindData.currentCourse.id > 0 {
										selectedTab = "TCourse"
									} else {
										selectedTab = "THome"
									}
								}
								
								Spacer()
							}
							.background {
								VStack {
									Spacer()
									Image("play_any")
										.resizable()
										.scaledToFit()
										.opacity(0.3)
										.padding(30)
								}
								
							}
						}
					}
				}
			}
			
			
			
			//Spacer()
			Divider()
		}
		.background(colorScheme == .light ? appBackgroundImage(colorMode: colorScheme) : appBackgroundImage(colorMode: colorScheme))
		.fullScreenCover(isPresented: $showTip, content: {
			TipTransparentModalView(showStepTip: $showTip, tipContent: $tipContent)
		})
		.onAppear(perform: {
			print("[debug] MyCourseView, onAppear")
			handleTip()
		})
	}
	
	@ViewBuilder
	private func displayFeatureMenu(minWidth: CGFloat) -> some View {
		//ScrollView(.horizontal) {
			//Group {
				/*Label("Favourite", systemImage: "suit.heart")
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
					}*/
				Label(title:{
					Text("Favorites")
						.foregroundColor( listFilterFavourite ? Color("Dynamic/ShadowReverse") : Color("Dynamic/MainBrown+6"))
				},icon:{
					Image(systemName: "suit.heart.fill")
						.foregroundColor(listFilterFavourite ? Color("Dynamic/ShadowReverse") : Color("Dynamic/IconHighlighted"))
				})
					.fixedSize(horizontal: true, vertical: true)
					.frame(minWidth: minWidth, maxHeight:20)
					.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
					.background(
						RoundedRectangle(cornerRadius: CGFloat(17))
							.foregroundColor(Color("Dynamic/MainBrown"))
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							.opacity(listFilterFavourite ? 0.85 : 0.25)
							.overlay {
								RoundedRectangle(cornerRadius: 17)
									.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
							}
					)
					.onTapGesture {
						withAnimation {
							listFilterFavourite.toggle()
						}
					}
				
				Label(title:{
					Text("Downloaded")
						.foregroundColor(listFilterDownloaded ? Color("Dynamic/ShadowReverse") : Color("Dynamic/MainBrown+6"))
				}, icon:{
					Image(systemName: "arrow.down.circle.fill")
						.foregroundColor(listFilterDownloaded ? Color("Dynamic/ShadowReverse") : Color("Dynamic/IconHighlighted"))
				})
					.fixedSize(horizontal: true, vertical: true)
					.frame(minWidth: minWidth, maxHeight:20)
					.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
					//.foregroundColor(Color("Dynamic/IconHighlighted"))
					.background(
						RoundedRectangle(cornerRadius: CGFloat(17))
							.foregroundColor(Color("Dynamic/MainBrown"))
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
							.opacity(listFilterDownloaded ? 0.85 : 0.25)
							.overlay {
								RoundedRectangle(cornerRadius: 17)
									.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
							}
					)
					.onTapGesture {
						withAnimation {
							listFilterDownloaded.toggle()
						}
					}
				
				//Spacer()
			//}
			//.padding([.leading, .trailing], 15)
			//.padding([.top,.bottom], 10)
		//}
	}
	
	private func getExplainText() -> String{
		if scorewindData.currentCourse.id > 0 {
			return "Look at my last viewed course and lesson now."
		} else {
			if studentData.wizardResult.learningPath.count == 0 {
				return "Ask ScoreWind for a course or a lesson now."
			} else {
				return "See the course and the lesson ScoreWind found last time."
			}
		}
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
		VStack (spacing: 0) {
			HStack(spacing:0) {
				Label("tip", systemImage: "lightbulb")
					.labelStyle(.iconOnly)
					.font(.title2)
					.foregroundColor(Color("MainBrown+6"))
					.shadow(color: Color("Dynamic/ShadowReverse"),radius: CGFloat(10))
					.padding(EdgeInsets(top: 8, leading: 15, bottom: 4, trailing: 15))
					.background(
						RoundedCornersShape(corners: verticalSize == .regular ? [.topLeft, .topRight] : [.allCorners], radius: 10)
							.fill(Color("AppYellow"))
							.opacity(0.90)
					)
				Spacer()
			}.padding(.leading, 28)
			
			VStack(spacing:0) {
				ScrollView {
					VStack(alignment: .leading) {
						HStack {
							Spacer()
							Label("My Courses", systemImage: "music.note.list")
								.labelStyle(.iconOnly)
								.font(.title)
								.padding(.bottom, 5)
							Spacer()
						}
						HStack {
							Spacer()
							Text("You'll find all your favorite or downloaded courses here.")
							.font(.headline)
							.padding(.bottom, 15)
							.multilineTextAlignment(.center)
							Spacer()
						}

						Divider().padding(.bottom, 20)
						(Text("This list offers you an overview of how many lessons in a course you've ")+Text(Image(systemName: "eye.circle.fill"))+Text(" watched or ")+Text(Image(systemName: "checkmark.circle.fill"))+Text(" completed.")).padding(.bottom, 15)
						(Text("In the list, you can also ")+Text(Image(systemName: "arrow.left.circle.fill"))+Text(" revisit your last completed or watched lesson in a course for a quick brushup.")).padding(.bottom, 15)
					}
					.foregroundColor(Color("MainBrown+6"))
					.padding(EdgeInsets(top: 18, leading: 40, bottom: 18, trailing: 40))
				}
			}
			.background(
				RoundedRectangle(cornerRadius: CGFloat(10))
					.foregroundColor(Color("AppYellow"))
					.shadow(color: Color("Dynamic/ShadowLight"),radius: CGFloat(7))
					.opacity(0.90)
			)
			.padding([.leading,.trailing],15)
		}
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

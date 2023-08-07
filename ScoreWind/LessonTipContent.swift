//
//  LessonTipContent.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/8/7.
//

import SwiftUI

struct LessonTipContent: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Environment(\.verticalSizeClass) var verticalSize
	
	var body: some View {
		VStack(alignment: .leading) {
			VStack(spacing: 0) {
				HStack {
					Spacer()
					Label(title: {Text("Lesson")}, icon: {
						Image(scorewindData.currentCourse.instrument)
							.resizable()
							.scaledToFit()
							.rotationEffect(Angle(degrees: 45))
							.frame(maxHeight: 80)
					})
					.labelStyle(.iconOnly)
					.padding(.bottom, 5)
					Spacer()
				}
				HStack {
					Spacer()
					Text("The Lesson")
						.font(.headline)
						.padding(.bottom, 15)
						.multilineTextAlignment(.center)
						.shadow(color:.white,radius: 15)
					Spacer()
				}
			}
			
			Group {
				Divider().padding(.bottom, 20)
				VStack(alignment: .center) {
					HStack {
						Spacer()
						if scorewindData.currentTimestampRecs.count == 0 {
							Text("Lesson is About to Start").font(.title2).bold()
						} else{
							Text("Watch and Practice").font(.title2).bold()
						}
						
						Spacer()
					}.padding([.bottom],15)
					
					if scorewindData.currentTimestampRecs.count == 0 {
						Text("Use the Headset")
							.font(.headline)
						if scorewindData.currentCourse.instrument == InstrumentType.guitar.rawValue {
							VideoLoopView(videoURL:URL(fileURLWithPath: "Ricardo_Headset_UltraHD_720", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: getVideoSize(), height: getVideoSize())
								.padding([.bottom], 15)
						} else {
							VideoLoopView(videoURL:URL(fileURLWithPath: "Esin_Headset_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: getVideoSize(), height: getVideoSize())
								.padding([.bottom], 15)
						}
						
						Text("Find a position at eye level for yor device.")
							.font(.headline)
						VideoLoopView(videoURL:URL(fileURLWithPath: "DIY_Notestannd_HD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: getVideoSize(), height: getVideoSize())
							.padding([.bottom], 15)
					} else {
						Text("Control the video playback by tapping the bar.")
							.font(.headline)
						VideoLoopView(videoURL:URL(fileURLWithPath: scorewindData.currentCourse.instrument == InstrumentType.guitar.rawValue ? "Ricardo_Notestand_TapA_UltraHD" : "Esin_Notestand_TapA_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: getVideoSize(), height: getVideoSize())
							.padding([.bottom], 15)
						
						Text("Use the Headset")
							.font(.headline)
						if scorewindData.currentCourse.instrument == InstrumentType.guitar.rawValue {
							VideoLoopView(videoURL:URL(fileURLWithPath: "Ricardo_Headset_UltraHD_720", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: getVideoSize(), height: getVideoSize())
								.padding([.bottom], 15)
						} else {
							VideoLoopView(videoURL:URL(fileURLWithPath: "Esin_Headset_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: getVideoSize(), height: getVideoSize())
								.padding([.bottom], 15)
						}
					}
				}
			}
			
			Divider().padding(.bottom, 20)
			HStack {
				Spacer()
				VStack() {
					Text("Support Any Orientation")
						.font(.title2).bold()
					VideoLoopView(videoURL:URL(fileURLWithPath: "alpha-phone-rotation", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: getVideoSize(), height: getVideoSize())
						.overlay(Circle().fill(Color.black).opacity(0.3))
						.padding([.bottom], 15)
				}
				Spacer()
			}
			
			Group {
				Divider().padding(.bottom, 20)
				HStack {
					Spacer()
					Text("While Learning").font(.title2).bold()
					Spacer()
				}.padding(.bottom, 15)
				
				VStack(alignment: .leading) {
					//Label(title: {Text("list.bullet.circle")}, icon: {Image(systemName: "list.bullet.circle")})
					HStack {
						Label("Features", systemImage: "list.bullet.circle")//music.note.house.fill
							.labelStyle(.iconOnly)
							.font(.title)
						Text("Feature List")
						.font(.headline)
					}.padding(.bottom, 8)
					HStack {
						Label("Detail", systemImage: "doc.plaintext")//music.note.house.fill
							.labelStyle(.iconOnly)
							.font(.title)
						Text("Lesson Details")
						.font(.headline)
					}.padding(.bottom, 8)
					HStack {
						Label("Complete", systemImage: "checkmark.circle")//music.note.house.fill
							.labelStyle(.iconOnly)
							.font(.title)
						Text("Mark this Lesson Finished")
						.font(.headline)
					}.padding(.bottom, 15)
				}
				
				Divider().padding(.bottom, 20)
				(Text("At last, ")+Text(Image(systemName: "chevron.backward"))+Text(" will take you back to see the course. Enjoy!")).padding(.bottom, 15)
			}
		}
		.foregroundColor(Color("MainBrown+6"))
		.padding(EdgeInsets(top: 18, leading: 40, bottom: 18, trailing: 40))
	}
	
	private func getVideoSize() -> CGFloat {
		if verticalSize == .regular {
			return UIScreen.main.bounds.width*0.6
		} else {
			return UIScreen.main.bounds.height*0.5
		}
	}
}

struct LessonTipContent_Previews: PreviewProvider {
	static var previews: some View {
		LessonTipContent()
	}
}

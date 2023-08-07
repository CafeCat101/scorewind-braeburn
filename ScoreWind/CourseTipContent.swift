//
//  CourseTipContent.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/7/30.
//

import SwiftUI

struct CourseTipContent: View {
	var instrument:String
	@Environment(\.verticalSizeClass) var verticalSize
	
	var body: some View {
		if verticalSize == .regular {
			VStack {
				displayVideoClip()
				displayFeatureTips()
			}
		} else {
			HStack {
				displayVideoClip()
				VStack {
					displayFeatureTips()
				}.frame(width: UIScreen.main.bounds.width * 0.6)
			}
		}
	}
	
	@ViewBuilder
	private func displayVideoClip() -> some View {
		if instrument == InstrumentType.guitar.rawValue {
			VideoLoopView(videoURL:URL(fileURLWithPath: "Ricardo_Guitar_Full_Body_HD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: getVideoSize(), height: getVideoSize())
				.padding([.bottom], 15)
			Divider().padding(.bottom, 20)
		} else if instrument == InstrumentType.violin.rawValue {
			VideoLoopView(videoURL:URL(fileURLWithPath: "Esin_Violin_Full_Body_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: getVideoSize(), height: getVideoSize())
				.padding([.bottom], 15)
			Divider().padding(.bottom, 20)
		}
	}
	
	@ViewBuilder
	private func displayFeatureTips() -> some View {
		/*VStack(){
			Text("See Your Progress").font(.title2).bold().padding([.bottom],15)
			HStack {
				Image(systemName: "eye.circle.fill")
				Text("Lesson you've watched.")
				Spacer()
			}.padding(.bottom, 15)
			HStack{
				Image(systemName: "checkmark.circle.fill")
				Text("Lessons you've completed.")
				Spacer()
			}.padding(.bottom, 15)
		}*/
		Text("See Your Progress").font(.title2).bold().padding([.bottom],15)
		VStack(alignment:.leading) {
			Label("Lesson you've watched.", systemImage: "eye.circle.fill").padding(.bottom, 15)
			Label("Lessons you've completed.", systemImage: "checkmark.circle.fill").padding(.bottom, 15)
		}
		
		Divider().padding(.bottom, 20)
		Text("Improve the Learning Experience").font(.title2).bold().padding([.bottom],15).multilineTextAlignment(.center)
		VStack(alignment:.leading) {
			Label("Course details", systemImage: "doc.plaintext").padding(.bottom, 15)
			Label("Mark your favorite", systemImage: "suit.heart").padding(.bottom, 15)
			Label("Download coure videos for your offline moments", systemImage: "arrow.down.circle").padding(.bottom, 15)
		}
	}
	
	private func getVideoSize() -> CGFloat {
		if verticalSize == .regular {
			return UIScreen.main.bounds.width*0.6
		} else {
			return UIScreen.main.bounds.height*0.5
		}
	}
}

struct CourseTipContent_Previews: PreviewProvider {
	static var previews: some View {
		CourseTipContent(instrument: InstrumentType.piano.rawValue)
	}
}

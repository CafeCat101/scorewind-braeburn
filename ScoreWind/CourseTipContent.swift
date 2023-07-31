//
//  CourseTipContent.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/7/30.
//

import SwiftUI

struct CourseTipContent: View {
	var instrument:String
	var body: some View {
		VStack() {
			if instrument == InstrumentType.guitar.rawValue {
				VideoLoopView(videoURL:URL(fileURLWithPath: "Ricardo_Guitar_Full_Body_HD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.6)
					.padding([.bottom], 15)
				Divider().padding(.bottom, 20)
			} else if instrument == InstrumentType.violin.rawValue {
				VideoLoopView(videoURL:URL(fileURLWithPath: "Esin_Violin_Full_Body_UltraHD", relativeTo: Bundle.main.resourceURL!.appendingPathComponent("sub")).appendingPathExtension("mp4")).frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.6)
					.padding([.bottom], 15)
				Divider().padding(.bottom, 20)
			}
			
			VStack(){
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
			}
			
			
			Divider().padding(.bottom, 20)
			Text("Improve the Learning Experience").font(.title2).bold().padding([.bottom],15).multilineTextAlignment(.center)
			VStack(alignment:.leading) {
				Label("Course details", systemImage: "doc.plaintext").padding(.bottom, 15)
				Label("Mark your favorite", systemImage: "suit.heart").padding(.bottom, 15)
				Label("Download coure videos for your offline moments", systemImage: "arrow.down.circle").padding(.bottom, 15)
			}
			
			
			/*Image(systemName: "doc.plaintext")
			 Text("Course details")
			 .padding(.bottom, 15)
			 Image(systemName: "suit.heart")
			 Text("Mark your favorite")
			 .padding(.bottom, 15)
			 Image(systemName: "arrow.down.circle")
			 Text("Download coure videos for your offline moments")
			 .padding(.bottom, 15)*/
			
			
			/*Divider().padding(.bottom, 20)
			 Text("Use features in the course to improve your learning experience.").padding(.bottom, 15)
			 (Text("Click ")+Text(Image(systemName: "doc.plaintext"))+Text(" to learn what this course is about in detail.")).padding(.bottom, 8)
			 (Text(Image(systemName: "suit.heart"))+Text(" Mark this course as your favorite for revisiting in the future.")).padding(.bottom, 8)
			 (Text(Image(systemName: "arrow.down.circle"))+Text(" Download the course videos for your offline moments.")).padding(.bottom, 15)*/
		}
	}
}

struct CourseTipContent_Previews: PreviewProvider {
	static var previews: some View {
		CourseTipContent(instrument: InstrumentType.piano.rawValue)
	}
}

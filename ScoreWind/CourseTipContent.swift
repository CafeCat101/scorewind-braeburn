//
//  CourseTipContent.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/7/30.
//

import SwiftUI

struct CourseTipContent: View {
	var instrument:InstrumentType
	var body: some View {
		VStack() {
			if instrument == .guitar {
				
			} else if instrument == .violin {
				
			} else {
				VStack(){
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
				Image(systemName: "doc.plaintext")
				Text("Course details")
					.padding(.bottom, 15)
				Image(systemName: "suit.heart")
				Text("Mark your favorite")
					.padding(.bottom, 15)
				Image(systemName: "arrow.down.circle")
				Text("Download coure videos for your offline moments")
					.padding(.bottom, 15)
				
				
				/*Divider().padding(.bottom, 20)
				Text("Use features in the course to improve your learning experience.").padding(.bottom, 15)
				(Text("Click ")+Text(Image(systemName: "doc.plaintext"))+Text(" to learn what this course is about in detail.")).padding(.bottom, 8)
				(Text(Image(systemName: "suit.heart"))+Text(" Mark this course as your favorite for revisiting in the future.")).padding(.bottom, 8)
				(Text(Image(systemName: "arrow.down.circle"))+Text(" Download the course videos for your offline moments.")).padding(.bottom, 15)*/
			}
		}
	}
}

struct CourseTipContent_Previews: PreviewProvider {
	static var previews: some View {
		CourseTipContent(instrument: .piano)
	}
}

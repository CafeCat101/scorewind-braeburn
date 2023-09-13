//
//  LearningPathView2.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/9/13.
//

import SwiftUI

struct LearningPathView2: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Environment(\.verticalSizeClass) var verticalSize
	@Environment(\.colorScheme) var colorScheme
	@State private var showDemoLesson = false
	
	var body: some View {
		ScrollView(.vertical) {
			Text("Starter Path")
				.font(verticalSize == .regular ? .title : .title2)
				.foregroundColor(Color("Dynamic/MainBrown+6"))
				.bold()
				.padding([.bottom], 15)
			
			VStack(spacing:0){
				/*VStack{
					Spacer()
					/*Image("guitar")
						.resizable()
						.scaledToFit()
						.rotationEffect(Angle(degrees: 65))
						.frame(width:150)*/
					HStack {
						Spacer()
						Text("Know your Instrument")
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.bold()
							.padding([.top], 5)
							.font(.title2)
							.shadow(color: .white,radius: CGFloat(4))
						Spacer()
					}
					Spacer()
				}
				.frame(minHeight: 150)
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/MainBrown"))
						.opacity(colorScheme == .light ? 0.25 : 0.08)
						.background(
							Image("guitar")
							.resizable()
							.scaledToFit()
							.rotationEffect(Angle(degrees: 65))
							.frame(width:150)
							.opacity(0.7)
						)
				)
				.padding([.leading,.trailing], 15)*/
				VStack{
					Spacer()
					Image("guitar")
						.resizable()
						.scaledToFit()
						.rotationEffect(Angle(degrees: 65))
						.frame(width:150)
					HStack {
						Spacer()
						Text("Know Your Instrument")
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.bold()
							.padding([.top], 5)
							.font(.title2)
							.shadow(color: .white,radius: CGFloat(4))
							.multilineTextAlignment(.center)
						Spacer()
					}
					Spacer()
				}
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/MainBrown"))
						.opacity(colorScheme == .light ? 0.25 : 0.08)
				)
				.padding([.leading,.trailing], 15)

				HStack(spacing:0){
					VStack(alignment: .leading) {
						HStack {
							Text("Introduction to Guitar")
								.bold()
								.foregroundColor(Color("Dynamic/MainBrown+6"))
							Spacer()
							Label("Go to course", systemImage: "arrow.right.circle.fill")
								.labelStyle(.iconOnly)
								.font(.title2)
								.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
						}
						Text("Level1")
							.font(.caption)
							.bold()
						
						HStack {
							//Text("8 Lessons")
							Spacer()
							Text("25 min. and 7 sec.")
						}.padding([.top],5)
						
						viewLessonsMenu(lessonCount: 8)
					}
					.padding(EdgeInsets(top: 21, leading: 15, bottom: 21, trailing: 15))
					//.padding(15)
				}
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/LightGreen"))
						.opacity(0.85)
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
				)
				.padding(EdgeInsets(top: 4, leading: 15, bottom: 0, trailing: 15))
				//:::::::::::::::::::
				Rectangle()
					.foregroundColor(Color("Dynamic/MainGreen"))
					.opacity(colorScheme == .light ? 0.85 : 0.08)
					//.rotationEffect(Angle(degrees: 45))
					.frame(width:8, height:20)
					//.padding([.top,.bottom],-6)
				//:::::::::::::::::::
				Group {
					HStack(spacing:0){
						VStack(alignment: .leading) {
							HStack {
								Text("Play With Right Hand")
									.bold()
									.foregroundColor(Color("Dynamic/MainBrown+6"))
								Spacer()
								Label("Go to course", systemImage: "arrow.right.circle.fill")
									.labelStyle(.iconOnly)
									.font(.title2)
									.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
							}
							Text("Level 2")
								.font(.caption)
								.bold()
							HStack {
								//Text("5 Lessons")
								Spacer()
								Text("28 min. and 3 sec.")
							}.padding([.top],5)
							
							viewLessonsMenu(lessonCount: 5)
								.onTapGesture {
									showDemoLesson.toggle()
								}
						}
						.padding(EdgeInsets(top: 21, leading: 15, bottom: 21, trailing: 15))
						//.padding(15)
					}
					.background(
						RoundedRectangle(cornerRadius: CGFloat(17))
							.foregroundColor(Color("Dynamic/LightGreen"))
							.opacity(0.85)
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					)
					.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
					if showDemoLesson {
						Group{
							HStack(spacing:0){
								Spacer()
								VStack(spacing:0){
									demoLessonItem()
										.padding([.top],5)
									Rectangle()
										.fill(Color("Dynamic/LightGray"))
										.opacity(0.85)
										.frame(width:8, height:20)
									demoLessonItem()
									Rectangle()
										.fill(Color("Dynamic/LightGray"))
										.opacity(0.85)
										.frame(width:8, height:20)
									demoLessonItem()
								}
							}
						}
					}
					
					//:::::::::::::::::::
					Rectangle()
						.foregroundColor(Color("Dynamic/MainGreen"))
						.opacity(colorScheme == .light ? 0.85 : 0.08)
						//.rotationEffect(Angle(degrees: 45))
						.frame(width:8, height:20)
						//.padding([.top,.bottom],-6)
					//:::::::::::::::::::
				}
				
				HStack(spacing:0){
					VStack(alignment: .leading) {
						HStack {
							Text("Play With Left Hand")
								.bold()
								.foregroundColor(Color("Dynamic/MainBrown+6"))
							Spacer()
							Label("Go to course", systemImage: "arrow.right.circle.fill")
								.labelStyle(.iconOnly)
								.font(.title2)
								.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
						}
						Text("Level3")
							.font(.caption)
							.bold()
						HStack {
							//Text("5 Lessons")
							Spacer()
							Text("28 min. and 3 sec.")
						}.padding([.top],5)
						
						viewLessonsMenu(lessonCount: 9)
					}
					.padding(EdgeInsets(top: 21, leading: 15, bottom: 21, trailing: 15))
					//.padding(15)
				}
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/LightGreen"))
						.opacity(0.85)
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
				)
				.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
				//:::::::::::::::::::
				Rectangle()
					.foregroundColor(Color("Dynamic/MainGreen"))
					.opacity(colorScheme == .light ? 0.85 : 0.08)
					.frame(width:8, height:20)
				//:::::::::::::::::::
				VStack{
					Spacer()
					Image("guitar")
						.resizable()
						.scaledToFit()
						.rotationEffect(Angle(degrees: 65))
						.frame(width:150)
					HStack {
						Spacer()
						Text("Make Sounds and Learn How to Read Notes")
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.bold()
							.padding([.top], 5)
							.font(.title2)
							.shadow(color: .white,radius: CGFloat(4))
							.multilineTextAlignment(.center)
						Spacer()
					}
					Spacer()
				}
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/MainBrown"))
						.opacity(colorScheme == .light ? 0.25 : 0.08)
				)
				.padding([.leading,.trailing], 15)
				HStack(spacing:0){
					VStack(alignment: .leading) {
						HStack {
							Text("The Strings' Note Names and Numbers - Trebles With i,m,a")
								.bold()
								.foregroundColor(Color("Dynamic/MainBrown+6"))
							Spacer()
							Label("Go to course", systemImage: "arrow.right.circle.fill")
								.labelStyle(.iconOnly)
								.font(.title2)
								.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
						}
						Text("Level 4")
							.font(.caption)
							.bold()
						HStack {
							//Text("5 Lessons")
							Spacer()
							Text("35 min. and 18 sec.")
						}.padding([.top],5)
						viewLessonsMenu(lessonCount: 14)
					}
					.padding(EdgeInsets(top: 21, leading: 15, bottom: 21, trailing: 15))
					//.padding(15)
				}
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("Dynamic/LightGreen"))
						.opacity(0.85)
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
				)
				.padding(EdgeInsets(top: 4, leading: 15, bottom: 0, trailing: 15))
				//:::::::::::::::::::
				Rectangle()
					.foregroundColor(Color("Dynamic/MainGreen"))
					.opacity(colorScheme == .light ? 0.85 : 0.08)
					.frame(width:8, height:20)
				//:::::::::::::::::::
			}
			
			
			
			
			
		}
		.background(colorScheme == .light ? appBackgroundImage(colorMode: colorScheme) : appBackgroundImage(colorMode: colorScheme))
	}
	
	@ViewBuilder
	private func viewLessonsMenu(lessonCount: Int) -> some View {
		/*Label(title:{
			Text("\(lessonCount) Lessons")
		}, icon: {
			Image(systemName: "tray.2")
		})
			.frame(maxHeight:20)
			.labelStyle(.titleAndIcon)
			.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
			.foregroundColor(Color("Dynamic/LightGray"))
			.background(
				RoundedRectangle(cornerRadius: CGFloat(17))
					.foregroundColor(Color("Dynamic/MainBrown"))
					.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
					.opacity(0.85)
					.overlay {
						RoundedRectangle(cornerRadius: 17)
							.stroke(Color("Dynamic/DarkGray"), lineWidth: 1)
					}
			)*/
		Text("8 Lessons")
	}
	
	@ViewBuilder
	private func demoLessonItem() -> some View {
		VStack(spacing:0) {
			VStack(alignment: .leading) {
				HStack {
					Text("A Lesson Title")
						.bold()
						.fixedSize(horizontal: false, vertical: true)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
					Spacer()
					Label("Go to lesson", systemImage: "arrow.right.circle.fill")
						.labelStyle(.iconOnly)
						.font(.title2)
						.foregroundColor(Color("Dynamic/MainGreen")) //original is "Dynamic/MainBrown"
				}
			}
			.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
		}
		.frame(maxWidth:UIScreen.main.bounds.size.width*0.8, minHeight: 86)
		.background(
			RoundedCornersShape(corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 17)
				.fill(Color("Dynamic/LightGray"))
				.opacity(0.85)
				.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
		)
		.padding([.leading,.trailing],15)
	}
}

struct LearningPathView2_Previews: PreviewProvider {
	static var previews: some View {
		LearningPathView2()
	}
}

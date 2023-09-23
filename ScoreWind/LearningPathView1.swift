//
//  LearningPathView1.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/9/14.
//

import SwiftUI

struct LearningPathView1: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Environment(\.verticalSizeClass) var verticalSize
	@Environment(\.colorScheme) var colorScheme
	
	var body: some View {
		VStack(spacing:0){
			ScrollView(.vertical) {
				Text("Starter Path")
					.font(verticalSize == .regular ? .title : .title2)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.bold()
				
				VStack(spacing:0){
					VStack {
						Text("Know your instrument")
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.bold()
							.padding([.top], 21)
							.font(.title2)
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing:0) {
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
								.frame(width: UIScreen.main.bounds.width*0.8)
								.padding(15)
								
								
								HStack(spacing:0){
									VStack(alignment: .leading) {
										HStack {
											Text("Playing With the Left Hand")
												.bold()
												.foregroundColor(Color("Dynamic/MainBrown+6"))
											
											Spacer()
											Label("Go to course", systemImage: "arrow.right.circle.fill")
												.labelStyle(.iconOnly)
												.font(.title2)
												.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
										}
										Text("Level2")
											.font(.caption)
											.bold()
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
								.frame(width: UIScreen.main.bounds.width*0.8)
								.padding(15)
								
								HStack(spacing:0){
									VStack(alignment: .leading) {
										HStack {
											Text("Playing With the Right Hand")
												.bold()
												.foregroundColor(Color("Dynamic/MainBrown+6"))
											
											Spacer()
											Label("Go to course", systemImage: "arrow.right.circle.fill")
												.labelStyle(.iconOnly)
												.font(.title2)
												.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
										}
										Text("Level 3")
											.font(.caption)
											.bold()
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
								.frame(width: UIScreen.main.bounds.width*0.8)
								.padding(15)
							}
							
						}
					}
					.background(
						RoundedRectangle(cornerRadius: CGFloat(17))
							.foregroundColor(Color("Dynamic/MainBrown"))
							.opacity(colorScheme == .light ? 0.25 : 0.08)
					)
					.padding([.leading,.trailing], 15)
					//:::::::::::::::::::
					Rectangle()
						.foregroundColor(Color("Dynamic/MainBrown"))
						.opacity(colorScheme == .light ? 0.25 : 0.08)
						.frame(width:5, height:50)
					//:::::::::::::::::::
					VStack {
						Text("Make sounds and learn how to read notes")
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.bold()
							.font(.title2)
							.padding([.top], 21)
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing:0) {
								VStack(spacing:0){
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
											Text("Level 4")
												.font(.caption)
												.bold()
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
									.frame(width: UIScreen.main.bounds.width*0.8)
									.padding(15)
									
									HStack(spacing:0){
										VStack(alignment: .leading) {
											HStack {
												Text("Playing With the Left Hand")
													.bold()
													.foregroundColor(Color("Dynamic/MainBrown+6"))
												
												Spacer()
												Label("Go to course", systemImage: "arrow.right.circle.fill")
													.labelStyle(.iconOnly)
													.font(.title2)
													.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
											}
											Text("Level 5")
												.font(.caption)
												.bold()
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
									.frame(width: UIScreen.main.bounds.width*0.8)
									.padding(15)
								}
								
								VStack(spacing:0){
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
											Text("Level 6")
												.font(.caption)
												.bold()
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
									.frame(width: UIScreen.main.bounds.width*0.8)
									.padding(15)
									
									HStack(spacing:0){
										VStack(alignment: .leading) {
											HStack {
												Text("Playing With the Left Hand")
													.bold()
													.foregroundColor(Color("Dynamic/MainBrown+6"))
												
												Spacer()
												Label("Go to course", systemImage: "arrow.right.circle.fill")
													.labelStyle(.iconOnly)
													.font(.title2)
													.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
											}
											Text("Level 7")
												.font(.caption)
												.bold()
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
									.frame(width: UIScreen.main.bounds.width*0.8)
									.padding(15)
								}
								
								VStack(spacing:0){
									HStack(spacing:0){
										VStack(alignment: .leading) {
											HStack {
												Text("Playing With the Right Hand")
													.bold()
													.foregroundColor(Color("Dynamic/MainBrown+6"))
												
												Spacer()
												Label("Go to course", systemImage: "arrow.right.circle.fill")
													.labelStyle(.iconOnly)
													.font(.title2)
													.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
											}
											
											Text("Level 8")
												.font(.caption)
												.bold()
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
									.frame(width: UIScreen.main.bounds.width*0.8)
									.padding(15)
									Spacer()
								}
								
								
								
								
								
								
								
								
							}
							
						}
					}
					.background(
						RoundedRectangle(cornerRadius: CGFloat(17))
							.foregroundColor(Color("Dynamic/MainBrown"))
							.opacity(colorScheme == .light ? 0.25 : 0.08)
					)
					.padding([.leading,.trailing], 15)
					//:::::::::::::::::::
					Rectangle()
						.foregroundColor(Color("Dynamic/MainBrown"))
						.opacity(colorScheme == .light ? 0.25 : 0.08)
						.frame(width:5, height:50)
					//::::::::::::::::::
					VStack {
						Text("Play simple melodies and learn new notes")
							.foregroundColor(Color("Dynamic/MainBrown+6"))
							.bold()
							.font(.title2)
							.padding([.top], 21)
						
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing:0) {
								HStack(spacing:0){
									VStack(alignment: .leading) {
										HStack {
											Text("Finger 1 on One String")
												.bold()
												.foregroundColor(Color("Dynamic/MainBrown+6"))
											
											Spacer()
											Label("Go to course", systemImage: "arrow.right.circle.fill")
												.labelStyle(.iconOnly)
												.font(.title2)
												.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
										}
										Text("Level 9")
											.font(.caption)
											.bold()
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
								.frame(width: UIScreen.main.bounds.width*0.8)
								.padding(15)
								
								HStack(spacing:0){
									VStack(alignment: .leading) {
										HStack {
											Text("Finger 2 and 3 on One String")
												.bold()
												.foregroundColor(Color("Dynamic/MainBrown+6"))
											
											Spacer()
											Label("Go to course", systemImage: "arrow.right.circle.fill")
												.labelStyle(.iconOnly)
												.font(.title2)
												.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
										}
										Text("Level 10")
											.font(.caption)
											.bold()
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
								.frame(width: UIScreen.main.bounds.width*0.8)
								.padding(15)
								
								HStack(spacing:0){
									VStack(alignment: .leading) {
										HStack {
											Text("One Finger Melodies with String Crossing")
												.bold()
												.foregroundColor(Color("Dynamic/MainBrown+6"))
											
											Spacer()
											Label("Go to course", systemImage: "arrow.right.circle.fill")
												.labelStyle(.iconOnly)
												.font(.title2)
												.foregroundColor(Color("Dynamic/MainGreen")) // original is "Dynamic/MainBrown"
										}
										Text("Level 11")
											.font(.caption)
											.bold()
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
								.frame(width: UIScreen.main.bounds.width*0.8)
								.padding(15)
								
								
								
								
								
							}
							
						}
					}
					.background(
						RoundedRectangle(cornerRadius: CGFloat(17))
							.foregroundColor(Color("Dynamic/MainBrown"))
							.opacity(colorScheme == .light ? 0.25 : 0.08)
					)
					.padding([.leading,.trailing], 15)
				}
				
				
				
				
				
			}
			
			
		}
		.background(colorScheme == .light ? appBackgroundImage(colorMode: colorScheme) : appBackgroundImage(colorMode: colorScheme))
	}
}

struct LearningPathView1_Previews: PreviewProvider {
    static var previews: some View {
        LearningPathView1()
    }
}

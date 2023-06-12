//
//  AbouSupportView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/6/1.
//

import SwiftUI

struct AbouSupportView: View {
	@Environment(\.verticalSizeClass) var verticalSize
	@Binding var showSupportAbout:Bool
	@Environment(\.colorScheme) var colorScheme
	
	var body: some View {
		VStack {
			HStack {
				Label("Close", systemImage: "chevron.backward")
					.labelStyle(.iconOnly)
					.font(verticalSize == .regular ? .title2 : .title3)
					.foregroundColor(Color("Dynamic/MainBrown+6"))
					.onTapGesture {
						showSupportAbout = false
					}
				if verticalSize != .regular {
					displayLogo()
				}
				Spacer()
			}
			.padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
			
			
			
			
			ScrollView {
				VStack {
					if verticalSize == .regular {
						HStack {
							Spacer()
							displayLogo()
							Spacer()
						}
					}
					
					Text("ScoreWind Support")
						.font(verticalSize == .regular ? .largeTitle : .title3)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.fontWeight(Font.Weight.bold)
						.multilineTextAlignment(.center)
					
					VStack(alignment:.center) {
						Text(getVersionNumber())
							.bold()
							.multilineTextAlignment(.center)
							.font(.title3)
							.foregroundColor(Color("Dynamic/StoreViewTitle"))
						
						Text("If you have any questions about the app or lessons from ScoreWind Teachers, please feel free to contact us at")
							.multilineTextAlignment(.center)
							.padding(.top, 5)
							.foregroundColor(Color("Dynamic/MainBrown+6"))
						
						Link(destination: URL(string: "mailto:scorewind@support.com")!, label: {
							Text("scorewind@support.com")
								.underline()
								.bold()
								.multilineTextAlignment(.center)
								.padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
								.tint(Color("Dynamic/StoreViewTitle"))
								/*.background(Color("ListDivider"))
								.clipShape(Capsule())*/
						})
					}
					.padding(EdgeInsets(top: 10, leading: 15, bottom: 40, trailing: 15))
					
					Divider()
					
					Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!, label: {
						Text("Terms & Conditions")
							.underline()
							.bold()
							.multilineTextAlignment(.center)
							.padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15))
							.tint(Color("Dynamic/StoreViewTitle"))
							.font(.subheadline)
					})
					
					Link(destination: URL(string: "https://scorewind.com/privacy.html")!, label: {
						Text("Privacy Policy")
							.underline()
							.bold()
							.multilineTextAlignment(.center)
							.padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15))
							.tint(Color("Dynamic/StoreViewTitle"))
							.font(.subheadline)
					})
					
					Divider()
					
					Text("Meet Our Teachers")
						.font(verticalSize == .regular ? .largeTitle : .title3)
						.foregroundColor(Color("Dynamic/MainBrown+6"))
						.fontWeight(Font.Weight.bold)
						.multilineTextAlignment(.center)
						.padding(.top,40)
					
					VStack {
						Text("Ricardo Alves Pereira")
							.bold()
							.font(.title2)
							.foregroundColor(Color("Dynamic/StoreViewTitle"))
							.padding(.top, 10)
						
						HStack {
							Spacer()
							Image("teacher-ricardo")
								.resizable()
								.scaledToFit()
								.cornerRadius(26)
							Spacer()
						}.frame(maxWidth: verticalSize == .regular ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height)
						
						Text("Ricardo Alves Pereira is a dedicated educator who brings the world of academia to students from diverse backgrounds. During a rich musical journey, Ricardo has traveled throughout Europe in pursuit of the best education on his instrument and learned from the living legends of classical guitar. Prior to ScoreWind, Ricardo has taught classical guitar in prestigious conservatories and many music schools that trained students for further education on classical guitar. ")
							.fontWeight(Font.Weight.semibold)
							.padding([.leading,.trailing], 15)
							.foregroundColor(Color("Dynamic/MainBrown+6"))
						HStack {
							musicLink(labelText: "Listen on Spotify", labelIconName: "icon-spotify", urlText: "https://open.spotify.com/artist/7D7x8UG2oPE8pG5t9FDJrF?si=UuDX3OvxTze1agPcSb_Mxw")
							musicLink(labelText: "Listen on YouTube", labelIconName: "icon-youtube", urlText: "https://www.youtube.com/channel/UC7uaVVd7tYq6Pr_XKlIlPpQ")
							Spacer()
						}.padding([.leading,.trailing], 15)
						
						
						Text("Esin Yardimli Alves Pereira")
							.bold()
							.font(.title2)
							.foregroundColor(Color("Dynamic/StoreViewTitle"))
							.padding(.top, 28)
						HStack {
							Spacer()
							Image("teacher-esin")
								.resizable()
								.scaledToFit()
								.cornerRadius(26)
							Spacer()
						}.frame(maxWidth: verticalSize == .regular ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height)
						Text("Esin Yardimli Alves Pereira is a dynamic instructor who seamlessly combines classical mastery with a passion for diverse musical genres. Over the course of more than two decades of international conservatory training and invaluable masterclasses from renowned performers, she enriched her expertise in classical music and jazz. With a keen focus on healthy posture, she guides a global community of students pursuing individual musical paths, including those actively engaged in classical music academia.")
							.fontWeight(Font.Weight.semibold)
							.padding([.leading,.trailing], 15)
							.foregroundColor(Color("Dynamic/MainBrown+6"))
						HStack {
							musicLink(labelText: "Listen on Spotify", labelIconName: "icon-spotify", urlText: "https://open.spotify.com/artist/4lb0t65W3fLoYa7MS0TKn6?si=QL3XeH-uTI6-gcGhWMj7IQ")
							musicLink(labelText: "Listen on YouTube", labelIconName: "icon-youtube", urlText: "https://www.youtube.com/channel/UCgyuqKiLT8-GvNtXPvCqDlw")
							Spacer()
						}.padding([.leading,.trailing], 15)
						Spacer().frame(height: 50)
					}
					Spacer()
				}
			}

		}
		.background(colorScheme == .light ? appBackgroundImage(colorMode: colorScheme) : appBackgroundImage(colorMode: colorScheme))
	}
	
	private func getVersionNumber() -> String {
		//:: CFBundleVersion for build number
		return "Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")  as! String)\nBuild \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")  as! String)"
		//return UIApplication.appVer
	}
	
	@ViewBuilder
	private func musicLink(labelText:String, labelIconName:String, urlText:String) -> some View {
		Link(destination: URL(string: urlText)!, label: {
			Label(title: {Text(labelText)}, icon: {
				Image(labelIconName)
					.resizable()
					.scaledToFit()
					.frame(maxWidth: 50)
			})
			.labelStyle(.iconOnly)
			.padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
			.foregroundColor(Color("Dynamic/MainBrown+6"))
			.background(
				Circle()
					.strokeBorder(Color("Dynamic/DarkGray"), lineWidth: 1)
					.background(
						Circle()
							.fill(Color("Dynamic/MainBrown"))
							.opacity(0.55)
							.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(10))
					)
					
			)
		})
	}
	
	@ViewBuilder
	private func displayLogo() -> some View {
		if colorScheme == .light {
			Image("logo")
				.resizable()
				.scaledToFit()
				.frame(maxWidth: verticalSize == .regular ? 46 : 23)
		} else {
			Image("logo")
				.resizable()
				.scaledToFit()
				.frame(maxWidth: verticalSize == .regular ? 46 : 23)
				.padding(verticalSize == .regular ? 15 : 5)
				.background(
					RoundedRectangle(cornerRadius: CGFloat(17))
						.foregroundColor(Color("AppYellow"))
						.shadow(color: Color("Dynamic/Shadow"),radius: CGFloat(5))
						.overlay {
							RoundedRectangle(cornerRadius: 17)
								.stroke(Color("Dynamic/ShadowReverse"), lineWidth: 1)
						}
				)
		}
	}
}

struct AbouSupportView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			AbouSupportView(showSupportAbout: .constant(false))
				.environment(\.colorScheme, .light)
				.previewDisplayName("Light Portrait")
			AbouSupportView(showSupportAbout: .constant(false))
				.environment(\.colorScheme, .dark)
				.previewDisplayName("Dark Portrait")
		}
		
	}
}

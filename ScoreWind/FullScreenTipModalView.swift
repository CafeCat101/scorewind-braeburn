//
//  FullScreenTipModalView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2023/1/18.
//

import SwiftUI

struct FullScreenTipModalView: View {
	@Environment(\.presentationMode) var presentationMode
	@EnvironmentObject var scorewindData:ScorewindData
	private var userDefaults = UserDefaults.standard
	@Binding var tipView: AnyView
	

	var body: some View {
		VStack {
			/*
			Button(action: {
				presentationMode.wrappedValue.dismiss()
			}, label: {
				VStack {
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(Color.black)//.foregroundColor(Color.white)
				.opacity(0.6)
				.overlay(content: {
					tipView
				})
			})
			 */
			VStack {
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color.black)//.foregroundColor(Color.white)
			.opacity(0.6)
			.overlay(content: {
				VStack{
					Spacer()
					tipView
					Spacer()
					VStack{
						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}, label: {
							Text("Don't show me again")
						}).foregroundColor(Color("LessonSheet"))
							.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
							 .background {
								 RoundedRectangle(cornerRadius: 26)
									 .foregroundColor(Color("BadgeScoreAvailable"))
							 }
						
						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}, label: {
							Text("OK")
						})
						.foregroundColor(Color("LessonSheet"))
						.padding(EdgeInsets(top: 18, leading: 26, bottom: 18, trailing: 26))
						.background {
							RoundedRectangle(cornerRadius: 26)
								.foregroundColor(Color("BadgeScoreAvailable"))
						}
					}
				}
				
			})
			.onTapGesture {
				presentationMode.wrappedValue.dismiss()
			}
		}
		.background(BackgroundCleanerView())
	}
	
	struct BackgroundCleanerView: UIViewRepresentable {
		func makeUIView(context: Context) -> UIView {
			let view = UIView()
			DispatchQueue.main.async {
				view.superview?.superview?.backgroundColor = .clear
			}
			return view
		}
		
		func updateUIView(_ uiView: UIView, context: Context) {}
	}
}

/*
 struct FullScreenTipModalView_Previews: PreviewProvider {
 @State static var tipView = AnyView(Text("hello")
 static var previews: some View {
 FullScreenTipModalView(selectedTab: $tab, stepName: $step, studentData: StudentData()).environmentObject(ScorewindData())
 }
 static var previews: some View {
 
 FullScreenTipModalView( tipView: $tipView).environmentObject(ScorewindData()
 }
 }
 */

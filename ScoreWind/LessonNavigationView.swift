//
//  LessonNavigationView.swift
//  ScoreWind
//
//  Created by Leonore Yardimli on 2022/8/8.
//

import SwiftUI

struct LessonNavigationView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@ObservedObject var downloadManager:DownloadManager
	var body: some View {
		NavigationView {
			NavigationLink(destination: LessonNowView(downloadManager: downloadManager)) {
				LessonNowView(downloadManager: downloadManager)
			}
			.navigationBarTitle("")
			.navigationBarHidden(true)
		}
	}
}

struct LessonNavigationView_Previews: PreviewProvider {
	static var previews: some View {
		LessonNavigationView(downloadManager: DownloadManager()).environmentObject(ScorewindData())
	}
}
